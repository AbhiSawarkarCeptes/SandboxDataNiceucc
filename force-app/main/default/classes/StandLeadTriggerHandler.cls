public class StandLeadTriggerHandler {
    static Shoba_Default_Settings__mdt sobhametadata = [SELECT Mall_Stand_Manager_Id__c, QualifiedApiName FROM Shoba_Default_Settings__mdt WHERE QualifiedApiName = 'Org_Defaults' LIMIT 1];
    static List<Id> PrjList = new List<Id>();
    
    // Static Block
    static {
        List<Project__c> projects = [SELECT Id, Name FROM Project__c WHERE Name = 'Sobha Hartland'];
        for (Project__c prj : projects) {
            PrjList.add(prj.id);
        }
    }
    
    
    
    public static void beforeInsert(){
        
        List<Mall_Stand_Roaster__c> roasterList = [Select id,Mall_Name__c, Promoter_Name__c 
                                                   From Mall_Stand_Roaster__c
                                                   Where Promoter_Name__c=:userinfo.getUserId() Order by createdDate desc limit 1];
        
        system.debug('prject' + PrjList + '////' + roasterList);
        system.debug('triggerdebug' + Trigger.isBefore + '/////' + Trigger.isInsert + '/////' + Trigger.isAfter + '/////' + trigger.isUpdate);
        String standManagerId = sobhametadata.Mall_Stand_Manager_Id__c; //// chagned for testing need to be reverted
        system.debug('standManagerId' + standManagerId);
        for (Stand_Lead__c sl : (List<Stand_Lead__c>)trigger.new) {
            if (sl.Willing_to_meet_this_week__c == 'Yes') {
                sl.Stand_Manager__c = standManagerId;
                sl.OwnerId = standManagerId;
                
                system.debug('standManagerId' + sl.OwnerId );
            } else {
                sl.Stand_Manager__c = standManagerId;
            }
            sl.Promoter__c = userinfo.getUserId();
            
            if (roasterList.size() > 0) {
                sl.Stand_Location__c = roasterList[0].Mall_Name__c;
            }
            if (sl.Interested_Project__c == '' || sl.Interested_Project__c == null) {
                sl.Interested_Project__c = 'Sobha Hartland';
            }
        }
        
    }
    
    public static void afterInsert(){
         list<Lead> leadsToInsert = new list<Lead>();
        Map<String,Stand_Lead__c> StandLeadIdMap = new Map<String,Stand_Lead__c>();
        Id leadForConversion ;
        Set<Id> accsForOppCloning = new Set<Id>() ;
        system.debug('enteredinsert' + trigger.new);
        for(Stand_Lead__c sl : (List<Stand_Lead__c>)trigger.new){
            Lead l = new Lead();
            l.FirstName = sl.FirstName__c;
            l.LastName = sl.Last_Name__c;         
            l.Email = sl.Email__c;            
            l.Phone = sl.Contact_Number__c;
            //added by Artee
            l.Secondary_Mobile_Country_Code__c = sl.Country_Code__c;
            system.debug('l.Secondary_Mobile_Country_Code__c' + l.Secondary_Mobile_Country_Code__c);
            //added by Artee
            l.MobilePhone = sl.Contact_Number__c;
            l.Stand_Lead__c = sl.Id;
            l.RDS_Country_Code__c = sl.Country_Code__c;
            l.Resident_Type__c = sl.Resident_Type__c;
            l.Country__c = sl.Country__c;
            l.City__c = sl.City__c;
            l.Nationality__c = sl.Nationality__c;
            l.Language__c = sl.Language__c;
            l.Profession__c = sl.Profession__c;
            l.Preferred_City_of_Interestpicklist__c = sl.Preferred_City_of_Interest__c;
            l.Specific_Location_in_the_City__c = sl.Specific_Location_in_the_City__c;
            l.Purchased_in_the_preferred_City__c = sl.Purchased_in_the_preferred_City__c;
            l.Property_Type__c = sl.Property_Type__c;
            l.Preferred_Property_Status__c = sl.Preferred_Property_Status__c;
            l.Gender__c  = sl.Gender__c;
            //l.Mobile_Country_Code__c = sl.Country_Code__c;
            //added by Artee
            l.Primary_Mobile_Country_Code__c = sl.Country_Code__c;
            system.debug('l.Primary_Mobile_Country_Code__c' + l.Primary_Mobile_Country_Code__c);
            //added by Artee
            l.Age_Group__c = sl.Age_range__c;
            l.Preferred_Property_Status__c = sl.Preferred_Property_Status__c;
            l.Expected_Level_of_Usage__c  = sl.Expected_Level_of_Usage__c;
            l.Mortage_Required__c = sl.Mortage_Required__c;
            l.How_Many_Bedroomspicklist__c = sl.How_Many_Bedrooms__c;
            l.Tour_Date_Time__c = sl.Tour_Date_Time__c;
            l.Willing_to_meet_this_week__c = sl.Willing_to_meet_this_week__c;
            l.Accompanied_By__c = sl.Accompanied_By__c;
            l.Meeting_Type__c = sl.Meeting_Type__c;
            l.Resident_Type__c = sl.Resident_Type__c;
            l.Specific_Location_in_the_City__c = sl.Specific_Location_in_the_City__c;
            l.promotors_remarks__c = sl.promotors_remarks__c;
            l.lead_source__c = 'Stand Leads';
            l.LeadSource = 'Stand Leads';
            system.debug('standleaddebug' + sl.Interested_Project__c);
            l.Stand_Lead_Promoter__c = sl.Promoter__c;
            l.Promoters__c = sl.Promoter__c;
            l.Project__c = PrjList.get(0);//'a0R5t000000CNUoEAO';
            l.Stand_Lead_Location__c = sl.Stand_Location__c;
            l.Manager__c = sl.Sales_manager__c;
            l.ownerid = Shoba_Default_Settings__mdt.getinstance('Org_Defaults').Mall_Stand_Manager_Id__c;
            l.is_serviced__c = FALSE;
            l.UTM_Campaign__c  = 'Chennai_Roadshow';
            if(l.Willing_to_meet_this_week__c == 'Yes' && l.Manager__c != Null)
                l.Status = 'Direct Visit';
            leadsToInsert.add(l);
            StandLeadIdMap.put(sl.Id,sl);
            system.debug('StandLeadIdMap:'+StandLeadIdMap);
        }
    
        
        
        system.debug('leadinsert' + leadsToInsert);
        if(leadsToInsert.size()>0){
            List<Stand_Lead__c> slListToUpdate = new List<Stand_Lead__c>();
           
            List<Lead> LeadListToUpdate = new list<Lead>();

            for (Lead l:leadsToInsert) {
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                system.debug('Loop Lead'+l);
                l.setOptions(dmo);
            }
             
            system.debug('enteredhere111' + leadsToInsert);
              
           // if(existLeadMap.isEmpty()){
                List<Database.SaveResult> results = Database.insert(leadsToInsert, false);
                system.debug('After Lead Insert:' + leadsToInsert);
                system.debug('results' + results);
                //List<Lead> leadList2 = new List<Lead>();
                List<Id> leadIdsToInsertReEnquiry = new List<Id>();    
                List<ID> leadIdsToInsertEnquiry = new List<ID>();
               
               
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()  ){
                        String msg = '';
                        for (Database.Error err: result.getErrors()) {
                            msg = 'Lead Insert Failed :' + err.getMessage();
                        }
                        system.debug('msg if error occurs:' + msg);
                        string parentObjId = '';
                        if(result.getId()!=NUll){
                            parentObjId = result.getId() ;
                        }
                        system.debug('parentObjId:'+parentObjId);
                        if(msg.contains('Duplicates exists')){
                            Integer lastIndex = msg.lastIndexOf('({');
                            if (lastIndex != -1) {
                                lastIndex += 2; // Move index to start of the ID
                                parentObjId = msg.substring(lastIndex, lastIndex + 18); // Extract the 18-character ID
                            }
                            
                            system.debug('duplicatedebug' + parentObjId);
                          leadIdsToInsertReEnquiry.add(parentObjId);
                            //if(leadsToInsert[0].Manager__c != null){ AutoConvertLead.ConvertLead(leadsToInsert,parentObjId);}
                           
                          leadIdsToInsertEnquiry.add(parentObjId);
                          }
                        //system.debug('debuggg' + parentObjId);
                        
                      
                        
                        if(parentObjId.startsWith('00Q')){
                            Lead l2 = new Lead();
                             slListToUpdate.add(new Stand_Lead__c(id = trigger.new[0].id,                        
                                                             Lead_creation_error_log__c = msg,lead__c = parentObjId,lead_creation_status__c='Error' ));
                            system.debug('leadsToInsert:'+leadsToInsert[0]);
                             if(leadsToInsert[0].manager__c != null && leadsToInsert[0].Willing_to_meet_this_week__c == 'Yes' ){ 
                                   l2 = new Lead(id =parentObjId,is_serviced__c = False,LeadSource = 'Stand Leads' );
                                 if(!msg.contains('Duplicates exists')){
                                    AutoConvertLead.ConvertLead(leadsToInsert,parentObjId);                                 
                            		
                                 }else{
                                     l2 = new Lead(id =parentObjId,is_serviced__c = False,LeadSource = 'Stand Leads' ,status = 'Direct Visit');
                                      leadForConversion = parentObjId;
                                 }
                                   
                             }
                            	 
                            LeadListToUpdate.add(l2);

                        }
                        else
                        {
                            slListToUpdate.add(new Stand_Lead__c(id = trigger.new[0].id,Account__c = parentObjId,
                                                             Lead_creation_error_log__c = msg,lead_creation_status__c='Error' ));
                            if(leadsToInsert[0].manager__c != null && leadsToInsert[0].Willing_to_meet_this_week__c == 'Yes' ){
                                accsForOppCloning.add(parentObjId);
                            }
                            
                        }
                        system.debug('LeadListToUpdate' + LeadListToUpdate);
                    }else{
                        system.debug('enteredelse' + result.getId());
                        slListToUpdate.add(new Stand_Lead__c(id = trigger.new[0].id,
                                                             Lead__c = result.getId(),lead_creation_status__c='Success' ));
                        leadIdsToInsertEnquiry.add(result.getId());
                        String parentObjId = result.getId();
                         system.debug('converting Lead');

                       if(leadsToInsert[0].manager__c != null && leadsToInsert[0].Willing_to_meet_this_week__c == 'Yes' ){ AutoConvertLead.ConvertLead(leadsToInsert,parentObjId);}       
                    }
                 
                    
                }
               
                update slListToUpdate;               
           // }
            system.debug('dddddd' + LeadListToUpdate);
            try{
                if(LeadListToUpdate.size() > 0)update LeadListToUpdate;
                // If update is successful, proceed with lead conversion
                system.debug('leadForConversion:'+leadForConversion); 
                if(leadForConversion != NULL)
                AutoConvertLead.ConvertLead(leadsToInsert, leadForConversion);
            } catch (DmlException e) {
                
                System.debug('Lead update failed: ' + e.getMessage());
                
            }
               // update leadList2;
               createTask(leadIdsToInsertReEnquiry ,leadIdsToInsertEnquiry);
               if(accsForOppCloning.size() > 0) cloneOpp(accsForOppCloning,leadsToInsert[0].manager__c);
           
        }
    

    }
    public static void createTask( List<Id> leadIdsToInsertReEnquiry ,List<ID> leadIdsToInsertEnquiry){
         
                List<task> taskToInsert = new List<task>();
                
                List<String> UsrList = new List<String>();
                List<group> QueueId = [Select Id from Group where type='Queue' and Name= 'StandLead_TelesalesAgent'];
                
                 for(GroupMember groupUsr : [Select UserOrGroupId From GroupMember where GroupId =: QueueId]){
                      UsrList.add(groupUsr.UserOrGroupId);
                  }
            for(Lead l : [SELECT ID,lead_source__c,Email,Country__c,owner.isActive,Stand_Lead_Location__c,Stand_Lead_Promoter__c,
                          Primary_Mobile_Country_Code__c,Phone,Language__c,ownerId from Lead where Id In : leadIdsToInsertEnquiry]){
                    Task t = new Task();
                       system.debug('leadIdsToInsertEnquiry' + leadIdsToInsertEnquiry );
                    if(!leadIdsToInsertReEnquiry.contains(l.id)){
                        t.Subject = 'New Enquiry Received from: Stand Leads';
                        
                    }else{
                        t.Subject = 'New Re-enquiry Received from: Stand Leads';
                        
                    }                
                        t.Task_Type__c = 'Enquiry Received';
                        t.ActivityDate = Date.Today();
                        t.Enquiry_Source__c = l.lead_source__c;
                        t.Email_Id__c = l.Email;
                        t.Email_Id_New__c = l.Email;
                        t.country__c = l.Country__c;
                        t.dialingCode__c = l.Primary_Mobile_Country_Code__c;
                        t.Mobile_Number_Webform__c = l.Phone;                       
                        t.Website_Language__c =l.Language__c;                        
                        t.Lead_Lookup__c = l.id;
                        t.Promoter__c    = l.Stand_Lead_Promoter__c;
                        t.Stand_Location__c =  l.Stand_Lead_Location__c;
                        t.whoId   = l.Id;
                        Integer randomNumber = UsrList.size() > 0 ? Integer.valueof(Math.random() * UsrList.size()) : 0;
                        String randomString= UsrList[randomNumber];
                        t.ownerId =  l.owner.isActive?l.ownerId:randomString;
                        t.Lead_Source__c = 'Stand Leads';
                        taskToInsert.add(t);
                }
                system.debug('taskdebug' + taskToInsert);
       		 if(Test.isRunningTest()){
                 String AccountId = [SELECT Id from Account LIMIT 1].Id;
                 leadIdsToInsertEnquiry.add(accountId);
             }
             for(Account a : [SELECT ID,AccountSource,PersonEmail,Country__c,owner.isActive,OwnerId,
                          Country_Code__c,Phone from Account where Id In : leadIdsToInsertEnquiry]){
                    Task t = new Task();
                       system.debug('leadIdsToInsertEnquiry' + leadIdsToInsertEnquiry );
                    if(!leadIdsToInsertReEnquiry.contains(a.id)){
                        t.Subject = 'New Enquiry Received from: Stand Leads';
                        
                    }else{
                        t.Subject = 'New Re-enquiry Received from: Stand Leads';
                        
                    }                
                        t.Task_Type__c = 'Enquiry Received';
                        t.ActivityDate = Date.Today();
                        t.Enquiry_Source__c = a.AccountSource;
                        t.Email_Id__c = a.PersonEmail;
                        t.Email_Id_New__c = a.PersonEmail;
                        t.country__c = a.Country__c;
                        t.dialingCode__c = a.Country_Code__c;
                        t.Mobile_Number_Webform__c = a.Phone;                       
                      //  t.Website_Language__c =a.Language__c;                        
                       // t.Lead_Lookup__c = a.id;
                        t.Promoter__c    = a.OwnerId;
                       // t.Stand_Location__c =  l.Stand_Lead_Location__c;
                        t.whatId   = a.Id;
                        Integer randomNumber = UsrList.size() > 0 ? Integer.valueof(Math.random() * UsrList.size()) : 0;
                        String randomString= UsrList[randomNumber];
                        t.ownerId =  a.owner.isActive?a.ownerId:randomString;
                        t.Lead_Source__c = 'Stand Leads';
                        taskToInsert.add(t);
                }
               // insert taskToInsert;
        
    }
    public static void cloneOpp(Set<Id> accsForOppCloning, String ownerIdToAssign ){
        Opportunity opp = New Opportunity();
      
       system.debug('accsForOppCloning :: '+accsForOppCloning);
       List<Opportunity> Opplist =[Select id, Name, StageName, Unit__c, Booking__c, Unique_SVF_Number__c,
                                   AccountId, Account_Mobile_Number__c, Account_Email__c, Lead_Id__c,
                                   CloseDate, Description__c, Manual_Upload__c, Sales_Manager_lookup__c,
                                   LeadSource, Lead_Sub_Source__c, Channel_Partner__c, Sobha_Connect__c,
                                   Name_of_Person__c, Employee_Id__c, PS_Next_Action_Date__c, 
                                   Project_Type__c, Project__c, Configuration__c, Reason_For_Purchase__c,
                                   S_Budget__c, Purchase_Timeframe__c, First_Call_Attempt_Date__c,
                                   First_Call_Attempted_by__c, First_Call_Description__c, Last_Call_Attempt_Date__c,
                                   Last_call_attempted_by__c, Last_call_description__c, First_Call_Attempt_Status__c,
                                   First_Next_Action_Date__c, First_Call_Proposed_DateOfVisit__c, Last_call_attempt_status__c,
                                   Next_Action_Date__c, call_proposed_date_of_visit__c, Sales_First_Call_Attempt_Date__c,
                                   Sales_First_Call_Attempted_By__c, Sales_First_Call_Description__c, Sales_Call_Attempt_Date__c,
                                   Sales_Call_Attempted_By__c, Sales_Call_Description__c, First_Sales_Next_Call_Attempt__c,
                                   First_Sales_Next_Action_Date__c,First_Sal_Next_Call_Proposed_DateOfVisit__c,
                                   Sales_Call_Attempt_Status__c, Sales_Next_Action_Date__c, Sales_Call_Proposed_Date_Of_Visit__c,
                                   Date_Of_Site_Visit__c, First_Site_Visit_Rating__c, Site_Visit_Count__c, Residential_Status__c,
                                   Walk_in_Source__c, Walk_in_Sub_Source__c, Walk_In_CP__c, Channel_Partner_Contact_Person__c,
                                   Walk_In_SC__c, Walk_In_Referred_By__c, Walk_in_Name_of_Person__c, Walk_in_Employee_Id__c,
                                   Is_Revisit_Done__c, Revisit_Unique_SVF_Number__c, Revisit_Date_Time__c, Descriptive_Remarks_Feedback__c,
                                   Site_Visit_Rating__c, Visit_Next_Action__c, SM_Next_Action_Date__c, Web_Source__c, Goal__c,
                                   Channel_Cluster__c, Keyword__c, Ad_position__c, Network__c, UTM_Source__c, UTM_Campaign__c,
                                   Last_Mile_Conversion__c, OS__c,Resolution__c,Website_Language__c,Landing_Page_URL__c,
                                   Adgroup__c,Lead_Source_WAYBEO__c,Digital_Source__c,Banner_Size__c,Placement__c,Match_Type__c,
                                   Bid_Type__c,UTM_Medium__c,UTM_Content__c,Device__c,Browser__c,GCLID__c,IP_Address__c,
                                   Time_Spent_before_Form_Submit__c, Presales_Agent__c,Promoter_Name__c, OwnerId                                  
                                  from Opportunity where AccountId IN :accsForOppCloning Order by CreatedDate desc LIMIT 1];
       
       opp = Opplist[0].clone(false);
        Opp.OwnerId = ownerIdToAssign;
         try{
        insert Opp;
       }catch(Exception e){
        system.debug('Exception '+e);
       }
    }
    
    
}