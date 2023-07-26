public class LogManager {
	private static LogManager instance = null;
	public static List<Log__c> logToInsertList = new List<Log__c>();
	public static List<Log__c> allInsertedLogList = new List<Log__c>();

	public enum RequestType {
		Outbound,
		Inbound
	}

	public static LogManager getInstance() {
		if (instance == null) {
			instance = new LogManager();
		}
		return instance;
	}

	private LogManager() {
	}

	public void generateLogByException(String pRequest, String pResponse) {
		Log__c newLog = new Log__c(Request__c = pRequest, Response__c = pResponse);

		logToInsertList.add(newLog);
	}

	public void generateLogByException(Exception pException) {
		if (pException == null)
			return;

		Log__c newLog = new Log__c(
			Message__c = pException.getMessage(),
			ExceptionLineNumber__c = pException.getLineNumber(),
			ExceptionTypeName__c = pException.getTypeName()
		);

		logToInsertList.add(newLog);
	}

	public void generateLogByHtmlRequestAndResponse(HttpRequest pRequest, HttpResponse pResponse) {
		Log__c newLog = new Log__c();

		if (pRequest != null) {
			newLog.Request__c = pRequest.getBody();
			newLog.MethodName__c = pRequest.getMethod();
			newLog.Endpoint__c = pRequest.getEndpoint();
		}

		if (pResponse != null) {
			newLog.Response__c = pResponse.getBody();
			newLog.StatusCode__c = pResponse.getStatusCode() != null
				? String.valueOf(pResponse.getStatusCode())
				: null;
		}

		logToInsertList.add(newLog);
	}

	public void addLog(
		HttpRequest pRequest,
		HttpResponse pResponse,
		RequestType pRequestType,
		String pClassMethod,
		String pComponent,
		String pAffectedId,
		String pMessage
	) {
		try {
			Log__c log = new Log__c();

			if (pRequest != null) {
				log.Endpoint__c = String.isBlank(pRequest.getEndpoint())
					? null
					: pRequest.getEndpoint().abbreviate(255);
				log.MethodName__c = pRequest.getMethod();
				try {
					log.Request__c = String.isBlank(pRequest.getBody())
						? null
						: JSON.serializePretty(
									(Map<String, Object>) JSON.deserializeUntyped(
										pRequest.getBody()
									)
								)
								.abbreviate(131072);
				} catch (Exception ex) {
					log.Request__c = String.isBlank(pRequest.getBody())
						? null
						: pRequest.getBody().abbreviate(131072);
				}
			}

			if (pResponse != null) {
				try {
					log.Response__c = String.isBlank(pResponse.getBody())
						? null
						: JSON.serializePretty(
									(Map<String, Object>) JSON.deserializeUntyped(
										pResponse.getBody()
									)
								)
								.abbreviate(131072);
				} catch (Exception ex) {
					log.Response__c = String.isBlank(pResponse.getBody())
						? null
						: pResponse.getBody().abbreviate(131072);
				}
				log.Response_Status__c = String.isBlank(pResponse.getStatus())
					? null
					: pResponse.getStatus().abbreviate(255);
				log.StatusCode__c = String.valueOf(pResponse.getStatusCode());
				log.Logging_Level__c = pResponse.getStatusCode() == null ||
					pResponse.getStatusCode() >= 400
					? String.valueOf(LoggingLevel.ERROR)
					: String.valueOf(LoggingLevel.DEBUG);
			}

			log.Request_Type__c = pRequestType != null ? String.valueOf(pRequestType) : null;
			log.Class_Method__c = pClassMethod;
			log.Affected_Id__c = pAffectedId;
			log.Message__c = pMessage;

			this.populateRecordTypeId(log, pComponent);

			logToInsertList.add(log);
		} catch (Exception pException) {
			System.debug(
				'LogManager: ' + pException.getLineNumber() + ' , ' + pException.getMessage()
			);
		}
	}

	public void addLog(
		RestRequest pRequest,
		RestResponse pResponse,
		RequestType pRequestType,
		String pClassMethod,
		String pComponent,
		String pAffectedId,
		String pMessage
	) {
		try {
			Log__c log = new Log__c();

			if (pRequest != null) {
				log.Headers__c = pRequest.headers != null && !pRequest.headers.isEmpty()
					? String.valueOf(pRequest.headers).abbreviate(2000)
					: null;
				log.Endpoint__c = pRequest.resourcePath != null
					? pRequest.resourcePath.abbreviate(254)
					: '';
				log.MethodName__c = pRequest.httpMethod;
				log.Request__c = (pRequest.requestBody != null &&
					String.isNotBlank(pRequest.requestBody.toString()))
					? pRequest.requestBody.toString().abbreviate(131072)
					: null;
			}

			if (pResponse != null) {
				log.Response__c = pResponse.responseBody != null &&
					String.isNotBlank(pResponse.responseBody.toString())
					? pResponse.responseBody.toString().abbreviate(131072)
					: null;

				log.StatusCode__c = pResponse.statusCode != null
					? String.valueOf(pResponse.statusCode)
					: null;
				log.Logging_Level__c = pResponse.statusCode != null &&
					pResponse.statusCode >= 400
					? String.valueOf(LoggingLevel.ERROR)
					: String.valueOf(LoggingLevel.DEBUG);
			}

			log.Request_Type__c = String.valueOf(pRequestType);
			log.Class_Method__c = pClassMethod;
			log.Affected_Id__c = pAffectedId;
			log.Message__c = pMessage;

			this.populateRecordTypeId(log, pComponent);

			logToInsertList.add(log);
		} catch (Exception pException) {
			System.debug(
				'LogManager: ' + pException.getLineNumber() + ' , ' + pException.getMessage()
			);
		}
	}

	public void addLog(
		String pMessage,
		String pClassMethod,
		String pComponent,
		String pAffectedId,
		System.LoggingLevel pLogLevel
	) {
		try {
			Log__c log = new Log__c(
				Message__c = String.isNotBlank(pMessage) && pMessage.length() > 131072
					? pMessage.substring(0, 131072)
					: pMessage,
				Class_Method__c = pClassMethod,
				Affected_Id__c = pAffectedId,
				Logging_Level__c = pLogLevel != null ? String.valueOf(pLogLevel) : null
			);

			this.populateRecordTypeId(log, pComponent);

			logToInsertList.add(log);
		} catch (Exception pException) {
			System.debug(
				'Error on addLog - LogManager: ' +
					pException.getLineNumber() +
					' , ' +
					pException.getMessage()
			);
		}
	}

	public void addLog(
		Exception pException,
		String pClassMethod,
		String pComponent,
		String pAffectedId,
		System.LoggingLevel pLogLevel
	) {
		try {
			String message = pException != null && String.isNotBlank(pException.getMessage())
				? this.getExceptionText(pException)
				: '';

			Log__c log = new Log__c(
				Message__c = message.length() > 131072 ? message.substring(0, 131072) : message,
				Class_Method__c = pClassMethod,
				Affected_Id__c = pAffectedId,
				Logging_Level__c = pLogLevel != null ? String.valueOf(pLogLevel) : null
			);

			if (pException != null) {
				log.ExceptionLineNumber__c = pException.getLineNumber();
				log.ExceptionTypeName__c = pException.getTypeName();
			}

			this.populateRecordTypeId(log, pComponent);

			logToInsertList.add(log);
		} catch (Exception ex) {
			System.debug(
				'Error on addLog - LogManager: ' + ex.getLineNumber() + ' , ' + ex.getMessage()
			);
		}
	}

	public static void insertAllLogs() {
		try {
			if (!logToInsertList.isEmpty()) {
				insert logToInsertList;
				allInsertedLogList.addAll(logToInsertList);
				logToInsertList.clear();
			}
		} catch (Exception pException) {
			System.debug(
				'Error on insert - LogManager: ' +
					pException.getMessage() +
					'\n' +
					pException.getStackTraceString()
			);
		}
	}

	private String getExceptionText(Exception pException) {
		if (pException == null)
			return '';

		return 'Exception - Type: ' +
			pException.getTypeName() +
			'; Line: ' +
			pException.getLineNumber() +
			'; Message: ' +
			pException.getMessage() +
			'; Stacktrace: ' +
			pException.getStackTraceString();
	}

	private void populateRecordTypeId(Log__c pLog, String pDeveloperName) {
		if (pLog == null || String.isBlank(pDeveloperName))
			return;

		try {
			String recordTypeId = Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName()
					.containsKey(pDeveloperName)
				? Schema.SObjectType.Log__c.getRecordTypeInfosByDeveloperName()
						.get(pDeveloperName)
						.getRecordTypeId()
				: null;

			if (recordTypeId != null)
				pLog.RecordTypeId = recordTypeId;
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
	}
}