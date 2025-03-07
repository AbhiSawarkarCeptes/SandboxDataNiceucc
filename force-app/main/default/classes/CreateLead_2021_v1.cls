@RestResource(urlMapping = '/pushLead/2021/v1/*')
Global Class CreateLead_2021_v1 {
    @HttpPost
    Global Static List<ResponseWrapper> doPost() {
        List<ResponseWrapper> rwList = new List<ResponseWrapper>();
        Savepoint sp = Database.setSavepoint();
        try {
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            System.debug('========== Request : '+json);
            if(system.label.AsyncLeadCreation == 'true' && !Test.isRunningTest()){
                system.debug('========== inside async lead creation');
                Lead_Creation__e  evt = new Lead_Creation__e();
                evt.Payload__c = json;
                EventBus.publish(evt);
                
                ResponseWrapper rw = new ResponseWrapper();
                rw.success = True;
                rw.message = 'Successfully Processed';
                rwList.add(rw);
                
                return rwList;
            }
            system.debug('========== outside async lead creation');
            DateTime startTime = system.now();
            List<CreateLeadParser> parserList = CreateLeadParser.parse(json);
            DateTime endTime = system.now();
        	system.debug('VVK Parser Execution Time: '+string.valueOf((endTime.getTime()-startTime.getTime())));
            
            Set<String> emails = new Set<String>();
            Set<String> phones = new Set<String>();
            
            Set<String> emailsV2 = new Set<String>();
            Set<String> phonesV2 = new Set<String>();
            
            for(CreateLeadParser parser : parserList) {
                if(parser.Email != null) {
                    emails.add(parser.Email);
                }
                if(parser.Mobile_Phone != null) {
                    phones.add(parser.Mobile_Phone);
                } 
                if(parser.Phone != null) {
                    phones.add(parser.Phone);
                }
            }
            
            List<Task> taskList = new List<Task>(); //=========> Which Obejct to use?: Task/Activity
            
            //===Checking : if exists in Lead==========
            List<Lead> lList = [SELECT Id, Email, Primary_Number__c, MobilePhone, ownerId,owner.isActive,Alternate_Mobile_Number__c, Phone, Office_Phone__c FROM Lead WHERE Email IN: emails OR MobilePhone IN: phones OR Alternate_Mobile_Number__c IN: phones OR Office_Phone__c IN: phones OR Phone IN: phones OR Primary_Number__c IN: phones];
            list<lead> leadToUpdateOwner = new list<lead>();
            list<lead> inactiveOwnerLeadList = [Select Id, OwnerId, Owner.IsActive from Lead where id in : lList and Owner.IsActive = false];
            Shoba_Default_Settings__mdt sett = [select Id, Tele_Sales_Head_User_Id__c from Shoba_Default_Settings__mdt where developername = 'Org_Defaults'];
            if(inactiveOwnerLeadList.size()>0 && sett.Tele_Sales_Head_User_Id__c != null){
                for(lead l : inactiveOwnerLeadList){
                    l.OwnerId = sett.Tele_Sales_Head_User_Id__c;
                    l.Presales_Agent__c = sett.Tele_Sales_Head_User_Id__c;
                    leadToUpdateOwner.add(l);
                }
                if(leadToUpdateOwner.size() > 0){
                    try{
                        Database.update(leadToUpdateOwner,false);
                    }
                    catch(Exception e){
                        system.debug('VVK Lead Owner Update Error: '+e.getMessage());
                    }
                }
            }
            lList = [SELECT Id, Email, Primary_Number__c, MobilePhone, ownerId,owner.isActive,Alternate_Mobile_Number__c, Phone, Office_Phone__c FROM Lead WHERE Email IN: emails OR MobilePhone IN: phones OR Alternate_Mobile_Number__c IN: phones OR Office_Phone__c IN: phones OR Phone IN: phones OR Primary_Number__c IN: phones];
            List<group> groupsForLead = [SELECT ID,Name FROM group WHERE  Name IN ('RUSSIAN Group For PSTL', 'Super Agent - English Language','Sunday Queue For Lead Assignments','Saturday Queue For Lead Assignments')];
            Map<String,ID> mapgroupNameToId = new Map<String,ID>();
            for(Group gr : groupsForLead){
                mapgroupNameToId.put(gr.Name, gr.Id);
            }
            
            
            Datetime dt = System.now();
            String dayOfWeek = dt.format('EEEE');
            Integer Hour = dt.hour();
            List<Lead> leadList2 = new List<Lead>();
            list<Assignment_Groups__c> assignmentGroup = [select Id,User__c from Assignment_Groups__c 
                                                          where Group_Name__r.Name='Normal Agent Group' AND 
                                                          Active__c='True' AND User_Active__c='True' AND User__c!=null];
            if(lList != null && lList.size() > 0) {
                for(Lead l : llist) {
                    //===Creating Re-Enquiry Task as the Lead exists in system===Map other fileds as well===
                    for(CreateLeadParser parser : parserList) {
                        if((parser.Email == l.Email) || (parser.Mobile_Phone == l.Primary_Number__c) || (parser.Mobile_Phone == l.MobilePhone) || (parser.Mobile_Phone == l.Alternate_Mobile_Number__c) || (parser.Mobile_Phone == l.Phone) || (parser.Mobile_Phone == l.Office_Phone__c) || (parser.Phone == l.Primary_Number__c) || (parser.Phone == l.MobilePhone) || (parser.Phone == l.Alternate_Mobile_Number__c) || (parser.Phone == l.Phone) || (parser.Phone == l.Office_Phone__c)) {
                            Task t = new Task();
                            t.Subject = 'Re Enquiry Received from:'+parser.Lead_Source;
                            t.Task_Type__c = 'Enquiry Received';
                            t.WhoId = l.Id;
                            
                            
                            t.ActivityDate = Date.Today();
                            t.Enquiry_Source__c = parser.Lead_Source;
                            t.Web_Source__c = parser.Web_Source;
                            t.Enquiry_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source )? parser.Lead_Sub_Source : parser.Web_Source;
                            t.Adgroup__c = parser.AD_Group;
                            t.Keyword__c = parser.Keyword;
                            t.Placement__c = parser.Placement;
                            t.Channel_Cluster__c = parser.Channel_Cluster;
                            t.Goal__c = parser.Goal;
                            t.Digital_Source__c = parser.Digital_Source;
                            t.UTM_Source__c = parser.UTM_Source;
                            t.UTM_Medium__c = parser.UTM_Medium;
                            t.UTM_Campaign__c = parser.UTM_Campaign;
                            t.UTM_Content__c = parser.UTM_Content;
                            if(parser.utmTerm != null){
                                t.UTM_Term__c = parser.utmTerm;
                            }
                            t.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                            t.Bid_Type__c = parser.Bid_Type;
                            t.Email_Id__c = parser.Email;
                            t.Email_Id_New__c = parser.Email;
                            t.country__c = parser.Dialing_Country;
                            t.dialingCode__c = parser.Country_Code;
                            t.Mobile_Number_Webform__c = parser.Mobile_Phone;
                            t.Website_Language__c = parser.Website_Language;
                            t.status = 'Completed';
                            t.Lead_Lookup__c = l.id;
                            t.ownerId = l.owner.isActive?l.ownerId:(assignmentGroup.size()>0)?assignmentGroup[0].User__c:UserInfo.getUserId();
                            
                            Lead l2 = new Lead();
                            l2.Id = l.Id;
                            l2.is_serviced__c = False;
                            l2.OwnerId = l.owner.isActive?l.ownerId:(assignmentGroup.size()>0)?assignmentGroup[0].User__c:UserInfo.getUserId();
                            l2.Presales_Agent__c = l.owner.isActive?l.ownerId:(assignmentGroup.size()>0)?assignmentGroup[0].User__c:UserInfo.getUserId();
                            
                            taskList.add(t);
                            leadList2.add(l2);
                        }
                    }
                    //===Removing values wich are already existing in Lead===
                    emails.remove(l.Email);
                    phones.remove(l.MobilePhone);
                    phones.remove(l.Alternate_Mobile_Number__c);
                    phones.remove(l.Phone);
                    phones.remove(l.Office_Phone__c);
                    phones.remove(l.Primary_Number__c);
                    
                    emailsV2.add(l.Email);
                    phonesV2.add(l.MobilePhone);
                    phonesV2.add(l.Alternate_Mobile_Number__c);
                    phonesV2.add(l.Phone);
                    phonesV2.add(l.Office_Phone__c);
                    phonesV2.add(l.Primary_Number__c);
                    
                }
            }
            //===Checking : if exists in Account===
            List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Name = : 'Sobha Hartland'];  //
            
            List<Account> accList = [SELECT Id, Name, Alternate_Email__c, PersonEmail, Email_Correspondence__c, Email_ID_1__c, Email_ID_2__c, Email_Local__c, Email_Permanent__c, Email__c, Key_Person_Email__c, Alternate_Mobile_No__c, PersonMobilePhone, Mobile__c, Mobile_correspondence__c, Mobile_Local__c, Mobile_No__c, Mobile_Permanent__c, Mobile1__c, Mobile2__c, Alternate_office_phone_number__c, PersonHomePhone, PersonOtherPhone, Phone__c, Phone, Phone_Correspondence__c, Phone_Local__c, Office_phone_number__c, Phone_Permanent__c FROM Account WHERE Alternate_Email__c IN: emails OR PersonEmail IN: emails OR Email_Correspondence__c IN: emails OR Email_ID_1__c IN: emails OR Email_ID_2__c IN: emails OR Email_Local__c IN: emails OR Email_Permanent__c IN: emails OR Email__c IN: emails OR Key_Person_Email__c IN: emails OR Alternate_Mobile_No__c IN: phones OR PersonMobilePhone IN: phones OR Mobile__c IN: phones OR Mobile_correspondence__c IN: phones OR Mobile_Local__c IN: phones OR Mobile_No__c IN: phones OR Mobile_Permanent__c IN: phones OR Mobile1__c IN: phones OR Mobile2__c IN: phones OR Alternate_office_phone_number__c IN: phones OR PersonHomePhone IN: phones OR PersonOtherPhone IN: phones OR Phone__c IN: phones OR Phone IN: phones OR Phone_Correspondence__c IN: phones OR Phone_Local__c IN: phones OR Office_phone_number__c IN: phones OR Phone_Permanent__c IN: phones];
            List<Account> accsToUpdate = new List<Account>();
            if(accList.size() > 0) {
                for(Account a : accList) {
                    //===Creating Re-Enquiry Task as the Account exists in system===
                    for(CreateLeadParser parser : parserList) {
                        if((parser.Email == a.Alternate_Email__c) || (parser.Email == a.PersonEmail) || (parser.Email == a.Email_Correspondence__c) || (parser.Email == a.Email_ID_1__c) || (parser.Email == a.Email_ID_2__c) || (parser.Email == a.Email_Local__c) || (parser.Email == a.Email_Permanent__c) || (parser.Email == a.Email__c) || (parser.Email == a.Key_Person_Email__c) || (parser.Mobile_Phone == a.Alternate_Mobile_No__c) || (parser.Mobile_Phone == a.PersonMobilePhone) || (parser.Mobile_Phone == a.Mobile__c) || (parser.Mobile_Phone == a.Mobile_correspondence__c) || (parser.Mobile_Phone == a.Mobile_Local__c) || (parser.Mobile_Phone == a.Mobile_No__c) || (parser.Mobile_Phone == a.Mobile_Permanent__c) || (parser.Mobile_Phone == a.Mobile1__c) || (parser.Mobile_Phone == a.Mobile2__c) || (parser.Mobile_Phone == a.Alternate_office_phone_number__c) || (parser.Mobile_Phone == a.PersonHomePhone) || (parser.Mobile_Phone == a.PersonOtherPhone) || (parser.Mobile_Phone == a.Phone__c) || (parser.Mobile_Phone == a.Phone) || (parser.Mobile_Phone == a.Phone_Correspondence__c) || (parser.Mobile_Phone == a.Phone_Local__c) || (parser.Mobile_Phone == a.Office_phone_number__c) || (parser.Mobile_Phone == a.Phone_Permanent__c) || 
                           (parser.Phone == a.Alternate_Mobile_No__c) || (parser.Phone == a.PersonMobilePhone) || (parser.Phone == a.Mobile__c) || (parser.Phone == a.Mobile_correspondence__c) || (parser.Phone == a.Mobile_Local__c) || (parser.Phone == a.Mobile_No__c) || (parser.Phone == a.Mobile_Permanent__c) || (parser.Phone == a.Mobile1__c) || (parser.Phone == a.Mobile2__c) || (parser.Phone == a.Alternate_office_phone_number__c) || (parser.Phone == a.PersonHomePhone) || (parser.Phone == a.PersonOtherPhone) || (parser.Phone == a.Phone__c) || (parser.Phone == a.Phone) || (parser.Phone == a.Phone_Correspondence__c) || (parser.Phone == a.Phone_Local__c) || (parser.Phone == a.Office_phone_number__c) || (parser.Phone == a.Phone_Permanent__c)) {
                               Task t = new Task();
                               t.Subject = 'Re Enquiry Received from:'+parser.Lead_Source;
                               t.WhatId = a.Id;
                               t.ActivityDate = Date.Today();
                               t.Enquiry_Source__c = parser.Lead_Source;
                               t.Web_Source__c = parser.Web_Source;
                               t.Enquiry_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source) ? parser.Lead_Sub_Source : parser.Web_Source;
                               t.Adgroup__c = parser.AD_Group;
                               t.Keyword__c = parser.Keyword;
                               t.Placement__c = parser.Placement;
                               t.Channel_Cluster__c = parser.Channel_Cluster;
                               t.Goal__c = parser.Goal;
                               t.Digital_Source__c = parser.Digital_Source;
                               t.UTM_Source__c = parser.UTM_Source;
                               t.UTM_Medium__c = parser.UTM_Medium;
                               t.UTM_Campaign__c = parser.UTM_Campaign;
                               t.UTM_Content__c = parser.UTM_Content;
                               if(parser.utmTerm != null){
                                   t.UTM_Term__c = parser.utmTerm;
                               }
                               t.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                               t.Bid_Type__c = parser.Bid_Type;
                               t.Email_Id__c = parser.Email;
                               t.Email_Id_New__c = parser.Email;
                               t.country__c = parser.Dialing_Country;
                               t.dialingCode__c = parser.Country_Code;
                               t.Mobile_Number_Webform__c = parser.Mobile_Phone;
                               //t.Phone = parser.Phone;
                               t.Website_Language__c = parser.Website_Language;
                               
                               //t.ProjectInterestedWeb__c  = parser.Project;
                               t.status = 'Completed';
                               taskList.add(t);
                               
                               Account a2 = new Account();
                               a2.Id = a.Id;
                               a2.is_serviced__c = False;
                               a2.Time_of_New_Enquiry__c = System.Now();
                               accsToUpdate.add(a2);
                           }
                    }
                    //=====Removing values wich are already existing in Opportunity=====
                    emails.remove(a.Alternate_Email__c);
                    emails.remove(a.PersonEmail);
                    emails.remove(a.Email_Correspondence__c);
                    emails.remove(a.Email_ID_1__c);
                    emails.remove(a.Email_ID_2__c);
                    emails.remove(a.Email_Local__c);
                    emails.remove(a.Email_Permanent__c);
                    emails.remove(a.Email__c);
                    emails.remove(a.Key_Person_Email__c);
                    phones.remove(a.Alternate_Mobile_No__c);
                    phones.remove(a.PersonMobilePhone);
                    phones.remove(a.Mobile__c);
                    phones.remove(a.Mobile_correspondence__c);
                    phones.remove(a.Mobile_Local__c);
                    phones.remove(a.Mobile_No__c);
                    phones.remove(a.Mobile_Permanent__c);
                    phones.remove(a.Mobile1__c);
                    phones.remove(a.Mobile2__c);
                    phones.remove(a.Alternate_office_phone_number__c);
                    phones.remove(a.PersonHomePhone);
                    phones.remove(a.PersonOtherPhone);
                    phones.remove(a.Phone__c);
                    phones.remove(a.Phone);
                    phones.remove(a.Phone_Correspondence__c);
                    phones.remove(a.Phone_Local__c);
                    phones.remove(a.Office_phone_number__c);
                    phones.remove(a.Phone_Permanent__c);
                    
                    emailsV2.add(a.Alternate_Email__c);
                    emailsV2.add(a.PersonEmail);
                    emailsV2.add(a.Email_Correspondence__c);
                    emailsV2.add(a.Email_ID_1__c);
                    emailsV2.add(a.Email_ID_2__c);
                    emailsV2.add(a.Email_Local__c);
                    emailsV2.add(a.Email_Permanent__c);
                    emailsV2.add(a.Email__c);
                    emailsV2.add(a.Key_Person_Email__c);
                    phonesV2.add(a.Alternate_Mobile_No__c);
                    phonesV2.add(a.PersonMobilePhone);
                    phonesV2.add(a.Mobile__c);
                    phonesV2.add(a.Mobile_correspondence__c);
                    phonesV2.add(a.Mobile_Local__c);
                    phonesV2.add(a.Mobile_No__c);
                    phonesV2.add(a.Mobile_Permanent__c);
                    phonesV2.add(a.Mobile1__c);
                    phonesV2.add(a.Mobile2__c);
                    phonesV2.add(a.Alternate_office_phone_number__c);
                    phonesV2.add(a.PersonHomePhone);
                    phonesV2.add(a.PersonOtherPhone);
                    phonesV2.add(a.Phone__c);
                    phonesV2.add(a.Phone);
                    phonesV2.add(a.Phone_Correspondence__c);
                    phonesV2.add(a.Phone_Local__c);
                    phonesV2.add(a.Office_phone_number__c);
                    phonesV2.add(a.Phone_Permanent__c);
                    
                }
            }
            insert taskList;
            update leadList2;
            update accsToUpdate;
            
            Map<String, Task> leadTaskMap = new Map<String, Task>();
            List<Lead> leadList = new List<Lead>();
            for(CreateLeadParser parser : parserList) {
                if((!emailsV2.contains(parser.Email)) && (!phonesV2.contains(parser.Phone)) && (!phonesV2.contains(parser.Mobile_Phone))) {
                    //===============Lead===================
                    Lead l = new Lead();
                    l.LastName = parser.lastName;
                    l.firstName = parser.firstName;
                    l.Lead_Source__c = parser.Lead_Source;
                    l.LeadSource = parser.Lead_Source;
                    l.Web_Source__c = parser.Web_Source;
                    l.Lead_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source ) ? parser.Lead_Sub_Source : parser.Web_Source;
                    l.Adgroup__c = parser.AD_Group;
                    l.Keyword__c = parser.Keyword;
                    l.Placement__c = parser.Placement;
                    l.Channel_Cluster__c = parser.Channel_Cluster;
                    l.Goal__c = parser.Goal;
                    l.Digital_Source__c = parser.Digital_Source;
                    l.UTM_Source__c = parser.UTM_Source;
                    l.UTM_Medium__c = parser.UTM_Medium;
                    l.UTM_Campaign__c = parser.UTM_Campaign;
                    l.UTM_Content__c = parser.UTM_Content;
                    //Added by Mohit as part of SOB - 760
                    if(parser.UTM_AdId != null){
                        l.UTM_Ad_id__c   = parser.UTM_AdId;
                    }if(parser.UTM_Adset != null){
                        l.UTM_Adset__c    = parser.UTM_Adset;
                    }if(parser.UTM_AdsetId != null){
                        l.UTM_Adset_id__c= parser.UTM_AdsetId;
                    }if(parser.UTM_Company != null){
                        l.UTM_Company__c= parser.UTM_Company;
                    }if(parser.UTM_Country != null){
                        l.UTM_Country__c= parser.UTM_Country;
                    }if(parser.UTM_Creative != null){
                        l.UTM_Creative__c= parser.UTM_Creative;
                    }if(parser.UTM_Language != null){
                        l.UTM_Language__c= parser.UTM_Language;
                    }if(parser.UTM_CampaignId != null){
                        l.UTM_Campaign_id__c= parser.UTM_CampaignId;
                    }
                    l.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                    l.Bid_Type__c = parser.Bid_Type;
                    l.Email = parser.Email;
                    l.RDS_Country__c = parser.Dialing_Country;
                    l.RDS_Country_Code__c = parser.Country_Code;
                    l.MobilePhone = parser.Mobile_Phone;
                    l.Phone = parser.Phone;
                    l.Website_Language__c = parser.Website_Language;
                    l.Website_Language__c = parser.Website_Language;
                    l.Project_Type__c = parser.Project_Type;
                    If(p.size()>0){
                        l.Project__c = p[0].id;}
                    l.Budget_In_Lacs__c = parser.BudgetInUsd;
                    l.RDS_Unit_type_configuration__c = parser.BedroomType;
                    l.GCLID__c = parser.GCLID;
                    if(parser.Nationality != null){
                        l.Nationality__c = parser.Nationality;
                    }
                    if(parser.RDS_Country_Code != null){
                        l.RDS_Country_Code__c = parser.RDS_Country_Code;
                    }
                    if(parser.Preferre_Method_of_Contact != null){
                        l.Preferred_Method_of_Contact__c = parser.Preferre_Method_of_Contact;                        
                    }
                    
                    if(parser.News_Offers_subscription){
                        l.News_Offer_Subscription__c = parser.News_Offers_subscription;
                    }
                    if(parser.Project_Name != null){
                        l.Project_Name__c = parser.Project_Name;
                    }
                    
                    if(parser.Privacy_Policy_Acknowledgement){
                        l.Privacy_Policy_Acknowledgement__c = parser.Privacy_Policy_Acknowledgement;
                    }
                    
                    l.Campaign_Code__c = parser.campaign_Code;
                    l.Campaign_Name__c = parser.Campaign_Name;
                    if(parser.Ad_set_ID != null){
                        l.Ad_set_ID__c = parser.Ad_set_ID;
                    }
                    if(parser.Time_Spent_before_Form_Submit != null){
                        l.Time_Spent_before_Form_Submit__c = parser.Time_Spent_before_Form_Submit;
                    }
                    if(parser.IP_Address != null){
                        l.IP_Address_Web2Lead__c = parser.IP_Address;
                    }
                    if(parser.Landing_Page_URL != null){
                        l.Landing_Page_URL__c = parser.Landing_Page_URL;
                    }
                    if(parser.Platform != null){
                        l.Platform__c = parser.Platform;
                    }
                    if(parser.Browser != null){
                        l.Browser__c = parser.Browser;
                    }
                    if(parser.network != null){
                        l.network__c = parser.network;
                    }
                    if(parser.Resolution != null){
                        l.Resolution__c = parser.Resolution;
                    }
                    if(parser.OS != null){
                        l.OS__c = parser.OS;
                    }
                    if(parser.Device != null){
                        l.Device__c = parser.Device;
                    }
                    if(parser.utmTerm != null){
                        l.UTM_Term__c = parser.utmTerm;
                    }
                    if(parser.Project_Name != null){
                        l.Project_Name__c = parser.Project_Name;
                    }
                    if(parser.UTM_adgroup != null){
                        l.UTM_Adgroup__c = parser.UTM_adgroup;
                    }
                    if(parser.areYouLookingFor!=null){
                        l.Are_you_looking_for__c = parser.areYouLookingFor;
                    }
                    
                    Task t = new Task();
                    t.Subject = 'New Enquiry Received from:'+parser.Lead_Source;
                    t.WhoId = l.Id;
                    t.Task_Type__c = 'Enquiry Received';
                    t.ActivityDate = Date.Today();
                    t.Enquiry_Source__c = parser.Lead_Source;
                    t.Web_Source__c = parser.Web_Source;
                    t.Enquiry_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source ) ? parser.Lead_Sub_Source : parser.Web_Source;
                    t.Adgroup__c = parser.AD_Group;
                    t.Keyword__c = parser.Keyword;
                    t.Placement__c = parser.Placement;
                    t.Channel_Cluster__c = parser.Channel_Cluster;
                    t.Goal__c = parser.Goal;
                    t.Digital_Source__c = parser.Digital_Source;
                    t.UTM_Source__c = parser.UTM_Source;
                    t.UTM_Medium__c = parser.UTM_Medium;
                    t.UTM_Campaign__c = parser.UTM_Campaign;
                    t.UTM_Content__c = parser.UTM_Content;
                    if(parser.utmTerm != null){
                        t.UTM_Term__c = parser.utmTerm;
                    }
                    t.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                    t.Bid_Type__c = parser.Bid_Type;
                    t.Email_Id__c = parser.Email;
                    t.Email_Id_New__c = parser.Email; 
                    t.country__c = parser.Dialing_Country;
                    t.dialingCode__c = parser.Country_Code;
                    t.Mobile_Number_Webform__c = parser.Mobile_Phone;
                    
                    if(parser.Privacy_Policy_Acknowledgement){
                        t.Privacy_Policy_Acknowledgement__c = parser.Privacy_Policy_Acknowledgement;
                    }
                    if(parser.News_Offers_subscription){
                        t.News_Offer_Subscription__c =  parser.News_Offers_subscription;
                    }
                    if(parser.Landing_Page_URL != null){
                        //t.Landing_Page_URL__c = parser.Landing_Page_URL;
                    }
                    if(parser.MatchType != null){
                        t.Match_Type__c = parser.MatchType;
                    }
                    if(parser.OS != null){
                        t.OS__c = parser.OS;
                    }
                    if(parser.Placement != null){
                        t.Placement__c = parser.Placement;
                    }
                    if(parser.Resolution != null){
                        t.Resolution__c = parser.Resolution;
                    }
                    if(parser.IP_Address != null){
                        t.IP_Address_Web2Lead__c = parser.IP_Address;
                    }
                    if(parser.Website_Language != null){
                        t.Website_Language__c = parser.Website_Language;
                    }
                    if(parser.areYouLookingFor!=null){
                        t.Are_you_looking_for__c = parser.areYouLookingFor;
                    }
                    
                    t.Lead_Lookup__c = l.id;
                    
                    leadTaskMap.put(l.LastName,t);
                    if(((dayOfWeek == 'Friday' && hour >= 19) || dayOfWeek == 'Saturday' || (dayOfWeek == 'Sunday' && hour < 19)||Test.isRunningTest())
                       && mapgroupNameToId.containsKey('Saturday Queue For Lead Assignments') && mapgroupNameToId.containsKey('Sunday Queue For Lead Assignments'))
                    {
                        if((dayOfWeek == 'Friday' && hour >= 19) || (dayOfWeek == 'Saturday' && hour <19) ||Test.isRunningTest()){
                            //l.Route_To_Saturday_Queue1__c = true;
                            //   l.ownerId = mapgroupNameToId.get('Saturday Queue For Lead Assignments');
                        }
                        else if((dayOfWeek == 'Saturday' && hour >= 19) || (dayOfWeek == 'Sunday' && hour <19)){
                            //l.Route_To_Sunday_Queue1__c = true;
                            //   l.ownerId = mapgroupNameToId.get('Sunday Queue For Lead Assignments');
                        }
                    }
                    /*   else if((parser.web_source == 'tas-programmatic-russia-ru' 
                    || parser.Lead_Sub_Source == 'tas-programmatic-russia-ru')&& mapgroupNameToId.containsKey('RUSSIAN Group For PSTL')){
                    l.ownerId = mapgroupNameToId.get('RUSSIAN Group For PSTL');
                    }else if(mapgroupNameToId.containsKey('Super Agent - English Language')){
                    l.ownerId = mapgroupNameToId.get('Super Agent - English Language');
                    } */
                    leadList.add(l);
                    
                    emails.remove(parser.Email);
                    phones.remove(parser.Phone);
                    phones.remove(parser.Mobile_Phone);
                    
                    emailsV2.add(parser.Email);
                    phonesV2.add(parser.Phone);
                    phonesV2.add(parser.Mobile_Phone);
                }
                insert leadList;
                //  AssignLeadsUsingAssignmentRules ass = new AssignLeadsUsingAssignmentRules();
                //  AssignLeadsUsingAssignmentRules.LeadAssign(leadList);
                List < Id > IdList = new List < Id > ();
                if(leadList != null && leadList.size() > 0){
                    IdList.add(leadList[0].Id);
                    CreateLead_2021_v1 cr = new CreateLead_2021_v1();
                    cr.LeadAssign(IdList);
                }
                
                Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id,OwnerId,Owner.isActive FROM Lead WHERE ID IN : leadList]);
                List<Task> tList = new List<Task>();
                for(Lead l : leadList) {
                    Task t = leadTaskMap.get(l.LastName);
                    t.WhoId = l.Id;
                    String leadOWnerId = leadMap.get(l.id).ownerId;
                    system.debug('1---'+leadOwnerId.startsWith('005'));
                    system.debug('2---'+l.Owner.isActive );
                    if(leadOwnerId.startsWith('005') && leadMap.get(l.id).Owner.isActive ==true){
                        t.ownerId = leadMap.get(l.id).ownerId;
                    }
                    tList.add(t);
                }
                insert tList;
            }
            
            ResponseWrapper rw = new ResponseWrapper();
            rw.success = True;
            rw.message = 'Successfully Processed';
            rwList.add(rw);
            
        }catch (Exception Ex) {
            system.debug('exdebug' + ex.getMessage() + '////' + ex.getLineNumber());
            Database.rollback(sp);
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'CreateLead_2021_v1';
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            logError.Request__c = json;
            insert logError;
            ResponseWrapper rw = new ResponseWrapper();
            rw.success = False;
            rw.message = Ex.getMessage();
            rwList.add(rw);
        } 
        return rwList;
    }
    
    public void LeadAssign(List < Id > leadIds){
        System.debug('leadids : '+leadIds);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        Lead Leads = [select id, ownerId from lead where lead.id in : leadIds];
        Leads.setOptions(dmo);
        update Leads;
        // List < lead > leadList = new List < Lead > ();
        //  leadList = [select id, ownerId from lead where lead.id in : LeadIds];
    }
    
    Global Class ResponseWrapper {
        Global Boolean success;
        Global String message;
    }
}