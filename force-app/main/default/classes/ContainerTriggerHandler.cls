public with sharing class ContainerTriggerHandler {

    public void handleBeforeInsert(List<Container__c> newContainers) {
        Set<String> externalIds = new Set<String>();

        for (Container__c container : newContainers) {
            externalIds.add(container.ExternalId__c);
        }

        Map<String, Contact> existingContacts = ContactHelper.getExistingContactsByExtId(externalIds);
        
        for (Container__c container : newContainers) {
            Contact contact = existingContacts.get(container.ExternalId__c);
            if (contact != null) {
                container.Contact__c = contact.Id;
            }
        }
    }

    public void handleAfterInsert(List<Container__c> newContainers) {
        Set<String> externalIds = new Set<String>();
        for (Container__c container : newContainers) {
            if (container.Contact__c == null) {
                externalIds.add(container.ExternalId__c);
            }
        }

        if (!externalIds.isEmpty()) {
            System.enqueueJob(new ContactCreatorQueue(externalIds));
        }
    }
}