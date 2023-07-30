public with sharing class ContactSelector {
    
    public static Map<String, Contact> getExistingContactsByExtId(Set<String> extIds) {
        Map<String, Contact> existingContactsMap = new Map<String, Contact>();
        
        List<Contact> existingContactsList = [
            SELECT Id, ExternalId__c 
            FROM Contact 
            WHERE ExternalId__c IN :extIds
            WITH SECURITY_ENFORCED
        ];

        for (Contact contact : existingContactsList) {
            existingContactsMap.put(contact.ExternalId__c, contact);
        }

        return existingContactsMap;
    }
}