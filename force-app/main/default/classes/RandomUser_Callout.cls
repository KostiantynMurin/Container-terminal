public without sharing class RandomUser_Callout extends CalloutGeneric {
	public RandomUser_Callout() {
		super('RandomUser');
	}

	private void parseError() {
		this.error = (RandomUser_Error) RandomUser_Error.parseResponseBody(this);
	}

	public override IntegrationError getError() {
		return (RandomUser_Error) this.error;
	}

	public override virtual CalloutGeneric send() {
		System.debug('Start send');
		try {
			assignHeaders();
			assignParams();

			if (Test.isRunningTest() && causeInternalError == true) {
				if (Schema.sObjectType.Account.fields.Name.isCreateable()) {
					insert new Account(Name = 'Cause of error');
				}
			}

			this.response = new Http().send(this.request);
			if (this.response.getStatusCode() != 200) {
				setFail();
				parseError();
			}
		} catch (Exception ex) {
			this.error = new RandomUser_Error(ex);
			setFail();
		}

		System.debug('request  ===  ' + this.request);
		if (this.request != null) {
			System.debug('request body  ===  ' + this.request.getBody());
		}

		System.debug('response  ===  ' + this.response);
		if (this.response != null) {
			System.debug('response body  ===  ' + this.response.getBody());
		}

		System.debug('error  ==  ' + this.error);

		this.addLog();

		System.debug('End send');

		return this;
	}
}