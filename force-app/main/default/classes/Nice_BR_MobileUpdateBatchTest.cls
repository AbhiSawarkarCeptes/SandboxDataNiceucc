/*******************************************
Class  : Nice_BR_MobileUpdateBatch
Test Class  : Nice_BR_MobileUpdateBatchTest
covers : 93%
Author : Artee Varma
********************************************/

@isTest
private class Nice_BR_MobileUpdateBatchTest {
    @isTest
    static void testBatchProcess() {
        // Create test data with numbers containing '+'
        List<Broker_Registration__c> brokerRegistrations = new List<Broker_Registration__c>();
        
        // Broker Registration with Mobile and Telephone number with "+" sign
        brokerRegistrations.add(new Broker_Registration__c(
            Mobile_Country_Code__c = '+91',
            Mobile__c = '+915551234567',
            Telephone_Country_Code__c = '+91',
            Telephone__c = '+917890123456',
            Broker_Category__c = 'Broker - RERA',
            Email__c = 'abc@abc.com'
        ));
        
        // Broker Registration with Mobile and Telephone number without "+" sign
        brokerRegistrations.add(new Broker_Registration__c(
            Mobile_Country_Code__c = '+91',
            Mobile__c = '5551234567',
            Telephone_Country_Code__c = '+91',
            Telephone__c = '7890123456',
            Broker_Category__c = 'Broker - RERA',
            Email__c = 'abc1@abc.com'
        ));
        
        // Broker Registration with Mobile and Telephone number with "0" sign
        brokerRegistrations.add(new Broker_Registration__c(
            Mobile_Country_Code__c = '+91',
            Mobile__c = '05551234567',
            Telephone_Country_Code__c = '+91',
            Telephone__c = '07890123456',
            Broker_Category__c = 'Broker - RERA',
            Email__c = 'abc1@abc.com'
        ));
        
        insert brokerRegistrations;
        
        // Start the batch process
        Test.startTest();
        
        Nice_BR_MobileUpdateBatch batch = new Nice_BR_MobileUpdateBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify results
        List<Broker_Registration__c> updatedBrokerRegistrations = [SELECT Mobile_Country_Code__c, Primary_Mobile_Number__c, Telephone_Country_Code__c, Secondary_Mobile_Number__c,Mobile__c,Telephone__c FROM Broker_Registration__c];
        
        // Check that the Mobile_Country_Code__c and Telephone_Country_Code__c are updated correctly
        for (Broker_Registration__c br : updatedBrokerRegistrations) {
            if (br.Mobile__c != null && br.Mobile__c.startsWith('+')) {
                System.assertEquals('+91', br.Mobile_Country_Code__c);
                System.assertEquals('+915551234567', br.Primary_Mobile_Number__c);
            }
            if (br.Telephone__c != null && br.Telephone__c.startsWith('+')) {
                System.assertEquals('+91', br.Telephone_Country_Code__c);
                System.assertEquals('+917890123456', br.Secondary_Mobile_Number__c);
            }
            
            // Case when mobile number does not start with '+'
            if (br.Mobile__c != null && !br.Mobile__c.startsWith('+')) {
                System.assertEquals('+91', br.Mobile_Country_Code__c);
                System.assertEquals('+915551234567', br.Primary_Mobile_Number__c);
            }
            
            // Case when telephone number does not start with '+'
            if (br.Telephone__c != null && !br.Telephone__c.startsWith('+')) {
                System.assertEquals('+91', br.Telephone_Country_Code__c);
                System.assertEquals('+917890123456', br.Secondary_Mobile_Number__c);
            }
            // Case when mobile number does not start with '0'
            if (br.Mobile__c != null && !br.Mobile__c.startsWith('0')) {
                System.assertEquals('+91', br.Mobile_Country_Code__c);
                System.assertEquals('+915551234567', br.Primary_Mobile_Number__c);
            }
            
            // Case when telephone number does not start with '0'
            if (br.Telephone__c != null && !br.Telephone__c.startsWith('0')) {
                System.assertEquals('+91', br.Telephone_Country_Code__c);
                System.assertEquals('+917890123456', br.Secondary_Mobile_Number__c);
            }
        }
    }
}