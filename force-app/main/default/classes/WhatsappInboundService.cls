@RestResource(urlMapping='/getTeleSalesAgent/*')
global class WhatsappInboundService {
    
   @HttpGet
    global static String doGet() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //{\n  \"Email\" : \"testEmail@sobharealty.com.invalid\"\n}
        String conMobile = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<PropStrength__Request__c> enqRecList = [SELECT id, name, ownerid, owner.email FROM PropStrength__Request__c
                               WHERE PropStrength__Primary_Contact__r.mobilePhone = :conMobile AND PropStrength__Request_Status__c	!= 'Closed/ Lost' AND PropStrength__Request_Status__c != '	Converted to Offer'
                               ORDER BY Createddate DESC
                               LIMIT 1];
        String agentEmail = 'NA';
        if(enqRecList.size() > 0 && enqRecList[0].ownerid != null) {
            agentEmail = enqRecList[0].owner.Email;
        }
        System.debug('email*---'+agentEmail);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Email', agentEmail);
        gen.writeEndObject();
        String reqBodyJson = gen.getAsString();
        system.debug(reqBodyJson);
        return(reqBodyJson);
    }
    
}