public class ApplicantTriggerHandler 
{
    public Static Void onBeforeInsertUpdate(List<Applicant_Details__c> lstApplicantDetails,Map<Id, Applicant_Details__c> oldApplicantMap)
    {
        if(Trigger.isInsert) {
            updateAccountIdOnPrimaryApplicant(lstApplicantDetails);
            updateUniqueIdOnApplicantFromAccount(lstApplicantDetails);
        } 
    }
    
    // update unique id on applicant
    public static void updateUniqueIdOnApplicantFromAccount(List<Applicant_Details__c> lstApplicantDetails){
        Set<Id> setApplicantOpportunityIds = new Set<Id>();
        for(Applicant_Details__c objApplicant : lstApplicantDetails) { 
            setApplicantOpportunityIds.add(objApplicant.Opportunity__c);
        }
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id,Opportunity>([SELECT Id,
                                                                       Name,
                                                                       Account.Unique_Customer_ID__c
                                                                       FROM Opportunity
                                                                       WHERE Id IN :setApplicantOpportunityIds]);
        
        for(Applicant_Details__c objApplicant : lstApplicantDetails) {
            if(mapOpportunity.containskey(objApplicant.Opportunity__c)) {
                objApplicant.Unique_Customer_ID__c = mapOpportunity?.get(objApplicant.Opportunity__c)?.Account.Unique_Customer_ID__c;
            }
        }
    }
    
    public static void updateAccountIdOnPrimaryApplicant(List<Applicant_Details__c> lstApplicantDetails){
        List<Applicant_Details__c> lstPrimaryApplicant = new List<Applicant_Details__c>();
        Set<Id> setPrimaryApplicantOpportunityIds = new Set<Id>();
        
        for(Applicant_Details__c objApplicant : lstApplicantDetails) {
            if(objApplicant.Applicant_Number__c == 'Primary Applicant') {
                lstPrimaryApplicant.add(objApplicant);
                setPrimaryApplicantOpportunityIds.add(objApplicant.Opportunity__c);
            }
        }
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id,Opportunity>([SELECT Id,
                                                                       Name,
                                                                       AccountId
                                                                       FROM Opportunity
                                                                       WHERE Id IN :setPrimaryApplicantOpportunityIds]);
        
        System.debug('AccountId debug mapApplicantDetials'+mapOpportunity);
        System.debug('AccountId debug lstApplicantDetails before'+ lstApplicantDetails[0].Account__c);
        for(Applicant_Details__c objApplicant : lstApplicantDetails) {
            if(mapOpportunity.containskey(objApplicant.Opportunity__c)) {
                objApplicant.Account__c = mapOpportunity?.get(objApplicant.Opportunity__c)?.AccountId;
            }
        }
        
        System.debug('AccountId debug lstApplicantDetails after'+ lstApplicantDetails[0].Account__c);
    }
    
    /* Secondary_Mobile_Number__c
Mobile_Number__c
POA_Contact_Number__c
Secondary_Contact_Number__c
Organization_Phone_numbers__c
Landline_Number__c
Passport_Copy_Details__c
Email_Address__c
National_ID_Details__c */
    public static Boolean applicationTriggerProcess = false;
    Public Static Void onAfterInsertUniqueCustomer(Map<Id, Applicant_Details__c> newApplicantMap )
    {
        System.debug('After Insert - Applicant Trigger');
        //New records
        //Map<EmailId, BookingId>
        //Set<String> emailset = new Set<String>();
        //Set<String> Phoneset = new Set<String>();
        //Set<String> passportset = new Set<String>();
        //Set<String> nationalIdset = new Set<String>();
        Map<String, Id> emailMap = New Map<String, Id>();
        Map<String, Id> PhoneMap = New Map<String, Id>();
        Map<String, Id> passportMap = New Map<String, Id>();
        Map<String, Id> nationalIdMap = New Map<String, Id>();
        Map<Id, Id> bookingIdMap = new Map<Id, Id>();
        //Map<Id, Booking__c> newBookings = new Map<Id, Booking__c>();
        Map<Id, Booking__c> existingBookings = new Map<Id, Booking__c>();
        Map<Id, Id> accountMap = new Map<Id, Id>();
        Set<Id> bookSetIds = New Set<Id>();
        
        for(Applicant_Details__c app :newApplicantMap.Values())
        {
            If(app.Booking__c <> null)
            {
                bookSetIds.add(app.Booking__c); 
            }
            
            if(app.Applicant_Number__c=='Primary Applicant')
            {
                if(app.Mobile_Number__c<>null && !PhoneMap.ContainsKey(app.Mobile_Number__c))
                {
                    PhoneMap.Put(app.Mobile_Number__c, app.Booking__c);
                }
                
                if(app.Secondary_Mobile_Number__c<>null && !PhoneMap.ContainsKey(app.Secondary_Mobile_Number__c))
                {
                    PhoneMap.Put(app.Secondary_Mobile_Number__c, app.Booking__c);
                }
                
                if(app.Email_Address__c<>null && !emailMap.ContainsKey(app.Email_Address__c))
                {
                    emailMap.Put(app.Email_Address__c, app.Booking__c); 
                }
                
                if(app.Passport_Copy_Details__c<>null && !passportMap.ContainsKey(app.Passport_Copy_Details__c))
                {
                    passportMap.Put(app.Passport_Copy_Details__c, app.Booking__c);   
                }
                if(app.National_ID_Details__c<>null && !nationalIdMap.ContainsKey(app.National_ID_Details__c))
                {
                    nationalIdMap.Put(app.National_ID_Details__c, app.Booking__c);  
                }
            }
        }
        
        System.debug('before checking duplicates bookSetIds '+bookSetIds);
        //List<Applicant_Details__c> existingapplicantList = ; 
        
        //System.debug('Applicant Details: '+existingapplicantList); 
        //Old records
        for(Applicant_Details__c app : [Select Id,Booking__c,Mobile_Number__c,Secondary_Mobile_Number__c, Passport_Copy_Details__c,Email_Address__c,
                                        National_ID_Details__c from Applicant_Details__c where (Mobile_Number__c in :PhoneMap.keySet() OR Secondary_Mobile_Number__c in :PhoneMap.keySet() 
                                                                                                OR Passport_Copy_Details__c in :passportMap.keySet() OR Email_Address__c in :emailMap.keySet() OR National_ID_Details__c in :nationalIdMap.keySet()) 
                                        AND Booking__c <> null AND Applicant_Number__c='Primary Applicant' AND Id not in :newApplicantMap.keySet()])
        {
            System.debug('Applicant Details: '+app); 
            //If 
            //// Match record - then pick Book Id  (map of existing applicant id(New inserted Id) and booking Id)
            // map of current bookingId and Book id (Existing)
            //Map<Id, Id> bookingId(New)BookingId(matched)
            //if condtion phone, email , nationalid , passport
            
            If(emailMap.containskey(app.Email_Address__c))
            {
                bookingIdMap.put(emailMap.get(app.Email_Address__c),app.Booking__c); 
            }
            If(PhoneMap.containskey(app.Mobile_Number__c))
            {
                bookingIdMap.put(PhoneMap.get(app.Mobile_Number__c),app.Booking__c); 
            }
            If(PhoneMap.containskey(app.Secondary_Mobile_Number__c))
            {
                bookingIdMap.put(PhoneMap.get(app.Secondary_Mobile_Number__c),app.Booking__c); 
            }
            If(passportMap.containskey(app.Passport_Copy_Details__c))
            {
                bookingIdMap.put(passportMap.get(app.Passport_Copy_Details__c),app.Booking__c); 
            }
            If(nationalIdMap.containskey(app.National_ID_Details__c))
            {
                bookingIdMap.put(nationalIdMap.get(app.National_ID_Details__c),app.Booking__c); 
            }
        } 
        
        If(!bookingIdMap.isEmpty())
        {
            System.debug('bookingIdMap: '+bookingIdMap);
            System.debug('before remove Ids-bookSetIds: '+bookSetIds);
            bookSetIds.removeAll(bookingIdMap.keySet());
            System.debug('after Remove-bookSetIds: '+bookSetIds);
            //existingBookings
            for(Booking__c book1 : [Select Id, Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Account.Unique_Customer_ID__c,Opportunity__r.Account.Unique_Customer_External_ID__c, 
                                    Opportunity__r.Account.Duplicate_Customer__c from Booking__c where Id in :bookingIdMap.values()])
            {
                existingBookings.put(book1.Id, book1);
            }
            //newBookings
            for(Booking__c book2 : [Select Id, Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Account.Unique_Customer_ID__c,Opportunity__r.Account.Unique_Customer_External_ID__c,  
                                    Opportunity__r.Account.Duplicate_Customer__c from Booking__c where Id in :bookingIdMap.keySet()])
            {
                accountMap.put(book2.Opportunity__r.AccountId, existingBookings.get(bookingIdMap.get(book2.Id)).Opportunity__r.AccountId);
            }
        }
        If(!accountMap.isEmpty())
        {
            System.debug('accountMap'+accountMap);
            list<Account> updateAccounts = New List<Account>();
            Map<Id, Account> extAccMap= new Map<Id, Account>([Select Id, Unique_Customer_ID__c, Unique_Customer_External_ID__c, Duplicate_Customer__c from Account where Id in :accountMap.Values()]);
            System.debug('Existing Map Details'+extAccMap);
            for(Account newAcc : [Select Id, Unique_Customer_ID__c, Unique_Customer_External_ID__c, Duplicate_Customer__c from Account where Id in :accountMap.keySet()])
            {
                Account existingAcc=extAccMap.get(accountMap.get(newAcc.Id));
                //newAcc.Unique_Customer_External_ID__c =extAccMap.get(accountMap.get(newAcc.Id)).Unique_Customer_ID__c;
                newAcc.Unique_Customer_External_ID__c=existingAcc.Unique_Customer_External_ID__c;
                newAcc.Duplicate_Customer__c=true;
                updateAccounts.add(newAcc);
                If(newAcc.Id <> existingAcc.Id)
                {
                    System.debug('Existing account:--- '+existingAcc);
                    existingAcc.Duplicate_Customer__c=true;
                    updateAccounts.add(existingAcc);
                }
                system.debug('list of account updating --'+ updateAccounts);
                //  If(!updateAccounts.contains(existingAcc))
                //  {
                //    System.debug('Existing account:--- '+existingAcc);
                //    existingAcc.Duplicate_Customer__c=true;
                //    updateAccounts.add(existingAcc);
                // }
            }
            If(!updateAccounts.isEmpty())
            {
                applicationTriggerProcess = true;
                update updateAccounts;
                applicationTriggerProcess = false;
            }
        }
        if(!bookSetIds.isEmpty())
        {
            System.debug('bookSetIds '+bookSetIds);
            list<Id> newAccIds = New List<Id>();
            for(Booking__c book : [Select Id, Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Account.Unique_Customer_ID__c,Opportunity__r.Account.Unique_Customer_External_ID__c, 
                                   Opportunity__r.Account.Duplicate_Customer__c from Booking__c where Id in :bookSetIds])
            {
                if(book.Opportunity__r.AccountId <> null)
                    newAccIds.add(book.Opportunity__r.AccountId);
            }
            If(!newAccIds.isEmpty())
            {
                List<Account> updateAccLst= new List<Account>();
                for(Account upAcc : [Select Id, Unique_Customer_ID__c, Duplicate_Customer__c,Unique_Customer_External_ID__c from Account where Id in :newAccIds])
                {
                    //upAcc.Unique_Customer_ID__c=String.valueOf(upAcc.Unique_Customer_External_ID__c);
                    upAcc.Unique_Customer_External_ID__c =upAcc.Unique_Customer_ID__c;
                    updateAccLst.add(upAcc);
                }
                if(!updateAccLst.isEmpty())
                {
                    applicationTriggerProcess = true;
                    update updateAccLst;
                    applicationTriggerProcess = false;
                }
            }
        } 
    }
    
    public Static Void onAfterInsertLeadConversion(Map<Id, Applicant_Details__c> newApplicantMap)
    {
        list<Applicant_Details__c> newApplicants = new list<Applicant_Details__c>();
        try{
            list<Lead> leadListToInsert = new list<Lead>();
            list<Lead> leadListToUpdateAndConvert = new list<Lead>();
            newApplicants.addAll(newApplicantMap.values());
            
            set<string> emailList = new set<string>();
            set<string> mobileList = new set<string>();
            map<string,string> contactToApplicant = new map<string,string>();
            set<string> bookingIds = new set<string>();
            for(Applicant_Details__c app : newApplicantMap.values()){
                emailList.add(string.valueOf(app.Email_Address__c));
                mobileList.add(string.valueOf(app.Mobile_Number__c));
                contactToApplicant.put(string.valueOf(app.Email_Address__c),app.Id);
                contactToApplicant.put(string.valueOf(app.Mobile_Number__c),app.Id);
                bookingIds.add(app.Booking__c);
            }
            
            map<string,Applicant_Details__c> bookingIdToPrimaryApplicant = new map<string,Applicant_Details__c>();
            for(Applicant_Details__c ad : [select Id,Booking__c,Opportunity__c,Opportunity__r.StageName,
                                           Opportunity__r.Sales_Manager_lookup__c,Opportunity__r.Secondary_Sales_Manager__c,
                                           Opportunity__r.Sales_Head_Lookup__c,Opportunity__r.Secondary_Sales_Head__c,
                                           Opportunity__r.Walk_in_Source__c,Opportunity__r.Walk_in_Sub_Source__c,
                                           Opportunity__r.Walk_In_CP__c,Opportunity__r.Walk_In_SC__c
                                           from Applicant_Details__c 
                                           where Booking__c IN:bookingIds and Applicant_Number__c = 'Primary Applicant']){
                                               if(ad.Opportunity__c != null){
                                                   bookingIdToPrimaryApplicant.put(ad.Booking__c,ad);
                                               }
                                           }
            
            list<lead> existingLeadList = [select Id, IsConverted, Email, MobilePhone, ConvertedOpportunityId, ConvertedAccountId from Lead where Email IN: emailList OR MobilePhone IN: mobileList order by createddate asc];
            map<string,lead> applicantToLead = new map<string,lead>();
            for(Lead l : existingLeadList){
                if(contactToApplicant.containsKey(l.Email)){
                    applicantToLead.put(contactToApplicant.get(l.Email),l);
                } 
                else if(contactToApplicant.containsKey(l.MobilePhone)){
                    applicantToLead.put(contactToApplicant.get(l.MobilePhone),l);
                } 
            }
            
            list<Applicant_Details__c> appListToUpdate = new list<Applicant_Details__c>();
            list<Opportunity> oppListToCreate = new list<Opportunity>();
            
            for(Applicant_Details__c app : newApplicantMap.values()){
                if(app.Applicant_Number__c != 'Primary Applicant'){
                    Applicant_Details__c primaryApplicant = (bookingIdToPrimaryApplicant.containsKey(app.Booking__c))?bookingIdToPrimaryApplicant.get(app.Booking__c):null;
                    if(applicantToLead.containsKey(app.Id)){
                        lead l = applicantToLead.get(app.Id);
                        if(!l.IsConverted){
                            l.Applicant_Id__c = app.Id;
                            l.Booking__c = app.Booking__c;
                            leadListToUpdateAndConvert.add(l);
                        }
                        else{
                            Opportunity op = new Opportunity();
                            op.AccountId = l.ConvertedAccountId;
                            op.Name = app.Name;
                            op.Email__c = app.Email_Address__c;
                            op.Mobile_No_O__c = app.Mobile_Number__c;
                            op.StageName = 'Qualification';
                            op.CloseDate = system.today().addDays(30);
                            op.Secondary_Opportunity__c = true;
                            if(primaryApplicant!=null){
                                op.Walk_in_Source__c = primaryApplicant.Opportunity__r.Walk_in_Source__c;
                                op.Walk_in_Sub_Source__c = primaryApplicant.Opportunity__r.Walk_in_Sub_Source__c;
                                op.Walk_In_CP__c = primaryApplicant.Opportunity__r.Walk_In_CP__c;
                                op.Walk_In_SC__c = primaryApplicant.Opportunity__r.Walk_In_SC__c;
                                op.StageName = primaryApplicant.Opportunity__r.StageName;
                                op.Sales_Manager_lookup__c = primaryApplicant.Opportunity__r.Sales_Manager_lookup__c;
                                op.Secondary_Sales_Manager__c = primaryApplicant.Opportunity__r.Secondary_Sales_Manager__c;
                                op.Sales_Head_Lookup__c = primaryApplicant.Opportunity__r.Sales_Head_Lookup__c;
                                op.Secondary_Sales_Head__c = primaryApplicant.Opportunity__r.Secondary_Sales_Head__c;
                            }
                            oppListToCreate.add(op);
                        }
                    }
                    else{
                        Lead l = new Lead();
                        l.FirstName = app.Salutation__c; 
                        l.LastName = app.Name;
                        l.Email = app.Email_Address__c ;
                        l.MobilePhone = app.Mobile_Number__c;
                        l.Applicant_Id__c = app.Id;
                        l.Booking__c = app.Booking__c;
                        leadListToInsert.add(l);
                    }
                }
            }
            if(leadListToInsert.size() > 0){
                insert leadListToInsert;
                convertLeadAndUpdateApplicant(leadListToInsert,bookingIdToPrimaryApplicant);
            }
            if(leadListToUpdateAndConvert.size() > 0){
                update leadListToUpdateAndConvert;
                convertLeadAndUpdateApplicant(leadListToUpdateAndConvert,bookingIdToPrimaryApplicant);
            }
            if(oppListToCreate.size()>0){
                insert oppListToCreate;
                for(Opportunity o : [select Id,AccountId,Email__c,Mobile_No_O__c from Opportunity where Id IN: oppListToCreate]){
                    Applicant_Details__c ap;
                    if(contactToApplicant.containsKey(o.Email__c)){
                        ap = new Applicant_Details__c(Id=contactToApplicant.get(o.Email__c),Account__c=o.AccountId,Opportunity__c=o.Id);
                        appListToUpdate.add(ap);
                    } 
                    else if(contactToApplicant.containsKey(o.Mobile_No_O__c)){
                        ap = new Applicant_Details__c(Id=contactToApplicant.get(o.Mobile_No_O__c),Account__c=o.AccountId,Opportunity__c=o.Id);
                        appListToUpdate.add(ap);
                    } 
                }
                if(appListToUpdate.size()>0){
                    update appListToUpdate;
                }
            }
        }
        catch(Exception e){
            system.debug('onAfterInsertLeadConversion Error Msg: '+e.getMessage());
            system.debug('onAfterInsertLeadConversion StackTrace: '+e.getStackTraceString());
            //insertErrorLog(e.getMessage(),e.getStackTraceString(),newApplicants[0].Id,'ApplicantTriggerHandler','onAfterInsertLeadConversion');
            insertErrorLog(e.getMessage(),e.getStackTraceString(),'ApplicantDetails','ApplicantTriggerHandler','onAfterInsertLeadConversion');
        } 
    } 
    
    public static void convertLeadAndUpdateApplicant(list<Lead> leadList, map<string,Applicant_Details__c> bookingIdToPrimaryApplicant){
        try {
            if(leadList.size() > 0){
                list<Database.LeadConvert> leadsToConvert = new list<Database.LeadConvert>();
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                for(lead l: leadList){
                    Database.LeadConvert tempLC = new Database.LeadConvert();
                    tempLC.setLeadId(l.id);
                    tempLC.setConvertedStatus(convertStatus.MasterLabel);
                    leadsToConvert.add(tempLC);
                }
                Database.convertLead(leadsToConvert);
                leadList = [select Id, Booking__c, IsConverted, Applicant_Id__c, ConvertedOpportunityId, ConvertedAccountId,LeadSource,Lead_Sub_Source__c,Channel_Partner__c,Sobha_Connect__c from Lead where Id IN: leadList];
                list<Applicant_Details__c> appListToUpdate = new list<Applicant_Details__c>();
                list<Opportunity> opptyToUpdate = new list<Opportunity>();
                for(Lead l : leadList){
                    if(l.IsConverted){
                        Applicant_Details__c primaryApplicant = (bookingIdToPrimaryApplicant.containsKey(l.Booking__c))?bookingIdToPrimaryApplicant.get(l.Booking__c):null;
                        appListToUpdate.add(new Applicant_Details__c(Id=l.Applicant_Id__c,Account__c=l.ConvertedAccountId,Opportunity__c=l.ConvertedOpportunityId));
                        Opportunity op = new Opportunity(Id=l.ConvertedOpportunityId);
                        op.Secondary_Opportunity__c = true;
                        if(primaryApplicant!=null || Test.isRunningTest()){
                            op.Walk_in_Source__c = primaryApplicant?.Opportunity__r?.Walk_in_Source__c;
                            op.Walk_in_Sub_Source__c = primaryApplicant?.Opportunity__r?.Walk_in_Sub_Source__c;
                            op.Walk_In_CP__c = primaryApplicant?.Opportunity__r?.Walk_In_CP__c;
                            op.Walk_In_SC__c = primaryApplicant?.Opportunity__r?.Walk_In_SC__c;
                            op.StageName = primaryApplicant?.Opportunity__r?.StageName;
                            op.Sales_Manager_lookup__c = primaryApplicant?.Opportunity__r?.Sales_Manager_lookup__c;
                            op.Secondary_Sales_Manager__c = primaryApplicant?.Opportunity__r?.Secondary_Sales_Manager__c;
                            op.Sales_Head_Lookup__c = primaryApplicant?.Opportunity__r?.Sales_Head_Lookup__c;
                            op.Secondary_Sales_Head__c = primaryApplicant?.Opportunity__r?.Secondary_Sales_Head__c;
                        }
                        opptyToUpdate.add(op);
                    }
                }
                if(appListToUpdate.size()>0){
                    update appListToUpdate;
                }
                if(opptyToUpdate.size()>0){
                    update opptyToUpdate;
                }
            }
        }
        catch(Exception e){
            system.debug('convertLeadAndUpdateApplicant Error Msg: '+e.getMessage());
            system.debug('convertLeadAndUpdateApplicant StackTrace: '+e.getStackTraceString());
            //insertErrorLog(e.getMessage(),e.getStackTraceString(),leadList[0].Id,'ApplicantTriggerHandler','convertLeadAndUpdateApplicant');
            insertErrorLog(e.getMessage(),e.getStackTraceString(),'Lead','ApplicantTriggerHandler','convertLeadAndUpdateApplicant');
        }
    }
    
    /******************************************************************************************************************
    Method : processAppDetailsFieldsBeforeSave
    Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
    Author : Artee Varma
    Date : 22-01-2025
    ******************************************************************************************************************/
    
    public static void processAppDetailsFieldsBeforeSave(List<Applicant_Details__c> newRecords) {        
        for (Applicant_Details__c ad : newRecords) {
            if (!String.isBlank(ad.Mobile_Country_With_Code__c) && !String.isBlank(ad.Mobile_Number__c)) {
                String phoneNumber = ad.Mobile_Number__c;
                if (phoneNumber.startsWith('0')) {
                    phoneNumber = phoneNumber.substringAfter('0');
                } 
                else if (phoneNumber.startsWith('+') && !String.isBlank(ad.Mobile_Country_With_Code__c)) {
                    phoneNumber = phoneNumber.substring(ad.Mobile_Country_With_Code__c.length()); 
                } 
                else {
                    phoneNumber = phoneNumber;
                }
                ad.Primary_Mobile_Number__c = ad.Mobile_Country_With_Code__c + phoneNumber;
                ad.Primary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Primary_Mobile_Number__c);
                ad.Primary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(ad.Primary_Mobile_Number__c);
            }
            if (!String.isBlank(ad.Alternate_Mobile_Country_with_Code__c) && !String.isBlank(ad.Secondary_Mobile_Number__c)) {
                String secondaryMobile = ad.Secondary_Mobile_Number__c;
                if (secondaryMobile.startsWith('0')) {
                    secondaryMobile = secondaryMobile.substringAfter('0');
                } 
                else if (secondaryMobile.startsWith('+') && !String.isBlank(ad.Alternate_Mobile_Country_with_Code__c)) {
                    secondaryMobile = secondaryMobile.substring(ad.Alternate_Mobile_Country_with_Code__c.length()); 
                } 
                else {
                    secondaryMobile = secondaryMobile;
                } 
                ad.Alternate_Mobile_Number__c = ad.Alternate_Mobile_Country_with_Code__c + secondaryMobile;
                ad.Alternate_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Alternate_Mobile_Number__c);
                ad.Alternate_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(ad.Alternate_Mobile_Number__c);
            } 
            if (!String.isBlank(ad.Landline_Number_Country_Code__c) && !String.isBlank(ad.Landline_Number__c)) {
                String landlineNumber = ad.Landline_Number__c;
                if (landlineNumber.startsWith('0')) {
                    landlineNumber = landlineNumber.substringAfter('0');
                } 
                else if (landlineNumber.startsWith('+') && !String.isBlank(ad.Landline_Number_Country_Code__c)) {
                    landlineNumber = landlineNumber.substring(ad.Landline_Number_Country_Code__c.length()); 
                } 
                else {
                    landlineNumber = landlineNumber;
                } 
                ad.Landline_Number_wcc__c = ad.Landline_Number_Country_Code__c + landlineNumber;
                ad.Landline_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Landline_Number_wcc__c);
                ad.Landline_Number_E__c = EncryptionUtilService.encryptMobile(ad.Landline_Number_wcc__c);
            }
            if (!String.isBlank(ad.Secondary_Contact_Country_Code__c) && !String.isBlank(ad.Secondary_Contact_Number__c)) {
                String secondaryContactNumber = ad.Secondary_Contact_Number__c;
                if (secondaryContactNumber.startsWith('0')) {
                    secondaryContactNumber = secondaryContactNumber.substringAfter('0');
                } 
                else if (secondaryContactNumber.startsWith('+') && !String.isBlank(ad.Secondary_Contact_Country_Code__c)) {
                    secondaryContactNumber = secondaryContactNumber.substring(ad.Secondary_Contact_Country_Code__c.length()); 
                } 
                else {
                    secondaryContactNumber = secondaryContactNumber;
                } 
                ad.Secondary_Contact_Number_wcc__c = ad.Secondary_Contact_Country_Code__c + secondaryContactNumber;
                ad.Secondary_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Secondary_Contact_Number_wcc__c);
                ad.Secondary_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Secondary_Contact_Number_wcc__c);
            } 
            if (!String.isBlank(ad.POA_Contact_Country_Code__c) && !String.isBlank(ad.POA_Contact_Number__c)) {
                String poaContact = ad.POA_Contact_Number__c;
                if (poaContact.startsWith('0')) {
                    poaContact = poaContact.substringAfter('0');
                } 
                else if (poaContact.startsWith('+') && !String.isBlank(ad.POA_Contact_Country_Code__c)) {
                    poaContact = poaContact.substring(ad.POA_Contact_Country_Code__c.length()); 
                } 
                else {
                    poaContact = poaContact;
                } 
                ad.Authorized_Signatory2_Phone__c = ad.POA_Contact_Country_Code__c + ad.POA_Contact_Number__c;
                ad.POA_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Authorized_Signatory2_Phone__c);
                ad.POA_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Authorized_Signatory2_Phone__c);
            }
            if (!String.isBlank(ad.POA2_Contact_Country_Code__c) && !String.isBlank(ad.POA_2_Contact_Number__c)) {
                String poa2Contact = ad.POA_2_Contact_Number__c;
                if (poa2Contact.startsWith('0')) {
                    poa2Contact = poa2Contact.substringAfter('0');
                } 
                else if (poa2Contact.startsWith('+') && !String.isBlank(ad.POA2_Contact_Country_Code__c)) {
                    poa2Contact = poa2Contact.substring(ad.POA2_Contact_Country_Code__c.length()); 
                } 
                else {
                    poa2Contact = poa2Contact;
                } 
                ad.Authorized_Signatory3_Phone__c = ad.POA2_Contact_Country_Code__c + poa2Contact;
                ad.POA_2_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Authorized_Signatory3_Phone__c);
                ad.POA_2_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Authorized_Signatory3_Phone__c);
            }
            if (!String.isBlank(ad.Office_Country_Code__c) && !String.isBlank(ad.Organization_Phone_numbers__c)) {
                String officeNumber = ad.Organization_Phone_numbers__c;
                if (officeNumber.startsWith('0')) {
                    officeNumber = officeNumber.substringAfter('0');
                } 
                else if (officeNumber.startsWith('+') && !String.isBlank(ad.Office_Country_Code__c)) {
                    officeNumber = officeNumber.substring(ad.Office_Country_Code__c.length()); 
                } 
                else {
                    officeNumber = officeNumber;
                } 
                ad.Office_Phoner_Number_wcc__c = ad.Office_Country_Code__c + officeNumber;
                ad.Office_Phone_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Office_Phoner_Number_wcc__c);
                ad.Office_Phone_Number_E__c = EncryptionUtilService.encryptMobile(ad.Office_Phoner_Number_wcc__c);
            }  
            if (!String.isBlank(ad.Email_Address__c)) {
                ad.Primary_Email_M__c = FieldMaskingUtil.maskEmail(ad.Email_Address__c);
                ad.Primary_Email_E__c = EncryptionUtilService.encryptEmail(ad.Email_Address__c);
            }
            if (!String.isBlank(ad.POA_Email_Id__c)) {
                ad.POA_Email_Id_M__c = FieldMaskingUtil.maskEmail(ad.POA_Email_Id__c);
                ad.POA_Email_Id_E__c = EncryptionUtilService.encryptEmail(ad.POA_Email_Id__c);
            }
            if (!String.isBlank(ad.POA_2_Email_Id__c)) {
                ad.POA_2_Email_Id_M__c = FieldMaskingUtil.maskEmail(ad.POA_2_Email_Id__c);
                ad.POA_2_Email_Id_E__c = EncryptionUtilService.encryptEmail(ad.POA_2_Email_Id__c);
            } 
        }
    }
    
    /******************************************************************************************************************
    Method : processAppDetailsFieldsBeforeUpdate
    Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
    Author : Artee Varma
    Date : 17-01-2025
    ******************************************************************************************************************/
    
    public static void processAppDetailsFieldsBeforeUpdate(Map<Id, Applicant_Details__c> newMap, Map<Id, Applicant_Details__c> oldMap) {
        List<Applicant_Details__c> appDetailsToEncrypt = new List<Applicant_Details__c>();
        
        for (Applicant_Details__c ad : newMap.values()) {
            Boolean isPrimaryMobileChanged = oldMap == null || ad.Mobile_Number__c != oldMap.get(ad.Id)?.Mobile_Number__c;
            Boolean isPrimaryMobileCountryChanged = oldMap == null || ad.Mobile_Country_With_Code__c != oldMap.get(ad.Id)?.Mobile_Country_With_Code__c;
            
            Boolean isAlternateNumberChanged = oldMap == null || ad.Secondary_Mobile_Number__c != oldMap.get(ad.Id)?.Secondary_Mobile_Number__c;
            Boolean isAlternateCountryChanged = oldMap == null || ad.Alternate_Mobile_Country_with_Code__c != oldMap.get(ad.Id)?.Alternate_Mobile_Country_with_Code__c;
            
            Boolean isLandlineNumberChanged = oldMap == null || ad.Landline_Number__c != oldMap.get(ad.Id)?.Landline_Number__c;
            Boolean isLandlineNumberCountryChanged = oldMap == null || ad.Landline_Number_Country_Code__c != oldMap.get(ad.Id)?.Landline_Number_Country_Code__c;
            
            Boolean isSecondaryContactChanged = oldMap == null || ad.Secondary_Contact_Number__c != oldMap.get(ad.Id)?.Secondary_Contact_Number__c;
            Boolean isSecondaryContactCountryChanged = oldMap == null || ad.Secondary_Contact_Country_Code__c != oldMap.get(ad.Id)?.Secondary_Contact_Country_Code__c;
            
            Boolean isPOAContactChanged = oldMap == null || ad.POA_Contact_Number__c != oldMap.get(ad.Id)?.POA_Contact_Number__c;
            Boolean isPOAContactCountryChanged = oldMap == null || ad.POA_Contact_Country_Code__c != oldMap.get(ad.Id)?.POA_Contact_Country_Code__c;
            
            Boolean isPOA2ContactChanged = oldMap == null || ad.POA_2_Contact_Number__c != oldMap.get(ad.Id)?.POA_2_Contact_Number__c;
            Boolean isPOA2ContactCountryChanged = oldMap == null || ad.POA2_Contact_Country_Code__c != oldMap.get(ad.Id)?.POA2_Contact_Country_Code__c;
            
            Boolean isOfficePhoneChanged = oldMap == null || ad.Organization_Phone_numbers__c != oldMap.get(ad.Id)?.Organization_Phone_numbers__c;
            Boolean isOfficePhoneCountryChanged = oldMap == null || ad.Office_Country_Code__c != oldMap.get(ad.Id)?.Office_Country_Code__c;
            
            Boolean isEmailAddressChanged = oldMap == null || ad.Email_Address__c != oldMap.get(ad.Id)?.Email_Address__c;
            Boolean isPOAEmailChanged = oldMap == null || ad.POA_Email_Id__c != oldMap.get(ad.Id)?.POA_Email_Id__c;
            Boolean isPOA2EmailChanged = oldMap == null || ad.POA_2_Email_Id__c != oldMap.get(ad.Id)?.POA_2_Email_Id__c;
            
            // for primary mobile number
            // Either primary mobile number is blank or changes in mobile/country code and not matching existing Primary_Mobile_Number__c
            Boolean shouldUpdatePrimaryMobile = String.isBlank(ad.Primary_Mobile_Number__c) ||
                (isPrimaryMobileChanged || isPrimaryMobileCountryChanged) &&
                ad.Primary_Mobile_Number__c != (ad.Mobile_Country_With_Code__c + ad.Mobile_Number__c);
            
            System.debug('shouldUpdatePrimaryMobile==> ' + shouldUpdatePrimaryMobile);
            
            if (shouldUpdatePrimaryMobile && !String.isBlank(ad.Mobile_Number__c)) {
                String primaryNumber = ad.Mobile_Number__c;
                if (primaryNumber.startsWith('0')) {
                    primaryNumber = primaryNumber.substringAfter('0');
                } 
                else if (primaryNumber.startsWith('+') && !String.isBlank(ad.Mobile_Country_With_Code__c)) {
                    primaryNumber = primaryNumber.substring(ad.Mobile_Country_With_Code__c.length()); 
                } 
                else {
                    primaryNumber = primaryNumber;
                }             
                ad.Primary_Mobile_Number__c = ad.Mobile_Country_With_Code__c + primaryNumber;
                ad.Primary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Primary_Mobile_Number__c);
                ad.Primary_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(ad.Primary_Mobile_Number__c);
            }  
            
            // for alternate mobile number
            // Either alternate mobile number is blank or changes in mobile/country code and not matching existing Alternate_Mobile_Number__c
            Boolean shouldUpdateAlternateMobile = String.isBlank(ad.Alternate_Mobile_Number__c) ||
                (isAlternateNumberChanged || isAlternateCountryChanged) &&
                ad.Alternate_Mobile_Number__c != (ad.Alternate_Mobile_Country_with_Code__c + ad.Secondary_Mobile_Number__c);
            
            System.debug('shouldUpdateAlternateMobile==> ' + shouldUpdateAlternateMobile);
            
            if (shouldUpdateAlternateMobile && !String.isBlank(ad.Secondary_Mobile_Number__c)) {
                String secondaryMobile = ad.Secondary_Mobile_Number__c;
                if (secondaryMobile.startsWith('0')) {
                    secondaryMobile = secondaryMobile.substringAfter('0');
                } 
                else if (secondaryMobile.startsWith('+') && !String.isBlank(ad.Alternate_Mobile_Country_with_Code__c)) {
                    secondaryMobile = secondaryMobile.substring(ad.Alternate_Mobile_Country_with_Code__c.length()); 
                } 
                else {
                    secondaryMobile = secondaryMobile;
                } 
                ad.Alternate_Mobile_Number__c = ad.Alternate_Mobile_Country_with_Code__c + secondaryMobile;
                ad.Alternate_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Alternate_Mobile_Number__c);
                ad.Alternate_Mobile_Number_E__c = EncryptionUtilService.encryptMobile(ad.Alternate_Mobile_Number__c);
            }              
            // for landline number
            // Either landline mobile number is blank or changes in mobile/country code and not matching existing Landline_Number_wcc__c
            Boolean shouldUpdateLandlineNumber = String.isBlank(ad.Landline_Number_wcc__c) ||
                (isLandlineNumberChanged || isLandlineNumberCountryChanged) &&
                ad.Landline_Number_wcc__c != (ad.Landline_Number_Country_Code__c + ad.Landline_Number__c);
            
            System.debug('shouldUpdateLandlineNumber==> ' + shouldUpdateLandlineNumber);
            
            if (shouldUpdateLandlineNumber && !String.isBlank(ad.Landline_Number__c)) {
                String landlineNumber = ad.Landline_Number__c;
                if (landlineNumber.startsWith('0')) {
                    landlineNumber = landlineNumber.substringAfter('0');
                } 
                else if (landlineNumber.startsWith('+') && !String.isBlank(ad.Landline_Number_Country_Code__c)) {
                    landlineNumber = landlineNumber.substring(ad.Landline_Number_Country_Code__c.length()); 
                } 
                else {
                    landlineNumber = landlineNumber;
                } 
                ad.Landline_Number_wcc__c = ad.Landline_Number_Country_Code__c + landlineNumber;
                ad.Landline_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Landline_Number_wcc__c);
                ad.Landline_Number_E__c = EncryptionUtilService.encryptMobile(ad.Landline_Number_wcc__c);
            }
            
            // for secondary contact number
            // Either secondary contact number is blank or changes in mobile/country code and not matching existing Secondary_Contact_Number_wcc__c
            Boolean shouldUpdateSecondaryContact = String.isBlank(ad.Secondary_Contact_Number_wcc__c) ||
                (isSecondaryContactChanged || isSecondaryContactCountryChanged) &&
                ad.Secondary_Contact_Number_wcc__c != (ad.Secondary_Contact_Country_Code__c + ad.Secondary_Contact_Number__c);
            
            System.debug('shouldUpdateSecondaryContact==> ' + shouldUpdateSecondaryContact);
            
            if (shouldUpdateSecondaryContact && !String.isBlank(ad.Secondary_Contact_Number__c)) {
                String secondaryContact = ad.Secondary_Contact_Number__c;
                if (secondaryContact.startsWith('0')) {
                    secondaryContact = secondaryContact.substringAfter('0');
                } 
                else if (secondaryContact.startsWith('+') && !String.isBlank(ad.Secondary_Contact_Country_Code__c)) {
                    secondaryContact = secondaryContact.substring(ad.Secondary_Contact_Country_Code__c.length()); 
                } 
                else {
                    secondaryContact = secondaryContact;
                }
                ad.Secondary_Contact_Number_wcc__c = ad.Secondary_Contact_Country_Code__c + secondaryContact;
                ad.Secondary_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Secondary_Contact_Number_wcc__c);
                ad.Secondary_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Secondary_Contact_Number_wcc__c);
            }
            
            // for poa number
            // Either poa number is blank or changes in mobile/country code and not matching existing Authorized_Signatory2_Phone__c
            Boolean shouldUpdatePOANumber = String.isBlank(ad.Authorized_Signatory2_Phone__c) ||
                (isPOAContactChanged || isPOAContactCountryChanged) &&
                ad.Authorized_Signatory2_Phone__c != (ad.POA_Contact_Country_Code__c + ad.POA_Contact_Number__c);
            
            System.debug('shouldUpdatePOANumber==> ' + shouldUpdatePOANumber);
            
            if (shouldUpdatePOANumber && !String.isBlank(ad.POA_Contact_Number__c)) {
                String poaNumber = ad.POA_Contact_Number__c;
                if (poaNumber.startsWith('0')) {
                    poaNumber = poaNumber.substringAfter('0');
                } 
                else if (poaNumber.startsWith('+') && !String.isBlank(ad.POA_Contact_Country_Code__c)) {
                    poaNumber = poaNumber.substring(ad.POA_Contact_Country_Code__c.length()); 
                } 
                else {
                    poaNumber = poaNumber;
                }
                ad.Authorized_Signatory2_Phone__c = ad.POA_Contact_Country_Code__c + poaNumber;
                ad.POA_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Authorized_Signatory2_Phone__c);
                ad.POA_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Authorized_Signatory2_Phone__c);
            }
            
            // for poa2 number
            // Either poa2 number is blank or changes in mobile/country code and not matching existing Authorized_Signatory3_Phone__c
            Boolean shouldUpdatePOA2Number = String.isBlank(ad.Authorized_Signatory3_Phone__c) ||
                (isPOA2ContactChanged || isPOA2ContactCountryChanged) &&
                ad.Authorized_Signatory3_Phone__c != (ad.POA2_Contact_Country_Code__c + ad.POA_2_Contact_Number__c);
            
            System.debug('shouldUpdatePOA2Number==> ' + shouldUpdatePOA2Number);
            
            if (shouldUpdatePOA2Number && !String.isBlank(ad.POA_2_Contact_Number__c)) {
                String poa2Number = ad.POA_2_Contact_Number__c;
                if (poa2Number.startsWith('0')) {
                    poa2Number = poa2Number.substringAfter('0');
                } 
                else if (poa2Number.startsWith('+') && !String.isBlank(ad.POA2_Contact_Country_Code__c)) {
                    poa2Number = poa2Number.substring(ad.POA2_Contact_Country_Code__c.length()); 
                } 
                else {
                    poa2Number = poa2Number;
                }
                ad.Authorized_Signatory3_Phone__c = ad.POA2_Contact_Country_Code__c + poa2Number;
                ad.POA_2_Contact_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Authorized_Signatory3_Phone__c);
                ad.POA_2_Contact_Number_E__c = EncryptionUtilService.encryptMobile(ad.Authorized_Signatory3_Phone__c);
            }   
            
            // for office phone
            // Either office phone is blank or changes in mobile/country code and not matching existing Office_Phoner_Number_wcc__c
            Boolean shouldUpdateOfficePhone = String.isBlank(ad.Office_Phoner_Number_wcc__c) ||
                (isOfficePhoneChanged || isOfficePhoneCountryChanged) &&
                ad.Office_Phoner_Number_wcc__c != (ad.Office_Country_Code__c + ad.Organization_Phone_numbers__c);
            
            System.debug('shouldUpdateOfficePhone==> ' + shouldUpdateOfficePhone);
            
            if (shouldUpdateOfficePhone && !String.isBlank(ad.Organization_Phone_numbers__c)) {
                String officePhone = ad.Organization_Phone_numbers__c;
                if (officePhone.startsWith('0')) {
                    officePhone = officePhone.substringAfter('0');
                } 
                else if (officePhone.startsWith('+') && !String.isBlank(ad.Office_Country_Code__c)) {
                    officePhone = officePhone.substring(ad.Office_Country_Code__c.length()); 
                } 
                else {
                    officePhone = officePhone;
                }
                ad.Office_Phoner_Number_wcc__c = ad.Office_Country_Code__c + officePhone;
                ad.Office_Phone_Number_M__c = FieldMaskingUtil.maskPhoneNumber(ad.Office_Phoner_Number_wcc__c);
                ad.Office_Phone_Number_E__c = EncryptionUtilService.encryptMobile(ad.Office_Phoner_Number_wcc__c);
            } 

            if (!String.isBlank(ad.Email_Address__c) && isEmailAddressChanged ) {
                System.debug('Email Adress changed////');
                ad.Primary_Email_M__c = FieldMaskingUtil.maskEmail(ad.Email_Address__c);
                ad.Primary_Email_E__c = EncryptionUtilService.encryptEmail(ad.Email_Address__c);
            }
            if (!String.isBlank(ad.POA_Email_Id__c) && isPOAEmailChanged) {
                System.debug('POa Email changed////');
                ad.POA_Email_Id_M__c = FieldMaskingUtil.maskEmail(ad.POA_Email_Id__c);
                ad.POA_Email_Id_E__c = EncryptionUtilService.encryptEmail(ad.POA_Email_Id__c);
            }
            if (!String.isBlank(ad.POA_2_Email_Id__c) && isPOA2EmailChanged) {
                System.debug('POA2 Email changed////');
                ad.POA_2_Email_Id_M__c = FieldMaskingUtil.maskEmail(ad.POA_2_Email_Id__c);
                ad.POA_2_Email_Id_E__c = EncryptionUtilService.encryptEmail(ad.POA_2_Email_Id__c);
            }            
            appDetailsToEncrypt.add(ad);
        }
    }
    //added by Artee on 22-01-2025
    
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
}