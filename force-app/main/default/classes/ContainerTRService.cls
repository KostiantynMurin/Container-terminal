public with sharing class ContainerTRService {
    
    public static void populateValuesOnArrival(List<Container__c> processingRecords) {

        for (Container__c container_i : processingRecords) {

            if (String.isBlank(container_i.Status__c)) {
                container_i.Status__c = 'Arrived For Delivery'; 
            }

            container_i.Arrival_Date__c = Datetime.now();
        }
    }
    
    public static void assignContacts(List<Container__c> processingRecords, Set<String> contactsExternalIds) {

        Map<String, Id> externalIdToContactIdMap = ContainerTRUtil.getExternalIdToContactIdMap(contactsExternalIds);

        for (Container__c container_i : processingRecords) {
            
            if (externalIdToContactIdMap.containsKey(container_i.Contact_Ext_Id__c)) {
                container_i.Contact__c = externalIdToContactIdMap.get(container_i.Contact_Ext_Id__c);
            }
        }
    }

    public static void scheduleContactAssignmentJob() {
        System.scheduleBatch(new ContactsCreationBatch(), 'ContactsCreationBatch', 5);
    }
}