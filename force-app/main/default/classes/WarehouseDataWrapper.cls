public class WarehouseDataWrapper {
    
    public Id warehouseId;
    private Warehouse__c warehouse;
    private List<Id> emptyCellIdsOrderedList;
    private Map<Id, CellDataWrapper> cellIdToDataWrapperMap;
    private Map<Id, CellDataWrapper> emptyCellsMap;
    private Map<String, Id> cellAddressToIdMap;

    public WarehouseDataWrapper(Id warehouseId, List<Cell__c> cells) {

        this.warehouseId = warehouseId;
        this.emptyCellIdsOrderedList = new List<Id>();
        this.cellIdToDataWrapperMap = new Map<Id, CellDataWrapper>();
        this.emptyCellsMap = new Map<Id, CellDataWrapper>();
        this.cellAddressToIdMap = new Map<String, Id>();

        if (String.isBlank(warehouseId)) {
            return;
        }

        for (Cell__c cell_i : cells) {
            
            if (cell_i.Warehouse__c != warehouseId) {
                continue;
            }

            if (this.warehouse == null) {
                this.warehouse = (Warehouse__c) cell_i.getSObject('Warehouse__r');
            }

            cellAddressToIdMap.put(cell_i.Address__c, cell_i.Id);

            CellDataWrapper cdw = new CellDataWrapper(cell_i);

            if (cdw.getContainer() == null) {
                emptyCellIdsOrderedList.add(cdw.cellId);
                emptyCellsMap.put(cdw.cellId, cdw);
            }
            
            cellIdToDataWrapperMap.put(cdw.cellId, cdw);
        }
    }

    public CellDataWrapper getEmptyCell() {

        if (emptyCellIdsOrderedList.isEmpty()) {
            return null;
        }

        return emptyCellsMap.get(emptyCellIdsOrderedList.get(0));
    }

    public Integer getAmountOfEmptyCells() {
        return emptyCellIdsOrderedList.size();
    }

    public void placeContainerToCell(Container__c container, CellDataWrapper cdw) {

        cellIdToDataWrapperMap.get(cdw.cellId).setContainer(container);
        emptyCellsMap.remove(cdw.cellId);

        Integer elementIndex = emptyCellIdsOrderedList.indexOf(cdw.cellId);
        if (elementIndex != -1) {
            emptyCellIdsOrderedList.remove(elementIndex);
        }
    }

    public CellDataWrapper getPreviousCell(CellDataWrapper currentCell) {

        String addressOfThePreviousCell = currentCell.getAddressOfThePreviousCell();

        if (String.isBlank(addressOfThePreviousCell) || !cellAddressToIdMap.containsKey(addressOfThePreviousCell)) {
            return null;
        }

        return cellIdToDataWrapperMap.get(cellAddressToIdMap.get(addressOfThePreviousCell));
    }

    public Integer getLevel() {
        return Integer.valueOf(warehouse.Level__c);
    }

    public Integer getWidth() {
        return Integer.valueOf(warehouse.Width__c);
    }

    public Integer getLength() {
        return Integer.valueOf(warehouse.Length__c);
    }
}