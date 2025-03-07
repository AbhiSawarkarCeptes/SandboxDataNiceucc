public class EzetapIntegrationStartCallout {
    
    public static string sendRequest(decimal amount, string deviceId, string prNumber){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:__Ezetab_Integration_Named_Credential/api/3.0/p2p/start');
            request.setHeader('Content-Type', 'application/json');
            EzetapWrapperClass.StartRequestWrapper requestWrapper = new EzetapWrapperClass.StartRequestWrapper();
            Eztap_Integration__mdt eztapObj  = [select App_Key__c, Username__c, DeviceId__c, ExternalRefNumber__c, PaymentMode__c from Eztap_Integration__mdt];
            requestWrapper.appKey = eztapObj.App_Key__c;
            requestWrapper.username = eztapObj.Username__c;
            requestWrapper.externalRefNumber = prNumber + ' ['+system.now()+']';
            requestWrapper.paymentMode = eztapObj.PaymentMode__c;
            requestWrapper.amount = amount;
            
            EzetapWrapperClass.PushTo pushTo = new EzetapWrapperClass.PushTo();
            pushTo.deviceId = deviceId;
            
           	requestWrapper.pushTo = pushTo;
            request.setBody(JSON.serialize(requestWrapper));
			System.debug('==== request'+ request.getEndpoint());
            System.debug('request body : ' + request.getBody());
            HttpResponse response = http.send(request);
			System.debug('===== response'+response.getBody());
			return response.getBody();
		}
        catch(Exception ex) {
			system.debug(':exception occurred:' + ex.getMessage());
            return ex.getMessage();
		}
    }

}