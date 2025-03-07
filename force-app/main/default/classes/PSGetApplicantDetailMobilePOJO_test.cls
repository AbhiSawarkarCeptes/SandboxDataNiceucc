@isTest
private class PSGetApplicantDetailMobilePOJO_test {
    @isTest
    static void testValidJSONParsing() {        
        String validJson = '{"bookingId": "ABC123"}'; 
        PSGetApplicantDetailMobilePOJO parsedObj = PSGetApplicantDetailMobilePOJO.parse(validJson);
        System.assertEquals('ABC123', parsedObj.bookingId);
    }

    @isTest
    static void testUnrecognizedProperty() {
        String jsonWithUnrecognizedProperty = '{"bookingId": "XYZ456", "unknownProperty": "foo"}';
        PSGetApplicantDetailMobilePOJO parsedObj = PSGetApplicantDetailMobilePOJO.parse(jsonWithUnrecognizedProperty);
        System.assertEquals('XYZ456', parsedObj.bookingId);
    }
}