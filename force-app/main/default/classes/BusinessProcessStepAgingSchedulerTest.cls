@isTest
public class BusinessProcessStepAgingSchedulerTest {

         @testSetup
    static void setUpdata(){
        
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        GroupMember gm = new GroupMember();
        gm.GroupId = queueId;
        gm.UserOrGroupId = UserInfo.getUserId();
        insert gm;
    }
    
    @isTest
    static void testOpenNextStep2() {
        Test.startTest();
        contact con = new contact();
        con.FirstName = 'For';
        con.LastName = 'TAT Emails';
        insert con;
        Id queueId = ([SELECT Id, Name, DeveloperName FROM Group WHere DeveloperName like '%Business_Process%' limit 1]).Id;
        Test.stopTest();
        // Test data setup
        // Add necessary fields and create test data for Business_Process_Step__c
        List<Business_Process_Step__c> newList = new List<Business_Process_Step__c>();
        // Populate newList with test data

        
        Map<Id, Business_Process_Step__c> oldMap = new Map<Id, Business_Process_Step__c>();
        // Populate oldMap with existing Business_Process_Step__c records

        Business_Process__c bp = new Business_Process__c(/* add necessary fields */);
        bp.name = 'test';
        bp.Status__c = 'In Progress';
        bp.Start_Date__c = system.now();
        insert bp;

        Business_Process_Step__c bps = new Business_Process_Step__c(
            Business_Process__c = bp.Id

        );
        bps.name = 'test';
        bps.Business_Process_Steps_Name_Custom__c = 'test';
        bps.Sequence__c = 1;
        bps.OwnerId = queueId;
        bps.Status__c = 'Open';
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
        bps1.OwnerId = UserInfo.getUserId();
        bps1.Status__c = 'Open';
        bps1.Accepted_Time__c = system.now();
        bps1.Assigned_Time__c = system.now();
        bps1.Completed_Time__c = system.now();
        bps1.Final_Accepted_Time__c = system.now();
        bps1.Final_Assigned_Time__c = system.now();
        bps1.Final_Completed_Time__c = system.now()+3;
        System.debug(' bps1.Final_Completed_Time__c '+ bps1.Final_Completed_Time__c);
        bps1.Original_Queue_Id__c = UserInfo.getUserId();
        insert bps1;

        

		 // Schedule the job
        String jobId = System.schedule('Test BusinessProcessStepAgingUpdateScheduler',
                                       '0 0 0 * * ?', // Set the cron expression to run daily at midnight
                                       new BusinessProcessStepAgingUpdateScheduler());
        BusinessProcessStepAgingUpdateBatch processBatch = new BusinessProcessStepAgingUpdateBatch(null);
        Database.executeBatch(processBatch);
        BusinessProcessAgingUpdateBatch processBatch1 = new BusinessProcessAgingUpdateBatch(null);
        Database.executeBatch(processBatch1);

    }    

        

}