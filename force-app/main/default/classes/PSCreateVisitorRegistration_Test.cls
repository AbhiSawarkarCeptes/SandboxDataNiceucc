@isTest
public class PSCreateVisitorRegistration_Test {
    @isTest
    static void WebToSFDCTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.FirstName = 'Test';
        cont.LastName = 'Con';
        insert cont;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        proj.Name = 'Test Project';
        insert proj;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        String json = '['+
        '   {'+
        '      \"FileContent\":\"FileContent\",'+
        '      \"First_Name\":\"First_Name\",'+
        '      \"Mobile\":\"1234567801\",'+
        '      \"Email\":\"Test@test.com\",'+
        '      \"Address\":\"Address\",'+
        '      \"City\":\"City\",'+
        '      \"Last_Name\":\"Last_Name\",'+
        '      \"Country\":\"India\",'+
        '      \"UAE_Resident\":\"True\",'+
        '      \"Interested_In\":\"True\",'+
        '      \"Purpose_Of_Purchase\":\"\",'+
        '      \"Remarks\":\"Remarks\",'+
        '      \"Source\":\"Walk-in\",'+
        '      \"Agent_Name\":\"Test Con\",'+
        '      \"Agent_Id\":\"Agent_Id\",'+
        '      \"Company\":\"Company\",'+
        '      \"Sales_Advisor\":\"Sales_Advisor\",'+
        '      \"Date_Value\":\"21-08-21\",'+
        '      \"Time_Value\":\"Time_Value\",'+
        '      \"Nationality\":\"Indian\",'+
        '      \"Alternate_Email\":\"Alternate_Email@email.com\",'+
        '      \"Alternate_Mobile\":\"1234567845\",'+
        '      \"Birth_Date\":\"\",'+
        '      \"Designation\":\"Acountant\",'+
        '      \"Existing_Sobha_Owner\":\"\",'+
        '      \"Occupation\":\"\",'+
        '      \"Project_Name\":\"Test Project\",'+
        '      \"Visiting_On_Behalf_Of\":\"Family\",'+
        '      \"Residential_Status\":\"Resident\",'+
        '      \"subProject_Name\":\"\",'+
        '      \"uniqueId\":\"12324\",'+
        '      \"Sobha_Connect_name\":\"Test Account Record\",'+
        '      \"Sobha_Connect_Id\":\"\",'+
        '      \"Raw_Request_Body\":\"Raw_Request_Body\",'+
        '      \"Sobha_Connect_companyName\":\"\"'+
        '   }'+
        ']';
        req.requestURI = '/services/apexrest/PSCreateVisitorRegistration/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(json);
        Test.startTest();
        PSCreateVisitorRegistration.WebToSFDC();
        Test.stopTest();
        List<PSCreateVisitorRegistrationPOJO> leadCapture = PSCreateVisitorRegistrationPOJO.parse(json);

    }
}