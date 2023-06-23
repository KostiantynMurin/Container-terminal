public with sharing class ContactHelper {
    
    public static Map<String, Contact> getExistingContactsByExtId(Set<String> extIds) {
        List<Contact> existingContactsList = [
            SELECT Id, ExternalId__c 
            FROM Contact 
            WHERE ExternalId__c IN :extIds
        ];

        Map<String, Contact> existingContactsMap = new Map<String, Contact>();
        for (Contact contact : existingContactsList) {
            existingContactsMap.put(contact.ExternalId__c, contact);
        }

        return existingContactsMap;
    }
}