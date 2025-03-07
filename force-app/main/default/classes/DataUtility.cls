@isTest
public class DataUtility {

    @isTest
    public static List<Customer_Registration__c> getSiteVisitForms(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        Cluster__c cl = new Cluster__c(Id=clusterId);
        cl.Name='Waves';
        update cl;
        
        Opportunity op = new Opportunity(Id=oppId);
        op.Other_Applicants_Name__c = 'Other';
        op.Other_Applicants_Email__c = 'other@other.com';
        update op;
        
        Unit__c un = new Unit__c(Id=unitId);
        un.Send_BCC__c = true;
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

        Id devRecordTypeId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByName().get('CRM Site Visit').getRecordTypeId();

        List<Customer_Registration__c> crList = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Country_Code__c = '+91';
        cr1.RecordTypeId = devRecordTypeId;
        cr1.Mobile_Number__c = '1111111111';
        cr1.Alternate_Mobile_Number__c = '1111111111';
        cr1.Dialing_Country__c = 'India';
        cr1.Booking__c = b.Id;
        cr1.Property_Type__c = 'Apartment';
        insert cr1;
        crList.add(cr1);
        return crList;
    }
    
    @isTest
    public static List<Sobha_Connect__c> getSobhaConnect(){
        List<Sobha_Connect__c> scList = new List<Sobha_Connect__c>();
        Sobha_Connect__c sc = new Sobha_Connect__c();
        insert sc;
        scList.add(sc);
        return scList;
    }
    @isTest
    public static List<Channel_Partner__c> getChannelPartner(){
        List<Channel_Partner__c> cpList = new List<Channel_Partner__c>();
        Channel_Partner__c cp = new Channel_Partner__c();
        insert cp;
        cpList.add(cp);
        return cpList;
    }

    @isTest
    public static List<Integration_Info__c> getCustomer_Registration(){
        List<Integration_Info__c> cfiList = new List<Integration_Info__c>();
        Integration_Info__c cif = new Integration_Info__c();
        cif.Active__c = true;
        cif.Name = 'Token API';
        insert cif;
        cfiList.add(cif);
        return cfiList;
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