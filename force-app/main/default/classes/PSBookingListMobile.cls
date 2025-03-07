@RestResource(urlMapping='/V1/PS/getBookingList')
global class PSBookingListMobile {
    
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString =  '';
        jsonString = PSBookingListMobileHelper.GetBookingMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}