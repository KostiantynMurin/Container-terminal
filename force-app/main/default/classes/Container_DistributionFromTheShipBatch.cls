public class Container_DistributionFromTheShipBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	public Database.QueryLocator start(Database.BatchableContext bc) {
		this.populateDateOfIssueOfContainers();

		return Database.getQueryLocator(
			'SELECT Id, Storage__c, Height_Location__c, Length_Location__c, Width_Location__c ' +
				'FROM Storage_Location__c ' +
				'WHERE Container__c = null'
		);
	}

	public void execute(Database.BatchableContext bc, List<Storage_Location__c> records) {
	}

	public void finish(Database.BatchableContext bc) {
	}

	private void populateDateOfIssueOfContainers() {
		List<Container__c> containerList = [
			SELECT Id
			FROM Container__c
			WHERE Date_Of_Issue__c = NULL
		];

		if (!containerList.isEmpty()) {
			Integer totalContainers = containerList.size();
			Integer weekdays = 5;
			Integer containersPerDay = totalContainers / weekdays;
			Integer remainingContainers = math.mod(totalContainers, weekdays);
			Integer currentIndex = 0;

			for (Integer day = 1; day <= weekdays; day++) {
				Integer containersForDay = containersPerDay;
				if (remainingContainers > 0 && day == weekdays) {
					containersForDay += remainingContainers;
				}

				for (Integer i = 0; i < containersPerDay; i++) {
					DateTime todayDateTime = DateTime.now();
					Integer dayOfWeek = Integer.valueOf(todayDateTime.format('u'));
					Integer numberOfAddedDays = day + 1 - dayOfWeek;
					if (numberOfAddedDays <= 0) {
						numberOfAddedDays += 7;
					}

					Container__c container = containerList.get(currentIndex);
					container.Date_Of_Issue__c = todayDateTime.addDays(numberOfAddedDays).date();

					currentIndex++;
				}
			}

			update containerList;
		}
	}

	public void execute(SchedulableContext sc) {
		Container_DistributionFromTheShipBatch batch = new Container_DistributionFromTheShipBatch();
		database.executeBatch(batch);
	}
}