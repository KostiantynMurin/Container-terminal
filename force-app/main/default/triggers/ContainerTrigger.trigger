trigger ContainerTrigger on Container__c (before insert, after insert, before update, after update, before delete) {
    ContainerTriggerHandler handler = new ContainerTriggerHandler();
    
    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            handler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.handleAfterInsert(Trigger.new);
        }
    }
}