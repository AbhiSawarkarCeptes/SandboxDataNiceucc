@isTest
public class niceClickToViewControllerTest {

    // Create a test record for the object that will be queried
    @testSetup
    private static void setUpClickToView(){
        
        Account acc = new Account(
            Name = 'Test Acc',
            recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId(),
            Email__c = 'ashok.kumar@ceptes.onmicrosoft.com',
            Broker_Sub_Type__c = 'Broker UAE',
            Tertiary_Mobile__c = '+918838391999',
            Phone__c = '8838391999'
        );
        insert acc;
    }

    // Call the method to test
    @isTest
    static void testGetPhoneFieldsValueToClickToView() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Map<String, String>> phoneFields = niceClickToViewController.getPhoneFieldsValueToClickToView(acc.Id);
        Test.stopTest();

        // Assert the results
        System.assertNotEquals(null, phoneFields, 'Phone fields should not be null');
        System.assert(phoneFields.size() > 0, 'Phone fields should contain data');
        
        // Additional assertions can be added here to check specific field values
        System.assertEquals('8838391999', phoneFields[0].get('value'), 'The phone number should match the test data');

        // Check for tertiary mobile number
        System.assertEquals('+918838391999', phoneFields[1].get('value'), 'The tertiary mobile number should match the test data');
    }
}