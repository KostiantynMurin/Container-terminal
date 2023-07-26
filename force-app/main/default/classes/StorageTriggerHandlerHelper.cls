public with sharing class StorageTriggerHandlerHelper {
	private List<Storage_Location__c> storageLocationToInsertList = new List<Storage_Location__c>();

	public void populateStorage(Storage__c pStorage) {
		for (Integer i = 1; i < pStorage.Width__c; i++) {
			for (Integer j = 1; j < pStorage.Length__c; j++) {
				for (Integer k = 1; k < pStorage.Height__c; k++) {
					Storage_Location__c storageLocation = new Storage_Location__c(
						Name = Storage__c.Name +
							': ' +
							String.valueOf(i) +
							'-' +
							String.valueOf(j) +
							'-' +
							String.valueOf(k),
						Storage__c = pStorage.Id,
						Width_Location__c = i,
						Length_Location__c = j,
						Height_Location__c = k
					);
					this.storageLocationToInsertList.add(storageLocation);
				}
			}
		}
	}

	public void initStorage() {
		if (!this.storageLocationToInsertList.isEmpty()) {
			insert this.storageLocationToInsertList;
		}
	}

	public void validateStorage(Storage__c pStorage) {
		if (
			pStorage.Length__c == null ||
			pStorage.Length__c == 0 ||
			pStorage.Width__c == null ||
			pStorage.Width__c == 0 ||
			pStorage.Height__c == null ||
			pStorage.Height__c == 0
		) {
			pStorage.addError('Width and Length and Height must be greater than 0');
		}
	}
}