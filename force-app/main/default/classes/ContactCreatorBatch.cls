/**
 * @description  The batch class for making a callout to an external system to get user details to create a contact and associate it with a container.
 * @author Kostiantyn Murin
 * @date 24-06-2023
 */
public with sharing class ContactCreatorBatch implements Database.Batchable<Container__c>, Database.AllowsCallouts, Database.Stateful {

    private String query = 'SELECT Id, ' +
                          '       Contact__c, ' +
                          '       External_Contact_ID__c ' +
                          'FROM Container__c ' +
                          'WHERE Contact__c = null AND External_Contact_ID__c != null';
    private Map<String, Contact> createdContactByExtIdMap = new Map<String, Contact>();
    private List<Container__c> containerToUpdateList = new List<Container__c>();
    
    /**
     * @description  Collect the batches of records or objects to be passed to execute. Container__c list.
     * @author Kostiantyn Murin
     * @date 24-06-2023
     */
    public Iterable<Container__c> start(Database.BatchableContext BC) {
        Id thisJobId = bc.getJobId();
        Id thisClassId = [
            SELECT Id 
            FROM ApexClass 
            WHERE Name = 'ContactCreatorBatch' 
            LIMIT 1]?.Id;
        List<AsyncApexJob> jobList = [
            SELECT Id 
            FROM AsyncApexJob 
            WHERE Id != :thisJobId 
            AND Status = 'Processing' 
            AND ApexClassId = :thisClassId 
            AND JobType = 'BatchApex'];
        if (jobList == null || jobList.isEmpty()) {
            return (Iterable<Container__c>)Database.getQueryLocator(this.query);
        }
        return new Container__c[0];
    }
 
    /**
     * @description  Process each batch of Container__c records. Making a callout to an external system and inserting new Contact records
     * @author Kostiantyn Murin
     * @date 24-06-2023
     */
    public void execute(Database.BatchableContext BC, List<Container__c> scope) {
        this.containerToUpdateList.addAll(scope);
        List<Contact> contactToInsertList = new List<Contact>();
        for (Container__c container : scope) {
            try {
                if (!this.createdContactByExtIdMap.containsKey(container.External_Contact_ID__c)) {
                    Contact newContact = ExternalUserService.getContactByExtId(container.External_Contact_ID__c);
                    this.createdContactByExtIdMap.put(container.External_Contact_ID__c, newContact);
                    contactToInsertList.add(newContact);
                }
            } catch (Exception e) {
                System.debug('Error:' + e.getMessage() + 'Line no:' + e.getLineNumber() ); 
            }
        }
        DMLExecutor.doInsert(contactToInsertList);
    }
 
    /**
     * @description  Assign Contact to the Container
     * @author Kostiantyn Murin
     * @date 24-06-2023
     */
    public void finish(Database.BatchableContext BC) {
        for (Container__c container : this.containerToUpdateList) {
            if (createdContactByExtIdMap.containsKey(container.External_Contact_ID__c)) {
                container.Contact__c = createdContactByExtIdMap.get(container.External_Contact_ID__c).Id;
            }
        }
        DMLExecutor.doUpdate(this.containerToUpdateList);
    }
}