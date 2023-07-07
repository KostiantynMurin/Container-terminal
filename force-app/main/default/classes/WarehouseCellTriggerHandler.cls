/**
 * @description  Trigger handler for the Warehouse_Cell__c object.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public with sharing class WarehouseCellTriggerHandler implements ITriggerHandler {
    private static final List<String> ARRIVED_STATUSES_LIST = new List<String>{ 'Arrived for issuance', 'Arrived for shipment' };
    /**
     * @description   Before insertion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newList List<SObject>
     */
    public void beforeInsert(List<SObject> newList) {}

    /**
     * @description   Before updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}

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
    public void afterInsert(Map<Id, SObject> newMap) {}

    /**
     * @description   After updation helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        moveContainersFromTemporaryStorage(newMap.values(), oldMap);
        publishPlatformEvent(newMap.values());
    }

    /**
     * @description   After deletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterDelete(Map<Id, SObject> oldMap) {}

    /**
     * @description   After undeletion helper method
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param newMap Map<Id, SObject> newMap
     * @param oldMap Map<Id, SObject> newMap
     */
    public void afterUndelete(Map<Id, SObject> oldMap) {}

    private static void moveContainersFromTemporaryStorage(List<Warehouse_Cell__c> newList, Map<Id, SObject> oldMap) {
        Boolean isCellEmpty = false;
        for (Warehouse_Cell__c cell : newList) {
            Warehouse_Cell__c oldCell = (Warehouse_Cell__c)oldMap.get(cell.Id);
            if (cell.Is_Empty__c && !oldCell.Is_Empty__c) {
                isCellEmpty = true;
                break;
            }
        }
        if (!isCellEmpty) {
            return;
        }
        List<Container__c> containerList = [
            SELECT Id, Issuance_Date__c, Status__c
            FROM Container__c
            WHERE Status__c IN :ARRIVED_STATUSES_LIST
            AND Warehouse_Cell__c = null
            ORDER BY Issuance_Date__c DESC
        ];
        if (!containerList.isEmpty()) {
            ContainerDistributorBatch distributorBatch = new ContainerDistributorBatch(containerList);
            Database.executeBatch(distributorBatch, 200);
        }
    }

    private void publishPlatformEvent(List<Warehouse_Cell__c> newList) {
        Set<Id> warehouseIdSet = new Set<Id>();
        for (Warehouse_Cell__c cell : newList) {
            warehouseIdSet.add(cell.Container_Warehouse__c);
        }
        PlatformEventBuilder.publishContainerWarehouseUpdateEvent(warehouseIdSet);
        PlatformEventBuilder.publishUnlocatedContainersCreatedEvent(warehouseIdSet);
    }
}