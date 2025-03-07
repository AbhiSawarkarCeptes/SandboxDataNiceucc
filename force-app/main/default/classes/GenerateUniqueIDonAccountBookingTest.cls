@IsTest
public class GenerateUniqueIDonAccountBookingTest {
    
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
        
        Opportunity oppRecord = new Opportunity(Id= oppId, AccountId = parentPersonAccount.Id);
        update oppRecord;
        
        unit_hold_request__c objNewSale = new unit_hold_request__c();
        objNewSale.Agent_Name__c = 'Jhon';
        objNewSale.Blocking_Amount_Paid__c = 123;
        objNewSale.Opportunity__c = oppId;
        objNewSale.Approval_Status__c = 'Pending';
        objNewSale.How_Many_Applicants__c = 'One Applicant';
        objNewSale.Approved_Date__c = System.today()+5;
        insert objNewSale;
    }
    
    @isTest
    public static void createBookingUniqueIdGenerateTest(){
        Id oppId = [SELECT ID FROM OPPORTUNITY LIMIT 1].Id;
        /*Quotation__c quote = createQuotation(oppId, [SELECT Id FROM Payment_Plan__c WHERE Plan_Code__c = '001' LIMIT 1].Id, [SELECT Id FROM Unit__c WHERE Unit_status__c = 'Available' LIMIT 1].Id); 
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
insert b;*/
        test.startTest();
        generateUniqueIDonAccountBooking.generateUniqueID(new List<Id> {oppId});
        test.stopTest();
        Account objAcc = [SELECT ID,Unique_Customer_ID__c FROM ACCOUNT LIMIT 1];
        Assert.areEqual('100000', objAcc.Unique_Customer_ID__c,'The Unique Customer Id must be started from 100000.');
        
    }
    
    @isTest
    public static void createBookingUniqueIdGenerateNextNumberTest(){
        
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John2';
        parentPersonAccount.LastName = 'Smith2';
        parentPersonAccount.PersonMobilePhone = '8579171112';
        parentPersonAccount.Phone = '8579171112';
        parentPersonAccount.PersonEmail = 'John2@test.com';
        parentPersonAccount.Unique_Customer_ID__c = '100000';
        insert parentPersonAccount;
        
        Id oppId = [SELECT ID FROM OPPORTUNITY LIMIT 1].Id;
        /*Quotation__c quote = createQuotation(oppId, [SELECT Id FROM Payment_Plan__c WHERE Plan_Code__c = '001' LIMIT 1].Id, [SELECT Id FROM Unit__c WHERE Unit_status__c = 'Available' LIMIT 1].Id); 
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
        insert b;*/
        
        test.startTest();
        generateUniqueIDonAccountBooking.generateUniqueID(new List<Id> {oppId});
        test.stopTest();
        
        Account objAcc = [SELECT ID,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        Assert.areEqual('100001', objAcc.Unique_Customer_ID__c,'The Unique Customer Id must be 100001 For Second Person Account.');
        
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