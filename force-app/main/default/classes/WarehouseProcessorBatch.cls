global without sharing class WarehouseProcessorBatch implements Database.batchable<SObject> {

    List<Warehouse__c> warehouses;

    public WarehouseProcessorBatch(List<Warehouse__c> warehouses) {
        this.warehouses = warehouses;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        WarehouseProcessorFeeder bf = new WarehouseProcessorFeeder(this.warehouses);
        return bf;
    }
    
    global void execute(Database.BatchableContext bc, SObject[] scope) {
        insert scope;
    }
    
    global void finish(Database.BatchableContext bc) {
    
    }
}