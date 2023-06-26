public class ContainerTriggerHandlerHelper {
    public void assignContacts(List<Container__c> newList) {
        List<String> contactsExternalIds = new List<String>();
        for( Container__c container : newList){
            contactsExternalIds.add(container.External_Contact_Id__c);
        }

        List<Contact> contacts = [
            SELECT Id
                , External_Id__c
            FROM Contact
            WHERE External_Id__c IN :contactsExternalIds
        ];
        Map<String, Contact> externalIdToContactMap = new Map<String, Contact>();
        if(!contacts.isEmpty()){
            for(Contact cont : contacts ){
                externalIdToContactMap.put(cont.External_Id__c, cont);
            }
        }
        if (!externalIdToContactMap.isEmpty()) {
            for(Container__c container : newList){
                if(externalIdToContactMap.containsKey(container.External_Contact_Id__c)){
                    container.contact__c = externalIdToContactMap.get(container.External_Contact_Id__c).Id;
                }
            }
        }
    }

    // public void changeTheIncomeStatus(List<Container__c> newList){}

    public void runContactsRetrieve(List<Container__c> newList) {

        List<CronTrigger> scheduledJobs = [
            SELECT Id
                , CronJobDetailId
                , CronJobDetail.Name
                , NextFireTime
                , PreviousFireTime
                , State
                , StartTime 
                , EndTime
                , CronExpression
                , TimeZoneSidKey
                , OwnerId
                , TimesTriggered 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = 'ContactsBatch'
        ];
        System.debug('scheduledJobs');
        System.debug(scheduledJobs);
        
        if(scheduledJobs.isEmpty()){
            System.scheduleBatch( new CreateContactsBatch(), 'ContactsBatch', 1);
        }
    }

}