public with sharing class WarehouseTriggerHandler {
    public void handleAfterInsert(List<Warehouse__c> newWarehouseList) {
        createCells(newWarehouseList);
    }

    public void handleAfterUpdate(List<Warehouse__c> newWarehouseList, Map<Id, Warehouse__c> oldWarehouseMap) {
        List<Id> warehouseIdList = new List<Id>();
        List<Warehouse__c> warehouseToRefreshCellsList = new List<Warehouse__c>();
        for (Warehouse__c warehouse : newWarehouseList) {
            if (warehouse.Heigth__c != oldWarehouseMap.get(warehouse.Id).Heigth__c ||
                warehouse.Length__c != oldWarehouseMap.get(warehouse.Id).Length__c ||
                warehouse.Width__c != oldWarehouseMap.get(warehouse.Id).Width__c) {
                    warehouseIdList.add(warehouse.Id);
                    warehouseToRefreshCellsList.add(warehouse);
            }
        }
        if (!warehouseIdList.isEmpty()){
            deleteCells(warehouseIdList);
        }

        if (!warehouseToRefreshCellsList.isEmpty()){
            createCells(warehouseToRefreshCellsList);
        }
    }

    private void createCells(List<Warehouse__c> warehouseList) {
        List<Cell__c> cellList = new List<Cell__c>();
        for (Warehouse__c warehouse : warehouseList) {
            Integer wWidth = (Integer)warehouse.Width__c;
            Integer wLenght = (Integer)warehouse.Length__c;
            Integer wHeight = (Integer)warehouse.Heigth__c;

            for (Integer i = 0; i < warehouse.Capacity__c; i++) {
                String currentWidth = WarehouseHelper.getWidthMapping().get(wWidth);
                Cell__c cell = new Cell__c(
                    Warehouse__c = warehouse.Id, 
                    Status__c = Cell.STATUS_FREE, 
                    Location__c = currentWidth + wLenght + 'L' + wHeight
                );
                cellList.add(cell);

                wHeight -= 1;
                if (wHeight <= 0){
                    wHeight = (Integer)warehouse.Heigth__c;
                    wLenght -= 1;
                    if (wLenght <= 0){
                        wLenght = (Integer)warehouse.Length__c;
                        wWidth -= 1;
                    }
                }
            }
        }
        insert cellList;
    }

    private void deleteCells(List<Id> warehouseIdList) {
        delete [SELECT Id FROM Cell__c WHERE Warehouse__c IN :warehouseIdList];
    }
}
