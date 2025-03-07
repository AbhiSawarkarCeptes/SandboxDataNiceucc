public class EzetapIntegrationCancelCallout {
    
    public static string sendRequest(string p2prequestId){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:__Ezetab_Integration_Named_Credential/api/3.0/p2p/cancel');
            request.setHeader('Content-Type', 'application/json');
            EzetapWrapperClass.StatusRequestWrapper requestWrapper = new EzetapWrapperClass.StatusRequestWrapper();
            map<string,decimal> currToRate = new map<string,decimal>();
            Eztap_Integration__mdt eztapDefaultUsername  = [select App_Key__c, Username__c,password__c from Eztap_Integration__mdt];
        
            requestWrapper.appKey = eztapDefaultUsername.App_Key__c;
            requestWrapper.username = eztapDefaultUsername.Username__c;
            requestWrapper.origP2pRequestId = p2prequestId;//populate it dynamically once complete integration is done
            requestWrapper.password= eztapDefaultUsername.password__c;
			System.debug('==== request'+ request);
            request.setBody(JSON.serialize(requestWrapper));
            HttpResponse response = http.send(request);
			System.debug('===== response'+response.getBody());
            return response.getBody();
			//EzetapWrapperClass.StatusResponseWrapper res = (EzetapWrapperClass.StatusResponseWrapper)System.Json.deserialize(response.getBody(),EzetapWrapperClass.StatusResponseWrapper.class);
            //if(res.success == false){
                //error
            //}else{
                //process body here
            //}
		}catch(Exception ex) {
			system.debug(':exception occurred:' + ex.getMessage());
            return ex.getMessage();
		}
    }
}