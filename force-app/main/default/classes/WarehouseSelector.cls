public with sharing class WarehouseSelector {
    public static List<Warehouse__c> getWarehouses() {

        List<Warehouse__c> warehouseList = [
            SELECT Id, Capacity__c, CurrentCapacity__c 
            FROM Warehouse__c 
            WITH SECURITY_ENFORCED
            ORDER BY CurrentCapacity__c ASC
        ];

        return warehouseList;
    }
}