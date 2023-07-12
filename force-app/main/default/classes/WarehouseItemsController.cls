public with sharing class WarehouseItemsController {
    
    @AuraEnabled(cacheable=true)
    public static List<CellWrapper> getCells(Id warehouseId) {
        List<Cell__c> cells = [
            SELECT Id, Name, Code__c, Row__c, Column__c, Level__c, Container__c, Container__r.Name, Container__r.Delivery_Date__c, Container__r.Status__c
            FROM Cell__c 
            WHERE Warehouse__c = :warehouseId
        ];

        List<CellWrapper> cellWrappers = new List<CellWrapper>();
        for (Cell__c cell : cells) {
            cellWrappers.add(new CellWrapper(cell));
        }

        return cellWrappers;
    }


    public class CellWrapper {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String code { get; set; }
        @AuraEnabled public String row { get; set; }
        @AuraEnabled public Decimal column { get; set; }
        @AuraEnabled public Decimal level { get; set; }
        @AuraEnabled public Id containerId { get; set; }
        @AuraEnabled public String containerName { get; set; }
        @AuraEnabled public Date deliveryDate { get; set; }
        @AuraEnabled public String status { get; set; }
    
        public CellWrapper(Cell__c cell) {
            this.id = cell.Id;
            this.name = cell.Name;
            this.code = cell.Code__c;
            this.row = cell.Row__c;
            this.column = cell.Column__c;
            this.level = cell.Level__c;
            this.containerId = cell.Container__c;
            this.containerName = cell.Container__r.Name;
            this.status = cell.Container__r.Status__c;
            this.deliveryDate = cell.Container__r.Delivery_Date__c;
        }
    }
}