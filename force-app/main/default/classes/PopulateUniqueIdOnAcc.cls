public class PopulateUniqueIdOnAcc {
    @testVisible
    private static Boolean doChainJob = true;
    
    public static Boolean oneTimePopulateUniqueId = false;
    public static void startProcess() {
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
                AND Opportunity__r.Account.Unique_Customer_External_ID__c = NULL
                AND Opportunity__r.Account.Unique_Customer_ID__c = NULL
                //AND (National_ID_Details__c in ('121099655','EA4063511')
                //OR Passport_Copy_Details__c in ('Z4732533','PX6898222') )
                Order By Opportunity__r.Account.CreatedDate ASC
                LIMIT 2000
            ]
        );
        if (!applicantMap.isEmpty()) {
            for (Applicant_Details__c app : applicantMap.values()) {
                if (emailMap.containskey(app.Email_Address__c)) {
                    emailMap.get(app.Email_Address__c).add(app.Id);
                } else {
                    emailMap.put(app.Email_Address__c, new Set<Id>{ app.Id });
                }
                if (mobileMap.containskey(app.Mobile_Number__c)) {
                    mobileMap.get(app.Mobile_Number__c).add(app.Id);
                } else {
                    mobileMap.put(app.Mobile_Number__c, new Set<Id>{ app.Id });
                }
                if (secMobileMap.containskey(app.Secondary_Mobile_Number__c)) {
                    secMobileMap.get(app.Secondary_Mobile_Number__c).add(app.Id);
                } else {
                    secMobileMap.put(
                        app.Secondary_Mobile_Number__c,
                        new Set<Id>{ app.Id }
                    );
                }
                if (passportMap.containskey(app.Passport_Copy_Details__c)) {
                    passportMap.get(app.Passport_Copy_Details__c).add(app.Id);
                } else {
                    passportMap.put(app.Passport_Copy_Details__c, new Set<Id>{ app.Id });
                }
                if (nationalIdMap.containskey(app.National_ID_Details__c)) {
                    nationalIdMap.get(app.National_ID_Details__c).add(app.Id);
                } else {
                    nationalIdMap.put(app.National_ID_Details__c, new Set<Id>{ app.Id });
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
                getUpdatedqueueable objGetList = new getUpdatedqueueable(mapWithUniqVal,applicantMap);
                System.enqueuejob(objGetList);
                //accToUpadte = getUpdateDataList(mapWithUniqVal, applicantMap);
            }
            System.debug('account size=>'+accToUpadte);
            if (accToUpadte.size() > 0) {
                //UpdateAccountsQueuable objUpdateAcc = new UpdateAccountsQueuable(accToUpadte);
                //System.enqueuejob(objUpdateAcc);
                /*PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
Update accToUpadte;
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;*/
            }
        } //EOF If Check
    } // EOF Method
    /*
public class UpdateAccountsQueuable implements Queueable {
List<Account> accToUpdate = new List<Account>();
public UpdateAccountsQueuable(List<Account> lstAcc) {
accToUpdate = lstAcc;
}
public void execute(QueueableContext context) {
if (accToUpdate.size() > 0) {
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
Update accToUpdate;
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
}
}
}*/
    
    /* @future
public static void updateAccounts(List<Account> accToUpadte) {
if (accToUpadte.size() > 0) {
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
Update accToUpadte;
PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
}
}*/
    
    public Class getUpdatedqueueable implements Queueable {
        Map<String, Set<Id>> mapObjApp = new Map<String, Set<Id>>();
        Map<Id, Applicant_Details__c> applicantMap = new Map<Id, Applicant_Details__c>();
        
        public getUpdatedqueueable(Map<String, Set<Id>> parMapObjApp, Map<Id, Applicant_Details__c> parApplicantMap) {
            mapObjApp = parMapObjApp;
            applicantMap = parApplicantMap;
        }
        
        public void execute(QueueableContext context) {
            List<Account> accToUpadte = new List<Account>();
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
            List<Account> uniqValACC = [Select Id, Unique_Customer_ID__c from Account where Unique_Customer_ID__c <> null order by Unique_Customer_ID__c desc Limit 1];
            List<Account> externalUniqValACC = [Select Id, Unique_Customer_External_ID__c from Account where Unique_Customer_External_ID__c <> null order by Unique_Customer_External_ID__c desc Limit 1] ;
            if(uniqValACC.size() > 0) {
                uniqVal =Integer.valueof(uniqValACC[0].Unique_Customer_ID__c);
            }
            
            if(externalUniqValACC.size() > 0) {
                externalUniqVal =Integer.valueof(externalUniqValACC[0].Unique_Customer_External_ID__c);
            }
           
                
            
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
                            accToUpadte.add(acc);
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
                        accToUpadte.add(acc);
                        accoutnIds.add(acc.Id);    
                        uniqVal++;
                    }
                    
                }
            }
            
            if(accToUpadte.size() > 0) {
                /*if(doChainJob) {
UpdateAccountsQueuable objUpdateAcc = new UpdateAccountsQueuable(accToUpadte);
System.enqueuejob(objUpdateAcc);
}*/
                    PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = true;
                System.debug('Account update external '+accToUpadte);
                    Update accToUpadte;
                    PopulateUniqueIdOnAcc.oneTimePopulateUniqueId = false;
                System.debug('Account update external '+accToUpadte);
                
                
            }
            
        }
    }
    
    /*
public static List<Account> getUpdateDataList(
Map<String, Set<Id>> mapObjApp,
Map<Id, Applicant_Details__c> applicantMap
) {
List<Account> accToUpadte = new List<Account>();
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
accToUpadte.add(acc);
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
accToUpadte.add(acc);
accoutnIds.add(acc.Id);    
uniqVal++;
}

}
}

return accToUpadte;
}*/
    
}