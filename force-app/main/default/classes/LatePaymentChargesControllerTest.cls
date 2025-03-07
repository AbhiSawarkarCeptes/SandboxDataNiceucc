/* Class Name -  LatePaymentChargesControllerTest
 * PurPose - To Cover the Test Coverage for LatePaymentChargesController
 * Created By - Ashwin Kushwah
 * Used - as a test class for LatePaymentChargesController
 * Modified By - 
 * Modification Reason - 
*/

@isTest
public class LatePaymentChargesControllerTest {
    
    //inserting the test data 
    @testSetup
    public static void setup(){
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Legal_Entity__c entity = new Legal_Entity__c(Name ='test Name');
        insert entity;
        
        Tower__c tower = [SELECT Id, Name,RDS_Company_Code__c, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        tower.Address__c ='test addr,,,';
        tower.RDS_Company_Code__c = entity.id;
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
        b.Total_Interest_Till_Date__c = 10;
        insert b;
        
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
        
        List<Demand__c> demandList = new List<Demand__c>();
        //insert demand record
        Demand__c d = new Demand__c();
        d.Milestone_Name__c = 'Debit note for DLD Charges';       
        d.Debit_Demanded__c = 100000;
        d.Debit_CGST__c = 0;
        d.Tax_Rate__c = 'OUT OF SCOPE';
        d.Debit_Type__c = 'Interest Charges';
        d.Invoice_Date__c = System.Today();
        d.GL_Date__c = System.Today();
        d.Due_Date__c = pm.Milestone_Due_Date__c;
        d.Project__c = recordIdMap.get('PROJECT');
        d.Booking__c = b.Id;
        d.Unit__c = unitId;
        d.Corporate_Collection_Control_Report__c = 50000; 
        d.Registration_Collection_Control_Report__c = 20000;
        d.Payment_Towards__c = 'Corporate Account';
        d.Payment_Milestones__c = pm.id;
        demandList.add(d);
        //insert d;
        
        Demand__c d1 = new Demand__c();
        d1.Milestone_Name__c = 'Debit note for DLD Charges';       
        d1.Debit_Demanded__c = 100000;        d1.Debit_CGST__c = 0;
        d1.Tax_Rate__c = 'OUT OF SCOPE';
        d1.Debit_Type__c = 'Interest Charges';
        d1.Invoice_Date__c = System.Today();
        d1.GL_Date__c = System.Today();
        d1.Due_Date__c = pm.Milestone_Due_Date__c;
        d1.Project__c = recordIdMap.get('PROJECT');
        d1.Booking__c = b.Id;
        d1.Unit__c = unitId;
        d1.Corporate_Collection_Control_Report__c = 50000; 
        d1.Registration_Collection_Control_Report__c = 20000;
        d1.Payment_Towards__c = 'Corporate Account';
        d1.Payment_Milestones__c = pm.id;
        d1.Due_Date__c = System.today().addDays(-50);
        d1.Invoice_Date__c = System.today().addDays(-50);
        demandList.add(d1);
        //insert d1;
        
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
        d2.Due_Date__c = System.today().addDays(-90);
        d2.Invoice_Date__c = System.today().addDays(-90);
        d2.Interest_Charges__c = 500;
        demandList.add(d2);
        //insert d2;
        Insert demandList;
    }
    @isTest
    public static void testController(){
        Booking__c booking = [Select Id From Booking__c LIMIT 1];
        Test.startTest();
        PageReference testPage = Page.LatePaymentcharges;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(booking.Id));
        LatePaymentChargescontroller latePaymentC = new LatePaymentChargescontroller();
        LatePaymentChargescontroller.hack();
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