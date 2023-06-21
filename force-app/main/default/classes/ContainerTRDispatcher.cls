public with sharing class ContainerTRDispatcher {
    
    public static void populateValuesOnArrival(List<Container__c> processingRecords) {
        System.debug('ContainerTRDispatcher => populateValuesOnArrival');

        ContainerTRService.populateValuesOnArrival(processingRecords);
    }

    public static void assignContacts(List<Container__c> processingRecords) {
        System.debug('ContainerTRDispatcher => assignContacts');

        Set<String> contactsExternalIds = new Set<String>();
        List<Container__c> containersToLinkContacts = new List<Container__c>();

        for (Container__c container_i : processingRecords) {
            
            if (String.isBlank(container_i.Contact_Ext_Id__c)) {
                continue;
            }
            
            contactsExternalIds.add(container_i.Contact_Ext_Id__c);
            containersToLinkContacts.add(container_i);
        }

        if (containersToLinkContacts.isEmpty()) {
            return;
        }

        ContainerTRService.assignContacts(containersToLinkContacts, contactsExternalIds);
    }

    public static void scheduleContactAssignmentJob() {

        List<CronTrigger> existedJobs = [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'ContactsCreationBatch'
            AND State != 'COMPLETE'
        ];

        if (!existedJobs.isEmpty()) {
            return;
        }

        ContainerTRService.scheduleContactAssignmentJob();
    }
}