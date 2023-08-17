public with sharing class WarehouseService {

    private static final List<String> LETTER_INDEX_LIST = new List<String> { 'A','B', 'C', 'D'};

    public static void specifyRelatedCells(List<Warehouse__c> warehouseList) {
        List<Warehouse_Cell__c> wCellListToInsert = new List<Warehouse_Cell__c>();
        for (Warehouse__c warehouse : warehouseList) {
            Integer wWidth = (Integer)warehouse.Width_Containers__c;
            Integer wHeight = (Integer)warehouse.Height_Containers__c;
            Integer wLenght = (Integer)warehouse.Length_Containers__c;
            for (Integer i = 0; i < warehouse.Cells_Max_Amount__c; i++) {
                String currentWidth = LETTER_INDEX_LIST[wWidth - 1];

                Warehouse_Cell__c cell = new Warehouse_Cell__c(
                    Warehouse__c = warehouse.Id, 
                    Is_Free__c = true, 
                    Unique_Address__c = currentWidth + wLenght + 'L' + wHeight
                );

                wCellListToInsert.add(cell);

                recalculateAvailableSpace(wWidth, wHeight, wHeight, warehouse);
            }
        }

        DMLExecutor.doInsert(wCellListToInsert);
    }

    public static void deleteRelatedCells(Set<Id> warehouseIdSet) {
        DMLExecutor.doDelete([SELECT Id FROM Warehouse_Cell__c WHERE Warehouse__c IN :warehouseIdSet]);
    }

    private static void recalculateAvailableSpace(Integer wWidth, Integer wHeight, Integer wLenght, Warehouse__c warehouse) {
        wWidth = wHeight - 1 > 0 && wLenght - 1 > 0 ? wWidth : wWidth - 1;
        wLenght = wHeight - 1 > 0 && wLenght - 1 > 0 ? wLenght - 1 : (Integer)warehouse.Length_Containers__c;
        wHeight = wHeight - 1 > 0 ? wHeight - 1 : (Integer)warehouse.Height_Containers__c;
    }
}