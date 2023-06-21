public with sharing class ContainerTRHandler {
    
    public static void handleTrigger(List<Container__c> newList, Map<Id, Container__c> oldMap, System.TriggerOperation triggerEvent) {
        
        System.debug('ContainerTRHandler => handleTrigger');
        
        switch on triggerEvent {
            
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                ContainerTRDispatcher.populateValuesOnArrival(newList);
                ContainerTRDispatcher.assignContacts(newList);
            }
            when AFTER_INSERT {
                ContainerTRDispatcher.scheduleContactAssignmentJob();
            }
        }
    }
}