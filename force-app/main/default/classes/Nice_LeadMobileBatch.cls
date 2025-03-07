public class Nice_LeadMobileBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    private static List<Lead> leadMobilevalidatedResults = new List<Lead>();
    private static final string API_KEY = System.Label.Nice_Apilayer_net_API_key;
    private static final string Query_LIMIT = System.Label.Nice_LeadMobileBatch_Limit;
    private static final string BASE_URL = 'http://apilayer.net/api/validate';

    public static Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, MobilePhone FROM Lead WHERE MobilePhone != Null AND num_verified__c = false AND Num_verify_failed__c = false ' + Query_LIMIT;
        return Database.getQueryLocator(query);
        
    }
    
    public static void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<Lead> failedLeads = new List<Lead>();
        Http http = new Http();
        for (Lead lead : scope) {
            Lead Result = validatePhoneNumber(lead.MobilePhone, lead.Id, http);
            system.debug('Lead Id -->'+ lead.Id);
            if (Result != null) {
                leadMobilevalidatedResults.add(Result);
            }
            else {
                Lead thisLead = new Lead(Id = lead.Id);
                thisLead.Num_verify_failed__c = true;
                failedLeads.add(thisLead);
            }
        }
        
        system.debug('leadMobilevalidatedResults -->'+leadMobilevalidatedResults);
        if (!leadMobilevalidatedResults.isEmpty()) {
            update leadMobilevalidatedResults; 
        }
        if (!failedLeads.isEmpty()) {
            update failedLeads; 
        }
    }
    
    public static void finish(Database.BatchableContext BC) {
        system.debug('Finish Called -->'+ leadMobilevalidatedResults.size());
       /* if (!leadMobilevalidatedResults.isEmpty()) {
            update leadMobilevalidatedResults; 
        }*/
    }

    private static Lead validatePhoneNumber(String phoneNumber, String leadId, Http http) {
        
        String endPointUrl = BASE_URL + '?access_key=' + API_KEY + '&number=' + EncodingUtil.urlEncode(phoneNumber, 'UTF-8');
        
        try {
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(endPointUrl);
            httpRequest.setMethod('GET');
            HttpResponse httpResponse = http.send(httpRequest);
            
            if (httpResponse.getStatusCode() == 200 && httpResponse.getBody() != Null && !httpResponse.getBody().contains('error')) {
                
                Nice_LeadMobileBatch.responseWrapper response = (Nice_LeadMobileBatch.responseWrapper) JSON.deserialize(httpResponse.getBody(), Nice_LeadMobileBatch.responseWrapper.class);
                
                if(response != null && response.valid){
                    system.debug('Is valid Number');
                    Lead le = new Lead();
                    le.Id = leadId;
                    le.Primary_Mobile__c = response.local_format;
                    le.Primary_Mobile_Number__c = response.international_format;
                    le.Primary_Mobile_Country_Code__c = response.country_prefix;
                    le.Primary_Mobile_Country__c = response.country_name;
                    le.num_verified__c = true;
                    return le;
                }
            }
            
        } catch (Exception ex) {
            system.debug('Error -->' + ex.getMessage() + 'Line Number -->'+ex.getLineNumber());
        }
        return Null;
        
    }
    
    public class responseWrapper {
        public Boolean valid { get; set; }
        public String local_format { get; set; }
        public String international_format { get; set; }
        public String country_prefix { get; set; }
        public String country_name { get; set; }
    }

}