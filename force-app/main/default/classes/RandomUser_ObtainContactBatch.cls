public class RandomUser_ObtainContactBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
	private Set<String> externalContactIDSet;

	private List<Contact> contactToInsertList = new List<Contact>();

	public RandomUser_ObtainContactBatch(Set<String> pExternalContactIDSet) {
		this.externalContactIDSet = pExternalContactIDSet;
	}

	public System.Iterable<String> start(Database.BatchableContext bc) {
		return new List<String>(externalContactIDSet);
	}

	public void execute(Database.BatchableContext bc, List<String> records) {
		RandomUser_CalloutService randomUser_CalloutService = new RandomUser_CalloutService();

		try {
			RandomUser_Callout randomUserCallout = randomUser_CalloutService.obtainRandomlyGeneratedUsers(
				records.size()
			);

			RandomUser_Wrappers.Users usersWrapper = RandomUser_Wrappers.parseObtainRandomlyGeneratedUser(
				randomUserCallout
			);

			Integer i = 0;
			for (String externalContactID_i : records) {
				RandomUser_Wrappers.Result randomUser = usersWrapper.results.get(i);
				i++;

				Contact contact = new Contact(
					External_ID_Container__c = externalContactID_i,
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

				contactToInsertList.add(contact);
			}
		} catch (Exception ex) {
			LogManager.getInstance().generateLogByException(ex);
		}

		randomUser_CalloutService.insertAllLogs();
	}

	public void finish(Database.BatchableContext bc) {
		if (!contactToInsertList.isEmpty()) {
			insert contactToInsertList;

			this.populateContainersWithNewContact();
		}
	}

	private void populateContainersWithNewContact() {
		if (!contactToInsertList.isEmpty()) {
			Map<String, Contact> externalContactIdToContactMap = new Map<String, Contact>();
			for (Contact contact_i : contactToInsertList) {
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
}