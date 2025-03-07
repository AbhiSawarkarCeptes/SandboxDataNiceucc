@isTest public class SendWarningLetterControllerTest {
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
        tower.Address__c ='test addr';
        tower.RDS_Company_Code__c = entity.id;
		tower.Name = 'Sobha Tranquility';
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Opportunity op = new Opportunity(Id=recordIdMap.get('OPPORTUNITY'));
        op.Other_Applicants_Name__c = 'Other Applicant';
        op.Other_Applicants_Email__c = 'other@test.com';
        update op;
        
        try{
            op.Secondary_Sales_Manager__c = UserInfo.getUserId();
            update op;
        }
        catch(Exception e){}
        
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
        b.Ageing_days__c = 35;
        b.Agreement_Value__c = 1000;
        b.Milestone_Due_Till_Date__c = 550;
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Email__c = 'test@test.com';
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
        objRec.GL_Date__c = System.today();
        insert objRec; 
    }
    
    @isTest public static void testGetBookings(){
        Test.startTest();
        Booking__c b = [select Id,Total_On_Account_Money_With_Registration__c from Booking__c limit 1];
        SendWarningLetterController.getBookings('All');
        Tower__c t = [select Id from Tower__c LIMIT 1];
        SendWarningLetterController.getBookings(t.Id);
        SendWarningLetterController.sendWarningLetter(b.Id);
        SendWarningLetterController ob = new SendWarningLetterController();
        SendWarningLetterController.getTowers();
        Test.stopTest();
    }
    
    @isTest public static void testCalculateAgeingOnBookingBatch(){
        CalculateAgeingOnBookingBatch ob = new CalculateAgeingOnBookingBatch();
        Test.startTest();
        Database.executeBatch(ob);
        Test.stopTest();
    }
    
    @isTest public static void testCalculateAgeingOnBookingSchedule(){
        CalculateAgeingOnBookingSchedule ob = new CalculateAgeingOnBookingSchedule();
        Test.startTest();
        String cronExp = '0 0 * * * ?';
        String jobID = System.schedule('Update Ageing On Booking Test', cronExp, ob);
        Test.stopTest();
    }
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(-10);
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
        pm.C1_Amount__c	= 1000;
        insert pm;        
        return pm;
    }
}