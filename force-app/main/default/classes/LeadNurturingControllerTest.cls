@isTest
public class LeadNurturingControllerTest {
	@isTest
    public static void testLeadNurturingController(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        Id towerId = recordMap.get('TOWER');
        Lead l = new Lead();
        l.lastname='Test1';
        l.email='test@test.com';
        l.MobilePhone = '1234567891';
        l.Project__c =projectId;
        l.RDS_Country__c ='Test India';
        l.Campaign_Code__c='Test Campaign';
        l.ownerId = UserInfo.getUserId();
        l.Last_Attempt_Status__c='No Contact - Follow-up';
        insert l;
        LeadNurturingController.getLeadNurturingConfigs();
        Day_Tracking__c d = new Day_Tracking__c();
        d.Name = 'Day 1';
        d.Lead__c = l.Id;
        insert d;
        Attempt_Tracking__c a = new Attempt_Tracking__c();
        a.Day_Tracking__c = d.Id;
        a.Attempted_By__c = UserInfo.getUserId();
        a.Name = 'Email';
        a.Attempt_Sequence__c = '1';
        insert a;
        LeadNurturingController.loadEmailTemplate(d.Id);
        LeadNurturingController.sendEmailToCustomer(d.Id);
        Database.executeBatch(new CreateLeadDailyTrackingBatch());
        Attempt_Tracking__c a1 = new Attempt_Tracking__c();
        a1.Day_Tracking__c = d.Id;
        a1.Attempted_By__c = UserInfo.getUserId();
        a1.Name = 'Official Mobile';
        a1.Attempt_Sequence__c = '3';
        insert a1;
        a1.Status__c = 'No Contact - Follow-up';
        update a1;
    }
}