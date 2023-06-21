public without sharing class HttpRequestUtil {
    
    public class HttpRequestUtilException extends Exception {}
    
    public static String sendRequest(String url, String authorizationHeader, String contentType, Map<String, String> additionalHeaders, String requestType, String body) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);    
        req.setMethod(requestType);
        req.setTimeout(120000);

        if (!String.isBlank(authorizationHeader)) {
            req.setHeader('Authorization', authorizationHeader);    
        }
        req.setHeader('Content-Type', contentType);

        setAdditionalHeaders(req, additionalHeaders);
        
        System.debug('HttpRequestUtil : Endpoint : ' + url);
        System.debug('HttpRequestUtil : authorizationHeader : ' + authorizationHeader);

        if(body != null) {
            system.debug('HttpRequestUtil : request body : ' + body);
            req.setBody(body);
        }

        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('HttpRequestUtil : response body : ' + res.getBody());
        
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201 && res.getStatusCode() != 204) {
            System.debug('HttpRequestUtil : API response error: ' + res.getStatusCode() + ' ' + res.getStatus());
            
            String errorMessage = res.getStatusCode() + ' ' + res.getStatus();
            if(!String.isBlank(res.getBody())) {
                //if response body is not a JSON just add body to errorMessage and throw exception
                Map<String, Object> response;
                try {
                    response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody().removeStart('[').removeEnd(']'));
                } catch (Exception e) {
                    errorMessage += '\n' + res.getBody();
                    throw new HttpRequestUtilException(errorMessage);
                }

                if(response.get('Message') != null) {
                    errorMessage += '\n' + String.valueOf(response.get('Message'));
                    
                } else if(response.get('message') != null) {
                    errorMessage += '\n' + String.valueOf(response.get('message'));
                }

                if(response.get('errors') != null) {
                    errorMessage += '\n' + String.valueOf(response.get('errors'));
                }
            }

            throw new HttpRequestUtilException(errorMessage);
        }

        return res.getBody();
    }

    private static void setAdditionalHeaders(HttpRequest req, Map<String, String> additionalHeaders) {

        if (additionalHeaders != null && !additionalHeaders.isEmpty()) {
            
            for (String headerName_i : additionalHeaders.keySet()) {
                
                if (String.isBlank(headerName_i) ||
                        String.isBlank(additionalHeaders.get(headerName_i))) {
                    continue;
                }
                
                req.setHeader(headerName_i, additionalHeaders.get(headerName_i));
            }
        }
    }
}