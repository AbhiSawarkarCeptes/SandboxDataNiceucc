@isTest
public class salesMeetingTrackerTrigger_Test {
    
    @testSetup
    static void setupTestData() {
        // Create roles
        UserRole salesManagerRole = new UserRole(Name='Sales Manager');
        UserRole salesHeadRole = new UserRole(Name='Sales Head');
        UserRole vicePresidentRole = new UserRole(Name='Vice President');
        UserRole seniorVicePresidentRole = new UserRole(Name='Senior Vice President');
        UserRole chiefSalesOfficerRole = new UserRole(Name='Chief Sales Officer');
        
        insert new List<UserRole> { salesManagerRole, salesHeadRole, vicePresidentRole, seniorVicePresidentRole, chiefSalesOfficerRole };
            
            // Create users
            User chiefSalesOfficerUser = new User(
                FirstName='Chief',
                LastName='Sales Officer',
                Email='cso@erw.com',
                Username='cso@erw.com',
                Alias='CSO',
                CommunityNickname='CSO',
                ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                UserRoleId=chiefSalesOfficerRole.Id,
                ManagerId=null,
                TimeZoneSidKey='America/New_York',
                LocaleSidKey='en_US',
                EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US',
                IsActive=true
            );
		insert chiefSalesOfficerUser;
        
        User seniorVicePresidentUser = new User(
            FirstName='Senior',
            LastName='Vice President',
            Email='seniorvp@rty.com',
            Username='seniorvp@rty.com',
            Alias='SVP',
            CommunityNickname='SVP',
            ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            UserRoleId=seniorVicePresidentRole.Id,
            ManagerId=chiefSalesOfficerUser.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            IsActive=true
        );
        insert seniorVicePresidentUser;
        
        
        
        User vicePresidentUser = new User(
            FirstName='Vice',
            LastName='President',
            Email='vicepresident@tyu.com',
            Username='vicepresident@tyu.com',
            Alias='VPres',
            CommunityNickname='VPres',
            ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            UserRoleId=vicePresidentRole.Id,
            ManagerId=seniorVicePresidentUser.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            IsActive=true
        );
         insert vicePresidentUser;
        
        
        User salesHeadUser = new User(
            FirstName='Sales',
            LastName='Head',
            Email='saleshead@xyz.com',
            Username='saleshead@xyz.com',
            Alias='SHead',
            CommunityNickname='SHead',
            ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            UserRoleId=salesHeadRole.Id,
            ManagerId=vicePresidentUser.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            IsActive=true
        );
         insert salesHeadUser;
        
        
        User salesManagerUser = new User(
            FirstName='Sales',
            LastName='Manager',
            Email='roshan.bande@gmail.com',
            Username='salesmanager@abc.com.invalid.test',
            Alias='SManager',
            CommunityNickname='SManager',
            ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            UserRoleId=salesManagerRole.Id,
            ManagerId=salesHeadUser.Id,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            IsActive=true
        );
        insert salesManagerUser;
 }
    
    @isTest
    static void testTriggerLogicAsSalesManager() {
        // Call the test setup method to create users and roles
        Test.startTest();
        //YourTestClass.createTestUsers();
        //YourTestClass.createTestRecords();
        UserRole ur=[SELECT Id from UserRole WHERE Name='Sales Manager' limit 1];
        // Find the Sales Manager user
        User salesManagerUser = [SELECT Id FROM User WHERE UserRoleId = :ur.Id LIMIT 1];
        
        // Run the trigger logic as the Sales Manager user
        System.runAs(salesManagerUser) {
            // Perform any logic that should be executed as the Sales Manager user
            // This could include creating or updating records that trigger the trigger
            
            // Example: Update a record to trigger the trigger
            Sales_Meeting_Tracker__c smt= new Sales_Meeting_Tracker__c();
            smt.Meeting_Date__c=Date.today();
            smt.Broker_category__c='Not Registered';
            smt.Broker_Name__c='Test broker';
            insert smt;
        }
        
        Test.stopTest();
        
        // Your assertions and verifications here
    }
}