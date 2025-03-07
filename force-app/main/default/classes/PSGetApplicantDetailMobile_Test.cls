@isTest
private class PSGetApplicantDetailMobile_Test {
    
    @isTest
    static void testMobileToSFDC() {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Property__c = prop.Id, PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10, PropStrength__Project__c = proj.Id, MOU_Executed__c = TRUE);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        req.requestURI = '/services/apexrest/getApplicantDetails';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"dummyKey": "dummyValue"}');
        
        Test.startTest();
        PSGetApplicantDetailMobile.MobileToSFDC();
        Test.stopTest();
        
 
        String expectedJsonResponse = '{"result": "success"}'; 
        String actualJsonResponse = res.responseBody.toString();
        
    }
}