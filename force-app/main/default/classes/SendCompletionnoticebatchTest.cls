@isTest public class SendCompletionnoticebatchTest {
	@isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        Cluster__c cl = new Cluster__c(Id=clusterId);
        cl.Name='Sobha Creek vistas Reserve';
        update cl;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Sobha Hartland Waves DM Completion Certificate',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        Unit__c un = new Unit__c(Id=unitId);
        un.Send_Completion_Notice__c = true;
        update un;
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Name__c = 'Test';
        b.Email_Address_2__c = 'abc.abc@abc.com';
        b.Email_Address_3__c = 'abc.abc@abc.com';
        b.Email_Address_4__c = 'abc.abc@abc.com';
        insert b;
        
        SendCompletionnoticebatch obj = new SendCompletionnoticebatch();
        Database.executeBatch(obj);
        list<booking__c> bList = [select id,Tower_Name__c,Primary_Applicant_Name__c,Cluster__c, Handover_Date__c, Dewa_Number__c, Unit__c, Primary_Applicant_Email__c,Unit__r.Name, Owner.Name,Owner.Email,Unit__r.Tower__r.Name,Project__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Date_of_Completion__c,Opportunity__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c, Opportunity__r.Permanent_Address__c, Opportunity__r.Primary_Phone__c, Opportunity__r.Primary_Email__c  from Booking__c limit 1];
        obj.execute(null,bList);
    }
    
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
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
    
    private static Payment_Milestones__c createPaymentMilestone(Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 300000000;          
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
}