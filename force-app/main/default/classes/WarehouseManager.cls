public with sharing class WarehouseManager {
    public static final Integer DELIVERY_DAYS = 5;

    public static void distributeContainers(List<Container__c> containerList) {
        WarehouseService.distributeContainers(containerList);
    }

}