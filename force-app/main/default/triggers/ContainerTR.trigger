trigger ContainerTR on Container__c (before insert, after insert, before update, after update, before delete, after undelete) {
    ContainerTRHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}