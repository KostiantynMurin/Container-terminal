public with sharing class WarehouseTRHandler {
    
    public static void handleTrigger(List<Warehouse__c> newList, Map<Id, Warehouse__c> oldMap, System.TriggerOperation triggerEvent) {
        
        System.debug('WarehouseTRHandler => handleTrigger');
        
        switch on triggerEvent {
            
            when AFTER_INSERT {
                System.debug('AFTER_INSERT');
                WarehouseTRDispatcher.createCells(newList, null);
            }
            when AFTER_UPDATE {
                System.debug('AFTER_UPDATE');
                WarehouseTRDispatcher.updateCellsNames(newList, oldMap);
                WarehouseTRDispatcher.createCells(newList, oldMap);
            }
        }
    }
}