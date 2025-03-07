@RestResource(urlMapping = '/V1/PS/registeruser')
global class PSGetCreateLeadMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetCreateLeadMobileHelper.PSGetCreateLeadMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}