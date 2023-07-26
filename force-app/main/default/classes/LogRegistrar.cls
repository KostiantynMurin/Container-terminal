public without sharing class LogRegistrar {
	public static void debug(
		CalloutGeneric pCallout,
		LogManager.RequestType pRequestType,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		String message;
		try {
			message = pCallout.getError() != null ? pCallout.getError().getMessage() : null;
		} catch (Exception ex) {
			message = ex.getMessage();
		}

		LogManager.getInstance()
			.addLog(
				pCallout.request,
				pCallout.response,
				pRequestType,
				pClassMethod,
				pComponent,
				pAffectedId,
				message
			);
	}

	public static void debug(
		HttpRequest pHttpRequest,
		HttpResponse pHttpResponse,
		LogManager.RequestType pRequestType,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		LogManager.getInstance()
			.addLog(
				pHttpRequest,
				pHttpResponse,
				pRequestType,
				pClassMethod,
				pComponent,
				pAffectedId,
				null
			);
	}

	public static void debug(
		RestRequest pRestRequest,
		RestResponse pRestResponse,
		LogManager.RequestType pRequestType,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		LogManager.getInstance()
			.addLog(
				pRestRequest,
				pRestResponse,
				pRequestType,
				pClassMethod,
				pComponent,
				pAffectedId,
				null
			);
	}

	public static void debug(
		String pMessage,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		LogManager.getInstance()
			.addLog(pMessage, pClassMethod, pComponent, pAffectedId, LoggingLevel.DEBUG);
	}

	public static void error(
		Exception pException,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		LogManager.getInstance()
			.addLog(pException, pClassMethod, pComponent, pAffectedId, LoggingLevel.ERROR);
	}

	public static void error(
		String pMessage,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		LogManager.getInstance()
			.addLog(pMessage, pClassMethod, pComponent, pAffectedId, LoggingLevel.ERROR);
	}

	public static void error(
		Database.UpsertResult pUpsertResult,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		String pMessage = '';
		for (Database.Error error : pUpsertResult.getErrors()) {
			pMessage +=
				'Code: ' +
				error.getStatusCode() +
				'\nMessage: ' +
				error.getMessage() +
				'\nFields: ' +
				String.join(error.getFields(), ',');
		}
		LogManager.getInstance()
			.addLog(pMessage, pClassMethod, pComponent, pAffectedId, LoggingLevel.ERROR);
	}

	public static void error(
		Database.SaveResult pSaveResult,
		String pClassMethod,
		String pComponent,
		String pAffectedId
	) {
		String pMessage = '';
		for (Database.Error error : pSaveResult.getErrors()) {
			pMessage +=
				'Code: ' +
				error.getStatusCode() +
				'\nMessage: ' +
				error.getMessage() +
				'\nFields: ' +
				String.join(error.getFields(), ',');
		}
		LogManager.getInstance()
			.addLog(pMessage, pClassMethod, pComponent, pAffectedId, LoggingLevel.ERROR);
	}

	public static List<Log__c> getAllInsertedLogs() {
		return LogManager.allInsertedLogList;
	}

	public static void insertAllLogs() {
		LogManager.insertAllLogs();
	}
}