@IsTest
public class GenerateUniqueIDonAccountTest {
    
    @testSetup
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
    public static void generateUniqueIdOnNewSaleApprovalTest() {
        Id oppId = [SELECT ID FROM OPPORTUNITY LIMIT 1].Id;
        unit_hold_request__c objNewSalesApproval = [SELECT ID,Approval_Status__c FROM unit_hold_request__c LIMIT 1];
        objNewSalesApproval.Approval_Status__c = 'Approved';
        
        Test.startTest();
        generateUniqueIDonAccount.generateUniqueID(new List<Id> {oppId});
        	//update objNewSalesApproval;
        Test.stopTest();
        
        Account objAcc = [SELECT ID,Unique_Customer_ID__c FROM ACCOUNT LIMIT 1];
        Assert.areEqual('100000', objAcc.Unique_Customer_ID__c,'The Unique Customer Id must be started from 100000.');
        
    }
    
     @isTest
    public static void generateUniqueIdOnNewSaleApprovalForSecondPersonAccountTest() {
         Id oppId = [SELECT ID FROM OPPORTUNITY LIMIT 1].Id;
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John2';
        parentPersonAccount.LastName = 'Smith2';
        parentPersonAccount.PersonMobilePhone = '8579171112';
        parentPersonAccount.Phone = '8579171112';
        parentPersonAccount.PersonEmail = 'John2@test.com';
         parentPersonAccount.Unique_Customer_ID__c = '100000';
        insert parentPersonAccount;
        
        unit_hold_request__c objNewSalesApproval = [SELECT ID,Approval_Status__c FROM unit_hold_request__c LIMIT 1];
        objNewSalesApproval.Approval_Status__c = 'Approved';
        
        Test.startTest();
        generateUniqueIDonAccount.generateUniqueID(new List<Id> {oppId});
        //update objNewSalesApproval;
        Test.stopTest();
        
        Account objAcc = [SELECT ID,Unique_Customer_ID__c FROM ACCOUNT WHERE PersonEmail = 'John@test.com'];
        Assert.areEqual('100001', objAcc.Unique_Customer_ID__c,'The Unique Customer Id must be 100001 For Second Person Account.');
    }
    
}