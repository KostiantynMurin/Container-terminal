trigger Storage on Storage__c(
	before insert,
	before update,
	after insert,
	after update,
	before delete,
	after delete
) {
	new StorageTriggerHandler().run();
}