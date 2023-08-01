/**
 * @description  PlatformEventBuilder class
 * @author Kostiantyn Murin
 * @date 06-07-2023
 */
public with sharing class PlatformEventBuilder {
    /**
     * @description   The method creates an platform events to refresh data on the Container Warehouse State table.
     * @author Kostiantyn Murin
     * @date 06-07-2023
     * @param recordIdSet Set<Id>
     */
    public static void publishContainerWarehouseUpdateEvent(Set<Id> recordIdSet){
        List<Map<String, Object>> wrapperListToSendByEvent = new List<Map<String, Object>>();
        for (String warehouseId : recordIdSet) {
            wrapperListToSendByEvent.add(buildWrapperToSendByEvent(recordIdSet));
        }
        if(wrapperListToSendByEvent.isEmpty()){
            return;
        }
        Container_Warehouse_Update__e platformEvent = buildContainerWarehousePlatformEvent(wrapperListToSendByEvent);
        Database.SaveResult sr = EventBus.publish(platformEvent);
        if(!sr.isSuccess()){
            String errorMessage = '';
            for(Database.Error error : sr.getErrors()){
                errorMessage+=error.getMessage()+'\n';
            }
            throw new PlatformEventBuilderException(errorMessage);
        }
    }

    /**
     * @description   The method creates an platform events to refresh data on the Unlocated Containers table.
     * @author Kostiantyn Murin
     * @date 06-07-2023
     * @param recordIdSet Set<Id>
     */
    public static void publishUnlocatedContainersCreatedEvent(Set<Id> recordIdSet){
        List<Map<String, Object>> wrapperListToSendByEvent = new List<Map<String, Object>>();
        for (String containerId : recordIdSet) {
            wrapperListToSendByEvent.add(buildWrapperToSendByEvent(recordIdSet));
        }
        if(wrapperListToSendByEvent.isEmpty()){
            return;
        }
        Unlocated_Container_Created__e platformEvent = buildContainerCreatedEvent(wrapperListToSendByEvent);
        Database.SaveResult sr = EventBus.publish(platformEvent);
        if(!sr.isSuccess()){
            String errorMessage = '';
            for(Database.Error error : sr.getErrors()){
                errorMessage+=error.getMessage()+'\n';
            }
            throw new PlatformEventBuilderException(errorMessage);
        }
    }

    private static Map<String, Object> buildWrapperToSendByEvent(Set<Id> recordIdSet) {
        Map<String, Object> wrapperMap = new Map<String, Object>();
        for (String recordId : recordIdSet) {
            wrapperMap.put('recordId', recordId);
        }
        return wrapperMap;
    }

    private static Container_Warehouse_Update__e buildContainerWarehousePlatformEvent(List<Map<String, Object>> wrapperListToSendByEvent) {
        return new Container_Warehouse_Update__e(UpdatedRows__c = JSON.serialize(wrapperListToSendByEvent));
    }

    private static Unlocated_Container_Created__e buildContainerCreatedEvent(List<Map<String, Object>> wrapperListToSendByEvent) {
        return new Unlocated_Container_Created__e(UpdatedRows__c = JSON.serialize(wrapperListToSendByEvent));
    }

    /**
     * @description  PlatformEventBuilderException class
     * @author Kostiantyn Murin
     * @date 06-07-2023
     */
    public class PlatformEventBuilderException extends Exception {}
}