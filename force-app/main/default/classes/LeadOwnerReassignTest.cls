@isTest
public class LeadOwnerReassignTest {

    static testMethod void leadownerReassign() {
        
        Profile pfr = [select id , name from profile where name = 'Presales'];
        User usr = new User();
        usr.Username = 'testing@sobha.com';
        usr.FirstName = 'testfirst';
        usr.LastName   = 'testlast';
        usr.IsActive = true;
        usr.Alias = 'test';
        usr.Email = 'abc@gmail.com';
        usr.ProfileId = pfr.id;
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocalesIdKey = 'en_US';
        usr.TimezonesIdKey = 'America/Los_Angeles';
        insert usr;
        
        group g = new group();
        g.Name = 'Super Agent - English Language';
        insert g;
         List<User> usrList = [select id from user limit 1];
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.email = 'test@test.com';
        l.Primary_Number__c = '00000';
        l.Presales_Agent__c = usrList[0].id;
        List<group> superAgentEnglishQueue = [SELECT ID,Name FROM group WHERE  Name = 'Super Agent - English Language'];
        string queueId = superAgentEnglishQueue[0].id;
       // Lead ld = new Lead(ownerID = usrList[0].id);
        l.ownerID = queueId;
        insert l;
        
       // String Query = 'Select id,name,Presales_Agent__c, OwnerId,owner.Name,Owner_Profile__c,createddate from Lead where  Id=:l.id order by createddate desc ';
        List<lead> l1 = [Select id,name,Presales_Agent__c, OwnerId,owner.Name,Owner_Profile__c,createddate from Lead where  Id=:l.id order by createddate desc ];
       // System.Assert(false,'message'+l1.Size());
        Test.startTest();
        LeadOwnerReassign b = new LeadOwnerReassign(); 
        b.execute(null,l1);
        database.executebatch(b); 
        
        Test.stopTest();
    }
}