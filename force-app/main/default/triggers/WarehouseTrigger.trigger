trigger WarehouseTrigger on Warehouse__c (after insert, after update) {
    WarehouseTriggerHandler handler = new WarehouseTriggerHandler();
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}