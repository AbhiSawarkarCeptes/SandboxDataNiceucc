/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class fbLeadsTest {
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"Test":"Test"}');
            return res;
        }
    }

   /* static testMethod void VerifyEndPoint() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.httpMethod = 'GET';
        req.addParameter('hub.challenge','challengemeFB');
        req.addParameter('hub.verify_token','secret007');
        RestContext.request = req;
        RestContext.response = res;
        
        fbLeads.fbVerifyEndPoint();        
    }*/
    
    static testMethod void leadCapture() {
        
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    
    Project__c p=new Project__c();
    p.Name = 'Sobha Hartland';
    p.Project_Code__c = '88884';
    p.Address__c='Pune';
    p.City__c='Pune';
    p.State__c='Maharashtra'; 
    insert p;
    
    Facebook_Lead_New__c csObj1 = new Facebook_Lead_New__c();
    csObj1.Name = '123046341703539'; // 685046341703539
    csObj1.Project_Name__c = 'TestProject';
    csobj1.Campaign_Id__c='12345';
    csobj1.Form_Name__c = 'Test Form';
    csobj1.Language__c = 'English';
    insert csObj1;
        
    Campaign c = New Campaign();
    c.Name = 'Test Project';
    c.isActive =True;
    c.Type = 'Advertisement';
    c.sub_source__c= 'Facebook';
    c.Primary_Project__c = p.id;
    c.Digital_Maketing_Campaign_Code__c ='12345'; 
    Insert c;
    List<Social_media_lead__c> smlList = new list<Social_media_lead__c>();
    Social_media_lead__c sml = new Social_media_lead__c();
    sml.Form_ID__c  = '123046341703539';
    sml.Page_ID__c  = '4534623232322';
    sml.AdSet_Id__c ='3253242432423';
    sml.Lead_ID__c  = '4523188';
    sml.Source__c   = 'Facebook';
    sml.Email__c    = 'abcd@gmail.com';
    sml.Full_Name__c = 'tesstfb';
    sml.processed__c = false;
    sml.Campaign_Id__c = c.Id;
    sml.Campaign_Name__c = c.Name;
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
    smlList.add(sml);
        
         Social_media_lead__c sml1 = new Social_media_lead__c();
    sml1.Form_ID__c  = '123046341703539';
        sml.AdSet_Id__c ='3253242432423';
        
    sml1.Page_ID__c  = '453462323282';
    sml1.Lead_ID__c  = '45231';
    sml1.Source__c   = 'Facebook';
    sml1.Email__c    = 'abcd@gmail.com';
    sml1.Full_Name__c = 'testfb1';
    sml1.processed__c = false;
    sml1.Campaign_Id__c = c.Id;
    sml1.Campaign_Name__c = c.Name;
    sml1.Country__c = 'AE';
    sml1.Ad_ID__c = '111111';
    sml1.Ad_Name__c = 'FaceBookAd';
        sml1.AdSet_Name__c = 'FaceBookAddSet';
        sml1.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml1.Platform_ig__c = 'Platform';
        sml1.Page_Name__c = 'pageName';
        sml1.Form_Name__c = 'newForm';
        sml1.Full_Name__c = 'Full Name';
        sml1.Phone_Number__c = '12345678';
       	sml1.Mobile_Number__c = '330613272013';
        sml1.Mobile_Number_No_Country_Code__c = '0613272013';
        sml1.Recording_URL__c = 'URL';
    smlList.add(sml1);
        
        insert smlList;
      
    ///// Added by Neha on 26/2/19    
    Lead_Source__c ls = new Lead_Source__c();
    ls.Lead__c = 'Digital';
    ls.Adgroup__c = 'Test';
    ls.Sub_Source__c = 'Facebook Leadgen';
    ls.UTM_Source__c = 'website';
    ls.UTM_Medium__c = 'paid-social';
    ls.Digital_Source__c = 'Facebook';
    ls.Goal__c = 'leadgen';
    ls.Channel_Cluster__c = 'social';
    ls.Digital_Marketing_Code__c = '123046341703539';
    ls.AdSet_Id__c = '3253242432423';
    ls.Banner_Size__c = '241';
    ls.Keyword__c = 'Facebook';
    ls.Placement__c = 'Facebook';
    ls.Ad_position__c = 'top';
    ls.Match_Type__c = 'Yes';
    ls.UTM_Campaign__c = 'direct-website';
    ls.UTM_Content__c = 'Facebook';
    ls.Lead_Source_27__c = 'Digital';
    ls.Last_Mile_Conversion__c = 'Contact Us';
    ls.Device__c = 'desktop';
    ls.OS__c = 'Windows 10';
    ls.Resolution__c = '1366x768';
    ls.Browser__c = 'Chrome';
    ls.GCLID__c = 'gclid';
    ls.Time_Spent_before_Form_Submit__c = '30';
    ls.IP_Address__c = '10.13.84.2';
    ls.Landing_Page_URL__c = 'sobharealty.com';
    ls.Bid_Type__c = 'Type 1 ';
    ls.Network__c = 'facebook';
        ls.Project__c = p.Id;
        ls.Project_Name__c = 'SOBHA';
        ls.Country_Name__c = 'India';
    insert ls;    
 
        
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
         ld.Email = 'pritam.polley@smaartt.com';
        ld.Primary_Number__c = '00000'; 
        ld.LastName = 'Pritam Polley';
        insert ld;
    

    //fbLeads.fbLeadCapture();
    //List<Social_media_lead__c> smlList = new List<Social_media_lead__c>();
    //smlList = [Select Id, Name, Processed__c from Social_media_lead__c];
    //System.assertEquals(1, smlList.size());
    Test.startTest();
    FBGetLeadsBatch b = new FBGetLeadsBatch(); 
    database.executebatch(b); 
    Test.stopTest();
}
//// Added by Neha on 28/2/19   
    static testMethod void leadCaptureNew() {
    Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    Project__c p=new Project__c();
    p.Name = 'Sobha Hartland';
    p.Project_Code__c = '88884';
    p.Address__c='Pune';
    p.City__c='Pune';
    p.State__c='Maharashtra'; 
    insert p;
    
    Facebook_Lead_New__c csObj1 = new Facebook_Lead_New__c();
    csObj1.Name = '1234351351513'; // 685046341703539
    csObj1.Project_Name__c = 'Sobha Hartland';
    csobj1.Campaign_Id__c='12345';
    csobj1.Form_Name__c = 'Test Form';
    csobj1.Language__c = 'English';
    insert csObj1;
        
     Campaign c = New Campaign();
    c.Name = 'Test Project';
    c.isActive =True;
    c.Type = 'Advertisement';
    c.sub_source__c= 'Facebook';
    //c.Primary_Project__c = p.id;
    c.Digital_Maketing_Campaign_Code__c ='12345'; 
    Insert c;
    
         Social_media_lead__c sml1 = new Social_media_lead__c();
    sml1.Form_ID__c  = '123435136713';
    sml1.Page_ID__c  = '453462323282';
    sml1.Lead_ID__c  = '45231';
    sml1.Source__c   = 'Facebook';
    sml1.Email__c    = 'abcd@gmail.com';
    sml1.Full_Name__c = 'testfb1';
    sml1.processed__c = false;
    sml1.Campaign_Id__c = c.Id;
    sml1.Campaign_Name__c = c.Name;
    sml1.Country__c = 'AE';
    sml1.Ad_ID__c = '111111';
    sml1.Ad_Name__c = 'FaceBookAd';
        sml1.AdSet_Name__c = 'FaceBookAddSet';
        sml1.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml1.Platform_ig__c = 'Platform';
        sml1.Page_Name__c = 'pageName';
        sml1.Form_Name__c = 'newForm';
        sml1.Full_Name__c = 'Full Name';
        sml1.Phone_Number__c = '12345678';
        sml1.Mobile_Number__c = '330613272013';
        sml1.Mobile_Number_No_Country_Code__c = '0613272013';
        sml1.Recording_URL__c = 'URL';
    insert sml1;
        
    ///// Added by Neha on 26/2/19    
    Lead_Source__c ls = new Lead_Source__c();
    ls.Lead__c = 'Digital';
    ls.Adgroup__c = 'Test';
    ls.Sub_Source__c = 'Facebook Leadgen';
    ls.UTM_Source__c = 'website';
    ls.UTM_Medium__c = 'paid-social';
    ls.Digital_Source__c = 'Facebook';
    ls.Goal__c = 'leadgen';
    ls.Channel_Cluster__c = 'social';
    ls.Digital_Marketing_Code__c = '123046341703539';
    ls.Banner_Size__c = '241';
    ls.Keyword__c = 'Facebook';
    ls.Placement__c = 'Facebook';
    ls.Ad_position__c = 'top';
    ls.Match_Type__c = 'Yes';
    ls.UTM_Campaign__c = 'direct-website';
    ls.UTM_Content__c = 'Facebook';
    ls.Lead_Source_27__c = 'Digital';
    ls.Last_Mile_Conversion__c = 'Contact Us';
    ls.Device__c = 'desktop';
    ls.OS__c = 'Windows 10';
    ls.Resolution__c = '1366x768';
    ls.Browser__c = 'Chrome';
    ls.GCLID__c = 'gclid';
    ls.Time_Spent_before_Form_Submit__c = '30';
    ls.IP_Address__c = '10.13.84.2';
    ls.Landing_Page_URL__c = 'sobharealty.com';
    ls.Bid_Type__c = 'Type 1 ';
    ls.Network__c = 'facebook';
    ls.Project__c = p.Id;
    ls.Project_Name__c = 'SOBHA';
    ls.Country_Name__c = 'India';
    insert ls;    
    
    Social_media_lead__c sml = new Social_media_lead__c();
    sml.Form_ID__c  = '1234351351513';
    sml.Page_ID__c  = '4534623232322';
    sml.Lead_ID__c  = '45524235632';
    sml.Source__c   = 'Facebook';
    sml.Email__c    = 'abc@gmail.com';
    sml.Full_Name__c = 'testfb';
    sml.Campaign_Id__c = c.Id;
    sml.Campaign_Name__c = c.Name;
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
        ld.Email = 'pritam.polley@smaartt.com';
        ld.Primary_Number__c = '00000'; 
        ld.LastName = 'Pritam Polley';
        insert ld;
        
    
    Test.startTest();
    FBGetLeadsBatch b = new FBGetLeadsBatch(); 
    database.executebatch(b); 
    Test.stopTest();
       
   
    }
    static testMethod void testbatchNegativeUseCase() {
    Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
    Project__c p=new Project__c();
    p.Name = 'Sobha Hartland';
    p.Project_Code__c = '88884';
    p.Address__c='Pune';
    p.City__c='Pune';
    p.State__c='Maharashtra'; 
    insert p;
    
    Facebook_Lead_New__c csObj1 = new Facebook_Lead_New__c();
    csObj1.Name = '1234351351513'; // 685046341703539
    csObj1.Project_Name__c = 'Sobha Hartland';
    csobj1.Campaign_Id__c='12345';
    csobj1.Form_Name__c = 'Test Form';
    csobj1.Language__c = 'English';
    insert csObj1;
        
     Campaign c = New Campaign();
    c.Name = 'Test Project';
    c.isActive =True;
    c.Type = 'Advertisement';
    c.sub_source__c= 'Facebook';
    c.Primary_Project__c = p.id;
    c.Digital_Maketing_Campaign_Code__c ='12345'; 
    Insert c;
    
    ///// Added by Neha on 26/2/19    
    Lead_Source__c ls = new Lead_Source__c();
    ls.Lead__c = 'Digital';
    ls.Adgroup__c = 'Test';
    ls.Sub_Source__c = 'Facebook Leadgen';
    ls.UTM_Source__c = 'website';
    ls.UTM_Medium__c = 'paid-social';
    ls.Digital_Source__c = 'Facebook';
    ls.Goal__c = 'leadgen';
    ls.Channel_Cluster__c = 'social';
    ls.Digital_Marketing_Code__c = '123046341703539';
    ls.Banner_Size__c = '241';
    ls.Keyword__c = 'Facebook';
    ls.Placement__c = 'Facebook';
    ls.Ad_position__c = 'top';
    ls.Match_Type__c = 'Yes';
    ls.UTM_Campaign__c = 'direct-website';
    ls.UTM_Content__c = 'Facebook';
    ls.Lead_Source_27__c = 'Digital';
    ls.Last_Mile_Conversion__c = 'Contact Us';
    ls.Device__c = 'desktop';
    ls.OS__c = 'Windows 10';
    ls.Resolution__c = '1366x768';
    ls.Browser__c = 'Chrome';
    ls.GCLID__c = 'gclid';
    ls.Time_Spent_before_Form_Submit__c = '30';
    ls.IP_Address__c = '10.13.84.2';
    ls.Landing_Page_URL__c = 'sobharealty.com';
    ls.Bid_Type__c = 'Type 1 ';
    ls.Network__c = 'facebook';
     ls.Project__c = p.Id;
        ls.Project_Name__c = 'SOBHA';
        ls.Country_Name__c = 'India';
    insert ls;    
    
    Social_media_lead__c sml = new Social_media_lead__c();
    sml.Form_ID__c  = '1234351351513';
    sml.Page_ID__c  = '4534623232322';
    sml.Lead_ID__c  = '4523520035632';
    sml.Source__c   = 'Facebook';
    //sml.Email__c    = '';
    sml.Full_Name__c = 'testfb';
    sml.Campaign_Id__c = c.Id;
    sml.Campaign_Name__c = c.Name;
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
         ld.Email = 'pritam.polley@smaartt.com';
        ld.Primary_Number__c = '00000'; 
        ld.LastName = 'Pritam Polley';
        insert ld;
    Test.startTest();
    //System.assertEquals(1, smlList.size());*/
    FBGetLeadsBatch b = new FBGetLeadsBatch(); 
    database.executebatch(b); 
    dateTime dt = dateTime.now().addHours(1);
    string schTimer = string.valueOf(dt.second()) + ' ' + string.valueOf(dt.minute()) + ' ' + string.valueof(dt.hour()) + ' ' + string.valueof(dt.day()) + ' ' + string.valueof(dt.month()) + ' ? '+ string.valueOf(dt.year());
    system.Schedule('testing FBGetLeadsBatch class',schTimer,new FBGetLeadBatch_sched());
    Test.stopTest();
    }

    
}