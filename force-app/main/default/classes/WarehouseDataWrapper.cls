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

            CellDataWrapper cdw = new CellDataWrapper(cell_i);

            if (cdw.getContainer() == null) {
                orderedListOfEmptyCellsAddresses.add(cdw.getAddress());
                emptyCellsMap.put(cdw.cellId, cdw);
            }
            
            cellIdToDataWrapperMap.put(cdw.cellId, cdw);
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

        for (CellDataWrapper cdw_i : emptyCellsMap.values()) {
            
            if (cdw_i.getLevel() == 1) {

                if (firstLevelCell == null) {
                    firstLevelCell = cdw_i;
                }
                continue;
            }

            CellDataWrapper previousCell = getPreviousCell(cdw_i);

            if (previousCell != null &&
                        !previousCell.isContainerForShipment() &&
                        ((previousCell.getContainersDateOfIssue() == null && previousCell.getContainer() != null) || 
                            (previousCell.getContainersDateOfIssue() != null && previousCell.getContainersDateOfIssue() <= dateOfIssue))) {
                    cellWithPreviousCellWithBiggestOrEqualsDateOfIssue = cdw_i;
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

        for (CellDataWrapper cdw_i : emptyCellsMap.values()) {
            
            if (cdw_i.getLevel() == 1) {

                if (firstLevelCell == null) {
                    firstLevelCell = cdw_i;
                }
                continue;
            }

            CellDataWrapper previousCell = getPreviousCell(cdw_i);

            if (previousCell != null && previousCell.isContainerForShipment()) {
                cellWithPreviousCellForShipment = cdw_i;
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

    public void placeContainerToCell(Container__c container, CellDataWrapper cdw) {

        container.Warehouse_Cell__c = cdw.cellId;

        cellIdToDataWrapperMap.get(cdw.cellId).setContainer(container);
        emptyCellsMap.remove(cdw.cellId);

        Integer elementIndex = orderedListOfEmptyCellsAddresses.indexOf(cdw.getAddress());
        if (elementIndex != -1) {
            orderedListOfEmptyCellsAddresses.remove(elementIndex);
            orderedListOfEmptyCellsAddresses.sort();
        }
    }

    public void removeContainerFromCell(Container__c container, CellDataWrapper cdw) {

        container.Warehouse_Cell__c = null;

        cellIdToDataWrapperMap.get(cdw.cellId).setContainer(null);
        emptyCellsMap.put(cdw.cellId, cdw);
        
        Integer elementIndex = orderedListOfEmptyCellsAddresses.indexOf(cdw.getAddress());
        if (elementIndex == -1) {
            orderedListOfEmptyCellsAddresses.add(cdw.getAddress());
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