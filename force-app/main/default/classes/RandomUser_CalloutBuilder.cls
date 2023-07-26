public without sharing class RandomUser_CalloutBuilder {
	private RandomUser_Setting__mdt randomUserSetting;

	public RandomUser_CalloutBuilder() {
		if (randomUserSetting == null) {
			List<RandomUser_Setting__mdt> randomUserSettingList = [
				SELECT Id, Label, DeveloperName, Base_URL__c, Requesting_Multiple_Users__c
				FROM RandomUser_Setting__mdt
				WHERE DeveloperName = 'Main'
			];
			randomUserSetting = randomUserSettingList.get(0);
		}
	}

	public RandomUser_Callout obtainRandomlyGeneratedUser() {
		String endpoint = randomUserSetting.Base_URL__c;

		RandomUser_Callout callout = new RandomUser_Callout();
		callout.setMethod('GET').setEndpoint(endpoint).setTimeout(120000).send();

		return callout;
	}

	public RandomUser_Callout obtainRandomlyGeneratedUsers(Integer pNumberOfUsers) {
		String endpoint =
			randomUserSetting.Base_URL__c +
			randomUserSetting.Requesting_Multiple_Users__c +
			pNumberOfUsers;

		RandomUser_Callout callout = new RandomUser_Callout();
		callout.setMethod('GET').setEndpoint(endpoint).setTimeout(120000).send();

		return callout;
	}

	private class RandomUser_CalloutBuilderException extends Exception {
	}
}