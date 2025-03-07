public without sharing class VisitorDashboardController {
    
    @AuraEnabled
    public static List<Visitor_Registration__c> getVisitors(){ 
        return [select Id,Name,First_Name__c,Last_Name__c,Mobile__c,Email__c,Nationality__c,Country__c, Alternate_Mobile_Number__c, AlternateEmail_Address__c  from Visitor_Registration__c where Status__c='Submitted' ORDER BY CreatedDate DESC];
    }
    
    @AuraEnabled
    public static string getContentDocumentId(string visitorId){ 
        list<contentdocumentlink> links = [select id,contentdocumentId from contentdocumentlink where LinkedEntityId =: visitorId];
        if(links.size()>0)
            return links[0].contentdocumentId;
        else 
            return null;
    }
    
    @AuraEnabled
    public static string acceptRejectVisitor(string visitorId, string status, boolean proceedWithExistingLead){
        string res='';
        if(status=='Rejected'){
            try{
                Visitor_Registration__c visitor = new Visitor_Registration__c(Id=visitorId,Status__c='Rejected');
                update visitor;
                res='success';
            }
            catch(Exception e){
                res='error : '+e.getMessage();
            }
        }
        if(status=='Accepted'){
            try{
                Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,Alternate_Mobile_Number__c,DocumentId__c,AlternateEmail_Address__c,File_Content__c from Visitor_Registration__c where Id=:visitorId];
                if(proceedWithExistingLead==false){
                    System.Debug('visitor Testing----' +visitor);
                    
                    
                    list<Opportunity> oppList = [select Id from Opportunity where
                                                 (Account.PersonMobilePhone != null and Account.PersonMobilePhone=:visitor.Mobile__c) OR
                                                 (Account.Phone!= null AND Account.Phone =: visitor.Mobile__c) OR 
                                                 (Account.PersonMobilePhone != null and Account.PersonMobilePhone=:visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Phone!= null AND Account.Phone =: visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Alternate_Mobile_No__c !=null and Account.Alternate_Mobile_No__c=:visitor.Alternate_Mobile_Number__c) OR
                                                 (Account.Alternate_number_1__c!= null AND Account.Alternate_number_1__c =: visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Alternate_number_2__c!= null AND Account.Alternate_number_2__c =: visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Alternate_number_3__c!= null AND Account.Alternate_number_3__c =: visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Alternate_office_phone_number__c!= null AND Account.Alternate_office_phone_number__c =: visitor.Alternate_Mobile_Number__c) OR 
                                                 (Account.Alternate_Mobile_No__c !=null and Account.Alternate_Mobile_No__c=: visitor.Mobile__c) OR
                                                 (Account.Alternate_number_1__c!= null AND Account.Alternate_number_1__c =: visitor.Mobile__c) OR 
                                                 (Account.Alternate_number_2__c!= null AND Account.Alternate_number_2__c =: visitor.Mobile__c) OR 
                                                 (Account.Alternate_number_3__c!= null AND Account.Alternate_number_3__c =: visitor.Mobile__c) OR 
                                                 (Account.Alternate_office_phone_number__c!= null AND Account.Alternate_office_phone_number__c =: visitor.Mobile__c)OR
                                                 (Account.PersonEmail!=null AND Account.PersonEmail =: visitor.Email__c) OR 
                                                 (Account.Alternate_Email__c!=null AND Account.Alternate_Email__c= : visitor.Email__c) OR
                                                 (Account.PersonEmail!=null AND Account.PersonEmail =: visitor.AlternateEmail_Address__c) OR 
                                                 (Account.Alternate_Email__c!=null AND Account.Alternate_Email__c= : visitor.AlternateEmail_Address__c)OR
                                                 (DocumentId__c != null and DocumentId__c=:visitor.DocumentId__c)];
                    System.debug('OppList Duplication check-->' +oppList);
                    if(oppList.size()>0){
                        
                        list<Customer_Registration__c> siteVisits = [select Id, Name, opportunity__r.Opportunity_ID__c, CreatedDate from Customer_Registration__c where opportunity__c IN: oppList order by createddate desc];
                        if(siteVisits.size()>0){
                            return 'There is already a site visit happend by this customer on '+siteVisits[0].CreatedDate.format()+' Opportunity ID: '+siteVisits[0].opportunity__r.Opportunity_ID__c+' Site Visit ID: '+siteVisits[0].Name+'. Are you sure you want to proceed?';
                        }
                    }
                }
                
                VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id,visitor.DocumentId__c,visitor.File_Content__c,visitor.Alternate_Mobile_Number__c,visitor.AlternateEmail_Address__c );
                visitor.Status__c='Accepted';
                update visitor;
                visitor = [select Id,Opportunity__c,Opportunity__r.Opportunity_ID__c from Visitor_Registration__c where Id=:visitorId];
                if(visitor.Opportunity__c!=null){
                    list<Customer_Registration__c> siteVisits = [select Id, Name from Customer_Registration__c where Opportunity__c =: visitor.Opportunity__c order by createddate desc limit 1];
                    string siteVisitName=(siteVisits.size()>0)?siteVisits[0].Name:'';
                    res='success#'+visitor.Opportunity__r.Opportunity_ID__c+'#'+siteVisitName;
                }
                else
                    res='success';
            }
            catch(Exception e){
                res='error : '+e.getMessage();
            }
        }
        return res;
    } 
    
    @AuraEnabled
    public static void submitVisitor(string projectId, string email, string phone, string visId, string documentId, string FileContent, string alternatephone, string alternatEmail){ 
        Set<Id> leadId = new Set<Id> ();
        Set<Id> accountId = new Set<Id> ();
        list < Lead > lstDuplicateLeadsEmail = new list < Lead > ();
        list < Lead > lstDuplicateLeads = new list < Lead > ();
        list < Opportunity > lstDuplicateOpty = new list < Opportunity > ();
        list < Account > lstDuplicateAccount = new list < Account > ();
        string strError = '';
        Boolean isDuplicateLeadExist = false;
        Boolean isDuplicateAccountExist = false;
        Boolean isDuplicateOptyExist = false;
        Boolean isMailDuplicateLeadExist = false;
        Boolean isDuplicateAccountExistEmail = false;
        list<Account> lstDuplicateAccountEmail = new list<Account>();
        string strLeadId;
        string strOptyId;
        string strAccountId;
        
        boolean isNew = false;
        lstDuplicateLeads = [Select Id, Name, MobilePhone, Project__r.Name ,Alternate_Mobile_Number__c,Phone,Owner.Name 
                             from Lead where(mobilephone = : phone OR Phone = : phone) and isConverted = false]; 
        
        list<Project__c> projList = [select Id from Project__c where Name=: projectId limit 1];
        projectId = null;
        if(projList.size()>0)
            projectId = projList[0].Id;
        
        
        if(string.isNotBlank(email))
        {
            
            lstDuplicateLeadsEmail = [select Id, Name, MobilePhone, Project__r.Name,Owner.Name ,
                                      Email,RDS_Alternate_Email_Id__c from Lead where (Email =:email OR RDS_Alternate_Email_Id__c=:email)  and isConverted = false];
            
            
            for(Lead lmdupes : lstDuplicateLeads) { leadId.add(lmdupes.Id); }
            
            for(Lead lEdupes : lstDuplicateLeadsEmail) { leadId.add(lEdupes.Id); }
            
            if(leadId.size()>1) { strError= 'More Than One leads found'; }
            
            if ((lstDuplicateLeads != null && lstDuplicateLeads.size() > 0)) {
                isDuplicateLeadExist = true;
                if(lstDuplicateLeadsEmail.size()!=0)
                {
                    if(lstDuplicateLeadsEmail[0].Id != lstDuplicateLeads[0].Id)
                    {
                        isMailDuplicateLeadExist = true;
                    }
                }
            }    
            else {
                isDuplicateLeadExist = false;
            }
        }
        
        if (lstDuplicateLeads != null && lstDuplicateLeads.size() > 0) {
            isDuplicateLeadExist = true;
        } 
        else {
            isDuplicateLeadExist = false;
        }
        if(lstDuplicateLeads.isEmpty() && lstDuplicateLeads.size() == 0)
        {
            if(lstDuplicateLeadsEmail != null && lstDuplicateLeadsEmail.size() > 0) { isDuplicateLeadExist = true; isMailDuplicateLeadExist = true; }
        }
        
        lstDuplicateAccount = [Select Id, Name, PersonMobilePhone, Phone,Alternate_Mobile_No__c, PersonEmail,Owner.Name  from Account
                               where(PersonMobilePhone = : phone OR Phone = : phone)]; 
        System.debug('Im duplicate Acc' +lstDuplicateAccount);
        
        if(string.isNotBlank(email))
        {
            lstDuplicateAccountEmail = [Select Id, Name, PersonMobilePhone, Alternate_Mobile_No__c,Owner.Name , PersonEmail from Account
                                        where PersonEmail =: email OR Alternate_Email__c= : email ];
            for(Account AccEmaildupes : lstDuplicateAccountEmail) { accountId.add(AccEmaildupes.Id); }
            
            for(Account AccMobdupes : lstDuplicateAccount) { accountId.add(AccMobdupes.Id); }
            
            if(accountId.size()>1) { strError='More Than One Account found'; }
            
            if (!lstDuplicateAccount.isEmpty() && lstDuplicateAccount.size() > 0)
            {
                isDuplicateAccountExist = true;
                
                if(lstDuplicateAccountEmail.size()!= 0)
                {
                    if( lstDuplicateAccount[0].Id != lstDuplicateAccountEmail[0].Id)
                    {
                        isDuplicateAccountExistEmail = true;
                    }
                }
            }
        }    
        if (!lstDuplicateAccount.isEmpty() && lstDuplicateAccount.size() > 0) {
            lstDuplicateOpty = [select id, Name, Project__r.Name, Account.PersonMobilePhone, OwnerId, Account.Name,
                                Account.Alternate_Email__c, Account.PersonEmail,
                                LeadSource, Project__c, AccountId,Owner.Name 
                                from Opportunity where AccountId = : lstDuplicateAccount[0].Id]; 
            
            System.debug(+lstDuplicateOpty);
            
            if (!lstDuplicateOpty.isEmpty() && lstDuplicateOpty.size() > 0) {
                isDuplicateOptyExist = true;
                isDuplicateAccountExist = false;
            } else {
                isDuplicateAccountExist = true;
                isDuplicateOptyExist = false;
            }
        }
        
        if(lstDuplicateAccount.isEmpty() && lstDuplicateAccount.size() == 0)
        {
            if(lstDuplicateAccountEmail != null  && lstDuplicateAccountEmail.size() > 0 )
            {
                lstDuplicateOpty = [select id, Name, Project__r.Name,Account.PersonEmail, Owner.Name ,Account.PersonMobilePhone,Account.Alternate_Email__c, OwnerId, Account.Name,
                                    LeadSource, Project__c, AccountId 
                                    from Opportunity where AccountId = : lstDuplicateAccountEmail[0].Id];
                
                if (!lstDuplicateOpty.isEmpty() && lstDuplicateOpty.size() > 0) {
                    isDuplicateOptyExist = true;
                    isDuplicateAccountExist = false;
                }
                else {
                    isDuplicateAccountExistEmail = true;
                    isDuplicateAccountExist = true;
                    isDuplicateOptyExist = false;
                }
            }
        }
        
        try {
            if (projectId == null || projectId == '') { strError = 'Please select the Project to proceed.';  }
            if (phone == '') {
                strError = 'Please enter the Contact No to proceed.';
            }
            
            if(phone != '' && phone != null){
                String mobile = phone;
                if(mobile.startsWith('971') || mobile.startsWith('0') || mobile.startsWith('+971')  ) { strError = 'Mobile Number should not start with Country code.'; }
            }
            
            list < Lead > lstLead = [Select Id, Name, MobilePhone, Project__r.Name from Lead where 
                                     ((MobilePhone!=null AND MobilePhone =: phone) OR
                                      (Phone!=null AND Phone =: phone) OR 
                                      (MobilePhone!=null AND MobilePhone =: alternatephone) OR
                                      (Phone!=null AND Phone =: alternatephone) OR 
                                      (RDS_Alternate_Mobile_No__c!=null AND RDS_Alternate_Mobile_No__c =: phone) OR 
                                      (RDS_Alternate_Mobile_No__c!=null AND RDS_Alternate_Mobile_No__c =: alternatephone) OR 
                                      (Alternate_Mobile_Number__c!=null AND Alternate_Mobile_Number__c =: phone) OR 
                                      (Alternate_Mobile_Number__c!=null AND Alternate_Mobile_Number__c =: alternatephone) OR 
                                      (Email!=null AND Email =: email) OR 
                                      (RDS_Alternate_Email_Id__c!=null AND RDS_Alternate_Email_Id__c =: alternatEmail) OR
                                      (Email!=null AND Email =: email) OR 
                                      (RDS_Alternate_Email_Id__c!=null AND RDS_Alternate_Email_Id__c =: alternatEmail) OR  
                                      (DocumentId__c!=null AND DocumentId__c =: documentId)) 
                                     and isConverted = false order by createddate desc]; 
            System.debug('Dup Lead List' +lstLead);
            
            
            List<Account> matchedAccounts = [Select Id, Name, PersonMobilePhone, Phone, Alternate_Mobile_No__c,Alternate_number_1__c,Alternate_number_2__c,Alternate_number_3__c, Alternate_office_phone_number__c,PersonEmail, Alternate_Email__c,DocumentId__c from Account where 
                                        ((DocumentId__c!=null AND DocumentId__c =: documentId) OR
                                         (PersonMobilePhone!=null AND PersonMobilePhone =: phone) OR 
                                         (Phone!= null AND Phone =: phone) OR 
                                         (Alternate_Mobile_No__c!= null AND Alternate_Mobile_No__c =: phone) OR 
                                         (Alternate_number_1__c!= null AND Alternate_number_1__c =: phone) OR 
                                         (Alternate_number_2__c!= null AND Alternate_number_2__c =: phone) OR 
                                         (Alternate_number_3__c!= null AND Alternate_number_3__c =: phone) OR 
                                         (Alternate_office_phone_number__c!= null AND Alternate_office_phone_number__c =: phone) OR 
                                         (PersonMobilePhone!=null AND PersonMobilePhone =: alternatephone) OR 
                                         (Phone!= null AND Phone =: alternatephone) OR 
                                         (Alternate_Mobile_No__c!= null AND Alternate_Mobile_No__c =: alternatephone) OR 
                                         (Alternate_number_1__c!= null AND Alternate_number_1__c =: alternatephone) OR 
                                         (Alternate_number_2__c!= null AND Alternate_number_2__c =: alternatephone) OR 
                                         (Alternate_number_3__c!= null AND Alternate_number_3__c =: alternatephone) OR 
                                         (Alternate_office_phone_number__c!= null AND Alternate_office_phone_number__c =: alternatephone) OR 
                                         (PersonEmail!=null AND PersonEmail =: email) OR 
                                         (Alternate_Email__c!=null AND Alternate_Email__c= : email) OR 
                                         (PersonEmail!=null AND PersonEmail =: alternatEmail) OR 
                                         (Alternate_Email__c!=null AND Alternate_Email__c= : alternatEmail))]; 
            
            
            System.debug('Dup Account List' +matchedAccounts);
            
            // Variable to store the prioritized account
            Account acc = null;
            
            // Loop through the queried accounts and assign based on the condition precedence
            for (Account a : matchedAccounts) {
                // 1. Check if DocumentId__c matches (highest priority)
                if (documentId != null && a.DocumentId__c == documentId) {
                    acc = a;
                    break; // Exit the loop since we found the highest priority match
                }
            }
            
            // 2. If no account was found based on DocumentId, check phone number conditions
            if (acc == null) {
                for (Account a : matchedAccounts) {
                    if ((phone != null && (
                        a.PersonMobilePhone == phone || a.Phone == phone || 
                        a.Alternate_Mobile_No__c == phone || a.Alternate_number_1__c == phone || 
                        a.Alternate_number_2__c == phone || a.Alternate_number_3__c == phone || 
                        a.Alternate_office_phone_number__c == phone))) {
                                acc = a;
                                break; // Exit the loop once a phone match is found
                            }
                }
            }
            
              // 3. If no account was found based on DocumentId,Phone check Alternate phone number conditions
            if (acc == null) {
                for (Account a : matchedAccounts) {
                    if ((alternatePhone != null && (
                        a.PersonMobilePhone == alternatePhone || a.Phone == alternatePhone || 
                        a.Alternate_Mobile_No__c == alternatePhone || a.Alternate_number_1__c == alternatePhone || 
                        a.Alternate_number_2__c == alternatePhone || a.Alternate_number_3__c == alternatePhone || 
                        a.Alternate_office_phone_number__c == alternatePhone))) {
                            acc = a;
                            break; // Exit the loop once a phone match is found
                        }
                }
            }
            
            // 4. If no account was found based on DocumentId or phone, check email conditions
            if (acc == null) {
                for (Account a : matchedAccounts) {
                    if ((email != null && (a.PersonEmail == email || a.Alternate_Email__c == email))) {
                            acc = a;
                            break; // Exit the loop once an email match is found
                        }
                }
            }
            
              // 5. If no account was found based on DocumentId or phone,Email check Alternate email conditions
            if (acc == null) {
                for (Account a : matchedAccounts) {
                    if ((alternatEmail != null && (a.PersonEmail == alternatEmail || a.Alternate_Email__c == alternatEmail))) {
                            acc = a;
                            break; // Exit the loop once an email match is found
                        }
                }
            }
            
            
            
            List < opportunity > lstOpp = new List < opportunity > ();
            if (lstLead != null && lstLead.size() > 0) {
                strLeadId = lstLead[0].Id;
            } 
            else if (acc != null) { //lstAccount != null && lstAccount.size() > 0
                strAccountId = acc.Id;
                //sendEmailNotification(System.Label.Site_Visit_Notification_Email,lstAccount);
            } 
            list<Visitor_Registration__c> visList = [select Id,First_Name__c,Last_Name__c,Mobile__c,Email__c,Permanent_Address__c,Birth_Date__c,
                                                     City__c,Country__c,UAE_Resident__c,Interested_in__c,Purpose_of_Purchase__c,DocumentId__c,AlternateEmail_Address__c,
                                                     Remarks_if_any__c,Source__c,Agent_Name__c,Agent_ID__c,Company__c,Sales_Adviser__c,
                                                     Nationality__c,Alternate_Email_Id__c,Alternate_Mobile_Number__c,Designation__c,
                                                     Existing_Sobha_Owner__c,Occupation__c,Project_Name__c,Visiting_On_Behalf_Of__c,Residential_Status__c,Sobha_Connect_Company_Name__c,
                                                     Sobha_Connect_Id__c,Sobha_Connect_Name__c,product_Type__c,Property_Type__c,Possession_Timeline__c,Budget__c,Unique_Id__c
                                                     from Visitor_Registration__c where Id =: visId];
            
            
            if(visList.size()>0){
                Visitor_Registration__c vr = visList[0];
                Customer_Registration__c sv = new Customer_Registration__c();
                sv.First_Name__c = vr.First_Name__c;
                sv.Last_Name__c = vr.Last_Name__c;
                sv.Address__c = vr.Permanent_Address__c;
                sv.Mobile_Number__c = vr.Mobile__c;
                sv.Email_Address__c = vr.Email__c;
                sv.Alternate_Email_Id__c = vr.Alternate_Email_Id__c;
                sv.AlternateEmailAddress__c = vr.AlternateEmail_Address__c;
                sv.Alternate_Mobile_Number__c = vr.Alternate_Mobile_Number__c;
                sv.Purpose_Of_Purchase__c = vr.Purpose_of_Purchase__c;
                sv.Occupation__c = vr.Occupation__c;
                sv.Company_Business_Name__c = vr.Company__c;
                sv.Designation__c = vr.Designation__c;
                sv.Nationality__c = vr.Nationality__c;
                sv.Source__c = vr.Source__c;
                sv.Unique_Id__c = vr.Unique_Id__c;
                sv.Possessiom_Timeline__c = vr.Possession_Timeline__c;
                sv.Configuration__c = vr.product_Type__c;
                sv.Interested_In__c =vr.Property_Type__c;
                sv.Property_Type__c =vr.Property_Type__c;
                sv.Indicative_Budget__c =vr.Budget__c;
                sv.project__c = projectId;
                sv.Budget__c = vr.Budget__c;
                sv.Birth_Date__c = vr.Birth_Date__c;
                sv.DocumentId__c = vr.DocumentId__c;
                sv.How_Did_You_Hear_About_Us__c = vr.Source__c;
                if(vr.Agent_ID__c != null){
                    list<Channel_Partner__c> cp = [select Id from Channel_Partner__c where Channel_Partner_Id__c =: vr.Agent_ID__c LIMIT 1];
                    if(cp.size()>0)
                        sv.Channel_Partner__c = cp[0].Id;
                }
                if(vr.Sobha_Connect_Id__c != null){
                    list<Sobha_Connect__c> sc = [select Id from Sobha_Connect__c where Name =: vr.Sobha_Connect_Id__c LIMIT 1];
                    if(sc.size()>0)
                        sv.Sobha_Connect__c = sc[0].Id;
                }
                VisitorDashboardController.submitWalkingForm(sv,strLeadId,strOptyId,strAccountId,projectId,phone,email, FileContent, vr.Sales_Adviser__c, vr.Id,documentId, visList[0], matchedAccounts);
            }
        } catch (exception ex) {
            system.debug('VVK inside catch : '+ex.getMessage());
            string strTempError = '';
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            
            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();
            
        }
    }
    
    public static void submitWalkingForm(Customer_Registration__c sv,string strLeadId,string strOptyId, string strAccountId, string strprojectId,string strMobile,string stremail, String FileContent, string salesAdvisor, string visitorId, string documentId, Visitor_Registration__c vr, List<Account> lstAccount){
        system.debug('VVK submitWalkingForm : ' + vr);
        system.debug('VVK submitWalkingForm : ' + vr);
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
                objAcc = [Select Id, PersonMobilePhone, Alternate_Email__c, Phone, MiddleName,
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
                strError = '';
                if(sv.First_Name__c == null || sv.First_Name__c == '')
                {
                    strError='Please Enter First Name';
                }
                if(sv.How_Did_You_Hear_About_Us__c == null || sv.How_Did_You_Hear_About_Us__c == '')
                {
                    strError='Please Let Us Know Walk-In Source';
                }               
                if(sv.Last_Name__c == null || sv.Last_Name__c=='')
                {
                    strError='Please Enter Last Name';
                }                        
                if(sv.How_Did_You_Hear_About_Us__c != null || sv.How_Did_You_Hear_About_Us__c != '')
                {
                    if(sv.How_Did_You_Hear_About_Us__c == 'Channel Partner')
                    {
                        isChannelPartner=true;
                    }
                }
                if(sv.Alternate_Mobile_Number__c != '' && sv.Alternate_Mobile_Number__c != null){
                    String mobile = sv.Alternate_Mobile_Number__c;
                    if(mobile.startsWith('971') || mobile.startsWith('0') || mobile.startsWith('+971')  )
                    {
                        strError = 'Mobile Number should not start with Country code';
                    }
                }  
                if(sv.Residential_Status__c == null || sv.Residential_Status__c == '')
                {
                    strError='Please Enter Residential Status';
                } 
                if(sv.Nationality__c == null || sv.Nationality__c == '')
                {
                    strError='Please Enter Nationality';
                } 
                if((strLeadId=='' || strLeadId == null) && (strOptyId==null || strOptyId=='') && (strAccountId==null || strAccountId==''))
                {               
                    Lead newLead=new Lead();
                    newLead.firstname=sv.First_Name__c;
                    //newLead.middlename=sv.Middle_Name__c;
                    newLead.lastname=sv.Last_Name__c;
                    newLead.Address_1_and_2_R__c = sv.Address__c;      
                    newLead.MobilePhone = sv.Mobile_Number__c;
                    newLead.Phone = sv.Alternate_Mobile_Number__c;
                    newLead.Email = sv.Email_Address__c;
                    newLead.RDS_Alternate_Email_Id__c = sv.Alternate_Email_Id__c;                                          
                    newLead.Birthdate__c=sv.Birth_Date__c; 
                    newLead.Reason_For_Purchase__c = sv.Purpose_Of_Purchase__c;                              
                    newLead.Profession__c  = sv.Occupation__c;  
                    newLead.Company_Name__c= sv.Company_Business_Name__c;          
                    newLead.Address_1_and_2_O__c = sv.Company_Business_Location__c;
                    newLead.Designation__c= sv.Designation__c;
                    newLead.Project_Type__c = sv.Property_Type__c;
                    newLead.Budget_In_Lacs__c = sv.Budget_in_cr__c;
                    newLead.RDS_Unit_type_configuration__c = sv.Configuration__c;
                    newLead.Possession_Requirement__c = sv.Possessiom_Timeline__c;
                    newlead.Site_Visit_Lead__c = True; 
                    newlead.Nationality__c = sv.Nationality__c; 
                    newlead.DocumentId__c = sv.DocumentId__c;
                    newlead.Channel_Partner__c = cp != null ? cp.Id : null;
                    insert newLead;
                    
                    List < Lead > leadListToconvert = new List < Lead > ();
                    List < Lead > ConvertedLeadlist = new List < Lead > ();
                    Opportunity optyObjToupdate = new Opportunity();
                    
                    leadListToconvert.add(newLead);
                    if (leadListToconvert != null)
                        convertCIFLeads(leadListToconvert);
                    
                    
                    ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Project__c from Lead
                                         where Id = : newLead.Id and Isconverted = true
                                         order by LastModifiedDate Desc limit 1];
                    
                    optyObjToupdate = [Select Id,Name,Project__c,Walk_in_Source__c, Walk_in_Sub_Source__c, Date_Of_Site_Visit__c,
                                       Walk_In_Referred_By__c, Walk_In_CP__c, Sales_Manager__c, Unique_SVF_Number__c, Channel_Partner_Contact_Person__c,
                                       Walk_In_SC__c, Residential_Status__c, Walk_in_Employee_Id__c, Walk_in_Name_of_Person__c
                                       from Opportunity where Id =: ConvertedLeadlist[0].ConvertedOpportunityId];
                    
                    
                    
                    sv.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    visitor.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    optyObjToupdate.Project__c = sv.Project__c;                
                    optyObjToupdate.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                    optyObjToupdate.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                    optyObjToupdate.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;                
                    optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c; 
                    optyObjToupdate.Channel_Partner__c = cp != null ? cp.Id : null;
                    optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                    optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                    optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                    optyObjToupdate.Site_Visit_Email__c = stremail;
                    optyObjToupdate.Site_Visit_Mobile__c = strMobile;
                    
                    if(sv.Channel_Partner__c != null)
                    {
                        optyObjToupdate.Walk_In_CP__c = sv.Channel_Partner__c;
                    } 
                    if(sv.Sobha_Connect__c != null)
                    {
                        optyObjToupdate.Walk_In_SC__c = sv.Sobha_Connect__c;
                    }
                    if(salesAdvisorRec.size()>0){
                        optyObjToupdate.OwnerId = salesAdvisorRec[0].Id; 
                        optyObjToupdate.Sales_Manager_lookup__c = salesAdvisorRec[0].Id;
                    }
                    optyObjToupdate.Channel_Partner_Contact_Person__c = sv.Channel_Partner_Contact_Person__c;  
                    optyObjToupdate.DocumentId__c = documentId;
                    optyObjToupdate.S_Budget__c =sv.Budget__c;
                    update optyObjToupdate;
                    insert sv;
                    
                    updateVisitorsFile(sv.Id, visitorId);
                    
                }
                else if ((strLeadId != null && strLeadId != '') && (strOptyId==null || strOptyId=='')) {
                    
                    
                    objLead.DocumentId__c = documentId;
                    objLead.LeadSource = sv.How_Did_You_Hear_About_Us__c;
                    objLead.Lead_Source__c = sv.How_Did_You_Hear_About_Us__c;
                    
                    update objLead;
                    List < Lead > leadListToconvert = new List < Lead > ();
                    List < Lead > ConvertedLeadlist = new List < Lead > ();
                    Opportunity optyObjToupdate = new Opportunity();
                    
                    leadListToconvert.add(objLead);
                    if (leadListToconvert != null)
                        convertCIFLeads(leadListToconvert);
                    
                    ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, Project__c from Lead
                                         where Id = : objLead.Id and Isconverted = true
                                         order by LastModifiedDate Desc limit 1];
                    
                    optyObjToupdate = [Select Id,Name,AccountId,Project__c,Walk_in_Source__c,Walk_in_Sub_Source__c, Walk_In_Referred_By__c,
                                       Walk_In_CP__c, Sales_Manager__c, Unique_SVF_Number__c, Walk_In_SC__c, Residential_Status__c,
                                       Walk_in_Employee_Id__c, Walk_in_Name_of_Person__c,
                                       Channel_Partner_Contact_Person__c from Opportunity
                                       where Id =: ConvertedLeadlist[0].ConvertedOpportunityId];
                    sv.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    visitor.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    optyObjToupdate.Project__c=sv.Project__c;
                    
                    optyObjToupdate.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                    optyObjToupdate.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                    optyObjToupdate.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;
                    optyObjToupdate.Walk_in_Employee_Id__c = sv.Employee_Id__c;
                    optyObjToupdate.Walk_in_Name_of_Person__c = sv.Name_of_Person__c;
                    optyObjToupdate.Residential_Status__c = sv.Residential_Status__c;
                    optyObjToupdate.Date_Of_Site_Visit__c = sv.Date__c;
                    optyObjToupdate.Site_Visit_Email__c = stremail;
                    optyObjToupdate.Site_Visit_Mobile__c = strMobile;

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
                    optyObjToupdate.DocumentId__c = documentId;
                    optyObjToupdate.S_Budget__c = sv.Budget__c;
                    update optyObjToupdate;
                    
                    insert sv;
                    updateVisitorsFile(sv.Id, visitorId);
                    sendEmailNotification(System.Label.Site_Visit_Notification_Email, lstAccount);
                    
                }
                
                else if((strAccountId != null && strAccountId != '') && (strOptyId==null || strOptyId==''))
                    
                {    
                    
                    objAcc.Alternate_Mobile_No__c = String.isBlank(objAcc.Alternate_Mobile_No__c) ? vr.Alternate_Mobile_Number__c : objAcc.Alternate_Mobile_No__c; //objAcc.Alternate_Mobile_No__c = vr.Alternate_Mobile_Number__c; 
                    objAcc.Alternate_Email__c = String.isBlank(objAcc.Alternate_Email__c) ? vr.AlternateEmail_Address__c : objAcc.Alternate_Email__c; //objAcc.Alternate_Email__c= vr.AlternateEmail_Address__c;
                    objAcc.DocumentId__c = String.isBlank(objAcc.DocumentId__c) ? documentId : objAcc.DocumentId__c; //objAcc.DocumentId__c = documentId; 
                    try{
                        update objAcc;
                    }catch(Exception e){}
                    
                    Opportunity objOptyToInsert = new Opportunity(); 
                    objOptyToInsert.Name = sv.First_Name__c +' '+ sv.last_name__c;
                    objOptyToInsert.Project__c = strprojectId;
                    objOptyToInsert.CloseDate=System.today().addDays(60);                
                    objOptyToInsert.stagename = 'Opportunity Identified';
                    objOptyToInsert.AccountId =objAcc.Id;                
                    objOptyToInsert.Walk_in_Source__c=sv.How_Did_You_Hear_About_Us__c;
                    objOptyToInsert.Walk_in_Sub_Source__c=sv.Sub_Source__c;
                    objOptyToInsert.Walk_In_Referred_By__c=sv.Please_specify_Source_Name__c;              
                    
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
                    objOptyToInsert.DocumentId__c = documentId;
                    objOptyToInsert.S_Budget__c = (!String.isBlank(sv.Budget__c) && String.isBlank(objOptyToInsert.S_Budget__c)) ? sv.Budget__c : objOptyToInsert.S_Budget__c;
                    insert objOptyToInsert;
                    System.debug('objOptyToInsert:tejaInsert:::'+objOptyToInsert.S_Budget__c);
                    sv.Opportunity__c = objOptyToInsert.Id;
                    visitor.Opportunity__c = objOptyToInsert.Id;
                    insert sv;
                    updateVisitorsFile(sv.Id, visitorId);
                    sendEmailNotification(System.Label.Site_Visit_Notification_Email, lstAccount);
                }
                else if(strOptyId!=null)
                {
                    
                }
                update visitor;
            }
            catch(exception ex){
                string strTempError = '';
                System.debug('Exception occured::'+ex);
                if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                    strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
                }
                
                if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                    strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
                }
                strError = strTempError != '' ? strTempError : ex.getMessage();
                
            }
        }
        catch(Exception e){
            system.debug('VVK submitWalkingForm getMessage: '+e.getMessage());
            system.debug('VVK submitWalkingForm getMessage: '+e.getStackTraceString());
        }
    }
    
    public static void sendEmailNotification(string toAddress, List<Account> dupAccountList){
        System.debug('dupAccountList' +dupAccountList);
        
        String svURL;
        for(Account acc: dupAccountList){
            
            if(svURL!= null){
                svURL = svURL + URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.ID + '<br/>';
            }else{
                svURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.ID + '<br/>';
            }
        }
        
        list<EmailTemplate> emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Site_Re_Visit_Notification' Limit 1];
        
        if(emailTemplate.size()>0){ 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list<string> toAddresses = new list<string>();
            
            
            toAddresses.add(toAddress);
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailTemplate[0].Subject);
            string emailBody = emailTemplate[0].HtmlValue;
            emailBody=emailBody.replace('#LINK_TO_SITE_VISIT#',svURL);
            mail.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    public static void convertCIFLeads(List < Lead > ll) {
        for (lead myLead: ll) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(myLead.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
    }
    
    public static void updateVisitorsFile(Id siteVisitId, String visitorId){
        List<ContentDocumentLink> toBeClonedContentDocumentLinks = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink where LinkedEntityId=:visitorId];
        for(ContentDocumentLink cdl : toBeClonedContentDocumentLinks){
            cdl.Id=null;
            cdl.LinkedEntityId = siteVisitId;
        }
        if(toBeClonedContentDocumentLinks.size()>0)
            insert toBeClonedContentDocumentLinks;
        List<ContentDocumentLink> deleteDocumentLinks = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink where LinkedEntityId=:visitorId];
        if(deleteDocumentLinks.size()>0)
            delete deleteDocumentLinks;
    }
    
    public static void createVisitorsFile(String fileContent, Id parentId, String fileName){
        try{
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = fileName+'.png';//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.Title = fileName;//Name of the file
            //cVersion.VersionData = Blob.valueof(fileContent);//File content
            cVersion.VersionData = EncodingUtil.base64Decode(fileContent);//File content
            Insert cVersion;
            system.debug('FileCOnteV: '+cVersion);
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            system.debug('FileDoc: '+cDocLink);
        } catch(Exception e){
            system.debug('File Upload Error: '+e.getMessage());
        }
    }
}