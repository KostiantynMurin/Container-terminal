public with sharing class WarehouseTriggerHandler implements TriggerHandlerInterface {

    public void beforeInsert(List<SObject> newList) {
        // Do before insert logic here
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        // Do before update logic here
    }
    
    public void beforeDelete(Map<Id, SObject> oldMap) {
        // Do before delete logic here
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        WarehouseService.specifyRelatedCells((List<Warehouse__c>)newMap.values());
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        // Do after update logic here
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        WarehouseService.deleteRelatedCells(oldMap.keySet());
    }

    public void afterUndelete(Map<Id, SObject> oldMap) {
        // Do after undelete logic here
    }
}