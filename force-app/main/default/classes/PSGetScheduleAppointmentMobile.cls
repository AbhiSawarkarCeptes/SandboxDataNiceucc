@RestResource(urlMapping = '/V1/PS/getScheduleAppointment')
global class PSGetScheduleAppointmentMobile {
    @HttpPost
    global static HttpResponseWrapper getPaymentReceipts(String bookingId,String apntType,String scheduleDate,String timing,String remarks){
        HttpResponseWrapper wrap = new HttpResponseWrapper();
        RestRequest req = RestContext.request;
        try{
            if(!String.isBlank(apntType)) {
                if(!String.isBlank(bookingId)) {
                    List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,QT_Keep_out_Date__c,Slot_Remarks__c,Home_Orientation_Remark__c,
                                                                              PropStrength__Primary_Customer__c
                                                                              FROM PropStrength__Application_Booking__c
                                                                              WHERE Id =: bookingId]; 
                    if(!bookingList.isEmpty()) {
                        if(apntType == 'Home Orientation') {
                            bookingList[0].Home_Orientation_Date__c =  Date.valueOf(scheduleDate);
                            bookingList[0].Home_Orientation_Time__c = timing;
                            bookingList[0].Home_Orientation_Slot_Status__c = 'Not yet scheduled';
                            if(bookingList[0].Home_Orientation_Remark__c != null){
                                bookingList[0].Home_Orientation_Remark__c += remarks;
                            }else{
                                bookingList[0].Home_Orientation_Remark__c = remarks;
                            }
                            update bookingList;
                            if(bookingList[0].Id != null) {
                                PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
                                sr.RecordtypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
                                sr.PropStrength__Request_Origin__c = 'Mobile App';
                                sr.SR_Department__c = 'CRM';
                                sr.PropStrength__Priority__c = 'Medium';
                                sr.SR_Category__c = 'Home Orientation';
                                sr.SR_Sub_Category__c = 'Slot Request';
                                sr.PropStrength__Application_Booking__c = bookingList[0].Id;
                                sr.PropStrength__Status__c = 'New';
                                sr.Contact__c = bookingList[0].PropStrength__Primary_Customer__c;
                                insert sr;
                                wrap = prepareResponse(null,'Successfully Updated','Successfully Updated',200,true);
                                
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = 'Successfully Updated';
                                logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';
                                logError.API_Name__c = '/services/apexrest/getScheduleAppointment';
                                logError.Status__c = '200';
                                //logError.Request_Body__c = JSON.serialize(jsonString);
                                insert logError;
                            } else {
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = 'Update Booking Issue';logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';
                                logError.API_Name__c = '/services/apexrest/getScheduleAppointment';logError.Status__c = '400';insert logError;
                            }
                        } else if(apntType == 'HandOver') {
                            String formattedScheduleDate = scheduleDate;
                            if (formattedScheduleDate.length() == 10) {
                                formattedScheduleDate += ' 00:00:00';
                            }
                            DateTime scheduledDateTime = DateTime.valueOf(formattedScheduleDate);
                            bookingList[0].Slot_Scheduled_Date__c =  scheduledDateTime;
                            bookingList[0].Timings__c = timing;
                            bookingList[0].Slot_Status__c = 'Not yet scheduled';
                            if(bookingList[0].Slot_Remarks__c != null){
                                bookingList[0].Slot_Remarks__c += remarks;
                            }else{
                                bookingList[0].Slot_Remarks__c = remarks;
                            }
                            update bookingList;
                            if(bookingList[0].Id != null) {
                                PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
                                sr.RecordtypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
                                sr.PropStrength__Request_Origin__c = 'Mobile App';
                                sr.SR_Department__c = 'CRM';
                                sr.SR_Category__c = 'HandOver';
                                sr.SR_Sub_Category__c = 'Slot Request';
                                sr.PropStrength__Priority__c = 'Medium';
                                sr.PropStrength__Application_Booking__c = bookingList[0].Id;
                                sr.PropStrength__Status__c = 'New';
                                sr.Contact__c = bookingList[0].PropStrength__Primary_Customer__c;
                                insert sr;
                                wrap = prepareResponse(null,'Successfully Updated','Successfully Updated',200,true);
                            } else {
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();logError.Response_Body__c = 'Update Booking Issue';logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';logError.API_Name__c = '/services/apexrest/getScheduleAppointment';logError.Status__c = '400';insert logError;
                            }
                        }
                    } else {
                        wrap = prepareResponse(null,'You cannot book the appointment. Please contact 800SOBHA','Booking Already Confirmed',200,false);
                        Mobile_App_Log__c logError = new Mobile_App_Log__c();
                        logError.Response_Body__c = 'Booking Already Confirmed';
                        logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';
                        logError.API_Name__c = '/services/apexrest/getScheduleAppointment';
                        logError.Status__c = '400';
                        //logError.Request_Body__c = JSON.serialize(jsonString);
                        insert logError;
                    }
                } 
            } else {
                wrap = prepareResponse(null,'Please contact SOBHA','apntType is Blank',400,false);
                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                logError.Response_Body__c = 'apntType is Blank';
                logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';
                logError.API_Name__c = '/services/apexrest/getScheduleAppointment';
                logError.Status__c = '400';
                //logError.Request_Body__c = JSON.serialize(jsonString);
                insert logError;
            }
        } catch (Exception ex) {
            wrap = prepareResponse(null,ex.getMessage(),'Error',400,false);
            Mobile_App_Log__c logError = new Mobile_App_Log__c();
            logError.Response_Body__c = ex.getMessage();
            logError.Class_Name__c = 'PSGetScheduleAppointmentMobile';
            logError.API_Name__c = '/services/apexrest/getScheduleAppointment';
            logError.Status__c = '400';
            //logError.Request_Body__c = JSON.serialize(jsonString);
            insert logError;
        }
        return wrap;
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