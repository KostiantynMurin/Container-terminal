global without sharing class ContainerDistributionBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Integer containerToDistributeCount;
    private Date currentDate;
    private Integer containerCounter = 0;
    private Integer daysCounter = 0;
    
    public ContainerDistributionBatch() {
        this.currentDate = DateHelper.getNextMonday(Date.today());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<AggregateResult> result = [SELECT COUNT(Id) ContainersCount FROM Container__c WHERE Status__c = :ContainerHelper.STATUS_DELIVERY_ARRIVED];
        this.containerToDistributeCount = Integer.valueOf(result[0].get('ContainersCount'));

        String query = 'SELECT Id, Name, Status__c, Delivery_Date__c FROM Container__c WHERE Status__c = \'' + ContainerHelper.STATUS_DELIVERY_ARRIVED + '\' OR Status__c = \'' + ContainerHelper.STATUS_LOAD_ARRIVED + '\'';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Container__c> scope) { 
        
        Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap = getCellsMap();

        for(Container__c container : scope) {
            if (container.Status__c == ContainerHelper.STATUS_DELIVERY_ARRIVED) {
                processDeliveryContainer(container, cellsMap);
            } else if (container.Status__c == ContainerHelper.STATUS_LOAD_ARRIVED) {
                processLoadContainer(container, cellsMap);
            }
        }

        update scope;
    }   

    private void processDeliveryContainer(Container__c container, Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap) {

        Date deliveryDate = getNextDistributionDate();
        CellWrapper cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_LOAD_WAITING, deliveryDate);

        if (cellWrapper == null) {
            recombineLoadCells(cellsMap, 1);
            cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_LOAD_WAITING, deliveryDate);
        }

        if (cellWrapper == null) {
            recombineLoadCells(cellsMap, 2);
            cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_LOAD_WAITING, deliveryDate);
        }

        if (cellWrapper == null) {
            recombineDeliveryCells(cellsMap, 1);
            cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_LOAD_WAITING, deliveryDate);
        }

        if (cellWrapper == null) {
            recombineDeliveryCells(cellsMap, 2);
            cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_LOAD_WAITING, deliveryDate);
        }
        
        if (cellWrapper != null) {
            System.debug('Found cell ' + cellWrapper.cell.Code__c + ' for container ' + container.Name);
            container.Status__c = ContainerHelper.STATUS_DELIVERY_WAITING;
            container.Delivery_Date__c = deliveryDate;
            container.Cell__c = cellWrapper.cell.Id;
            cellWrapper.container = container;
        }
        else {
            System.debug('No cell found for container ' + container.Name);
        }
    }

    private void processLoadContainer(Container__c container, Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap) {

        Date deliveryDate = DateHelper.getNextSunday(Date.today());
        CellWrapper cellWrapper = getNextAvailableCell(cellsMap, ContainerHelper.STATUS_DELIVERY_WAITING, deliveryDate);
        
        if (cellWrapper != null) {
            System.debug('Found cell ' + cellWrapper.cell.Code__c + ' for container ' + container.Name);
            container.Status__c = ContainerHelper.STATUS_LOAD_WAITING;
            container.Delivery_Date__c = deliveryDate;
            container.Cell__c = cellWrapper.cell.Id;
            cellWrapper.container = container;
        }
        else {
            System.debug('No cell found for container ' + container.Name);
        }
    }

    private Date getNextDistributionDate() {
        Integer containersPerDay = this.containerToDistributeCount / 5;

        Date result = this.currentDate;

        this.containerCounter++;
        if(this.containerCounter == containersPerDay && this.daysCounter < 4) {
            this.currentDate = this.currentDate.addDays(1);
            this.containerCounter = 0;
            this.daysCounter++;
        }

        return result;
    }

    private Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> getCellsMap() {
        List<Cell__c> allCells = [
            SELECT Id, Code__c, Row__c, Column__c, Level__c, Container__c, Container__r.Name, Container__r.Status__c, Container__r.Delivery_Date__c, Container__r.Cell__c
            FROM Cell__c 
            ORDER BY Row__c, Column__c, Level__c
        ];

        Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap = new Map<String, Map<Decimal, Map<Decimal, CellWrapper>>>();

        for(Cell__c cell : allCells) {
            if(!cellsMap.containsKey(cell.Row__c)) {
                cellsMap.put(cell.Row__c, new Map<Decimal, Map<Decimal, CellWrapper>>());
            }

            if(!cellsMap.get(cell.Row__c).containsKey(cell.Column__c)) {
                cellsMap.get(cell.Row__c).put(cell.Column__c, new Map<Decimal, CellWrapper>());
            }

            cellsMap.get(cell.Row__c).get(cell.Column__c).put(cell.Level__c, new CellWrapper(cell));
        }

        return cellsMap;
    }

    private CellWrapper getNextAvailableCell(Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap, String filterStatus, Date filterDate) {
        for(String row : cellsMap.keySet()) {
            if (!cellsMap.containsKey(row)) continue;
            
            for(Decimal column : cellsMap.get(row).keySet()) {
                if (!cellsMap.get(row).containsKey(column)) continue;

                if (cellsMap.get(row).get(column).containsKey(0) && cellsMap.get(row).get(column).get(0).container == null) {
                    for(Decimal level : cellsMap.get(row).get(column).keySet()) {
                        return cellsMap.get(row).get(column).get(level);
                    }
                } else {
                    for(Decimal level : cellsMap.get(row).get(column).keySet()) {
                        CellWrapper cellWrapper = cellsMap.get(row).get(column).get(level);
                        if(cellWrapper.container != null) {
                            if (filterStatus != null && cellWrapper.container.Status__c == filterStatus)
                                break;
                            else if (cellWrapper.container.Delivery_Date__c < filterDate)
                                break;
                            else 
                                continue;
                        }

                        return cellsMap.get(row).get(column).get(level);
                    }
                }
            }
        }

        return null;
    }

    private void recombineLoadCells(Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap, Integer containersCount) {
        
        List<CellWrapper> recipients = new List<CellWrapper>();
        List<CellWrapper> donors = new List<CellWrapper>();

        for(String row : cellsMap.keySet()) {
            if (!cellsMap.containsKey(row)) continue;
            
            for(Decimal column : cellsMap.get(row).keySet()) {
                if (!cellsMap.get(row).containsKey(column)) continue;

                List<CellWrapper> loadCells = new List<CellWrapper>();
                List<CellWrapper> emptyCells = new List<CellWrapper>();
                for (Decimal level : cellsMap.get(row).get(column).keySet()) {
                    CellWrapper cellWrapper = cellsMap.get(row).get(column).get(level);
                    if (cellWrapper.container != null && cellWrapper.container.Status__c == ContainerHelper.STATUS_LOAD_WAITING) {
                        loadCells.add(cellWrapper);
                    } else if (cellWrapper.container == null && loadCells.size() > 0) {
                        emptyCells.add(cellWrapper);
                    } else {
                        loadCells.clear();
                        emptyCells.clear();
                    }
                }

                if (donors.size() == 0 && loadCells.size() == containersCount){
                    donors = loadCells;
                } else if (emptyCells.size() >= containersCount && (recipients.size() == 0 || recipients.size() > emptyCells.size())) {
                    recipients = emptyCells;
                } 
            }
        }

        if (donors.size() > 0 && recipients.size() > 0) {
            List<Container__c> containersToUpdate = new List<Container__c>();
            for (Integer i = 0; i < donors.size(); i++) {
                Integer donorIndex = donors.size() - i - 1;
                System.debug('Moving container ' + donors[donorIndex].container.Name + ' from cell ' + donors[donorIndex].cell.Code__c + ' to cell ' + recipients[i].cell.Code__c);
                recipients[i].container = donors[donorIndex].container;
                recipients[i].container.Cell__c =  recipients[i].cell.Id;
                donors[donorIndex].container = null;
                containersToUpdate.add(recipients[i].container);
            }

            update containersToUpdate;
        }
    }

    private void recombineDeliveryCells(Map<String, Map<Decimal, Map<Decimal, CellWrapper>>> cellsMap, Integer containersCount) {
        
        List<CellWrapper> recipients = new List<CellWrapper>();
        List<CellWrapper> donors = new List<CellWrapper>();
        Date maxDelivaryDate = Date.newInstance(1970, 1, 1);
        Date maxDonorDelivaryDate = Date.newInstance(1970, 1, 1);

        for(String row : cellsMap.keySet()) {
            if (!cellsMap.containsKey(row)) continue;
            
            for(Decimal column : cellsMap.get(row).keySet()) {
                if (!cellsMap.get(row).containsKey(column)) continue;

                List<CellWrapper> loadCells = new List<CellWrapper>();
                List<CellWrapper> emptyCells = new List<CellWrapper>();
                for (Decimal level : cellsMap.get(row).get(column).keySet()) {
                    CellWrapper cellWrapper = cellsMap.get(row).get(column).get(level);
                    if (cellWrapper.container != null && cellWrapper.container.Status__c == ContainerHelper.STATUS_DELIVERY_WAITING) {
                        loadCells.add(cellWrapper);
                    } else if (cellWrapper.container == null && loadCells.size() > 0) {
                        emptyCells.add(cellWrapper);
                    } else {
                        loadCells.clear();
                        emptyCells.clear();
                    }
                }

                Date currentDeliveryDate = loadCells[loadCells.size() - 1].container.Delivery_Date__c;
                if (emptyCells.size() >= containersCount && (recipients.size() == 0 || currentDeliveryDate > maxDelivaryDate)) {
                    recipients = emptyCells;
                    maxDelivaryDate = currentDeliveryDate;
                } 
            }
        }

        for(String row : cellsMap.keySet()) {
            if (!cellsMap.containsKey(row)) continue;
            
            for(Decimal column : cellsMap.get(row).keySet()) {
                if (!cellsMap.get(row).containsKey(column)) continue;

                List<CellWrapper> loadCells = new List<CellWrapper>();
                List<CellWrapper> emptyCells = new List<CellWrapper>();
                for (Decimal level : cellsMap.get(row).get(column).keySet()) {
                    CellWrapper cellWrapper = cellsMap.get(row).get(column).get(level);
                    if (cellWrapper.container != null && cellWrapper.container.Status__c == ContainerHelper.STATUS_DELIVERY_WAITING) {
                        loadCells.add(cellWrapper);
                    } else if (cellWrapper.container == null && loadCells.size() > 0) {
                        emptyCells.add(cellWrapper);
                    } else {
                        loadCells.clear();
                        emptyCells.clear();
                    }
                }

                Date currentDeliveryDate = loadCells[loadCells.size() - 1].container.Delivery_Date__c;
                if (loadCells.size() == containersCount && (donors.size() == 0 || currentDeliveryDate > maxDonorDelivaryDate && currentDeliveryDate < maxDelivaryDate)){
                    donors = loadCells;
                    maxDonorDelivaryDate = currentDeliveryDate;
                } 
            }
        }


        if (donors.size() > 0 && recipients.size() > 0) {
            List<Container__c> containersToUpdate = new List<Container__c>();
            for (Integer i = 0; i < donors.size(); i++) {
                Integer donorIndex = donors.size() - i - 1;
                System.debug('Moving container ' + donors[donorIndex].container.Name + ' from cell ' + donors[donorIndex].cell.Code__c + ' to cell ' + recipients[i].cell.Code__c);
                recipients[i].container = donors[donorIndex].container;
                recipients[i].container.Cell__c =  recipients[i].cell.Id;
                donors[donorIndex].container = null;
                containersToUpdate.add(recipients[i].container);
            }

            update containersToUpdate;
        }
    }
 
    global void finish(Database.BatchableContext BC){}

    private class CellWrapper {
        public Cell__c cell;
        public Container__c container;

        public CellWrapper(Cell__c cell) {
            this.cell = cell;
            this.container = cell.Container__r;
        }
    }
}