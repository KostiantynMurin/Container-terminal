public with sharing class WarehouseTransactionManager {

    public static WarehouseTransaction__c createTransaction(Container__c theContainer, Id cellId, String fromLocation, String toLocation) {
        String type = theContainer.Source__c == Container.SOURCE_IS_SHIP 
            ? WarehouseTransaction.TYPE_SHIP_TO 
            : WarehouseTransaction.TYPE_TRUCK_TO;
        if (toLocation == ''){
            type = WarehouseTransaction.TYPE_DELIVERED;
        }

        return new WarehouseTransaction__c(
                    Warehouse__c = theContainer.Warehouse__c,
                    Container__c = theContainer.Id,
                    Cell__c = cellId,
                    TransactionDate__c = System.now(),
                    FromLocation__c = fromLocation,
                    ToLocation__c = toLocation,
                    Type__c = type
                );
    }
}