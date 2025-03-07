@istest
public class Test_Mb_ApiUtility {
    
     @isTest
    static void testInsertMethod1(){
        string apiName = 'ProjectTriggerHandler';
        String className = 'ProjectTriggerHandler';
        String requestBody = 'requestBody';
        String responseBody = 'responseBody';
        String errorMsg = 'No Errors';
        Integer statutCode  = 400;
        test.startTest();
        Mobile_ApiUtility.createMobileAPILogs(apiName,className,requestBody,responseBody,errorMsg,statutCode);
        test.stopTest();
    }
    
     @isTest
    static void testInsertMethodRes(){
        Mobile_TestUtil.createBooking();
        
        List<Booking__c> bk = [Select Id,name,Status__c from Booking__c Limit 2];
        List<Mobile_ApiUtility.responseBodyWrapper> resplst = new List<Mobile_ApiUtility.responseBodyWrapper>();
        Mobile_ApiUtility.responseBodyWrapper  wrap = new Mobile_ApiUtility.responseBodyWrapper();
        wrap.bookingID= bk[0].Id;
        wrap.bookingName = bk[0].name;
        wrap.bookingStatus = bk[0].Status__c;
        resplst.add(wrap);
        
        Mobile_ApiUtility.prepareResponse(resplst,'Operation Successfull','Success',200,true);
        
        //Mobile_ApiUtility.responseBodyWrapper rwrap = new Mobile_ApiUtility.responseBodyWrapper();
        //rwrap.bookingStatus = 'Test';
        
        //Mobile_ApiUtility.HttpResponseWrapper respon = new Mobile_ApiUtility.HttpResponseWrapper();
        //respon = Mobile_ApiUtility.prepareResponse(rwrap, 'rMessage', 'rStatus', 22, true);
    }	
    
     @isTest
    static void testInsertMethod2(){
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
        request.requestURI = '/sradminnotification/v1/admin/notifications';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        RestContext.response = response;
        
        String templateSlug = 'TemplateSlug';
        String email = 'testEmail@gmail.com';
       // Mobile_ApiUtility.TemplateData =
       // Mobile_ApiUtility.TemplateData.unit_no = 'Unit No';
        
        
        test.startTest();
        Mobile_ApiUtility.sendnotifications(templateSlug,email,null,'type');
        test.stopTest();
        
    }

}