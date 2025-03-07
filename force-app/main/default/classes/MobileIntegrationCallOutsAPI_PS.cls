global class MobileIntegrationCallOutsAPI_PS {
    
    public static string callMobileApp(string endPointURL,string methodType,string body) {
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String sftoken = mobile_appmdt.sf_Token__c;
        String Subscription_Key = mobile_appmdt.Subscription_Key__c;
        string res = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(endPointURL);
        request.setMethod(methodType);
        request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
        request.setHeader('x-sf-token',sftoken);
        request.setBody(body);
        System.debug('body : '+body);
        System.debug('request mobile app: '+request);
        if(Test.isRunningTest()) {
            return 'test';
        }
        HttpResponse response = http.send(request);
        system.debug('getBody:::'+ response.getBody());
        if (response.getStatusCode() == 200) {
            system.debug('sucess:::'+response.getBody());
            res = response.getBody();
        } else {
            res = response.getBody();
            system.debug('Error:::'+ res);
        }
        return res;
    }
    
    public static void sendnotifications(String bookingId,String templateSlug,String email,TemplateData templateDataRec, String type){
        requestBodyWrapper wrap = new requestBodyWrapper();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');    
        String sftoken = mobile_appmdt.sf_Token__c;
        String Subscription_Key = mobile_appmdt.Subscription_Key__c;
        String endPointURL = mobile_appmdt.Notifications_Endpoint__c;
        if(test.isrunningtest())
            endPointURL = 'url';
        string methodType = 'POST';
        string response = '';
        String errorMessage = '';
        wrap.templateslug = templateSlug;
        wrap.senderSlug = 'salesforce';
        wrap.email = email;
        wrap.type = type;
        wrap.templateData = templateDataRec;
        
        Payload payld = new Payload();
        payld.payloadBooking = bookingId;
        payld.slug = templateSlug;
        wrap.payload = payld;
        
        String wrapstg = JSON.serialize(wrap);
        try{ 
           if(wrap.templateData != null){    
                wrapstg = wrapstg.replace('community_name','<community_name>');
                wrapstg = wrapstg.replace('unit_no', '<unit_no>');
                wrapstg = wrapstg.replace('booking_Name', '<booking_id>');
                wrapstg = wrapstg.replace('tower_villa', '<tower/villa>');
                wrapstg = wrapstg.replace('payloadBooking', 'booking_id');
            }
            system.debug('~~~wrapstg: '+wrapstg);
            if(wrapstg != null){      
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endPointURL);
                request.setMethod(methodType);
                request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
                request.setHeader('Content-Type','application/json');
                request.setHeader('x-integration-key', 'salesforce');
                request.setHeader('x-sf-token',sftoken);
                request.setBody(wrapstg);
                HttpResponse res = http.send(request);
                if (res.getStatusCode() == 200) {
                    system.debug('sucess:::'+res.getBody());
                    Mobile_App_Log__c logError = new Mobile_App_Log__c();
                    logError.Notifications_Slug__c = templateSlug;
                    logError.Response_Body__c = res.getBody();
                    logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotifications';
                    logError.API_Name__c = endPointURL;
                    logError.Status__c = '200';
                    logError.Notifications_Slug__c = templateSlug;
                    logError.Application_Booking__c = bookingId;
                    logError.Request_Body__c = JSON.serialize(wrapstg);
                    insert logError;
                } else {
                    Mobile_App_Log__c logError = new Mobile_App_Log__c();
                    logError.Notifications_Slug__c = templateSlug;
                    logError.Response_Body__c = res.getBody();
                    logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotifications';
                    logError.API_Name__c = endPointURL;
                    logError.Status__c = '400';
                    logError.Notifications_Slug__c = templateSlug;
                    logError.Application_Booking__c = bookingId;
                    logError.Request_Body__c = JSON.serialize(wrapstg);
                    insert logError;
                }
            }
        }catch(Exception e){
            errorMessage = e.getMessage();Mobile_App_Log__c logError = new Mobile_App_Log__c(); logError.Application_Booking__c = bookingId; logError.Notifications_Slug__c = templateSlug;
            logError.Response_Body__c = errorMessage;logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotifications';
            logError.API_Name__c = endPointURL;logError.Status__c = 'Exception';logError.Notifications_Slug__c = templateSlug;logError.Request_Body__c = JSON.serialize(wrapstg);
            insert logError;
        }
    }
    
   /* public static void sendnotificationsPayment(String templateSlug,String email, TemplateData templateDataRec, String type) {
        requestBodyWrapper wrap = new requestBodyWrapper();
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String sftoken = mobile_appmdt.sf_Token__c;
        String Subscription_Key = mobile_appmdt.Subscription_Key__c;
        String endPointURL = mobile_appmdt.Notifications_Endpoint__c;
        string methodType = 'POST';
        string response = '';
        String errorMessage = '';
        wrap.templateslug = templateSlug;
        wrap.senderSlug = 'salesforce';
        wrap.email = email;
        wrap.type = type;
        //wrap.templateData = templateDataRec;
        Payload payld = new Payload();
        payld.payloadBooking = templateDataRec.booking_id;
        payld.slug = templateSlug;
        wrap.payload = payld;
        String wrapstg = JSON.serialize(wrap);
        try{ 
            if(wrap.payload != null){    
                wrapstg = wrapstg.replace('payloadBooking', 'booking_id');
            }
            system.debug('~~~wrapstg: '+wrapstg);
            if(wrapstg != null){      
                if(wrapstg != null){      
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endPointURL);
                    request.setMethod(methodType);
                    request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
                    request.setHeader('Content-Type','application/json');
                    request.setHeader('x-integration-key', 'salesforce');
                    request.setHeader('x-sf-token',sftoken);
                    request.setBody(wrapstg);
                    HttpResponse res = http.send(request);
                    if (res.getStatusCode() == 200) {
                        system.debug('sucess:::'+res.getBody());
                        Mobile_App_Log__c logError = new Mobile_App_Log__c();
                        logError.Notifications_Slug__c = templateSlug;
                        logError.Response_Body__c = res.getBody();
                        logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotificationsPayment';
                        logError.API_Name__c = endPointURL;
                        logError.Status__c = '200';
                        //logError.Application_Booking__c = templateDataRec.booking_id;
                        logError.Notifications_Slug__c = templateSlug;
                        logError.Request_Body__c = JSON.serialize(wrapstg);
                        insert logError;
                    } else {
                        Mobile_App_Log__c logError = new Mobile_App_Log__c();
                        //logError.Application_Booking__c = templateDataRec.booking_id;
                        logError.Notifications_Slug__c = templateSlug;
                        logError.Response_Body__c = res.getBody();
                        logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotificationsPayment';
                        logError.API_Name__c = endPointURL;
                        logError.Status__c = '400';
                        logError.Notifications_Slug__c = templateSlug;
                        logError.Request_Body__c = JSON.serialize(wrapstg);
                        insert logError;
                    }
                }
            }
        }catch(Exception e){
            errorMessage = e.getMessage();
            Mobile_App_Log__c logError = new Mobile_App_Log__c();
            logError.Notifications_Slug__c = templateSlug;
            logError.Response_Body__c = errorMessage;
            logError.Class_Name__c = 'MobileIntegrationCallOutsAPI_PS.sendnotificationsPayment';
            logError.API_Name__c = endPointURL;
            logError.Status__c = 'Exception';
            logError.Notifications_Slug__c = templateSlug;
            logError.Request_Body__c = JSON.serialize(wrapstg);
            insert logError;
        }
    }
    */
    
    global class requestBodyWrapper {
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
        //public String booking_id;
        public String tower_villa;
        public String booking_Name;
    }
    
    public class Payload{
        public String payloadBooking;
        public String slug;
    }
}