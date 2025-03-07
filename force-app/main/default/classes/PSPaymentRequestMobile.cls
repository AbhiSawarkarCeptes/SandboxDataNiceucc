@RestResource(urlMapping='/V1/PS/paymentRequest')
global class PSPaymentRequestMobile {
    
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSPaymentRequestMobileHelper.GetPaymentRequestMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}