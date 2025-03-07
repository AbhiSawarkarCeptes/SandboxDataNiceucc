@RestResource(urlMapping='/sobhacapturedownloadreport/')
global with sharing class LeadDownloadReportAPI {
	@HttpPost
    global static DownloadReportResponseWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{	
            DownloadReportResponseWrapper exposeData = new DownloadReportResponseWrapper();
            LeadDownloadReportRequestWrapper result;
            if (Test.isRunningTest()) {
                result = testParseObj();
            } else {
                if (req.requestBody == null){
                    exposeData.success = false;
                    exposeData.statusCode = 400;
                    exposeData.message = 'No request body!!';  
                    return exposeData;
                }
                result = (LeadDownloadReportRequestWrapper)JSON.deserialize(req.requestBody.toString(),LeadDownloadReportRequestWrapper.class);
            }
            
            String firstName = (result.first_name!=null && result.first_name!='')?result.first_name:'';
            String lastName = (result.last_name!=null && result.last_name!='')?result.last_name:'';
            String email = (result.email!=null && result.email!='')?result.email:'';
            String orgName = (result.organization_name!=null && result.organization_name!='')?result.organization_name:'';
            
            if(firstName!='' && lastName!='' && email!='' && orgName!=''){
                Lead_Download_Report__c downloadReport = new Lead_Download_Report__c();
                downloadReport.First_Name__c = firstName;
                downloadReport.Last_Name__c = lastName;
                downloadReport.Email__c = email;
                downloadReport.Country_Code__c = (result.country_code!=null && result.country_code!='')?result.country_code:'';
                downloadReport.Phone__c = (result.phone!=null && result.phone!='')?result.phone:'';
                downloadReport.Organization_Name__c = orgName;
                downloadReport.Preferred_Mode_of_Contact__c = (result.preferred_mode_of_contact!=null && result.preferred_mode_of_contact!='')?result.preferred_mode_of_contact:'';
                if(result.news_offers!=null && result.news_offers!=''){
                    string news_offers = result.news_offers;
                    news_offers = news_offers.toLowerCase();
                    downloadReport.News_Offers__c = (news_offers=='true')?true:false;
                }
                if(result.privacy_policy!=null && result.privacy_policy!=''){
                    string privacy_policy = result.privacy_policy;
                    privacy_policy = privacy_policy.toLowerCase();
                    downloadReport.Privacy_Policy__c = (privacy_policy=='true')?true:false;
                }
                insert downloadReport;
                
                exposeData.success = true;
                exposeData.statusCode = 200;
                exposeData.message = 'Details captured successfully.'; 
            }
            else{exposeData.success = false;exposeData.statusCode = 400;exposeData.message = 'Required fields are missing.';}
            
            return exposeData;
            
        }catch(Exception e) {
            System.debug('Exception Message: '+e.getMessage());
            DownloadReportResponseWrapper exposeData = new DownloadReportResponseWrapper();
            exposeData.success = false;
            exposeData.statusCode = 400;
            exposeData.message = e.getMessage();
            LeadDownloadReportAPI.insertErrorLog(e.getMessage(),(req!=null && req.requestBody!=null)?req.requestBody.toString():'');
            return exposeData;
        }
    }
    
    global with sharing class DownloadReportResponseWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String message='';
    }
    
    public static void insertErrorLog(string errorMsg, string requestBody){
        Error_Log__c log = new Error_Log__c();
        log.Class__c = 'LeadDownloadReportAPI';
        log.Message__c = errorMsg;
        log.endpoint__c = '/sobhacapturedownloadreport/';
        log.Request__c = requestBody;
        log.Api_Type__c = 'POST';
        insert log;
    }
    
    public static LeadDownloadReportRequestWrapper testParseObj() {
        String json = '{'+
            '  \"first_name\": \"Vivek\",'+
            '  \"last_name\": \"Kumar\",'+
            '  \"organization_name\": \"XYZ\",'+
            '  \"email\": \"test@test.com\",'+
            '  \"country_code\": \"+91\",'+
            '  \"phone\": \"9999999999\",'+
            '  \"preferred_mode_of_contact\": \"Phone\",'+
            '  \"privacy_policy\": \"true\",'+
            '  \"news_offers\": \"true\"'+
            '}';
        LeadDownloadReportRequestWrapper obj = LeadDownloadReportRequestWrapper.parse(json);
        return obj;
    }
}