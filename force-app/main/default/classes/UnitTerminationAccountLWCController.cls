public without sharing class  UnitTerminationAccountLWCController {
    
    
    @AuraEnabled
    public static List<BookingWrapper> bookingListWithOverDue(String projectId,String towerId,List<String> terminationStatus) {
        Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPPD = new Map<String,List<PropStrength__Payment_Plan_Details__c>>();
        Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>();
        if (towerId != 'All') {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                            PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c
                            ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,
                            PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                            Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved' 
                            and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId and PropStrength__Property__r.PropStrength__Tower__c =: towerId  and Termination_Process_Status__c in: terminationStatus]);
        } else {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                            PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c
                            ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,
                            PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                            Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved'  
                            and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId  and Termination_Process_Status__c in: terminationStatus]);
            
        }
        
        if (towerId != 'All') {
        Date finalPymtDt;
        for(PropStrength__Payment_Plan_Details__c paymentPlanDetail : [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND PropStrength__Application_Booking__c in:bookingMap.keySet()] ) {
                        if(!bookingToPPD.containsKey(paymentPlanDetail.PropStrength__Application_Booking__c)) {
                            bookingToPPD.put(paymentPlanDetail.PropStrength__Application_Booking__c, new List<PropStrength__Payment_Plan_Details__c>{paymentPlanDetail});
                        } else {
                            finalPymtDt = bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c)[0].PropStrength__Final_Payment_Date__c;
                            if(finalPymtDt == null && paymentPlanDetail.PropStrength__Final_Payment_Date__c != null) {
                                bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c).set(0, paymentPlanDetail);
                            } else if(finalPymtDt != null && paymentPlanDetail.PropStrength__Final_Payment_Date__c != null && paymentPlanDetail.PropStrength__Final_Payment_Date__c > finalPymtDt) {
                                bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c).set(0, paymentPlanDetail);
                            }
                        }
                    } 
        } else{
        Date finalPymtDt;
        for(PropStrength__Payment_Plan_Details__c paymentPlanDetail : [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND PropStrength__Application_Booking__c in:bookingMap.keySet()] ) {
                        if(!bookingToPPD.containsKey(paymentPlanDetail.PropStrength__Application_Booking__c)) {
                            bookingToPPD.put(paymentPlanDetail.PropStrength__Application_Booking__c, new List<PropStrength__Payment_Plan_Details__c>{paymentPlanDetail});
                        } else {
                            finalPymtDt = bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c)[0].PropStrength__Final_Payment_Date__c;
                            if(finalPymtDt == null && paymentPlanDetail.PropStrength__Final_Payment_Date__c != null) {
                                bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c).set(0, paymentPlanDetail);
                            } else if(finalPymtDt != null && paymentPlanDetail.PropStrength__Final_Payment_Date__c != null && paymentPlanDetail.PropStrength__Final_Payment_Date__c < finalPymtDt) {
                                bookingToPPD.get(paymentPlanDetail.PropStrength__Application_Booking__c).set(0, paymentPlanDetail);
                            }
                        }
                    } 
        }
        
        
        return createBookingWrapper(bookingMap,bookingToPPD);
    }
    
    @AuraEnabled 
    public static void submittedToAccount(String[] bookingIdList, String terminationStatus,String reasonValue,String submitedToWhom,String submittedBy) {
        List<PropStrength__Application_Booking__c> bookingListToUpdate = new List<PropStrength__Application_Booking__c>();
        string profileID = UserInfo.getProfileId();
        List<Booking__Share> bookShareToInsert = new List<Booking__Share>();
        
        for (PropStrength__Application_Booking__c book : [select id,PropStrength__Agreement_Termination_Reason__c,Termination_Process_Status__c,Name from PropStrength__Application_Booking__c where id in: bookingIdList]) {
                                    if (submitedToWhom == 'Audit' ) {
                                        bookingListToUpdate.add(new PropStrength__Application_Booking__c(Id=book.Id, Termination_Process_Status__c = terminationStatus, Submitted_to_Audit_for_Termination_Date__c=System.Today()));
                                    } else {
                                        if (book.Termination_Process_Status__c == 'Resubmitted to collections by audit' && !terminationStatus.toLowerCase().contains('reject') ) {
                                            book.Termination_Process_Status__c = 'Resubmitted to audit by collections';
                                        }else if (book.Termination_Process_Status__c == 'Resubmitted to Collection and Accounts by audit' && !terminationStatus.toLowerCase().contains('reject') ) {
                                            book.Termination_Process_Status__c = 'Resubmitted to accounts by collections';
                                        } else if (book.Termination_Process_Status__c == 'Resubmitted to accounts by collections' ) { // && book.Submitted_To_Audit_Date__c == null
                                            book.Termination_Process_Status__c = 'Submitted to audit';
                                        } else {
                                            book.Termination_Process_Status__c = terminationStatus;
                                        }
                                        if (!terminationStatus.toLowerCase().contains('reject')) {
                                            if (submitedToWhom == 'Account') {
                                                //book.Submitted_to_Accounts_Date__c = System.today();
                                            } else if (submitedToWhom == 'Audit') {
                                                //book.Submitted_To_Audit_Date__c =  System.today();
                                            } else if (submitedToWhom == 'DLD') {
                                                //book.Submitted_To_DLD_Date__c = System.today();
                                            } else if (submitedToWhom == 'Collection and Account') {
                                                //book.Submitted_to_Collection_Date__c = System.today();
                                                //book.Submitted_to_Accounts_Date__c = System.today();
                                            } else {
                                                //book.Submitted_to_Collection_Date__c = System.today();
                                            }
                                        }
                                        if (book.PropStrength__Agreement_Termination_Reason__c == null) {
                                            //book.PropStrength__Agreement_Termination_Reason__c =  terminationStatus +' by ' + UserInfo.getFirstName() + ' ' + USerInfo.getLastName() + ' on date- ' + System.today();
                                        } else {
                                            //book.PropStrength__Agreement_Termination_Reason__c =  book.PropStrength__Agreement_Termination_Reason__c + '\r\n' + terminationStatus+ ' by ' + UserInfo.getFirstName() + ' ' + USerInfo.getLastName() + ' on date- ' + System.now();
                                        }
                                        if (reasonValue != null) {
                                            //book.PropStrength__Agreement_Termination_Reason__c =  book.PropStrength__Agreement_Termination_Reason__c + ' Remarks -' +  reasonValue; 
                                        }
                                        if (submittedBy == 'Audit') {
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                //reasonValue = (book.Audit_comments_for_resubmission__c != null) ? book.Audit_comments_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                //book.Audit_comments_for_resubmission__c = reasonValue;
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                //book.Audit_comments_for_rejection__c = reasonValue;
                                                //book.Termination_Rejection_Date__c = System.today();
                                            } 
                                        } else if (submittedBy == 'Collection') {
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                /*reasonValue = (book.Collection_comment_for_resubmission__c != null) ? book.Collection_comment_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                book.Collection_comment_for_resubmission__c = reasonValue;*/
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                //book.Collection_comment_for_rejection__c = reasonValue; 
                                                //book.Termination_Rejection_Date__c = System.today();
                                            }   
                                        } else  {
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                //reasonValue = (book.Account_comments_for_resubmission__c != null) ? book.Account_comments_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                //book.Account_comments_for_resubmission__c = reasonValue;
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                //book.Account_comments_for_rejection__c = reasonValue; 
                                                //book.Termination_Rejection_Date__c = System.today();
                                            }   
                                        }
                                        bookingListToUpdate.add(book);
                                    }
                                }
                                if(!bookingListToUpdate.isEmpty()) {
                                    update bookingListToUpdate;
                                }
        
    }
    
    private static List<BookingWrapper> createBookingWrapper(Map<Id, PropStrength__Application_Booking__c> bookingMap ,Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPM ) {
        List<BookingWrapper> bookingWrapperList = new List<BookingWrapper>();
        for(String booking : bookingToPM.keySet()){
            PropStrength__Application_Booking__c bk = bookingMap.get(booking);
            list<PropStrength__Payment_Plan_Details__c> bpm = bookingToPM.get(booking);
            if(!bpm.isEmpty()) {
                for(PropStrength__Payment_Plan_Details__c ppd : bpm) {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingName = bk.Name;
                    wrap.customerName = bk.PropStrength__Primary_Applicant_Name__c != null ? bk.PropStrength__Primary_Applicant_Name__c : '';
                    wrap.bookingDate = bk.PropStrength__Booking_Date__c != null ? bk.PropStrength__Booking_Date__c.format() : '';
                    wrap.saleValue = bk.PropStrength__Revised_Total_Sales_Consideration__c != null ? bk.PropStrength__Revised_Total_Sales_Consideration__c : 0;
                    wrap.demandRaised = (ppd.PropStrength__Received_Payments__r.isEmpty() == FALSE) ? 'TRUE' : '';
                    wrap.milestoneDue = ppd.PropStrength__Amount_Due_Plus_Tax__c != null ? ppd.PropStrength__Amount_Due_Plus_Tax__c : 0;
                    wrap.collected = ppd.PropStrength__Amount_Paid__c != null ? ppd.PropStrength__Amount_Paid__c : 0;
                    wrap.age = ppd.Interest_Ageing__c;
                    wrap.balance = ppd.PropStrength__Balance__c != null ? ppd.PropStrength__Balance__c : 0;
                    wrap.registrationStatus = bk.Pre_Registration_Completed__c ? 'TRUE' : 'FALSE';
                    wrap.soaLink = '/apex/SOALetterHTML?id='+ppd.PropStrength__Application_Booking__c;
                    wrap.submittedToAccountDate = bk.Submitted_to_Accounts_for_Termination__c != null ? bk.Submitted_to_Accounts_for_Termination__c.format() : '';
                    wrap.terminationStatus = bk.Termination_Process_Status__c;
                    bookingWrapperList.add(wrap);
                }
            }
        }
        return bookingWrapperList;
    }
    public class BookingWrapper {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingIdVal;
        @AuraEnabled public string customerName;
        @AuraEnabled public Decimal saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public Decimal milestoneDue;
        @AuraEnabled public Decimal collected;
        @AuraEnabled public long due;
        @AuraEnabled public long fullDue;
        @AuraEnabled public string category;
        @AuraEnabled public string commentsHistory;
        @AuraEnabled public string soaLink;
        @AuraEnabled public string registrationStatus;
        @AuraEnabled public string bookingDate;
        @AuraEnabled public string bucketColor;
        @AuraEnabled public string lastCallAttemptStatus;
        @AuraEnabled public string primaryMobileNumber;
        @AuraEnabled public Decimal age;
        @AuraEnabled public String terminationStatus;
        @AuraEnabled public String terminationRemarks;
        @AuraEnabled public String submittedToAccountDate;
        @AuraEnabled public String submittedToAuditDate;
        @AuraEnabled public String submittedToCollectionDate;
        @AuraEnabled public String auditResubmissionComment;
        @AuraEnabled public String accountResubmissionComment;
        @AuraEnabled public String collectionResubmissionComment;
        @AuraEnabled public long purchasePrice;
        @AuraEnabled public long demandsRaised;
        @AuraEnabled public long amountCollected;
        @AuraEnabled public long outstandingAmount;
        @AuraEnabled public string demandRaised;
        @AuraEnabled public Decimal balance;
        @AuraEnabled public String ppdId;
        @AuraEnabled public String ppdName;
    }
    
}