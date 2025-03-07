@RestResource(urlMapping='/V1/PS/getPaymentPlan')
global class PSGetPaymentPlanMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetPaymentPlanMobileHelper.GetPaymentPlanMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}