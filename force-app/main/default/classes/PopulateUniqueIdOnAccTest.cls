@IsTest
public class PopulateUniqueIdOnAccTest {
    
    @testsetup
    public static void createData(){
        
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John';
        parentPersonAccount.LastName = 'Smith';
        parentPersonAccount.PersonMobilePhone = '8579171110';
        parentPersonAccount.Phone = '8579171110';
        parentPersonAccount.PersonEmail = 'John@test.com';
        //parentPersonAccount.Unique_Customer_ID__c = '1254';
        //parentPersonAccount.Unique_Customer_External_ID__c = '1254';
        insert parentPersonAccount;
        
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        
        Opportunity oppRecord = new Opportunity(Id= oppId, AccountId = parentPersonAccount.Id);
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
        insert b;
        
        parentPersonAccount.Unique_Customer_ID__c = '';
        parentPersonAccount.Unique_Customer_External_ID__c = '';
        update parentPersonAccount;
        Applicant_Details__c objApplicant1 = new Applicant_Details__c();
        objApplicant1.Name = 'Duplicate Applicant Email';
        objApplicant1.Mobile_Number__c = '343434341';
        objApplicant1.Booking__c = b.Id;
        objApplicant1.Applicant_Number__c = 'Primary Applicant';
        objApplicant1.Email_Address__c = 'testno1@test.com';
        objApplicant1.Opportunity__c = oppId;
        insert objApplicant1;
        
        Applicant_Details__c objApplicant2 = new Applicant_Details__c();
        objApplicant2.Name = 'Duplicate Applicant Email';
        objApplicant2.Mobile_Number__c = '343434341';
        objApplicant2.Booking__c = b.Id;
        objApplicant2.Applicant_Number__c = 'Primary Applicant';
        objApplicant2.Email_Address__c = 'testno1@test.com';
        objApplicant2.Opportunity__c = oppId;
        test.startTest();
        insert objApplicant2;
        
       
        test.stopTest();
        
    }
    
    @isTest
    public static void updateUniqueCustomerIdTest() {
        test.startTest();
        PopulateUniqueIdOnAccQueueable obj = new PopulateUniqueIdOnAccQueueable();
        System.enqueuejob(obj);
        //PopulateUniqueIdOnAcc.startProcess();
        test.stopTest();
        
         List<Account> lstAccount2 = [SELECT ID,NAME,Unique_Customer_External_ID__c,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        System.debug('account need check if updated->'+lstAccount2);
        
        Assert.areEqual('1015001', lstAccount2[0].Unique_Customer_External_ID__c,'The Unique Customer External Id must be started from 100000.');
        Assert.areEqual('1015001', lstAccount2[0].Unique_Customer_ID__c,'The Unique Customer Id must be started from 100000.');
    }
    
    @isTest
    public static void updateUniqueCustomerIdForSingleApplicantTest() {
        
        Account parentPersonAccount2 = new Account();
        parentPersonAccount2.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount2.FirstName = 'John33';
        parentPersonAccount2.LastName = 'Smith33';
        parentPersonAccount2.PersonMobilePhone = '85791711144';
        parentPersonAccount2.Phone = '8579171114';
        parentPersonAccount2.PersonEmail = 'John4@test.com';
        insert parentPersonAccount2;
        
        Opportunity opp = new Opportunity(Name = 'Opp', StageName='Opportunity Identified', Amount=5000000, AccountId =parentPersonAccount2.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, Project__c = [SELECT ID FROM Project__c LIMIT 1].Id,closeDate=System.today());
        test.startTest();
        insert opp;
        
         Applicant_Details__c objApplicant3 = new Applicant_Details__c();
        objApplicant3.Name = 'Duplicate Applicant Email4';
        objApplicant3.Mobile_Number__c = '3434343414';
        objApplicant3.Booking__c = [SELECT ID FROM Booking__c LIMIT 1].Id;
        objApplicant3.Applicant_Number__c = 'Primary Applicant';
        objApplicant3.Email_Address__c = 'testno1@test4.com';
        objApplicant3.Opportunity__c = opp.Id;
        insert objApplicant3;
        
        //PopulateUniqueIdOnAcc.startProcess();
        PopulateUniqueIdOnAccQueueable obj = new PopulateUniqueIdOnAccQueueable();
        System.enqueuejob(obj);
        test.stopTest();
        
        List<Account> lstAccount2 = [SELECT ID,NAME,Unique_Customer_External_ID__c,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        System.debug('account need check if updated->'+lstAccount2);
        
        Assert.areEqual('1015001', lstAccount2[0].Unique_Customer_External_ID__c,'The Unique Customer External Id must be started from 100000.');
        Assert.areEqual('1015001', lstAccount2[0].Unique_Customer_ID__c,'The Unique Customer Id must be started from 100000.');
      
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