global without sharing class ResetContainersBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Status__c, Delivery_Date__c FROM Container__c WHERE Status__c = \'' + ContainerHelper.STATUS_DELIVERY_WAITING + '\' OR Status__c = \'' + ContainerHelper.STATUS_LOAD_WAITING + '\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Container__c> scope) { 
        

        for(Container__c container : scope) {
            
            if (container.Status__c == ContainerHelper.STATUS_DELIVERY_WAITING) {
                container.Status__c = ContainerHelper.STATUS_DELIVERY_ARRIVED;
            } else if (container.Status__c == ContainerHelper.STATUS_LOAD_WAITING) {
                container.Status__c = ContainerHelper.STATUS_LOAD_ARRIVED;
            }

            container.Delivery_Date__c = null;
            container.Cell__c = null;
           
        }

        update scope;
    }   

    global void finish(Database.BatchableContext BC){}
}