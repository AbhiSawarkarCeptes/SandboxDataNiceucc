@RestResource(urlMapping='/V1/PS/getBookingJourney')
global class PSGetBookingJourneyMobile {
    @HttpPost
    global static void MobileToSFDC() {
        RestRequest request = RestContext.request;
        String jsonString = PSGetBookingJourneyMobileHelper.GetBookingJourneyMobile(request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
}