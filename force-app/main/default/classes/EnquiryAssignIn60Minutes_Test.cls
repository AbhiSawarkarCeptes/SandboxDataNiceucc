@isTest
public class EnquiryAssignIn60Minutes_Test {
     @isTest
    static void testMethod1() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Customer' AND SObjectType = 'Contact' LIMIT 1];
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.RecordTypeId = rt.Id;
        cont.Email = 'test@test.com';
        insert cont;

        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;

        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Assignment_Group_Name__c assGrp = TestDataFactorySobha.createAssignmentGroup(null);
        assGrp.PropStrength__Type__c = 'Enquiry';
		insert assGrp;
        
        PropStrength__Group_Member__c member = TestDataFactorySobha.createAssignmentGroupMember(null);
        member.PropStrength__Assignment_Group__c = assGrp.Id;
        member.PropStrength__Order__c = 1;
        insert member;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28),PropStrength__IsActive__c = true, PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000);
        insert advt;
        List<PropStrength__Request__c> req = new List<PropStrength__Request__c>();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        
        enq.PropStrength__Request_Status__c = 'Open';
        enq.Web_Source__c = 'Test Source';
        enq.Reassigned_Owners__c = 'Test Reassigned Owners';
        enq.Facebook_Adset_Name__c = 'Test Adset';
        enq.Facebook_Ad_Name__c = 'Test Ad';
        enq.UTM_Source__c = 'Test UTM Source';
        enq.Campaign_Name__c = 'Test Campaign';
        enq.Mobile_Country_Code__c = '+61';
        enq.Last_Processing_DateTime__c = null;
        enq.UTM_Campaign__c = 'Test UTM Campaign';
        enq.Prefered_LAnguage__c = 'English';
        enq.Route_To_Saturday_Queue1__c = true;
        enq.Route_To_Sunday_Queue1__c = true;
        enq.PropStrength__Request_Source__c = 'Test Request Source';
        enq.Assignment_Group__c = assGrp.Id;
        insert enq;
        enq.Enquiry_Owner_Batch_Update_60_min__c = System.now().addMinutes(-60);
        enq.Re_Enquiry__c = true;
        update enq;
        EnquiryAssignIn60Minutes.reAssignEnquiryIn20Min(new List<PropStrength__Request__c>{enq});
    }
}