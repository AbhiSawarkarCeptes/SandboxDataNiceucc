@RestResource(urlMapping='/V1/PS/uploadDocument')
global class PSUploadDocumentMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSUploadDocumentMobileHelper.UploadDocumentMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}