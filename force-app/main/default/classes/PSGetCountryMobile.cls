@RestResource(urlMapping='/V1/PS/getCountryList')
global class PSGetCountryMobile {
    @HttpGet
    global Static void getItems() {
        RestResponse res = RestContext.response;
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Payment_Request__c.Country_of_Initiation__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(pickListValuesList,'Operation Successfull','Success',200,true)));
            res.statusCode = 200;
            Mobile_App_Log__c logError = new Mobile_App_Log__c();
            logError.Response_Body__c = JSON.serialize(pickListValuesList);
            logError.Class_Name__c = 'PSGetCountryMobile';
            logError.API_Name__c = '/services/apexrest/getCountryList/';
            logError.Status__c = '200';
            insert logError;
        }
        catch(Exception e){
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,e.getMessage(),'Fail',400,false)));res.statusCode = 400;Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = e.getMessage();logError.Class_Name__c = 'PSGetCountryMobile';
            logError.API_Name__c = '/services/apexrest/getCountryList/';logError.Status__c = '400';insert logError;
        }
    }
    Public static HttpResponseWrapper prepareResponse(list<string> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.body = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }
    Public class HttpResponseWrapper{
        Public String status;
        Public Integer statusCode;
        Public list<String> body = new list<string>();
        Public boolean success;
        Public String Message;
    }
}