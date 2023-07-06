public with sharing class ContainerTRDispatcher {
    
    public static void populateValuesOnArrival(List<Container__c> processingRecords) {
        System.debug('ContainerTRDispatcher => populateValuesOnArrival');

        ContainerTRService.populateValuesOnArrival(processingRecords);
    }

    public static void assignContacts(List<Container__c> processingRecords) {
        System.debug('ContainerTRDispatcher => assignContacts');

        Set<String> contactsExternalIds = new Set<String>();
        List<Container__c> containersToLinkContacts = new List<Container__c>();

        for (Container__c container_i : processingRecords) {
            
            if (String.isBlank(container_i.Contact_Ext_Id__c)) {
                continue;
            }
            
            contactsExternalIds.add(container_i.Contact_Ext_Id__c);
            containersToLinkContacts.add(container_i);
        }

        if (containersToLinkContacts.isEmpty()) {
            return;
        }

        ContainerTRService.assignContacts(containersToLinkContacts, contactsExternalIds);
    }

    public static void scheduleContactAssignmentJob() {
        System.debug('ContainerTRDispatcher => scheduleContactAssignmentJob');

        List<CronTrigger> existedJobs = [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'ContactsCreationBatch'
            AND State != 'COMPLETE'
        ];

        if (!existedJobs.isEmpty()) {
            return;
        }

        ContainerTRService.scheduleContactAssignmentJob();
    }

    public static void distributeContainersForShipment(List<Container__c> processingRecords) {
        System.debug('ContainerTRDispatcher => distributeContainersForShipment');

        List<Container__c> containersToDistribute = new List<Container__c>();

        for (Container__c container_i : processingRecords) {
            
            if (container_i.Status__c == 'Arrived For Shipment') {
                containersToDistribute.add(container_i);
            }
        }

        if (containersToDistribute.isEmpty()) {
            return;
        }

        ContainerTRService.distributeContainersForShipment(containersToDistribute);
    }

    public static void removeContainersFromWarehouseAfterDeliveryShipment(List<Container__c> processingRecords, Map<Id, Container__c> oldMap) {
        System.debug('ContainerTRDispatcher => removeContainersFromWarehouseAfterDeliveryShipment');

        Map<Id, Map<String, Container__c>> warehouseIdToMapOfCellAddressToContainerMap = new Map<Id, Map<String, Container__c>>();

        for (Container__c container_i : processingRecords) {
            
            if (container_i.Warehouse_Cell__c == null) {
                continue;
            }

            Container__c oldContainer = oldMap.get(container_i.Id);

            if ((container_i.Status__c == 'Delivered' && oldContainer.Status__c == 'Waiting For Delivery') ||
                    (container_i.Status__c == 'Shipped' && oldContainer.Status__c == 'Waiting For Shipment')) {
                
                if (!warehouseIdToMapOfCellAddressToContainerMap.containsKey(container_i.Warehouse_Id__c)) {
                    warehouseIdToMapOfCellAddressToContainerMap.put(container_i.Warehouse_Id__c, new Map<String, Container__c>());
                }
                warehouseIdToMapOfCellAddressToContainerMap.get(container_i.Warehouse_Id__c).put(container_i.Warehouse_Cell_Address__c, container_i);
            }
        }

        if (warehouseIdToMapOfCellAddressToContainerMap.isEmpty()) {
            return;
        }

        Map<Id, List<Container__c>> warehouseIdToContainersOrderedByCellAddressMap = new Map<Id, List<Container__c>>();

        for (Id warehouseId_i : warehouseIdToMapOfCellAddressToContainerMap.keySet()) {

            Map<String, Container__c> cellAddressToContainerMap = warehouseIdToMapOfCellAddressToContainerMap.get(warehouseId_i);

            List<String> orderedListOfCellAddresses = new List<String>(cellAddressToContainerMap.keySet());
            orderedListOfCellAddresses.sort();

            List<Container__c> containersOrderedByCellAddress = new List<Container__c>();

            for (String address_j : orderedListOfCellAddresses) {
                containersOrderedByCellAddress.add(cellAddressToContainerMap.get(address_j));
            }

            warehouseIdToContainersOrderedByCellAddressMap.put(warehouseId_i, containersOrderedByCellAddress);
        }

        ContainerTRService.removeContainersFromWarehouseAfterDeliveryShipment(warehouseIdToContainersOrderedByCellAddressMap);
    }
}