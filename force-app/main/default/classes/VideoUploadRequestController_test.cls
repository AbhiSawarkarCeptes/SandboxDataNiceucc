@isTest
public class VideoUploadRequestController_test {
    
    @isTest
    public static void testMethod1(){
          User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = u.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Channel_Partner__c = chPartner.id;
        evnt.Broker_Account__c = acc.id;
        //evnt.Event_Approved_status__c = System.Label.Event_Approved_Status;//'The event has been approved by Sales Director';
        evntlst.add(evnt);
        insert evntlst;
    

         
    
    Test.startTest();
        VideoUploadRequestController.currentId = evnt.id;
        VideoUploadRequestController.getrelatedTo();
    Test.stopTest();
    }
   
}