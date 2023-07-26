public with sharing class ContainerTriggerHandlerHelper {
	private Map<String, Container__c> externalContactIdToContainerMap = new Map<String, Container__c>();

	public void prepareContainerWithContact(Container__c pContainer) {
		if (String.isNotBlank(pContainer.External_Contact_ID__c)) {
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
			Map<String, Contact> externalContactIdToContactMap = new Map<String, Contact>();
			for (String contactId_i : contactMap.keySet()) {
				Contact contact_i = contactMap.get(contactId_i);

				Container__c container = externalContactIdToContainerMap.get(
					contact_i.External_ID_Container__c
				);
				container.Contact__c = contactId_i;

				externalContactIdToContainerMap.remove(contact_i.External_ID_Container__c);
			}
		}
	}

	public void populateContainersWithNewContact() {
		if (!externalContactIdToContainerMap.isEmpty()) {
			// TODO: run Batch for obtain new Contact
		}
	}
}