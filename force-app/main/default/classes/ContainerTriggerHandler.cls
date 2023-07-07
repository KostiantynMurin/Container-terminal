/**
 * @description  Trigger handler for the Container object.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public class ContainerTriggerHandler implements ITriggerHandler {

    private static final List<String> AWAITING_STATUSES_LIST = new List<String>{ 'Awaiting issuance', 'Awaiting shipment' };
    private static final List<String> ARRIVED_STATUSES_LIST = new List<String>{ 'Arrived for issuance', 'Arrived for shipment' };
    
    /**
     * @description   Before insertion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newList List<SObject>
     */
    public void beforeInsert(List<SObject> newList) {
        processContainerItems(newList);
    }

    /**
     * @description   Before updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        removeContainerCellRelation(newMap.values(), oldMap);
    }

    /**
     * @description   Before deletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param oldMap Map<Id, SObject> newMap
     */
    public void beforeDelete(Map<Id, SObject> oldMap) {}

    /**
     * @description   After insertion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     */
    public void afterInsert(Map<Id, SObject> newMap) {
        runContactCreatorBatch();
        publishPlatformEvent(newMap.values());
    }

    /**
     * @description   After updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        updateRelatedCell(newMap.values(), oldMap);
    }

    /**
     * @description   After deletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterDelete(Map<Id, SObject> oldMap) {
        updateRelatedCell(oldMap.values());
    }

    /**
     * @description   After undeletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUndelete(Map<Id, SObject> oldMap) {}

    private static void processContainerItems(List<Container__c> newList) {

        Map<String, List<Container__c>>  containersByContactExtIdMap = new Map<String, List<Container__c>>();
        for (Container__c container : newList) {
            container.Delivery_Date__c = Date.today();
            setContainerStatus(container);
            setIssuanceDate(container);
            fillContainersByContactExtIdMap(container, containersByContactExtIdMap);
        }

        Map<String, SObject> existingContactByExternalIdMap = new Map<String, SObject>(
            [SELECT External_Id__c Id, Id contactId 
             FROM Contact 
             WHERE External_Id__c IN :containersByContactExtIdMap.keySet()
             AND External_Id__c != null
             GROUP BY External_Id__c, Id]
        );
        assignContact(existingContactByExternalIdMap, containersByContactExtIdMap);
    }

    private static void setContainerStatus(Container__c container) {
        if (container.Status__c == null) {
            container.Status__c = 'Arrived for issuance';
        }
    }

    private static void setIssuanceDate(Container__c container) {
        if (container.Status__c == 'Arrived for issuance') {
            container.Issuance_Date__c = Date.today().addDays(2 + (Integer)Math.floor(Math.random() * 5));
        }
    }

    private static void fillContainersByContactExtIdMap(Container__c container, Map<String, List<Container__c>>  containersByContactExtIdMap) {
        if (containersByContactExtIdMap.containsKey(container.External_Contact_ID__c)) {
            containersByContactExtIdMap.get(container.External_Contact_ID__c).add(container);
        } else {
            containersByContactExtIdMap.put(container.External_Contact_ID__c, new List<Container__c>{ container });
        }
    }

    private static void assignContact(Map<String, SObject> existingContactByExternalIdMap, Map<String, List<Container__c>>  containersByContactExtIdMap) {
        for (String contactExtId : existingContactByExternalIdMap.keySet()) {
            for (Container__c container : containersByContactExtIdMap.get(contactExtId)) {
                container.Contact__c = (String)existingContactByExternalIdMap.get(contactExtId).get('contactId');
            }
        }
    }

    private static void runContactCreatorBatch() {
        DataBase.executeBatch(new ContactCreatorBatch(), 50);
    }

    private static void removeContainerCellRelation(List<Container__c> newList, Map<Id, SObject> oldMap) {
        for (Container__c container : newList) {
            if (container.Status__c != oldMap.get(container.Id).get('Status__c') && container.Status__c == 'Issued') {
                container.Warehouse_Cell__c = null;
            }
        }
    }

    private static void updateRelatedCell(List<Container__c> newList, Map<Id, SObject> oldMap) {
        List<Warehouse_Cell__c> cellToUpdateList = new List<Warehouse_Cell__c>();
        Set<Date> issuanceDateSet = new Set<Date>();
        for (Container__c container : newList) {
            if (container.Status__c != oldMap.get(container.Id).get('Status__c') && container.Status__c == 'Issued' && container.Warehouse_Cell__c == null) {
                issuanceDateSet.add(container.Issuance_Date__c);
                cellToUpdateList.add(
                    new Warehouse_Cell__c(
                        Id = (Id)oldMap.get(container.Id).get('Warehouse_Cell__c'),
                        Is_Empty__c = true
                    )
                );
            }
        }
        DMLExecutor.doUpdate(cellToUpdateList);
    }

    private void publishPlatformEvent(List<Container__c> newList) {
        Boolean isUnlocatedContainerCreated = false;
        for (Container__c container : newList) {
            if (ARRIVED_STATUSES_LIST.contains(container.Status__c) && container.Warehouse_Cell__c == null) {
                isUnlocatedContainerCreated = true;
                break;
            }
        }
        if (isUnlocatedContainerCreated) {
            Map<Id, Container_Warehouse__c> warehouseMap = new Map<Id, Container_Warehouse__c>([
                SELECT Id FROM Container_Warehouse__c
            ]);
            PlatformEventBuilder.publishUnlocatedContainersCreatedEvent(warehouseMap.keySet());
        }
    }

    private void updateRelatedCell(List<Container__c> oldList) {
        List<Warehouse_Cell__c> cellToUpdateList = new List<Warehouse_Cell__c>();
        for (Container__c container : oldList) {
            if (container.Warehouse_Cell__c == null) {
                continue;
            }
            cellToUpdateList.add(
                new Warehouse_Cell__c(
                    Id = container.Warehouse_Cell__c,
                    Is_Empty__c = true
                )
            );
        }
        DMLExecutor.doUpdate(cellToUpdateList);
    }
}