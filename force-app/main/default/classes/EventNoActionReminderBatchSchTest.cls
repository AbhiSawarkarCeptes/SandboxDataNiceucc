@isTest
public class EventNoActionReminderBatchSchTest {
    public static testMethod void testschedule() {
        Profile userProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User 
                            WHERE Profile.Name = 'System Administrator' AND 
                                UserRoleId != null AND 
                                isActive = true LIMIT 1];
        // Create related objects
        Account testAccount = new Account(Name = 'Test Account', OwnerId = adminUser.Id);
        insert testAccount;
        // Create test Contact
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',
                                            AccountId=testAccount.Id);
        insert testContact;
        System.runAs(adminUser) {
            // Create a test User linked to the test Contact and assign the Role
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@example.com',
                Username = 'testuser' + DateTime.now().getTime() + '@example.com',
                Alias = 'tuser',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = userProfile.Id,
                LanguageLocaleKey = 'en_US',
                ContactId = testContact.Id,
                isActive=true,
                managerId = adminUser.id
            );
            insert testUser;
            
        User salesManager = [SELECT Id FROM User LIMIT 1];
        // Create Sales Director User
        User salesDirector = [SELECT Id FROM User LIMIT 1];
        // Create a test Event
        Events__c testEvent = new Events__c(
            Name = 'Test Event',
            Collateral_Uploaded__c = false,
            Campaign_Leads__c = 10,
            Campaign_Lead_7_days_before_event__c = 7,
            Sales_Manager__c = salesManager.Id,
            Sales_Director__c = salesDirector.Id,
            Total_Purchase_Price__c = 10000,
            Expected_number_of_Visitors__c = 100,
            city_country__c = 'Test City country',
            Confirmed_No_of_Meeting__c = 5,
            Country__c = 'Test Country',
            Date_Of_Event__c = Date.today() + 31,
            End_Date_Of_Event__c = Date.today().addDays(32),
            Visit_numbers__c = 50,
            Event_Sales_Value__c = 5000,
            From_Broker_Portal__c = true,
            No_Action_Notify__c = false,
            Channel_Relationship_Manager__c = testuser.id,
            Event_Approved_status__c = '',
            recordTypeId = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId()
        );
        insert testEvent;
        }
        // Create Sales Manager User
        Test.startTest();
        EventNoActionReminderBatchSchedule testsche = new EventNoActionReminderBatchSchedule();
        String sch = '0 0 0 * * ?';
        system.schedule('Test status', sch, testsche);
        Test.stopTest();
    }
}