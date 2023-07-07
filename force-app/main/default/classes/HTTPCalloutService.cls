/**
 * @description  HTTPCalloutService.
 * @author Kostiantyn Murin
 * @date 24-06-2023
 */
public class HTTPCalloutService {

    private HTTPCalloutConfiguration__c calloutSetting;
    private String endpointURL;
    private String requestMethod;
    private String requestBody;
    private String requestCertificate;
    private Blob requestBodyAsBlob;
    private Dom.Document requestBodyAsDocument;
    private Integer requestTimeout;
    private Boolean isCompressedRequest;
    private Map<String, String> urlParametersMap;
    private Map<String, String> headerParametersMap;
    private static final String TYPE_URL_PARAMETERS = 'URL_PARAMETERS';
    private static final String TYPE_HEADER_PARAMETERS = 'HEADER_PARAMETERS';
    private HTTPRequest request;
    
    /**
     * @description   Constructor
     * @author Kostiantyn Murin
     * @date 26-06-2023
     */
    public HTTPCalloutService() {
        initialize();
    }

    /**
     * @description   Constructor with custom setting
     * @author Kostiantyn Murin
     * @date 26-06-2023
     * @param calloutSettingName String 
     */
    public HTTPCalloutService(String calloutSettingName) {
        try {
            calloutSetting = HTTPCalloutConfiguration__c.getInstance(calloutSettingName);
        } catch (Exception e) {
            throw new HTTPCalloutException(Label.CustomSettingNotFound);
        }
        initialize();
    }

    /**
     * @description   This method is used to form HTTP Request
     * @author Kostiantyn Murin
     * @date 26-06-2023
     */
    public void formHTTPRequest() {
        request = new HTTPRequest();
        addHeaderParameters();
        if(String.isNotEmpty(endpointURL)) {
            endpointURL = endpointURL.substringBefore('?');
            appendURLParameters();
            request.setEndpoint(endpointURL);
        }
        if(String.isNotEmpty(requestMethod)) {
            request.setMethod(requestMethod);
        }
        if(String.isNotEmpty(requestBody)) {
            request.setBody(requestBody);
        } else if((requestBodyAsBlob != null) &&  String.isNotEmpty(requestBodyAsBlob.toString())) {
            request.setBodyAsBlob(requestBodyAsBlob);
        } else if((requestBodyAsDocument != null) && String.isNotEmpty(requestBodyAsDocument.toXmlString())) {
            request.setBodyDocument(requestBodyAsDocument);
        }
        if(requestTimeout!=null) {
            request.setTimeout(requestTimeout);
        }
        if(String.isNotEmpty(requestCertificate)) {
            request.setClientCertificateName(requestCertificate);
        }
        if(isCompressedRequest!=null) {
            request.setCompressed(isCompressedRequest);
        }
    }

    /**
     * @description   This method forms and returns the HTTP Request without sending (for debugging purposes)
     * @author Kostiantyn Murin
     * @date 26-06-2023
     * @return HTTPRequest
     */
    public HTTPRequest getRequest() {
        formHTTPRequest();
        return request;
    }

    /**
     * @description   This method is used to send HTTP Request and return the response
     * @author Kostiantyn Murin
     * @date 26-06-2023
     * @return HTTPResponse
     */
    public HTTPResponse sendRequest() {
        formHTTPRequest();
        Http http = new Http();
        return http.send(request);
    }

    /**
     * @description   This method is used to send HTTP Request received in parameter and return the response
     * @author Kostiantyn Murin
     * @date 26-06-2023
     * @param request HTTPRequest 
     * @return HTTPResponse
     */
    public HTTPResponse sendRequest(HTTPRequest request) {
        Http http = new Http();
        return http.send(request);
    }

    /*
    * Initialization of class variables
    */
    private void initialize() {
        this.urlParametersMap = new Map<String, String>();
        this.headerParametersMap = new Map<String, String>();
        if(calloutSetting != null) {
            this.endpointURL = calloutSetting.Endpoint__c;
            this.requestMethod = calloutSetting.Method__c;
            this.requestBody = calloutSetting.Body__c;
            this.requestTimeout = Integer.valueOf(calloutSetting.Timeout__c);
            this.isCompressedRequest = calloutSetting.IsCompressed__c;
            this.requestCertificate = calloutSetting.CertificateName__c;
            setUrlOrHeaderParameters(TYPE_URL_PARAMETERS, calloutSetting.URLParameters__c);
            setUrlOrHeaderParameters(TYPE_HEADER_PARAMETERS, calloutSetting.HeaderParameters__c);
        }
    }

    /*
    * This method is used to set URL or Header parameters from Custom Metadata
    */
    private void setUrlOrHeaderParameters(String parameterType, String parameterInfo) {
        if(String.isNotEmpty(parameterInfo)) {
            Map<String, String> parametersMap = new Map<String, String>();
            List<String> parameters = parameterInfo.split('\n');
            for(String urlParam : parameters) {
                List<String> keyValuePair = urlParam.trim().split(':');
                if(!keyValuePair.isEmpty()) {
                    if(keyValuePair.size() == 2) {
                        if(String.isNotEmpty(keyValuePair[0]) && String.isNotEmpty(keyValuePair[1])) {
                            parametersMap.put(keyValuePair[0], keyValuePair[1]);
                        }
                    } else if(
                        (keyValuePair.size() == 1) &&
                        (parameterType != TYPE_HEADER_PARAMETERS)
                    ) {
                        if(String.isNotEmpty(keyValuePair[0])) {
                            parametersMap.put(keyValuePair[0], '');
                        }
                    }
                }
            }
            if(parameterType == TYPE_URL_PARAMETERS) {
                urlParametersMap.putAll(parametersMap);
            } else if(parameterType == TYPE_HEADER_PARAMETERS) {
                headerParametersMap.putAll(parametersMap);
            }
        }
    }

    /*
    * This method is used to append the URL parameters at the end of URL
    */
    private void appendURLParameters() {
        Set<String> urlParamKeys = urlParametersMap.keySet();
        if(!urlParamKeys.isEmpty()) {
            endpointURL += '?';
            for(String urlParamKey : urlParamKeys) {
                endpointURL += urlParamKey + '=' + urlParametersMap.get(urlParamKey) + '&';
            }
            endpointURL = endpointURL.substringBeforeLast('&');
        }
    }

    /*
    * This method is used to set Header parameters using headerParametersMap
    */
    private void addHeaderParameters() {
        for(String key : headerParametersMap.keySet()) {
            request.setHeader(key, headerParametersMap.get(key));
        }
    }

    public class HTTPCalloutException extends Exception {}
}