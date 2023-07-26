public without sharing virtual class CalloutService {
	public List<Log__c> getAllInsertedLogs() {
		return LogRegistrar.getAllInsertedLogs();
	}

	public virtual void insertAllLogs() {
		LogRegistrar.insertAllLogs();
	}
}