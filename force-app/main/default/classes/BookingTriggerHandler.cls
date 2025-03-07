public class BookingTriggerHandler {
    
    @future(callOut=true)
    Public static void sendToMobileAPI(string newBookingString, string oldBookingString,boolean isInsert){
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/bookings';
        string methodType = 'POST';
        list<Booking__c> newList = (list<Booking__c>)JSON.deserialize(newBookingString, list<Booking__c>.Class);
        String errorMessage = '';
        String requestString = '';
        string response = '';
        Integer statusCode;
        String bookingId = '';
        requestBodyWrapper wrap;
        boolean spaExecuted = false;
        boolean spaExecuteddocSign = false;
        String notificationStatus = '';
        Map<Id,Id> unitWithBookingMap = new Map<Id,Id>();
        Map<Id,requestBodyWrapper> wrapMap =  new Map<Id,requestBodyWrapper>();
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        Boolean sendAlert = false;
        Boolean sendmessage = false;
        Boolean isApplicantBlank = false;
        try{
            for(Booking__c bk :newList){
                unitWithBookingMap.put(bk.Unit__c, bk.Id);
                wrap = new requestBodyWrapper();
                if(oldBookingString != null){
                    Map<Id,Booking__c> oldMap = (Map<Id,Booking__c>)JSON.deserialize(oldBookingString, Map<Id,Booking__c>.Class);
                    wrap.bookingID = bk.Id;
                    wrap.bookingName = bk.Name;
                    wrap.bookingStatus = bk.Status__c != null ? bk.Status__c : String.ValueOf(oldMap.get(bk.Id).Status__c);
                    wrap.customerName = bk.Primary_Applicant_Name__c != null ? bk.Primary_Applicant_Name__c : String.ValueOf(oldMap.get(bk.Id).Primary_Applicant_Name__c);
                    wrap.customerEmail = bk.Primary_Applicant_Email__c != null ? bk.Primary_Applicant_Email__c : String.ValueOf(oldMap.get(bk.Id).Primary_Applicant_Email__c);
                    wrap.handoverDate = bk.Handover_Date__c != null ? bk.Handover_Date__c : oldMap.get(bk.Id).Handover_Date__c;
                    wrap.sfUnitId = bk.Unit__c;
                    
                    if(bk.SPA_Executed__c != oldMap.get(bk.Id).SPA_Executed__c){
                        
                        if(bk.SPA_Executed__c == 'SPA Sent through Docusign'){ 
                            sendAlert = true;
                            notificationStatus = 'SPA_readiness_customer_signature';
                        }else if (bk.SPA_Executed__c == 'SPA Executed'){ 
                            sendAlert = true;
                            notificationStatus = 'completion_SPA_approval';
                        }
                    }
                    if(bk.Current_Status__c != oldMap.get(bk.Id).Current_Status__c && bk.Current_Status__c == 'Sent to Client'){
                        notificationStatus = 'booking_form_readiness_for_the_customer_signature';
                        sendAlert = true;
                    }
                    if(bk.Booking_Approver_Audit__c != oldMap.get(bk.Id).Booking_Approver_Audit__c && bk.Booking_Approver_Audit__c == 'Accepted'){
                        notificationStatus = 'completion_booking_approval';
                        sendmessage = true;
                    }
                    if(bk.Pre_registration__c != oldMap.get(bk.Id).Pre_registration__c && bk.Pre_registration__c == 'Completed'){
                        notificationStatus = 'document_available_user_after_final_approval';
                        sendmessage = true;
                    }
                    if(bk.Status__c != oldMap.get(bk.Id).Status__c && bk.Status__c == 'Cancelled'){
                        notificationStatus = 'rejection_booking_form_approval';
                        sendAlert = true;
                    }
                    if(bk.BCC_Notice_Sent__c != oldMap.get(bk.Id).BCC_Notice_Sent__c && bk.BCC_Notice_Sent__c == True){
                        notificationStatus = 'building_completion_certificate_document';
                        sendmessage = true;
                    }
                    if(bk.Title_Transfer_Completed__c != oldMap.get(bk.Id).Title_Transfer_Completed__c && bk.Title_Transfer_Completed__c == 'Completed'){
                        notificationStatus = 'readiness_title_deed';
                        sendmessage = true;
                    }
                    
                }else{
                    
                    if(bk.Id != null){
                        wrap.bookingID = bk.Id;
                    }
                    if(bk.name != null){
                        wrap.bookingName = bk.name;
                    }
                    if(bk.Status__c != null){
                        wrap.bookingStatus = bk.Status__c;
                    }
                    if(bk.Primary_Applicant_Name__c != null){
                        wrap.customerName = bk.Primary_Applicant_Name__c;
                    }
                    if(bk.Primary_Applicant_Email__c != null){
                        wrap.customerEmail = bk.Primary_Applicant_Email__c;
                    }
                    else{
                        isApplicantBlank = true;
                    }
                    if(bk.Handover_Date__c != null){
                        wrap.handoverDate = bk.Handover_Date__c;
                    }
                    wrap.actualHandoverDate = null; 
                    if(bk.Unit__c != null){
                        wrap.sfUnitId = bk.Unit__c;
                    }
                }
                wrapMap.put(bk.Id,wrap);
            }
            if(unitWithBookingMap.size() > 0){
                for(Unit__c unitinfo : [select Id, DLP_End_Date__c from Unit__c where id IN :unitWithBookingMap.keySet()]){
                    wrapMap.get(unitWithBookingMap.get(unitinfo.Id)).dlpDate = unitinfo.DLP_End_Date__c != null ? unitinfo.DLP_End_Date__c : null;
                }
                for(Time_Slot_For_Handover__c timeslot : [select Scheduled_Date__c,Booking__c from Time_Slot_For_Handover__c where Booking__c IN :unitWithBookingMap.values() and Status__c = 'Completed' AND RecordType.Name='HandOver']){
                    wrapMap.get(timeslot.Booking__c).actualHandoverDate = timeslot.Scheduled_Date__c != null ? timeslot.Scheduled_Date__c : null;
                }
                if(isApplicantBlank){
                    for(Applicant_Details__c applicantRec : [select id, Name, Booking__c,Email_Address__c from Applicant_Details__c  where Booking__r.id IN :unitWithBookingMap.values() and Applicant_Number__c = 'Primary Applicant']){
                        wrapMap.get(applicantRec.Booking__c).customerEmail = applicantRec.Email_Address__c;
                        wrapMap.get(applicantRec.Booking__c).customerName = applicantRec.Name;
                    }
                }
                for(Id bkgId : wrapMap.keySet()){
                    wraplst.add(wrapMap.get(bkgId));
                }
            }         
            if(wraplst != null){
                String userResponse=null;
                response = callbookingAPI(wraplst, isInsert, sendAlert, sendmessage, notificationStatus);
                
            }
        }catch(Exception e){
            errorMessage = e.getMessage();
            statusCode = 400;
            
        }
        
    }
    
    public static String callbookingAPI(List<requestBodyWrapper> wraplst, Boolean isInsert, Boolean sendAlert, Boolean sendmessage, String notificationStatus){
        String response = '';
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/bookings';
        string methodType = 'POST';
        // code added by Roshan
        if(wraplst[0].customerEmail==null && wraplst[0].customerName==null)
        {
            return null;
        }
        //end 
        response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
        
        if(response != null && response != '' && isInsert){ 
            ID jobID = System.enqueueJob(new MobileAppQueuable(new List<String>{wraplst[0].bookingID},wraplst[0].customerEmail,'unit_booking_confirmation','message'));
        }else if(response != null && sendAlert){ 
            ID jobID = System.enqueueJob(new MobileAppQueuable(new List<String>{wraplst[0].bookingID},wraplst[0].customerEmail,notificationStatus,'alert'));
        }
        else if(response != null && sendmessage){
            ID jobID = System.enqueueJob(new MobileAppQueuable(new List<String>{wraplst[0].bookingID},wraplst[0].customerEmail,notificationStatus,'message'));
        }
        return response;
    }
    
    
    public class requestBodyWrapper{
        String bookingID;
        String bookingStatus;
        String bookingName;
        String customerName;
        String customerEmail;
        Date handoverDate;
        Date actualHandoverDate;
        String sfUnitId;
        Date dlpDate;
    }
    
}