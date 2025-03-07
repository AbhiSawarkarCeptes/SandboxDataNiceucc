public without sharing class TeleCallButtonController {
	@AuraEnabled
    public static string getLeadMobileNumber(string recordId){
        list<NPS_Survey_Log__c> npsLog = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Lead__c =: recordId]; 
        list<NPS_Survey_Log__c> npsLogToday = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Lead__c =: recordId and NPS_Call_Date__c = TODAY]; 
        if(npsLog.size()==5){
            return 'NPS Survey cannot be made, as the number of survey attempts has been exceeded';
        }
        else if(npsLogToday.size() == 2){
            return 'NPS Survey cannot be made, as the number of survey attempts for today has been exceeded';
        }
        else{
            NPS_Survey_Log__c log = new NPS_Survey_Log__c();
            log.Lead__c=recordId;
            log.call_done_by__c = UserInfo.getUserId();
            log.NPS_Call_Counter__c = npsLog.size()+1;
            log.NPS_Call_Date__c = system.today();
            log.NPS_Call_Date_and_time__c = system.now();
            insert log;
            Lead l = [select Id,MobilePhone from Lead where Id=:recordId];
            return l.MobilePhone;
        }
    }
    
    @AuraEnabled
    public static string getNPSSurveyMobileNumber(string recordId){
        list<NPS_Survey_Log__c> npsLog = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where NPS_Survey__c =: recordId]; 
        list<NPS_Survey_Log__c> npsLogToday = [select id,NPS_Call_Counter__c,NPS_Call_Date__c,NPS_Call_Date_and_time__c,NPS_Survey__r.NPS_Survey_Status__c from NPS_Survey_Log__c where NPS_Survey__c =: recordId and NPS_Call_Date__c = TODAY Order By CreatedDate Desc]; 
        Datetime currentDateTimeMinus1Hour = System.now().addHours(-(Integer.valueOf(System.Label.NPS_Call_Gap)));
        if(npsLog.size()==Integer.valueOf(System.Label.NPS_Overall_Call)){
            return 'NPS Survey cannot be made, as the number of survey attempts has been exceeded';
        }
        else if(npsLogToday.size() == Integer.valueOf(System.Label.NPS_Per_Day_Call) && npsLogToday[0].NPS_Survey__r.NPS_Survey_Status__c != 'Call Scheduled'){
            return 'NPS Survey cannot be made, as the number of survey attempts for today has been exceeded';
        }
        else if(npsLogToday.size() == 1 && npsLogToday[0].NPS_Call_Date_and_time__c > currentDateTimeMinus1Hour && npsLogToday[0].NPS_Survey__r.NPS_Survey_Status__c != 'Call Scheduled'){
            return 'NPS Survey cannot be made, as there must be a minimum of 1 hour gap from the previous attempt.';
        }
        else{
            NPS_Survey_Log__c log = new NPS_Survey_Log__c();
            log.NPS_Survey__c=recordId;
            log.call_done_by__c = UserInfo.getUserId();
            log.NPS_Call_Counter__c = npsLog.size()+1;
            log.NPS_Call_Date__c = system.today();
            log.NPS_Call_Date_and_time__c = system.now();
            insert log;
            NPS_Survey__c l = [select Id,Phone__c from NPS_Survey__c where Id=:recordId];
            return l.Phone__c;
        }
    }
    
    @AuraEnabled
    public static string getBookingMobileNumber(string recordId){
        list<NPS_Survey_Log__c> npsLog = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Booking__c =: recordId]; 
        list<NPS_Survey_Log__c> npsLogToday = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Booking__c =: recordId and NPS_Call_Date__c = TODAY]; 
        if(npsLog.size()==5){
            return 'NPS Survey cannot be made, as the number of survey attempts has been exceeded';
        }
        else if(npsLogToday.size() == 2){
            return 'NPS Survey cannot be made, as the number of survey attempts for today has been exceeded';
        }
        else{
            NPS_Survey_Log__c log = new NPS_Survey_Log__c();
            log.Booking__c=recordId;
            log.call_done_by__c = UserInfo.getUserId();
            log.NPS_Call_Counter__c = npsLog.size()+1;
            log.NPS_Call_Date__c = system.today();
            log.NPS_Call_Date_and_time__c = system.now();
            insert log;
            Booking__c b = [select Id,PrimaryMobileNumber__c from Booking__c where Id=:recordId];
        	return b.PrimaryMobileNumber__c;
        }
    }
    
    @AuraEnabled
    public static string getNPSSurveyStatus(string recordId){
        string status='';
        if(recordId.startsWith('00Q')){
            Lead l = [select Id,NPS_Survey_Status__c from Lead where Id=:recordId];
            status = l.NPS_Survey_Status__c;
        }
        else if(recordId.startsWith('a06')){
            Booking__c b = [select Id,NPS_Survey_Status__c from Booking__c where Id=:recordId];
            status = b.NPS_Survey_Status__c;
        }
        else if(recordId.startsWith('006')){
            Opportunity o = [select Id,NPS_Survey_Status__c from Opportunity where Id=:recordId];
            status = o.NPS_Survey_Status__c;
        }
        else{
            status='';
        }
        return status;
    }
    
    @AuraEnabled
    public static void updateNPSSurveyStatus(string recordId, string status){
        system.debug('inside updateNPSSurveyStatus recordId: '+recordId);
        system.debug('inside updateNPSSurveyStatus status: '+status);
        if(recordId.startsWith('00Q')){
            system.debug('inside lead update');
            Lead l = new Lead(Id=recordId,NPS_Survey_Status__c=status);
            update l;
        }
        else if(recordId.startsWith('a06')){
            system.debug('inside booking update');
            Booking__c b = new Booking__c(Id=recordId,NPS_Survey_Status__c=status);
            update b;
        }
        else if(recordId.startsWith('006')){
            system.debug('inside Opportunity update');
            Opportunity o = new Opportunity(Id=recordId,NPS_Survey_Status__c=status);
            update o;
        }
    }
    
    @AuraEnabled
    public static String getOppMobileNumber(String recordId){
        list<NPS_Survey_Log__c> npsLog = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Opportunity__c =: recordId]; 
        list<NPS_Survey_Log__c> npsLogToday = [select id,NPS_Call_Counter__c,NPS_Call_Date__c from NPS_Survey_Log__c where Opportunity__c =: recordId and NPS_Call_Date__c = TODAY]; 
        if(npsLog.size()==5){
            return 'NPS Survey cannot be made, as the number of survey attempts has been exceeded';
        }
        else if(npsLogToday.size() == 2){
            return 'NPS Survey cannot be made, as the number of survey attempts for today has been exceeded';
        }
        else{
            NPS_Survey_Log__c log = new NPS_Survey_Log__c();
            log.Opportunity__c=recordId;
            log.call_done_by__c = UserInfo.getUserId();
            log.NPS_Call_Counter__c = npsLog.size()+1;
            log.NPS_Call_Date__c = system.today();
            log.NPS_Call_Date_and_time__c = system.now();
            insert log;
            String leadId = [select Lead_Id__c from Opportunity where Id=:recordId].Lead_Id__c;
            list<Lead> l = [select Id,MobilePhone from Lead where Lead_Id__c=:leadId];
            if(l.size()>0) return l[0].MobilePhone; else return '';
        }
    }
    
    @AuraEnabled
    public static string getTimezone(String recordId){
        string tZone='';
        map<string,CountryCodeInfo__mdt> countryCodeToTimezone = new map<string,CountryCodeInfo__mdt>();
        map<string,CountryCodeInfo__mdt> countryToTimezone = new map<string,CountryCodeInfo__mdt>();
        for(CountryCodeInfo__mdt cc : [select id,CountryCodeInfo__c,CountryName__c,Timezone__c from CountryCodeInfo__mdt]){
            countryCodeToTimezone.put(cc.CountryCodeInfo__c,cc);
            countryToTimezone.put(cc.CountryName__c,cc);
        }
        NPS_Survey__c nps = [select Id, Object_Type__c, Record_Id__c from NPS_Survey__c where Id =: recordId];
        if(nps.Object_Type__c=='Lead'){
        //if(recordId.startsWith('00Q')){
            Lead l = [select Id,RDS_Country_Code__c,Nationality__c from Lead where Id=:nps.Record_Id__c];
            if(l.RDS_Country_Code__c!=null){
                tZone=l.RDS_Country_Code__c;
                tZone=tZone.replace('+','');
                tZone=(tZone!=null && tZone!='' && countryCodeToTimezone.containsKey(tZone))?countryCodeToTimezone.get(tZone).Timezone__c:'';
            }
            if(l.Nationality__c!=null){
                tZone=tZone+'#'+l.Nationality__c;
            }
        }
        else if(nps.Object_Type__c=='Booking'){
        //else if(recordId.startsWith('a06')){
            Booking__c b = [select Id,NPS_Survey_Status__c,Opportunity__r.Lead_Id__c,(select Id,Nationality__c,Country__c from ApplicantDetails__r where Applicant_Number__c='Primary Applicant') from Booking__c where Id=:nps.Record_Id__c];
            /*if(b.Opportunity__r.Lead_Id__c!=null){
                list<Lead> l = [select Id,RDS_Country_Code__c,Nationality__c from Lead where Lead_Id__c=:b.Opportunity__r.Lead_Id__c];
                if(l.size()>0){
                    if(l[0].RDS_Country_Code__c!=null){
                        tZone=l[0].RDS_Country_Code__c;
                        tZone=tZone.replace('+','');
                        tZone=countryCodeToTimezone.get(tZone).Timezone__c;
                    }
                }
            }*/
            if(b.ApplicantDetails__r!=null && b.ApplicantDetails__r.size()>0){
                string country = '';
                if(b.ApplicantDetails__r[0].Country__c != null){
                    country = b.ApplicantDetails__r[0].Country__c;
                    if(country == 'UAE')
                        country = 'United Arab Emirates';
                    tZone=(country!=null && country!='' && countryToTimezone.containsKey(country))?countryToTimezone.get(country).Timezone__c:'';
                }
                tZone=tZone+'#'+b.ApplicantDetails__r[0].Nationality__c;
            }
        }
        else if(nps.Object_Type__c=='Opportunity'){
        //else if(recordId.startsWith('006')){
            String leadId = [select Lead_Id__c from Opportunity where Id=:nps.Record_Id__c].Lead_Id__c;
            list<Lead> l = [select Id,RDS_Country_Code__c,Nationality__c from Lead where Lead_Id__c=:leadId];
            if(l.size()>0){
                if(l[0].RDS_Country_Code__c!=null){
                    tZone=l[0].RDS_Country_Code__c;
                    tZone=tZone.replace('+','');
                    tZone=(tZone!=null && tZone!='' && countryCodeToTimezone.containsKey(tZone))?countryCodeToTimezone.get(tZone).Timezone__c:'';
                }
                if(l[0].Nationality__c!=null){
                    tZone=tZone+'#'+l[0].Nationality__c;
                }
            }
        }
        
        return tZone;
    }
    
}