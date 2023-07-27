public with sharing class ContainerTriggerHandlerHelper {
	private Map<String, Container__c> externalContactIdToContainerMap = new Map<String, Container__c>();

	public void prepareContainerWithContact(Container__c pContainer) {
		if (pContainer.Contact__c == null && String.isNotBlank(pContainer.External_Contact_ID__c)) {
			externalContactIdToContainerMap.put(pContainer.External_Contact_ID__c, pContainer);
		}
	}

	public void populateContainersWithContact() {
		Map<Id, Contact> contactMap = new Map<Id, Contact>(
			[
				SELECT Id
				FROM Contact
				WHERE External_ID_Container__c IN :externalContactIdToContainerMap.keySet()
			]
		);

		if (!contactMap.isEmpty()) {
			for (Id contactId_i : contactMap.keySet()) {
				Contact contact_i = contactMap.get(contactId_i);

				Container__c container = externalContactIdToContainerMap.get(
					contact_i.External_ID_Container__c
				);
				container.Contact__c = contactId_i;
			}
		}
	}

	public void populateContainersWithNewContact() {
		List<CronTrigger> scheduledJobs = [
			SELECT Id
			FROM CronTrigger
			WHERE CronJobDetail.Name = 'PopulateContainersWithContactsBatch'
		];

		if (scheduledJobs.isEmpty()) {
			System.scheduleBatch(
				new PopulateContainersWithContactsBatch(),
				'PopulateContainersWithContactsBatch',
				5
			);
		}
	}
}