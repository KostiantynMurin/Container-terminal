public class Container_PopulateWithContactBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {
	private List<Contact> contactToInsertList = new List<Contact>();

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			'SELECT Id, External_Contact_ID__c' +
				'FROM Container__c ' +
				'WHERE Contact__c = NULL AND External_Contact_ID__c != NULL'
		);
	}

	public void execute(SchedulableContext SC) {
		Database.executeBatch(new Container_PopulateWithContactBatch(), 90);
	}

	public void execute(Database.BatchableContext bc, List<Container__c> records) {
		RandomUser_CalloutService randomUser_CalloutService = new RandomUser_CalloutService();

		try {
			RandomUser_Callout randomUserCallout = randomUser_CalloutService.obtainRandomlyGeneratedUsers(
				records.size()
			);

			RandomUser_Wrappers.Users usersWrapper = RandomUser_Wrappers.parseObtainRandomlyGeneratedUser(
				randomUserCallout
			);

			Integer i = 0;
			for (Container__c container_i : records) {
				RandomUser_Wrappers.Result randomUser = usersWrapper.results.get(i);
				i++;

				Contact contact = new Contact(
					External_ID_Container__c = container_i.External_Contact_ID__c,
					FirstName = randomUser.name.first,
					LastName = randomUser.name.last,
					Email = randomUser.email,
					Phone = randomUser.phone,
					MobilePhone = randomUser.cell,
					MailingCountry = randomUser.location.country,
					MailingState = randomUser.location.state,
					MailingPostalCode = randomUser.location.postcode,
					MailingCity = randomUser.location.city,
					MailingStreet = randomUser.location.street.name +
						' ' +
						randomUser.location.street.number_w,
					Salutation = randomUser.name.title,
					Description = randomUser.nat
				);

				this.contactToInsertList.add(contact);
			}
		} catch (Exception ex) {
			LogManager.getInstance().generateLogByException(ex);
		}

		randomUser_CalloutService.insertAllLogs();
	}

	public void finish(Database.BatchableContext bc) {
		if (!this.contactToInsertList.isEmpty()) {
			insert this.contactToInsertList;

			this.populateContainersWithNewContact();
		}
	}

	private void populateContainersWithNewContact() {
		Map<String, Contact> externalContactIdToContactMap = new Map<String, Contact>();
		for (Contact contact_i : this.contactToInsertList) {
			externalContactIdToContactMap.put(contact_i.External_ID_Container__c, contact_i);
		}

		Map<Id, Container__c> containerMap = new Map<Id, Container__c>(
			[
				SELECT Id
				FROM Container__c
				WHERE External_Contact_ID__c IN :externalContactIdToContactMap.keySet()
			]
		);

		Map<Id, Container__c> containerToUpdateMap = new Map<Id, Container__c>();
		for (Id containerId_i : containerMap.keySet()) {
			Container__c container_i = containerMap.get(containerId_i);
			container_i.Contact__c = externalContactIdToContactMap.get(
					container_i.External_Contact_ID__c
				)
				.Id;

			containerToUpdateMap.put(containerId_i, container_i);
		}

		if (!containerToUpdateMap.isEmpty()) {
			update containerToUpdateMap.values();
		}
	}
}