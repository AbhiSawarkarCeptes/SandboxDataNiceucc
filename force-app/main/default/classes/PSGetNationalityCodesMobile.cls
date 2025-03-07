@RestResource(urlMapping = '/V1/PS/getMobileNationalityCodes')
global class PSGetNationalityCodesMobile {

    @HttpGet
    global Static void getItems() {
        RestResponse res = RestContext.response;
        try{
            List<String> pickListValuesList= new List<String>();
            Schema.DescribeFieldResult fieldResult = PropStrength__Request__c.Mobile_Country_Code__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            } 
            PSGetNationalityMobile.HttpResponseWrapper resWrap = PSGetNationalityMobile.prepareResponse(pickListValuesList,'Operation Successfull','Success',200,true);
            res.responseBody = BLOB.valueOf(JSON.serialize(resWrap));
            res.statusCode = 200;
            Mobile_App_Log__c logError = new Mobile_App_Log__c();
            logError.Response_Body__c = JSON.serialize(pickListValuesList);
            logError.Class_Name__c = 'getMobileNationalityCodes';
            logError.API_Name__c = '/services/apexrest/getMobileNationalityCodes/';
            logError.Status__c = '200';
            insert logError;
        }
        catch(Exception e){res.responseBody = BLOB.valueOf(JSON.serialize(PSGetNationalityMobile.prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = e.getMessage();logError.Class_Name__c = 'getMobileNationalityCodes';logError.API_Name__c = '/services/apexrest/getMobileNationalityCodes/';logError.Status__c = '400';insert logError;
        }
    }
}