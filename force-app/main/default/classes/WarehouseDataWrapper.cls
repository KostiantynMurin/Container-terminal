public class WarehouseDataWrapper {
    
    public Id warehouseId;
    private Warehouse__c warehouse;
    private List<String> orderedListOfEmptyCellsAddresses;
    private Map<Id, CellDataWrapper> cellIdToDataWrapperMap;
    private Map<Id, CellDataWrapper> emptyCellsMap;
    private Map<String, Id> cellAddressToIdMap;

    public WarehouseDataWrapper(Id warehouseId, List<Cell__c> cells) {

        this.warehouseId = warehouseId;
        this.orderedListOfEmptyCellsAddresses = new List<String>();
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

            CellDataWrapper cellDataWrapper = new CellDataWrapper(cell_i);

            if (cellDataWrapper.getContainer() == null) {
                orderedListOfEmptyCellsAddresses.add(cellDataWrapper.getAddress());
                emptyCellsMap.put(cellDataWrapper.cellId, cellDataWrapper);
            }
            
            cellIdToDataWrapperMap.put(cellDataWrapper.cellId, cellDataWrapper);
        }

        orderedListOfEmptyCellsAddresses.sort();
    }

    public CellDataWrapper getEmptyCell() {

        if (orderedListOfEmptyCellsAddresses.isEmpty()) {
            return null;
        }

        return emptyCellsMap.get(cellAddressToIdMap.get(orderedListOfEmptyCellsAddresses.get(0)));
    }

    public CellDataWrapper getEmptyCellForClientContainer(Date dateOfIssue) {

        if (orderedListOfEmptyCellsAddresses.isEmpty()) {
            return null;
        }

        CellDataWrapper firstLevelCell = null;
        CellDataWrapper cellWithPreviousCellWithBiggestOrEqualsDateOfIssue = null;

        for (CellDataWrapper cellDataWrapper_i : emptyCellsMap.values()) {
            
            if (cellDataWrapper_i.getLevel() == 1) {

                if (firstLevelCell == null) {
                    firstLevelCell = cellDataWrapper_i;
                }
                continue;
            }

            CellDataWrapper previousCell = getPreviousCell(cellDataWrapper_i);

            if (previousCell != null
                        && !previousCell.isContainerForShipment()
                        && ((previousCell.getContainersDateOfIssue() == null && previousCell.getContainer() != null)
                            || (previousCell.getContainersDateOfIssue() != null && previousCell.getContainersDateOfIssue() >= dateOfIssue))) {
                    cellWithPreviousCellWithBiggestOrEqualsDateOfIssue = cellDataWrapper_i;
                break;
            }
        }

        CellDataWrapper emptyCellForClientContainer = null;

        if (cellWithPreviousCellWithBiggestOrEqualsDateOfIssue != null) {
            emptyCellForClientContainer = cellWithPreviousCellWithBiggestOrEqualsDateOfIssue;
        } else if (firstLevelCell != null) {
            emptyCellForClientContainer = firstLevelCell;
        }

        return emptyCellForClientContainer;
    }

    public CellDataWrapper getEmptyCellForShipmentContainer() {

        if (orderedListOfEmptyCellsAddresses.isEmpty()) {
            return null;
        }

        CellDataWrapper firstLevelCell = null;
        CellDataWrapper cellWithPreviousCellForShipment = null;

        for (CellDataWrapper cellDataWrapper_i : emptyCellsMap.values()) {
            
            if (cellDataWrapper_i.getLevel() == 1) {

                if (firstLevelCell == null) {
                    firstLevelCell = cellDataWrapper_i;
                }
                continue;
            }

            CellDataWrapper previousCell = getPreviousCell(cellDataWrapper_i);

            if (previousCell != null && previousCell.isContainerForShipment()) {
                cellWithPreviousCellForShipment = cellDataWrapper_i;
                break;
            }
        }

        CellDataWrapper emptyCellForShipmentContainer = null;

        if (cellWithPreviousCellForShipment != null) {
            emptyCellForShipmentContainer = cellWithPreviousCellForShipment;
        } else if (firstLevelCell != null) {
            emptyCellForShipmentContainer = firstLevelCell;
        }

        return emptyCellForShipmentContainer;
    }

    public Integer getAmountOfEmptyCells() {
        return orderedListOfEmptyCellsAddresses.size();
    }

    public void placeContainerToCell(Container__c container, CellDataWrapper cellDataWrapper) {

        container.Warehouse_Cell__c = cellDataWrapper.cellId;

        cellIdToDataWrapperMap.get(cellDataWrapper.cellId).setContainer(container);
        emptyCellsMap.remove(cellDataWrapper.cellId);

        Integer elementIndex = orderedListOfEmptyCellsAddresses.indexOf(cellDataWrapper.getAddress());
        if (elementIndex != -1) {
            orderedListOfEmptyCellsAddresses.remove(elementIndex);
            orderedListOfEmptyCellsAddresses.sort();
        }
    }

    public void removeContainerFromCell(Container__c container, CellDataWrapper cellDataWrapper) {

        container.Warehouse_Cell__c = null;

        cellIdToDataWrapperMap.get(cellDataWrapper.cellId).setContainer(null);
        emptyCellsMap.put(cellDataWrapper.cellId, cellDataWrapper);
        
        Integer elementIndex = orderedListOfEmptyCellsAddresses.indexOf(cellDataWrapper.getAddress());
        if (elementIndex == -1) {
            orderedListOfEmptyCellsAddresses.add(cellDataWrapper.getAddress());
            orderedListOfEmptyCellsAddresses.sort();
        }
    }

    public CellDataWrapper getPreviousCell(CellDataWrapper currentCell) {

        String addressOfThePreviousCell = currentCell.getAddressOfThePreviousCell();

        if (String.isBlank(addressOfThePreviousCell) || !cellAddressToIdMap.containsKey(addressOfThePreviousCell)) {
            return null;
        }

        return cellIdToDataWrapperMap.get(cellAddressToIdMap.get(addressOfThePreviousCell));
    }

    public CellDataWrapper getNextCell(CellDataWrapper currentCell) {

        String addressOfTheNextCell = currentCell.getAddressOfTheNextCell(getLevel());

        if (String.isBlank(addressOfTheNextCell) || !cellAddressToIdMap.containsKey(addressOfTheNextCell)) {
            return null;
        }

        return cellIdToDataWrapperMap.get(cellAddressToIdMap.get(addressOfTheNextCell));
    }

    public CellDataWrapper getCell(Id cellId) {
        return cellIdToDataWrapperMap.get(cellId);
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