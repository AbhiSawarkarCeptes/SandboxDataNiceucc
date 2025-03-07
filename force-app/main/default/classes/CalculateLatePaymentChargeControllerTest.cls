/* Class Name - CalculateLatePaymentChargeControllerTest
* PurPose - This Class is used to test the CalculateLatePaymentCharge Demands
* Created By - Ashwin Kushwah
* Modified By - 
* Modification Reason - 
*/

@isTest
public class CalculateLatePaymentChargeControllerTest {
    
    //inserting the test data 
    @testSetup
    public static void setup(){
        List<Demand__c> demandList = new List<Demand__c>();
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';      
        insert b;
        
        Quotation__c q1 = new Quotation__c();
        q1.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q1.Unit__c = recordIdMap.get('UNIT');
        q1.Payment_Plan__c = recordIdMap.get('PLAN');
        q1.Quote_Status__c = 'Valid';
        insert q1;
        
        Payment_Milestones__c pm1 = createPaymentMilestone(q1.Id);
        /*
        Booking__c b1 = new Booking__c();
        b1.Booking_Date__c = System.today().addDays(-10);
        b1.Project__c = recordIdMap.get('PROJECT');
        b1.Tower__c = recordIdMap.get('TOWER');
        b1.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b1.Quotation__c = q1.Id;
        b1.Unit__c = recordIdMap.get('UNIT');
        b1.Agreement_Value__c = 2500;
        b1.Status__c = 'Processed';
        b1.Stage_of_Booking__c = 'Booked';
        b1.Verification_status__c = 'Not Started';
        b1.Booking_Approver_Audit__c = 'Not Started';
        b1.Call_Disposition__c = 'Not Started';      
        insert b1; */
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c =recordIdMap.get('PROJECT');
        objRec.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec.Project_Unit__c = recordIdMap.get('UNIT');
        objRec.Booking__c = b.Id; 
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 500;
        objRec.Total_Amount__c = 500;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec; 
        /*
        Receipt__c objRec1 = new Receipt__c();
        objRec1.Project__c =recordIdMap.get('PROJECT');
        objRec1.Opportunity__c =recordIdMap.get('OPPORTUNITY');
        objRec1.Project_Unit__c = recordIdMap.get('UNIT');
        objRec1.Booking__c = b1.Id; 
        objRec1.Receipt_Status__c = 'Cleared';
        objRec1.Mode__c = 'Cheque';
        objRec1.Cheque_DD__c = '12';
        objRec1.Remarks__c = true;
        objRec1.Amount_Rs__c = 500;
        objRec1.Total_Amount__c = 500;
        objRec1.Receipt_Date__c = System.today().addDays(-1);
        objRec1.Cheque_DD_Date__c = System.today();
        objRec1.Token_Amount_Receipt__c = true;
        objRec1.On_Account_Money__c = 0;
        objRec1.Currency__c = 'Indian Rupee';
        insert objRec1;
        */
        /*
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'First Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        insert a1;
        */
        Team__c t = new Team__c();
        t.Team_Type__c = 'CRM Team';
        t.Project__c =  recordIdMap.get('PROJECT');
        t.Sub_Project__c = recordIdMap.get('CLUSTER');
        insert t;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Team__c = t.Id;
        tm.User_Active__c = true;
        tm.User__c = UserInfo.getUserId();
        insert tm; 
        
        Team_Members__c tm1 = new Team_Members__c();
        tm1.Team__c = t.Id;
        tm1.User_Active__c = true;
        tm1.User__c = UserInfo.getUserId();
        insert tm1;
        
        //insert demand record
        Demand__c d = new Demand__c();
        d.Milestone_Name__c = 'Debit note for DLD Charges';       
        d.Debit_Demanded__c = 100;
        d.Debit_CGST__c = 0;
        d.Tax_Rate__c = 'OUT OF SCOPE';
        d.Debit_Type__c = 'Interest Charges';
        d.Invoice_Date__c = System.Today();
        d.GL_Date__c = System.Today();
        d.Due_Date__c = pm.Milestone_Due_Date__c;
        d.Project__c = recordIdMap.get('PROJECT');
        d.Booking__c = b.Id;
        d.Unit__c = unitId;
        d.Corporate_Collection_Control_Report__c = 20; 
        d.Registration_Collection_Control_Report__c = 20;
        d.Payment_Towards__c = 'Corporate Account';
        d.Payment_Milestones__c = pm.id;
       // demandList.add(d);
        insert d;
        
        Demand__c d1 = new Demand__c();
        d1.Milestone_Name__c = 'Debit note for DLD Charges';       
        d1.Debit_Demanded__c = 100;        d1.Debit_CGST__c = 0;
        d1.Tax_Rate__c = 'OUT OF SCOPE';
        d1.Debit_Type__c = 'Interest Charges';
        d1.GL_Date__c = System.Today();
        d1.Due_Date__c = pm.Milestone_Due_Date__c;
        d1.Project__c = recordIdMap.get('PROJECT');
        d1.Booking__c = b.Id;
        d1.Unit__c = unitId;
        d1.Corporate_Collection_Control_Report__c = 50; 
        d1.Registration_Collection_Control_Report__c = 20;
        d1.Payment_Towards__c = 'Corporate Account';
        d1.Payment_Milestones__c = pm1.id;
        d1.Due_Date__c = System.today().addDays(-50);
        d1.Invoice_Date__c = System.today().addDays(-50);
       // demandList.add(d1);
        insert d1;
        
        Demand__c d2 = new Demand__c();
        d2.Milestone_Name__c = 'Debit note for DLD Charges';       
        d2.Debit_Demanded__c = 100000;
        d2.Debit_CGST__c = 0;
        d2.Tax_Rate__c = 'OUT OF SCOPE';
        d2.Debit_Type__c = 'Interest Charges';
        d2.Invoice_Date__c = System.Today();
        d2.GL_Date__c = System.Today();
        d2.Due_Date__c = pm.Milestone_Due_Date__c;
        d2.Project__c = recordIdMap.get('PROJECT');
        d2.Booking__c = b.Id;
        d2.Unit__c = unitId;
        d2.Corporate_Collection_Control_Report__c = 50000; 
        d2.Registration_Collection_Control_Report__c = 20000;
        d2.Payment_Towards__c = 'Corporate Account';
        d2.Payment_Milestones__c = pm.id;
       // d2.Due_Date__c = System.today().addDays(-90);
        //d2.Invoice_Date__c = System.today().addDays(-90);
        //demandList.add(d2);
        insert d2;
        /*
        Demand__c d11 = new Demand__c();
        d11.Milestone_Name__c = 'Debit note for DLD Charges';       
        d11.Debit_Demanded__c = 100;
        d11.Debit_CGST__c = 0;
        d11.Tax_Rate__c = 'OUT OF SCOPE';
        d11.Debit_Type__c = 'Interest Charges';
        d11.Invoice_Date__c = System.Today();
        d11.GL_Date__c = System.Today();
        d11.Due_Date__c = pm1.Milestone_Due_Date__c;
        d11.Project__c = recordIdMap.get('PROJECT');
        d11.Booking__c = b1.Id;
        d11.Unit__c = unitId;
        d11.Corporate_Collection_Control_Report__c = 50000; 
        d11.Registration_Collection_Control_Report__c = 20000;
        d11.Payment_Towards__c = 'Corporate Account';
        d11.Payment_Milestones__c = pm1.id;
        demandList.add(d11);
        //insert d11; */
       // insert demandList;
 }
    @isTest
    public static void calculateLatePaymentTest(){
        Demand__c demand = [Select Id, Booking__c From Demand__c Where Booking__c != Null LIMIT 1];
        System.debug('the demand in testing is --' + demand);
        Booking__c booking =[Select Id,Total_On_Account_Money_With_Registration__c From Booking__c Where Id =:demand.Booking__c LIMIT 1];
        System.debug('the booking in testing is --- '+ booking);
        Test.startTest();
        CalculateLatePaymentChargeController.calculateLatePayment(booking.id);
        Test.stopTest();
    }
    
    @isTest
    public static void calculateLatePaymentNegTest(){
       List<Demand__c> demandList = [Select Id, Booking__c From Demand__c Where Booking__c != Null];
       for(Demand__c demand : demandList){
          demand.Debit_Demanded__c = 100;
          demand.Corporate_Collection_Control_Report__c = 20; 
          demand.Registration_Collection_Control_Report__c = 20;   
        }
	   Booking__c booking =[Select Id,Total_On_Account_Money_With_Registration__c From Booking__c LIMIT 1];
 	  // List<Demand__c> demandList = [Select Id, ]
       Test.startTest();
       update demandList; 
	   CalculateLatePaymentChargeController.calculateLatePayment(booking.id);
       Test.stopTest(); 
            
    } 
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(10);
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 0;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;
    }
}