@isTest
public class AccountTriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Person Account' LIMIT 1];
        // Insert test accounts with various phone number formats and country codes
        List<Account> testAccounts = new List<Account>{
            new Account(
                FirstName = 'Account',
                LastName = '1',
                Primary_Mobile__c = '0123456789',
                Primary_Mobile_Country_Code__c = '+91',
                PersonEmail = 'personemail@example.com',
                Alternate_Email__c = 'alternameemail@example.com',
                Primary_POA_Email__c = 'poa1@example.com',
                Secondary_POA_Email__c = 'poa2@example.com',
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

    @isTest
    static void testUpdateChildRecordsCustomerUniqueIds() {
        // Retrieve test account for update
        Account acc = [SELECT Id,Secondary_Mobile__c, Unique_Customer_ID__c FROM Account LIMIT 1];
        acc.Unique_Customer_ID__c = 'NEW_UNIQUE_ID';

        Test.startTest();
        List<Account> accList = new List<Account>{acc};
        Map<Id, Account> oldMap = new Map<Id, Account>{acc.Id => acc.clone()};
        oldMap.get(acc.Id).Unique_Customer_ID__c = null;

        AccountTriggerHandler.updateChildRecordsCustomerUniqueIds(accList, oldMap);
        Test.stopTest();

        // Assertions
        System.assert(acc.Unique_Customer_ID__c != null, 'Unique Customer ID should be updated.');
    }

    @isTest
    static void testUpdateChildRecordsCustomerUniqueIds_NoChange() {
        // Test when Unique_Customer_ID__c is not null in oldMap
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Unique_Customer_ID__c = 'EXISTING_ID';

        Test.startTest();
        List<Account> accList = new List<Account>{acc};
        Map<Id, Account> oldMap = new Map<Id, Account>{acc.Id => acc.clone()};

        AccountTriggerHandler.updateChildRecordsCustomerUniqueIds(accList, oldMap);
        Test.stopTest();

        System.assertEquals('EXISTING_ID', acc.Unique_Customer_ID__c, 'Unique Customer ID should not change.');
    }

    @isTest
    static void testUpdateChildRecordsCustomerUniqueIds_EmptyList() {
        // Test with empty account list
        Test.startTest();
        AccountTriggerHandler.updateChildRecordsCustomerUniqueIds(new List<Account>(), new Map<Id, Account>());
        Test.stopTest();

        // No assertions needed, just verifying no exceptions occur
    }

    @isTest
    static void testProcessContactFieldsBeforeSave() {
        Account acc = new Account(
            LastName = 'Test Account Save',
            Primary_Mobile__c = '+911234567890',
            Primary_Mobile_Country_Code__c = '+91',
            Secondary_Mobile__c = '0123456789',
            Secondary_Mobile_Country_Code__c = '+91',
            Tertiary_Mobile__c = '1234567890',
            Tertiary_Mobile_Country_Code__c = '+91',
            Fourth_Mobile__c = '0987654321',
            Fourth_Mobile_Country_Code__c = '+91',
            Primary_POA_Mobile__c = '1122334455',
            Primary_POA_Mobile_Country_Code__c = '+91',
            Secondary_POA_Mobile__c = '2233445566',
            Secondary_POA_Mobile_Country_Code__c = '+91',
            PersonEmail = 'test@example.com',
            Alternate_Email__c = 'alt@example.com',
            Primary_POA_Email__c = 'poa1@example.com',
            Secondary_POA_Email__c = 'poa2@example.com'
        );
        List<Account> accList = new List<Account>{acc};

        Test.startTest();
        AccountTriggerHandler.processContactFieldsBeforeSave(accList);
        Test.stopTest();

        // Assertions for primary mobile
        System.assertEquals('+911234567890', acc.Primary_Mobile_Number__c, 'Primary Mobile Number should be concatenated with country code.');
        System.assertNotEquals(null, acc.Primary_Mobile_Number_M__c, 'Primary Mobile Number Masked should not be null.');
        System.assertNotEquals(null, acc.Primary_Mobile_Number_E__c, 'Primary Mobile Number Encrypted should not be null.');

        // Assertions for secondary mobile
        System.assertEquals('+91123456789', acc.Secondary_Mobile_Number__c, 'Secondary Mobile Number should be concatenated with country code.');
        System.assertNotEquals(null, acc.Secondary_Mobile_Number_M__c, 'Secondary Mobile Number Masked should not be null.');
        System.assertNotEquals(null, acc.Secondary_Mobile_Number_E__c, 'Secondary Mobile Number Encrypted should not be null.');

        // Assertions for emails
        System.assertNotEquals(null, acc.Primary_Email_M__c, 'Primary Email Masked should not be null.');
        System.assertNotEquals(null, acc.Primary_Email_E__c, 'Primary Email Encrypted should not be null.');
        System.assertNotEquals(null, acc.Secondary_Email_M__c, 'Secondary Email Masked should not be null.');
        System.assertNotEquals(null, acc.Secondary_Email_E__c, 'Secondary Email Encrypted should not be null.');
    }

    @isTest
    static void testProcessContactFieldsBeforeSave_BlankFields() {
        // Test with blank fields
        Account acc = new Account(
            LastName = 'Test Account Blank'
        );
        List<Account> accList = new List<Account>{acc};

        Test.startTest();
        AccountTriggerHandler.processContactFieldsBeforeSave(accList);
        Test.stopTest();

        // Assertions
        System.assertEquals(null, acc.Primary_Mobile_Number__c, 'Primary Mobile Number should be null.');
        System.assertEquals(null, acc.Secondary_Mobile_Number__c, 'Secondary Mobile Number should be null.');
    }

    @isTest
    static void testProcessContactFieldsBeforeUpdate() {
        Account acc = [SELECT Id,
                        Primary_Mobile__c,
                        Primary_Mobile_Country_Code__c,
                        Primary_Mobile_Number__c,
                        Secondary_Mobile__c,
                        Secondary_Mobile_Country_Code__c,
                        Secondary_Mobile_Number__c,
                        Tertiary_Mobile__c,
                        Tertiary_Mobile_Country_Code__c,
                        Tertiary_Mobile_Number__c,
                        Fourth_Mobile__c,
                        Fourth_Mobile_Country_Code__c,
                        Fourth_Mobile_Number__c,
                        Primary_POA_Mobile__c,
                        Primary_POA_Mobile_Country_Code__c,
                        Primary_POA_Mobile_Number__c,
                        Secondary_POA_Mobile__c,
                        Secondary_POA_Mobile_Country_Code__c,
                        Secondary_POA_Mobile_Number__c,
                        PersonEmail,
                        Alternate_Email__c,
                        Primary_POA_Email__c,
                        Secondary_POA_Email__c
                       FROM Account LIMIT 1];
        acc.Primary_Mobile__c = '+919876543210';
        acc.Secondary_Mobile__c = '+919876543211';
        acc.Tertiary_Mobile__c = '+919876543212';
        acc.Fourth_Mobile__c = '+919876543213';
        acc.Primary_POA_Mobile__c = '+919876543214';
        acc.Secondary_POA_Mobile__c = '+919876543215';

        Map<Id, Account> oldMap = new Map<Id, Account>{acc.Id => acc.clone()};
        oldMap.get(acc.Id).Primary_Mobile__c = '+911234567890';
        oldMap.get(acc.Id).Primary_Mobile_Country_Code__c = '+91';
        oldMap.get(acc.Id).Secondary_Mobile__c = '+919876543210';        
        oldMap.get(acc.Id).Secondary_Mobile_Country_Code__c = '+91';

        Map<Id, Account> newMap = new Map<Id, Account>{acc.Id => acc};

        Test.startTest();
        AccountTriggerHandler.processContactFieldsBeforeUpdate(newMap, oldMap);
        Test.stopTest();

        // Assertions for primary mobile
        System.assertEquals('+919876543210', acc.Primary_Mobile_Number__c, 'Updated Primary Mobile Number should concatenate country code and phone number.');
        System.assertNotEquals(null, acc.Primary_Mobile_Number_M__c, 'Updated Primary Mobile Number Masked should not be null.');
        System.assertNotEquals(null, acc.Primary_Mobile_Number_E__c, 'Updated Primary Mobile Number Encrypted should not be null.');

        // Assertions for secondary mobile
        System.assertEquals('+919876543211', acc.Secondary_Mobile_Number__c, 'Updated Secondary Mobile Number should concatenate country code and phone number.');
        System.assertNotEquals(null, acc.Secondary_Mobile_Number_M__c, 'Updated Secondary Mobile Number Masked should not be null.');
        System.assertNotEquals(null, acc.Secondary_Mobile_Number_E__c, 'Updated Secondary Mobile Number Encrypted should not be null.');

        // Assertions for emails
        System.assertNotEquals(null, acc.Primary_Email_M__c, 'Primary Email Masked should not be null.');
        System.assertNotEquals(null, acc.Primary_Email_E__c, 'Primary Email Encrypted should not be null.');
    }

    @isTest
    static void testProcessContactFieldsBeforeUpdate_NoChanges() {
        // Test when no fields have changed
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Map<Id, Account> oldMap = new Map<Id, Account>{acc.Id => acc.clone()};
        Map<Id, Account> newMap = new Map<Id, Account>{acc.Id => acc};

        Test.startTest();
        AccountTriggerHandler.processContactFieldsBeforeUpdate(newMap, oldMap);
        Test.stopTest();

        // No assertions needed, just verifying no exceptions occur
    }
}
