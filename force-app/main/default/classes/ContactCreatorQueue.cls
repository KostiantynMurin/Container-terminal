public with sharing class ContactCreatorQueue implements Queueable, Database.AllowsCallouts {
    Set<String> externalIds;
    
    public ContactCreatorQueue(Set<String> externalIds) {
        this.externalIds = externalIds;
    }

    public void execute(QueueableContext context) {
        Set<String> extIdsForNextQueue = new Set<String>();
        List<Contact> contactsToInsert = new List<Contact>();

        // When executing the queue, we perform this check again, 
        // because during the execution of the queue (which may start some time after the trigger), 
        // contacts with such externalIds may have been created by other processes.
        Map<String, Contact> existingContacts = ContactHelper.getExistingContactsByExtId(externalIds);

        for (String extId : externalIds) {
            Contact contact = existingContacts.get(extId);

            if (contact == null) {
                if (Limits.getLimitCallouts() - Limits.getCallouts() > 0) {
                    contact = IntegrationService.getContactByExtId(extId);
                    if (contact != null) {
                        existingContacts.put(extId, contact);
                    }
                } else {
                    extIdsForNextQueue.add(extId);
                }
            }

            if (contact != null && contact.Id == null) {
                contactsToInsert.add(contact);
            }
        }

        if (!contactsToInsert.isEmpty()){
            insert contactsToInsert;
        }

        if (!extIdsForNextQueue.isEmpty()) {
            System.enqueueJob(new ContactCreatorQueue(extIdsForNextQueue));
        }
    }
}