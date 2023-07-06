public with sharing class DistributeContainersFromShipBatch implements Database.Batchable<Container__c>, Database.AllowsCallouts, Database.Stateful {
    
    public DistributeContainersFromShipBatch(){}

    public DistributeContainersFromShipBatch(List<Container__c> containersForBatch){
        containersForBatch = containersForBatch;
    }

    List<Container__c> containersForBatch;
    List<Storage_Unit__c> storageUnits;
    Map<Id, Storage_Unit__c> storageUnitsMap;
    List<Container__c> waitingContainers = new List<Container__c>();
    List<Id> emptyStorages = new List<Id>();
    List<Id> storagesWithOneContainer = new List<Id>();
    List<Id> storagesWithTwoContainers = new List<Id>();
    List<Container__c> firstLevelContainersForMoving = new List<Container__c>();
    List<Container__c> secondLevelContainersForMoving = new List<Container__c>();
    List<Container__c> placedContainers = new List<Container__c>();
    Storage_Unit__c tempStorage;
    public Iterable<Container__c> start(Database.BatchableContext bc) {
        
        List<Container__c> containersForReturn = new List<Container__c>();
        if ( containersForBatch != null ){
            containersForReturn = containersForBatch;
        } else {
            containersForReturn = [
                SELECT Id
                FROM Container__c
                WHERE Storage_Unit__c = NULL
                AND Status__c = 'Arrived for client'
            ];
        }
        if(containersForReturn.isEmpty()){
            return containersForReturn;
        }
        tempStorage = [
            SELECT Id, 
                Name
            FROM Storage_Unit__c
            WHERE Name = 'Temporary Storage'
            LIMIT 1
        ];

        storageUnits = [
            SELECT Id
                , Stock__c
                , Stock__r.Height__c
                , Name
                , Uniq_Id__c
                , Length_Position__c
                , Width_Position__c
                , Height_Position__c
                , ( SELECT Id
                        , Status__c
                        , Storage_Unit__c
                        , Storage_Unit__r.Stock__r.Height__c
                    FROM Containers__r
                    LIMIT 1)
            FROM Storage_Unit__c
            WHERE Name != 'Temporary Storage'
            ORDER BY Stock__c, Name
        ];
        Map<Integer, Storage_Unit__c> indexToStorageUnitMap = new Map<Integer, Storage_Unit__c>();
        Map<Id, Integer> storageIdToListIndexMap = new Map<Id, Integer>();
        storageUnitsMap = new Map<Id, Storage_Unit__c>(storageUnits);
        Integer storagesOpenedAfterFirstLevelMoving = 0;
        Integer storagesOpenedAfterSecondLevelMoving = 0;
        for(Integer i = 0; i < storageUnits.size(); i++){
            Storage_Unit__c storageUnit = storageUnits.get(i);
            indexToStorageUnitMap.put(i, storageUnit);
            storageIdToListIndexMap.put(storageUnit.Id, i);
            System.debug('storageUnit');
            System.debug(storageUnit.Name);
            Integer storageHieght = Integer.valueOf(storageUnit.Stock__r.Height__c);
            if(storageUnit.Height_Position__c == 1 && storageUnit.Containers__r.isEmpty()){
                for(Integer j = 0; j < storageHieght; j++){
                    emptyStorages.add(storageUnits.get(i + j).Id);  
                } 
            } else if (storageUnit.Height_Position__c == 2 && storageUnit.Containers__r.isEmpty()) {
                Storage_Unit__c previousStorage = storageUnits.get(i - 1);
                if(emptyStorages.contains(previousStorage.Id)){
                    continue;
                }
                Container__c previousContainer = previousStorage.Containers__r?.get(0);
                if(previousContainer.Status__c.equals('Waiting for client')){
                    for(Integer j = 0; j < storageHieght - 1; j++){
                        emptyStorages.add(storageUnits.get(i + j).Id);  
                    } 
                } else {
                    firstLevelContainersForMoving.add(previousContainer);
                    storagesOpenedAfterFirstLevelMoving += Integer.valueOf(storageUnit.Stock__r.Height__c);
                }
                
            } else if (storageUnit.Height_Position__c == 3 && storageUnit.Containers__r.isEmpty()){
                Storage_Unit__c previousStorage = storageUnits.get(i - 1);
                if(emptyStorages.contains(previousStorage.Id)){
                    continue;
                }
                Container__c previousContainer = previousStorage?.Containers__r.get(0);
                if(previousContainer.Status__c.equals('Waiting for client')){
                    for(Integer j = 0; j < storageHieght - 2; j++){
                        emptyStorages.add(storageUnits.get(i + j).Id);  
                    } 
                } else {
                    Container__c firstLevelContainer = storageUnits.get(i - 2).Containers__r.get(0);
                    secondLevelContainersForMoving.add(previousContainer);
                    secondLevelContainersForMoving.add(firstLevelContainer);
                    storagesOpenedAfterSecondLevelMoving += Integer.valueOf(storageUnit.Stock__r.Height__c);
                }
            } else {
                continue;
            }
        }

        List<Container__c> containersForTemporaryStorage = new List<Container__c>();
        System.debug('emptyStorages.size()');
        System.debug(emptyStorages.size());
        System.debug('containersForReturn.size()');
        System.debug(containersForReturn.size());
        if (containersForReturn.size() > emptyStorages.size() ){
            Integer containersForPlacementLeft = containersForReturn.size() - emptyStorages.size();
            for(Integer i = 0; containersForPlacementLeft > 0; i++){
                if(!firstLevelContainersForMoving.isEmpty()){
                    Container__c containerForMoving = firstLevelContainersForMoving.remove(0);
                    Integer stockHeight = Integer.valueOf(containerForMoving.Storage_Unit__r.Stock__r.Height__c);
                    containersForTemporaryStorage.add(containerForMoving);
                    containersForPlacementLeft -= stockHeight;
                    Integer storageIndexInList = storageIdToListIndexMap.get(containerForMoving.Storage_Unit__c);
                    for(Integer j = 0; j < stockHeight; j++){
                        emptyStorages.add(indexToStorageUnitMap.get(storageIndexInList + j).Id);
                    }
                } else if (!secondLevelContainersForMoving.isEmpty()){
                    Container__c containerForMoving = secondLevelContainersForMoving.remove(0);
                    Integer stockHeight = Integer.valueOf(containerForMoving.Storage_Unit__r.Stock__r.Height__c);
                    containersForTemporaryStorage.add(containerForMoving);
                    containersForTemporaryStorage.add(secondLevelContainersForMoving.remove(0));
                    containersForPlacementLeft -= stockHeight;
                    Integer storageIndexInList = storageIdToListIndexMap.get(containerForMoving.Storage_Unit__c);
                    for(Integer j = 0; j < stockHeight; j++){
                        emptyStorages.add(indexToStorageUnitMap.get(storageIndexInList + j).Id);
                    }               
                } else {
                    System.debug('we have ' + containersForPlacementLeft + ' of unplaced containers');
                    break;
                }
            }
       }
        if(!containersForTemporaryStorage.isEmpty()){
            moveContainersToTemparoryStorage(containersForTemporaryStorage);
        }
        return containersForReturn;
    }

    public void execute(Database.BatchableContext BC, List<Container__c> scope) {
        
        for (Container__c container : scope) {
            if (!emptyStorages.isEmpty()){
                container.Storage_Unit__c = emptyStorages.remove(0);
                /* System.debug(container.Storage_Unit__c);
                container.Status__c = 'Waiting for client';
                placedContainers.add(container); */
            } else {
                container.Storage_Unit__c = tempStorage.Id;
            }
            System.debug(container.Storage_Unit__c);
            container.Status__c = 'Waiting for client';
            placedContainers.add(container);
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
        ContainerTriggerHandler.skip = true;
        update placedContainers;

        if (!waitingContainers.isEmpty()){
            Database.executeBatch(new DistributeContainersFromShipBatch(waitingContainers), 200);
        }
    }

    private void moveContainersToTemparoryStorage(List<Container__c> containersForTemporaryStorage ) {
        for(Container__c container : containersForTemporaryStorage ){
            container.Storage_Unit__c = tempStorage.Id;
        }
        ContainerTriggerHandler.skip = true;
        update containersForTemporaryStorage;
    }


    public class DistributeContainersFromShipBatchException extends Exception {}
}