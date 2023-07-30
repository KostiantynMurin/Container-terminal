public with sharing class ContainerService {
    public static void updateContainerContacts(Set<String> contactExtIdSet) {   
        List<Container__c> containersToUpdateList = new List<Container__c>();

        Map<String, Contact> ExtIdToContactMap = ContactSelector.getExistingContactsByExtId(contactExtIdSet);

        for (Container__c container : [SELECT Id, Contact__c, ExternalId__c FROM Container__c WHERE ExternalId__c IN :contactExtIdSet]) {
            Contact contact = ExtIdToContactMap.get(container.ExternalId__c);
            if (contact != null) {
                container.Contact__c = contact.Id;
                containersToUpdateList.add(container);
            }
        }
        if (!containersToUpdateList.isEmpty()){
            update containersToUpdateList;
        }
    }
}