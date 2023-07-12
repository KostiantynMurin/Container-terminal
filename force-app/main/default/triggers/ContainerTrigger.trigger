trigger ContainerTrigger on Container__c (before insert, after insert, before update, after update) {

    if (Trigger.isAfter && Trigger.isInsert) {
        ContainerTriggerHandler handler = new ContainerTriggerHandler();
        handler.onAfterInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        ContainerTriggerHandler handler = new ContainerTriggerHandler();
        handler.onBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        ContainerTriggerHandler handler = new ContainerTriggerHandler();
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        ContainerTriggerHandler handler = new ContainerTriggerHandler();
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }

}