trigger CellTrigger on Cell__c (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        CellTriggerHandler handler = new CellTriggerHandler();
        handler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        CellTriggerHandler handler = new CellTriggerHandler();
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}