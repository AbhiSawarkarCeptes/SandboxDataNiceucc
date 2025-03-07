@RestResource(urlMapping = '/getScheduleAppointment')
global class Mobile_getScheduleAppointment {
	 @HttpPost
    global static HttpResponseWrapper getPaymentReceipts(String bookingId,String apntType,Date scheduleDate,String timing,String remarks){
        List<ResponseBodyWrapper> paymentReceiptsWrapper = new List<ResponseBodyWrapper>();
        RestRequest req = RestContext.request;
        try{
           List<Time_Slot_For_Handover__c> handoverRec = [Select id, RecordType.Name, Status__c,Remarks__c, Scheduled_Date__c,QT_Keepout_Date__c from Time_Slot_For_Handover__c where Booking__c = :bookingId and recordType.name =:apntType and Status__c = ''];

            if(handoverRec != null && handoverRec.size() > 0){
             	handoverRec[0].Scheduled_Date__c =  scheduleDate;
                if(handoverRec[0].QT_Keepout_Date__c == null){
                    handoverRec[0].QT_Keepout_Date__c = scheduleDate;
                }
                if(timing.equals('7 PM - 8 PM')){ //because of space in the picklist value we write this condition.
                     handoverRec[0].Timings__c = '7PM - 8 PM';
                }else{
                     handoverRec[0].Timings__c = timing;
                }
               
                handoverRec[0].Status__c = 'Confirmed';
                if(handoverRec[0].Remarks__c != null){
                     handoverRec[0].Remarks__c += remarks;
                }else{
                    handoverRec[0].Remarks__c = remarks;
                }
               
                update handoverRec;
                return prepareResponse(null,'Successfully Updated','Successfully Updated',200,true);
            }else{
               return prepareResponse(null,'You cannot book the appointment. Please contact 800SOBHA','Booking Already Confirmed',200,false);         
            }
            
        }catch (Exception ex) {
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'Mobile_getScheduleAppointment';
            insert logError;
            return prepareResponse(null,ex.getMessage(),'Error',400,false);
        }
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
    
    public class ResponseBodyWrapper{
        public String primaryApplicantName;
        public String Email;
        public String mode;
        public String receiptNumber;
        public Decimal totalamount;
        public Date createdDate;
        public String unitName;
        public String projectName;
    }
    
    global class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public List<responseBodyWrapper> data = new list<responseBodyWrapper>();
        public Boolean success;
        public String Message;
    }
}