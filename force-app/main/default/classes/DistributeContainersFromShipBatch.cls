public with sharing class DistributeContainersFromShipBatch implements Database.Batchable<Container__c>, Database.AllowsCallouts, Database.Stateful {
    
    public DistributeContainersFromShipBatch(){}

    public DistributeContainersFromShipBatch(List<Container__c> containersForBatch){
        containersForBatch = containersForBatch;
    }

    List<Container__c> containersForBatch;
    Map<Id, Storage_Unit__c> storageUnits;
    List<Container__c> waitingContainers = new List<Container__c>();
    List<Id> emptyStorages = new List<Id>();
    List<Id> storagesWithOneContainer = new List<Id>();
    List<Id> storagesWithTwoContainers = new List<Id>();
    List<Container__c> placedContainers = new List<Container__c>();
    
    public Iterable<Container__c> start(Database.BatchableContext bc) {
        
        storageUnits = new Map<Id, Storage_Unit__c>([
            SELECT Id
                , Stock__c
                , Stock__r.Height__c
                , Name
                , Uniq_Id__c
                , Length_Position__c
                , Width_Position__c
                , Height_Position__c
                , ( SELECT Id
                    FROM Containers__r
                    LIMIT 1)
            FROM Storage_Unit__c
            ORDER BY Stock__c, Name
        ]);

        for(Integer i = 0; i < storageUnits.values().size(); i++){
            Storage_Unit__c storageUnit = storageUnits.values().get(i);
            System.debug('storageUnit');
            System.debug(storageUnit.Name);
            Integer storageHieght = Integer.valueOf(storageUnit.Stock__r.Height__c);
            if(storageUnit.Height_Position__c == 1 && storageUnit.Containers__r.isEmpty()){
                for(Integer j = 0; j < storageHieght; j++){
                    emptyStorages.add(storageUnits.values().get(i+j).Id);  
                } 
            } else if (storageUnit.Height_Position__c == 2 && storageUnit.Containers__r.isEmpty()) {
                storagesWithOneContainer.add(storageUnit.Id);
            } else if (storageUnit.Height_Position__c == 3 && storageUnit.Containers__r.isEmpty()){
                storagesWithTwoContainers.add(storageUnit.Id);
            } else {
                continue;
            }
            i += storageHieght - Integer.valueOf(storageUnit.Height_Position__c);
        }


        if (containersForBatch != null ){
            return containersForBatch;
        }
        List<Container__c> containersForPlacement = [
            SELECT Id
            FROM Container__c
            WHERE Storage_Unit__c = NULL
            AND Status__c = 'Arrived for client'
        ];
        return containersForPlacement;
    }

    public void execute(Database.BatchableContext BC, List<Container__c> scope) {
        
        for (Container__c container : scope) {
            if (!emptyStorages.isEmpty()){
                container.Storage_Unit__c = emptyStorages.remove(0);
                System.debug(container.Storage_Unit__c);
                container.Status__c = 'Waiting for client';
                placedContainers.add(container);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!placedContainers.isEmpty()) {
            Integer containersQuantity = placedContainers.size();
            Date sunday = Date.today().addDays(1);
            for (Integer i = containersQuantity; i > 0; i--) {
                Decimal partOfContainers = i * 100 / containersQuantity;
                Container__c container = placedContainers.get(i - 1);
                if(partOfContainers > 80 ){
                    container.Departure_Date__c = sunday.addDays(1);
                } else if(partOfContainers > 60 ){
                    container.Departure_Date__c = sunday.addDays(2);
                } else if(partOfContainers > 40 ){
                    container.Departure_Date__c = sunday.addDays(3);
                } else if(partOfContainers > 20 ){
                    container.Departure_Date__c = sunday.addDays(4);
                } else {
                    container.Departure_Date__c = sunday.addDays(5);
                }
            }
        }
        update placedContainers;

        if (!waitingContainers.isEmpty()){
            Database.executeBatch(new DistributeContainersFromShipBatch(waitingContainers), 200);
        }
    }

    public class DistributeContainersFromShipBatchException extends Exception {}
}