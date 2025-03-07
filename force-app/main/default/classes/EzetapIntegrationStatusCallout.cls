public class EzetapIntegrationStatusCallout {
    
    public static string sendRequest(String p2pRequestId){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:__Ezetab_Integration_Named_Credential/api/3.0/p2p/status');
            request.setHeader('Content-Type', 'application/json');
            EzetapWrapperClass.StatusRequestWrapper requestWrapper = new EzetapWrapperClass.StatusRequestWrapper();
            Eztap_Integration__mdt eztapDefaultUsername  = [select App_Key__c, Username__c,password__c from Eztap_Integration__mdt];
            requestWrapper.appKey = eztapDefaultUsername.App_Key__c;
            requestWrapper.username = eztapDefaultUsername.Username__c;
            requestWrapper.password= eztapDefaultUsername.password__c;
			
            requestWrapper.origP2pRequestId = p2pRequestId;
            request.setBody(JSON.serialize(requestWrapper));
			HttpResponse response = http.send(request);
			System.debug('===== '+response.getBody());
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			return response.getBody();
		}catch(Exception ex) {
			system.debug(':exception occurred:' + ex.getMessage());
            return ex.getMessage();
		}
    }
}