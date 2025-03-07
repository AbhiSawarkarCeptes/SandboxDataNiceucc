@isTest
public class SoftReminderBatchSchedular_Test {
@isTest
    static void testSchedulableClass() {
      
        SoftReminderBatchSchedular schedulableJob = new SoftReminderBatchSchedular();
        String jobId = System.schedule('Test Schedulable Job', '0 0 0 * * ?', schedulableJob);
        CronTrigger[] jobs = [SELECT Id, CronJobDetail.Name, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, jobs.size(), 'Job should be scheduled');
        System.assertEquals('Test Schedulable Job', jobs[0].CronJobDetail.Name, 'Job name should match');
        System.assertEquals('WAITING', jobs[0].State, 'Job should be in WAITING state');
        /*Test.startTest();
        System.scheduleJob(schedulableJob, 'Test Schedulable Job');
        Test.stopTest();*/
    }
        
}