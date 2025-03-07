@isTest
public class MortgageTriggerClassTest {
    
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
        insert b;
        
        Mortgage__c mortgageRec = new Mortgage__c();
        mortgageRec.Booking__c = b.Id;
        mortgageRec.Bank_Name__c = 'ENBD – Emirates NBD';
        mortgageRec.Cheque_Amount__c = 100.00;
        mortgageRec.Status__c = 'Approved by Accounts';
        insert mortgageRec;
    }
    @isTest
    public static void testTriggerClass(){
        Mortgage__c mortgageRec = [Select Id,Status__c From Mortgage__c LIMIT 1];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
    	app.setObjectId(mortgageRec.Id);    
    	Approval.ProcessResult result = Approval.process(app);
        Test.startTest();        
        mortgageRec.Status__c = 'Approved by Audit';
        update mortgageRec;
        
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