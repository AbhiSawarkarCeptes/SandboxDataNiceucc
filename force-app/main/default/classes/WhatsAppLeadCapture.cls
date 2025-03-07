@RestResource(urlMapping='/WhatsAppLeadCapture/')
global class WhatsAppLeadCapture {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = WhatsAppLeadCaptureHelper.insertContactAndEnquiry(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}