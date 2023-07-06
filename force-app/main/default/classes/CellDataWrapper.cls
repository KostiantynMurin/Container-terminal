public class CellDataWrapper {
    
    public Id cellId;
    public Id warehouseId;
    private Cell__c cell;
    private Container__c container;

    public CellDataWrapper(Cell__c cell) {
        this.cellId = cell.Id;
        this.warehouseId = cell.Warehouse__c;
        this.cell = cell;

        if (!cell.Containers__r.isEmpty()) {
            this.container = cell.Containers__r.get(0);
        }
    }

    public void setContainer(Container__c container) {
        this.container = container;
    }

    public Container__c getContainer() {
        return container;
    }

    public Boolean isContainerForShipment() {

        if (container == null || container.Status__c != 'Waiting For Shipment') {
            return false;
        }

        return true;
    }

    public String getAddress() {
        return cell.Address__c;
    }

    public String getAddressOfThePreviousCell() {

        Integer level = getLevel();
        if (level == 1) {
            return null;
        }

        return WarehouseTRUtil.getCellAddress(getWidth(), getLength(), level - 1);
    }

    public String getAddressOfTheNextCell(Integer warehouseMaxLevel) {

        Integer level = getLevel();
        if (level == warehouseMaxLevel) {
            return null;
        }

        return WarehouseTRUtil.getCellAddress(getWidth(), getLength(), level + 1);
    }

    public Integer getLevel() {
        return Integer.valueOf(cell.Level__c);
    }

    public Integer getWidth() {
        return Integer.valueOf(cell.Width__c);
    }

    public Integer getLength() {
        return Integer.valueOf(cell.Length__c);
    }
}