@isTest
public class BusinessProcessTriggerHandlerTest {

    @testSetup
    static void setUpdata(){
        
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        GroupMember gm = new GroupMember();
        gm.GroupId = queueId;
        gm.UserOrGroupId = UserInfo.getUserId();
        insert gm;
    }
    @isTest
    static void testSendEmailOnCompletion() {
        // Test data setup: Create necessary Business_Process__c, Business_Process_Step__c, and related records
        // Ensure the test data represents the conditions in which sendEmailOnCompletion should be triggered
        contact con = new contact();
        con.FirstName = 'For';
        con.LastName = 'TAT Emails';
        insert con;
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        // Example: Insert Business_Process__c and related Business_Process_Step__c records with the necessary fields set
        Business_Process__c bp = new Business_Process__c(/* add necessary fields */);
        bp.name = 'test';
        insert bp;
        
        Business_Process_Step__c bps = new Business_Process_Step__c(
            Business_Process__c = bp.Id

        );
        bps.name = 'test';
        bps.Business_Process_Steps_Name_Custom__c = 'test';
        bps.Sequence__c = 1;
        bps.OwnerId = queueId;
        bps.Accepted_Time__c = system.now();
        bps.Assigned_Time__c = system.now();
        bps.Completed_Time__c = system.now();
        bps.Final_Accepted_Time__c = system.now();
        bps.Final_Assigned_Time__c = system.now();
        bps.Final_Completed_Time__c = system.now();
        bps.Original_Queue_Id__c = queueId;
        insert bps;
        
         Business_Process_Step__c bps1 = new Business_Process_Step__c(
            Business_Process__c = bp.Id

        );
        bps1.name = 'test';
        bps1.Business_Process_Steps_Name_Custom__c = 'test';
        bps1.Sequence__c = 2;
        bps1.OwnerId = queueId;
        bps1.Status__c = 'Open';
        bps1.Accepted_Time__c = system.now();
        bps1.Assigned_Time__c = system.now();
        bps1.Completed_Time__c = system.now();
        bps1.Final_Accepted_Time__c = system.now();
        bps1.Final_Assigned_Time__c = system.now();
        bps1.Final_Completed_Time__c = system.now();
        bps1.Original_Queue_Id__c = queueId;
        insert bps1;
        
        bp.Status__c = 'Completed';
        bp.Start_Date__c = system.now();
        bp.End_Date__c = system.now();
        update bp;
        // Call the method under test
        Test.startTest();
        // Pass appropriate parameters to the sendEmailOnCompletion method
        // Example: BusinessProcessTriggerHandler.sendEmailOnCompletion(newList, oldMap);
        Test.stopTest();
        
        // Add assertions to verify the expected behavior
        
        // Example: Assert that the email message is sent to the correct recipients
    }

    // Add more test methods for other methods in BusinessProcessTriggerHandler class

}