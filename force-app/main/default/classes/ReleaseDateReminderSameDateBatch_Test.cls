@isTest
public class ReleaseDateReminderSameDateBatch_Test {
	@TestSetup static void setup(){
        Group marketingGroup = new Group(Name='Marketing_Group', DeveloperName='Marketing_Group');
        insert marketingGroup;
        
        // Avoid mixed DML using runAs
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = marketingGroup.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
        }
        
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(Release_Date__c=System.Today(),PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000);
        insert advt;
    }
      @isTest
    Public  static void ReleaseDateReminderSameDateBatchTest(){
       	ReleaseDateReminderSameDateBatch st = new ReleaseDateReminderSameDateBatch();
        Database.executeBatch(st);
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, st); 
    }
}