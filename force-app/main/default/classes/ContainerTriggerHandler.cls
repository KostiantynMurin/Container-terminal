public class ContainerTriggerHandler extends TriggerHandler {
    public static Boolean skip = false;

    /*  check for needed manipulations( run containers removing batch )"		 */

    private ContainerTriggerHandlerHelper helper = new ContainerTriggerHandlerHelper();

    protected override void beforeInsert() {
        if (skip) return;
        System.debug('before Insert');
        helper.setArrivingDay((List<Container__c>) Trigger.new);
        helper.assignContacts((List<Container__c>) Trigger.new);
    }

    protected override void beforeUpdate() {
        if (skip) return;
        helper.updateOnRelease((List<Container__c>) Trigger.new, (Map<Id, Container__c>) Trigger.oldMap);
    }

    protected override void afterInsert() {
        if (skip) return;
        System.debug('after Insert');

        helper.runContactsRetrieve((List<Container__c>) Trigger.new);
    }

    protected override void afterUpdate() {
        if (skip) return;
    }
}
