@istest
public class ApptrigTest {
    
    @TestSetup
    static void setupData() {
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
        
        Opportunity oppRecord = new Opportunity(Id= oppId, AccountId = parentPersonAccount.Id);
        update oppRecord;
        
        List<Applicant_Details__c> appDList = new List<Applicant_Details__c>();
        for(Integer i=0; i<5; i++){
            Applicant_Details__c app = new Applicant_Details__c(Name = 'Test Name'+i, Mobile_Number__c='34343434'+i, Email_Address__c='testno'+i+'@test.com');
            appDList.add(app);
        }
        insert appDList;
    }
    
    @isTest
    static void testMethod1(){
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = 'Test';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        List<Applicant_Details__c> appDetailsList = [SELECT Id, Name, Mobile_Number__c, Email_Address__c FROM Applicant_Details__c LIMIT 100];
        Test.stopTest();
    }
    
    @isTest
    public static void duplicateApplicantTest() {
        List<Account> lstAccount = [SELECT ID,NAME,Unique_Customer_External_ID__c,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        System.debug('account need check if updated->'+lstAccount);
        
        Id oppId = [SELECT ID FROM OPPORTUNITY LIMIT 1].Id;
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
        Test.startTest();
        insert b;
        
        Applicant_Details__c objApplicant1 = new Applicant_Details__c();
        objApplicant1.Name = 'Duplicate Applicant Email';
        objApplicant1.Mobile_Number__c = '343434341';
        objApplicant1.Booking__c = b.Id;
        objApplicant1.Applicant_Number__c = 'Primary Applicant';
        objApplicant1.Email_Address__c = 'testno1@test.com';
        insert objApplicant1;
        
        Applicant_Details__c objApplicant = new Applicant_Details__c();
        objApplicant.Name = 'Duplicate Applicant Email';
        objApplicant.Mobile_Number__c = '343434341';
        objApplicant.Booking__c = b.Id;
        objApplicant.Applicant_Number__c = 'Primary Applicant';
        objApplicant.Email_Address__c = 'testno1@test.com';
        insert objApplicant;
        Test.stopTest();
        
        List<Account> lstAccount2 = [SELECT ID,NAME,Unique_Customer_External_ID__c,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        System.debug('account need check if updated->'+lstAccount2);
        //ApplicantTriggerHandler.insertErrorLog('test','test','test','test','test');
        
        //Assert.areEqual('100000', lstAccount2[0].Unique_Customer_External_ID__c,'The Unique Customer External Id must be started from 100000.');
        //Assert.areEqual('100000', lstAccount2[0].Unique_Customer_ID__c,'The Unique Customer Id must be started from 100000.');
    }
    
    @isTest
    public static void duplicatePersonAccountTest() {
        PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John';
        parentPersonAccount.LastName = 'Smith';
        parentPersonAccount.PersonMobilePhone = '8579171110';
        parentPersonAccount.Phone = '8579171110';
        parentPersonAccount.PersonEmail = 'John@test.com';
        insert parentPersonAccount;
        PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
        
        Campaign c = new Campaign(Name = 'Test Campaign', Type = 'Newspapers', isActive = true, Digital_Maketing_Campaign_Code__c='1111');
        insert c;
        
         Account parentPersonAccount2 = new Account();
        parentPersonAccount2.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount2.FirstName = 'John2';
        parentPersonAccount2.LastName = 'Smith2';
        parentPersonAccount2.PersonMobilePhone = '8579171110';
        parentPersonAccount2.Phone = '8579171112';
        parentPersonAccount2.PersonEmail = 'Joh2n@test.com';
        parentPersonAccount2.Campaign_Code__c = c.Id;
        insert parentPersonAccount2;
        /*List<Lead> leadList = new List<Lead>();
        try {
            Lead l = new Lead();
            l.FirstName = 'Barack'; 
            l.LastName = 'smith';
            l.Email = 'barack@smaith.com' ;
            l.MobilePhone = '99852147';
            //l.Booking__c = app.Booking__c;
            insert l;
            leadList.add(l);
            
            Lead l2 = new Lead();
            l2.FirstName = 'Barack2'; 
            l2.LastName = 'smith2';
            l2.Email = 'barack@smaith.com' ;
            l2.MobilePhone = '998521472';
            //l.Booking__c = app.Booking__c;
             Test.startTest();
            insert l2;
            leadList.add(l2);
        }catch(exception ex) {
            
        }
        
        try {
            list<Database.LeadConvert> leadsToConvert = new list<Database.LeadConvert>();
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            
            for(lead l: leadList){
                System.debug('lead conver'+l);
                Database.LeadConvert tempLC = new Database.LeadConvert();
                tempLC.setLeadId(l.id);
                tempLC.setConvertedStatus(convertStatus.MasterLabel);
                leadsToConvert.add(tempLC);
            }
           
            Database.convertLead(leadsToConvert);
            Test.stopTest();
        }catch(Exception exp) {
            
        }
        List<Lead> lstLead = [SELECT ID FROM LEAD];
        System.debug('lead list=>'+lstLead);*/
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