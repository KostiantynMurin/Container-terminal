/**
 * @description  ContainerDistributorService class.
 * @author Kostiantyn Murin
 * @date 07-07-2023
 */
public with sharing class ContainerDistributorService {

    private List<Container__c> containerList;
    private static final String DEFAULT_WAREHOUSE_NAME = 'CT1W1';

    /**
     * @description  Constructor.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     * @param containerList containers for distribution
     */
    public ContainerDistributorService(List<Container__c> containerList) {
        this.containerList = containerList;
    }
    
    /**
     * @description  Run distribution proccess.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public void run() {
        List<Container_Warehouse__c> warehouseList = [SELECT Id,
                                                             Length__c,
                                                             Width__c,
                                                             Max_Cell_Level__c
                                                      FROM Container_Warehouse__c
                                                      WHERE Name = :DEFAULT_WAREHOUSE_NAME];
        ContainerWarehouseStructure warehouseStructure;
        if (warehouseList.isEmpty()) {
            warehouseStructure = new ContainerWarehouseStructure(getDefaultWarehouse());
        } else {
            warehouseStructure = new ContainerWarehouseStructure(warehouseList.get(0));
        }
        distributeContainers(warehouseStructure);
    }

    private Container_Warehouse__c getDefaultWarehouse() {
        List<Container_Warehouse__c> warehouseToInsertList = new List<Container_Warehouse__c>{
            new Container_Warehouse__c(
                Name = DEFAULT_WAREHOUSE_NAME,
                Length__c = 5,
                Width__c = 4,
                Max_Cell_Level__c = 4
            )
        };
        DMLExecutor.doInsert(warehouseToInsertList);
        return warehouseToInsertList[0];
    }

    private void distributeContainers(ContainerWarehouseStructure warehouseStructure) {
        List<Container__c> newContainerList = new List<Container__c>(this.containerList);
        List<Warehouse_Cell__c> cellList = warehouseStructure.getCellList();
        Map<Id, Container__c> cellIdToContainerMap = warehouseStructure.getCellIdToContainerMap();
        List<List<List<Warehouse_Cell__c>>> warehouseMatrix = warehouseStructure.getWarehouseMatrix();

        List<Warehouse_Cell__c> cellsToUpdate = new List<Warehouse_Cell__c>();
        List<Container__c> containersToUpdate = new List<Container__c>();

        for (Integer i = 0; i < warehouseStructure.getWidth(); i++) {
            for (Integer j = 0; j < warehouseStructure.getLength(); j++) {
                for (Integer k = 0; k < warehouseStructure.getMaxCellLevel(); k++) {
                    Warehouse_Cell__c currentCell = warehouseMatrix[i][j][k];
                    Warehouse_Cell__c downstreamCell = k == 0 ? null : warehouseMatrix[i][j][k - 1];
                    Boolean isTopCell = k == warehouseStructure.getMaxCellLevel() - 1;

                    if (newContainerList.isEmpty()) {
                        break;
                    }
                    if (!currentCell.Is_Empty__c) {
                        continue;
                    } else if (currentCell.Is_Empty__c) {
                        Container__c container = newContainerList.remove(0);
                        Container__c downstreamContainer = downstreamCell == null ? null : cellIdToContainerMap.get(downstreamCell.Id);
                        if ((downstreamCell == null)
                            || (downstreamContainer != null && 
                                downstreamContainer.Issuance_Date__c >= container.Issuance_Date__c &&
                                (isSamePurpose(container.Status__c, downstreamContainer.Status__c) || isTopCell && isContainerForIssuance(container.Status__c))))
                        {
                            currentCell.Is_Empty__c = false;
                            cellsToUpdate.add(currentCell);
                            container.Warehouse_Cell__c = currentCell.Id;
                            container.Status__c = getStatus(container.Status__c);
                            containersToUpdate.add(container);
                            cellIdToContainerMap.put(currentCell.Id, container);
                        } else {
                            container.Status__c = getStatus(container.Status__c);
                            addToStartOfList(newContainerList, container);
                            continue;
                        }
                    }
                }
            }
        }

        DMLExecutor.doUpdate(cellsToUpdate);
        containersToUpdate.addAll(newContainerList);
        DMLExecutor.doUpdate(containersToUpdate);
    }

    private static String getStatus(String status) {
        String updatedStatus = status == 'Arrived for issuance' 
                                    ? 'Awaiting issuance' 
                                    : status == 'Arrived for shipment' 
                                        ? 'Awaiting shipment' 
                                        : status;
        return updatedStatus;
    }

    private static Boolean isContainerForShipment(String currentContainerStatus) {
        return currentContainerStatus == 'Arrived for shipment' || currentContainerStatus == 'Awaiting shipment';
    }

    private static Boolean isContainerForIssuance(String currentContainerStatus) {
        return currentContainerStatus == 'Arrived for issuance' || currentContainerStatus == 'Awaiting issuance';
    }

    private static Boolean isSamePurpose(String currentContainerStatus, String downstreamContainerStatus) {
        return isContainerForShipment(currentContainerStatus) && isContainerForShipment(downstreamContainerStatus)
            || isContainerForIssuance(currentContainerStatus) && isContainerForIssuance(downstreamContainerStatus);
    }

    private static void addToStartOfList(List<Container__c> containerList, Container__c container) {
        if (containerList.isEmpty()) {
            containerList.add(container);
        } else {
            containerList.add(0, container);
        }
    }
}