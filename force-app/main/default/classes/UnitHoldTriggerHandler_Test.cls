@isTest
public class UnitHoldTriggerHandler_Test {

    @isTest
    static void testBeforeInsert() {
       
        // Create a test user with the desired user role for the test
        UserRole testUserRole = new UserRole(Name = 'Sales Manager');
        insert testUserRole;
        string managedId = [SELECT ID FROM User WHERE ID =: userInfo.getUserId()].ID;
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            UserName = 'testuser@example.com.sobha.test',
            LanguageLocaleKey='en_US', 
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = userProfile.Id,
            UserRoleId = testUserRole.Id,
            managerId = managedId
        );
        insert testUser;

       
        system.runas(testUser){
            Test.startTest();
            Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
            Id unitId = recordMap.get('UNIT');
          
             // Create Unit_Hold__c records for testing
         Unit_Hold__c testUnitHold1 = new Unit_Hold__c(Unit_Hold_Requested__c = true,unit__c = unitId);
         Unit_Hold__c testUnitHold2 = new Unit_Hold__c(Unit_Hold_Requested__c = false,unit__c = unitId);
         insert new List<Unit_Hold__c>{testUnitHold1, testUnitHold2};
        Test.stopTest();
        testUnitHold1  = [SELECT ID,Status__c,Unit_Hold_Approval_Status__c,Reason__c FROM Unit_Hold__C WHERE Id=: testUnitHold1.Id];
        // Validate the results using System.assertEquals or System.assertNotEquals
       
        }
        
    }

    @isTest
    static void testAfterInsert() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
      
        Test.startTest();
         // Create Unit_Hold__c records for testing
         Unit_Hold__c testUnitHold1 = new Unit_Hold__c(Unit_Hold_Requested__c = true,unit__c = unitId);
         Unit_Hold__c testUnitHold2 = new Unit_Hold__c(Unit_Hold_Requested__c = false,unit__c = unitId);
         insert new List<Unit_Hold__c>{testUnitHold1, testUnitHold2};
 
        Test.stopTest();
    }

    @isTest
    static void testUpdateStatusToActive() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
      
        // Create Unit_Hold__c records for testing
        Unit_Hold__c testUnitHold1 = new Unit_Hold__c(Unit_Hold_Approval_Status__c = 'Pending with VP',unit__c = unitId);
        insert new List<Unit_Hold__c>{testUnitHold1};
        Test.startTest();
        testUnitHold1.Unit_Hold_Approval_Status__c = 'Approved';
        testUnitHold1.Request_Time__c = '1 Hour';
        update testUnitHold1;
        Test.stopTest();

    }

   
    @isTest
    static void testUnitHoldRejectionValidation() {
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
      
        // Create Unit_Hold__c records for testing
       Unit_Hold__c testUnitHold2 = new Unit_Hold__c(Unit_Hold_Approval_Status__c = 'Pending with VP',unit__c = unitId);

        insert new List<Unit_Hold__c>{testUnitHold2};
        Test.startTest();
        testUnitHold2.Unit_Hold_Approval_Status__c = 'Rejected by VP';
        testUnitHold2.rejection_reason__c = 'test';
        update testUnitHold2;
        Test.stopTest();
   }
}