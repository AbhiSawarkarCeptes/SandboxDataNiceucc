public class LeadTriggerHandler {
    public static boolean bypassLeadTrigger = false;
    public static string formatNumber(string countryCode, string formatNumber){
        System.debug('countryCode==> ' + countryCode + '::' + 'formatNumber==> ' + formatNumber);
        if(countryCode!=null && countryCode!=''){
            if(countryCode.endsWith('0')){
                //countryCode = countryCode.removeEnd('0');
            }
            if(countryCode.startsWith('+')){
                //countryCode =  countryCode.substringAfter('+');
            }
        }
        if(formatNumber!=null && formatNumber!=''){
            if(formatNumber.startsWith('+')) {
                //formatNumber = formatNumber.substringAfter('+');
                //commented above &added by Artee
                formatNumber = formatNumber;
            }
            if(formatNumber.startsWith('0')){
                formatNumber = formatNumber.substringAfter('0');
                formatNumber = countryCode + formatNumber;
            }
            else{
                formatNumber = countryCode + formatNumber;
            }
            
            if(formatNumber != '' && formatNumber != null){
                formatNumber = formatNumber.remove(' ');
                formatNumber = formatNumber.remove('(');
                formatNumber = formatNumber.remove(')');
                formatNumber = formatNumber.replaceAll('[^a-zA-Z0-9\\s+]', '');                
                //formatNumber = formatNumber.remove('+');
                //formatNumber = formatNumber.replaceAll('[^0-9]','');
                //commented above & added by Artee
                formatNumber = formatNumber.replaceAll('[^0-9+]','');
            }
        	System.debug('Final Format Number==> ' + formatNumber);
        }
        return formatNumber;
    }
    
    public static Lead formatMobilePhone(Lead l){
        system.debug('YAY' + l);
        //String countryCode='';
        String formatMobile='';
        String formatPhone='';
        if(l.RDS_Country_Code__c!=null){
            if(l.RDS_Country_Code__c.startsWith('+')){
                //l.RDS_Country_Code__c =  l.RDS_Country_Code__c.substringAfter('+');
                //commented above &added by Artee
                l.RDS_Country_Code__c =  l.RDS_Country_Code__c;
            }
            if(l.RDS_Country_Code__c.startsWith('0')){
                l.RDS_Country_Code__c =  l.RDS_Country_Code__c.substringAfter('0');
            }
        }
        if(l.MobilePhone != null && !l.Mobile_Number_Formatted__c){
            formatMobile = formatNumber(l.RDS_Country_Code__c,l.MobilePhone);
            l.MobilePhone = formatMobile;
            l.Mobile_Number_Formatted__c = true;
        }
        if(l.Phone != null && !l.Phone_Number_Formatted__c){
            System.debug('l.Phone==> ' + l.Phone);
            formatPhone = formatNumber(l.RDS_Country_Code__c,l.Phone);
            l.Phone = formatPhone;
            l.Phone_Number_Formatted__c = true;
        }
        system.debug('YAY2' + l);
        return l;
    }
    
    public static void beforeInsert(){
        try{
            Set < ID > projectID = new Set < ID > ();
            Integer score = 0;
            for (Lead l: (list<lead>)trigger.new) {
                l = formatMobilePhone(l);
                l.Call_Attempt_Status__c = l.Last_Call_Attempt_Status__c;
                if (l.Project__c != Null) {
                    projectID.add(l.Project__c);
                }
            }
            System.debug('Project ID:' + (list<lead>)trigger.new);
            
            if (!projectID.isEmpty()) {
                Map < ID, Project__c > projectMap = new Map < ID, Project__c > ([Select ID, Name, PossessionRequirement__c, Configuration__c, Max_Budget__c, Min_Budget__c from Project__c where ID =: projectID]);
                for (Lead l: (list<lead>)trigger.new) {
                    if ((l.Possession_Requirement__c != Null) && (projectMap.get(l.Project__c).PossessionRequirement__c.contains(l.Possession_Requirement__c))) {
                        score += 1;
                    }
                    if ((l.RDS_Unit_type_configuration__c != Null) && (projectMap.get(l.Project__c).Configuration__c.contains(l.RDS_Unit_type_configuration__c))) {
                        score += 1;
                    }
                    if ((l.Budget_In_lacs_Number__c != Null) && ((projectMap.get(l.Project__c).Max_Budget__c >= l.Budget_In_lacs_Number__c) || ((projectMap.get(l.Project__c).Min_Budget__c <= l.Budget_In_lacs_Number__c)))) {
                        score += 1;
                    }
                    l.Lead_Score_Text__c = score;
                }
            }
            
            LeadManagementServices.checkIfLeadShouldBeRoutedToWeekendQueue((list<lead>)trigger.new);
            LeadManagementServices.updateLeadStatus((list<lead>)trigger.new, null);
            LeadUtility.updateLeadAttributionHashFields((list<lead>)trigger.new,(map<Id,lead>)trigger.oldMap,false);
            
            List < DupResultsDTO > dupResList = new List < DupResultsDTO > ();
            //check the user, if its batch user, only then call the preprocessing logic
            If(!(System.isBatch() || N_ScreenPopController.skipDuplicateCheck)) {
                dupResList = LeadManagementServices.leadPreProcessing((list<lead>)trigger.new, 'WEB');
                system.debug('VVK dupResList : ' + dupResList);
                if (!dupResList.isEmpty()) {
                    for (Lead l: (list<lead>)trigger.new) {
                        System.debug('(list<lead>)trigger.new: ' + l);
                        for (DupResultsDTO d: dupResList) {
                            if (d.originalLead == l) {
                                System.debug('(list<lead>)trigger.new: dup match' + l + d.originalLead);
                                System.debug('Dup Results Lead Id:: ' + d.duplicatesMap);
                                String errMsg = 'Duplicates exists for: ' + l.lastName; 
                                for (String dupType: d.duplicatesMap.keySet()){
                                    errMsg += ' (' + d.duplicatesMap.get(dupType) + ')'; 
                                    if (!test.isRunningTest())
                                        l.addError(errMsg);
                                }
                            }
                        }
                    }
                }                 
            }   
        }
        catch(Exception e){
            system.debug('VVK here catch: '+ e.getMessage());
            insertErrorLog(e.getMessage(),e.getStackTraceString(),'LeadMobilePhoneFormatting','LeadTriggerHandler','beforeInsert');
        }
    }
    
    public static void beforeUpdate(){
        List<Lead> newLeads = (list<lead>)trigger.new;
        List<Lead> oldLeads = (list<lead>)trigger.old;
        Map<Id,Lead> oldLeadMap = (map<Id,lead>)trigger.oldMap;
        Map<Id,Lead> newLeadMap = (map<Id,lead>)trigger.newMap;
        List < DupResultsDTO > dupResList = new List < DupResultsDTO > ();
        
        LeadManagementServices.updateLeadStatus(newLeads, oldLeadMap);
        LeadRoundRobinTriggerHandler.assignLeadOwner(newLeads,oldLeads,oldLeadMap); 
        LeadUtility.updateLeadAttributionHashFields(newLeads,oldLeadMap,true);
        
        if (checkRecursion.isFirstRun()) {
            Set < ID > projectID = new Set < ID > ();
            Integer score = 0;
            String countryCode='';
            String formatMobile='';
            String formatPhone='';
            for (Lead l: newLeads) {
                l.Call_Attempt_Status__c = l.Last_Call_Attempt_Status__c;
                if (l.Project__c != Null) {
                    projectID.add(l.Project__c);
                }
                //COUNTRY-CODE LOGIC STARTS HERE
                countryCode='';
                formatMobile='';
                formatPhone='';
                if(l.RDS_Country_Code__c!=null && l.RDS_Country_Code__c != oldLeadMap.get(l.Id).RDS_Country_Code__c){
                    if(l.RDS_Country_Code__c.startsWith('+')){
                        //l.RDS_Country_Code__c =  l.RDS_Country_Code__c.substringAfter('+');
                        //commented above & added by Artee
                        l.RDS_Country_Code__c =  l.RDS_Country_Code__c;
                    }
                    if(l.RDS_Country_Code__c.startsWith('0')){
                        l.RDS_Country_Code__c =  l.RDS_Country_Code__c.substringAfter('0');
                    }
                    countryCode = l.RDS_Country_Code__c;
                }
                if(l.MobilePhone != null && l.MobilePhone != oldLeadMap.get(l.Id).MobilePhone){
                    formatMobile = l.MobilePhone;
                    if(formatMobile.startsWith('+')) { 
                        //formatMobile = formatMobile.substringAfter('+');
                        //commented above & added by Artee
                        formatMobile = formatMobile;
                    }
                    if(formatMobile.startsWith('0')){
                        formatMobile = formatMobile.substringAfter('0'); 
                    }
                    formatMobile = countryCode + formatMobile;
                    
                    if(formatMobile != '' && formatMobile != null){
                        formatMobile = formatMobile.remove(' ');
                        formatMobile = formatMobile.remove('(');
                        formatMobile = formatMobile.remove(')');
                        formatMobile = formatMobile.replaceAll('[^a-zA-Z0-9\\s+]', '');
                        //formatMobile = formatMobile.remove('+');
                        //formatMobile = formatMobile.replaceAll('[^0-9]','');
                        //commented above & added by Artee
                        formatMobile = formatMobile.replaceAll('[^0-9+]','');
                    }
                    l.MobilePhone = formatMobile;
                    l.Mobile_Number_Formatted__c = true;
                }
                if(l.Phone != null && l.Phone != oldLeadMap.get(l.Id).Phone){
                    formatPhone = l.Phone;
                    if(formatPhone.startsWith('+')) { 
                        //formatPhone = formatPhone.substringAfter('+');
                        //commented above & added by Artee
                        formatPhone = formatPhone;
                    }
                    if(formatPhone.startsWith('0')){
                        formatPhone = formatPhone.substringAfter('0'); 
                    }
                    formatPhone = countryCode + formatPhone;
                    
                    if(formatPhone != '' && formatPhone != null){
                        formatPhone = formatPhone.remove(' ');
                        formatPhone = formatPhone.remove('(');
                        formatPhone = formatPhone.remove(')');
                        formatPhone = formatPhone.replaceAll('[^a-zA-Z0-9\\s+]', '');                        
                        //formatPhone = formatPhone.remove('+');
                        //formatPhone = formatPhone.replaceAll('[^0-9]','');
                        //commented above & added by Artee
                        formatMobile = formatMobile.replaceAll('[^0-9+]','');
                    }
                    l.Phone = formatPhone;
                    l.Phone_Number_Formatted__c = true;
                }
                //COUNTRY-CODE LOGIC ENDS HERE
                l.Hash_Value__c = LeadUtility.getSha256(l.CreatedById + ',' + l.Form_Data__c +',' +
                                                        l.Leadgen_Form_ID__c+','+
                                                        l.Facebook_Adset_ID__c+','+
                                                        l.Facebook_Adset_Name__c+','+
                                                        l.Facebook_Ad_ID__c+','+
                                                        l.Facebook_Ad_Name__c+','+
                                                        l.Campaign_Code__c+','+
                                                        l.Email+','+
                                                        l.Facebook_Form_Name__c+','+
                                                        l.LastName+','+
                                                        l.Facebook_Page_Name__c+','+
                                                        l.Phone+','+
                                                        l.Platform__c+','+
                                                        l.MobilePhone+','+
                                                        l.RDS_Country_Code__c);
                 
                
            }
           
            
            
            System.debug('Project ID:' + projectID);
            
            if (!projectID.isEmpty()) {
                Map < ID, Project__c > projectMap = new Map < ID, Project__c > ([Select ID, Name, PossessionRequirement__c, Configuration__c, Max_Budget__c, Min_Budget__c from Project__c where ID =: projectID]);
                
                for (Lead l: newLeads) {
                    if ((l.Possession_Requirement__c != Null) && (projectMap.get(l.Project__c).PossessionRequirement__c.contains(l.Possession_Requirement__c))) {
                        score += 1;
                    }
                    if ((l.RDS_Unit_type_configuration__c != Null) && (projectMap.get(l.Project__c).Configuration__c.contains(l.RDS_Unit_type_configuration__c))) {
                        score += 1;
                    }
                    if ((l.Budget_In_lacs_Number__c != Null) && ((projectMap.get(l.Project__c).Max_Budget__c >= l.Budget_In_lacs_Number__c) && ((projectMap.get(l.Project__c).Min_Budget__c <= l.Budget_In_lacs_Number__c)))) {
                        score += 1;
                    }
                    l.Lead_Score_Text__c = score;
                }
                
            }
            
            if(!(System.isBatch()) && !(LeadAutoReassignController.skipDuplicateLeadLogic)) {
                try {
                    dupResList = LeadManagementServices.leadPreProcessing(newLeads, 'WEB');
                    if (!dupResList.isEmpty()) {
                        for (Lead l: newLeads) {
                            System.debug('newLeads: ' + l);
                            for (DupResultsDTO d: dupResList) {
                                if (d.originalLead == l) {
                                    System.debug('newLeads: dup match' + l + d.originalLead);
                                    String errMsg = 'Duplicates exist for:' + l.lastName; 
                                    for (String dupType: d.duplicatesMap.keySet()) {
                                        errMsg +=  ' (' + d.duplicatesMap.get(dupType) + ')'; 
                                    }
                                    if (!test.isRunningTest())
                                        l.addError(errMsg);
                                }
                            }
                        }
                    }
                } catch (GlobalException ex) {
                    System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
                }
            }
            
        }
        List < Lead > updateCMList = new List < Lead > ();
        for (lead l: newLeads) {
            if (newLeadMap.get(l.Id).Campaign_Code__C != oldLeadMap.get(l.Id).Campaign_Code__C) {
                updateCMList.add(l);
            }
        }
    }
    
    
    public static void afterInsert(){
        try{
            
            if(System.IsBatch() == false && System.isFuture() == false){ 
                WebEngageServiceHandler.handleAPI((list<lead>)trigger.new,(map<Id,lead>)trigger.oldMap,trigger.isInsert);
            }
            createDayAndAttemptTracking((list<lead>)trigger.new);
            
            list<lead> leadListToProcess = new list<lead>();
            set<string> campaigns = new set<string>();
            set<string> campaignsLandingURLs = new set<string>();
            for (Lead l: (list<lead>)trigger.new) {
                if(l.UTM_Campaign__c != null && l.email != null){
                    leadListToProcess.add(l);
                    campaigns.add(l.UTM_Campaign__c);
                }
                if(l.Landing_Page_URL__c != null && l.email != null){
                    leadListToProcess.add(l);
                    campaignsLandingURLs.add(l.Landing_Page_URL__c);
                }
            }  
            if(leadListToProcess.size()>0){
                QRCodeReaderController.createRoadshowAppointment(leadListToProcess,campaigns,campaignsLandingURLs);
            }
        }
        catch(Exception e){
            insertErrorLog(e.getMessage(),e.getStackTraceString(),'LeadMobilePhoneFormatting','LeadTriggerHandler','beforeInsert');
        }
    }
    
    public static void afterUpdate(){
        List<Lead> newLeads = (list<lead>)trigger.new;
        List<Lead> oldLeads = (list<lead>)trigger.old;
        Map<Id,Lead> oldLeadMap = (map<Id,lead>)trigger.oldMap;
        Map<Id,Lead> newLeadMap = (map<Id,lead>)trigger.newMap;
       
            
        
        if(System.IsBatch() == false && System.isFuture() == false){ 
            WebEngageServiceHandler.handleAPI(newLeads,oldLeadMap, Trigger.isInsert);
        }
        list<string> leadIdsWithOwnerChanged = new list<string>();
        List < Lead > updateCMList = new List < Lead > ();
        List < Lead > leadsToSendRoadshowNotification = new List < Lead > ();
        map<string,string> leadIdToUTMCampaign = new map<string,string>();
        
        list<lead> leadListToProcess = new list<lead>();
        set<string> campaigns = new set<string>();
        set<string> campaignsLandingURLs = new set<string>();
        
        for (lead l: newLeads) {
            if (newLeadMap.get(l.Id).Campaign_Code__C != oldLeadMap.get(l.Id).Campaign_Code__C) {
                updateCMList.add(l);
            }
            if((l.OwnerId != null && l.OwnerId != oldLeadMap.get(l.Id).OwnerId && System.Label.LeadNurturingFeatureFlag == 'true') || Test.isRunningTest()) {
                string leadOwnerId = l.OwnerId;
                if(leadOwnerId.startsWith('005'))
                    leadIdsWithOwnerChanged.add(l.Id);
            }
            if(l.Send_Roadshow_Notification__c && l.Send_Roadshow_Notification__c != oldLeadMap.get(l.Id).Send_Roadshow_Notification__c){
            	leadsToSendRoadshowNotification.add(l);   
                if(l.UTM_Campaign__c != null){
                    leadIdToUTMCampaign.put(l.Id,l.UTM_Campaign__c);
                }
            }
            if(l.UTM_Campaign__c != null && l.UTM_Campaign__c != oldLeadMap.get(l.Id).UTM_Campaign__c && l.email != null){
                leadListToProcess.add(l);
                campaigns.add(l.UTM_Campaign__c);
            }
            else if(l.Landing_Page_URL__c != null && l.Landing_Page_URL__c != oldLeadMap.get(l.Id).Landing_Page_URL__c && l.email != null){
                leadListToProcess.add(l);
                campaignsLandingURLs.add(l.Landing_Page_URL__c);
            }
        }
        
        if(leadListToProcess.size()>0){
            QRCodeReaderController.createRoadshowAppointment(leadListToProcess,campaigns,campaignsLandingURLs);
        }
        
        if(leadIdsWithOwnerChanged.size()>0){
            try{
                list<Attempt_Tracking__c> attemptToUpdate = new list<Attempt_Tracking__c>();
                for(Attempt_Tracking__c at : [select Id,Day_Tracking__r.Lead__r.OwnerId from Attempt_Tracking__c where Day_Tracking__r.Lead__c IN:leadIdsWithOwnerChanged and Status__c = null]){
                    at.Attempted_By__c = at.Day_Tracking__r.Lead__r.OwnerId;
                    attemptToUpdate.add(at);
                }
                if(attemptToUpdate.size()>0){
                    update attemptToUpdate;
                }
            }
            catch(Exception e){
                system.debug('VVK attemptToUpdate: '+e.getMessage());
            }
        }
        if(leadsToSendRoadshowNotification.size() > 0){
            map<string,Campaign_Schedule__c> campaignToCampaignSchedule = new map<string,Campaign_Schedule__c>();
            list<Campaign_Schedule__c> campaignSchedules = [select Id,Campaign_Name__c,Subject__c,Email_Body__c,Location__c from Campaign_Schedule__c where Campaign_Name__c IN : leadIdToUTMCampaign.values() and Active__c = true];
            for(Campaign_Schedule__c cs : campaignSchedules){
                campaignToCampaignSchedule.put(cs.Campaign_Name__c,cs);
            }
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            // Fetch Org-Wide Email Address
            OrgWideEmailAddress[] orgWideAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'marketing@sobharealty.com' LIMIT 1];
            String orgWideEmailAddress = (orgWideAddresses.isEmpty()) ? null : orgWideAddresses[0].Address;
            Id orgWideEmailId = (orgWideAddresses.isEmpty()) ? null : orgWideAddresses[0].Id;
            list<string> leadsToSendEmail = new list<string>();
            for(Lead l : leadsToSendRoadshowNotification){
                if(leadIdToUTMCampaign.containsKey(l.Id)){
                    if(campaignToCampaignSchedule.containsKey(leadIdToUTMCampaign.get(l.Id))){
                        leadsToSendEmail.add(l.Id);
                        Campaign_Schedule__c cs = campaignToCampaignSchedule.get(leadIdToUTMCampaign.get(l.Id));
                        string qrCode = l.QR_Code__c;
                        qrCode = qrCode.split('_IM1_')[1];
                        qrCode = qrCode.split('_IM2_')[0];
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                        email.setSubject(cs.Subject__c);
                        email.setToAddresses(new List<string>{l.Email});
                        email.setBccAddresses(new String[]{'dinav.dileep@sobharealty.com'});
						string customerName = l.FirstName+' '+l.LastName;
                        if(customerName.contains('null')){
                            customerName = customerName.replace('null', '');
                        }
                        customerName  = customerName.trim();
                        string htmlBody = '<p>';
                        htmlBody += '<span style="font-size: 11px; font-family: Tahoma;">Dear '+customerName+ ',</span><br/>';
                        htmlBody += cs.Email_Body__c + '';
                        htmlBody += '<center><b style="font-size: 12px; font-family: Tahoma;">Entry QR Code</b></center>';
                        htmlBody += '<center style="font-size: 12px; font-family: Tahoma;">Please present this QR code at the venue entrance:</center><br/>';
                        //htmlBody += l.QR_Code__c + '<br/><br/>';
                        htmlBody += '<center><img src="'+qrCode+'" alt="Scan QR Code" border="0" height="150px" width="150px"/>' + '</center><br/>';
                        htmlBody += '<b>Warm regards,</b><br/>';
                        htmlBody += '<b>Sobha Realty Team</b>';
                        htmlBody += '</p>';
                        email.setHtmlBody(htmlBody);
                        if (orgWideEmailId != null) {
                            email.setOrgWideEmailAddressId(orgWideEmailId); 
                        }
                        emails.add(email);
                    }
                }
            }
            if(emails.size() > 0){
                try{
                    Messaging.sendEmail(emails);
                    updateEmailLog(leadsToSendEmail,'success');
                }
                catch(Exception e){
                    updateEmailLog(leadsToSendEmail,'failed');
                }
            }
        }
    }
    
    @future
    public static void updateEmailLog(list<string> leadIds, string result){
        string currentDateTime = system.now().format();
        string msg = '';
        if(result == 'success'){
            msg = 'Email Sent At ' + currentDateTime;
        }
        else{
            msg = 'Email Failed At ' + currentDateTime;
        }
        list<Lead> leadList = [select Id,Email_Log__c from Lead where Id IN : leadIds];
        for(Lead l : leadList){
            l.Email_Log__c = (l.Email_Log__c != null) ? l.Email_Log__c + ' | ' + msg : msg;
        }
        try{
            update leadList;
        }catch(Exception e){}
    }
    
    public static void createDayAndAttemptTracking(list<Lead> leadList){
        list<Day_Tracking__c> dayTrackingToInsert = new list<Day_Tracking__c>();
        map<string,string> leadIdToOwnerId = new map<string,string>();
        Lead_Nurturing__mdt day1 = [select Value__c from Lead_Nurturing__mdt where DeveloperName = 'Day_1' LIMIT 1];
        string day1Attempts = day1.Value__c;
        day1Attempts = day1Attempts.split(',')[0];
        map<string,string> recordTypeNameToId = new map<string,string>();
        for(RecordType recType : [select id,name from RecordType where sObjectType='Attempt_Tracking__c']){
            recordTypeNameToId.put(recType.name,recType.id);
        }
        if(checkRecursion.isFirstRunTask()) {
            for(Lead l : leadList)
            { 
                leadIdToOwnerId.put(l.Id,l.OwnerId);
                if(System.Label.LeadNurturingFeatureFlag=='true' || Test.isRunningTest()){
                    Day_Tracking__c d = new Day_Tracking__c();
                    d.Name = 'Day 1';
                    d.Lead__c = l.Id;
                    dayTrackingToInsert.add(d);
                }
            }
            if(dayTrackingToInsert.size()>0){
                try{
                    insert dayTrackingToInsert;
                    list<Attempt_Tracking__c> attemptTrackingToInsert = new list<Attempt_Tracking__c>();
                    for(Day_Tracking__c dt : [select Id, Lead__c from Day_Tracking__c where Id IN: dayTrackingToInsert]){
                        string leadOwnerId = leadIdToOwnerId.get(dt.Id);
                        Attempt_Tracking__c a = new Attempt_Tracking__c();
                        a.Day_Tracking__c = dt.Id;
                        a.Name = day1Attempts;
                        a.RecordTypeId = recordTypeNameToId.get(day1Attempts);
                        a.Attempt_Sequence__c = '1';
                        a.Attempted_By__c = (leadOwnerId!=null && leadOwnerId!='' && leadOwnerId.startsWith('005'))?leadOwnerId:null;
                        attemptTrackingToInsert.add(a);
                    }
                    if(attemptTrackingToInsert.size()>0)
                        insert attemptTrackingToInsert;
                }
                catch(Exception e){
                    system.debug('VVK dayTrackingToInsert: '+e.getMessage());
                }
            } 
        }
    }
    
    public static void insertErrorLog(string errorMsg, string stackTrace, string recordName, string className, string methodName){
        Error_Log__c logError = new Error_Log__c();
        try{
            logError.Name=recordName;
            logError.Class__c=className;
            logError.Message__c=errorMsg;
            logError.Request__c=stackTrace;
            logError.Api_Type__c=methodName; 
            insert logError;
        }
        catch(Exception e){
            system.debug('insertErrorLog Error Msg: '+e.getMessage());
            system.debug('insertErrorLog StackTrace: '+e.getStackTraceString());
        }
    }
   
    /**
	* Handler for before insert and before update trigger events.
	* Encrypts Primary and Secondary mobile numbers/emails if they are provided.
	*added by Artee on 22-01-2025
	**/
    public static void processLeadFieldsBeforeSave(List<Lead> newRecords) {        
        for (Lead l : newRecords) {
            
            if (!String.isBlank(l.Primary_Mobile_Country_Code__c) && !String.isBlank(l.Primary_Mobile__c)) {
                String primaryNumber = l.Primary_Mobile__c;
                if (primaryNumber.startsWith('+') && !String.isBlank(l.RDS_Country_Code__c)) {
                    primaryNumber = primaryNumber.substring(l.RDS_Country_Code__c.length());
                } else {
                    primaryNumber = primaryNumber;
                } 
                l.Primary_Mobile_Number__c = l.Primary_Mobile_Country_Code__c + primaryNumber;
                l.Primary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Primary_Mobile_Number__c);
                l.Primary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Primary_Mobile_Number__c);
            }

            if (!String.isBlank(l.Secondary_Mobile_Country_Code__c) && !String.isBlank(l.Secondary_Mobile__c)) {
                String secondaryNumber = l.Secondary_Mobile__c;
                if(secondaryNumber.startsWith('+')) {
                    secondaryNumber = secondaryNumber.substring(l.Secondary_Mobile_Country_Code__c.length());
                } else {
                    secondaryNumber = secondaryNumber;
                }
                l.Secondary_Mobile_Number__c = l.Secondary_Mobile_Country_Code__c + secondaryNumber;
                l.Secondary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Secondary_Mobile_Number__c);
                l.Secondary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Secondary_Mobile_Number__c);
            }
            if (!String.isBlank(l.Email)) {
                l.Primary_Email_M__c = FieldMaskingUtil.maskEmail(l.Email);
                l.Primary_Email_E__c = EncryptionUtilService.encryptEmail(l.Email);
            }
            if (!String.isBlank(l.RDS_Alternate_Email_Id__c)) {
                l.Alternate_Email_Id_M__c = FieldMaskingUtil.maskEmail(l.RDS_Alternate_Email_Id__c);
                l.Alternate_Email_Id_E__c = EncryptionUtilService.encryptEmail(l.RDS_Alternate_Email_Id__c);
            }
            
        }
    }
    
    
    public static void processLeadFieldsBeforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        List<Lead> leadToEncrypt = new List<Lead>();
        
        for (Lead l : newMap.values()) {
            Boolean isPrimaryMobileChanged = oldMap == null || l.Primary_Mobile__c != oldMap.get(l.Id)?.Primary_Mobile__c;
            Boolean isPrimaryMobileCountryChanged = oldMap == null || l.Primary_Mobile_Country_Code__c != oldMap.get(l.Id)?.Primary_Mobile_Country_Code__c;
            Boolean isSecondaryMobileChanged = oldMap == null || l.Secondary_Mobile__c != oldMap.get(l.Id)?.Secondary_Mobile__c;
            Boolean isSecondaryMobileCountryChanged = oldMap == null || l.Secondary_Mobile_Country_Code__c != oldMap.get(l.Id)?.Secondary_Mobile_Country_Code__c;
            Boolean isPrimaryEmailChanged = oldMap == null || l.Email != oldMap.get(l.Id)?.Email;
            Boolean isAlternateEmailChanged = oldMap == null || l.RDS_Alternate_Email_Id__c != oldMap.get(l.Id)?.RDS_Alternate_Email_Id__c;
                   
			// for primary mobile number
            // Either primary mobile number is blank or changes in mobile/country code and not matching existing Primary_Mobile_Number__c
        	Boolean shouldUpdatePrimaryMobile = String.isBlank(l.Primary_Mobile_Number__c) ||
            									(isPrimaryMobileChanged || isPrimaryMobileCountryChanged) &&
            									l.Primary_Mobile_Number__c != (l.Primary_Mobile_Country_Code__c + l.Primary_Mobile__c);
            
            System.debug('shouldUpdatePrimaryMobile==> ' + shouldUpdatePrimaryMobile);
            
            if (shouldUpdatePrimaryMobile && !String.isBlank(l.Primary_Mobile__c)) {
                String primaryNumber = l.Primary_Mobile__c;
                if (primaryNumber.startsWith('0')) {
                    primaryNumber = primaryNumber.substringAfter('0');
                } 
                else if (primaryNumber.startsWith('+') && !String.isBlank(l.Primary_Mobile_Country_Code__c)) {
                    primaryNumber = primaryNumber.substring(l.Primary_Mobile_Country_Code__c.length()); 
                } 
                else {
                    primaryNumber = primaryNumber;
                }   
                l.Primary_Mobile_Number__c = l.Primary_Mobile_Country_Code__c + primaryNumber;
                l.Primary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Primary_Mobile_Number__c);
                l.Primary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Primary_Mobile_Number__c);
            } 
            // for secondary mobile number
            // Either primary mobile number is blank or changes in mobile/country code and not matching existing Secondary_Mobile_Number__c
        	Boolean shouldUpdateSecondaryMobile = String.isBlank(l.Secondary_Mobile_Number__c) ||
            									(isSecondaryMobileChanged || isSecondaryMobileCountryChanged) &&
            									l.Secondary_Mobile_Number__c != (l.Secondary_Mobile_Country_Code__c + l.Secondary_Mobile__c);
            
            System.debug('shouldUpdateSecondaryMobile==> ' + shouldUpdateSecondaryMobile);
            
            if (shouldUpdateSecondaryMobile && !String.isBlank(l.Secondary_Mobile__c)) {
                String secondaryMobile = l.Secondary_Mobile__c;
                if (secondaryMobile.startsWith('0')) {
                    secondaryMobile = secondaryMobile.substringAfter('0');
                } 
                else if (secondaryMobile.startsWith('+') && !String.isBlank(l.Secondary_Mobile_Country_Code__c)) {
                    secondaryMobile = secondaryMobile.substring(l.Secondary_Mobile_Country_Code__c.length()); 
                } 
                else {
                    secondaryMobile = secondaryMobile;
                } 
                l.Secondary_Mobile_Number__c = l.Secondary_Mobile_Country_Code__c + secondaryMobile;
                l.Secondary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Secondary_Mobile_Number__c);
                l.Secondary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Secondary_Mobile_Number__c);
            }              
                /*if (!String.isBlank(l.Primary_Mobile_Number__c) && isPrimaryNumberChanged) {
                    System.debug('Primary Mobile number changed////');
                    l.Primary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Primary_Mobile_Number__c);
                    l.Primary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Primary_Mobile_Number__c);
                }  
                if (!String.isBlank(l.Secondary_Mobile_Number__c) && isSecondaryNumberChanged) {
                    System.debug('Secondary Mobile number changed////');
                    l.Secondary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(l.Secondary_Mobile_Number__c);
                    l.Secondary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(l.Secondary_Mobile_Number__c);     
                }*/
                if (!String.isBlank(l.Email) && isPrimaryEmailChanged ) {
                    System.debug('Email changed////');
                    l.Primary_Email_M__c = FieldMaskingUtil.maskEmail(l.Email);
                    l.Primary_Email_E__c = EncryptionUtilService.encryptEmail(l.Email);
                }
                if (!String.isBlank(l.RDS_Alternate_Email_Id__c) && isAlternateEmailChanged) {
                    System.debug('Alternate Email changed////');
                    l.Alternate_Email_Id_M__c = FieldMaskingUtil.maskEmail(l.RDS_Alternate_Email_Id__c);
                    l.Alternate_Email_Id_E__c = EncryptionUtilService.encryptEmail(l.RDS_Alternate_Email_Id__c);
                }
               
            leadToEncrypt.add(l);
        }
    }
    //added by Artee on 22-01-2025
    
    
    class requestBodyWrapper{
        //string name;
        string lastName;
        string email;
        string mobile;
        string source;
        string firstName;
        String dialCode;
    }
    
}