public class ContainerTriggerHandler implements TriggerHandlerInterface {

    public void beforeInsert(List<SObject> newList) {
        ContainerService.initArrivedContainersProcess(newList);
    }

    public void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        ContainerService.releaseWarehouseCellFromContainer(newMap.values(), oldMap);
    }

    public void beforeDelete(Map<Id, SObject> oldMap) {
        // Dd before delete logic here
    }

    public void afterInsert(Map<Id, SObject> newMap) {
        Database.executeBatch(new ExternalUserContactCreationBatch());
    }

    public void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        // Dd after update logic here
    }

    public void afterDelete(Map<Id, SObject> oldMap) {
        ContainerService.updateWarehouseCellToFree(oldMap.values());
    }

    public void afterUndelete(Map<Id, SObject> oldMap) {
        // Dd after undelete logic here
    }
}