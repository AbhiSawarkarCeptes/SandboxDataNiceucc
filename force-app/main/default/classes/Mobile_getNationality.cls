@RestResource(urlMapping = '/getNationalities')
global class Mobile_getNationality {
    
    @HttpGet
    global Static void getItems() {
        RestResponse res = RestContext.response;
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Applicant_Details__c.Nationality__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(pickListValuesList,'Operation Successfull','Success',200,true)));
            res.statusCode = 200;
        }
        catch(Exception e){
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;
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