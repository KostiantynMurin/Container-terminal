public with sharing class ContainerTRService {
    
    public static void populateValuesOnArrival(List<Container__c> processingRecords) {

        for (Container__c container_i : processingRecords) {

            if (String.isBlank(container_i.Status__c)) {
                container_i.Status__c = 'Arrived For Delivery'; 
            }

            container_i.Arrival_Date__c = Datetime.now();
        }
    }
    
    public static void assignContacts(List<Container__c> processingRecords, Set<String> contactsExternalIds) {

        Map<String, Id> externalIdToContactIdMap = ContainerTRUtil.getExternalIdToContactIdMap(contactsExternalIds);

        for (Container__c container_i : processingRecords) {
            
            if (externalIdToContactIdMap.containsKey(container_i.Contact_Ext_Id__c)) {
                container_i.Contact__c = externalIdToContactIdMap.get(container_i.Contact_Ext_Id__c);
            }
        }
    }

    public static void scheduleContactAssignmentJob() {
        System.scheduleBatch(new ContactsCreationBatch(), 'ContactsCreationBatch', 5);
    }

    public static void distributeContainersForShipment(List<Container__c> processingRecords) {

        WarehousesDataService whDataService = WarehousesDataService.getInstance();

        CellDataWrapper emptyCell = null;

        for (Container__c container_i : processingRecords) {
            container_i.Status__c = 'Waiting For Shipment';
            emptyCell = whDataService.getEmptyCellForShipmentContainer(emptyCell?.warehouseId);
            whDataService.placeContainerToCell(container_i, emptyCell);
        }
    }

    public static void removeContainersFromWarehouseAfterDeliveryShipment(Map<Id, List<Container__c>> warehouseIdToContainersOrderedByCellAddressMap) {

        WarehousesDataService whDataService = WarehousesDataService.getInstance();

        Map<Id, Container__c> containersToUpdateMap = new Map<Id, Container__c>();

        for (Id warehouseId_i : warehouseIdToContainersOrderedByCellAddressMap.keySet()) {
            
            for (Container__c container_j : warehouseIdToContainersOrderedByCellAddressMap.get(warehouseId_i)) {
                
                CellDataWrapper currentCell = whDataService.getCell(warehouseId_i, container_j.Warehouse_Cell__c);
                CellDataWrapper nextCell = whDataService.getNextCell(currentCell);

                if (nextCell == null || nextCell.getContainer() == null) {
                    whDataService.removeContainerFromCell(container_j, currentCell);
                    continue;
                }

                List<CellDataWrapper> notEmptyCells = new List<CellDataWrapper>{nextCell};

                while (true) {

                    nextCell = whDataService.getNextCell(nextCell);

                    if (nextCell == null || nextCell.getContainer() == null) {
                        break;
                    }
                    notEmptyCells.add(nextCell);
                }

                whDataService.removeContainerFromCell(container_j, currentCell);

                for (CellDataWrapper notEmptyCell_i : notEmptyCells) {

                    Container__c containerToTransfer = notEmptyCell_i.getContainer();
                    whDataService.removeContainerFromCell(containerToTransfer, notEmptyCell_i);
                    whDataService.placeContainerToCell(containerToTransfer, currentCell);
                    containersToUpdateMap.put(containerToTransfer.Id, containerToTransfer);

                    currentCell = notEmptyCell_i;
                }
            }
        }

        if (containersToUpdateMap.isEmpty()) {
            return;
        }

        update containersToUpdateMap.values();
    }

    public static void changeCellAvailability(Set<Id> cellIdsToUpdate) {

        List<Cell__c> cellsToUpdate = new List<Cell__c>();

        for (Cell__c cell_i : [SELECT Id
                                    , Is_Empty__c
                                    , (SELECT Id FROM Containers__r LIMIT 1)
                               FROM Cell__c
                               WHERE Id IN: cellIdsToUpdate
                               AND Warehouse__r.RecordTypeId =: WarehouseTRUtil.warehouseRTId]) {
            
            Boolean isEmptyNewValue = cell_i.Containers__r.isEmpty();

            if (cell_i.Is_Empty__c != isEmptyNewValue) {
                cell_i.Is_Empty__c = isEmptyNewValue;
                cellsToUpdate.add(cell_i);
            }
        }

        if (cellsToUpdate.isEmpty()) {
            return;
        }

        update cellsToUpdate;
    }

    public static void scheduleBufferDistributionJob(List<CronTrigger> existedJobs) {

        if (!existedJobs.isEmpty()) {
            
            for (CronTrigger job_i : existedJobs) {
                System.abortJob(job_i.Id);
            }
        }

        System.scheduleBatch(new BufferContainerDistributionBatch(), 'BufferContainerDistributionBatch', 5);
    }
}