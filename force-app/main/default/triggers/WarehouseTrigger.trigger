trigger WarehouseTrigger on Warehouse__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new WarehouseTriggerHandler(), Trigger.operationType);
}