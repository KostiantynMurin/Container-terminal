public with sharing class WarehouseTRDispatcher {
    
    public static void createCells(List<Warehouse__c> processingRecords, Map<Id, Warehouse__c> oldMap) {
        System.debug('WarehouseTRDispatcher => createCells');

        List<Warehouse__c> warehousesToCreateCells = new List<Warehouse__c>();

        if (oldMap == null) {
            warehousesToCreateCells.addAll(processingRecords);
        } else {
            
            for (Warehouse__c wh_i : processingRecords) {

                Warehouse__c whOld = oldMap.get(wh_i.Id);
    
                if (wh_i.Width__c != whOld.Width__c ||
                        wh_i.Length__c != whOld.Length__c ||
                        wh_i.Level__c != whOld.Level__c) {
                    warehousesToCreateCells.add(wh_i);
                }
            }
        }

        if (warehousesToCreateCells.isEmpty()) {
            return;
        }

        WarehouseTRService.createCells(warehousesToCreateCells, oldMap != null);
    }

    public static void updateCellsNames(List<Warehouse__c> processingRecords, Map<Id, Warehouse__c> oldMap) {
        System.debug('WarehouseTRDispatcher => updateCellsNames');

        List<Warehouse__c> warehousesToUpdateCellsNames = new List<Warehouse__c>();

        for (Warehouse__c wh_i : processingRecords) {
            
            Warehouse__c whOld = oldMap.get(wh_i.Id);

            if (wh_i.Name != whOld.Name) {
                warehousesToUpdateCellsNames.add(wh_i);
            }
        }

        if (warehousesToUpdateCellsNames.isEmpty()) {
            return;
        }

        WarehouseTRService.updateCellsNames(warehousesToUpdateCellsNames);
    }
}