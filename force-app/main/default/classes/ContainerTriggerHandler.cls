public with sharing class ContainerTriggerHandler {

    public void handleBeforeInsert(List<Container__c> newContainerList) {
        Set<String> externalIdSet = new Set<String>();

        if (newContainerList.size() == 1){
            if (newContainerList.get(0).Source__c == null) newContainerList.get(0).Source__c = Container.SOURCE_IS_TRUCK;
            if (newContainerList.get(0).Status__c == null) newContainerList.get(0).Status__c = Container.STATUS_ARRIVED_SHIPMENT;

        } else {
            for (Container__c theContainer : newContainerList) {
                if (newContainerList.get(0).Source__c == null) theContainer.Source__c = Container.SOURCE_IS_SHIP;
                if (newContainerList.get(0).Status__c == null) theContainer.Status__c = Container.STATUS_ARRIVED_ISSUANCE;
            }
        }

        // Fetch externalId Set
        for (Container__c theContainer : newContainerList) {
            externalIdSet.add(theContainer.ExternalId__c);
        }

        Map<String, Contact> ExtIdToContactMap = ContactSelector.getExistingContactsByExtId(externalIdSet);
        List<Warehouse__c> warehouseList = WarehouseSelector.getWarehouses();

        for (Container__c theContainer : newContainerList) {
            Contact contact = ExtIdToContactMap.get(theContainer.ExternalId__c);
            if (contact != null) {
                theContainer.Contact__c = contact.Id;
            }

            //Select and set warehouse
            if (!warehouseList.isEmpty()){
                for(Warehouse__c whouse: warehouseList){
                    if (whouse.Capacity__c >= newContainerList.size()){
                        theContainer.Warehouse__c = whouse.Id;
                    }
                }
                if(theContainer.Warehouse__c == null){
                    theContainer.Warehouse__c = warehouseList.get(0).Id;
                }
            }
        }
    }

    public void handleAfterInsert(List<Container__c> newContainerList) {
        Set<String> externalIds = new Set<String>();
        for (Container__c container : newContainerList) {
            if (container.Contact__c == null) {
                externalIds.add(container.ExternalId__c);
            }
        }

        if (!externalIds.isEmpty()) {
            System.enqueueJob(new ContactCreatorQueue(externalIds));
        }

        WarehouseService.distributeContainers(newContainerList);
    }

    public void handleAfterUpdate(List<Container__c> newContainerList, Map<Id, Container__c> oldContainerMap){
        List<Container__c> containerToFreeCell = new List<Container__c>();
        for (Container__c newContainer : newContainerList) {
            Container__c oldContainer = oldContainerMap.get(newContainer.Id);
            
            if (oldContainer.Status__c != newContainer.Status__c && newContainer.Status__c == Container.STATUS_SHIPPED) {
                containerToFreeCell.add(newContainer);
            }
        }

        CellHelper.cleanCellsForContainers(containerToFreeCell);
    }
}