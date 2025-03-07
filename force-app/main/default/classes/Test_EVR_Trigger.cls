@isTest 
public class Test_EVR_Trigger {
    static Booking__c b;
    public static Boolean isInternalUser = false;
    public static Boolean hasFinanceAccess = false;
    public static Boolean hasVendorAccess = false;
    public static Boolean hasAdminAccess = false;
    
	@testSetup
    public static void setupData() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        
        List<Receipt__c> receiptsList = new List<Receipt__c>();
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 20000000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 20000000;
        r1.Amount_Rs__c = 20000000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'AED';
        r1.Booking__c = b.Id;
        r1.Receipt_Status__c = 'Cleared';
        //r1.Mode__c='Credit Note';
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 20000000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = oppId;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 2000;
        r2.Amount_Rs__c = 2000;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'Cheque';
        r2.Currency__c = 'AED';
        r2.Booking__c = b.Id;
        r2.Receipt_Status__c = 'Cleared';
        //r1.Mode__c='Credit Note';
        r2.Registration_Collection_Control_Report__c = 2000;
        r2.GL_Date__c = System.today();
        insert r2;
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
    
    @isTest static void testInternalUser(){
        isInternalUser = false;
        hasFinanceAccess = true;
        
        List<External_Verification_Register__c> evrs = [SELECT id FROM External_Verification_Register__c];
        if(evrs.isEmpty()){
            List<Booking__c> bookings = [SELECT id FROM Booking__c];
            evrs.add(
                new External_Verification_Register__c(
                	Booking__c = bookings[0].Id
                )
            );
            insert evrs;
        }
        
        
        try{
            evrs[0].Verifier_s_Comment_Options__c = 'Matching in both Xpedeon & SalesForce';
            evrs[0].SOA_Verified__c = false;
            update evrs;
            evrs[0].SOA_Verified__c = false;
            update evrs;
            evrs[0].Verifier_s_Comment_Options__c = 'Matching in both Xpedeon & SalesForce';
            evrs[0].SOA_Verified__c = true;
            update evrs;
            evrs[0].Verifier_s_Comment_Options__c = 'Matching in both Xpedeon & SalesForce';
            evrs[0].AR_Verified__c = false;
            update evrs;
            evrs[0].AR_Verified__c = true;
            update evrs;
        }catch(Exception ex){
            
        }
        
    }
    
    @isTest static void testExternalUser(){
        isInternalUser = true;
        hasVendorAccess = true;
        
        List<External_Verification_Register__c> evrs = [SELECT id FROM External_Verification_Register__c];
        if(evrs.isEmpty()){
            List<Booking__c> bookings = [SELECT id FROM Booking__c];
            evrs.add(
                new External_Verification_Register__c(
                	Booking__c = bookings[0].Id
                )
            );
            insert evrs;
        }
        
        
        
        try{
            evrs[0].Verifier_s_Comment_Options__c = 'Matching in both Xpedeon & SalesForce';
            evrs[0].SOA_Verified__c = true;
            update evrs;
            evrs[0].Verifier_s_Comment_Options__c = 'Matching in both Xpedeon & SalesForce';
            evrs[0].AR_Verified__c = false;
            update evrs;
            evrs[0].AR_Verified__c = true;
            update evrs;
             evrs[0].SOA_Verified__c = false;
             update evrs;
        }catch(Exception ex){}
    }
}