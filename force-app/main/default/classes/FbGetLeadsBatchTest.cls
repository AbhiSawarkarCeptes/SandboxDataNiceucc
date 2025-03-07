@isTest
public class FbGetLeadsBatchTest {
    
    @TestSetup
    static void setupData() {
        
        Project__c p=new Project__c();
        p.Name = 'Sobha Hartland';
        p.Project_Code__c = '88884';
        p.Address__c='Pune';
        p.City__c='Pune';
        p.State__c='Maharashtra'; 
        insert p;
        
        Social_media_lead__c sml = new Social_media_lead__c();
        sml.Form_ID__c  = '1234351351513';
        sml.Page_ID__c  = '4534623232322';
        sml.Lead_ID__c  = '4523520035632';
        sml.Source__c   = 'Facebook';
        sml.Full_Name__c = 'testfb';
        sml.Country__c = 'AE';
        sml.Ad_ID__c = '111111';
        sml.Ad_Name__c = 'FaceBookAd';
        sml.AdSet_Name__c = 'FaceBookAddSet';
        sml.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml.Platform_ig__c = 'Platform';
        sml.Page_Name__c = 'pageName';
        sml.Form_Name__c = 'newForm';
        sml.Full_Name__c = 'Full Name';
        sml.Phone_Number__c = '12345678';
        sml.Mobile_Number__c = '330613272013';
        sml.Mobile_Number_No_Country_Code__c = '0613272013';
        sml.Recording_URL__c = 'URL';
        insert sml;
        
        
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
        List<User> usrList = [select id from user where isactive=true limit 1];
        
        List<group> superAgentEnglishQueue = [SELECT ID,Name FROM group WHERE  Name = 'Super Agent - English Language'];
        string queueId = superAgentEnglishQueue[0].id;
        
        
        Lead ld = new Lead(ownerID = usrList[0].id);
        ld.Email = 'sobha@realty.com';
        ld.Primary_Number__c = '00000'; 
        ld.LastName = 'Sobha Realty';
        insert ld;
        
    }
    
    @isTest
    public static void testUniqueLead() {
        
        Test.startTest();
        dateTime dt = dateTime.now().addHours(1);
        string schTimer = string.valueOf(dt.second()) + ' ' + string.valueOf(dt.minute()) + ' ' + string.valueof(dt.hour()) + ' ' + string.valueof(dt.day()) + ' ' + string.valueof(dt.month()) + ' ? '+ string.valueOf(dt.year());
        system.Schedule('testing FBGetLeadsBatch class',schTimer,new FBGetLeadBatch_sched());
        
        database.executebatch(new FBGetLeadsBatch(),1); 
        
        Test.stopTest();
    }
    
     @isTest
    public static void testDuplicateLead() {
        
        Social_media_lead__c smlOld = [SELECT id FROM Social_media_lead__c LIMIT 1];
        smlOld.processed__c = TRUE;
        update smlOld;
        
        Social_media_lead__c sml = new Social_media_lead__c();
        sml.Email__c = 'sobha@realty.com';
        sml.Processed__c = FALSE;
        insert sml;
        
        Test.startTest();
        dateTime dt = dateTime.now().addHours(1);
        string schTimer = string.valueOf(dt.second()) + ' ' + string.valueOf(dt.minute()) + ' ' + string.valueof(dt.hour()) + ' ' + string.valueof(dt.day()) + ' ' + string.valueof(dt.month()) + ' ? '+ string.valueOf(dt.year());
        system.Schedule('testing FBGetLeadsBatch class',schTimer,new FBGetLeadBatch_sched());
        
        database.executebatch(new FBGetLeadsBatch(),1); 
        
        Test.stopTest();
    }
    
    
}