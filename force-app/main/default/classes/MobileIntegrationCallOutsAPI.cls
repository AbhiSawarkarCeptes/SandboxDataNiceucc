public class MobileIntegrationCallOutsAPI {
    
    Public static void createMasterComunity(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://srdevapimgmt.sobhaapps.com/srprosalesforce/v1/salesforce/master-communities');
        request.setMethod('POST');
        request.setHeader('Ocp-Apim-Subscription-Key', '75bbac88e64a46178dd3dfe22a47e337');
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
        request.setHeader('x-sf-token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM3LCJuYW1lIjoic2FsZXNmb3JjZSIsImlhdCI6MTY4NzIzOTkyOH0.f1dGPdJL4R50DKsemb7iOAiPLZCA-_mvPWM_v2a562Q');
        request.setBody('{"name":"Social Heart Land","address":"MBR City, Dubai","maxBudget":1300000,"minBudget":1000000,"longitude":43.1,"latitude":76.1,"stage":"Pre-Launch","projectType":"Residential","sfMasterCommunityId":"a0R7S234233zKsyUAE"}');
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        system.debug(JSON.deserializeUntyped(response.getBody()));
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(JSON.deserializeUntyped(response.getBody()));
            
        }
    }
    Public static void createComunity(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://srdevapimgmt.sobhaapps.com/srprosalesforce/v1/salesforce/communities');
        request.setMethod('POST');
        request.setHeader('Ocp-Apim-Subscription-Key', '75bbac88e64a46178dd3dfe22a47e337');
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
        request.setHeader('x-sf-token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM3LCJuYW1lIjoic2FsZXNmb3JjZSIsImlhdCI6MTY4NzIzOTkyOH0.f1dGPdJL4R50DKsemb7iOAiPLZCA-_mvPWM_v2a562Q');
        request.setBody('{"name":"The Crest","description":"Embrace caribbean style living at the epicenter of Dubai","minArea":1300000,"maxArea":1000000,"sfMasterCommunityId":"a0R7S234233zKsyUAE","sfCommunityId":"a0A2o6735221rWgEAJ"}');
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        system.debug(JSON.deserializeUntyped(response.getBody()));
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(JSON.deserializeUntyped(response.getBody()));
            
        }
    }

    Public static void createUnit(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://srdevapimgmt.sobhaapps.com/srprosalesforce/v1/salesforce/unit');
        request.setMethod('POST');
        request.setHeader('Ocp-Apim-Subscription-Key', '75bbac88e64a46178dd3dfe22a47e337');
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
        request.setHeader('x-sf-token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM3LCJuYW1lIjoic2FsZXNmb3JjZSIsImlhdCI6MTY4NzIzOTkyOH0.f1dGPdJL4R50DKsemb7iOAiPLZCA-_mvPWM_v2a562Q');
        request.setBody('{"floorNumber":1,"unitType":"1 BHK","unitName":"Unit Name","unitPrice":1000000,"unitNumber":101,"isAvailableForSale":true,"availabilityStatus":"Available","DLDBuildingNumber":13423,"noOfBedrooms":1,"permittedUse":"Residential","projectPropertyType":"Residential","noOfParkings":1,"propertyType":"Apartment","parkingType":"Covered","totalArea":1000,"saleableArea":1000,"plotArea":1000,"RERAApplicableArea":1000,"plotNumber":100034,"sfUnitId":"a0n1t4405977qCKAAY","sfCommunityId":"a0A1t591262RDuvEAG","sfTowerId":"a0k1t599789Ea78AAC","sfMasterCommunityId":"a0R1t467893QhInEAK"}');
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        system.debug(JSON.deserializeUntyped(response.getBody()));
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(JSON.deserializeUntyped(response.getBody()));
            
        }
    }
    Public static void createUser(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://srdevapimgmt.sobhaapps.com/sruser/v1/user');
        request.setMethod('POST');
        request.setHeader('Ocp-Apim-Subscription-Key', '75bbac88e64a46178dd3dfe22a47e337');
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
        request.setHeader('x-sf-token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM3LCJuYW1lIjoic2FsZXNmb3JjZSIsImlhdCI6MTY4NzIzOTkyOH0.f1dGPdJL4R50DKsemb7iOAiPLZCA-_mvPWM_v2a562Q');
        request.setBody('{"firstName":"fake","lastName":"name","email":"testuser@gmail.com","dialCode":971,"mobile":551234567,"source":"salesForce"}');
        HttpResponse response = http.send(request);
        system.debug(response.getBody());
        system.debug(JSON.deserializeUntyped(response.getBody()));
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(JSON.deserializeUntyped(response.getBody()));
            
        }
    }
    public static string callMobileApp(string endPointURL,string methodType,string body){
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        String sftoken = mobile_appmdt.sf_Token__c;
        String Subscription_Key = mobile_appmdt.Subscription_Key__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointURL);
        request.setMethod(methodType);
     //   request.setHeader('Ocp-Apim-Subscription-Key', '75bbac88e64a46178dd3dfe22a47e337');
     	request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
        request.setHeader('Content-Type','application/json');
        request.setHeader('x-integration-key', 'salesforce');
     //   request.setHeader('x-sf-token','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM3LCJuYW1lIjoic2FsZXNmb3JjZSIsImlhdCI6MTY4NzIzOTkyOH0.f1dGPdJL4R50DKsemb7iOAiPLZCA-_mvPWM_v2a562Q');
        request.setHeader('x-sf-token',sftoken);
        request.setBody(body);
        System.debug('body : '+body);
        System.debug('request mobile app: '+request);
        HttpResponse response = http.send(request);
        if( !Test.isRunningTest() ){
        Mobile_ApiUtility.createMobileAPILogs(endPointURL,'MobileIntegrationCallOutsAPI',body,response.getBody(),'',response.getStatusCode());
        }
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            system.debug(JSON.deserializeUntyped(response.getBody()));
            return response.getBody();
        }
        return null;
    }
}