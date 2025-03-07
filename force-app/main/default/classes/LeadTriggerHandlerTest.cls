@isTest
public class LeadTriggerHandlerTest {

    // Helper method to create test Project records
    private static void createTestProjects() {
        List<Project__c> projects = new List<Project__c>();
        projects.add(new Project__c(
            Name = 'Test Project 1', 
            PossessionRequirement__c = 'Immediate',
            Project_Code__c = '101',
            Configuration__c = '2BHK', 
            Max_Budget__c = 100.0, 
            Min_Budget__c = 50.0
        ));
        insert projects;
    }

    @isTest
    static void testFormatNumber() {
        // Test standard number formatting
        String result = LeadTriggerHandler.formatNumber('+91', '0123456789');
        System.assertEquals('+91123456789', result, 'Number formatting did not work as expected.');
        
        // Test with special characters
        result = LeadTriggerHandler.formatNumber('+91', '(012) 345-6789');
        System.assertEquals('+91123456789', result, 'Number formatting with special characters failed');
        
        // Test with empty country code
        result = LeadTriggerHandler.formatNumber('', '0123456789');
        System.assertEquals('0123456789', result, 'Number formatting with empty country code failed');
        
        // Test with empty number
        result = LeadTriggerHandler.formatNumber('+91', '');
        System.assertEquals('', result, 'Number formatting with empty number failed');
        
        // Test with null values
        result = LeadTriggerHandler.formatNumber(null, null);
        System.assertEquals(null, result, 'Number formatting with null values failed');
        
        // Test with international number format
        result = LeadTriggerHandler.formatNumber('+1', '6505551234');
        System.assertEquals('+16505551234', result, 'International number formatting failed');
        
        // Test with leading zeros
        result = LeadTriggerHandler.formatNumber('+91', '0012345678');
        System.assertEquals('+9112345678', result, 'Number formatting with leading zeros failed');
        
        // Test with multiple special characters
        result = LeadTriggerHandler.formatNumber('+91', '+91-(012)-345-6789');
        System.assertEquals('+91123456789', result, 'Number formatting with multiple special characters failed');
    }

    @isTest
    static void testFormatMobilePhone() {
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0123456789',
            Phone = '0987654321'
        );
        lead = LeadTriggerHandler.formatMobilePhone(lead);

        System.assertEquals('+91123456789', lead.MobilePhone, 'Mobile phone formatting is incorrect.');
        System.assertEquals('+91987654321', lead.Phone, 'Phone formatting is incorrect.');
        System.assert(lead.Mobile_Number_Formatted__c, 'Mobile number formatted flag not set.');
        System.assert(lead.Phone_Number_Formatted__c, 'Phone number formatted flag not set.');
    }

    @isTest
    static void testBeforeInsert() {
        createTestProjects();
        Lead lead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0987654321',
            Phone = '0123456789',
            Project__c = [SELECT Id FROM Project__c LIMIT 1].Id,
            Possession_Requirement__c = 'Immediate',
            RDS_Unit_type_configuration__c = '2BHK',
            Budget_In_lacs_Number__c = 75.0
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead insertedLead = [SELECT Id, MobilePhone, Phone, Lead_Score_Text__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('+91987654321', insertedLead.MobilePhone, 'Mobile phone formatting failed.');
        System.assertEquals('+91123456789', insertedLead.Phone, 'Phone formatting failed.');
        System.assertEquals(3, insertedLead.Lead_Score_Text__c, 'Lead score calculation failed.');
    }

    @isTest
    static void testBeforeUpdate() {
        createTestProjects();
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0987654321',
            Phone = '0123456789',
            Project__c = [SELECT Id FROM Project__c LIMIT 1].Id,
            Possession_Requirement__c = 'Immediate',
            RDS_Unit_type_configuration__c = '2BHK',
            Budget_In_lacs_Number__c = 75.0
        );
        insert lead;

        Test.startTest();
        lead.MobilePhone = '0123456789';
        lead.Phone = '0987654321';
        update lead;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, MobilePhone, Phone FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('+910123456789', updatedLead.MobilePhone, 'Mobile phone formatting failed on update.');
        System.assertEquals('+910987654321', updatedLead.Phone, 'Phone formatting failed on update.');
    }

    @isTest
    static void testAfterInsert() {
        // Test basic insert
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0987654321',
            Phone = '0123456789',
            Email = 'test@test.com',
            UTM_Campaign__c = 'Test Campaign'
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead insertedLead = [SELECT Id FROM Lead WHERE Id = :lead.Id];
        System.assertNotEquals(null, insertedLead, 'Lead was not inserted successfully.');
        
        // Test with multiple campaigns
        Lead lead2 = new Lead(
            LastName = 'Test2',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0987654321',
            Phone = '0123456789',
            Email = 'test2@test.com',
            UTM_Campaign__c = 'Test Campaign2',
            Landing_Page_URL__c = 'https://test.com'
        );
        insert lead2;
        
        // Test with null values
        Lead lead3 = new Lead(
            LastName = 'Test3',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            MobilePhone = '0987654321',
            Phone = '0123456789',
            Email = null,
            UTM_Campaign__c = null
        );
        insert lead3;
    }

    @isTest
    static void testErrorHandling() {
        Test.startTest();
        try {
            Lead lead = new Lead(
                LastName = 'Error Test',
                Company = 'Test Company',
                MobilePhone = 'InvalidPhone!@#'
            );
            insert lead;
            System.assert(false, 'Expected exception was not thrown.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null.');
        }
        
        // Test error logging with invalid project reference
        try {
            Lead lead = new Lead(
                LastName = 'Error Test',
                Company = 'Test Company',
                Project__c = '001000000000000',
                Possession_Requirement__c = 'Invalid'
            );
            insert lead;
            System.assert(false, 'Expected exception was not thrown.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null.');
        }
        
        // Test error in duplicate handling
        try {
            Lead lead1 = new Lead(
                LastName = 'Duplicate Test',
                Company = 'Test Company',
                Email = 'test@test.com'
            );
            insert lead1;
            
            Lead lead2 = new Lead(
                LastName = 'Duplicate Test',
                Company = 'Test Company',
                Email = 'test@test.com'
            );
            insert lead2;
            System.assert(false, 'Expected duplicate exception was not thrown.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null.');
        }
        
        // Test error in email validation
        try {
            Lead lead = new Lead(
                LastName = 'Email Test',
                Company = 'Test Company',
                Email = 'invalid-email'
            );
            insert lead;
            System.assert(false, 'Expected email validation exception was not thrown.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null.');
        }
        
        // Test error in budget validation
        try {
            Lead lead = new Lead(
                LastName = 'Budget Test',
                Company = 'Test Company',
                Budget_In_lacs_Number__c = -100
            );
            insert lead;
            System.assert(false, 'Expected budget validation exception was not thrown.');
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null.');
        }
        Test.stopTest();
    }

    @isTest
    static void testProcessLeadFieldsBeforeSave() {
        // Test with complete data
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            Primary_Mobile__c = '0987654321',
            Secondary_Mobile__c = '0123456789',
            Email = 'test@test.com',
            RDS_Alternate_Email_Id__c = 'test2@test.com'
        );

        Test.startTest();
        LeadTriggerHandler.processLeadFieldsBeforeSave(new List<Lead>{lead});
        Test.stopTest();

        System.assertEquals('+910987654321', lead.Primary_Mobile_Number__c, 'Primary mobile number formatting failed.');
        System.assertEquals('+910123456789', lead.Secondary_Mobile_Number__c, 'Secondary mobile number formatting failed.');
        System.assertNotEquals(null, lead.Primary_Email_E__c, 'Primary email encryption failed.');
        System.assertNotEquals(null, lead.Alternate_Email_Id_E__c, 'Alternate email encryption failed.');

        // Test with null values
        Lead lead2 = new Lead(
            LastName = 'Test Null',
            Company = 'Test Company',
            RDS_Country_Code__c = null,
            Primary_Mobile__c = null,
            Secondary_Mobile__c = null,
            Email = null,
            RDS_Alternate_Email_Id__c = null
        );

        LeadTriggerHandler.processLeadFieldsBeforeSave(new List<Lead>{lead2});
        System.assertEquals(null, lead2.Primary_Mobile_Number__c, 'Null primary mobile number should remain null');
        System.assertEquals(null, lead2.Secondary_Mobile_Number__c, 'Null secondary mobile number should remain null');
        System.assertEquals(null, lead2.Primary_Email_E__c, 'Null email should remain null');
        System.assertEquals(null, lead2.Alternate_Email_Id_E__c, 'Null alternate email should remain null');

        // Test with invalid phone numbers
        Lead lead3 = new Lead(
            LastName = 'Test Invalid',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            Primary_Mobile__c = 'invalid',
            Secondary_Mobile__c = 'invalid'
        );

        LeadTriggerHandler.processLeadFieldsBeforeSave(new List<Lead>{lead3});
        System.assertNotEquals('invalid', lead3.Primary_Mobile_Number__c, 'Invalid primary mobile number should be formatted');
        System.assertNotEquals('invalid', lead3.Secondary_Mobile_Number__c, 'Invalid secondary mobile number should be formatted');
    }

    @isTest
    static void testProcessLeadFieldsBeforeUpdate() {
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            RDS_Country_Code__c = '+91',
            Primary_Mobile__c = '0987654321',
            Secondary_Mobile__c = '0123456789',
            Email = 'test@test.com',
            RDS_Alternate_Email_Id__c = 'test2@test.com'
        );
        insert lead;

        Test.startTest();
        lead.Primary_Mobile__c = '0123456789';
        lead.Secondary_Mobile__c = '0987654321';
        lead.Email = 'test3@test.com';
        lead.RDS_Alternate_Email_Id__c = 'test4@test.com';
        LeadTriggerHandler.processLeadFieldsBeforeUpdate(new Map<Id, Lead>{lead.Id => lead}, new Map<Id, Lead>{lead.Id => lead});
        Test.stopTest();

        Lead updatedLead = [SELECT Id, Primary_Mobile_Number__c, Secondary_Mobile_Number__c, Primary_Email_E__c, Alternate_Email_Id_E__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('+910123456789', updatedLead.Primary_Mobile_Number__c, 'Primary mobile number formatting failed on update.');
        System.assertEquals('+910987654321', updatedLead.Secondary_Mobile_Number__c, 'Secondary mobile number formatting failed on update.');
        System.assertNotEquals(null, updatedLead.Primary_Email_E__c, 'Primary email encryption failed on update.');
        System.assertNotEquals(null, updatedLead.Alternate_Email_Id_E__c, 'Alternate email encryption failed on update.');
    }

    @isTest
    static void testCreateDayAndAttemptTracking() {
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            Email = 'test@test.com',
            OwnerId = UserInfo.getUserId()
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        List<Day_Tracking__c> dayTracking = [SELECT Id FROM Day_Tracking__c WHERE Lead__c = :lead.Id];
        System.assertEquals(1, dayTracking.size(), 'Day tracking record was not created');
        
        List<Attempt_Tracking__c> attemptTracking = [SELECT Id FROM Attempt_Tracking__c WHERE Day_Tracking__c = :dayTracking[0].Id];
        System.assertEquals(1, attemptTracking.size(), 'Attempt tracking record was not created');
    }

    @isTest
    static void testAfterUpdateEmailSending() {
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            Email = 'test@test.com',
            Send_Roadshow_Notification__c = false
        );
        insert lead;

        Test.startTest();
        lead.Send_Roadshow_Notification__c = true;
        update lead;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, Email_Log__c FROM Lead WHERE Id = :lead.Id];
        System.assert(updatedLead.Email_Log__c.contains('Email Sent At'), 'Email log was not updated');
    }
}
