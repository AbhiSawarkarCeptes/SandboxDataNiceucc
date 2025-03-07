@isTest
public class X_CustomerCodeUpdateBatchTest {
@testSetup
    public static void testData(){
      Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
      Id oppId = recordMap.get('OPPORTUNITY'); 
      Id unitId = recordMap.get('UNIT');
      Id towerid = recordMap.get('TOWER');
      Id projectid = recordMap.get('PROJECT');
        
      Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);     
        
      Account acc = new Account();
      acc.LastName = 'testName';
      insert acc;
        
      Booking__c b = new Booking__c();
      b.Booking_Date__c = system.today();
      b.Project__c = projectId;
      b.Opportunity__c = oppId;
      b.Unit__c = unitId;
      b.status__c = 'Processed';
      b.Quotation__c = quote.Id;
      b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
      b.Future_Correspondence_Contact__c = 'First Applicant';
      b.Agreement_Value__c = 6000000;
      insert b;
    }
    
    @isTest
    public static void testCustomerCode(){
        opportunity opp = [select id,AccountId from Opportunity limit 1];
        Account acc = [select id,code__c from Account limit 1];
        opp.accountId = acc.id;
        update Opp;
        test.startTest();
        Id batchJobId = Database.executeBatch(new X_CustomerCodeUpdateBatch(), 20);
        test.stopTest();
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