global without sharing class WarehouseProcessorFeeder implements Iterator<SObject>, Iterable<SObject> {

    List<Warehouse__c> warehouses;

    Integer warehouseIndex = 0;
    Integer rowIndex = 0;
    Integer columnIndex = 0;
    Integer levelIndex = 0;

    global Iterator<SObject> iterator() {
        return this;
    }
    
    global WarehouseProcessorFeeder(List<Warehouse__c> warehouses) {
        this.warehouses = warehouses;
    }
    
    global SObject next() {

        Warehouse__c warehouse = warehouses[warehouseIndex];

        Cell__c cell = new Cell__c();
        cell.Warehouse__c = warehouse.Id;
        cell.Row__c = getLetterCode(rowIndex);
        cell.Column__c = columnIndex;
        cell.Level__c = levelIndex;

        if (columnIndex == warehouse.Columns__c - 1) {
            columnIndex = 0;
            if (rowIndex == warehouse.Rows__c - 1) {
                rowIndex = 0;
                if (levelIndex == warehouse.Levels__c - 1) {
                    levelIndex = 0;
                    warehouseIndex++;
                } else {
                    levelIndex++;
                }
            } else {
                rowIndex++;
            }
        } else {
            columnIndex++;
        }

        return cell;
    }
    
    global boolean hasNext() {
        return warehouseIndex < warehouses.size();
    }

    private String getRowName(Integer rowIndex) {
        return getLetterCode(rowIndex);
    }
    
    private String getLetterCode(Integer index) {
        String[] letters = new String[]{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
        String letterCode = '';
        while (index >= 0) {
            Integer remainder = Math.mod(index, 26);
            letterCode = letters[remainder] + letterCode;
            index = (index - remainder) / 26 - 1;
        }
        return letterCode;
    }
}