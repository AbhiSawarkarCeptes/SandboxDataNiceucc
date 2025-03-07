global class PSGetBookingJourneyMobileHelper {
    global Static String GetBookingJourneyMobile(RestRequest request) {
        String responce = '';
        String status = '';
        String jsonString = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                jsonString = request.requestBody.toString();
                try {
                    String appNames = '';
                    PSGetApplicantDetailMobilePOJO allApplicantDetail = (PSGetApplicantDetailMobilePOJO) JSON.deserialize(jsonString, PSGetApplicantDetailMobilePOJO.class);
                    if(allApplicantDetail != null) {
                        if(!String.isBlank(allApplicantDetail.bookingId)) {
                            List<PropStrength__Application_Booking__c> appList = [SELECT Id,Name,createddate,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Status__c,
                                                                                  SPA_Status__c,SPA_Execution_Date__c,Pre_Registration_Status__c,BCC_Notice_Sent__c,PCC_Status__c,PCC_Document_Approved_by_Audit_Date__c,
                                                                                  PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,PropStrength__Project__r.Name,Title_Deed_Status__c,Title_Deed_Transfer_Executed__c,
                                                                                  Home_Orientation_Slot_Status__c,Handover_Notice_Sent__c,Handover_Completed__c,Slot_Status__c,
                                                                                  PropStrength__Project__r.Master_Project__r.Name,PropStrength__Total_Payment_Due__c,
                                                                                  (SELECT Id,Name,PropStrength__Applicant_Acc__r.Name
                                                                                   FROM PropStrength__Applicant_Details__r WHERE PropStrength__Type__c =: '1st Applicant'),
                                                                                  (SELECT Id,Name,Installment__c,PropStrength__Amount_Percent__c,PropStrength__Payment_Due_Date__c,PropStrength__Total_Amount_Due_with_Service_Tax__c,
                                                                                   PropStrength__Total_Amount_Due__c,PropStrength__Milestone_Name__c,Booking_Status__c,PropStrength__Balance__c,
                                                                                   PropStrength__Milestone__r.PropStrength__Milestone_Name__c
                                                                                   FROM PropStrength__Payment_Plan_Details__r)
                                                                                  FROM PropStrength__Application_Booking__c
                                                                                  WHERE Id =: allApplicantDetail.bookingId];
                            if(!appList.isEmpty()) {
                                system.debug('appList::'+appList);
                                gen.writeStartObject();
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('message', 'Operation Successful');
                                gen.writeFieldName('data');
                                gen.writeStartObject();
                                for(PropStrength__Application_Booking__c book : appList) {
                                    gen.writeFieldName('unitDetails');
                                    gen.writeStartObject();
                                    gen.writeStringField('unitNumber', !String.isBlank(book.PropStrength__Property__r.PropStrength__Property_Name__c) ? book.PropStrength__Property__r.PropStrength__Property_Name__c : '');
                                    gen.writeStringField('dueAmount', book.PropStrength__Total_Payment_Due__c != null ? String.valueOf(book.PropStrength__Total_Payment_Due__c) : '0.00');
                                    gen.writeStringField('bookingNumber',Book.Name);
                                    gen.writeStringField('unitid', !String.isBlank(book.PropStrength__Property__c) ? book.PropStrength__Property__c : '');
                                    gen.writeStringField('towerName', !String.isBlank(book.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c) ? book.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c : '');
                                    gen.writeStringField('masterCommunityName', !String.isBlank(book.PropStrength__Project__r.Master_Project__r.Name) ? book.PropStrength__Project__r.Master_Project__r.Name : '');
                                    gen.writeStringField('communityName', !String.isBlank(book.PropStrength__Project__r.Name) ? book.PropStrength__Project__r.Name : '');
                                    if(book.PropStrength__Applicant_Details__r.size() > 0) {
                                        for(PropStrength__Applicant_Detail__c applicant : book.PropStrength__Applicant_Details__r) {
                                            appNames = applicant.PropStrength__Applicant_Acc__r.Name;
                                        }
                                    }
                                    gen.writeStringField('applicantNames', (appNames != null && appNames != '') ? appNames : '');
                                    gen.writeEndObject();
                                    // paymentBreakup Start
                                    gen.writeFieldName('paymentBreakup');
                                    gen.writeStartArray();
                                    if(book.PropStrength__Payment_Plan_Details__r.size() > 0) {
                                        for(PropStrength__Payment_Plan_Details__c appDetail : book.PropStrength__Payment_Plan_Details__r) {
                                            gen.writeStartObject();
                                            if(appDetail.PropStrength__Total_Amount_Due__c == appDetail.PropStrength__Balance__c) {
                                                gen.writeStringField('paymentStatus', 'Unpaid');
                                            } else if(appDetail.PropStrength__Balance__c == 0) {
                                                gen.writeStringField('paymentStatus', 'Paid');
                                            } else {
                                                gen.writeStringField('paymentStatus', 'In Progress');
                                            }
                                            gen.writeStringField('name', !String.isBlank(appDetail.Name) ? appDetail.Name : '');
                                            gen.writeStringField('installment', appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Name__c != null ? appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Name__c : '');
                                            gen.writeStringField('amount', appDetail.PropStrength__Total_Amount_Due_with_Service_Tax__c!= null ? String.valueOf(appDetail.PropStrength__Total_Amount_Due_with_Service_Tax__c) : '');
                                            gen.writeStringField('description', appDetail.PropStrength__Milestone_Name__c != null ? appDetail.PropStrength__Milestone_Name__c : '');
                                            gen.writeStringField('dueDate', appDetail.PropStrength__Payment_Due_Date__c != null ? String.valueOf(Date.newinstance(appDetail.PropStrength__Payment_Due_Date__c.year(), appDetail.PropStrength__Payment_Due_Date__c.month(), appDetail.PropStrength__Payment_Due_Date__c.day())) : '');
                                            gen.writeNumberField('chargePercent', appDetail.PropStrength__Amount_Percent__c != null ? appDetail.PropStrength__Amount_Percent__c : 0.00);
                                            gen.writeEndObject();
                                        }
                                    }
                                    gen.writeEndArray();
                                    // milestones Start
                                    gen.writeFieldName('milestones');
                                    gen.writeStartArray();
                                    gen.writeStartObject();
                                    gen.writeStringField('statusDate', String.valueOf(date.newinstance(book.createddate.year(), book.createddate.month(), book.createddate.day())));
                                    gen.writeStringField('order', '2');
                                    gen.writeStringField('heading', 'Booking Form');
                                    gen.writeNullField('documentLink');
                                    gen.writeStringField('currentStatus', (book.PropStrength__Status__c == 'Audit Approved' && book.PropStrength__Status__c != 'Cancelled') ? 'Completed' : book.PropStrength__Status__c == 'Booking_Cancelled' ? 'Cancelled' : 'In Progress');
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '3');
                                    gen.writeStringField('heading', 'Sales & Purchase Agreement (SPA)');
                                    if(!String.isBlank(book.SPA_Status__c)) {
                                        if((book.SPA_Status__c == 'To be Issued' || book.SPA_Status__c == 'Blocked Sales' ||
                                            book.SPA_Status__c == 'Audit rejected' || book.SPA_Status__c == 'SPA is Voided in Docusign' ||
                                            book.SPA_Status__c == 'SPA - issue but not sent to dispatch' || book.SPA_Status__c == 'SPA Issued But Not Sent' || 
                                            book.SPA_Status__c == 'Revised SPA Particular Received - SPA Copy Pending')) {
                                                gen.writeNullField('currentStatus'); 
                                            } else {
                                                gen.writeStringField('currentStatus', ((book.SPA_Status__c == 'SPA Executed' || 
                                                                                        book.SPA_Status__c == 'Executed copy send through DocuSign') ? 'Completed' : 'In Progress'));
                                            } 
                                     } else {
                                        gen.writeNullField('currentStatus');                        
                                     }
                                    gen.writeNullField('documentLink');
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '4');
                                    gen.writeStringField('heading', 'OQOOD Registration');
                                    if(!String.isBlank(book.Pre_Registration_Status__c)) {
                                       gen.writeStringField('currentStatus', ((book.Pre_Registration_Status__c == 'Request Completed') ? 'Completed' : 'In Progress')); 
                                     } else {
                                        gen.writeNullField('currentStatus');                        
                                     }
                                    gen.writeNullField('documentLink');
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '5');
                                    gen.writeStringField('heading', 'Pay as per Payment Plan');
                                    gen.writeNullField('documentLink');
                                    gen.writeNullField('currentStatus');
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '6');
                                    gen.writeStringField('heading', 'Building Completion Certificate');
                                    gen.writeNullField('documentLink');
                                    if(book.BCC_Notice_Sent__c) {
                                        gen.writeStringField('currentStatus','Completed');
                                    } else {
                                        gen.writeNullField('currentStatus');
                                    }
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '7');
                                    gen.writeStringField('heading', 'Home Orientation');
                                    gen.writeNullField('documentLink');
                                    if(!String.isBlank(book.Home_Orientation_Slot_Status__c)) {
                                        if(book.Home_Orientation_Slot_Status__c == 'Booking Allowed') {
                                            gen.writeStringField('currentStatus', 'Booking Allowed');
                                        } else if(book.Home_Orientation_Slot_Status__c == 'Completed') {
                                            gen.writeStringField('currentStatus', 'Completed');
                                        } else if(book.Home_Orientation_Slot_Status__c == 'Confirmed') {
                                            gen.writeStringField('currentStatus', 'In Progress');
                                        } else {
                                            gen.writeNullField('currentStatus');                        
                                        }
                                     } else {
                                        gen.writeNullField('currentStatus');                        
                                     }
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    /*gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '10');
                                    gen.writeStringField('heading', 'Payment Completion Certificate');
                                    gen.writeNullField('documentLink');
                                    if(!String.isBlank(book.PCC_Status__c)) {
                                        if(book.PCC_Status__c == 'PCC Approved' && book.PCC_Document_Approved_by_Audit_Date__c != null) {
                                            gen.writeStringField('currentStatus','Completed');
                                        } else if(book.PCC_Status__c == 'PCC Approved' && book.PCC_Document_Approved_by_Audit_Date__c == null) {
                                            gen.writeStringField('currentStatus','In progress');
                                        } else {
                                            gen.writeNullField('currentStatus');                        
                                        }
                                    } else {
                                        gen.writeNullField('currentStatus');
                                    }
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();*/
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '9');
                                    gen.writeStringField('heading', 'Handover');
                                    gen.writeNullField('documentLink');
                                    if(!String.isBlank(book.Slot_Status__c)) {
                                        if(book.Slot_Status__c == 'Booking Allowed') {
                                            gen.writeStringField('currentStatus','Booking Allowed');
                                        } else if(book.Slot_Status__c == 'Completed') {
                                            gen.writeStringField('currentStatus','Completed');
                                        } else if(book.Slot_Status__c == 'Confirmed') {
                                            gen.writeStringField('currentStatus','In Progress');
                                        } else {
                                            gen.writeNullField('currentStatus');                        
                                        }
                                    } else {
                                        gen.writeNullField('currentStatus');
                                    }
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    
                                    gen.writeStartObject();
                                    gen.writeNullField('statusDate');
                                    gen.writeStringField('order', '11');
                                    gen.writeStringField('heading', 'Title Deed');
                                    gen.writeNullField('documentLink');
                                    //gen.writeStringField('currentStatus',book.Title_Deed_Status__c == null ? null : (book.Title_Deed_Status__c == 'Request Completed' && book.Title_Deed_Transfer_Executed__c) ? 'Completed' : 'In progress');
                                    if(!String.isBlank(book.Title_Deed_Status__c)) {
                                        gen.writeStringField('currentStatus', ((book.Title_Deed_Status__c == 'Request Completed') ? 'Completed' : 'In Progress')); 
                                    } else {
                                        gen.writeNullField('currentStatus');                        
                                    }
                                    gen.writeNullField('actionLink');
                                    gen.writeEndObject();
                                    gen.writeEndArray();
                                }
                                gen.writeEndObject();
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                system.debug('responce 159::'+responce);
                                status = '200';
                            } 
                            else {
                                gen.writeStartObject();     
                                gen.writeStringField('success', 'false');
                                gen.writeStringField('status', 'Error');
                                gen.writeStringField('Message', 'No data found');
                                gen.writeStringField('statusCode', '400');
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                status = '400';
                            }
                        } 
                        else {
                            gen.writeStartObject();     
                            gen.writeStringField('success', 'false');
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'Bookind Id is Required.');
                            gen.writeStringField('statusCode', '400');
                            gen.writeEndObject();
                            responce = gen.getAsString();
                            system.debug('responce 181::'+responce);
                            status = '400';
                        }
                    }
                }
                catch(Exception e) {
                    gen.writeStartObject();     
                    gen.writeStringField('success', 'false');
                    gen.writeStringField('status', 'Error');
                    gen.writeStringField('Message', String.valueOf(e.getMessage()));
                    gen.writeStringField('statusCode', '400');
                    gen.writeEndObject();
                    responce = gen.getAsString();
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                    status = '400';
                }
            }
        Mobile_App_Log__c logError = new Mobile_App_Log__c();
        logError.Request_Body__c = JSON.serialize(jsonString);
        logError.Response_Body__c = responce;
        logError.Class_Name__c = 'PSGetBookingJourneyMobileHelper';
        logError.API_Name__c = '/services/apexrest/getBookingJourney/';
        logError.Status__c = status;
        insert logError;
        return responce;
    }
}