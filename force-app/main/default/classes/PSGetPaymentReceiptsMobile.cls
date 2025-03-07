@RestResource(urlMapping='/V1/PS/getPaymentReceipts')
global class PSGetPaymentReceiptsMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetPaymentReceiptsMobileHelper.GetPaymentReceiptsMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}