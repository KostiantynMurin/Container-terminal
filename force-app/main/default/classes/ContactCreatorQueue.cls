public with sharing class ContactCreatorQueue implements Queueable, Database.AllowsCallouts {
    Set<String> externalIdSet;
    
    public ContactCreatorQueue(Set<String> extIdSet) {
        externalIdSet = extIdSet;
    }

    public void execute(QueueableContext context) {
        Set<String> extIdsForNextQueue = new Set<String>(); 
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<String> contactExtIdSet = new Set<String>();
        // When executing the queue, we perform this check again, 
        // because during the execution of the queue (which may start some time after the trigger), 
        // contacts with such externalIds may have been created by other processes.
        Map<String, Contact> existingContacts = ContactSelector.getExistingContactsByExtId(externalIdSet);

        for (String extId : externalIdSet) {
            Contact contact = existingContacts.get(extId);

            if (contact == null) {
                if (Limits.getLimitCallouts() - Limits.getCallouts() > 0) {
                    contact = IntegrationService.getContactByExtId(extId);
                } else {
                    extIdsForNextQueue.add(extId);
                }
            }

            if (contact != null && contact.Id == null) {
                contactsToUpdate.add(contact);
                contactExtIdSet.add(contact.ExternalId__c);
            }
        }

        if (!contactsToUpdate.isEmpty()){
            upsert contactsToUpdate ExternalId__c;
            ContainerService.updateContainerContacts(contactExtIdSet);
        }

        if (!extIdsForNextQueue.isEmpty()) {
            System.enqueueJob(new ContactCreatorQueue(extIdsForNextQueue));
        }
    }
}