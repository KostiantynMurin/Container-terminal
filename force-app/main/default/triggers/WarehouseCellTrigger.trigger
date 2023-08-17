trigger WarehouseCellTrigger on Warehouse_Cell__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new WarehouseCellTriggerHandler(), Trigger.operationType);
}