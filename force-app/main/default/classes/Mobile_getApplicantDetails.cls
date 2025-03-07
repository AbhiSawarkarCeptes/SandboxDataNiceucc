@RestResource(urlMapping = '/getApplicantDetails')
global class Mobile_getApplicantDetails {

    @HttpPost
    global static void getApplicantDetails(String bookingId) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String responseString = '';
        String errorMessage = '';       
        try{
            List<Applicant_Details__c> applicantLst = [Select id, Name, Applicant_Number__c, Passport_Copy_Details__c, Emirates_ID_Details__c, Mobile_Number__c, Email_Address__c  from Applicant_Details__c where Booking__c =:bookingId ]; 
            List<responseBodyWrapper> resplst = new List<responseBodyWrapper>();
            if(applicantLst.size() > 0){
                for(Applicant_Details__c al :applicantLst){
                    responseBodyWrapper wrap = new responseBodyWrapper();
                    wrap.id = al.id;
                    wrap.ApplicantName = al.Name;
                    wrap.Applicant_Number = al.Applicant_Number__c;
                    wrap.PassportNo = al.Passport_Copy_Details__c;
                    wrap.Emirates_ID = al.Emirates_ID_Details__c;
                    wrap.Email = al.Email_Address__c;
                    wrap.MobileNumber = al.Mobile_Number__c;
                    resplst.add(wrap);
                }
            }
            responseString = (prepareResponse(resplst,'Operation Successfull','Success',200,true)).toString().replace('"','');
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(resplst,'Operation Successfull','Success',200,true)));
            res.statusCode = 200;  
        }
        catch(Exception e){
            errorMessage = e.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }
        Mobile_ApiUtility.createMobileAPILogs('getApplicantDetails','Mobile_getApplicantDetails',bookingId,responseString,errorMessage,res.statusCode);
    }
    public static HttpResponseWrapper prepareResponse(list<responseBodyWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }

    public class responseBodyWrapper{
        public String id;
        public String ApplicantName;
        public String Applicant_Number;
        public String PassportNo;
        public String Emirates_ID;  
        public String Email;  
        public String MobileNumber;  
    }  
    public class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public List<responseBodyWrapper> data = new list<responseBodyWrapper>();
        public Boolean success;
        public String Message;
    }
}