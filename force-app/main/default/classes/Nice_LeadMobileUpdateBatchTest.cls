/*******************************************
Class : Nice_LeadMobileUpdateBatch
Test class: Nice_LeadMobileUpdateBatchTest
covers : 96%
Author : Artee Varma
********************************************/
@isTest
public class Nice_LeadMobileUpdateBatchTest {
   @isTest
    static void testBatchProcess() {
        // Create test data with numbers containing '+'
        List<Lead> leads = new List<Lead>{ 
            new Lead(
                FirstName = 'Shock',
                LastName = 'Wave',
                MobilePhone = '5551234567',
                Primary_Mobile_Country_Code__c = '+91',
                Primary_Mobile__c = '+915551234567',
                Secondary_Mobile_Country_Code__c = '+91',
                Secondary_Mobile__c = '+917890123456'
            ),
                new Lead(
                    FirstName = 'Shock',
                    LastName = 'Wave1',
                    MobilePhone = '5551234567',
                    Primary_Mobile_Country_Code__c = '+91',
                    Primary_Mobile__c = '09876543210',
                    Secondary_Mobile_Country_Code__c = '+91',
                    Secondary_Mobile__c = '06677889900'
                ),
                new Lead(
                    FirstName = 'Shock',
                    LastName = 'Wave2',
                    MobilePhone = '5551234567',
                    Primary_Mobile_Country_Code__c = '+91',
                    Primary_Mobile__c = '+915551234567',
                    Secondary_Mobile_Country_Code__c = '+91',
                    Secondary_Mobile__c = '+917890123456'
                ),
                new Lead(
                    FirstName = 'Shock',
                    LastName = 'Wave3',
                    MobilePhone = '5551234567',
                    Primary_Mobile_Country_Code__c = '+91',
                    Primary_Mobile__c = '9876543210',
                    Secondary_Mobile_Country_Code__c = '+91',
                    Secondary_Mobile__c = '6677889900'
                )
        };
        
        insert leads;
        
        // Start the batch process
        Test.startTest();
        
        Nice_LeadMobileUpdateBatch batch = new Nice_LeadMobileUpdateBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Verify results
        List<Lead> updatedLeads = [SELECT Id, 
                Primary_Mobile__c,
            	MobilePhone,
            	Primary_Mobile_Country_Code__c,
                Primary_Mobile_Number__c,
                Secondary_Mobile__c, 
            	Secondary_Mobile_Country_Code__c,
            	Secondary_Mobile_Number__c            
            FROM Lead];
        
        // Check that the Mobile_Country_Code__c and Telephone_Country_Code__c are updated correctly
        for (Lead l : updatedLeads) {
            // Case when primary mobile number starts with '+'
            if (l.Primary_Mobile__c != null && l.Primary_Mobile__c.startsWith('+')) {
                System.assertEquals('+91', l.Primary_Mobile_Country_Code__c);
                System.assertEquals('+915551234567', l.Primary_Mobile_Number__c);
            }
            // Case when primary mobile number does not start with '+'
            if (l.Primary_Mobile__c != null && !l.Primary_Mobile__c.startsWith('+')) {
                System.assertEquals('+91', l.Primary_Mobile_Country_Code__c);
                System.assertEquals('+919876543210', l.Primary_Mobile_Number__c);
            }
            // Case when primary mobile number starts with '0'
            if (l.Primary_Mobile__c != null && l.Primary_Mobile__c.startsWith('0')) {
                System.assertEquals('+91', l.Primary_Mobile_Country_Code__c);
                System.assertEquals('+919876543210', l.Primary_Mobile_Number__c);
            }
            // Case when secondary mobile number starts with '+'
            if (l.Secondary_Mobile__c != null && l.Secondary_Mobile__c.startsWith('+')) {
                System.assertEquals('+91', l.Secondary_Mobile_Country_Code__c);
                System.assertEquals('+917890123456', l.Secondary_Mobile_Number__c);
            }
            // Case when secondary number does not start with '+'
            if (l.Secondary_Mobile__c != null && !l.Secondary_Mobile__c.startsWith('+')) {
                System.assertEquals('+91', l.Secondary_Mobile_Country_Code__c);
                System.assertEquals('+916677889900', l.Secondary_Mobile_Number__c);
            }
            // Case when secondary number does starts with '0'
            if (l.Secondary_Mobile__c != null && l.Secondary_Mobile__c.startsWith('0')) {
                System.assertEquals('+91', l.Secondary_Mobile_Country_Code__c);
                System.assertEquals('+916677889900', l.Secondary_Mobile_Number__c);
            }
        }
    }
}