public with sharing class ContainerService {

    private static Map<String, String> extCntIdToCntIdMap = new Map<String, String>(); //Map <External Contact Id, Contact Id>

    public static void initArrivedContainersProcess(List<Container__c> containerList) {

        Set<String> externalContactIdSet = new Set<String>();
        for (Container__c container : containerList) {
            externalContactIdSet.add(container.External_Contact_Id__c);
        }

        obtainContactsByExtCntIdSet(externalContactIdSet);

        for (Container__c container : containerList) {
            container.Delivery_Date__c = Date.today();
            if (container.Status__c == null) {
                container.Status__c = Constants.ARRIVED_FOR_ISSUANCE;
            }
            if (container.Status__c == Constants.ARRIVED_FOR_ISSUANCE) {
                container.Issuance_Date__c = Date.today().addDays(2 + (Integer)Math.floor(Math.random() * 5));
            }
            container.Contact__c = extCntIdToCntIdMap.get(container.External_Contact_Id__c);
        }        
    }

    public static void releaseWarehouseCellFromContainer(List<SObject> newList, Map<Id, SObject> oldMap) {
        Set<String> warehouseCellIdSet = new Set<String>();
        for (Container__c container : (List<Container__c>)newList) {
            Container__c oldContainer = (Container__c)oldMap.get(container.Id);
            if (oldContainer.Status__c != Constants.ISSUED 
                && container.Status__c == Constants.ISSUED
            ) {
                container.Warehouse_Cell__c = null;
                warehouseCellIdSet.add(oldContainer.Warehouse_Cell__c);
            }
        }

        updateWarehouseCellToFree(warehouseCellIdSet);
    }

    public static void updateWarehouseCellToFree(List<Container__c> oldList) {
        List<Warehouse_Cell__c> wCellListToUpdate = new List<Warehouse_Cell__c>();
        for (Container__c container : oldList) {
            if (container.Warehouse_Cell__c != null) {
                wCellListToUpdate.add(
                    new Warehouse_Cell__c(
                        Id = container.Warehouse_Cell__c,
                        Is_Free__c = true
                    )
                );
            }
        }

        DMLExecutor.doUpdate(wCellListToUpdate);
    }

    private static void updateWarehouseCellToFree(Set<String> warehouseCellIdSet) {
        List<Warehouse_Cell__c> wCellListToUpdate = new List<Warehouse_Cell__c>();
        for (String warehouseCellId : warehouseCellIdSet) {
            wCellListToUpdate.add(
                new Warehouse_Cell__c(
                    Id = warehouseCellId,
                    Is_Free__c = true
                )
            );
        }

        DMLExecutor.doUpdate(wCellListToUpdate);
    }

    private static void obtainContactsByExtCntIdSet(Set<String> externalContactIdSet) {
        List<Contact> existingContactList = new List<Contact>{[
            SELECT Id, External_Contact_Id__c 
            FROM Contact 
            WHERE External_Contact_Id__c IN :externalContactIdSet
        ]};

        for (Contact contact: existingContactList) {
            extCntIdToCntIdMap.put(contact.External_Contact_Id__c, contact.Id);
        }
    }
    
    
}