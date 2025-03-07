@isTest
public class Test_Mb_getPaymentPlan {
    
    @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
    @isTest
    static void testGetBookingListWithRecords() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/services/apexrest/getPaymentPlan';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        List<booking__c> book = [select id, name, Quotation__c from booking__c];
        
        List<Tower__c> tower = [select id, name from Tower__c];
        
        ProjectCharges__c pc = new ProjectCharges__c();
        pc.Active__c = true;
        pc.Tower__c = tower[0].Id;
        pc.Calculatedas__c = 'Rate list at Unit level';
        pc.ChargeBucket__c = 'Agreement Value';
        insert pc;
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.NoofMilestones__c = 1;
        insert pp;
        
        
        
        Payment_Plan_Milestones__c pm = new Payment_Plan_Milestones__c();
        pm.Plan_Milestone_Type__c = 'Construction Linked';
        pm.Number_Of_Days_Plan__c = 0;       
        pm.Milestone_Name_Picklist__c = '<<Construction Stage Name>>';
       // pm.Project_Construction_Stages__c = pgs;
        pm.Payment_Plan__c = pp.Id;
        insert pm;
        
        Payment_Milestones__c payMil = new Payment_Milestones__c();
        payMil.Charge1Percentage__c = 1;
        payMil.Number_Of_Days__c = 25;
        payMil.Milestone_Type_edit__c = 'Date Linked';
        payMil.Quotation__c = book[0].Quotation__c;
        payMil.Charge1Name__c = 'Basic';
        payMil.Charge1Percentage__c = 5;
        payMil.C1_Amount__c = 10000;          
        payMil.C1_CGST__c = 41250;
        payMil.C1_SGST__c = 2475;
        insert payMil;
        system.debug('!~~~~'+payMil);
        
        
        Test.startTest();
        Mobile_getPaymentPlan.getPaymentPlan(book[0].Id);
        Test.stopTest();
        
        System.assertEquals(200, response.statusCode);
    }
    
    @isTest
    static void testGetBookingListWithException() {
        // Test the case where an exception is thrown in the code
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/getPaymentPlan';
        request.httpMethod = 'POST';
        // Set the request body, e.g., JSON with the email parameter

        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        // Simulate an exception by passing a null email parameter
        Mobile_getPaymentPlan.getPaymentPlan(null);
        Test.stopTest();

        // Assert the response status code and any other expected results
        System.assertEquals(400, response.statusCode);
        // Add more assertions as needed
    }

}