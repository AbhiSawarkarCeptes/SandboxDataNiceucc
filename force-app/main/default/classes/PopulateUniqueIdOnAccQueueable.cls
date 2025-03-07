public class PopulateUniqueIdOnAccQueueable implements Queueable{
    
    public void execute(QueueableContext context) {
        Map<String, Set<Id>> emailMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> mobileMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> secMobileMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> passportMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> nationalIdMap = new Map<String, Set<Id>>();
        
        Map<Id, Applicant_Details__c> applicantMap = new Map<Id, Applicant_Details__c>(
            [
                SELECT
                Id,
                Name,
                CreatedDate,
                Booking__c,
                Opportunity__r.AccountId,
                Applicant_Number__c,
                Passport_Copy_Details__c,
                National_ID_Details__c,
                Mobile_Number__c,
                Secondary_Mobile_Number__c,
                Email_Address__c
                FROM Applicant_Details__c
                WHERE
                Applicant_Number__c = 'Primary Applicant'
                AND Booking__c != NULL
                AND Opportunity__r.AccountId != NULL
                //AND (National_ID_Details__c in ('121099655','EA4063511')
                //OR Passport_Copy_Details__c in ('Z4732533','PX6898222') )
                Order By Opportunity__r.Account.CreatedDate ASC
            ]
        );
        if (!applicantMap.isEmpty()) {
            for (Applicant_Details__c app : applicantMap.values()) {
                if (emailMap.containskey(app.Email_Address__c)) {
                    emailMap.get(app.Email_Address__c).add(app.Id);
                } else {
                    if(!String.isBlank(app.Email_Address__c))
                    	emailMap.put(app.Email_Address__c, new Set<Id>{ app.Id });
                }
                if (mobileMap.containskey(app.Mobile_Number__c)) {
                    mobileMap.get(app.Mobile_Number__c).add(app.Id);
                } else {
                    if(!String.isBlank(app.Mobile_Number__c))
                        mobileMap.put(app.Mobile_Number__c, new Set<Id>{ app.Id });
                }
                if (secMobileMap.containskey(app.Secondary_Mobile_Number__c)) {
                    secMobileMap.get(app.Secondary_Mobile_Number__c).add(app.Id);
                } else {
                    if(!String.isBlank(app.Secondary_Mobile_Number__c)) {
                        secMobileMap.put(
                        app.Secondary_Mobile_Number__c,
                        new Set<Id>{ app.Id }
                    );
                    }
                    
                }
                if (passportMap.containskey(app.Passport_Copy_Details__c)) {
                    passportMap.get(app.Passport_Copy_Details__c).add(app.Id);
                } else {
                    if(!String.isBlank(app.Passport_Copy_Details__c)) {
                         passportMap.put(app.Passport_Copy_Details__c, new Set<Id>{ app.Id });
                    }
                   
                }
                if (nationalIdMap.containskey(app.National_ID_Details__c)) {
                    nationalIdMap.get(app.National_ID_Details__c).add(app.Id);
                } else {
                     if(!String.isBlank(app.National_ID_Details__c)) {
                         nationalIdMap.put(app.National_ID_Details__c, new Set<Id>{ app.Id });
                     }
                    
                }
            }
            
            Integer uniqVal = 1015001;
            Map<String, Set<Id>> mapWithUniqVal = new Map<String, Set<Id>>();
            for (Applicant_Details__c app : applicantMap.values()) {
                if (emailMap.containskey(app.Email_Address__c)) {
                    mapWithUniqVal.put(
                        app.Email_Address__c,
                        emailMap.get(app.Email_Address__c)
                    );
                } 
                if (mobileMap.containskey(app.Mobile_Number__c)) {
                    mapWithUniqVal.put(
                        app.Mobile_Number__c,
                        mobileMap.get(app.Mobile_Number__c)
                    );
                } 
                if (secMobileMap.containskey(app.Secondary_Mobile_Number__c)) {
                    mapWithUniqVal.put(
                        app.Secondary_Mobile_Number__c,
                        secMobileMap.get(app.Secondary_Mobile_Number__c)
                    );
                } 
                if (passportMap.containskey(app.Passport_Copy_Details__c)) {
                    mapWithUniqVal.put(
                        app.Passport_Copy_Details__c,
                        passportMap.get(app.Passport_Copy_Details__c)
                    );
                } 
                if (nationalIdMap.containskey(app.National_ID_Details__c)) {
                    mapWithUniqVal.put(
                        app.National_ID_Details__c,
                        nationalIdMap.get(app.National_ID_Details__c)
                    );
                }
            }
            List<Account> accToUpadte = new List<Account>();
            if (!mapWithUniqVal.isEmpty()) {
                getUpdateDataList(mapWithUniqVal, applicantMap);
            }
            System.debug('account size=>'+accToUpadte);
            /*if (accToUpadte.size() > 0) {
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
Update accToUpadte;
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
}*/
        } //EOF If Check
    }
    
    public static void getUpdateDataList(
        Map<String, Set<Id>> mapObjApp,
        Map<Id, Applicant_Details__c> applicantMap
    ) {
        List<Account> accToUpadte = new List<Account>();
        List<Account> accToUpadte2 = new List<Account>();
        List<Id> accoutnIds = new List<Id>();
        Map<Id, Integer> mapAccountExternalKey = new Map<Id,Integer>();
        Map<Id, Integer> mapAccountUniqueKey = new Map<Id,Integer>();
        Set<ID> excludeId = new Set<ID>{
            '001JX000009zibkYAA',
                '001JX000009zoHGYAY',
                '001JX000009zq33YAA'
                }; //Added to Exclude Some Testing Records
                    Integer uniqVal = 1015001;
        Integer externalUniqVal = 1015001;
        System.debug('mapObjApp->'+mapObjApp);
        System.debug('applicantMap->'+applicantMap);
        
        // run for duplicate logic
        for (String mapV : mapObjApp.keySet()) {
            Set<Id> appIdList = mapObjApp.get(mapV);
            externalUniqVal = uniqVal;
            
            
            if (appIdList.size() > 1) {
                
                for(Id appId : appIdList) {
                    if(mapAccountExternalKey.containskey(applicantMap.get(appId).Opportunity__r.AccountId)) {
                        externalUniqVal = mapAccountExternalKey.get(applicantMap.get(appId).Opportunity__r.AccountId);
                        continue;
                    }
                }
                
                for (Id appId : appIdList) {
                    
                    mapAccountExternalKey.put(applicantMap.get(appId).Opportunity__r.AccountId, externalUniqVal);
                    mapAccountUniqueKey.put(applicantMap.get(appId).Opportunity__r.AccountId, uniqVal);
                    System.debug('app list=>'+appId);
                    Account acc = new Account();
                    acc.Id = applicantMap.get(appId).Opportunity__r.AccountId;
                    acc.Unique_Customer_External_ID__c = String.valueOf(externalUniqVal);
                    acc.Unique_Customer_ID__c = String.valueOf(uniqVal) ;
                    acc.Duplicate_Customer__c = true;
                    if(! (accoutnIds.contains(acc.Id) || excludeId.contains(acc.Id))) {
                        if(accToUpadte.size() > 9000) {
                            accToUpadte2.add(acc);
                        } else {
                            accToUpadte.add(acc);
                        }
                        accoutnIds.add(acc.Id);
                        uniqVal++;
                    }
                    
                }
            } else {
                
                List<Id> lstId = new List<Id>(appIdList);
                if(mapAccountExternalKey.containskey(applicantMap.get(lstId[0]).Opportunity__r.AccountId)) {
                    externalUniqVal = mapAccountExternalKey.get(applicantMap.get(lstId[0]).Opportunity__r.AccountId);
                    continue;
                }
                mapAccountExternalKey.put(applicantMap.get(lstId[0]).Opportunity__r.AccountId, uniqVal);
                mapAccountUniqueKey.put(applicantMap.get(lstId[0]).Opportunity__r.AccountId, uniqVal);
                System.debug('for single record'+lstId);
                Account acc = new Account();
                acc.Id = applicantMap.get(lstId[0]).Opportunity__r.AccountId;
                acc.Unique_Customer_External_ID__c =String.valueOf(uniqVal);
                acc.Unique_Customer_ID__c = String.valueOf(uniqVal);
                acc.Duplicate_Customer__c = true;
                if(! (accoutnIds.contains(acc.Id) || excludeId.contains(acc.Id))) {
                    if(accToUpadte.size() > 9000) {
                        accToUpadte2.add(acc);
                    } else {
                        accToUpadte.add(acc);
                    }
                    accoutnIds.add(acc.Id);    
                    uniqVal++;
                }
                
            }
        }
        
        System.debug('DEBUG unique ->'+ accToUpadte);
        System.debug('DEBUG unique ->'+ accToUpadte2);
        
        if (accToUpadte.size() > 0) {
            PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
            Update accToUpadte;
            PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
        }
        
        if(accToUpadte2.size() > 0) {
            updateAccountsUniqueIds objUniq =new  updateAccountsUniqueIds(accToUpadte2);
            System.enqueuejob(objUniq);
        }
    }
    
    public class updateAccountsUniqueIds implements Queueable {
        List<Account> accToUpadte2 = new List<Account>();
        public updateAccountsUniqueIds(List<Account> accToUpadte){
            accToUpadte2 = accToUpadte;
        }
        public void execute(QueueableContext context) {
            
            if (accToUpadte2.size() > 0) {
            PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
            Update accToUpadte2;
            PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
        }
        }
    }
    
}