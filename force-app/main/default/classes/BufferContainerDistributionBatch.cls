public class BufferContainerDistributionBatch implements Database.Batchable<sObject>, Schedulable {

    private String query = 'SELECT Id'
                              + ', Status__c'
                              + ', Date_Of_Issue__c'
                        + ' FROM Container__c ';
    private String condition;
    private String order = ' ORDER BY Status__c, Date_Of_Issue__c ASC NULLS LAST';
    private Id bufferZoneRTId;

    public BufferContainerDistributionBatch() {
        this.query += ' WHERE Warehouse_Cell__r.Warehouse__r.RecordTypeId =: bufferZoneRTId';
        this.query += ' AND Status__c IN (\'Waiting For Delivery\', \'Waiting For Shipment\')';
        this.query += order;
    }

    public BufferContainerDistributionBatch(String condition) {
        this.condition = condition;
        query += condition != null ? condition : '';
        this.query += order;
    }

    public void execute(SchedulableContext sc) {
        if (String.isBlank(condition)) {
            Database.executeBatch(new BufferContainerDistributionBatch());
        } else {
            Database.executeBatch(new BufferContainerDistributionBatch(condition));
        } 
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        this.bufferZoneRTId = WarehouseUtil.bufferZoneRTId;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Container__c> scope) {

        System.debug('scope : ' + scope);
        WarehousesDataService whDataService = WarehousesDataService.getInstance();

        Map<Id, Container__c> containersToUpdate = new Map<Id, Container__c>();

        CellDataWrapper clientEmptyCell = null;
        CellDataWrapper shipmentEmptyCell = null;

        for (Container__c container_i : scope) {

            CellDataWrapper currentEmptyCell = null;

            if (container_i.Status__c == 'Waiting For Delivery') {
                clientEmptyCell = whDataService.getEmptyCellForClientContainer(container_i.Date_Of_Issue__c, clientEmptyCell?.warehouseId);
                currentEmptyCell = clientEmptyCell;
            } else {
                shipmentEmptyCell = whDataService.getEmptyCellForShipmentContainer(shipmentEmptyCell?.warehouseId);
                currentEmptyCell = shipmentEmptyCell;
            }

            if (currentEmptyCell.isBufferZoneCell) {
                break;
            }

            whDataService.placeContainerToCell(container_i, currentEmptyCell);
            containersToUpdate.put(container_i.Id, container_i);
        }

        if (containersToUpdate.isEmpty()) {
            return;
        }

        List<Container__c> lockedContainers = [SELECT Id FROM Container__c WHERE Id IN: containersToUpdate.keySet() FOR UPDATE];

        update containersToUpdate.values();
    }

    public void finish(Database.BatchableContext bc) {}
}