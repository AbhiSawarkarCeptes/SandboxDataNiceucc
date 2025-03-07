@RestResource(urlMapping='/PSCreateVisitorRegistration/')
global with sharing class PSCreateVisitorRegistration {
    @HttpPost
    global static void WebToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSCreateVisitorRegistrationHelper.createVisitorRegistration(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}