public without sharing class WarehouseTriggerHandler {
    
    public void onAfterInsert(List<Warehouse__c> newWarehouses) {
        // Run warehouse processor batch 
        WarehouseProcessorBatch batch = new WarehouseProcessorBatch(newWarehouses);
        Database.executeBatch(batch);
    }

}