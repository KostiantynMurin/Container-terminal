public without sharing class ContainerTriggerHandler {
    
    public void onBeforeInsert(List<Container__c> newContainers) {
        setContainerArrived(newContainers);
    }

    public void onAfterInsert(List<Container__c> newContainers) {
        syncContainersCell(newContainers, null);
        registerContainerOperation(newContainers, null);

        ContainerContactCreateBatch batch = new ContainerContactCreateBatch(newContainers);
        Database.executeBatch(batch, 20);
    }

    public void onBeforeUpdate(List<Container__c> newContainers, Map<Id, Container__c> oldContainers) {
        cleanUpWarehouse(newContainers, oldContainers);
    }

    public void onAfterUpdate(List<Container__c> newContainers, Map<Id, Container__c> oldContainers) {
        syncContainersCell(newContainers, oldContainers);
        registerContainerOperation(newContainers, oldContainers);
    }

    private void setContainerArrived(List<Container__c> containers) {
        for (Container__c container : containers) {
            if (container.Status__c == null) {
                container.Status__c = ContainerHelper.STATUS_DELIVERY_ARRIVED;
            }

           if (container.Arrival_Date__c == null) {
               container.Arrival_Date__c = Date.today();
           }
        }
    }

    private void syncContainersCell(List<Container__c> newContainers, Map<Id, Container__c> oldContainers) {

        Set<Id> cellsIdsToUpdate = new Set<Id>();
        for (Container__c container : newContainers) {
            if (oldContainers == null) {
                cellsIdsToUpdate.add(container.Cell__c);
            } else if (container.Cell__c != oldContainers.get(container.Id).Cell__c) {
                cellsIdsToUpdate.add(container.Cell__c);
                cellsIdsToUpdate.add(oldContainers.get(container.Id).Cell__c);
            }
        }

        Map<Id, Cell__c> cellsToUpdate = new Map<Id, Cell__c>([SELECT Id, Container__c FROM Cell__c WHERE Id IN :cellsIdsToUpdate]);
        for (Container__c container : newContainers) {
            if (oldContainers == null) {
                if (container.Cell__c != null) {
                    cellsToUpdate.get(container.Cell__c).Container__c = container.Id;
                }
            } else if (container.Cell__c != oldContainers.get(container.Id).Cell__c) {
                if (container.Cell__c != null) {
                    cellsToUpdate.get(container.Cell__c).Container__c = container.Id;
                } 
                if (oldContainers.get(container.Id).Cell__c != null) {
                    cellsToUpdate.get(oldContainers.get(container.Id).Cell__c).Container__c = null;
                }
            }
        }

        update cellsToUpdate.values();
    }

    private void registerContainerOperation(List<Container__c> newContainers, Map<Id, Container__c> oldContainers) {

        List<Container_Operation__c> operationsToInsert = new List<Container_Operation__c>();
        for(Container__c container : newContainers) {
            
            if (oldContainers == null || container.Status__c != oldContainers.get(container.Id).Status__c || container.Cell__c != oldContainers.get(container.Id).Cell__c) {
                Container_Operation__c operation = new Container_Operation__c();

                operation.Container__c = container.Id;
                operation.Date_of_Operation__c = Datetime.now();

                if (container.Status__c == ContainerHelper.STATUS_DELIVERY_ARRIVED) {
                    operation.Action__c = ContainerHelper.ACTION_ARRIVED;
                } else if (container.Status__c == ContainerHelper.STATUS_DELIVERY_WAITING) {
                    operation.Action__c = ContainerHelper.ACTION_RELOCATED;
                    operation.New_Location__c = container.Cell__c;
                    if (oldContainers != null) {
                        operation.Initial_Location__c = oldContainers.get(container.Id).Cell__c;
                    }
                } else if (container.Status__c == ContainerHelper.STATUS_DELIVERED) {
                    operation.Action__c = ContainerHelper.ACTION_DELIVERED;
                    operation.Initial_Location__c = oldContainers.get(container.Id).Cell__c;
                    operation.New_Location__c = null;
                } else if (container.Status__c == ContainerHelper.STATUS_LOAD_ARRIVED) {
                    operation.Action__c = ContainerHelper.ACTION_ARRIVED;
                } else if (container.Status__c == ContainerHelper.STATUS_LOAD_WAITING) {
                    operation.Action__c = ContainerHelper.ACTION_RELOCATED;
                    operation.New_Location__c = container.Cell__c;
                    if (oldContainers != null) {
                        operation.Initial_Location__c = oldContainers.get(container.Id).Cell__c;
                    }
                } else if (container.Status__c == ContainerHelper.STATUS_LOADED) {
                    operation.Action__c = ContainerHelper.ACTION_LOADED;
                    operation.Initial_Location__c = oldContainers.get(container.Id).Cell__c;
                    operation.New_Location__c = null;
                } 

                operationsToInsert.add(operation);
            }
        }

        insert operationsToInsert;
    }

    private void cleanUpWarehouse(List<Container__c> newContainers, Map<Id, Container__c> oldContainers) {

        for(Container__c container : newContainers) {
            if (oldContainers == null || container.Status__c != oldContainers.get(container.Id).Status__c) {

                if (container.Status__c == ContainerHelper.STATUS_DELIVERED) {
                    container.Cell__c = null;
                } else if (container.Status__c == ContainerHelper.STATUS_LOADED) {
                    container.Cell__c = null;
                }
            }
        }
    }
}