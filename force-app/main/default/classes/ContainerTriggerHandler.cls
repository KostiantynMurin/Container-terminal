public with sharing class ContainerTriggerHandler extends TriggerHandler {
	private ContainerTriggerHandlerHelper helper = new ContainerTriggerHandlerHelper();

	protected override void beforeInsert() {
		for (Container__c container_i : (List<Container__c>) Trigger.new) {
			helper.populateArrivalDate(container_i);
			helper.prepareContainerWithContact(container_i);
		}

		helper.populateContainersWithContact();
	}

	protected override void beforeUpdate() {
		Map<Id, Container__c> containerNewMap = (Map<Id, Container__c>) Trigger.newMap;
		for (Id containerId_i : containerNewMap.keySet()) {
			Container__c container_i = containerNewMap.get(containerId_i);
		}
	}

	protected override void afterInsert() {
		Map<Id, Container__c> containerNewMap = (Map<Id, Container__c>) Trigger.newMap;
		for (Id containerId_i : containerNewMap.keySet()) {
			Container__c container_i = containerNewMap.get(containerId_i);

			helper.checkPopulateContainersWithContact(container_i);
			helper.checkDistributionOfContainersFromTheShip(container_i);
		}

		helper.populateContainersWithNewContact();
		helper.distributionOfContainersFromTheShip();
	}

	protected override void afterUpdate() {
		Map<Id, Container__c> containerNewMap = (Map<Id, Container__c>) Trigger.newMap;
		for (Id containerId_i : containerNewMap.keySet()) {
			Container__c container_i = containerNewMap.get(containerId_i);
		}
	}
}