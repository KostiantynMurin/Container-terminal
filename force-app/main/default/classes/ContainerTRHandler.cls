public with sharing class ContainerTRHandler {
    
    public static void handleTrigger(List<Container__c> newList, Map<Id, Container__c> oldMap, System.TriggerOperation triggerEvent) {
        
        System.debug('ContainerTRHandler => handleTrigger');
        
        switch on triggerEvent {
            
            when BEFORE_INSERT {
                System.debug('BEFORE_INSERT');
                ContainerTRDispatcher.populateValuesOnArrival(newList);
                ContainerTRDispatcher.assignContacts(newList);
                ContainerTRDispatcher.distributeContainersForShipment(newList);
            }
            when AFTER_INSERT {
                ContainerTRDispatcher.scheduleContactAssignmentJob();
                ContainerTRDispatcher.changeCellAvailability(newList, null);
            }
            when BEFORE_UPDATE {
                ContainerTRDispatcher.removeContainersFromWarehouseAfterDeliveryShipment(newList, oldMap);
            }
            when AFTER_UPDATE {
                ContainerTRDispatcher.changeCellAvailability(newList, oldMap);
                ContainerTRDispatcher.scheduleBufferDistributionJob();
            }
            when AFTER_DELETE {
                ContainerTRDispatcher.changeCellAvailability(oldMap.values(), null);
            }
            when AFTER_UNDELETE {
                ContainerTRDispatcher.changeCellAvailability(newList, null);
            }
        }
    }
}