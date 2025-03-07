@isTest
private class ChannelPartnerTriggerTest {

    @testSetup
    private static void setupData() {
        // Create setup records, like UserRole
        UserRole role = new UserRole(Name = 'Test Role');
        insert role;

        // Create Profile record if needed
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

         User testUser3 = new User(
            Username = 'testuser3_' + Math.random() + '@example.com',
            Email = 'testuser3@example.com',
            Alias = 'tuser3',
            ProfileId = profile.Id,
            UserRoleId = role.Id,
            IsActive = true,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LastName = 'Test'
        );
        insert testUser3;
        // Create test users with unique usernames
        User testUser1 = new User(
            Username = 'testuser1_' + Math.random() + '@example.com',
            Email = 'testuser1@example.com',
            Alias = 'tuser1',
            ProfileId = profile.Id,
            UserRoleId = role.Id,
            IsActive = true,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LastName = 'Test',
            ManagerId=testUser3.Id
        );
        insert testUser1;

        User testUser2 = new User(
            Username = 'testuser2_' + Math.random() + '@example.com',
            Email = 'testuser2@example.com',
            Alias = 'tuser2',
            ProfileId = profile.Id,
            UserRoleId = role.Id,
            IsActive = true,
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LastName = 'Test',
            ManagerId=testUser3.id
        );
        insert testUser2;
    }

    @isTest
    private static void testChannelPartnerTrigger() {
        // Retrieve test users created in the @testSetup method
        User testUser1 = [SELECT Id,ManagerId FROM User WHERE Username LIKE 'testuser1_%' LIMIT 1];
        User testUser2 = [SELECT Id,ManagerId FROM User WHERE Username LIKE 'testuser2_%' LIMIT 1];

        // Create a Channel Partner record using test users
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name = 'Test CP';
        cp.Sales_Manager__c = testUser1.Id;
        cp.Contact_Person__c = 'Test Contact Person';
        cp.Channel_Relationship_Manager__c = testUser1.Id;
        cp.Sales_Manager_s_Line_Manager__c = testUser1.ManagerId;
        cp.Channel_Relationship_Head__c = testUser1.ManagerId;
        cp.Mobile_No__c = '1334244555';
        cp.Is_Active__c = true;
        cp.Approval_Status__c = 'Approved';
        cp.OwnerId = testUser1.Id;
        
        Test.startTest();
        insert cp;
        
        // Perform update operation
            Channel_Partner__c cp1 = [SELECT Id, Sales_Manager__c FROM Channel_Partner__c WHERE Id = :cp.Id LIMIT 1];
            cp1.Sales_Manager__c = testUser2.ManagerId;
            update cp1;
        Test.stopTest();
    }
}