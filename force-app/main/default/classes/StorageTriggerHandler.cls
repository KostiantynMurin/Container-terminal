public with sharing class StorageTriggerHandler extends TriggerHandler {
	private StorageTriggerHandlerHelper helper = new StorageTriggerHandlerHelper();

	protected override void beforeInsert() {
		for (Storage__c storage_i : (List<Storage__c>) Trigger.new) {
			helper.validateStorage(storage_i);
		}
	}

	protected override void beforeUpdate() {
		Map<Id, Storage__c> storageNewMap = (Map<Id, Storage__c>) Trigger.newMap;
		for (Id storageId_i : storageNewMap.keySet()) {
			Storage__c storage_i = storageNewMap.get(storageId_i);
		}
	}

	protected override void afterInsert() {
		Map<Id, Storage__c> storageNewMap = (Map<Id, Storage__c>) Trigger.newMap;
		for (Id storageId_i : storageNewMap.keySet()) {
			Storage__c storage_i = storageNewMap.get(storageId_i);

			helper.populateStorage(storage_i);
		}

		helper.initStorage();
	}

	protected override void afterUpdate() {
		Map<Id, Storage__c> storageNewMap = (Map<Id, Storage__c>) Trigger.newMap;
		for (Id storageId_i : storageNewMap.keySet()) {
			Storage__c storage_i = storageNewMap.get(storageId_i);
		}
	}
}