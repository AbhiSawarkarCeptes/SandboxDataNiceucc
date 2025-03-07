public without sharing class QRCodeReaderController {
    
    @AuraEnabled
    public static boolean checkIfCampaignActive(String leadId) {
        boolean response = true;
        string campaignName = '';
        String landingPage = '';
        if(leadId.startsWith('00Q')){
            Lead ld = [
                select Id, UTM_Campaign__c,Landing_Page_URL__c
                from lead
                where id = :leadId 
            ];
            if(ld.UTM_Campaign__c != null){
                campaignName = ld.UTM_Campaign__c;
            }
            if(ld.Landing_Page_URL__c != null){
                landingPage = ld.Landing_Page_URL__c;
            }
        }
        if(leadId.startsWith('006')){
            Opportunity op = [
                select Id, UTM_Campaign__c,Landing_Page_URL__c
                from Opportunity
                where id = :leadId 
            ];
            if(op.UTM_Campaign__c != null){
                campaignName = op.UTM_Campaign__c;
            }
            if(op.Landing_Page_URL__c != null){
                landingPage = op.Landing_Page_URL__c;
            }
        }
        if(campaignName == '' && landingPage =='' ){
            response = false;
        }
        else{
            list<Campaign_Schedule__c> campaignSchedules = [select Id from Campaign_Schedule__c where (Campaign_Name__c =: campaignName OR Landing_Page_URL__c=:landingPage) and Active__c = true];
            if(campaignSchedules.size() == 0){
                response = false;
            }else{
                response = true;
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static boolean checkIfAlreadyOngoingSiteVisit() {
        boolean response = false;
        list<Opportunity> oppList = [
            select Id from Opportunity
            where (OwnerId =: UserInfo.getUserId() or Sales_Manager_lookup__c =: UserInfo.getUserId()) and Site_Visit_Start_Time__c != null and Site_Visit_End_Time__c = null
        ];
        if(oppList.size() > 0){
            response = true;
        }
        return response;
    }
    
    @AuraEnabled
    public static boolean checkIfSiteVisitExists(String leadId) {
        boolean response = false;
        if(leadId.startsWith('00Q')){
            Lead ld = new Lead();
            ld = [
                select Id, Lead_Id__c, ConvertedOpportunityId, ConvertedAccountId
                from lead
                where id = :leadId 
            ];
            list<Customer_Registration__c> svs = new list<Customer_Registration__c>();
            if(ld.ConvertedAccountId != null){
                svs = [select id from Customer_Registration__c where opportunity__r.AccountId =: ld.ConvertedAccountId and createddate = TODAY];
            }
            else{
                svs = [select id from Customer_Registration__c where Lead_Id__c =: ld.Lead_Id__c and createddate = TODAY];
            }
            if(svs.size() > 0){
                response = true;
            }
        }
        if(leadId.startsWith('006')){
            list<Customer_Registration__c> svs = [select id from Customer_Registration__c where opportunity__c =: leadId and createddate = TODAY];
            if(svs.size() > 0){
                response = true;
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static string saveDetails(String leadId) {
        string result = '';
        User u = [select Id, Profile.Name, Name from User where id = : UserInfo.getUserId()];
        Lead ld = new Lead();
        Opportunity op = new Opportunity();
        if(leadId.startsWith('00Q')){
            ld = [
                select Id, FirstName, LastName, Email, MobilePhone, Project__c, Project__r.Name, Lead_Id__c, ConvertedOpportunityId, ConvertedAccountId
                from lead
                where id = :leadId 
            ];
        }
        if(leadId.startsWith('006')){
            op = [
                SELECT 
                Id,
                OwnerId,
                AccountId,
                Account_Email__c,
                Account.Name,
                Account_Mobile_Number__c,
                Project__c,
                Project__r.Name,
                (select Id from Customer_Registration_Forms__r)
                FROM
                Opportunity
                WHERE
                Id = :leadId
            ];
        }
        
        if(leadId.startsWith('00Q')){
            Lead l = new Lead(Id=leadId);
            l.Roadshow_Visit_Status__c = 'Met WIth Sales Manager';
            l.Roadshow_Visited_At__c = System.now();
            update l;
            
            system.debug('VVK HERE LEAD');
            Visitor_Registration__c vrRec = new Visitor_Registration__c();
            vrRec.First_Name__c = ld.FirstName;
            vrRec.Last_Name__c = ld.LastName;
            vrRec.Mobile__c = ld.MobilePhone;
            vrRec.Email__c = ld.Email;
            vrRec.Project_Name__c = ld.Project__c;
            vrRec.Status__c = 'Accepted';
            vrRec.Sales_Adviser__c = u.Name;
            insert vrRec;
            
            List<Visitor_Registration__c> vrToInsert = [
                SELECT
                Id,First_Name__c,Last_Name__c,Mobile__c,Email__c,Permanent_Address__c,Birth_Date__c,
                City__c,Country__c,UAE_Resident__c,Interested_in__c,Purpose_of_Purchase__c,DocumentId__c,AlternateEmail_Address__c,
                Remarks_if_any__c,Source__c,Agent_Name__c,Agent_ID__c,Company__c,Sales_Adviser__c,
                Nationality__c,Alternate_Email_Id__c,Alternate_Mobile_Number__c,Designation__c,
                Existing_Sobha_Owner__c,Occupation__c,Project_Name__c,Visiting_On_Behalf_Of__c,Residential_Status__c,Sobha_Connect_Company_Name__c,
                Sobha_Connect_Id__c,Sobha_Connect_Name__c,product_Type__c,Property_Type__c,Possession_Timeline__c,Budget__c,Unique_Id__c
                FROM 
                Visitor_Registration__c
                WHERE
                Id = :vrRec.Id
            ];
            
            for(Visitor_Registration__c vr : vrToInsert){
                Customer_Registration__c sv = new Customer_Registration__c();
                sv.First_Name__c = vr.First_Name__c;
                sv.Last_Name__c = vr.Last_Name__c;
                sv.project__c = vr.Project_Name__c;
                sv.Mobile_Number__c = vr.Mobile__c;
                sv.Email_Address__c = vr.Email__c;
                if(ld.ConvertedAccountId != null){
                    system.debug('VVK ld.ConvertedAccountId ' + ld.ConvertedAccountId);
                    result = submitWalkingForm(sv,null,null,ld.ConvertedAccountId,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
                }
                else{
                    system.debug('VVK leadId ' + leadId);
                    result = submitWalkingForm(sv,leadId,null,null,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
                }
            }
        }
        if(leadId.startsWith('006')){
            
            Opportunity o = new Opportunity(Id=leadId);
            o.Roadshow_Visit_Status__c = 'Met WIth Sales Manager';
            o.Roadshow_Visited_At__c = System.now();
            update o;
            
            system.debug('VVK HERE OPPORTUNITY');
            Visitor_Registration__c vrRec = new Visitor_Registration__c();
            String accountName = op.Account.Name;
            List<String> name = accountName.split(' ');
            if(name.size() > 0){
                vrRec.First_Name__c = name[0];
            }
            if(name.size() > 1){
                name.remove(0);
                vrRec.Last_Name__c = String.join(name, ' ');
            }
            vrRec.Mobile__c = op.Account_Mobile_Number__c;
            vrRec.Email__c = op.Account_Email__c;
            vrRec.Project_Name__c = op.Project__c;
            vrRec.Opportunity__c = op.Id;
            vrRec.Status__c = 'Accepted';
            vrRec.Sales_Adviser__c = u.Name;
            insert vrRec;
            
            List<Visitor_Registration__c> vrToInsert = [
                SELECT
                Id,First_Name__c,Last_Name__c,Mobile__c,Email__c,Permanent_Address__c,Birth_Date__c,
                City__c,Country__c,UAE_Resident__c,Interested_in__c,Purpose_of_Purchase__c,DocumentId__c,AlternateEmail_Address__c,
                Remarks_if_any__c,Source__c,Agent_Name__c,Agent_ID__c,Company__c,Sales_Adviser__c,
                Nationality__c,Alternate_Email_Id__c,Alternate_Mobile_Number__c,Designation__c,
                Existing_Sobha_Owner__c,Occupation__c,Project_Name__c,Visiting_On_Behalf_Of__c,Residential_Status__c,Sobha_Connect_Company_Name__c,
                Sobha_Connect_Id__c,Sobha_Connect_Name__c,product_Type__c,Property_Type__c,Possession_Timeline__c,Budget__c,Unique_Id__c
                FROM 
                Visitor_Registration__c
                WHERE
                Id = :vrRec.Id
            ];
            
            for(Visitor_Registration__c vr : vrToInsert){
                Customer_Registration__c sv = new Customer_Registration__c();
                sv.First_Name__c = vr.First_Name__c;
                sv.Last_Name__c = vr.Last_Name__c;
                sv.project__c = vr.Project_Name__c;
                sv.Mobile_Number__c = vr.Mobile__c;
                sv.Email_Address__c = vr.Email__c;
                if(op.OwnerId != UserInfo.getUserId()){
                    result = submitWalkingForm(sv,null,null,op.AccountId,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
                }
                else if(op.Customer_Registration_Forms__r.size() == 0 ){
                    result = submitWalkingForm(sv,null,leadId,null,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
                }
                else if(op.Customer_Registration_Forms__r.size() > 0){
                    result = submitWalkingForm(sv,null,null,op.AccountId,vr.Project_Name__c,vr.Mobile__c,vr.Email__c,'','', vr.Id,'',vr,null);
                }
            }
        }
        string currentDateTime = system.now().format();
        if(result == 'success'){
            if(leadId.startsWith('00Q')){
                ld = [
                    select Id, FirstName, Scan_Log__c, LastName, Email, MobilePhone, Project__c, Project__r.Name, Lead_Id__c, ConvertedOpportunityId, ConvertedAccountId
                    from lead
                    where id = :leadId 
                ];
                ld.Scan_Log__c = (ld.Scan_Log__c != null) ? ld.Scan_Log__c + ' | ' + 'Scan Successful At ' + currentDateTime : 'Scan Successful At ' + currentDateTime;
                update ld;
                list<Opportunity> oppList = [select Id, Scan_Log__c from Opportunity where AccountId =: ld.ConvertedAccountId and CreatedById =: UserInfo.getUserId() order by createddate desc LIMIT 1];
                if(oppList.size()>0){
                    Opportunity toUpdate = new Opportunity(Id=oppList[0].Id);
                    toUpdate.Site_Visit_Start_Time__c = system.now();
                    toUpdate.Scan_Log__c = (oppList[0].Scan_Log__c != null) ? oppList[0].Scan_Log__c + ' | ' + 'Scan Successful At ' + currentDateTime : 'Scan Successful At ' + currentDateTime;
                    update toUpdate;
                    return oppList[0].Id;
                }
                else{
                    return leadId;
                }
            }
            if(leadId.startsWith('006')){
                list<Opportunity> oppList = [select Id, Scan_Log__c from Opportunity where AccountId =: op.AccountId and CreatedById =: UserInfo.getUserId() order by createddate desc LIMIT 1];
                if(oppList.size()>0){
                    Opportunity toUpdate = new Opportunity(Id=oppList[0].Id);
                    toUpdate.Site_Visit_Start_Time__c = system.now();
                    toUpdate.Scan_Log__c = (oppList[0].Scan_Log__c != null) ? oppList[0].Scan_Log__c + ' | ' + 'Scan Successful At ' + currentDateTime : 'Scan Successful At ' + currentDateTime;
                    return oppList[0].Id;
                }
                else{
                    return leadId;
                }
            }
            return leadId;
        }
        else{
            if(leadId.startsWith('00Q')){
                Lead l = [
                    select Id, Scan_Log__c
                    from lead
                    where id = :leadId 
                ];
                l.Scan_Log__c = (l.Scan_Log__c != null) ? l.Scan_Log__c + ' | ' + 'Scan Failed At ' + currentDateTime : 'Scan Failed At ' + currentDateTime;
                update l;
            }
            if(leadId.startsWith('006')){
                Opportunity o = [
                    select Id, Scan_Log__c
                    from Opportunity
                    where id = :leadId 
                ];
                o.Scan_Log__c = (o.Scan_Log__c != null) ? o.Scan_Log__c + ' | ' + 'Scan Failed At ' + currentDateTime : 'Scan Failed At ' + currentDateTime;
                update o;
            }
            return 'FAILED : ' + result;
        }
    }
    
    public static void createRoadshowAppointment(list<lead> leads, set<string> campaigns, set<string> campaignLandingURLs){
        map<string,Campaign_Schedule__c> campaignToCampaignSchedule = new map<string,Campaign_Schedule__c>();
        map<string,Campaign_Schedule__c> campaignURLToCampaignSchedule = new map<string,Campaign_Schedule__c>();
        list<Campaign_Schedule__c> campaignSchedules = [select Id,Campaign_Name__c,Active__c,End_Date__c,Start_Date__c,Type__c,Landing_Page_URL__c from Campaign_Schedule__c where (Campaign_Name__c IN : campaigns or Landing_Page_URL__c IN : campaignLandingURLs) and Active__c = true];
        for(Campaign_Schedule__c cs : campaignSchedules){
            campaignToCampaignSchedule.put(cs.Campaign_Name__c,cs);
            if(cs.Landing_Page_URL__c != null){
                campaignURLToCampaignSchedule.put(cs.Landing_Page_URL__c,cs);
            }
        }
        for(lead l : [select Id,UTM_Campaign__c,Landing_Page_URL__c from Lead where Id IN:leads]){
            if(campaignToCampaignSchedule.containsKey(l.UTM_Campaign__c) || campaignURLToCampaignSchedule.containsKey(l.Landing_Page_URL__c)){
                Send_Email_From_Site__e event = new Send_Email_From_Site__e();
                event.Object_Id__c = l.Id;
                EventBus.publish(event);
            }
        }
    }
    
    @AuraEnabled
    public static void sendRoadshowNotification(String leadId) {
        if(leadId.startsWith('00Q')){
            Lead l = new Lead(Id=leadId,Send_Roadshow_Notification__c=true);
            update l;
        }
        if(leadId.startsWith('006')){
            Opportunity o = new Opportunity(Id=leadId,Send_Roadshow_Notification__c=true);
            update o;
        }
    }
    
    @AuraEnabled
    public static LeadWrapper getEmailDetails(String leadId) {
        LeadWrapper wrap = new LeadWrapper();
        Lead l = [select Id,QR_Code__c,FirstName,LastName,Email,UTM_Campaign__c from Lead where Id = :leadId];
        string name = '';
        if(l.FirstName != null)
            name = l.FirstName + ' ';
        if(l.LastName != null)
            name = name + l.LastName;
        
        wrap.leadName = name;
        map<string,Campaign_Schedule__c> campaignToCampaignSchedule = new map<string,Campaign_Schedule__c>();
        list<Campaign_Schedule__c> campaignSchedules = [select Id,Campaign_Name__c,Subject__c,Email_Body__c,Location__c from Campaign_Schedule__c where Campaign_Name__c =: l.UTM_Campaign__c and Active__c = true];
        for(Campaign_Schedule__c cs : campaignSchedules){
            campaignToCampaignSchedule.put(cs.Campaign_Name__c,cs);
        }
        if(campaignToCampaignSchedule.containsKey(l.UTM_Campaign__c)){
            wrap.emailBody = campaignToCampaignSchedule.get(l.UTM_Campaign__c).Email_Body__c;
            wrap.emailSubject = campaignToCampaignSchedule.get(l.UTM_Campaign__c).Subject__c;
        }
        return wrap;
    }
    
    public static string submitWalkingForm(Customer_Registration__c sv,string strLeadId,string strOptyId, string strAccountId, string strprojectId,string strMobile,string stremail, String FileContent, string salesAdvisor, string visitorId, string documentId, Visitor_Registration__c vr, List<Account> lstAccount){
        system.debug('VVK submitWalkingForm : ' + vr);
        string result = '';
        try{
            Visitor_Registration__c vsData = [SELECT ID,Agent_ID__c from Visitor_Registration__c WHERE ID =:visitorId ];
            Channel_Partner__c cp;
            if(vsData != null && vsData.Agent_ID__c != null){
                cp = [SELECT ID ,Channel_Partner_Id__c FROM Channel_Partner__c WHERE Channel_Partner_Id__c =: vsData.Agent_ID__c LIMIT 1];
            }
            Visitor_Registration__c visitor = new Visitor_Registration__c(Id=visitorId);
            list<User> salesAdvisorRec = [select Id from User where name =: salesAdvisor limit 1];
            if(salesAdvisorRec.size()>0){
                sv.OwnerId = salesAdvisorRec[0].Id; 
            }
            list<Opportunity> sameSourceOppty = new list<Opportunity>();
            String strError;
            Lead objLead;
            Account objAcc;
            Opportunity objOpty;
            boolean isChannelPartner=false;
            sv.Status__c = 'In Progress';
            sv.Site_Visit_Start_Time__c = system.now();
            if(String.isBlank(string.valueOf(sv.Date__c))){
                sv.Date__c = System.Today();
            } 
            if(strMobile != null && strMobile != '') {
                sv.Mobile_Number__c = strMobile;
                sv.Project__c = strprojectId;
                sv.Email_Address__c = stremail;              
            } 
            if (strLeadId != null && strLeadId != '') {
                
                objLead = [Select Id, firstname, lastname, Email, pin_code__c, MobilePhone, Project__r.Name, RDS_Email__c, Birthdate__c,
                           Phone, Company_Name__c, RDS_Budget__c, Possession_Timeframe__c, LeadSource,
                           Profession__c, Project_Type__c, Designation__c, Budget_In_Lacs__c, RDS_Unit_type_configuration__c,
                           RDS_Alternate_Email_Id__c, Alternate_Mobile_Number__c, middlename, Address_1_and_2_O__c, Address_1_and_2_R__c, 
                           Reason_For_Purchase__c, Possession_Requirement__c, Lead_Sub_Source__c, Nationality__c                     
                           from Lead where Id=:strLeadId];
                sv.Address__c = objLead.Address_1_and_2_R__c;
                sv.LeadSource__c = objLead.LeadSource;
                sv.Birth_Date__c=objLead.Birthdate__c;                                 
                sv.Project__c = strprojectId;
                sv.Purpose_Of_Purchase__c = objLead.Reason_For_Purchase__c;
                sv.Occupation__c = objLead.Profession__c; 
                sv.Company_Business_Name__c=objLead.Company_Name__c;    
                sv.Designation__c=objLead.Designation__c;
                sv.Company_Business_Location__c = objLead.Address_1_and_2_O__c;                     
                sv.Configuration__c = objLead.RDS_Unit_type_configuration__c ;
                sv.Property_Type__c = objLead.Project_Type__c;
                sv.Budget_in_cr__c = objLead.Budget_In_Lacs__c;
                sv.Possessiom_Timeline__c = objLead.Possession_Requirement__c;
                sv.Nationality__c = objLead.Nationality__c;   
                If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();
                }                                        
            }
            if(strAccountId != null && strAccountId != '') {
                objAcc = [Select Id, PersonMobilePhone, Alternate_Email__c, Phone, MiddleName, PersonContact.Email,
                          Gender__c, Birth_Date__c, Alternate_Mobile_No__c, PersonEmail, firstname, lastname,
                          Designation_Permanent__c, Residential_Street__c, Office_Street__c,
                          Company_Name__c,Designation__c,Postal_Code__c,
                          profession__c, S_PReason_for_Purchase__c,Nationality__c,DocumentId__c
                          from Account where Id =:strAccountId];  
                
                sameSourceOppty = [select Id, Walk_in_Source__c from Opportunity where 
                                   AccountId =: strAccountId and 
                                   Walk_in_Source__c!=null and 
                                   Walk_in_Source__c=:vr.Source__c order by createddate desc limit 1];
                
                
                sv.Address__c  = objAcc.Residential_Street__c;
                sv.Birth_Date__c= objAcc.Birth_Date__c; 
                sv.Project__c = strprojectId;  
                sv.Purpose_Of_Purchase__c = objAcc.S_PReason_for_Purchase__c;  
                sv.Occupation__c = objAcc.profession__c; 
                sv.Company_Business_Name__c=objAcc.Company_Name__c;                             
                sv.Designation__c=objAcc.Designation__c;
                sv.Company_Business_Location__c = objAcc.Office_Street__c;         
                sv.Nationality__c = objAcc.Nationality__c;     
                If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();
                }  
                
            }
            if(strOptyId!=null)
            {
                objOpty=[select Name, Account.FirstName, Account.LastName, Account.MiddleName, Account_Mobile_Number__c,Walk_In_Referred_By__c,
                         Walk_in_Source__c, Walk_in_Sub_Source__c, Walk_In_CP__c, Referred_By__c, Account.Birth_Date__c,
                         Account.Alternate_Email__c, Email__c, Project__c,Configuration__c,
                         AccountId, Account.PersonEmail, Budget_In_Cr__c, Date_Of_Visit__c, Date_Of_Site_Visit__c,
                         Account.Residential_Street__c, Account.Designation__c, Account.Company_Name__c,
                         Account.profession__c, Account.Office_Street__c, Account.Phone, Reason_For_Purchase__c,
                         Budget_Site_Visit_In_Lacs__c, Purchase_Timeframe__c, Project_Type__c, S_Budget__c, LeadSource, Lead_Sub_Source__c,DocumentId__c 
                         from Opportunity where Id=:strOptyId];                    
                
                sv.Address__c = objOpty.Account.Residential_Street__c; 
                sv.LeadSource__c = objOpty.LeadSource;                  
                sv.Birth_Date__c = objOpty.Account.Birth_Date__c;
                sv.Project__c=objOpty.Project__c;
                sv.Purpose_Of_Purchase__c = objOpty.Reason_For_Purchase__c;            
                sv.Opportunity__c=objOpty.Id;  
                visitor.Opportunity__c = objOpty.Id;
                sv.Occupation__c = objOpty.Account.profession__c; 
                sv.Company_Business_Name__c = objOpty.Account.Company_Name__c;          
                sv.Designation__c = objOpty.Account.Designation__c;           
                sv.Company_Business_Location__c = objOpty.Account.Office_Street__c; 
                sv.Property_Type__c = objOpty.Project_Type__c;         
                sv.Budget_in_cr__c = objOpty.S_Budget__c;
                sv.Configuration__c = objOpty.Configuration__c;                                   
                sv.Possessiom_Timeline__c = objopty.Purchase_Timeframe__c;
                
                If(String.isBlank(string.valueOf(sv.Date__c))){
                    sv.Date__c = System.Today();
                }  
            }
            try
            {
                if ((strLeadId != null && strLeadId != '') && (strOptyId==null || strOptyId=='')) {
                    
                    
                    objLead.DocumentId__c = documentId;
                    objLead.Last_Call_Attempt_Status__c = 'Visit Confirmed';
                    objLead.Status = 'Book Site Visit - Visit Confirmed';
                    objLead.No_Follow_Up_Reminder__c = true;
                    
                    update objLead;
                    List < Lead > leadListToconvert = new List < Lead > ();
                    List < Lead > ConvertedLeadlist = new List < Lead > ();
                    Opportunity optyObjToupdate = new Opportunity();
                    
                    leadListToconvert.add(objLead);
                    if (leadListToconvert != null)
                        VisitorDashboardController.convertCIFLeads(leadListToconvert);
                    
                    ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Project__c from Lead
                                         where Id = : objLead.Id and Isconverted = true
                                         order by LastModifiedDate Desc limit 1];
                    
                    optyObjToupdate = [Select Id,Name,AccountId,Project__c,Walk_in_Source__c,Walk_in_Sub_Source__c, Walk_In_Referred_By__c,Account.PersonContact.Email,
                                       Walk_In_CP__c, Sales_Manager__c, Unique_SVF_Number__c, Walk_In_SC__c, Residential_Status__c,
                                       Walk_in_Employee_Id__c, Walk_in_Name_of_Person__c,
                                       Channel_Partner_Contact_Person__c from Opportunity
                                       where Id =: ConvertedLeadlist[0].ConvertedOpportunityId];
                    sv.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    visitor.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    optyObjToupdate.Project__c=sv.Project__c;
                    optyObjToupdate.Email__c = optyObjToupdate?.Account?.PersonContact?.Email;
                    optyObjToupdate.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                    optyObjToupdate.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                    optyObjToupdate.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;
                    optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                    optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                    optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                    optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
                    optyObjToupdate.Site_Visit_Email__c = stremail;
                    optyObjToupdate.Site_Visit_Mobile__c = strMobile;
                    optyObjToupdate.Walk_in_Source__c = 'Digital';
                    
                    if(sv.Channel_Partner__c != null)
                    {
                        optyObjToupdate.Walk_In_CP__c = sv.Channel_Partner__c;
                    }
                    if(sv.Sobha_Connect__c != null)
                    {
                        optyObjToupdate.Walk_In_SC__c = sv.Sobha_Connect__c;
                    }
                    optyObjToupdate.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;
                    optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
                    if(salesAdvisorRec.size()>0){
                        optyObjToupdate.OwnerId = salesAdvisorRec[0].Id; 
                        optyObjToupdate.Sales_Manager_lookup__c = salesAdvisorRec[0].Id;
                    }
                    else{
                        optyObjToupdate.OwnerId = UserInfo.getUserId(); 
                        optyObjToupdate.Sales_Manager_lookup__c = UserInfo.getUserId();
                    }
                    optyObjToupdate.DocumentId__c = documentId;
                    optyObjToupdate.S_Budget__c = sv.Budget__c;
                    Task t = getLatestReEnquiryTask(strLeadId);
                    if(t != null){
                        optyObjToupdate = updateUTMFieldsFromTask(optyObjToupdate,t);
                    }
                    update optyObjToupdate;
                    sv.LeadSource__c = 'Digital';
                    insert sv;
                    objLead.Status = 'Book Site Visit - Visit Confirmed';
                    update objLead;
                    
                }
                
                else if((strAccountId != null && strAccountId != '') && (strOptyId==null || strOptyId==''))
                    
                {    
                    objAcc.Alternate_Mobile_No__c = String.isBlank(objAcc.Alternate_Mobile_No__c) ? vr.Alternate_Mobile_Number__c : objAcc.Alternate_Mobile_No__c; 
                    objAcc.Alternate_Email__c = String.isBlank(objAcc.Alternate_Email__c) ? vr.AlternateEmail_Address__c : objAcc.Alternate_Email__c; 
                    objAcc.DocumentId__c = String.isBlank(objAcc.DocumentId__c) ? documentId : objAcc.DocumentId__c; 
                    try{
                        update objAcc;
                    }catch(Exception e){}
                    
                    Opportunity objOptyToInsert = new Opportunity(); 
                    objOptyToInsert.Name = sv.First_Name__c +' '+ sv.last_name__c;
                    objOptyToInsert.Project__c = strprojectId;
                    objOptyToInsert.CloseDate=System.today().addDays(60);                
                    objOptyToInsert.stagename = 'Qualification';
                    objOptyToInsert.AccountId =objAcc.Id;                
                    objOptyToInsert.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                    objOptyToInsert.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                    objOptyToInsert.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;              
                    objOptyToInsert.Email__c = objAcc?.PersonContact?.Email;
                    objOptyToInsert.Configuration__c = sv.Configuration__c;
                    objOptyToInsert.S_Budget__c = sv.Budget_in_cr__c;
                    objOptyToInsert.Purchase_Timeframe__c = sv.Possessiom_Timeline__c;
                    objOptyToInsert.Project_Type__c = sv.Property_Type__c;
                    objOptyToInsert.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;
                    objOptyToInsert.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                    objOptyToInsert.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                    objOptyToInsert.Residential_Status__c = sv.Residential_Status__c; 
                    objOptyToInsert.Date_Of_Site_Visit__c = sv.Date__c;  
                    objOptyToInsert.Site_Visit_Email__c = stremail;
                    objOptyToInsert.Site_Visit_Mobile__c = strMobile; 
                    objOptyToInsert.Walk_in_Source__c = 'Digital';
                    if(sv.Channel_Partner__c != null)
                    {
                        objOptyToInsert.Walk_In_CP__c = sv.Channel_Partner__c;
                    } 
                    if(sv.Sobha_Connect__c != null)
                    {
                        objOptyToInsert.Walk_In_SC__c = sv.Sobha_Connect__c;
                    }
                    objOptyToInsert.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;   
                    objOptyToInsert.Date_Of_Site_Visit__c = sv.Date__c;
                    if(salesAdvisorRec.size()>0){
                        objOptyToInsert.OwnerId = salesAdvisorRec[0].Id; 
                        objOptyToInsert.Sales_Manager_lookup__c = salesAdvisorRec[0].Id;
                    }
                    else{
                        objOptyToInsert.OwnerId = UserInfo.getUserId(); 
                        objOptyToInsert.Sales_Manager_lookup__c = UserInfo.getUserId();
                    }
                    objOptyToInsert.DocumentId__c = documentId;
                    objOptyToInsert.S_Budget__c = (!String.isBlank(sv.Budget__c) && String.isBlank(objOptyToInsert.S_Budget__c)) ? sv.Budget__c : objOptyToInsert.S_Budget__c;
                    Task t = getLatestReEnquiryTask(strAccountId);
                    if(t != null){
                        objOptyToInsert = updateUTMFieldsFromTask(objOptyToInsert,t);
                    }
                    insert objOptyToInsert;
                    sv.Opportunity__c = objOptyToInsert.Id;
                    sv.LeadSource__c = 'Digital';
                    visitor.Opportunity__c = objOptyToInsert.Id;
                    insert sv;
                }
                else if(strOptyId!=null)
                {
                    Opportunity oppToUpdate = [select Id, OwnerId, AccountId, Account.PersonContact.Email from Opportunity where Id =: strOptyId LIMIT 1];
                    sv.OwnerId = oppToUpdate.OwnerId;
                    sv.LeadSource__c = 'Digital';
                    insert sv;
                    Task t = getLatestReEnquiryTask(oppToUpdate.AccountId);
                    if(t != null){
                        oppToUpdate = updateUTMFieldsFromTask(oppToUpdate,t);
                    }
                    oppToUpdate.Email__c = oppToUpdate?.Account?.PersonContact?.Email;
                    oppToUpdate.Walk_in_Source__c = 'Digital';
                    update oppToUpdate;
                }
                update visitor;
                return 'success';
            }
            catch(exception ex){
                result = ex.getMessage();
                System.debug('DML Exception msg::'+ex);
                System.debug('DML Exception getStackTraceString::'+ex.getStackTraceString());
            }
        }
        catch(Exception e){
            result = e.getMessage();
            system.debug('submitWalkingForm getMessage: '+e.getMessage());
            system.debug('submitWalkingForm getStackTraceString: '+e.getStackTraceString());
        }
        return result;
    }
    
    public static Opportunity updateUTMFieldsFromTask(Opportunity op, Task t){
        op.UTM_Campaign__c = t.UTM_Campaign__c;
        op.UTM_Source__c  = t.UTM_Source__c;
        op.Landing_Page_URL__c = t.Landing_Page_URL__c;
        op.Walk_in_Source__c = 'Digital';
        op.Web_Source__c = t.Web_Source__c;
        op.Campaign__c = t.Bid_Type__c;
        return op;
    }
    
    public static Task getLatestReEnquiryTask(string recordId){
        list<Task> reenquiryTasks = [
            select Id,Enquiry_Source__c,UTM_Source__c,UTM_Campaign__c,Web_Source__c,Landing_Page_URL__c,Bid_Type__c from Task where (WhoId =: recordId or WhatId =: recordId) and subject like '%enquiry%' and createddate = TODAY order by createddate desc
        ];
        if(reenquiryTasks.size() > 0){
            return reenquiryTasks[0];
        }
        else{
            return null;
        }
    }
    
    public class LeadWrapper {
        @AuraEnabled public string leadName;
        @AuraEnabled public string emailBody;
        @AuraEnabled public string emailSubject;
    }
}