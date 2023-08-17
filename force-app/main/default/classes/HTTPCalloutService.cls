public with sharing class HTTPCalloutService {

    public static HttpResponse makeHttpCallout(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);
        
        if (response.getStatusCode() == 200) {
            return response;
        } else {
            throw new HttpCalloutException('Callout Error: ' + response.getStatusCode() + ' - ' + response.getStatus() +
                                          '. Error Message: ' + response.getBody());
        }
    }

    public class HttpCalloutException extends Exception {}
}