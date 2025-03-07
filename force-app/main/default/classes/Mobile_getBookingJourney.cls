@RestResource(urlMapping = '/getBookingJourney')
global class Mobile_getBookingJourney {

    @HttpPost
    global static void getBookingJourney(String bookingId){ 
        RestResponse res = RestContext.response; 
        String responseString = '';
        String errorMessage = '';
        try{ 
            ResponseBodyWrapper bookingJourneyWrapper = new ResponseBodyWrapper();
            List<Milestones> milestoneWrapper = new List<Milestones>();
            List<Mobile_getPaymentPlan.responseBodyWrapper> paymentBreakupList = new List<Mobile_getPaymentPlan.responseBodyWrapper>();
            if(bookingId != null && String.isNotBlank(bookingId)){
                List<Booking__c> bklst = [select id, Quotation__c, name,unit__r.name,unit__r.tower__r.name,unit__r.tower__r.Cluster__r.name,unit__r.Project__r.Name,Opportunity__r.Lead_Id__c,Due_Payments__c,BCC_Notice_Sent__c,PCC_Approved_By_Audit__c,Paid_Percentage__c,Current_Status__c,
                                       Opportunity__r.CreatedDate,Status__c,createddate,SPA_Executed_Date__c,SPA_Executed__c,SPA_Sent_Date__c,Date_of_Pre_registration_Completion__c,Pre_registration__c,Title_Transfer_Completed__c,(select id, name,Registration_Collection_Control_Report__c from Receipts__r)  
                                       from Booking__c where id =:bookingId ];
                //new add for getting applicant details
                List<Applicant_Details__c> applicantlst = [select id, Name from Applicant_Details__c  where Booking__r.id =:bookingId];
                String appNames=''; 
                if(applicantlst.size() > 0){
                    for(Applicant_Details__c applicant : applicantlst ){
                        appNames += applicant.Name + '|'; 
                    }
                    appNames = appNames.removeEnd('|');
                }

                // Title_Transfer_Date__c no field in QA but there is PROD
                if(bklst.size() > 0){
                    Map<String,String> customerDocWithId = getCustomerDocumentMap('Booking__c', bookingId);
                    Booking__c bookingRec = bklst[0];
                    UnitDetails  uwrap = new UnitDetails();
                    uwrap.bookingNumber = bookingRec.Name;
                    uwrap.unitNumber = bookingRec.unit__r.name;
                    uwrap.unitid = bookingRec.unit__r.Id;
                    uwrap.towerName = bookingRec.unit__r.tower__r.name;
                    uwrap.communityName = bookingRec.unit__r.tower__r.Cluster__r.name;
                    uwrap.masterCommunityName = bookingRec.unit__r.Project__r.Name;
                    uwrap.dueAmount = bookingRec.Due_Payments__c;
                    uwrap.applicantNames = appNames;
                    bookingJourneyWrapper.unitDetails = uwrap;   

                 /*   Milestones leadMilestone = new Milestones();
                    leadMilestone.heading = 'Lead';
                    leadMilestone.order = '1';
                    leadMilestone.currentStatus = 'Completed';
                    leadMilestone.statusDate = date.newinstance(bookingRec.Opportunity__r.createddate.year(), bookingRec.Opportunity__r.createddate.month(), bookingRec.Opportunity__r.createddate.day());
                    leadMilestone.documentLink = null;
                    milestoneWrapper.add(leadMilestone);*/

                    Milestones bookingForm = new Milestones();
                    bookingForm.heading = 'Booking Form';
                    bookingForm.order = '2';
                    bookingForm.currentStatus = (bookingRec.Current_Status__c == 'Audit Accepted' && bookingRec.Status__c != 'Cancelled') ? 'Completed' : bookingRec.Status__c == 'Cancelled' ? 'Cancelled' : 'In Progress' ;
                    bookingForm.statusDate = date.newinstance(bookingRec.createddate.year(), bookingRec.createddate.month(), bookingRec.createddate.day());
                    bookingForm.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('Booking Form') ? customerDocWithId.get('Booking Form') : null;
                    bookingForm.actionLink = null;
                    milestoneWrapper.add(bookingForm);
	
                    Milestones spaDocument = new Milestones(); 
                    spaDocument.heading = 'Sales & Purchase Agreement (SPA)';
                    spaDocument.order = '3';
                    spaDocument.currentStatus = bookingRec.SPA_Executed__c == 'Blocked Sales' || bookingRec.SPA_Executed__c == 'Revised SPA Particular Received - SPA Copy pending.' || bookingRec.SPA_Executed__c == 'SPA Issued But Not Sent' || bookingRec.SPA_Executed__c == 'SPA - issued but not sent to dispatch.' || bookingRec.SPA_Executed__c == 'SPA is Voided in Docusign' || bookingRec.SPA_Executed__c == 'Audit Rejected' || bookingRec.SPA_Executed__c == 'To Be Issued'? null : bookingRec.SPA_Executed__c == 'SPA Executed' || bookingRec.SPA_Executed__c == 'Executed copy send through DocuSign' ? 'Completed' : 'In Progress'; 
                    //spaDocument.statusDate = spaDocument.currentStatus == 'Completed' ? bookingRec.SPA_Executed_Date__c : bookingRec.SPA_Sent_Date__c != null ? bookingRec.SPA_Sent_Date__c : null;
                    spaDocument.statusDate = spaDocument.currentStatus == 'Completed' ? null : bookingRec.SPA_Sent_Date__c != null ? bookingRec.SPA_Sent_Date__c : null;
                    spaDocument.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('SPA') ? customerDocWithId.get('SPA') : null;
                    spaDocument.actionLink = null;
                    milestoneWrapper.add(spaDocument);

                    Milestones oqood = new Milestones();
                    oqood.heading = 'OQOOD Registration';
                    oqood.order = '4';
                    oqood.currentStatus = bookingRec.Pre_registration__c == 'Not Initiated' || bookingRec.Pre_registration__c == 'Additional Docs required' || bookingRec.Pre_registration__c == null ? null : bookingRec.Pre_registration__c == 'Completed' ? 'Completed' : 'In Progress';
                    oqood.statusDate = bookingRec.Date_of_Pre_registration_Completion__c != null ? date.newinstance(bookingRec.Date_of_Pre_registration_Completion__c.year(), bookingRec.Date_of_Pre_registration_Completion__c.month(), bookingRec.Date_of_Pre_registration_Completion__c.day())  : null;
                    oqood.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('OQOOD') ? customerDocWithId.get('OQOOD') : null;
                    milestoneWrapper.add(oqood);

                    Milestones payPlan = new Milestones();
                    payPlan.heading = 'Pay as per Payment Plan';
                    payPlan.order = '5';
                    milestoneWrapper.add(payPlan);
                    if(bookingRec.Quotation__c != null){
                        paymentBreakupList = Mobile_getPaymentPlan.getPaymentMilestones(bookingRec.Quotation__c);
                    }
                    
                    // 6. Building Completion Certificate pending discussion
					Milestones bcc = new Milestones();
					bcc.heading = 'Building Completion Certificate'; 
                    bcc.order = '6';
                    bcc.currentStatus = bookingRec.BCC_Notice_Sent__c ? 'Completed' : null;
                    bcc.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('Building Completion Certificate') ? customerDocWithId.get('Building Completion Certificate') : null;
					milestoneWrapper.add(bcc); 
                    
                    List<Time_Slot_For_Handover__c> homeOrientationRec = [Select id, RecordType.Name, Status__c, Scheduled_Date__c, Timings__c, createddate  from Time_Slot_For_Handover__c where Booking__c = :bookingId and recordType.Name = 'Home Orientation' order by createddate desc];
                    
                    if(homeOrientationRec != null && homeOrientationRec.size() > 0){
                         Milestones homeOrc = new Milestones();
                         homeOrc.heading = 'Home Orientation';
                         homeOrc.order = '7';
                         String tempstatus = '';
                        Date tempDate = null;
                         String timing = '';
                        for(Time_Slot_For_Handover__c homeOrientation : homeOrientationRec ){
                            if(homeOrientation.Status__c == 'Completed'){
                                tempstatus = 'Completed';
                                tempDate = homeOrientation.Scheduled_Date__c;
                                timing = homeOrientation.Timings__c;
                                break;
                            }else if(homeOrientation.Status__c == 'Confirmed'){
                                tempDate = homeOrientation.Scheduled_Date__c;
                                timing = homeOrientation.Timings__c;
                                tempstatus = 'In Progress';
                                break;
                            }else{
                                tempDate = date.newinstance(homeOrientation.createddate.year(), homeOrientation.createddate.month(), homeOrientation.createddate.day());  
                                tempstatus = 'Booking Allowed';                            
                            }
                        }
   							                    
                        homeOrc.currentStatus = tempstatus;
                        homeOrc.statusDate = tempDate;
                       // handover.currentStatus = handoverRec.Status__c == 'Cancelled' ? 'Cancelled' : handoverRec.Status__c == 'Completed' ? 'Completed' : handoverRec.Status__c == 'None' || handoverRec.Status__c == null ? 'Booking Allowed' : 'In Progress';
                       // homeOrc.statusDate = homeOrc.Scheduled_Date__c != null ? homeOrc.Scheduled_Date__c :null;
                        homeOrc.documentLink = timing;
                        milestoneWrapper.add(homeOrc);
                    } else {
                        Milestones homeOrt = new Milestones();
                        homeOrt.heading = 'Home Orientation';
                        homeOrt.order = '7';
                        
                        homeOrt.currentStatus = null;
                        homeOrt.statusDate = null;
                        homeOrt.documentLink = null;
                        milestoneWrapper.add(homeOrt);
                    }
                    
                   // Milestones pcc = new Milestones();
                  //  pcc.heading = 'Payment Completion Certificate';
                  //  pcc.order = '10';
                  //  pcc.currentStatus = bookingRec.Paid_Percentage__c == 100 && bookingRec.PCC_Approved_By_Audit__c  ? 'Completed' : bookingRec.Paid_Percentage__c == 100 && bookingRec.PCC_Approved_By_Audit__c == false ? 'In progress' : null;
                  //  pcc.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('Payment Completion Certificate') ? customerDocWithId.get('Payment Completion Certificate') : null;
                   // milestoneWrapper.add(pcc);

                    List<Time_Slot_For_Handover__c> handOverRec = [Select id, RecordType.Name, Status__c, Scheduled_Date__c, Timings__c, createddate from Time_Slot_For_Handover__c where Booking__c = :bookingId and recordType.Name = 'HandOver' order by createddate desc];
                    
                    if(handOverRec != null && handOverRec.size() > 0){
                         Milestones handOver = new Milestones();
                         handOver.heading = 'Handover';
                         handOver.order = '9';
                         String tempstatus = '';
                        Date tempDate = null;
                         String timing = '';
                        for(Time_Slot_For_Handover__c handrec : handOverRec ){
                            if(handrec.Status__c == 'Completed'){
                                tempstatus = 'Completed';
                                tempDate = handrec.Scheduled_Date__c;
                                timing = handrec.Timings__c;
                                break;
                            }else if(handrec.Status__c == 'Confirmed'){
                             	tempDate = handrec.Scheduled_Date__c;
                                timing = handrec.Timings__c;
                                tempstatus = 'In progress';
                                break;
                            }else{
                                tempDate = date.newinstance(handrec.createddate.year(), handrec.createddate.month(), handrec.createddate.day());  
                                tempstatus = 'Booking Allowed';                               
                            }
                        }
   							                    
                        handOver.currentStatus = tempstatus;
                        handOver.statusDate = tempDate;
                       // handover.currentStatus = handoverRec.Status__c == 'Cancelled' ? 'Cancelled' : handoverRec.Status__c == 'Completed' ? 'Completed' : handoverRec.Status__c == 'None' || handoverRec.Status__c == null ? 'Booking Allowed' : 'In Progress';
                       // homeOrc.statusDate = homeOrc.Scheduled_Date__c != null ? homeOrc.Scheduled_Date__c :null;
                        handOver.documentLink = timing;
                        milestoneWrapper.add(handOver);
                    } else{
                        Milestones handover = new Milestones();
                        handover.heading = 'Handover';
                        handover.order = '9';
                        handover.currentStatus = null;
                        handover.statusDate = null;
                        handover.documentLink = null;
                        milestoneWrapper.add(handover);
                    }

                    // 8. handover notice is a manual process   
                    Milestones titleDeed = new Milestones();
                    titleDeed.heading = 'Title Deed';
                    titleDeed.order = '11';
                    titleDeed.currentStatus = bookingRec.Title_Transfer_Completed__c == 'Not Initiated' ? null : bookingRec.Title_Transfer_Completed__c == 'Completed' ? 'Completed' : 'In progress';
                    titleDeed.documentLink = customerDocWithId.size() > 0 && customerDocWithId.containsKey('Title Deed') ? customerDocWithId.get('Title Deed') : null;
                    milestoneWrapper.add(titleDeed);
                    bookingJourneyWrapper.milestones = milestoneWrapper;
                    bookingJourneyWrapper.paymentBreakup = paymentBreakupList;
                    //return prepareResponse(bookingJourneyWrapper,'Operation Successfull','Success',200,true);
                    responseString = (prepareResponse(bookingJourneyWrapper,'Operation Successfull','Success',200,true)).toString().replace('"','');
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(bookingJourneyWrapper,'Operation Successfull','Success',200,true)));
                    res.statusCode = 200;
                }
                else{
                    // return prepareResponse(null,'No data found','No Data Found',400,false);
                    res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'No Data Found','Error',400,false)));
                    res.statusCode = 400;
                }        
            }
         }
        catch(Exception ex){
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('getBookingJourney','Mobile_getBookingJourney',bookingId,responseString,errorMessage,res.statusCode);
    }

    global class ResponseBodyWrapper{
        UnitDetails unitDetails;
        List<Milestones> milestones;
        List<Mobile_getPaymentPlan.responseBodyWrapper> paymentBreakup;
    }

    global class UnitDetails{
        String bookingNumber;
        String unitNumber;
        String unitid;
        String towerName;
        String communityName;
        String masterCommunityName;
        Decimal dueAmount;
        String applicantNames;
    }

    public class Milestones{
        public String heading;
        public String order;
        public String currentStatus;
        public Date statusDate;
        public String documentLink;
        public String actionLink;
    }

    public class PaymentBreakup{
        public String name;
        public String description;
        public String amount;
        public Date dueDate;
        public String installment;
        public Decimal chargePercent;
    }

    Public static HttpResponseWrapper prepareResponse(ResponseBodyWrapper rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody; 
        resWrap.message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }

    global class HttpResponseWrapper{
        String status;
        Integer statusCode;
        ResponseBodyWrapper data = new ResponseBodyWrapper();
        boolean success;
        String message;
    }

    public static Map<String,String> getCustomerDocumentMap(String objectName, String relatedId){
        Map<String,String> customerDocWithIdMap = new Map<String,Id>();
        List<Customer_Related_Document__c> customerDocsList = new List<Customer_Related_Document__c>();
        String queryString = 'Select id, Active__c, Booking__c, File_Name__c, DocumentId__c from Customer_Related_Document__c';
        if(objectName != null && relatedId != null){
            queryString += ' Where '+objectName+ ' = :relatedId and Active__c = true';
        }
        customerDocsList = Database.query(queryString);
        if(customerDocsList.size() > 0){
            for(Customer_Related_Document__c custDocRec : customerDocsList){
                customerDocWithIdMap.put(custDocRec.File_Name__c,custDocRec.DocumentId__c);
            }
        }
        return customerDocWithIdMap;
    }

}