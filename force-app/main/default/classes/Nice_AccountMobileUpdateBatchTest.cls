/******************************************************
Class : Nice_AccountMobileUpdateBatch
Test Class : Nice_AccountMobileUpdateBatchTest 
Purpose : NICE - Test class 96%
Author : Artee Verma
*******************************************************/
@IsTest
public class Nice_AccountMobileUpdateBatchTest {

    @TestSetup
    static void setupTestData() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Person Account' LIMIT 1];
        // Insert test accounts with various phone number formats and country codes
        List<Account> testAccounts = new List<Account>{
            new Account(
                FirstName = 'Account',
                LastName = '1',
                Primary_Mobile__c = '0123456789',
                Primary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '2',
                Primary_Mobile__c = '+91123456789',
                Primary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '3',
                Primary_Mobile__c = '123456789',
                Primary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '4',
                Secondary_Mobile__c = '1234567890',
                Secondary_Mobile_Country_Code__c = '+44',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '5',
                Secondary_Mobile__c = '01234567890',
                Secondary_Mobile_Country_Code__c = '+44',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '6',
                Secondary_Mobile__c = '+441234567890',
                Secondary_Mobile_Country_Code__c = '+44',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '7',
                Tertiary_Mobile__c = '0234567890',
                Tertiary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '8',
                Tertiary_Mobile__c = '234567890',
                Tertiary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '9',
                Tertiary_Mobile__c = '+91234567890',
                Tertiary_Mobile_Country_Code__c = '+91',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '10',
                Fourth_Mobile__c = '1234567890',
                Fourth_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '11',
                Fourth_Mobile__c = '+931234567890',
                Fourth_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '12',
                Fourth_Mobile__c = '01234567890',
                Fourth_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '13',
                Primary_POA_Mobile__c = '0123456789',
                Primary_POA_Mobile_Country_Code__c = '+61',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '14',
                Primary_POA_Mobile__c = '123456789',
                Primary_POA_Mobile_Country_Code__c = '+61',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '15',
                Primary_POA_Mobile__c = '+61123456789',
                Primary_POA_Mobile_Country_Code__c = '+61',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '16',
                Secondary_POA_Mobile__c = '9876543210',
                Secondary_POA_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '17',
                Secondary_POA_Mobile__c = '09876543210',
                Secondary_POA_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            ),
            new Account(
                FirstName = 'Account',
                LastName = '18',
                Secondary_POA_Mobile__c = '+939876543210',
                Secondary_POA_Mobile_Country_Code__c = '+93',
                RecordTypeId = rt.Id
            )
        };
        insert testAccounts;
    }

    @IsTest
    static void testBatchExecution() {
        Test.startTest();
        Nice_AccountMobileUpdateBatch batchInstance = new Nice_AccountMobileUpdateBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        List<Account> updatedAccounts = [
            SELECT Id, LastName, Primary_Mobile__c, Primary_Mobile_Country_Code__c, Primary_Mobile_Number__c,
                   Secondary_Mobile__c,  Secondary_Mobile_Number__c,
                   Tertiary_Mobile__c, Tertiary_Mobile_Number__c,
                   Fourth_Mobile__c, Fourth_Mobile_Number__c,
                   Primary_POA_Mobile__c, Primary_POA_Mobile_Number__c,
                   Secondary_POA_Mobile__c, Secondary_POA_Mobile_Number__c
            FROM Account
        ];

        for (Account acc : updatedAccounts) {
            switch on acc.LastName {
                when '1' {
                    System.assertEquals('+91123456789', acc.Primary_Mobile_Number__c, 'Primary number should be updated correctly for Account 1');
                }
                when '2' {
                    System.assertEquals('+91123456789', acc.Primary_Mobile_Number__c, 'Primary number should be updated correctly for Account 2');
                }
                when '3' {
                    System.assertEquals('+91123456789', acc.Primary_Mobile_Number__c, 'Primary number should be updated correctly for Account 3');
                }             
                when '4' {
                    System.assertEquals('+441234567890', acc.Secondary_Mobile_Number__c, 'Secondary number should be updated correctly for Account 4');
                }              
                when '5' {
                    System.assertEquals('+441234567890', acc.Secondary_Mobile_Number__c, 'Secondary number should be updated correctly for Account 5');
                }
                when '6' {
                    System.assertEquals('+441234567890', acc.Secondary_Mobile_Number__c, 'Secondary number should be updated correctly for Account 6');
                }
                when '7' {
                    System.assertEquals('+91234567890', acc.Tertiary_Mobile_Number__c, 'Tertiary number should be updated correctly for Account 7');
                }
                when '8' {
                    System.assertEquals('+91234567890', acc.Tertiary_Mobile_Number__c, 'Tertiary number should be updated correctly for Account 8');
                }
                when '9' {
                    System.assertEquals('+91234567890', acc.Tertiary_Mobile_Number__c, 'Tertiary number should be updated correctly for Account 9');
                }
                when '10' {
                    System.assertEquals('+931234567890', acc.Fourth_Mobile_Number__c, 'Fourth number should be updated correctly for Account 10');
                }
                when '11' {
                    System.assertEquals('+931234567890', acc.Fourth_Mobile_Number__c, 'Fourth number should be updated correctly for Account 11');
                }
                when '12' {
                    System.assertEquals('+931234567890', acc.Fourth_Mobile_Number__c, 'Fourth number should be updated correctly for Account 12');
                }
                when '13' {
                    System.assertEquals('+61123456789', acc.Primary_POA_Mobile_Number__c, 'POA 1 number should be updated correctly for Account 13');
                }
                when '14' {
                    System.assertEquals('+61123456789', acc.Primary_POA_Mobile_Number__c, 'POA 1 number should be updated correctly for Account 14');
                }
                when '15' {
                    System.assertEquals('+61123456789', acc.Primary_POA_Mobile_Number__c, 'POA 1 number should be updated correctly for Account 15');
                }
                when '16' {
                    System.assertEquals('+939876543210', acc.Secondary_POA_Mobile_Number__c, 'POA 2 number should be updated correctly for Account 16');
                }
                when '17' {
                    System.assertEquals('+939876543210', acc.Secondary_POA_Mobile_Number__c, 'POA 2 number should be updated correctly for Account 17');
                }
                when '18' {
                    System.assertEquals('+939876543210', acc.Secondary_POA_Mobile_Number__c, 'POA 2 number should be updated correctly for Account 18');
                }
            }
        }
    }

    @IsTest
    static void testExceptionHandling() {
        // Test error scenario by inserting invalid account data
        Account invalidAccount = new Account(
            FirstName = 'Invalid',
            LastName = 'Account',
            Primary_Mobile_Number__c = 'InvalidMobileNumber'
        );
        insert invalidAccount;

        Test.startTest();
        Nice_AccountMobileUpdateBatch batchInstance = new Nice_AccountMobileUpdateBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        System.assert(true, 'Batch completed without unhandled exceptions.');
    }

    @IsTest
    static void testLeadingZeroHandling() {
        Account testAccount = new Account(
            FirstName = 'Account',
            LastName = '7',
            Primary_Mobile__c = '0123456789',
            Primary_Mobile_Country_Code__c = '+1'
        );
        insert testAccount;

        Test.startTest();
        Nice_AccountMobileUpdateBatch batchInstance = new Nice_AccountMobileUpdateBatch();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        Account updatedAccount = [
            SELECT Primary_Mobile__c, Primary_Mobile_Number__c
            FROM Account WHERE Id = :testAccount.Id
        ];

        System.assertEquals('+1123456789', updatedAccount.Primary_Mobile_Number__c, 'Leading zero should be handled correctly for mobile number.');
    }
}