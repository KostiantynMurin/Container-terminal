/**
 * @description  The batch class for distribute containers.
 * @author Kostiantyn Murin
 * @date 07-07-2023
 */
public with sharing class ContainerDistributorBatch implements Database.Batchable<Container__c>, Database.Stateful {

    private List<Container__c> containerList;
    private String issuedStatus = 'Issued';
    private String query = 'SELECT Id, ' +
                          '        Issuance_Date__c, ' +
                          '        Status__c ' +
                          'FROM Container__c ' +
                          'WHERE Warehouse_Cell__c = null ' +
                          'AND Status__c != :issuedStatus ' +
                          'AND Issuance_Date__c != null ' +
                          'ORDER BY Issuance_Date__c DESC';

    /**
     * @description  Constructor.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public ContainerDistributorBatch(List<Container__c> containerList) {
        this.containerList = containerList;
    }

    /**
     * @description  Constructor.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public ContainerDistributorBatch() {}
    
    /**
     * @description  Collect the batches of records or objects to be passed to execute. Container__c list.
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public Iterable<Container__c> start(Database.BatchableContext BC) {
        if (containerList == null) {
            System.Iterable<Container__c>  contList = (Iterable<Container__c>)Database.getQueryLocator(this.query);
            return contList;
        }
        return (Iterable<Container__c>)this.containerList;
    }

    /**
     * @description  Process each batch of Container__c records. Run ContainerDistributorService
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public void execute(Database.BatchableContext BC, List<Container__c> scope){
        ContainerDistributorService service = new ContainerDistributorService(scope);
        service.run();
    }

    /**
     * @description  Publish platform Event
     * @author Kostiantyn Murin
     * @date 07-07-2023
     */
    public void finish(Database.BatchableContext BC){
        publishPlatformEvent();
    }

    private static void publishPlatformEvent() {
        Map<Id, Container_Warehouse__c> warehouseMap = new Map<Id, Container_Warehouse__c>([
                SELECT Id FROM Container_Warehouse__c
            ]);
        PlatformEventBuilder.publishUnlocatedContainersCreatedEvent(warehouseMap.keySet());
    }
}