public with sharing class WarehouseService {

    public static void distributeContainers(List<Container__c> containerList) {
        List<WarehouseTransaction__c> transactionList = new List<WarehouseTransaction__c>();
        List<Container__c> containerToUpdateList = new List<Container__c>();
        List<Cell__c> updatedCells = new List<Cell__c>();

        Map<Id, List<Cell__c>> warehouseToCellMap = CellSelector.getAllWarehouseToCellMap();

        for (Integer i = 0; i < containerList.size(); i++) {
            Container__c theContainer = containerList[i].clone(false, true, false, false);
            theContainer.Id = containerList[i].Id;
            Boolean isFromShip = theContainer.Source__c == Container.SOURCE_IS_SHIP;
            Date deliveryDate =  WarehouseHelper.calculateDeliveryDate(i+1, containerList.size(), isFromShip);
            theContainer.DeliveryDate__c = deliveryDate;
            theContainer.Status__c = isFromShip ? Container.STATUS_AWAITING_ISSUANCE : Container.STATUS_AWAITING_SHIPMENT;

            // find free cell for this container
            Cell__c targetCell = WarehouseHelper.findTargetCellForContainer(theContainer, warehouseToCellMap.get(theContainer.Warehouse__c));

            if (targetCell != null) {
                // update cell
                targetCell.Status__c = Cell.STATUS_OCCUPIED;
                targetCell.DeliveryDate__c = theContainer.DeliveryDate__c;
                targetCell.Container__c = theContainer.Id;
                updatedCells.add(targetCell);

                // create warehouse transaction
                transactionList.add(WarehouseTransactionManager.createTransaction(theContainer, targetCell.Id, '', targetCell.Location__c));
            } else {
                // Cell not found, move container to the temp storage
                theContainer.Is_In_Temporary_Storage__c = true;
            }
            containerToUpdateList.add(theContainer);
        }
        
        // Update containers, cells and create transactions
        Savepoint sp = Database.setSavepoint();
        try {
            if (!containerToUpdateList.isEmpty()){
                update containerToUpdateList;
            }
            if (!updatedCells.isEmpty()){
                update updatedCells;
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