public class TaskManagementServices {
    public static String className = TaskManagementServices.class.getName();
    public static boolean processReEnquiryTasksFirstFunFlag = true;
    
    public static Map < Id, Task > createTaskforEnquiries(Map < Id, Lead > enquiriesMap) {
        List < task > taskList = new List < Task > ();
        List < task > retTaskList = new List < Task > ();
        List < Id > taskIds = new List < Id > ();
        Map < Id, Task > taskWhoIdMap = new Map < Id, Task > ();
        List < Id > aSet = new List < Id > ();
        List < Id > lSet = new List < Id > ();
        Map < Id, Account > accDetails = new Map < Id, Account > ();
        Map < Id, Lead > leadDetails = new Map < Id, Lead > ();
        Set<String> leadOwnerSet = new Set<String>();
        System.debug('Enquiries Map:' + enquiriesMap);
        List<String> UsrList = new List<String>();
        List<String> QueueId = new List<String>();
        List<Task> taskListCount = new list<Task>();

        if (!enquiriesMap.isEmpty()) {
            for (Id wid: enquiriesMap.keyset()) {
                if (wId.getSObjectType().getDescribe().getName() == 'Account') {
                    aSet.add(wid);
                } else if (wId.getSObjectType().getDescribe().getName() == 'Lead') {
                    lSet.add(wid);
                } else {

                }
            }

            // if the task is to be associated with an person account, then the personcontactId has to be mapped in whoId

            if (!aSet.isEmpty()) {
                accDetails = new Map < Id, Account > ([Select Id, PersonContactId, OwnerId from Account where id in : aSet]);
            }

            if (!lset.isEmpty()) {
                list<lead> leadToUpdateOwner = new list<lead>();
                list<lead> leadList = [Select Id, OwnerId, Owner.IsActive from Lead where id in : lSet and Owner.IsActive = false];
                list<Assignment_Groups__c> assignmentGroup = [select Id,User__c from Assignment_Groups__c 
                                       where Group_Name__r.Name='Normal Agent Group' AND Active__c='True' AND User_Active__c='True' AND User__c!=null];
                if(leadList.size()>0 && assignmentGroup.size()>0){
                    for(lead l : leadList){
                        l.OwnerId = assignmentGroup[0].User__c;
                        l.Presales_Agent__c = assignmentGroup[0].User__c;
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
                leadDetails = new Map < Id, Lead > ([Select Id, OwnerId,Last_Call_Attempt_Status__c,Previous_Last_Call_Attempt_Status__c from Lead where id in : lSet]);
            }

            System.debug('LEAD DETAILS:' + leadDetails);
            System.debug('ACCOUNT DETAILS:' + accDetails);
            
            for(Id leadowner : enquiriesMap.keyset()){
                System.debug('entereded:');
                if(leadDetails.containsKey(leadowner)){
                    leadOwnerSet.add(leadDetails.get(leadowner).OwnerId);
                }
            }
            System.debug('leadOwnerSet DETAILS:' + leadOwnerSet);
            for(group Que : [Select Id from Group where type='Queue' ]){
                if(leadOwnerSet.contains(Que.id)){
                    QueueId.add(Que.Id);
                }
            }
            System.debug('QueueId DETAILS:' + QueueId);
            if(QueueId.size() > 0 && !test.isRunningTest()){
                for(GroupMember groupUsr : [Select UserOrGroupId From GroupMember where GroupId in: QueueId]){
                    UsrList.add(groupUsr.UserOrGroupId);
                }
            }
            
            
            taskListCount = [select id,Lead_Lookup__c from task where Lead_Lookup__c in: leadDetails.keyset() and RecordType.name = 'New Enquiry Received'];
            if(taskListCount != null && taskListCount.size() >= 1){
                updateLastCallStatusOnLead(leadDetails.values());
            }

            for (Id wId: enquiriesMap.keyset()) {
                task t = new task();
                t.status = 'Completed';
                t.task_type__c = 'Enquiry Received';
                t.Subject = taskListCount.size() >= 1 ? 'New Re-enquiry Received from:' + enquiriesMap.get(wId).leadSource :'New Enquiry Received From:' + enquiriesMap.get(wId).leadSource;
                if (String.isNotBlank(enquiriesMap.get(wId).lastName))
                    t.FullName__c = (enquiriesMap.get(wId).lastName);
                if (String.isNotBlank(enquiriesMap.get(wId).RDS_Email__c)) {
                    t.emailAddress__c = (enquiriesMap.get(wId).RDS_Email__c);
                    t.Email_Id__c = (enquiriesMap.get(wId).RDS_Email__c);
                }
                if (String.isNotBlank(enquiriesMap.get(wId).RDS_Country__c))
                    t.country__c = (enquiriesMap.get(wId).RDS_Country__c);
                if (String.isNotBlank(enquiriesMap.get(wId).RDS_Country_Code__c))
                    t.dialingCode__c = (enquiriesMap.get(wId).RDS_Country_Code__c);
                if (String.isNotBlank(enquiriesMap.get(wId).RDS_Mobile__c))
                    t.Mobile_Number_Webform__c = (enquiriesMap.get(wId).RDS_Mobile__c);
                //if (String.isNotBlank(enquiriesMap.get(wId).Budget_In_Lacs__c))
                    //t.Budget_WebForm__c = (enquiriesMap.get(wId).Budget_In_Lacs__c);
                if (String.isNotBlank(enquiriesMap.get(wId).Project__c))
                    t.ProjectInterestedWeb__c = (enquiriesMap.get(wId).Project__c);
                if (String.isNotBlank(enquiriesMap.get(wId).description__c))
                    t.description = (enquiriesMap.get(wId).description__c);
                //fields added for SEO information
                if (String.isNotBlank(enquiriesMap.get(wId).web_banner_source__c))
                    t.web_banner_source__c = (enquiriesMap.get(wId).web_banner_source__c);
                if (String.isNotBlank(enquiriesMap.get(wId).web_banner_size__c))
                    t.web_banner_size__c = (enquiriesMap.get(wId).web_banner_size__c);
                if (String.isNotBlank(enquiriesMap.get(wId).IP_address_web2lead__c))
                    t.IP_address_web2lead__c = (enquiriesMap.get(wId).IP_address_web2lead__c);
                if (String.isNotBlank(enquiriesMap.get(wId).leadSource))
                    t.Enquiry_Source__c = (enquiriesMap.get(wId).leadSource);
                if(String.isNotBlank(enquiriesMap.get(wId).Lead_Sub_Source__c))
                    t.Enquiry_Sub_Source__c = (enquiriesMap.get(wId).Lead_Sub_Source__c);
                ///////////////////////////////////////////----------------------- vikas added below some field on dated 23-08-16 for web lead enquiry received -------------------///////////////////////// 

                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Campaign__c))
                    t.UTM_Campaign__c = (enquiriesMap.get(wId).UTM_Campaign__c);
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Display__c))
                    t.UTM_Display__c = (enquiriesMap.get(wId).UTM_Display__c);
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Medium__c))
                    t.UTM_Medium__c = (enquiriesMap.get(wId).UTM_Medium__c);
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Source__c))
                    t.UTM_Source__c = (enquiriesMap.get(wId).UTM_Source__c);
                if (String.isNotBlank(enquiriesMap.get(wId).UTM_Term__c))
                    t.UTM_Term__c = (enquiriesMap.get(wId).UTM_Term__c);
                //if (String.isNotBlank(enquiriesMap.get(wId).Special_Request_Info__c))
                    //t.Special_Request_Info__c=(enquiriesMap.get(wId).Special_Request_Info__c);  ///Added By Prashant                                      

                ////////////////////////////////////////////////////------------------- vikas added field end here -----------------------------///////////////////////////////  
                //////////////////////////////-----------------------Added by Neha on 05/12/18 Starts Here -------------------///////////////////////// 

               if (String.isNotBlank(enquiriesMap.get(wId).Web_Source__c))
                    t.Web_Source__c = (enquiriesMap.get(wId).Web_Source__c);  
               if (String.isNotBlank(enquiriesMap.get(wId).Adgroup__c))
                    t.Adgroup__c = (enquiriesMap.get(wId).Adgroup__c);                                    
               if (String.isNotBlank(enquiriesMap.get(wId).Goal__c))
                    t.Goal__c = (enquiriesMap.get(wId).Goal__c);
               if (String.isNotBlank(enquiriesMap.get(wId).Digital_Source__c))
                    t.Digital_Source__c = (enquiriesMap.get(wId).Digital_Source__c);
               if (String.isNotBlank(enquiriesMap.get(wId).Channel_Cluster__c))
                    t.Channel_Cluster__c = (enquiriesMap.get(wId).Channel_Cluster__c);              
               if (String.isNotBlank(enquiriesMap.get(wId).Web_Banner_Size__c))
                    t.Web_Banner_Size__c = (enquiriesMap.get(wId).Web_Banner_Size__c);  
               if (String.isNotBlank(enquiriesMap.get(wId).Keyword__c))
                    t.Keyword__c = (enquiriesMap.get(wId).Keyword__c);                                    
               if (String.isNotBlank(enquiriesMap.get(wId).Placement__c))
                    t.Placement__c = (enquiriesMap.get(wId).Placement__c);
               if (String.isNotBlank(enquiriesMap.get(wId).Adposition__c))
                    t.Ad_position__c = (enquiriesMap.get(wId).Adposition__c);
               if (String.isNotBlank(enquiriesMap.get(wId).Matchtype__c))
                    t.Match_Type__c = (enquiriesMap.get(wId).Matchtype__c);                    
               if (String.isNotBlank(enquiriesMap.get(wId).network__c))
                    t.Network__c = (enquiriesMap.get(wId).network__c);  
               if (String.isNotBlank(enquiriesMap.get(wId).Bid_Type__c))
                    t.Bid_Type__c = (enquiriesMap.get(wId).Bid_Type__c);                                    
               if (String.isNotBlank(enquiriesMap.get(wId).UTM_Content__c))
                    t.UTM_Content__c = (enquiriesMap.get(wId).UTM_Content__c);
               if (String.isNotBlank(enquiriesMap.get(wId).LeadSource))
                    t.Lead_Source__c = (enquiriesMap.get(wId).LeadSource);
                   
               if (String.isNotBlank(enquiriesMap.get(wId).Last_Mile_Conversion__c))
                    t.Last_Mile_Conversion__c = (enquiriesMap.get(wId).Last_Mile_Conversion__c);              
               if (String.isNotBlank(enquiriesMap.get(wId).Device__c))
                    t.Device__c = (enquiriesMap.get(wId).Device__c);  
               if (String.isNotBlank(enquiriesMap.get(wId).OS__c))
                    t.OS__c = (enquiriesMap.get(wId).OS__c);                                    
               if (String.isNotBlank(enquiriesMap.get(wId).Resolution__c))
                    t.Resolution__c = (enquiriesMap.get(wId).Resolution__c);
               //if (String.isNotBlank(enquiriesMap.get(wId).Browser__c))
                    //t.Browser__c = (enquiriesMap.get(wId).Browser__c);
               if (String.isNotBlank(enquiriesMap.get(wId).GCLID__c))
                    t.GCLID__c = (enquiriesMap.get(wId).GCLID__c);                   
               //if (String.isNotBlank(enquiriesMap.get(wId).Time_Spent_before_Form_Submit__c))
                    //t.Time_Spent_before_Form_Submit__c = (enquiriesMap.get(wId).Time_Spent_before_Form_Submit__c);
               if (String.isNotBlank(enquiriesMap.get(wId).Landing_Page_URL__c))
                    t.Description = 'Landing Page URL: ' + (enquiriesMap.get(wId).Landing_Page_URL__c); // Changed by Neha on 24/1/19
               if (String.isNotBlank(enquiriesMap.get(wId).Website_Language__c))
                    t.Website_Language__c = (enquiriesMap.get(wId).Website_Language__c);
               /////////////////////////////--------------------- Added by Neha on 05/12/18 Ends Here  -----------------------------/////////////////////////////// 
               /////////////////////////////------- Added by Neha For Scheduling a Visit on 24/12/18 Starts Here  -----------------------------/////////////////////////////// 
               if (String.isNotBlank(enquiriesMap.get(wId).Interested_In__c ))
                    t.Interested_In__c = (enquiriesMap.get(wId).Interested_In__c );                   
               if (enquiriesMap.get(wId).Date_of_Visit__c != null)
                    t.Date_of_Visit__c = (enquiriesMap.get(wId).Date_of_Visit__c );
               if (String.isNotBlank(enquiriesMap.get(wId).HH__c ))
                    t.HH__c = (enquiriesMap.get(wId).HH__c );
               if (String.isNotBlank(enquiriesMap.get(wId).MM__c ))
                    t.MM__c = (enquiriesMap.get(wId).MM__c );
                if (String.isNotBlank(enquiriesMap.get(wId).Are_you_looking_for__c ))
                    t.Are_you_looking_for__c = (enquiriesMap.get(wId).Are_you_looking_for__c );
                //if (String.isNotBlank(enquiriesMap.get(wId).Budgett__c ))
                    //t.Budgett__c = (enquiriesMap.get(wId).Budgett__c );

               /////////////////////////////------- Added by Neha For Scheduling a Visit on 24/12/18 Starts Here  -----------------------------/////////////////////////////// 

                if (wId.getSObjectType().getDescribe().getName() == 'Lead') {
                    t.whoId = wId;
                    Integer randomNumber = UsrList.size() > 0 ? Integer.valueof(Math.random() * UsrList.size()) : 0;
                    String randomString= UsrList.size() > 0 ? UsrList[randomNumber]:null;
                    t.OwnerId = UsrList.size() > 0 ? randomString: leadDetails.get(wid).OwnerId  ;
                } else if (wId.getSObjectType().getDescribe().getName() == 'Account') {
                    t.whoId = accDetails.get(wId).PersonContactId;
                    t.ownerId = accDetails.get(wid).OwnerId;
                    t.whatId = wId;
                } else {
                    t.whoId = '';
                    t.ownerId = '';
                }
                if (t.ActivityDate == null) {
                    t.activityDate = System.today();
                    t.Call_Time__c = System.Now().format('h:mm a');
                }
                taskList.add(t);
            }

            try {
                Database.SaveResult[] srList = Database.insert(taskList, true);
                // Iterate through each returned result
                for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Task ID: ' + sr.getId());
                        taskIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors  
                        List < String > customMsgList = new List < String > ();
                        for (Database.Error err: sr.getErrors()) {
                            String msg = 'Task Insert Failed :' + err.getMessage();
                            customMsgList.add(msg);
                        }
                        throw new GlobalException(customMsgList, '', className);
                    }
                }

                if (!taskIds.isEmpty()) {
                    retTaskList = [SELECT Id, Subject, WhoId, WhatId, OwnerId from Task where Id in : taskIds];
                   
                }

                for (task t: retTaskList) {
                    taskWhoIdMap.put(t.whoId, t);
                }

            } catch (System.DmlException ex) {
                List < String > customMsgList = new List < String > ();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    String msg = 'Task Insert Failed :' + ex.getMessage();
                    customMsgList.add(msg);
                }
                throw new GlobalException(customMsgList, '', className);
            }
        }
        return taskWhoIdMap;
    }
    
    public static void updateLastCallStatusOnLead(List<Lead> leadList){
        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead llist : leadList){
           llist.Previous_Last_Call_Attempt_Status__c =  llist.Last_Call_Attempt_Status__c ;
           llist.Last_Call_Attempt_Status__c = 'Not Actioned';
            leadToUpdate.add(llist);
        }
        if(leadToUpdate != null && leadToUpdate.size() > 0){
            update leadToUpdate;
        }
    }

    public static List < Task > getTaskByType(String taskType, String taskStatus, String sortField, String sortOrder, Id whatId) {

        String baseQuery = 'SELECT Id, Subject, Task_Type__c, ActivityDate, Call_Time__c, Status, What.Name, Who.Name, Priority, Registraion_Status__c, Owner.Name, Description, Call_Attempt_Status__c, Previous_Call_Attempt_Status__c from Task ';
        String buildQuery = baseQuery;
        List < String > customMsgList = new List < String > ();

        if (String.isBlank(taskType) || String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whatId)) {
            String msg = 'Required Parameters Missing';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
        }

        if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {
            String msg = 'Incorrect sort order, sort order can only be ASC or DESC';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');

        }
        List < String > taskStatusList = new List < String > ();
        if (taskStatus.equals('ALL')) {
            taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Open\'');
            taskStatusList.add('\'Scheduled\'');
        } else {
            taskStatusList.add('\'' + taskStatus + '\'');
        }

        buildQuery = buildQuery + 'where task_type__c =' + '\'' + taskType + '\'' + ' and status IN ' + taskStatusList + ' and whatId =' + '\'' + whatId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
        System.debug('QUERY:' + buildQuery);
        List < Task > taskList = (List < Task > ) Database.query(buildQuery);
        return taskList;
    }

    public static List < Task > getTaskByTypeLead(String taskType, String taskStatus, String sortField, String sortOrder, Id whoId) {
        // New - Netra 18/03/2016
        String baseQuery = 'SELECT Id, Subject, Task_Type__c, ActivityDate, Call_Time__c, Owner.Name, Status, What.Name, Who.Name, Priority, OwnerId, Description, Call_Attempt_Status__c, Previous_Call_Attempt_Status__c FROM Task ';

        String buildQuery = baseQuery;
        List < String > customMsgList = new List < String > ();

        if (String.isBlank(taskType) || String.isblank(taskStatus) || String.isBlank(sortOrder) || String.isBlank(sortField) || String.isBlank(whoId)) {
            String msg = 'Required Parameters Missing';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');
        }

        if (!sortOrder.equals('ASC') && !sortOrder.equals('DESC')) {
            String msg = 'Incorrect sort order, sort order can only be ASC or DESC';
            customMsgList.add(msg);
            throw new GlobalException(customMsgList, '', 'TaskManagementServices.getTaskByType');

        }
        List < String > taskStatusList = new List < String > ();
        if (taskStatus.equals('ALL')) {
            taskStatusList.add('\'Completed\'');
            taskStatusList.add('\'Open\'');
        } else {
            taskStatusList.add('\'' + taskStatus + '\'');
        }

        buildQuery = buildQuery + 'where task_type__c =' + '\'' + taskType + '\'' + ' and status IN ' + taskStatusList + ' and whoId =' + '\'' + whoId + '\'' + ' order by Status, ' + sortField + ' ' + sortOrder;
        System.debug('QUERY:' + buildQuery);
        List < Task > taskList = (List < Task > ) Database.query(buildQuery);
        return taskList;
    }


    public static boolean isRevisit(String parentId) {
        List < Task > taskList = new List < Task > ();
        taskList = TaskManagementServices.getTaskByType('Site Visit', 'ALL', 'createdDate', 'DESC', parentId);
        if (taskList.size() > 0)
            return true;
        else
            return false;
    }

    public static boolean isFirstVisit(String parentId) {
        List < Task > taskList = new List < Task > ();
        taskList = TaskManagementServices.getTaskByType('Site Visit', 'ALL', 'createdDate', 'DESC', parentId);
        if (taskList.size() == 1)
            return true;
        else
            return false;
    }
    public static void categoriseTask(List<Task> taskList) {
        System.debug('Inside categorise task:' + taskList);
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = profile[0].Name;
        
        for(Task t: taskList) {
            if(String.isBlank(t.task_type__c) ) {
                if(profileName.equalsIgnoreCase('Presales') )
                t.Task_Type__c = 'Presales Call';
                else if(profileName.equalsIgnoreCase('Sales') ) 
                t.Task_Type__c = 'Sales Call';
            } 
            if(t.CallType != null && t.CallType.equalsIgnoreCase('Inbound')) {
                t.Communication_Type__c = 'Inbound Call';
                // CT enters the campaign code in description, move it to another field and release the description field for the presales/sales team to type their comments
                // this is the only long text area in task
                t.UTM_Campaign__c = t.Description;
                t.Description = '';
            } else if (t.CallType != null && t.CallType.equalsIgnoreCase('Outbound')) {
                t.Communication_Type__c = 'Outbound Call';
                t.UTM_Campaign__c = t.Description;
                t.Description = '';
            } 
        }
    }
    public static void rollUpCampaignCodeToLead(List < Task > taskList){
        System.debug('Inside roll up campaign code from UTM campaign to lead campaign code:' + taskList);
        Set < Id > leadIdSet = new Set<Id>();
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        
        List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = profile[0].Name;
        for (Task t: TaskList) {
            if (t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                leadIdSet.add(t.whoId);
            }
            leadTaskMap.put(t.whoId, t);
        }
        List < Lead > leadList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c,
            Last_call_attempted_by__c, Last_call_attempt_status__c, Last_call_description__c, Presales_agent__c,
            Last_Call_Rating__c, Presales_Call_counter__c, last_call_attempt_date__c, IsFirstPresalesCall__c, Presales_First_Call_Sub_Disposition__c, Presales_Last_Call_Sub_Disposition__c from lead
            where Id in : leadIdSet];
        for (Lead l: leadList) {
            if (leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).UTM_Campaign__c != null ) {
                    l.Campaign_Code__c = leadTaskMap.get(l.Id).UTM_Campaign__c;                    
            }
            // when a CTI lead is created, the lead is assigned to the agent that is answering the call
            // but the presales agent is not populated by CTI. We are taking the person that spoke to the customer from 
            // and populating that value in the presales agent field. the current user is determined by the user that logged the call log task
            // in case of missed call/ unanswered calls this would be the CTI guest user. In that we will not populate this field
            // till an outbound call is made to the customer by the agent.
            if (l.Presales_agent__c == null && profileName.equalsIgnoreCase('Presales'))
                        l.Presales_agent__c = UserInfo.getUserId();
        }
        if(leadList != null && leadList.size() > 0) {
            update leadList;
        }
    }
    
    public static void rollUpCampaignCodeToAccount(List < Task > taskList){
        System.debug('Inside roll up campaign code from UTM campaign to account campaign code:' + taskList);
        Set <Id> accIdSet = new Set<Id>();
        Map<Id, Task> taskMap = new Map<Id, Task>();
        Set<Id> oppIdSet = new Set<Id>();
        for (Task t: TaskList) {
            if (t.whatId != null && t.whatId.getSObjectType().getDescribe().getName() == 'Account') {
                accIdSet.add(t.whatId);
            } else if (t.whatId != null && t.whatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                    oppIdSet.add(t.whatId);
            }
            taskMap.put(t.Id, t);
        }
        if(oppIdSet != null && oppIdSet.size() > 1 ) {
            List<Opportunity> oppList = [Select Id, AccountId from Opportunity where Id in : oppIdSet];
            for(Opportunity o : oppList) {
                    accIdSet.add(o.AccountId);
            }
        }
        if(accIdSet != null && accIdSet.size() > 1) {
                List<Account> aList = [Select Id, Campaign_Code__c from Account where Id in :accIdSet];
                for(Account a : aList){
                    if(taskMap.containsKey(a.Id))
                        a.Campaign_code__c = taskMap.get(a.Id).UTM_Campaign__c;
                }
                if(aList != null && aList.size() > 0) {
                    update aList;
                }
        }        
    }
    
    public static void latestTaskRollupToOpp(List < Task > taskList) {
        Map < Id, Task > opptyTaskMap = new Map < Id, Task > ();
        List<Account> AcclistNew = New List<Account>();
        
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                if (opptyTaskMap.containsKey(t.whatId)) {
                    // if a task already exist for the oppty, 
                    // replace it with the new task only if the new task is the latest
                    if (opptyTaskMap.get(t.whatId).createdDate < t.createdDate) {
                        opptyTaskMap.put(t.whatId, t);
                    }
                } else {
                    opptyTaskMap.put(t.whatId, t);
                }
            }
        }
        List < Opportunity > oppList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c,
            Last_call_attempted_by__c, Last_call_attempt_status__c,Last_call_description__c ,
            last_call_attempt_date__c, Last_Call_Rating__c, Presales_Call_counter__c,
            Unique_SVF_Number__c, Walk_in_Source__c, Walk_in_Sub_Source__c, Site_Visit_Channel_Partner__c,
            /* Walk_in_Channel_Partner_Email__c, Walk_in_Channel_Partner_Name__c,
            Walk_in_Channel_Partner_Phone__c, Walk_in_Channel_Partner__c, */
            Walk_in_Source_Remarks__c, Site_Visit_Count__c, 
            /*Walk_in_Respective_Customer_Account__c,*/ Walk_in_Attended_By__c,
            visit_counter__c, Date_Of_Visit__c, Visit_Rating__c, Visit_Task_Id__c, AccountId,
            Sourcing_Manager__c, Sales_Manager__c, Descriptive_Remarks_Feedback__c,
            Unit_type_configuration__c, S_Budget__c, IsFirstPresalesCall__c, /*Sourcing_TL__c, Name_of_TL__c,*/
            Walk_In_CP__c,Walk_In_Referred_By__c,Sales_Call_Attempt_Status__c ,
            Sales_Call_Description__c,Sales_Call_Attempted_By__c ,Sales_Next_Action_Date__c,Sales_Call_Proposed_Date_Of_Visit__c,Sales_Call_Attempt_Date__c,
            Sales_Call_Rating__c,Sales_Call_Follow_Up_Bucket__c,Sales_Call_Reason_Not_Interested__c, Presales_First_Call_Sub_Disposition__c, Presales_Last_Call_Sub_Disposition__c,
            Sales_First_Call_Sub_Disposition__c, Sales_Last_Call_Sub_Disposition__c
            from Opportunity
            where Id in : opptyTaskMap.keySet()];
        
        Set < Id > accIdSetNew = new Set < Id > ();
        Set < Id > accIdSet = new Set < Id > ();
        List < AggregateResult > taskCountAg = [Select count(Id) taskCount, whatId oppId, task_type__c taskType from Task
            where whatId in : opptyTaskMap.keySet() group by whatId, task_type__c];
        Map < String, Map < String, Integer >> oppTaskCountMap = new Map < String, Map < String, Integer >> ();
        Map < String, Integer > tempMap = new Map < String, Integer > ();
        for (AggregateResult ar: taskCountAg) {
            if (oppTaskCountMap.containsKey((String) ar.get('oppId'))) {
                oppTaskCountMap.get((String) ar.get('oppId')).put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
            } else {
                
                tempMap.put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
                oppTaskCountMap.put((String) ar.get('oppId'), tempMap);
            }
        }
        
        system.debug('tempMap :: '+tempMap);
   
        for (Opportunity o: oppList) {
            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Presales Call' && string.isNotBlank(opptyTaskMap.get(o.Id).Call_Attempt_Status__c) && UserInfo.getName() != 'CTI Site Guest User') {
                o.Last_call_description__c = opptyTaskMap.get(o.Id).description;
                o.Last_Presales_Task_Id__c = opptyTaskMap.get(o.Id).Id;
                o.Last_call_attempt_status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                o.Next_Action_Date__c = opptyTaskMap.get(o.Id).Next_Action_Date__c;
                o.call_proposed_date_of_visit__c = opptyTaskMap.get(o.Id).Call_Proposed_Date_Of_Visit__c;
                //Commented as part of Task Clean up Activity
                //o.Last_Call_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                //Commented as part of Task Clean up Activity
                o.Last_call_attempted_by__c = UserInfo.getName();
                Datetime taskDate = opptyTaskMap.get(o.Id).ActivityDate;
                o.Presales_Last_Call_Sub_Disposition__c = opptyTaskMap.get(o.Id).Sub_Dispositions__c;

                if (taskDate == null)
                    taskDate = Date.today();

                // stripping the time value 00:00:00 from the t.activity date value
                String taskDate1 = taskDate.Date().format();                
                // Here we are concatenating the date and time values to make create a datetime string    
                                                 
                   taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).CreatedDate.format('hh:mm a');
               

                o.last_call_attempt_date__c = DateTime.Parse(taskDate1);              
                o.Presales_Call_counter__c = oppTaskCountMap.get(o.Id).get('Presales Call');
                system.debug('o.Presales_Call_counter__c:::: ' + o.Presales_Call_counter__c);
                if (o.Presales_Call_counter__c == 1) // To populate first call details for Presales on Opty
                {
                    o.IsFirstPresalesCall__c = true;
                    o.First_Call_Attempt_Date__c = o.last_call_attempt_date__c; 
                    o.First_Call_Attempted_by__c = o.Last_call_attempted_by__c;
                    o.First_Call_Description__c = o.Last_call_description__c;
                    o.First_Call_Attempt_Status__c = o.Last_call_attempt_status__c;
                    o.First_Next_Action_Date__c = o.Next_Action_Date__c;
                    o.First_Call_Proposed_DateOfVisit__c = o.call_proposed_date_of_visit__c;
                    o.Presales_First_Call_Sub_Disposition__c= opptyTaskMap.get(o.Id).Sub_Dispositions__c;
                }        
                else
                    o.IsFirstPresalesCall__c = false;
                system.debug('o.IsFirstPresalesCall__c::::: '  + o.IsFirstPresalesCall__c);

            }
            
            if(opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Sales Call' && string.isNotBlank(opptyTaskMap.get(o.Id).Call_Attempt_Status__c) && UserInfo.getName() != 'CTI Site Guest User') {
                o.Sales_Call_Attempt_Status__c = opptyTaskMap.get(o.Id).Call_Attempt_Status__c;
                o.Sales_Call_Description__c = opptyTaskMap.get(o.Id).description;
                o.Sales_Call_Attempted_By__c = UserInfo.getName();
                o.Sales_Next_Action_Date__c = opptyTaskMap.get(o.Id).Next_Action_Date__c;
                o.Sales_Call_Proposed_Date_Of_Visit__c = opptyTaskMap.get(o.Id).Call_Proposed_Date_Of_Visit__c;
                //Commented as part of Task Clean up Activity
                //o.Sales_Call_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                //Commented as part of Task Clean up Activity
                o.Sales_Call_Follow_Up_Bucket__c = opptyTaskMap.get(o.Id).Follow_Up_Status__c;
                o.Sales_Last_Call_Sub_Disposition__c= opptyTaskMap.get(o.Id).Sub_Dispositions__c;
               // o.Sales_Call_Reason_Not_Interested__c = opptyTaskMap.get(o.Id).Sales_Reason_Not_Interested__c;
                
                system.debug(''+o.Sales_Call_Description__c);
                /*if (string.isNotBlank(o.Sales_Call_Description__c)){
                    system.debug('in Sales call desc IF loop');
                    o.Sales_Call_Description__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).Call_Rating__c + ' : ' +opptyTaskMap.get(o.Id).description;
                }*/
                //else{
                    system.debug('in Sales call desc ELSE loop');
                //  o.Sales_Call_Description__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).Call_Rating__c + ' : '  + opptyTaskMap.get(o.Id).description;
                    o.Sales_Call_Description__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
               // }
                Datetime taskDate = opptyTaskMap.get(o.Id).ActivityDate; 
    
                if(taskDate == null) 
                taskDate = Date.today();
                
                String taskDate1 = taskDate.Date().format();
                taskDate1 = taskDate1 + ' ' + opptyTaskMap.get(o.Id).CreatedDate.format('hh:mm a');
                System.Debug('Value of datetime parse function' + taskDate1);
                o.Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                
                Integer salesCallCounter = oppTaskCountMap.get(o.Id).get('Sales Call');
                
                if (salesCallCounter == 1) // To populate first call details for sales on opty
                {                
                   o.Sales_First_Call_Attempt_Date__c = o.Sales_Call_Attempt_Date__c;
                   o.Sales_First_Call_Attempted_By__c = o.Sales_Call_Attempted_By__c;
                   o.Sales_First_Call_Description__c = o.Sales_Call_Description__c;
                   o.First_Sales_Next_Call_Attempt__c =  o.Sales_Call_Attempt_Status__c;
                   o.First_Sales_Next_Action_Date__c = o.Sales_Next_Action_Date__c;
                   o.First_Sal_Next_Call_Proposed_DateOfVisit__c =  o.Sales_Call_Proposed_Date_Of_Visit__c;
                   o.Sales_First_Call_Sub_Disposition__c= opptyTaskMap.get(o.Id).Sub_Dispositions__c; 
                }                                    
            }

            if (opptyTaskMap.containsKey(o.Id) && opptyTaskMap.get(o.Id).Task_Type__c == 'Site Visit') { /////!(opptyTaskMap.get(o.Id).revisit__c)) commented by vikas
                o.Unique_SVF_Number__c = opptyTaskMap.get(o.Id).Visit_Form_No__c;
                o.Walk_in_Source__c = opptyTaskMap.get(o.Id).Walk_in_Source__c;
                o.Walk_in_Sub_Source__c = opptyTaskMap.get(o.Id).Walk_in_Sub_Source__c;
                o.Site_Visit_Channel_Partner__c = opptyTaskMap.get(o.Id).Channel_Partner__c;
                o.Site_Visit_Source_Details__c = opptyTaskMap.get(o.Id).Registraion_Status__c;
              //  o.Walk_in_Channel_Partner_Email__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Email__c;
             //  o.Walk_in_Channel_Partner_Name__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Name__c;
             //   o.Walk_in_Channel_Partner_Phone__c = opptyTaskMap.get(o.Id).New_Channel_Partner_Phone__c;

                if (string.isNotBlank(o.Descriptive_Remarks_Feedback__c))
                    o.Descriptive_Remarks_Feedback__c += '\n' + system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
                else
                    o.Descriptive_Remarks_Feedback__c = system.today().format() + ' : ' + opptyTaskMap.get(o.Id).description;
                //o.Walk_in_Respective_Customer_Account__c = opptyTaskMap.get(o.Id).Walk_in_Respective_Customer_Account__c;
                o.Sales_Manager__c = opptyTaskMap.get(o.Id).Sales_Attempted_By__c;
                o.visit_counter__c = oppTaskCountMap.get(o.Id).get('Site Visit');
                o.Date_Of_Visit__c = opptyTaskMap.get(o.Id).ActivityDate;
                //Commented as part of Task Clean up Activity
                //o.Visit_Rating__c = opptyTaskMap.get(o.Id).Call_Rating__c;
                //Commented as part of Task Clean up Activity
                o.Visit_Task_Id__c = opptyTaskMap.get(o.Id).Id;
                o.Sourcing_Manager__c = opptyTaskMap.get(o.Id).Sourcing_Manager__c;
                 //Commented as part of Task Clean up Activity
                //o.Sales_Manager__c = opptyTaskMap.get(o.Id).Call_Attempted_By_Name__c;
                 //Commented as part of Task Clean up Activity
                //o.Name_of_TL__c = opptyTaskMap.get(o.Id).Name_of_TL__c;
                //o.Sourcing_TL__c = opptyTaskMap.get(o.Id).Sourcing_TL__c;
                //Shailesh added//
                o.Walk_In_CP__c = opptyTaskMap.get(o.Id).Channel_Partner__c;
                
                //o.Unit_type_configuration__c = opptyTaskMap.get(o.Id).Configuration__c;
                o.S_Budget__c = opptyTaskMap.get(o.Id).Budget__c;
                //Commented as part of Task Clean up Activity
                /*if (opptyTaskMap.get(o.Id).Budget_Site_Visit_In_Lacs__c != null)
                    o.Budget_Site_Visit_In_Lacs__c = opptyTaskMap.get(o.Id).Budget_Site_Visit_In_Lacs__c;*/
                //Commented as part of Task Clean up Activity
                    
                /// Added by Priya on 17 March 2018 to update Site Visit Count on Opportunity          
                o.Site_Visit_Count__c = 0;            
                system.debug('o.Site_Visit_Count__c :: '+ o.Site_Visit_Count__c);  
                if(o.Site_Visit_Count__c != Null && tempMap != Null){              
                 o.Site_Visit_Count__c += tempMap.get('Site Visit');              
                }
            }

            // update opportunities with once SV done at Account level
            System.debug('revisit logic:' + isRevisit(o.Id));
            if (isFirstVisit(o.Id)) {
                accIdSet.add(o.AccountId);
            }
            System.debug('accidSet:' + accIdSet);
            accIdSetNew.add(o.AccountId);
        }
        update(oppList);
        List <Account> accList = [Select Id, visit_count__c from Account where Id in : accIdSet];
        System.debug('accList:' + accList);
        for (Account a: accList) {
            if (a.visit_count__c != null) { a.visit_count__c++;}
            else {
                a.visit_count__c = 1;
            }
       }  
        update accList;
       
    
    }

    public static void latestTaskRollupToLead(List < Task > taskList) {
        Map < Id, Task > leadTaskMap = new Map < Id, Task > ();
        Integer callCount = 0;
        for (Task t: TaskList) {
            if (t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                if (leadTaskMap.containsKey(t.whoId)) {
                    // if a task already exist for the lead, 
                    // replace it with the new task only if the new task is the latest
                    if (leadTaskMap.get(t.whoId).createdDate < t.createdDate) {leadTaskMap.put(t.whoId, t);}
                } else {
                    leadTaskMap.put(t.whoId, t);
                }
            }
        }
        List < Lead > leadList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c,
            Last_call_attempted_by__c, Last_call_attempt_status__c, Last_call_description__c, Count_of_Non_Contactable_Calls__c,
            Last_Call_Rating__c, Presales_Call_counter__c, last_call_attempt_date__c, IsFirstPresalesCall__c, Presales_First_Call_Sub_Disposition__c, Presales_Last_Call_Sub_Disposition__c from lead
            where Id in : leadTaskMap.keySet()];

        List < AggregateResult > taskCountAg = [Select count(Id) taskCount, whoId leadId, task_type__c taskType from Task where whoId in : leadTaskMap.keySet() group by whoId, task_type__c];
        Map < String, Map < String, Integer >> leadTaskCountMap = new Map < String, Map < String, Integer >> ();
        for (AggregateResult ar: taskCountAg) {
            if (leadTaskCountMap.containsKey((String) ar.get('leadId'))) {leadTaskCountMap.get((String) ar.get('leadId')).put((String) ar.get('taskType'), (Integer) ar.get('taskCount')); } 
            else {
                Map < String, Integer > tempMap = new Map < String, Integer > ();
                tempMap.put((String) ar.get('taskType'), (Integer) ar.get('taskCount'));
                leadTaskCountMap.put((String) ar.get('leadId'), tempMap);
            }
        }
        
        for (Lead l: leadList) {
            
            // For Count of non contactable Calls  
               If(leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).task_type__c == 'Presales Call') {
               System.debug('Call Status::: ' + leadTaskMap.get(l.Id).Call_Status__c);
                   If(leadTaskMap.get(l.Id).Call_Status__c != 'Call complete' && leadTaskMap.get(l.Id).Call_Status__c != 'Spoke to 3rd party') // 
                   {
                       System.debug('Inside first If Call Status::: ' + leadTaskMap.get(l.Id).Call_Status__c);
                       if(l.Count_of_Non_Contactable_Calls__c == null)l.Count_of_Non_Contactable_Calls__c = 0;
                           
                       l.Count_of_Non_Contactable_Calls__c += 1;                       
                   }
                   else if(leadTaskMap.get(l.Id).Call_Status__c == 'Call complete' || leadTaskMap.get(l.Id).Call_Status__c == 'Spoke to 3rd party'){ 
                       System.debug('Inside second If Call Status::: ' + leadTaskMap.get(l.Id).Call_Status__c);
                       l.Count_of_Non_Contactable_Calls__c = 0;
                   }
               }
                
              // when the agent edits the task and enters the call attempt status then overwrite the previous task information on the task with the latest.
            if (leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).Task_Type__c == 'Presales Call' && string.isNotBlank(leadTaskMap.get(l.Id).Call_Attempt_Status__c) && UserInfo.getName() != 'CTI Site Guest User') {
                l.Last_call_description__c = leadTaskMap.get(l.Id).description;
                l.Last_Presales_Task_Id__c = leadTaskMap.get(l.Id).Id;
                l.Last_call_attempt_status__c = leadTaskMap.get(l.Id).Call_Attempt_Status__c;
                l.Latest_Next_Action_Date__c = leadTaskMap.get(l.Id).Next_Action_Date__c;
                l.call_proposed_date_of_visit__c = leadTaskMap.get(l.Id).Call_Proposed_Date_Of_Visit__c;
                //Commented as part of Task Clean up Activity
                //l.Last_Call_Rating__c = leadTaskMap.get(l.Id).Call_Rating__c;
                //Commented as part of Task Clean up Activity
                l.Last_call_attempted_by__c = UserInfo.getName();
                Datetime taskDate = leadTaskMap.get(l.Id).ActivityDate;
                l.Presales_Last_Call_Sub_Disposition__c = leadTaskMap.get(l.Id).Sub_Dispositions__c;

                if (taskDate == null) taskDate = Date.today();

                // stripping the time value 00:00:00 from the t.activity date value
                //String taskDate1 = taskDate.Date().format();

                // Here we are concatenating the date and time values to make create a datetime string                       
                //taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).CreatedDate.format('hh:mm a');

               // System.Debug('Value of datetime parse function' + taskDate1);
                l.last_call_attempt_date__c =taskDate ;
               //l.last_call_attempt_date__c = System.now();
                l.Presales_Call_counter__c = leadTaskCountMap.get(l.Id).get('Presales Call');
                system.debug('l.Presales_Call_counter__c:::: ' + l.Presales_Call_counter__c);
                if (l.Presales_Call_counter__c == 1) // To populate first call details for Presales on lead
                {
                    l.IsFirstPresalesCall__c = true;
                    l.First_Call_Attempt_Date__c = l.last_call_attempt_date__c;
                    l.First_Call_Attempted_By__c = l.Last_call_attempted_by__c;
                    l.First_Call_Description__c = l.Last_call_description__c;
                    l.First_Call_Attempt_Status__c = l.Last_call_attempt_status__c;
                    l.First_Next_Action_Date__c = l.Latest_Next_Action_Date__c;
                    l.First_Call_Proposed_DateOfVisit__c =  l.call_proposed_date_of_visit__c;
                    l.Presales_First_Call_Sub_Disposition__c= leadTaskMap.get(l.Id).Sub_Dispositions__c;
                }
                else
                    l.IsFirstPresalesCall__c = false;
                system.debug('l.IsFirstPresalesCall__c::::: ' + l.IsFirstPresalesCall__c);
            }
            
            if(leadTaskMap.containsKey(l.Id) && leadTaskMap.get(l.Id).Task_Type__c == 'Sales Call' && string.isNotBlank(leadTaskMap.get(l.Id).Call_Attempt_Status__c) && UserInfo.getName() != 'CTI Site Guest User') {
                l.Sales_Call_Attempt_Status__c = leadTaskMap.get(l.Id).Call_Attempt_Status__c;
                l.Sales_Call_Attempted_By__c = UserInfo.getName();
                l.Sales_Next_Action_Date__c = leadTaskMap.get(l.Id).Next_Action_Date__c;
                l.Sales_Call_Proposed_Date_Of_Visit__c = leadTaskMap.get(l.Id).Call_Proposed_Date_Of_Visit__c;
                //Commented as part of Task Clean up Activity
                //l.Sales_Call_Rating__c = leadTaskMap.get(l.Id).Call_Rating__c;
                //Commented as part of Task Clean up Activity
                l.Sales_Call_Follow_Up_Bucket__c = leadTaskMap.get(l.Id).Follow_Up_Status__c;
                l.Presales_Last_Call_Sub_Disposition__c= leadTaskMap.get(l.Id).Sub_Dispositions__c;
               // l.Sales_Call_Reason_Not_Interested__c = leadTaskMap.get(l.Id).Sales_Reason_Not_Interested__c;
                
                system.debug(''+l.Sales_Call_Description__c);
               /* if (string.isNotBlank(l.Sales_Call_Description__c)){
                    system.debug('in Sales call desc IF loop');
                    l.Sales_Call_Description__c += '\n' + system.today().format() + ' : ' + leadTaskMap.get(l.Id).Call_Rating__c + ' : ' +leadTaskMap.get(l.Id).description;
                }*/
                //else{
                    system.debug('in Sales call desc ELSE loop');
                    l.Sales_Call_Description__c = system.today().format() + ' : '  + leadTaskMap.get(l.Id).description;
                //}
                Datetime taskDate = leadTaskMap.get(l.Id).ActivityDate; 
    
                if(taskDate == null) taskDate = Date.today();
                
                String taskDate1 = taskDate.Date().format();
                taskDate1 = taskDate1 + ' ' + leadTaskMap.get(l.Id).createdDate.format('hh:mm a');
                System.Debug('Value of datetime parse function' + taskDate1);
                l.Sales_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
                
                Integer leadSalesCallCounter = leadTaskCountMap.get(l.Id).get('Sales Call'); // To populate first call details for sales on lead
                
                if (leadSalesCallCounter == 1)
                {                
                   l.Sales_First_Call_Attempt_Date__c = l.Sales_Call_Attempt_Date__c;
                   l.Sales_First_Call_Attempted_By__c = l.Sales_Call_Attempted_By__c;
                   l.Sales_First_Call_Description__c = l.Sales_Call_Description__c;
                   l.First_Sales_Next_Call_Attempt__c = l.Sales_Call_Attempt_Status__c;
                   l.First_Sales_Next_Action_Date__c = l.Sales_Next_Action_Date__c;
                   l.First_Sal_Next_Call_Proposed_DateOfVisit__c =  l.Sales_Call_Proposed_Date_Of_Visit__c; 
                }  
            }
        }
        update(leadList);
    }
//// Added by Neha on 23/4/19 to roll up task on Booking    
    public static void latestTaskRollupToBooking(List <Task> taskList) {
        System.debug('Inside roll up booking');
        Map <Id, Task> bookTaskMap = new Map <Id, Task> ();
        
        for(Task t: taskList){
            if(bookTaskMap.containsKey(t.Booking__c)){
                if(bookTaskMap.get(t.Booking__c).createdDate < t.createdDate)
                    bookTaskMap.put(t.Booking__c, t);
            } else {
                bookTaskMap.put(t.Booking__c, t);    
            }
        }
        
        List<Booking__c> bookList = [SELECT Id, Name, Last_Call_Attempt_Date__c, Last_Call_Attempted_By__c,
                                     Last_Call_Description__c, Last_Call_Attempt_Status__c, Next_Action_Date__c, 
                                     PTP_Amount__c, PTP_Date__c FROM Booking__c WHERE Id IN :bookTaskMap.keySet()];
        
       for(Booking__c b: bookList){
           Datetime taskDate = bookTaskMap.get(b.Id).ActivityDate;

            if (taskDate == null)
                taskDate = Date.today();
    
            // stripping the time value 00:00:00 from the t.activity date value
            String taskDate1 = taskDate.Date().format();
    
            // Here we are concatenating the date and time values to make create a datetime string                       
           taskDate1 = taskDate1 + ' ' + bookTaskMap.get(b.Id).CreatedDate.format('hh:mm a');
           System.Debug('Value of datetime parse function' + taskDate1);
           
           b.Last_Call_Attempt_Date__c = DateTime.Parse(taskDate1);
           b.Last_Call_Attempted_By__c = UserInfo.getName();   
           b.Last_Call_Description__c = bookTaskMap.get(b.Id).Description;  
           b.Last_Call_Attempt_Status__c = bookTaskMap.get(b.Id).Call_Attempt_Status__c;  
           b.Next_Action_Date__c = bookTaskMap.get(b.Id).Next_Action_Date__c;  
           b.PTP_Amount__c = bookTaskMap.get(b.Id).PTP_Amount__c;    
           b.PTP_Date__c =  bookTaskMap.get(b.Id).PTP_Date__c;               
       }
       update(bookList);                          
    }
    
   public static void HomeLoanTaskRollupToOpp(List < Task > taskList) {
        Map < Id, Task > opptyTaskMap = new Map < Id, Task > ();
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                if (opptyTaskMap.containsKey(t.whatId) && t.Task_Type__c == 'Home Loan') {
                    System.debug('This opty is already added into the map');
                } else {
                    opptyTaskMap.put(t.whatId, t);
                }
            }
        }
        List < Opportunity > oppList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c
            from Opportunity where Id in : opptyTaskMap.keySet()];
    }

    public static void RegTaskRollupToOpp(List < Task > taskList) {
        Map < Id, Task > opptyTaskMap = new Map < Id, Task > ();
        for (Task t: TaskList) {
            if (t.WhatId != null && t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity') {
                if (opptyTaskMap.containsKey(t.whatId) && t.Task_Type__c == 'Registration') {
                    System.debug('This opty is already added into the map');
                } else {
                    opptyTaskMap.put(t.whatId, t);
                }
            }
        }
        List < Opportunity > oppList = [select Name, Id, call_proposed_date_of_visit__c, Follow_up_date__c
            from Opportunity where Id in : opptyTaskMap.keySet()
        ];
        update oppList;
    }
    // returns the time from the datetime field in the user's locale
    // if the input was 17/1/2016 12:30 AM, returns 12:30 AM as a string
    public static String formatTime(DateTime input) {
        String dt = input.format();
        Integer s = dt.indexOf(' ');
        return dt.substring(s + 1);
    }
    
    /********** Below method added by Vikas on dated 05/12/2019 for updating No Counter on Lead *******/
    
    Public static void incrementNoContactCounter(List<Task> taskList){
        system.debug('inside incrementNoContactCounter method');
        Set<id> whoIds = new Set<Id>();
        Map<Id,lead> leadMap = new Map<Id,lead>();
        Map<id,List<Task>> leadTaskMap = new Map<id, List<Task>>();
        List<Lead> leadList = new List<Lead>();
        List<Id> leadId = new List<Id>();        
        for(task t : taskList){
            whoIds.add(t.whoId);
        }
        for(lead l : [select id,name,No_Contact_Counter__c,Status,Reason_For_Lost__c from Lead where Id IN:whoIds]){
            leadMap.put(l.id,l);
            leadId.add(l.id);
        }
        System.debug('Lead list:' + leadId);
        for(Task ts : [select id,whoId,createdDate from Task where whoId IN: leadId and createdDate =TODAY and Call_Attempt_Status__c = 'No Contact']){
            if(leadTaskMap.containsKey(ts.whoId)){
               List<Task> lList = leadTaskMap.get(ts.whoId);
               lList.add(ts); 
               leadTaskMap.put(ts.whoId,lList);
            }else{
               List<Task> lList = new List<Task>(); 
               lList.add(ts); 
               leadTaskMap.put(ts.whoId,lList);
            }
        }
        if(leadTaskMap!= null && !leadTaskMap.isEmpty()){
            for(Id key : leadTaskMap.keySet()){
                if(leadTaskMap.get(key).size()<=2){
                    if(leadMap.containskey(key)){
                        if(leadMap.get(key).No_Contact_Counter__c == null){
                           leadMap.get(key).No_Contact_Counter__c = 0; 
                        }
                        leadMap.get(key).No_Contact_Counter__c += 1;      
                        leadList.add(leadMap.get(key));
                    }
                }
            }
        }
        
     /*   for(task t : taskList){
            if(leadMap.containskey(t.whoId)){
                if(leadMap.get(t.whoId).No_Contact_Counter__c == null){
                   leadMap.get(t.whoId).No_Contact_Counter__c = 0; 
                }
                leadMap.get(t.whoId).No_Contact_Counter__c += 1;      
                if(leadMap.get(t.whoId).No_Contact_Counter__c >= 7){
                   //leadMap.get(t.whoId).Status = 'Lost';
                   //leadMap.get(t.whoId).Reason_For_Lost__c = 'Non contactable';
                }
            }
        } */
        //system.debug('counter id :'+leadList[0].No_Contact_Counter__c);
        if(!leadList.isEmpty()){
            update leadList;
        }
        
    }
    
    Public static void setZeroNoContactCounter (List<Task> taskList){
        system.debug('inside setZeroNoContactCounter method');
        Set<id> whoIds = new Set<Id>();
        Map<Id,lead> leadMap = new Map<Id,lead>();
        List<Lead> leadList = new List<Lead>();
        for(task t : taskList){
            whoIds.add(t.whoId);
        }
        for(lead l : [select id,name,No_Contact_Counter__c,Status,Reason_For_Lost__c from Lead where Id IN:whoIds]){
            leadMap.put(l.id,l);
            leadList.add(l); 
        }
        
        for(task t : taskList){
            if(leadMap.containskey(t.whoId)){
                leadMap.get(t.whoId).No_Contact_Counter__c = 0; 
            }
        }
        //system.debug('counter id :'+leadList[0].No_Contact_Counter__c);
        update leadList;
    }
    
    public static void processReEnquiryTasks(list<Task> reEnquiryTasks, map<string,Task> leadIdToTask){
        system.debug('VVK processReEnquiryTasks');
        if(TaskManagementServices.processReEnquiryTasksFirstFunFlag == true){
            Map<Id,Integer> leadIdToRenquiryCount = new Map<Id,Integer>();
            List<Opportunity> optysToUpdate = new List<Opportunity>();
            
            for(Lead ld : [
                SELECT Id, ConvertedOpportunityId ,(
                    SELECT Subject 
                    FROM Tasks
                    WHERE Subject LIKE '%re enquiry%'
                    OR Subject LIKE '%re-enquiry%'
                    OR Subject LIKE '%Re-enquiry Received from%'
                )
                FROM Lead
                WHERE Id IN :leadIdToTask.keySet()
            ]) {
                leadIdToRenquiryCount.put(ld.Id, ld.Tasks.size());
                
                if( ld.ConvertedOpportunityId != null ) {
                    optysToUpdate.add(new Opportunity(
                        Id = ld.ConvertedOpportunityId,
                        IsServiced__c = true,
                        Reenquiry_Lead__c = DateTime.now()
                    ));
                }
            }
            if(optysToUpdate != null && optysToUpdate.size() > 0)update optysToUpdate;
            
            
            list<Lead> leadsToUpdate = new list<Lead>();
            list<Lead_Re_Enquiry_Mapping__mdt> fieldMappings = [select Id, Lead_Field_API__c, Task_Field_API__c 
                                                                from Lead_Re_Enquiry_Mapping__mdt 
                                                                where Active__c = true and Lead_Field_API__c != null and 
                                                                Task_Field_API__c != null];
            
            list<Error_Log__c> errLogToInsert = new list<Error_Log__c>();
            for(string leadId : leadIdToTask.keySet()){
                Lead l = new Lead(Id=leadId);
                
                if( leadIdToRenquiryCount.containsKey(leadId) ) {
                    l.Re_Enquiry_Count__c = String.valueOf(leadIdToRenquiryCount.get(leadId));
                    l.IsReenquire__c = true;
                    l.status = 'Open';
                }
                
                system.debug('VVK leadId : '+leadId);
                Task t = leadIdToTask.get(leadId);
                if(fieldMappings.size() > 0){
                    for(Lead_Re_Enquiry_Mapping__mdt mapping : fieldMappings){
                        try{
                            string taskField = mapping.Task_Field_API__c;
                            system.debug('VVK Field : '+mapping.Task_Field_API__c+' : ' +string.valueof(t.get(mapping.Task_Field_API__c)));
                            if(taskField!=null && taskField.containsIgnoreCase('email')){
                                if(t.get(mapping.Task_Field_API__c) != null)
                                    l.put(mapping.Lead_Field_API__c, string.valueof(t.get(mapping.Task_Field_API__c)));
                            }
                            else{
                                l.put(mapping.Lead_Field_API__c, string.valueof(t.get(mapping.Task_Field_API__c)));
                            }
                        }
                        catch(Exception lException){
                            system.debug('processReEnquiryTasks error message: '+lException.getMessage());
                            errLogToInsert.add(prepareErrorLog(lException.getMessage(),lException.getStackTraceString(),leadId,'TaskManagementServices','processReEnquiryTasks'));
                        }
                    }
                }
                leadsToUpdate.add(l);
            }
            system.debug('VVK leadsToUpdate : '+leadsToUpdate.size());
            if(leadsToUpdate != null && leadsToUpdate.size() > 0){
                try{
                    //Database.DMLOptions dmo = new Database.DMLOptions();
                    //dmo.AssignmentRuleHeader.useDefaultRule = TRUE;
                    List<Database.SaveResult> results = Database.update(leadsToUpdate,false);
                    Integer index = 0;
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for(Database.Error err : result.getErrors()) {
                                errLogToInsert.add(prepareErrorLog(err.getMessage(),'LeadUpdateError',leadsToUpdate[index].Id,'TaskManagementServices','processReEnquiryTasks'));
                            }
                        }
                        index++;
                    }
                }
                catch(Exception e){
                    system.debug('VVK Lead Update Error: '+e.getMessage());
                }
                if(errLogToInsert.size()>0){
                    try{
                        insert errLogToInsert;
                    }
                    catch(Exception e){
                        
                    }
                }
            }
            try{
                List<Lead> lList = [select Id, IsConverted, ConvertedOpportunityId,Owner.Email, OwnerId,Lead_Id__c from Lead where Id IN: leadIdToTask.keySet() and IsConverted=true and ConvertedOpportunityId != null];
                system.debug('VVK lList : '+lList.size());
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                list<string> toAddress = new list<string>();
                //string preSalesHeadEmails = System.Label.Pre_Sales_Head_Emails;
                //list<string> toAddress = Owner.Email//preSalesHeadEmails.split(',');
                String taskURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                OrgWideEmailAddress orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfnotifications@sobharealty.com' Limit 1];
                EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name ='ReEnquiryConvertedLeadEmail'];
                for(Lead ld : lList){
                    if(leadIdToTask.containsKey(ld.Id)){
                        Task t = leadIdToTask.get(ld.Id);
                        if(ld.IsConverted == true && ld.ConvertedOpportunityId != null){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                         
                            toAddress.add(ld.Owner.Email);//Added by mohit to fix prod issue #SOB780
                            system.debug('etneredconvertedloop' + toAddress);
                            email.setToAddresses(toAddress);
                            email.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                            String sub = emailTemplate.Subject;  // added lead id by mohit as part of SOB -711
                            email.setSubject(sub.replace('{!Lead.Id}', ld.Lead_Id__c));
                            //email.setSubject('Converted Lead ' + ld.Lead_Id__c +  'Re-Enquiry Created ' );
                            String plainBody = emailTemplate.Body;
                            plainBody = plainBody.replace('taskURL', taskURL);
                            plainBody = plainBody.replace('{!Task.Id}', t.Id);
                            plainBody = plainBody.replace('ConvertedOpportunityId', ld.ConvertedOpportunityId);
                            email.setPlainTextBody(plainBody);
                            //email.setHtmlBody('Hello, <br/><br/>A Re-Enquiry task has been created for a converted lead. <br/>'+'Task: '+taskURL+t.Id+'<br/>'+'Opportunity: '+taskURL+ld.ConvertedOpportunityId+'<br/><br/>Regards,<br/> Salesforce');
                            mails.add(email);
                            Converted_Lead_Opportunity_Update__e evt = new Converted_Lead_Opportunity_Update__e();
                            evt.Task_Id__c = t.Id;
                            evt.Opportunity_Id__c = ld.ConvertedOpportunityId;
                            evt.Task_Subject__c = 'Converted Lead ' +t.Subject; 
                            EventBus.publish(evt);
                        }
                    }
                }
                if(mails.size()>0){
                    try{
                        system.debug('VVK email failure message: '+mails);
                        Messaging.sendEmail(mails);
                    }catch(exception e){
                        system.debug('VVK email failure message: '+e.getMessage());
                    }
                }
            }
            catch(Exception tException){
                system.debug('taskToUpdate error message: '+tException.getMessage());
            }
            TaskManagementServices.processReEnquiryTasksFirstFunFlag = false;
        }
    }
    
    public static void processEnquiriesOnOpportunity(list<Opportunity> opptyToUpdateActionStatus){
        if(opptyToUpdateActionStatus != null && opptyToUpdateActionStatus.size() > 0){
            list<Error_Log__c> errLogToInsert = new list<Error_Log__c>();
            try{
                List<Database.SaveResult> results = Database.update(opptyToUpdateActionStatus,false);
                Integer index = 0;
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for(Database.Error err : result.getErrors()) {
                            errLogToInsert.add(prepareErrorLog(err.getMessage(),'OpportunityUpdateError',opptyToUpdateActionStatus[index].Id,'TaskManagementServices','processEnquiriesOnOpportunity'));
                        }
                    }
                    index++;
                }
            }
            catch(Exception e){
                system.debug('VVK Opportunity Update Error: '+e.getMessage());
                errLogToInsert.add(prepareErrorLog(e.getMessage(),'OpportunityUpdateError','processEnquiriesOnOpportunity Exception','TaskManagementServices','processEnquiriesOnOpportunity'));
            }
            if(errLogToInsert.size()>0){
                try{
                    insert errLogToInsert;
                }
                catch(Exception e){
                    
                }
            }
        }
    }
    
    public static Error_Log__c prepareErrorLog(string errorMsg, string stackTrace, string recordName, string className, string methodName){
        Error_Log__c logError = new Error_Log__c();
        try{
            logError.Name=recordName;
            logError.Class__c=className;
            logError.Message__c=errorMsg;
            logError.Request__c=stackTrace;
            logError.Api_Type__c=methodName; 
        }
        catch(Exception e){
            
        }
        return logError;
    }
}