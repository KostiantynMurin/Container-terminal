/**
 * @description  The trigger implements all events, and just contains a single line of code to call the TriggerDispatcher.
 * @author Konstiantyn Murin
 * @date 18.06.2023
 */
trigger ContainerTrigger on Container__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new ContainerTriggerHandler(), Trigger.operationType);
}