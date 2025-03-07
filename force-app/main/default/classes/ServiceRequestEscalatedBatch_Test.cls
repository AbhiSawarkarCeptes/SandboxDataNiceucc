@isTest
public class ServiceRequestEscalatedBatch_Test {
    @testSetup static void createTestData() {
        List<User> users = new List<User>();

        User managerUser = TestDataFactorySobha.createUser(null);
        insert managerUser;

        User normalUser = TestDataFactorySobha.createUser(null);
        normalUser.ManagerId = managerUser.Id;
        normalUser.ProfileId = [SELECT id FROM Profile WHERE name = 'System Administrator'][0].Id;
        insert normalUser;


        PropStrength__Service_Request__c serviceRequest = new PropStrength__Service_Request__c(
            PropStrength__Status__c = 'New',
            OwnerId = normalUser.Id,
            Escalated_Case__c = false
        );
        insert serviceRequest;
        Test.setCreatedDate(serviceRequest.Id, Date.today().addDays(-2));        

    }

    @isTest
    static void testBatchExecution() {
        
        Test.startTest();

        ServiceRequestEscalatedBatch batch = new ServiceRequestEscalatedBatch();
        ID batchId = Database.executeBatch(batch);

        Test.stopTest();
        

        List<PropStrength__Service_Request__c> updatedRequests = [SELECT Id, Escalated_Case__c FROM PropStrength__Service_Request__c];
        for (PropStrength__Service_Request__c req : updatedRequests) {
            System.debug('Service Request ID: ' + req.Id + ' Escalated: ' + req.Escalated_Case__c);
        }
    }

    @isTest
    static void testScheduledExecution() {
        
        Test.startTest();

        String jobId = System.schedule('TestServiceRequestEscalatedBatch', '0 0 * * * ?', new ServiceRequestEscalatedBatch());

        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.debug('Scheduled Job Name: ' + ct.CronJobDetail.Name + ' Next Fire Time: ' + ct.NextFireTime);
    }
}