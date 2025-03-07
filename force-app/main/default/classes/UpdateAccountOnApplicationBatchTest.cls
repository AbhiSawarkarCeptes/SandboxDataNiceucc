@IsTest
public class UpdateAccountOnApplicationBatchTest {
    
    @testsetup
    public static void createData() {
        
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John';
        parentPersonAccount.LastName = 'Smith';
        parentPersonAccount.PersonMobilePhone = '8579171110';
        parentPersonAccount.Phone = '8579171110';
        parentPersonAccount.PersonEmail = 'John@test.com';
        insert parentPersonAccount;
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        
        Opportunity oppRecord = new Opportunity(Id= oppId, AccountId = null);
        update oppRecord;
        
        Quotation__c quote = createQuotation(oppId, [SELECT Id FROM Payment_Plan__c WHERE Plan_Code__c = '001' LIMIT 1].Id, [SELECT Id FROM Unit__c WHERE Unit_status__c = 'Available' LIMIT 1].Id); 
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = [SELECT Id FROM Project__c LIMIT 1].Id;
        b.Opportunity__c = oppId;
        b.Unit__c = [SELECT Id FROM Unit__c WHERE Unit_status__c = 'Available' LIMIT 1].Id;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        test.startTest();
        insert b;
        
        System.debug('batch size main'+Limits.getQueueableJobs());
        System.debug('batch size main'+Limits.getLimitQueueableJobs());
        Applicant_Details__c objApplicant1 = new Applicant_Details__c();
        objApplicant1.Name = 'Duplicate Applicant Email';
        objApplicant1.Mobile_Number__c = '343434341';
        objApplicant1.Booking__c = [SELECT ID FROM Booking__c LIMIT 1].Id;
        objApplicant1.Applicant_Number__c = 'Primary Applicant';
        objApplicant1.Email_Address__c = 'testno1@test.com';
        objApplicant1.Opportunity__c = oppId;
        
        insert objApplicant1;
        test.stopTest();
        System.debug('batch size after'+Limits.getQueueableJobs());
        System.debug('batch size after'+Limits.getLimitQueueableJobs());

    }
    
    @isTest
    public static void updateAccountIdOnApplicantTest() {
        
        
        Id oppId = [SELECT ID FROM Opportunity LIMIT 1].Id;
        
        Opportunity opp2 = new Opportunity(Id = oppId, AccountId = [SELECT ID FROM Account LIMIT 1].Id);
        update opp2;
        System.debug('batch size'+Limits.getQueueableJobs());
        System.debug('batch size'+Limits.getLimitQueueableJobs());
        System.debug('batch size->'+[select id,Name,Booking__c,Opportunity__r.AccountId,Applicant_Number__c,Account__c 
                                     from Applicant_Details__c 
                                     where Applicant_Number__c = 'Primary Applicant']);
        System.debug('batch size->'+[select id,Name,Opportunity__r.AccountId,Applicant_Number__c,Account__c 
                                     from Applicant_Details__c 
                                     where Applicant_Number__c = 'Primary Applicant' 
                                     AND Booking__c != NULL 
                                     AND Account__c = NULL
                                     AND Opportunity__r.AccountId != NULL]);
        
        test.startTest();
        Database.executeBatch(new UpdateAccountOnApplicationBatch(),1);
        test.stopTest();
        
        List<Applicant_Details__c> lstApplicant = [SELECT ID,Opportunity__r.AccountId, Account__c FROM Applicant_Details__c];
		        
        Assert.areEqual(lstApplicant[0].Opportunity__r.AccountId, lstApplicant[0].Account__c, 'For Primary Applicant Opportunity Account Id and Applicant Account Id must be same.');
        
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