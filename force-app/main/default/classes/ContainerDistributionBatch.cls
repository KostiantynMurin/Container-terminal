public class ContainerDistributionBatch implements Database.Batchable<Container__c>, Database.Stateful {
    
    private Integer currentDayNumber;
    private Integer amountOfContainersForCurrentDay;
    private Date dateOfCurrentDay;
    private Map<Integer, Integer> dayNumberToAmountOfContainers;
    private Map<Integer, Date> dayNumberToDate;
    private WarehousesDataService whDataService;

    public Iterable<Container__c> start(Database.BatchableContext bc) {

        List<Container__c> containers = [
            SELECT Id
            FROM Container__c
            WHERE Status__c = 'Arrived For Delivery'
            AND Warehouse_Cell__c = null
            ORDER BY Contact_Ext_Id__c
        ];

        if (containers.isEmpty()) {
            return containers;
        }

        Integer numberOfDays = 5;
        Decimal amountOfContainers = (Decimal) containers.size();

        Decimal amountOfContainersPerDayRaw = amountOfContainers / numberOfDays;
        amountOfContainersPerDayRaw = amountOfContainersPerDayRaw.setScale(0);

        Integer amountOfContainersPerDay = amountOfContainersPerDayRaw.intValue() == 0 ? 1 : amountOfContainersPerDayRaw.intValue();
        Integer amountOfContainersForLastDay = amountOfContainersPerDay;

        Integer delta = amountOfContainers.intValue() - (amountOfContainersPerDay * numberOfDays);

        if (delta != 0) {
            amountOfContainersForLastDay = amountOfContainersForLastDay + delta;
        }
        
        if (amountOfContainersForLastDay <= 0) {

            if (amountOfContainersForLastDay == 0) {
                numberOfDays--;
            } else if (amountOfContainersForLastDay < 0) {
                
                do {
                    numberOfDays--;
                    amountOfContainersForLastDay = amountOfContainersPerDay + amountOfContainersForLastDay;
                } while (amountOfContainersForLastDay < 1);
            }

            amountOfContainersForLastDay = amountOfContainersPerDay;
        }

        dayNumberToDate = new Map<Integer, Date>();
        dayNumberToAmountOfContainers = new Map<Integer, Integer>();

        for (Integer i = 1; i < numberOfDays + 1; i++) {

            dayNumberToDate.put(i, Date.today().addDays(i + 1));

            Integer amount = amountOfContainersPerDay;

            if (i == numberOfDays) {
                amount = amountOfContainersForLastDay;
            }

            dayNumberToAmountOfContainers.put(i, amount);
        }

        currentDayNumber = numberOfDays;
        amountOfContainersForCurrentDay = dayNumberToAmountOfContainers.get(currentDayNumber);
        dateOfCurrentDay = dayNumberToDate.get(currentDayNumber);

        whDataService = WarehousesDataService.getInstance();

        return containers;
    }

    public void execute(Database.BatchableContext BC, List<Container__c> scope) {

        Map<Id, Container__c> containersToUpdateMap = new Map<Id, Container__c>();

        Integer lastContainerIndex = scope.size() - 1;

        for (Integer i = 0; i < scope.size(); i++) {
            
            recalculateDistibutionValues();
            amountOfContainersForCurrentDay--;

            Container__c container_i = scope.get(i);

            CellDataWrapper currentEmptyCell = whDataService.getEmptyCell();

            container_i.Date_Of_Issue__c = dateOfCurrentDay;
            container_i.Status__c = 'Waiting For Delivery';

            if (currentEmptyCell.getLevel() == 1) {
                whDataService.placeContainerToCell(container_i, currentEmptyCell);
                containersToUpdateMap.put(container_i.Id, container_i);
                continue;
            }

            CellDataWrapper previousCell = whDataService.getPreviousCell(currentEmptyCell);

            if (!previousCell.isContainerForShipment()) {
                whDataService.placeContainerToCell(container_i, currentEmptyCell);
                containersToUpdateMap.put(container_i.Id, container_i);
                continue;
            }

            Integer levelOfThePreviousCell = previousCell.getLevel();

            List<CellDataWrapper> cellsWithContainersForShipment = new List<CellDataWrapper>{previousCell};
            
            for (Integer j = levelOfThePreviousCell; j > 1; j--) {

                CellDataWrapper previousCell_j = whDataService.getPreviousCell(cellsWithContainersForShipment.get(levelOfThePreviousCell - j));

                if (!previousCell_j.isContainerForShipment()) {
                    break;
                }

                cellsWithContainersForShipment.add(previousCell_j);
            }

            Container__c currentContainerToPlace = container_i;

            for (Integer j = cellsWithContainersForShipment.size() - 1; j > -1; j--) {

                CellDataWrapper lowestCell = cellsWithContainersForShipment.get(j);

                Container__c currentContainerOfTheLowestCell = lowestCell.getContainer();

                whDataService.placeContainerToCell(currentContainerToPlace, lowestCell);
                containersToUpdateMap.put(currentContainerToPlace.Id, currentContainerToPlace);

                currentContainerToPlace = currentContainerOfTheLowestCell;
            }

            whDataService.placeContainerToCell(currentContainerToPlace, currentEmptyCell);
            containersToUpdateMap.put(currentContainerToPlace.Id, currentContainerToPlace);
        }

        update containersToUpdateMap.values();
    }

    private void recalculateDistibutionValues() {

        if (amountOfContainersForCurrentDay != 0) {
            return;
        }

        currentDayNumber--;
        amountOfContainersForCurrentDay = dayNumberToAmountOfContainers.get(currentDayNumber);
        dateOfCurrentDay = dayNumberToDate.get(currentDayNumber);
    }

    public void finish(Database.BatchableContext BC) {

    }
}