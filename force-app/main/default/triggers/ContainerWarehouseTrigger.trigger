/**
 * @description  The trigger implements all events, and just contains a single line of code to call the TriggerDispatcher.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
trigger ContainerWarehouseTrigger on Container_Warehouse__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new ContainerWarehouseTriggerHandler(), Trigger.operationType);
}