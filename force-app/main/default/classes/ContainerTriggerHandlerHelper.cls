public with sharing class ContainerTriggerHandlerHelper {
	private Map<String, Container__c> externalContactIdToContainerMap = new Map<String, Container__c>();
	private Boolean isPopulateContainersWithContact = false;
	private Boolean isDistributionOfContainersFromTheShip = false;

	public void populateArrivalDate(Container__c pContainer) {
		pContainer.Arrival_Date__c = date.today();
	}

	public void prepareContainerWithContact(Container__c pContainer) {
		if (pContainer.Contact__c == null && String.isNotBlank(pContainer.External_Contact_ID__c)) {
			externalContactIdToContainerMap.put(pContainer.External_Contact_ID__c, pContainer);
		}
	}

	public void checkPopulateContainersWithContact(Container__c pContainer) {
		if (pContainer.Contact__c == null && String.isNotBlank(pContainer.External_Contact_ID__c)) {
			isPopulateContainersWithContact = true;
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
		if (isPopulateContainersWithContact) {
			List<CronTrigger> scheduledJobs = [
				SELECT Id
				FROM CronTrigger
				WHERE CronJobDetail.Name = 'Container_PopulateWithContactBatch'
			];

			if (scheduledJobs.isEmpty()) {
				System.scheduleBatch(
					new Container_PopulateWithContactBatch(),
					'Container_PopulateWithContactBatch',
					5
				);
			}
		}
	}

	public void checkDistributionOfContainersFromTheShip(Container__c pContainer) {
		String dayOfWeek = pContainer.Arrival_Date__c.format('EEEE');
		if (dayOfWeek == 'Saturday') {
			isDistributionOfContainersFromTheShip = true;
		}
	}

	public void distributionOfContainersFromTheShip() {
		List<CronTrigger> scheduledJobs = [
			SELECT Id
			FROM CronTrigger
			WHERE CronJobDetail.Name = 'Container_DistributionFromTheShipBatch'
		];

		if (scheduledJobs.isEmpty()) {
			System.scheduleBatch(
				new Container_DistributionFromTheShipBatch(),
				'Container_DistributionFromTheShipBatch',
				5
			);
		}
	}
}