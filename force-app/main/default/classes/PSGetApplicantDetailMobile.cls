@RestResource(urlMapping='/V1/PS/getApplicantDetails')
global class PSGetApplicantDetailMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetApplicantDetailMobileHelper.GetApplicantDetailMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}