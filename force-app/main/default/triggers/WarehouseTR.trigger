trigger WarehouseTR on Warehouse__c (before insert, after insert, before update, after update, before delete, after undelete) {
    WarehouseTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}