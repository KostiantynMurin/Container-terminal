@IsTest
private class CalloutGenericTest {
	@IsTest
	static void testBehavior() {
		CalloutGeneric calloutGeneric = new CalloutGeneric('Paubox');
		calloutGeneric.setParam('Test', 'Test');
		calloutGeneric.setMethod('GET');
		calloutGeneric.setHeader('Test', 'Test');
		calloutGeneric.setEndpoint('Test');
		calloutGeneric.setTimeout(100);
		calloutGeneric.setRequestBody('Test');
		calloutGeneric.isSuccess();
		calloutGeneric.setFail();
		calloutGeneric.getError();
		calloutGeneric.send();

		System.assertEquals('Test', calloutGeneric.getRequestBody());
	}
}