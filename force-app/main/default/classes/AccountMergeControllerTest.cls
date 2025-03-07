@isTest
public class AccountMergeControllerTest {
    
    @testsetup
    public static void createData() {
        
        Account parentPersonAccount = new Account();
        parentPersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        parentPersonAccount.FirstName = 'John';
        parentPersonAccount.LastName = 'Smith';
        parentPersonAccount.PersonMobilePhone = '8579171110';
        parentPersonAccount.Phone = '8579171110';
        parentPersonAccount.PersonEmail = 'John@test.com';
        parentPersonAccount.Unique_Customer_ID__c = '1254';
        parentPersonAccount.Unique_Customer_External_ID__c = '1254';
        insert parentPersonAccount;
        
        Account duplicatePersonAccount = new Account();
        duplicatePersonAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        duplicatePersonAccount.FirstName = 'Tesla';
        duplicatePersonAccount.LastName = 'Test';
        duplicatePersonAccount.PersonMobilePhone = '8579173333';
        duplicatePersonAccount.Phone = '3857914444';
        duplicatePersonAccount.PersonEmail = 'John@test.com';
        duplicatePersonAccount.Unique_Customer_External_ID__c = '1254';
        duplicatePersonAccount.Unique_Customer_ID__c = '1250';
        insert duplicatePersonAccount;
        
    }
    
    public testmethod static void getDuplicatePersonAccount(){
        String accountId = [SELECT ID FROM ACCOUNT LIMIT 1].ID;
        
        Test.startTest();
        String result = AccountMergeController.getDuplicates(accountId);
        Test.stopTest();
        
        Assert.isTrue(!String.isEmpty(result));
    }
    
    public testmethod static void mergePersonAccount(){
        
        String accountId = [SELECT ID FROM ACCOUNT LIMIT 1].ID;
        String result = AccountMergeController.getDuplicates(accountId); 
        
        Account masterAccount = [SELECT ID,FIRSTNAME,LASTNAME,PHONE 
                                 FROM ACCOUNT 
                                 WHERE Unique_Customer_ID__c = '1254'];
        
        JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeStringField('First Name', masterAccount.FirstName );
        g.writeStringField('Last Name', masterAccount.LastName );
        g.writeStringField('Mobile', masterAccount.Phone );
        g.writeEndObject();
        
        Test.startTest();
        AccountMergeController.mergeRecord(g.getAsString(),result);
        Test.stopTest();
        
        Assert.areEqual(1,[SELECT Id FROM Account].size(),'The Account count must be 1.');
        
    }
    
    
}