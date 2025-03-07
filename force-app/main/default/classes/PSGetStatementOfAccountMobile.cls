@RestResource(urlMapping='/V1/PS/getStatementOfAccount')
global class PSGetStatementOfAccountMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetStatementOfAccountMobileHelper.GetStatementOfAccountMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}