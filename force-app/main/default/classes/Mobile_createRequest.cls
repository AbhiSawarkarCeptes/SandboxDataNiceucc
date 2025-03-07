@RestResource(urlMapping='/createRequest')
global class Mobile_createRequest{
    @HttpPost 
    global static void doCreateCase(){
        RestResponse res = RestContext.response;
        RestRequest request = RestContext.request;
        String responseString = '';
        String errorMessage = '';
        CaseRequestWrapper objcase = (CaseRequestWrapper)System.JSON.deserialize(request.requestBody.toString(),CaseRequestWrapper.class);
        String crmRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        String collecRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collection').getRecordTypeId();
            Set<String> collectionTypes = new Set<String>{'PCC','SOA'};
        try {
            if(objcase != null){
                
                List<Mobile_App_Case_Mapping__mdt> caseMetadata = [Select id, Department__c, Queue_Id__c from Mobile_App_Case_Mapping__mdt where MasterLabel = :objcase.requestType LIMIT 1];
                Case newCase = new Case();
                newCase.SuppliedEmail = objcase.email;
                newCase.SuppliedPhone = objcase.mobile;
                newCase.description = objcase.description;
                //newCase.Department__c = caseMetadata.Department__c;
                if(objcase.requestType != null && objcase.requestType != '') {
                    newCase.Department__c = caseMetadata.size() > 0 ? caseMetadata[0].Department__c : 'CRM';
                }
                else {
                    newCase.Department__c = 'CRM';
                }
                newCase.Booking__c = objcase.bookingId != null ? objcase.bookingId : '';
                newCase.Origin = 'Mobile App';
                newCase.Category__c = 'Other';
                newCase.recordTypeId = collectionTypes.contains(objcase.requestType) ? collecRecordTypeID : crmRecordTypeID;
                insert newCase;
                responseString = (Mobile_Case.prepareResponse(new List<Case>{newCase},'Operation Successfull','Success',200,true)).toString().replace('"','');
                res.responseBody =  Blob.valueOf(JSON.serialize(Mobile_Case.prepareResponse(new List<Case>{newCase},'Operation Successfull','Success',200,true)));
                res.statusCode = 200;
                
            }
            else{
                res.responseBody =  Blob.valueOf(JSON.serialize(Mobile_Case.prepareResponse(null,'No data found','No data found',400,false)));
                res.statusCode = 400;
            }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_Case.prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('createRequest','Mobile_createRequest',request.requestBody.toString(),responseString,errorMessage,res.statusCode);        
    }

    public class CaseRequestWrapper{
        public String email;
        public String mobile;
        public String description;
        public String requestType;
        public String bookingId;
    }
}