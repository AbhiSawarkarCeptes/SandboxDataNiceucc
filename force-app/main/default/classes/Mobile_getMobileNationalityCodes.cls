@RestResource(urlMapping = '/getMobileNationalityCodes')
global class Mobile_getMobileNationalityCodes {

    @HttpGet
    global Static void getItems() {
        RestResponse res = RestContext.response;
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Lead.Mobile_Country_Code__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            Mobile_getNationality.HttpResponseWrapper resWrap = Mobile_getNationality.prepareResponse(pickListValuesList,'Operation Successfull','Success',200,true);
            res.responseBody = BLOB.valueOf(JSON.serialize(resWrap));
            res.statusCode = 200;
            
        }
        catch(Exception e){
            res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_getNationality.prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;
        }
        
    }

}