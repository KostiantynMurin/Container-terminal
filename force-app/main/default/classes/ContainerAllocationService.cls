public with sharing class ContainerAllocationService {
    private Warehouse__c warehouse;
    private List<Warehouse_Cell__c> relatedCellList;
    private List<Warehouse_Cell__c> availableWCellList = new List<Warehouse_Cell__c>();

    public void initAllocationFlow(List<Container__c> containerList) {
        this.warehouse = [
            SELECT Id, Height_Containers__c, Width_Containers__c, Length_Containers__c 
            FROM Warehouse__c LIMIT 1
        ];

        this.relatedCellList = [
            SELECT Id, Unique_Address__c, Is_Free__c, (SELECT Id, Issuance_Date__c, Status__c FROM Containers__r) 
            FROM Warehouse_Cell__c
            WHERE Warehouse__c = :warehouse.Id
        ];

        for (Warehouse_Cell__c wCell : relatedCellList) {
            if (wCell.Is_Free__c) {
                this.availableWCellList.add(wCell);
            }
        }

        distributeContainers(containerList);
    }

    private void distributeContainers(List<Container__c> containerList) {
        List<Warehouse_Cell__c> cellListToUpdate = new List<Warehouse_Cell__c>();
        List<Container__c> containerListToUpdate = new List<Container__c>();

        for (Container__c container : containerList) {
            Warehouse_Cell__c availableWCell = this.availableWCellList.remove(0);
            availableWCell.Is_Free__c = false;
            cellListToUpdate.add(availableWCell);
            
            container.Warehouse_Cell__c = availableWCell.Id;
            container.Status__c = specifyNextStatus(container.Status__c);
            containerListToUpdate.add(container);
        }

        DMLExecutor.doUpdate(cellListToUpdate);
        DMLExecutor.doUpdate(containerListToUpdate);
    }

    private static String specifyNextStatus(String currentStatus) {
        return currentStatus == Constants.ARRIVED_FOR_ISSUANCE 
                ? Constants.AWAITING_ISSUANCE 
                : currentStatus == Constants.ARRIVED_FOR_SHIPMENT 
                    ? Constants.AWAITING_SHIPMENT 
                    : currentStatus;
    }

}