@isTest
public class LatePaymentFeeBatch_Test {
    
    @isTest
    public static void testMethod1() {
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Tomar';
        PSProject.Do_Not_Raise_Demand__c = true;
        PSProject.Do_Not_Send_Reminder__c = true;
        PSProject.PropStrength__Active__c = true;
        PSProject.Customer_Care_Email_ID__c = 'divyansh@cloudsteer.com';
        PSProject.PropStrength__Avoid_ITC_calculation_on_Booking_Amount__c = true;
        PSProject.PropStrength__Completion_Certification_Received__c = true;
        PSProject.PropStrength__Enable_Pie_Chart_Count_Wise__c = true;
        PSProject.PropStrength__Is_First_Transfer_Free__c = true;
        PSProject.PropStrength__Over_Booking_Allowed__c = true;
        PSProject.PropStrength__Rebate_Applicable__c = true;
        PSProject.PropStrength__Under_PMAY_Scheme__c = true;
        PSProject.PropStrength__VAT_Applicable__c = true;
        PSProject.RERA_Registered__c = true;
        PSProject.T_link_Demand_Days__c = 5.0;
        insert PSProject;
        
        PropStrength__Application_Booking__c AppBooking = new PropStrength__Application_Booking__c ();
        AppBooking.PropStrength__Project__c = PSProject.id;
        AppBooking.PropStrength__Booking_Date__c = system.today();
        insert AppBooking;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = AppBooking.Id);
        insert appDetail;

        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = AppBooking.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, Recurring_Interest_Till_date__c = 1000);
        insert ppd;

        Database.executeBatch(new LatePaymentFeeBatch());

        List<PropStrength__Received_Payment__c> createdPayments = [SELECT Id FROM PropStrength__Received_Payment__c WHERE PropStrength__Application_Booking__c = :AppBooking.Id];
        //System.assertEquals(1, createdPayments.size(), 'One payment record should have been created');
    }
}