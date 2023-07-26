public without sharing class RandomUser_Error extends IntegrationError {
	public RandomUser_Error() {
		super();
	}

	public RandomUser_Error(Exception ex) {
		super(ex);
	}

	public RandomUser_Error(String error) {
		super(error);
	}

	public static RandomUser_Error parseResponseBody(Exception ex) {
		return new RandomUser_Error(ex);
	}

	public static RandomUser_Error parseResponseBody(String error) {
		return new RandomUser_Error(error);
	}

	public static RandomUser_Error parseResponseBody(RandomUser_Callout callout) {
		try {
			String result = callout.getResponseBody();
			return new RandomUser_Error(result);
		} catch (Exception ex) {
			return new RandomUser_Error(ex);
		}
	}

	public class RandomUser_ErrorException extends Exception {
	}
}