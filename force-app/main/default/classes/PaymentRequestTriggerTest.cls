@isTest
public class PaymentRequestTriggerTest {
    @testSetup 
    public static void setup() {
     
        // Create test data for Booking__c records
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
        Booking__c testBooking = new Booking__c();
        testBooking.Booking_Date__c = system.today();
        testBooking.Project__c = projectId;
        testBooking.Opportunity__c = oppId;
        testBooking.Unit__c = unitId;
        testBooking.status__c = 'Processed';
        testBooking.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        testBooking.Future_Correspondence_Contact__c = 'First Applicant';
        testBooking.Agreement_Value__c = 6000000;
        testBooking.Secondary_Sales_Manager__c =  userinfo.getUserId();
        testBooking.Stage_of_Booking__c = 'Booked';
        testBooking.Quotation__c = quote.Id;
        insert testBooking;
        
        Payment_Request__c pr1 = new Payment_Request__c();
        pr1.name__c = 'Test PR 1';
        pr1.Booking__c=testBooking.id;
        pr1.Email__c = 'test@test.com.invalid';
        pr1.Mobile_Number__c='000';
        pr1.Emirates_Id_Passport_Number__c='000';
        pr1.Mode__c = 'OTC Deposits';
        pr1.Status__c='Approved';
        pr1.Amount__c = 123;
        pr1.Submitted_Date__c = String.valueOf(System.today());
        pr1.Approved_Date_and_Time__c=System.today();
        pr1.Towards_Other_Charges_Amount__c =10;
        pr1.Towards_Pre_Registration_Amount__c =23;
        pr1.Towards_Unit_Price_Amount__c = 100;
        pr1.Mortgage_Value__c = 100;
        pr1.From_Booking__c = true;
        insert pr1;

    }
    
    @isTest 
    public static void testInsertPaymentRequest() {
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        Payment_Request__c testPR = [SELECT id FROM Payment_Request__c LIMIT 1];
        
        Test.StartTest();
        Payment_Request__c pr1 = new Payment_Request__c();
        pr1.name__c = 'Test PR 1';
        pr1.Booking__c=testBooking.id;
        pr1.Email__c = 'test@test.com.invalid';
        pr1.Mobile_Number__c='000';
        pr1.Emirates_Id_Passport_Number__c='000';
        pr1.Mode__c = 'OTC Deposits';
        pr1.Status__c='Approved';
        pr1.Amount__c = 123;
        pr1.Submitted_Date__c = String.valueOf(System.today());
        pr1.Approved_Date_and_Time__c=System.today();
        pr1.Towards_Other_Charges_Amount__c =10;
        pr1.Towards_Pre_Registration_Amount__c =23;
        pr1.Towards_Unit_Price_Amount__c = 100;
        pr1.Mortgage_Value__c = 100;
        pr1.From_Booking__c = true;
        pr1.Payment_Request__c = testPR.Id;
        insert pr1;
        Test.StopTest();
        
    }
    
    @isTest 
    public static void testOtherCharges() {
        Booking__c testBooking = [SELECT Id FROM Booking__c LIMIT 1];
        Payment_Request__c testPR = [SELECT id FROM Payment_Request__c LIMIT 1];
        
        Payment_Request__c pr1 = new Payment_Request__c();
        pr1.name__c = 'Test PR 1';
        pr1.Booking__c=testBooking.id;
        pr1.Email__c = 'test@test.com.invalid';
        pr1.Mobile_Number__c='000';
        pr1.Emirates_Id_Passport_Number__c='000';
        pr1.Mode__c = 'OTC Deposits';
        pr1.Status__c='Partially Approved';
        pr1.Amount__c = 123;
        pr1.Submitted_Date__c = String.valueOf(System.today());
        pr1.Approved_Date_and_Time__c=System.today();
        pr1.Towards_Other_Charges_Amount__c =10;
        pr1.Towards_Pre_Registration_Amount__c =23;
        pr1.Towards_Unit_Price_Amount__c = 100;
        pr1.Mortgage_Value__c = 100;
        pr1.From_Booking__c = true;
        pr1.Others__c = 'Mortgage Fees';
        insert pr1;
        
        Test.StartTest();
        pr1.Status__c='Approved';
        update pr1;
        
        pr1.Others__c = 'DEWA Charges';
        pr1.Mode__c = 'CDM Cash';
        pr1.Towards_Other_Charges_Amount__c = 1000;
        try {
        update pr1;
        
        pr1.Status__c = 'Resubmitted to SM/SD';
        update pr1;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        Test.StopTest();
        
    }
            
}