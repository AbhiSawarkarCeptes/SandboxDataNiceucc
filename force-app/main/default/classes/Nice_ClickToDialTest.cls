/***************************************************************************
Class Name     : Nice_ClickToDialTest
Covers         : Nice_ClickToDialUtility
Author         : Ashok Kumar M
*****************************************************************************/
@isTest
public class Nice_ClickToDialTest {
    
    @testSetup
    private static void setUp() {
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email__c = 'ashok.kumar@ceptes.onmicrosoft.com';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Tertiary_Mobile__c = '+918838391999';
        acc.Phone__c = '8838391999';
        insert acc;
        
    }
    
    @isTest
    private static void testgetPhoneFieldsFromCmdt() {
        
        test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Map<String, String>> res = Nice_ClickToDialUtility.getPhoneFields(acc.Id);
        List<Map<String, String>> resctv = Nice_ClickToDialUtility.getPhoneFieldsValueToClickToView(acc.Id);
        Assert.isNotNull(res);
        test.stopTest();
        
    }
    
    @isTest
    private static void testWithInvalidId(){
        
        try {
            List<Map<String, String>> res = Nice_ClickToDialUtility.getPhoneFields('Invalid');
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage());
        }
        
    }
    
    @isTest
    private static void testWithInvalidIdClickToView(){
        
        try {
            List<Map<String, String>> res = Nice_ClickToDialUtility.getPhoneFieldsValueToClickToView('Invalid');
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage());
        }
        
    }
    
}