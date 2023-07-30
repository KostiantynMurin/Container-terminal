public with sharing class CellHelper {
    
    public static void cleanCellsForContainers(List<Container__c> containersList){
        List<WarehouseTransaction__c> transactionList = new List<WarehouseTransaction__c>();
        List<Cell__c> cellToUpdateList = new List<Cell__c>();

        List<Cell__c> cellList = CellSelector.getOccupiedCellsByContainers(containersList);
        for (Cell__c theCell: cellList){
            transactionList.add(WarehouseTransactionManager.createTransaction(theCell.Container__r, theCell.Id, theCell.Location__c, ''));

            theCell.Status__c = Cell.STATUS_FREE;
            theCell.DeliveryDate__c = null;
            theCell.Container__c = null;
            cellToUpdateList.add(theCell);
        }

        // Update cells and create transactions
        Savepoint sp = Database.setSavepoint();
        try {
            if (!cellToUpdateList.isEmpty()){
                update cellToUpdateList;
            }
            if (!transactionList.isEmpty()){
                insert transactionList;
            }
        } catch(exception ex){
            Database.rollback(sp);
            throw new DmlException(ex.getMessage());
        }
    }
}