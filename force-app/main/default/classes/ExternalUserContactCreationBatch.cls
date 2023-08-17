/**
 * @description The class makes external system calls to obtain information about the user,
 *               which allows to create contacts and associate them with containers.
 * @author Oleg Bezrukov
 * @date 07-2023
 */
public with sharing class ExternalUserContactCreationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    private Map<String, Contact> extCntIdToContactMap = new Map<String, Contact>();
    private List<Container__c> containerListToUpdate = new List<Container__c>();
    
    /**
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Contact__c, Arrival_Date__c, External_Contact_Id__c ' + 
                        'FROM Container__c ' + 
                        'WHERE Contact__c = null ' + 
                                'AND External_Contact_Id__c != null';
        return Database.getQueryLocator(query);
    }
 
    /**
     * @description External system callouts and insertion of new contact records.
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Contact> contactListToInsert = new List<Contact>();
        for (SObject sObj : scope) {
            Container__c container = (Container__c)sObj;
            if (!this.extCntIdToContactMap.containsKey(container.External_Contact_Id__c)) {
                Contact newCntToInsert = RandomUserService.obtainContactByRandomUser(container.External_Contact_Id__c);
                this.extCntIdToContactMap.put(container.External_Contact_Id__c, newCntToInsert);
                contactListToInsert.add(newCntToInsert);
            }
        }
        DMLExecutor.doInsert(contactListToInsert);
        this.containerListToUpdate.addAll((List<Container__c>)scope);
    }
 
    /**
     * @description Associate Contact with Container
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public void finish(Database.BatchableContext BC) {
        for (Container__c container : this.containerListToUpdate) {
            if (this.extCntIdToContactMap.containsKey(container.External_Contact_ID__c)) {
                container.Contact__c = this.extCntIdToContactMap.get(container.External_Contact_ID__c).Id;
            }
        }
        DMLExecutor.doUpdate(this.containerListToUpdate);
        // Database.executeBatch(new ContainerDistributorBatch(), 200);
    }
}