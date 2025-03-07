@isTest 
public class AccountMasterTest {
    
    @isTest static void test1(){
        Test.startTest();
        Account_Master__c am = new Account_Master__c();
        am.Name = 'TRADE RECEIVABLE';
        am.Account_Number__c = '1234';
        am.Type__c = 'Others';
        insert am;
        
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'TRADE RECEIVABLE';
        am2.Account_Number__c = '1234';
        am2.Type__c = 'Others';
        insert am2;
        
        am.Account_Number__c = '12345';
        update am;
        
        Test.stopTest();
    }
    
}