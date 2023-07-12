trigger WarehouseTrigger on Warehouse__c (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        WarehouseTriggerHandler handler = new WarehouseTriggerHandler();
        handler.onAfterInsert(Trigger.new);
    }
}