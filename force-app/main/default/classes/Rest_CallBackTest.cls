@isTest
private class Rest_CallBackTest{
    
    @isTest 
    private static void TestCreateEnquiry(){
           
             
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
            FirstName='Test1 User',
            Alias = 'tstU1',
            Email = 'testUsr1@stetig.in',
            Username = 'testUsr1@stetig.in',
            ProfileId = profileId.id,
            OzoneTel_AgentId__c = 'test.test1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
            lstUser.add(new User(LastName = 'Test2',
            FirstName='Test User2',
            Alias = 'tstU2',
            Email = 'testUsr2@stetig.in',
            Username = 'testUsr2@stetig.in',
            ProfileId = profileId.id,
            department='presales',
            OzoneTel_AgentId__c = 'test.test2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert lstUser;
        
        
        Lead testLead = new Lead();
        Lead testLead1 = new Lead();
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',
                             Digital_Maketing_Campaign_Code__c='918068442375');
        insert campaign;
        
        Project__c p = new Project__c();
        p.Name = 'Sobha Hartland';
        p.Project_Code__c = '002';
        insert p;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"00447089581562\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0044\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
     @isTest
     private static void TestCreateEnquiry2(){
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"00917089581500\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
     @isTest
     private static void TestCreateEnquiry3(){
         
        Account acc = createPATemplate('TestPA1' , 'testleada3@stetig.in', '0617089581566', false);
        acc.Country__c= 'United Arab Emirates';
        acc.Country_Code__c = '+971';  
        update acc;
         
        Project__c p = new Project__c();
        p.Name = 'Sobha Hartland';
        p.Project_Code__c = '002';
        insert p;
         
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        oList[0].Project__c = p.Id;
        system.debug('Opportunity list :: '+ oList);
        
        Id oppId;
        oppId = oList[0].id;
         
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',
                             Digital_Maketing_Campaign_Code__c='918068442375');
        insert campaign;
        
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"0617089581566\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
     // creates  a person account with the basic parameters
          public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
            
                RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                Account a = new Account(lastName=accName, personEmail = email, personMobilePhone  = Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster, Country__c = 'test');
                
               insert a;
               return a;
           } 
    public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
            
        List<Opportunity> oList = new List<Opportunity>();
        Date closeDate; 
        
        for(Integer i =0;i<numOfOpp; i++){
          closeDate = Date.newInstance(2015, 8,29);
            Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', Project__c = ProjId,closeDate=System.today()); //S_Budget_In_lacs__c = 5000000,Phone__c = '9876544442'
            oList.add(o);            
        }
        
        insert oList;
        return oList;
      }
    
     @isTest
     private static void TestCreateEnquiry4(){
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"00607089581577\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
      req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
      @isTest
     private static void TestCreateEnquiry5(){
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09717089581534\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
      req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
      @isTest
     private static void TestCreateEnquiry6(){
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09657089581545\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
      req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    @isTest
     private static void TestCreateEnquiry7(){
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"monitorUCID\": \"1929157114451262\", \"UUI\": \"-\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09667089581576\", \"PhoneName\": \"sheetal\", \"Skill\": \"sunteck_realty\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"9021134576\", \"AgentUniqueID\": \"75797\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKa54cb6b0abe0ce764ba98a9f0a6976da\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"sunteck_realty\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"0091\"}}';
        res.responseBody = Blob.valueOf(json);
      req.requestURI =  'http://sandboxpu-createdigitallead.cs75.force.com/Callback1/services/apexrest/Integration/Callback1' ;
      //  req.requestURI = 'https://sbdev-totalenv.cs31.force.com/callback/services/apexrest/Integration/Callback';  
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        REST_CallbackCTI.CreateActivity();         
    } 
    
}