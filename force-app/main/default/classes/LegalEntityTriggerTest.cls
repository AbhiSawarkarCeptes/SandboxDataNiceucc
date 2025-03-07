@isTest
public with sharing class LegalEntityTriggerTest {
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
       
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
               
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    } 
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 10000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;                  
     }     
    
    @isTest
    public static void LegalEntityTriggerTest() {
        Map<String, Id> recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
      
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Cancellation In Progress';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        Legal_Entity__c entity = new Legal_Entity__c(Name ='test Name');
        insert entity;
        
        Unit__c u = new Unit__c(Id = unitId, Legal_Entity__c = entity.id);
        upsert u;
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = projectid;
        objRec.Opportunity__c =optyId;
         objRec.Booking__c = b.Id; // Neha
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 100000;
        objRec.Total_Amount__c = 100000;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        //     objRec.Opportunity_Email_id__c = 'test@test.com';
        insert objRec; 
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=objRec.id;       
        insert fr1; 
        entity.project_name_id__c = 'test';
        update entity;
    }
    
    @isTest
    public static void Batch_UpdateFRRsTest() {
        Map<String, Id> recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
      
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Cancellation In Progress';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        Legal_Entity__c entity = new Legal_Entity__c(Name ='test Name');
        insert entity;
        
        Unit__c u = new Unit__c(Id = unitId, Legal_Entity__c = entity.id);
        upsert u;
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = projectid;
        objRec.Opportunity__c =optyId;
         objRec.Booking__c = b.Id; // Neha
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 100000;
        objRec.Total_Amount__c = 100000;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        //     objRec.Opportunity_Email_id__c = 'test@test.com';
        insert objRec; 
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=objRec.id;       
        insert fr1; 
        entity.project_name_id__c = 'test';
        update entity;
        Test.startTest();
        Database.executeBatch(new Batch_UpdateFRRs(new Set<Id>{entity.id}));
        Test.stopTest();
    }
    
}