public class ContainerTriggerHandler extends TriggerHandler {
    // public static Boolean skip = false;


    /* "for inserts, when a list of containers is added -> create contacts 
    and run the batch to retrieve data for them
    (if not new contacts is added -> run the incoming batch for containers)
    on after update: check the status and clear the storage unit from container;
     check for needed manipulations( run containers removing batch )"		 */

    private ContainerTriggerHandlerHelper helper = new ContainerTriggerHandlerHelper();

    protected override void beforeInsert() {
        // if (skip) return;
        System.debug('before Insert');
        helper.setArrivingDay((List<Container__c>) Trigger.new);
        helper.assignContacts((List<Container__c>) Trigger.new);
        // helper.changeTheIncomeStatus((List<Container__c>) Trigger.new);
    }

    protected override void beforeUpdate() {
        // if (skip) return;
    }

    protected override void afterInsert() {
        // if (skip) return;
        System.debug('after Insert');

        helper.runContactsRetrieve((List<Container__c>) Trigger.new);
    }

    protected override void afterUpdate() {
        // if (skip) return;
        // helper.modifyStorageUnits((List<Container__c>) Trigger.new, (Map<Id, Container__c>) Trigger.oldMap );
    }
}
