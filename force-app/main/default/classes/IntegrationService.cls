public with sharing class IntegrationService {

    private static final String RANDOM_USER_API_URL = 'callout:randomuser_me';

    public static Contact getContactByExtId(String externalId) {
        String responseBody;
        try {
            responseBody = makeCalloutToRandomUserAPI();
        } catch (Exception e) {
            System.debug('Failed to make callout to RandomUser API: ' + e.getMessage());
            return null;
        }

        Map<String, Object> response;
        try {
            response = parseResponse(responseBody);
        } catch (Exception e) {
            System.debug('Failed to parse response from RandomUser API: ' + e.getMessage());
            return null;
        }

        Contact contact = new Contact();
        contact.ExternalId__c = externalId;
        contact.FirstName = (String) response.get('first');
        contact.LastName = (String) response.get('last');
        contact.Email = (String) response.get('email');

        return contact;
    }

    private static String makeCalloutToRandomUserAPI() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(RANDOM_USER_API_URL);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            throw new CalloutException('Unexpected status code from RandomUser API: ' + response.getStatusCode());
        }

        return response.getBody();
    }

    private static Map<String, Object> parseResponse(String response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> resultsList = (List<Object>) responseMap.get('results');
        Map<String, Object> userMap = (Map<String, Object>) resultsList.get(0);
        Map<String, Object> nameMap = (Map<String, Object>) userMap.get('name');

        Map<String, Object> parsedResponse = new Map<String, Object>();
        parsedResponse.put('first', nameMap.get('first'));
        parsedResponse.put('last', nameMap.get('last'));
        parsedResponse.put('email', userMap.get('email'));

        return parsedResponse;
    }
}