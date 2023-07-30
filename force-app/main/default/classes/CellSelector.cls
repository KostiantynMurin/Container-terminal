public with sharing class CellSelector {

     // Get Map warehouse to cells
     public static Map<Id, List<Cell__c>> getAllWarehouseToCellMap() {
        Map<Id, List<Cell__c>> warehouseToCellsMap = new Map<Id, List<Cell__c>>();
        for (Cell__c cell : [
            SELECT Id, Warehouse__c, Status__c, Level__c, Container__r.DeliveryDate__c, Location__c, Column__c
            FROM Cell__c 
            WITH SECURITY_ENFORCED 
            ORDER BY DeliveryDate__c ASC, Location__c ASC
        ]) {
            if (!warehouseToCellsMap.containsKey(cell.Warehouse__c)) {
                warehouseToCellsMap.put(cell.Warehouse__c, new List<Cell__c>());
            }
            warehouseToCellsMap.get(cell.Warehouse__c).add(cell);
        }
        return warehouseToCellsMap;
    }

    // Get List cells occupied by containers
    public static List<Cell__c> getOccupiedCellsByContainers(List<Container__c> containersList){
        return [
            SELECT Id, Status__c, DeliveryDate__c, Location__c, 
                Container__c, Container__r.Warehouse__c, Container__r.Source__c
            FROM Cell__c 
            WHERE Container__c IN :containersList 
            AND Status__c = :Cell.STATUS_OCCUPIED
            WITH SECURITY_ENFORCED];
    }
}