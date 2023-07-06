public class WarehousesDataService {
    
    private static String cellsQueryBase = 'SELECT Id'
                                              + ', Address__c'
                                              + ', Length__c'
                                              + ', Width__c'
                                              + ', Level__c'
                                              + ', Warehouse__c'
                                              + ', Warehouse__r.Length__c'
                                              + ', Warehouse__r.Width__c'
                                              + ', Warehouse__r.Level__c'
                                              + ', (SELECT Id, Status__c FROM Containers__r)'
                                        + ' FROM Cell__c'
                                        + ' WHERE Warehouse__r.RecordTypeId =: rtId';
    private static WarehousesDataService instance;
    private Id bufferZoneRTId;
    private Id warehouseRTId;
    private CellDataWrapper bufferZoneCell;
    private Map<Id, WarehouseDataWrapper> warehouseIdToDataWrapperMap;
    private List<Id> warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells;
    private Id currentWarehouseWithEmptyCells;

    public class WarehousesDataWrapperException extends Exception {}

    private WarehousesDataService() {
        Map<String, Schema.RecordTypeInfo> devNameToRecordTypeInfoMap = Schema.SObjectType.Warehouse__c.getRecordTypeInfosByDeveloperName();
        this.bufferZoneRTId = devNameToRecordTypeInfoMap.get('Buffer_Zone').getRecordTypeId();
        this.warehouseRTId = devNameToRecordTypeInfoMap.get('Warehouse').getRecordTypeId();
        initData();
    }

    public static WarehousesDataService getInstance() {
        if(instance == null) {
            instance = new WarehousesDataService();
        }
        return instance;
    }

    public void refreshData() {
        initData();
    }

    public CellDataWrapper getEmptyCell() {

        if (warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.isEmpty()) {
            return bufferZoneCell;
        }

        if (currentWarehouseWithEmptyCells == null) {
            setCurrentWarehouseWithEmptyCells();
        }

        CellDataWrapper cell = warehouseIdToDataWrapperMap.get(currentWarehouseWithEmptyCells).getEmptyCell();
        return cell;
    }

    public CellDataWrapper getEmptyCellForShipmentContainer(Id warehouseId) {
        
        if (bufferZoneCell.warehouseId == warehouseId || warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.isEmpty()) {
            return bufferZoneCell;
        }

        if (warehouseId == null || !warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.contains(warehouseId)) {
            warehouseId = currentWarehouseWithEmptyCells;
        }

        WarehouseDataWrapper wdw = warehouseIdToDataWrapperMap.get(warehouseId);
        CellDataWrapper emptyCellForShipmentContainer = wdw.getEmptyCellForShipmentContainer();

        if (emptyCellForShipmentContainer != null) {
            return emptyCellForShipmentContainer;
        }

        for (Id warehouseId_i : warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells) {
            
            if (warehouseId == warehouseId_i) {
                continue;
            }

            wdw = warehouseIdToDataWrapperMap.get(warehouseId);
            emptyCellForShipmentContainer = wdw.getEmptyCellForShipmentContainer();

            if (emptyCellForShipmentContainer != null) {
                break;
            }
        }

        if (emptyCellForShipmentContainer != null) {
            return emptyCellForShipmentContainer;
        }

        return bufferZoneCell;
    }

    public CellDataWrapper getPreviousCell(CellDataWrapper currentCell) {
        return warehouseIdToDataWrapperMap.get(currentCell.warehouseId).getPreviousCell(currentCell);
    }

    public CellDataWrapper getNextCell(CellDataWrapper currentCell) {
        return warehouseIdToDataWrapperMap.get(currentCell.warehouseId).getNextCell(currentCell);
    }

    public CellDataWrapper getCell(Id warehouseId, Id cellId) {
        return warehouseIdToDataWrapperMap.get(warehouseId).getCell(cellId);
    }

    public Integer getMaxLevelOfTheCurrentWherhouse() {
        return warehouseIdToDataWrapperMap.get(currentWarehouseWithEmptyCells).getLevel();
    }

    public void placeContainerToCell(Container__c container, CellDataWrapper cell) {

        if (cell.cellId == bufferZoneCell.cellId) {
            container.Warehouse_Cell__c = cell.cellId;
            return;
        }

        WarehouseDataWrapper wdw = warehouseIdToDataWrapperMap.get(cell.warehouseId);
        wdw.placeContainerToCell(container, cell);

        if (wdw.getAmountOfEmptyCells() == 0) {

            Integer elementIndex = warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.indexOf(wdw.warehouseId);
            if (elementIndex != -1) {
                warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.remove(elementIndex);
            }
            setCurrentWarehouseWithEmptyCells();
        }
    }

    public void removeContainerFromCell(Container__c container, CellDataWrapper cell) {

        if (cell.cellId == bufferZoneCell.cellId) {
            container.Warehouse_Cell__c = null;
            return;
        }

        warehouseIdToDataWrapperMap.get(cell.warehouseId).removeContainerFromCell(container, cell);
        setWarehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells();
    }

    private void initData() {

        setBufferZoneCell();
        setWarehouseIdToDataWrapperMap();
        setWarehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells();
        setCurrentWarehouseWithEmptyCells();
    }

    private void setBufferZoneCell() {
        this.bufferZoneCell = getBufferZoneCell();
    }

    private CellDataWrapper getBufferZoneCell() {

        String query = cellsQueryBase;
        query = query.replace('rtId', 'bufferZoneRTId');

        List<Cell__c> bufferCells = Database.query(query);

        Cell__c cell;
        if (bufferCells.isEmpty()) {
            insert new Warehouse__c(Name = 'Buffer Zone', RecordTypeId = bufferZoneRTId);
            cell = (Cell__c) Database.query(query);
        } else {
            cell = bufferCells.get(0);
        }

        return new CellDataWrapper(cell);
    }

    private void setWarehouseIdToDataWrapperMap() {
        this.warehouseIdToDataWrapperMap = getWarehouseIdToDataWrapperMap();
    }

    private Map<Id, WarehouseDataWrapper> getWarehouseIdToDataWrapperMap() {

        String query = cellsQueryBase;
        query = query.replace('rtId', 'warehouseRTId');
        query += ' ORDER BY Warehouse__c, Address__c';

        Map<Id, List<Cell__c>> warehouseIdToCellsMap = new Map<Id, List<Cell__c>>();

        for (Cell__c cell_i : Database.query(query)) {
            
            if (!warehouseIdToCellsMap.containsKey(cell_i.Warehouse__c)) {
                warehouseIdToCellsMap.put(cell_i.Warehouse__c, new List<Cell__c>());
            }
            warehouseIdToCellsMap.get(cell_i.Warehouse__c).add(cell_i);
        }

        if (warehouseIdToCellsMap.isEmpty()) {
            throw new WarehousesDataWrapperException('You need to create at least one Warehouse record with Warehouse record type');
        }

        Map<Id, WarehouseDataWrapper> warehouseIdToDataWrapperMap = new Map<Id, WarehouseDataWrapper>();

        for (Id warehouseId_i : warehouseIdToCellsMap.keySet()) {
            warehouseIdToDataWrapperMap.put(warehouseId_i, new WarehouseDataWrapper(warehouseId_i, warehouseIdToCellsMap.get(warehouseId_i)));
        }

        return warehouseIdToDataWrapperMap;
    }

    private void setWarehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells() {
        this.warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells = getWarehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells();
    }

    private List<Id> getWarehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells() {

        List<Id> warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells = new List<Id>();

        if (warehouseIdToDataWrapperMap.isEmpty()) {
            return warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells;
        }

        Map<Integer, List<Id>> amountOfEmptyCellsToWarehouseIdsMap = new Map<Integer, List<Id>>();

        for (WarehouseDataWrapper wdw_i : warehouseIdToDataWrapperMap.values()) {
            
            Integer amountOfEmptyCells = wdw_i.getAmountOfEmptyCells();

            if (amountOfEmptyCells == 0) {
                continue;
            }

            if (!amountOfEmptyCellsToWarehouseIdsMap.containsKey(amountOfEmptyCells)) {
                amountOfEmptyCellsToWarehouseIdsMap.put(amountOfEmptyCells, new List<Id>());
            }
            amountOfEmptyCellsToWarehouseIdsMap.get(amountOfEmptyCells).add(wdw_i.warehouseId);
        }

        if (amountOfEmptyCellsToWarehouseIdsMap.isEmpty()) {
            return warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells;
        }

        List<Integer> orderedAmounts = new List<Integer>(amountOfEmptyCellsToWarehouseIdsMap.keySet());
        orderedAmounts.sort();

        for (Integer amountOfEmptyCells_i : orderedAmounts) {
            warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.addAll(amountOfEmptyCellsToWarehouseIdsMap.get(amountOfEmptyCells_i));
        }

        return warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells;
    }

    private void setCurrentWarehouseWithEmptyCells() {
        this.currentWarehouseWithEmptyCells = getCurrentWarehouseWithEmptyCells();
    }

    private Id getCurrentWarehouseWithEmptyCells() {

        if (warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.isEmpty()) {
            return null;
        }

        return warehouseIdsWithEmptyCellsOrderedByAmountOfEmptyCells.get(0);
    }
}