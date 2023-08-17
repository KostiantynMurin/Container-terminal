public with sharing class WarehouseCellService {
    
    public static void relocateContainers(List<SObject> newList, Map<Id, SObject> oldMap) {
        if (areAnyWarehouseCellsEmpty((List<Warehouse_Cell__c>)newList, (Map<Id, Warehouse_Cell__c>)oldMap)) {
            List<Container__c> containerList = [
                SELECT Id, Issuance_Date__c, Status__c
                FROM Container__c
                WHERE Status__c IN :Constants.ARRIVED_STATUS_LIST
                        AND Warehouse_Cell__c = null
                ORDER BY Issuance_Date__c DESC
            ];

            if (containerList.isEmpty()) {
                return;
            }

            // Do Container Allocation logic here
        }
    }

    private static Boolean areAnyWarehouseCellsEmpty(List<Warehouse_Cell__c> newList, Map<Id, Warehouse_Cell__c> oldMap) {        
        for (Warehouse_Cell__c wCell : newList) {
            if (wCell.Is_Free__c && !oldMap.get(wCell.Id).Is_Free__c) {
                return true;
            }
        }

        return false;
    }
}