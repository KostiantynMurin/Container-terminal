trigger ContainerTrigger on Container__c (before insert, after insert) {
    ContainerTriggerHandler handler = new ContainerTriggerHandler();
    
    if (Trigger.isBefore && Trigger.isInsert) {
        handler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        handler.handleAfterInsert(Trigger.new);
    }
}