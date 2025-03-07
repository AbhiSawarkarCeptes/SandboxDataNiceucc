public  class reEnquiryLayoutForTSAController {
    @AuraEnabled(cacheable= true)  
    public static List<Task> getTaskData(String leadLookup){
        system.debug('enteredd');
        return [select id,Last_Mile_Conversion__c,Keyword__c,CreatedDate,GCLID__c,Adgroup__c,Placement__c,Match_Type__c,Lead_Lookup__r.CreatedDate,Lead_Lookup__r.Web_Source__c, Lead_Lookup__r.Project_Name__c,Lead_Lookup__r.Campaign_Name__c,Are_you_looking_for__c, UTM_Source__c,Lead_Lookup__r.Project__c, Landing_Page_URL__c, Lead_Source__c, Digital_Source__c, Lead_Lookup__r.Lead_Sub_Source__c, Web_Source__c, Goal__c, UTM_Campaign__c, UTM_Content__c,UTM_Medium__c,Budget__c from Task where Lead_Lookup__c =: leadLookup and  Lead_Lookup__r.IsReenquire__c = true]; 
    }
}