@IsTest
public class TestSendEmailOnBookingForm {
     @testSetup
     public static void setupMethod() {
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        User user1 = TestDataFactory.createUserSysAdmin('On1e','sample11on', 'gal1111ron1@radius.com', 'g11alvatron1@radius.com');

        Unit__c u = new Unit__c(id=unitId, Reason_for_Cancellation__c = 'Test');
        upsert u;
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        Booking__c b = new Booking__c();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Sales_Managers__c = user1.Id;
        b.sales_Head__c = user1.Id;
        b.Secondary_Sales_Manager__c =  user1.Id;
        b.Secondary_Sales_Head__c =  user1.Id;
        b.status__c = 'UnProcessed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Booking_Date__c = datetime.newInstance(2024, 9, 25, 4, 0, 0);
        insert b;
        
        
    }
      @isTest
    public static void testNonSiniya() {
         
         Test.StartTest();
		SendEmailOnBookingForm sh1 = new SendEmailOnBookingForm();
		String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        Booking__c book = [Select id, Name, status__c from Booking__C where Project__r.Name = 'Test Project'];
         System.assertEquals('Cancelled', book.Status__c, 'Booking not Cancelled');
       
    }
     @isTest
    public static void testSiniya() {
         Booking__c b = [Select id, Name, status__c from Booking__C LIMIT 1];
           b.status__c='UnProcessed';
        b.Reason_For_Cancellation__c ='';
        update b;
         Project__c prj =[SELECT Id from Project__c LIMIT 1];
        prj.Name='Sobha Siniya Island';
        update prj;
         Test.StartTest();
		SendEmailOnBookingForm sh1 = new SendEmailOnBookingForm();
		String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check1', sch, sh1); 
        Test.stopTest();
        Booking__c book = [Select id, Name, status__c from Booking__C where Project__r.Name = 'Sobha Siniya Island'];
         System.assertEquals('Cancelled', book.Status__c, 'Booking not Cancelled');
       
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
       
    }