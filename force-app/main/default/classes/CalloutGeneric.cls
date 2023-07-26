public without sharing virtual class CalloutGeneric {
	public Object responseObj;
	protected Boolean isSuccess = true;
	public HttpRequest request;
	public HttpResponse response;
	protected IntegrationError error;

	protected Map<String, String> headersMap;
	protected Map<String, String> paramsMap;
	protected Id recordTypeId;
	protected String rtDevName;

	public static Boolean causeInternalError;

	@TestVisible
	protected CalloutGeneric(String pRtDevName) {
		this.rtDevName = pRtDevName;
		this.headersMap = new Map<String, String>();
		this.paramsMap = new Map<String, String>();
		this.request = new HttpRequest();
	}

	public CalloutGeneric setParam(String key, String value) {
		this.paramsMap.put(key, value);
		return this;
	}

	public CalloutGeneric setParams(Map<String, String> params) {
		for (String key : params.keySet()) {
			this.paramsMap.put(key, params.get(key));
		}
		return this;
	}

	public CalloutGeneric setMethod(String method) {
		this.request.setMethod(method);
		return this;
	}

	public CalloutGeneric setHeader(String key, String value) {
		this.headersMap.put(key, value);
		return this;
	}

	public CalloutGeneric setEndpoint(String endpoint) {
		this.request.setEndpoint(endpoint);
		return this;
	}

	public CalloutGeneric setTimeout(Integer timeout) {
		this.request.setTimeout(timeout);
		return this;
	}

	public CalloutGeneric setRequestBody(String body) {
		if (String.isNotBlank(body)) {
			this.request.setBody(body);
		}
		return this;
	}

	public CalloutGeneric setRequestBodyAsBlob(Blob body) {
		this.request.setBodyAsBlob(body);
		return this;
	}

	public String getEndpoint() {
		return this.request.getEndpoint();
	}

	public String getRequestBody() {
		return this.request.getBody();
	}

	public String getResponseBody() {
		return this.response.getBody();
	}

	public String getStatus() {
		return this.response.getStatus();
	}

	public Integer getStatusCode() {
		return this.response.getStatusCode();
	}

	public Boolean isSuccess() {
		return this.isSuccess;
	}

	public void setFail() {
		this.isSuccess = false;
	}

	public virtual IntegrationError getError() {
		return this.error;
	}

	protected void assignHeaders() {
		for (String key : headersMap.keySet()) {
			request.setHeader(key, headersMap.get(key));
		}
	}

	protected void assignParams() {
		String finalEndpoint = request.getEndpoint();
		finalEndpoint = paramsMap.keySet().size() > 0 ? finalEndpoint + '?' : finalEndpoint;
		List<String> paramsKeyList = new List<String>(paramsMap.keySet());
		for (Integer i = 0; i < paramsKeyList.size(); i++) {
			String key = paramsKeyList.get(i);
			if (i == 0) {
				finalEndpoint += key + '=' + paramsMap.get(key);
			} else {
				finalEndpoint += '&' + key + '=' + paramsMap.get(key);
			}
		}
		request.setEndpoint(finalEndpoint.replace(' ', '%20'));
	}

	public virtual CalloutGeneric send() {
		System.debug('Start send');

		try {
			if (String.isBlank(this.request.getEndpoint())) {
				throw new CalloutGenericException('Endpoint is blank');
			}

			assignHeaders();
			assignParams();

			if (Test.isRunningTest() && causeInternalError == true) {
				if (Schema.sObjectType.Account.fields.Name.isCreateable()) {
					insert new Account(Name = 'Cause of error');
				}
			}

			this.response = new Http().send(this.request);
			if (this.response.getStatusCode() >= 400) {
				setFail();
				/* parseError(); */
			}
		} catch (Exception ex) {
			this.error = new IntegrationError(ex);
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

	/* protected virtual void parseError() {
        //TODO
    } */

	public void addLog() {
		LogRegistrar.debug(
			this,
			LogManager.RequestType.Outbound,
			'CalloutGeneric.addLog',
			this.rtDevName,
			null
		);
	}

	public class CalloutGenericException extends Exception {
	}
}