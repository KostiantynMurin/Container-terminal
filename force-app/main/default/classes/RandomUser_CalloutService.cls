public without sharing class RandomUser_CalloutService extends CalloutService {
	RandomUser_CalloutBuilder calloutBuilder;

	public RandomUser_CalloutService() {
		super();
		this.calloutBuilder = new RandomUser_CalloutBuilder();
	}

	public RandomUser_Callout obtainRandomlyGeneratedUser() {
		RandomUser_Callout callout = this.calloutBuilder.obtainRandomlyGeneratedUser();
		return callout;
	}

	public RandomUser_Callout obtainRandomlyGeneratedUsers(Integer pNumberOfUsers) {
		RandomUser_Callout callout = this.calloutBuilder.obtainRandomlyGeneratedUsers(
			pNumberOfUsers
		);
		return callout;
	}

	public class RandomUser_CalloutServiceException extends Exception {
	}
}