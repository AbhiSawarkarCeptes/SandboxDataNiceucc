global class Mobile_ApiUtility {
	
     Public static HttpResponseWrapper prepareResponse(list<responseBodyWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody; 
         resWrap.Message = rMessage;
         resWrap.status = rStatus;
         resWrap.statusCode = rStatusCode;
         resWrap.success = rSuccess;
        return resWrap;
    }
    
    public class responseBodyWrapper{
        public String bookingID;
        public String bookingStatus;
        public String bookingName;
        public String unitName;
        public String towerName;
        public String clusterName;
        public String projectName;
        public boolean isresale;
    }
    
    Public class HttpResponseWrapper{
        Public String status;
        Public Integer statusCode;
        Public list<responseBodyWrapper> data = new list<responseBodyWrapper>();
        Public boolean success;
        Public String Message;
    }
    
     public static void createMobileAPILogs(string apiName,string className,string requestBody,string responseBody,string errorMsg, integer statutCode){
        Mobile_Logs__c log = new Mobile_Logs__c();
        log.API_Name__c = (apiName!=null && apiName!='')?apiName:'';
        log.Class_Name__c = (className!=null && className!='')?className:'';
        log.Error_Log__c = (errorMsg!=null && errorMsg!='')?errorMsg:'';
        log.Request_Body__c = (requestBody!=null && requestBody!='')?requestBody:'';
        log.Response_Body__c = (responseBody!=null && responseBody!='')?responseBody:'';
        log.Status_Code__c = statutCode;
        log.isSuccess__c = statutCode == 200 ? true : false;
        system.debug(log);
        insert log;
    }
    
   
    public static void sendnotifications(String templateSlug,String email, TemplateData templateDataRec, String type){
        requestBodyWrapper wrap = new requestBodyWrapper();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        String sftoken = mobile_appmdt.sf_Token__c;
        String Subscription_Key = mobile_appmdt.Subscription_Key__c;
        System.debug('endpoint : '+endpoint);
        String endPointURL = endpoint+'/sradminnotification/v1/admin/notifications';
        string methodType = 'POST';
        string response = '';
        String errorMessage = '';
        try{ 
            TemplateData newTemplateRec = new TemplateData();
            newTemplateRec.booking_id = templateDataRec.booking_Name;
            newTemplateRec.unit_no = templateDataRec.unit_no;
            newTemplateRec.community_name = templateDataRec.community_name;
            newTemplateRec.tower_villa = templateDataRec.tower_villa;
            
            wrap.templateslug = templateSlug;
            wrap.senderSlug = 'salesforce';
            wrap.email = email;
            wrap.type = type;
            wrap.templateData = newTemplateRec; //templateDataRec
            
            Payload payld = new Payload();
            payld.payloadBooking = templateDataRec.booking_id;
            payld.slug = templateSlug;
            wrap.payload = payld;
			
            String wrapstg = JSON.serialize(wrap);
            if(wrap.templateData != null){    
                wrapstg = wrapstg.replace('community_name','<community_name>');
                wrapstg = wrapstg.replace('unit_no', '<unit_no>');
                wrapstg = wrapstg.replace('booking_id', '<booking_id>');
                wrapstg = wrapstg.replace('tower_villa', '<tower/villa>');
                wrapstg = wrapstg.replace('payloadBooking', 'booking_id');
            }
            
            
            
            system.debug('~~~wrapstg: '+wrapstg);
            if(wrapstg != null){      
             response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,wrapstg);
            }
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
    }
    
     global class requestBodyWrapper{
      
        string templateSlug;
        string senderSlug;
        String email;
        String type;
        templateData templateData;
        payload payload;
    }
    
    public class TemplateData{
        public String community_name;
        public String unit_no;
        public String booking_id;
        public String tower_villa;
        public String booking_Name;
    }
    
    public class Payload{
        public String payloadBooking;
        public String slug;
    }
    
}