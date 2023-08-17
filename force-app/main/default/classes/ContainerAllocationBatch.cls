public with sharing class ContainerAllocationBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Issuance_Date__c, Status__c ' +
                        'FROM Container__c ' +
                        'WHERE Warehouse_Cell__c = null ' +
                                ' AND Status__c != ' + Constants.ISSUED + 
                                ' AND Issuance_Date__c != null ' +
                        'ORDER BY Issuance_Date__c DESC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        // ContainerAllocationService logic
    }

    public void finish(Database.BatchableContext BC){
    }
}