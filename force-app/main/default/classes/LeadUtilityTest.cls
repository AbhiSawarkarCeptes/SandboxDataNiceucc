@isTest
public class LeadUtilityTest {
    static testMethod void leadUtility1() {
        Test.startTest();
        
        Campaign c = New Campaign();
        c.Name = 'Test Project';
        c.isActive =True;
        c.Type = 'Advertisement';
        c.sub_source__c= 'Facebook';
        //c.Primary_Project__c = p.id;
        c.Digital_Maketing_Campaign_Code__c ='12345';  
        Insert c;
        
        Lead l = new Lead();
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
        sml.AdSet_Id__c ='3253242432423';
        sml.Form_ID__c = '454323234235';
        sml.Ad_Name__c = 'FaceBookAd';
        sml.AdSet_Name__c = 'FaceBookAddSet';
        sml.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml.Platform_ig__c = 'Platform';
        sml.Page_Name__c = 'pageName';
        sml.Form_Name__c = 'newForm';
        sml.Full_Name__c = 'Full Name';
        sml.Phone_Number__c = '12345678';
        sml.Mobile_Number__c = '334613272013';
        sml.Mobile_Number_No_Country_Code__c = '4613272013';
        insert sml;
       
        LeadUtility.formatPhone2(l, sml);
        Test.stopTest();
    }	
    static testMethod void Testutility2(){
        
        Project__c p=new Project__c();
    p.Name = 'TestProject';
    p.Project_Code__c = '88884';
    p.Address__c='Pune';
    p.City__c='Pune';
    p.State__c='Maharashtra'; 
    insert p;
        
        
         Lead_Source__c ls = new Lead_Source__c();
        ls.Lead__c = 'Digital';
        ls.Adgroup__c = 'Test';
        ls.Sub_Source__c = 'Facebook Leadgen';
        ls.UTM_Source__c = 'website';
        ls.UTM_Medium__c = 'paid-social';
        ls.Digital_Source__c = 'Facebook';
        ls.Goal__c = 'leadgen';
        ls.Channel_Cluster__c = 'social';
        ls.Digital_Marketing_Code__c = '123';
        ls.AdSet_Id__c = '456';
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
        //ls.AdSet_Id__c ='456';
        //ls.Form_ID__c = '456';
        //ls.UTM_Medium_Key__c = '123';
        insert ls;  
        
        Campaign c = New Campaign();
        c.Name = 'Test Project';
        c.isActive =True;
        c.Type = 'Advertisement';
        c.sub_source__c= 'Facebook';
        //c.Primary_Project__c = p.id;
        c.Digital_Maketing_Campaign_Code__c ='12345'; 
        Insert c;
        
        Social_media_lead__c sml = new Social_media_lead__c();
        //sml.Form_ID__c  = '1234351351513';
        sml.Page_ID__c  = '4534623232322';
        sml.Lead_ID__c  = '45524235632';
        sml.Source__c   = 'Facebook';
        sml.Email__c    = 'abc@gmail.com';
        sml.Full_Name__c = 'testfb';
        sml.Campaign_Id__c = c.Id;
        sml.Campaign_Name__c = c.Name;
        sml.Country__c = 'UAE';
        sml.Ad_ID__c = '111111';
        sml.AdSet_Id__c ='456';
        sml.Form_ID__c = '123';
        sml.Mobile_Number__c = '334613272013';
        sml.Mobile_Number_No_Country_Code__c = '4613272013';
        sml.Ad_Name__c = 'FaceBookAd';
        sml.AdSet_Name__c = 'FaceBookAddSet';
        sml.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml.Platform_ig__c = 'Platform';
        sml.Page_Name__c = 'pageName';
        sml.Form_Name__c = 'newForm';
        sml.Full_Name__c = 'Full Name';
        sml.Phone_Number__c = '12345678';
        //sml.UTM_Medium_Key__c = '123';
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
        
        Test.startTest();
        //system.assert(false, 'VVK: '+[select id,UTM_Medium_Key__c  from Lead_Source__c where id=: ls.Id][0].UTM_Medium_Key__c );
        lead l = new Lead();
        Social_media_lead__c smlTmp = [select id,Form_ID__c,UTM_Medium_Key__c,source__c  from Social_media_lead__c where id=: sml.Id];
        LeadUtility.fetchLeadSource(l,smlTmp);
        LeadUtility.updateLeadAttributionHashFields(new list<Lead>{l},null,false);
        Test.stopTest();
    }
}