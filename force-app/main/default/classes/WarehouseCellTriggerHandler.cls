public with sharing class WarehouseCellTriggerHandler implements TriggerHandlerInterface {
    
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
        // Do after insert logic here
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        WarehouseCellService.relocateContainers(newMap.values(), oldMap);
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        // Do after delete logic here
    }

    public void afterUndelete(Map<Id, SObject> oldMap) {
        // Do after undelete logic here
    }

}