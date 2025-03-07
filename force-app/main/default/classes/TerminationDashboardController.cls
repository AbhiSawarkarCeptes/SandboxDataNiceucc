public without sharing class  TerminationDashboardController {
    
    
    @AuraEnabled
    public static List<BookingWrapper> bookingListWithOverDue(String projectId,String towerId,List<String> terminationStatus) {
        Map<string,List<Payment_Milestones__c>> bookingToPM = new Map<String,List<Payment_Milestones__c>>();
        List<Booking__c> bookingList = new List<Booking__c>();
        System.debug('HEERE'+projectId+'---'+towerId);
        if(projectId == 'All'){
            System.debug('All'+projectId+'---'+towerId);
            bookingList  = [SELECT id,Due_Against_Purchase_price__c,SPA_Executed_Date__c,Registration_Amount_Paid__c,Raised_Cancellation_Date__c,Unit__r.Name,Unit__c,Unit__r.Project__r.Name,Unit__r.Project__c,Name,
                            Agreement_Value__c,Total_On_Account_Money_With_Registration__c,Opportunity__r.Other_Applicants_Name__c
                            ,SPA_Executed__c,Audit_Approval_Date__c,Total_Due__c,Total_Payment_Due__c,Primary_Applicant_Name__c,
                            Total_Agreement_Value_Demanded__c,Full_Due__c,Opportunity__c,Booking_Date__c,Total_Purchase_Price__c,
                            Pre_Registration_Status__c,Pre_registration__c,Last_Call_Attempt_Status__c,Termination_Status__c,Termination_Remarks__c,
                            TotalAmountDemanded__c,Submitted_to_Accounts_Date__c,Submitted_To_Audit_Date__c,Account_comments_for_resubmission__c,
                            Collection_comment_for_resubmission__c,Audit_comments_for_rejection__c,Total_On_Account_Money__c,Due_Payments__c,Audit_comments_for_resubmission__c,
                            Submitted_to_Collection_Date__c FROM Booking__c WHERE  Current_Status__c ='Audit Accepted' AND Stage_of_Booking__c != 'EOI' AND Status__c != 'Cancelled' AND Under_cancellation__c = false 
                            AND X30days_Demand_Raised__c = true AND X15days_Demand_Raised__c = true  
                            AND Termination_Status__c in: terminationStatus];
        }else if (towerId != 'All') {
            System.debug('TAll'+projectId+'---'+towerId);
            bookingList  = [SELECT id,Due_Against_Purchase_price__c,SPA_Executed_Date__c,Registration_Amount_Paid__c,Raised_Cancellation_Date__c,Unit__r.Name,Unit__c,Unit__r.Project__r.Name,Unit__r.Project__c,Name,
                            Agreement_Value__c,Total_On_Account_Money_With_Registration__c,Opportunity__r.Other_Applicants_Name__c
                            ,SPA_Executed__c,Audit_Approval_Date__c,Total_Due__c,Total_Payment_Due__c,Primary_Applicant_Name__c,
                            Total_Agreement_Value_Demanded__c,Full_Due__c,Opportunity__c,Booking_Date__c,Total_Purchase_Price__c,
                            Pre_Registration_Status__c,Pre_registration__c,Last_Call_Attempt_Status__c,Termination_Status__c,Termination_Remarks__c,
                            TotalAmountDemanded__c,Submitted_to_Accounts_Date__c,Submitted_To_Audit_Date__c,Account_comments_for_resubmission__c,
                            Collection_comment_for_resubmission__c,Audit_comments_for_rejection__c,Total_On_Account_Money__c,Due_Payments__c,Audit_comments_for_resubmission__c,
                            Submitted_to_Collection_Date__c FROM Booking__c WHERE  Current_Status__c ='Audit Accepted' AND Status__c != 'Cancelled' AND Under_cancellation__c = false 
                            AND X30days_Demand_Raised__c = true AND X15days_Demand_Raised__c = true  
                            AND Unit__r.Project__c =:projectId AND Unit__r.Tower__c =: towerId  AND Termination_Status__c in: terminationStatus];
        } else {
            System.debug('ELSE'+projectId+'---'+towerId);
            bookingList  = [SELECT id,Due_Against_Purchase_price__c,SPA_Executed_Date__c,Registration_Amount_Paid__c,Raised_Cancellation_Date__c,Unit__r.Name,Unit__c,Unit__r.Project__r.Name,Unit__r.Project__c,Name,
                            Agreement_Value__c,Total_On_Account_Money_With_Registration__c,Opportunity__r.Other_Applicants_Name__c
                            ,SPA_Executed__c,Audit_Approval_Date__c,Total_Due__c,Total_Payment_Due__c,Primary_Applicant_Name__c,
                            Total_Agreement_Value_Demanded__c,Full_Due__c,Opportunity__c,Booking_Date__c,Total_Purchase_Price__c,
                            Pre_Registration_Status__c,Pre_registration__c,Last_Call_Attempt_Status__c,Termination_Status__c,Termination_Remarks__c,Audit_comments_for_resubmission__c,
                            TotalAmountDemanded__c,Submitted_to_Accounts_Date__c,Submitted_To_Audit_Date__c,Account_comments_for_resubmission__c,
                            Collection_comment_for_resubmission__c,Audit_comments_for_rejection__c,Total_On_Account_Money__c,Due_Payments__c,
                            Submitted_to_Collection_Date__c FROM Booking__c WHERE  Current_Status__c ='Audit Accepted' AND Status__c != 'Cancelled' AND Under_cancellation__c = false 
                            AND X30days_Demand_Raised__c = true AND X15days_Demand_Raised__c = true  
                            AND Unit__r.Project__c =:projectId  AND Termination_Status__c in: terminationStatus];
            
        }
        
        System.debug('PM'+projectId+'---'+towerId);
        for(Payment_Milestones__c paymentMileStone : [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c, Quotation__c, Quotation__r.Booking__c 
                                                      FROM Payment_Milestones__c 
                                                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                                                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                                                      Quotation__r.Booking__r.Under_cancellation__c = false AND
                                                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                                                      Milestone_Due_Date__c <= TODAY AND Quotation__r.Booking__c in:bookingList] ) {
                                                          if (bookingToPM.containsKey(paymentMileStone.Quotation__r.Booking__c)) {
                                                              bookingToPM.get(paymentMileStone.Quotation__r.Booking__c).add(paymentMileStone);
                                                          } else {
                                                              bookingToPM.put(paymentMileStone.Quotation__r.Booking__c,new List<Payment_Milestones__c>{paymentMileStone});
                                                          }
                                                          
                                                      }
        System.debug('bookingList'+bookingToPM+'---'+bookingList);
        return createBookingWrapper(bookingList,bookingToPM);
    }
    
    @AuraEnabled 
    public static void submittedToAccount(String[] bookingIdList, String terminationStatus,String reasonValue,String submitedToWhom,String submittedBy) {
        System.debug('MM bookingIdList '+bookingIdList);
        System.debug('MM terminationStatus '+terminationStatus);
        System.debug('MM reasonValue '+reasonValue);
        System.debug('MM submitedToWhom '+submitedToWhom);
        System.debug('MM submittedBy '+submittedBy);
        List<Booking__c> bookingListToUpdate = new List<Booking__c>();
        string profileID = UserInfo.getProfileId();
        List<Booking__c> bookingForEmail = new List<Booking__c>();
        List<Booking__Share> bookShareToInsert = new List<Booking__Share>();
        
        for (Booking__c book : [SELECT id,Termination_Remarks__c,Raised_Cancellation_Date__c,Cancellation_Allocation__c,Termination_Status__c,Tower_Under_Construction__c,Total_Due__c,Name,Collection_comment_for_resubmission__c,Pre_Registration_Status__c,Pre_registration__c,SPA_Executed__c,
                                Account_comments_for_resubmission__c,Account_comments_for_rejection__c,Audit_comments_for_rejection__c,Audit_comments_for_resubmission__c,Submitted_To_Audit_Date__c FROM Booking__c WHERE id in: bookingIdList]) {
                                    if (submitedToWhom == 'Audit' &&  book.Total_Due__c < 10 &&  book.Tower_Under_Construction__c) {
                                        System.debug('book'+book);
                                        bookingForEmail.add(book);
                                    } else {
                                        if (book.Termination_Status__c == 'Resubmitted to collections by audit' && !terminationStatus.toLowerCase().contains('reject') ) {
                                            book.Termination_Status__c = 'Resubmitted to audit by collections';
                                        }else if (book.Termination_Status__c == 'Resubmitted to Collection and Accounts by audit' && !terminationStatus.toLowerCase().contains('reject') ) {
                                            book.Termination_Status__c = 'Resubmitted to accounts by collections';
                                        } else if (book.Termination_Status__c == 'Resubmitted to accounts by collections' && book.Submitted_To_Audit_Date__c == null ) {
                                            book.Termination_Status__c = 'Submitted to audit';
                                        }else if(submittedBy == 'Audit' && submitedToWhom == 'DLD' && (book.Pre_registration__c != 'Completed' || (book.SPA_Executed__c != 'SPA Executed' && book.SPA_Executed__c != 'Executed copy sent through DocuSign'))) {
                                            book.Termination_Status__c = 'Raised to DLD Team';
                                            book.Cancellation_Allocation__c = 'Allocate to CRM Team';
                                            book.Termination_Process_Status_for_CRM__c = '';
                                        } else if(submittedBy == 'Collection' && terminationStatus == 'Re Allocated To CRM By Collection') {
                                            book.Cancellation_Allocation__c = terminationStatus;
                                            book.Termination_Status__c = 'Raised to DLD Team';
                                        }else{
                                            book.Termination_Status__c = terminationStatus;
                                        }
                                        if (!terminationStatus.toLowerCase().contains('reject')) {
                                            if (submitedToWhom == 'Account') {
                                                book.Submitted_to_Accounts_Date__c = System.today();
                                            } else if (submitedToWhom == 'Audit') {
                                                book.Submitted_To_Audit_Date__c =  System.today();
                                            } else if (submitedToWhom == 'DLD') {
                                                book.Submitted_To_DLD_Date__c = System.today();
                                            } else if (submitedToWhom == 'Collection and Account') {
                                                book.Submitted_to_Collection_Date__c = System.today();
                                                book.Submitted_to_Accounts_Date__c = System.today();
                                            } else {
                                                book.Submitted_to_Collection_Date__c = System.today();
                                            }
                                        }
                                        if (book.Termination_Remarks__c == null) {
                                            book.Termination_Remarks__c =  terminationStatus +' by ' + UserInfo.getFirstName() + ' ' + USerInfo.getLastName() + ' on date- ' + System.today();
                                        } else {
                                            book.Termination_Remarks__c =  book.Termination_Remarks__c + '\r\n' + terminationStatus+ ' by ' + UserInfo.getFirstName() + ' ' + USerInfo.getLastName() + ' on date- ' + System.now();
                                        }
                                        if (reasonValue != null) {
                                            book.Termination_Remarks__c =  book.Termination_Remarks__c + ' Remarks -' +  reasonValue; 
                                        }
                                        if (submittedBy == 'Audit') {
                                            
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                reasonValue = (book.Audit_comments_for_resubmission__c != null) ? book.Audit_comments_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                book.Audit_comments_for_resubmission__c = reasonValue;
                                                if(terminationStatus == 'Resubmitted to collections by audit'){
                                                    book.Resubmitted_to_collections_by_audit_date__c = System.today();
                                                }
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                book.Audit_comments_for_rejection__c = reasonValue;
                                                book.Termination_Rejection_Date__c = System.today();
                                            } 
                                        } else if (submittedBy == 'Collection') {
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                reasonValue = (book.Collection_comment_for_resubmission__c != null) ? book.Collection_comment_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                book.Collection_comment_for_resubmission__c = reasonValue;
                                                if(book.Cancellation_Allocation__c == 'Re Allocated To CRM By Collection'){
                                                    book.Cancellation_Allocation__c = null;
                                                }
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                book.Collection_comment_for_rejection__c = reasonValue; 
                                                book.Termination_Rejection_Date__c = System.today();
                                                book.Termination_Rejection_by_collection_Date__c = System.today();
                                            }   
                                        } else  {
                                            if (terminationStatus.toLowerCase().contains('resubmit') && reasonValue != null) {
                                                reasonValue = (book.Account_comments_for_resubmission__c != null) ? book.Account_comments_for_resubmission__c + ' ' + reasonValue : reasonValue;
                                                book.Account_comments_for_resubmission__c = reasonValue;
                                            } else if (terminationStatus.toLowerCase().contains('reject') && reasonValue != null) {
                                                book.Account_comments_for_rejection__c = reasonValue; 
                                                book.Termination_Rejection_Date__c = System.today();
                                            }   
                                        }
                                        //sob-525 to capture raise cancellation date
                                        if(book.Raised_Cancellation_Date__c == null && submittedBy == 'Collection'){
                                            book.Raised_Cancellation_Date__c = System.today();
                                        }
                                        bookingListToUpdate.add(book);
                                    }
                                }
        update bookingListToUpdate;
        
        if (!bookingForEmail.isEmpty()) {
            sendEmail(bookingForEmail);  
        }
        List<Termination_Dashboard_Sync_Ups__e> terminationDasboardList = new List<Termination_Dashboard_Sync_Ups__e>();
        terminationDasboardList.add(new Termination_Dashboard_Sync_Ups__e(message__c = 'Termination Dashboard Sync'));
        List<Database.SaveResult> results = EventBus.publish(terminationDasboardList);
    }
    
    private static void sendEmail(List<Booking__c> bookingList) {
        List<String> ccAddress = new List<String>{'crmteam@sobharealty.com' , 'helpdesk@sobharealty.com' };
        if(System.label.SobhaCollectionTeamMe != null)
        ccAddress.add(System.label.SobhaCollectionTeamMe);
            
            User[] userList = [select id,ManagerId FROM User WHERE id =: userInfo.getUserId()];
        List<Booking__c> bookingListToUpdate = new List<Booking__c>();
        List<Messaging.SingleEmailMessage> emailListToSend  = new List<Messaging.SingleEmailMessage>();
        for (Booking__c book : bookingList) {
            book.Termination_Status__c = null;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Not able to proceed for cancellation');
            if (userList[0].ManagerId != null) {
                mail.setToAddresses(new List<String>{userList[0].ManagerId,userList[0].Id});
            } else {
                mail.setToAddresses(new List<String>{userList[0].Id});  
            }
            mail.setCcAddresses(ccAddress);
            String textBody = 'Under construction project and due is less than 10%, so not able to proceed with cancellation for ' + book.Name;
            mail.setPlainTextBody(textBody);
            emailListToSend.add(mail);
            bookingListToUpdate.add(book);
        }
        Messaging.sendEmail(emailListToSend);
        update bookingListToUpdate;
    }
    
    private static List<BookingWrapper> createBookingWrapper(List<Booking__c> bookingList ,Map<string,List<Payment_Milestones__c>> bookingToPM ) {
        List<BookingWrapper> bookingWrapperList = new List<BookingWrapper>();
        for (Booking__c bk : bookingList) {
            BookingWrapper wrap = new BookingWrapper();
            wrap.unitName = bk.Unit__r.Name;
            wrap.unitId = '/'+bk.Unit__c;
            wrap.bookingName = bk.Name;
            wrap.bookingId = '/'+bk.id;
            wrap.bookingIdVal = bk.id;
            wrap.customerName = bk.Primary_Applicant_Name__c;
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Name__c != null){
                wrap.customerName = wrap.customerName + ' & ' + bk.Opportunity__r.Other_Applicants_Name__c;
            }
            wrap.saleValue = (Integer) bk.Agreement_Value__c;
            wrap.demands = (Integer) bk.Total_Agreement_Value_Demanded__c;
            wrap.collected = (Integer) bk.Total_On_Account_Money_With_Registration__c;
            wrap.fullDue = (Integer) bk.Full_Due__c;
            wrap.registrationStatus = bk.Pre_registration__c;
            wrap.lastCallAttemptStatus = bk.Last_Call_Attempt_Status__c;
            wrap.terminationStatus = bk.Termination_Status__c;
            wrap.auditResubmissionComment = bk.Audit_comments_for_resubmission__c;
            wrap.collectionResubmissionComment  = bk.Collection_comment_for_resubmission__c;
            wrap.accountResubmissionComment = bk.Account_comments_for_resubmission__c;
            wrap.terminationRemarks = bk.Termination_Remarks__c; 
            wrap.purchasePrice = (long)bk.Total_Purchase_Price__c;
            wrap.demandsRaised = (long)bk.TotalAmountDemanded__c;
            wrap.amountCollected = (long) bk.Total_On_Account_Money__c;
            wrap.outstandingAmount = (long) bk.Due_Payments__c;
            if (bk.Submitted_to_Accounts_Date__c != null) {
                wrap.submittedToAccountDate =bk.Submitted_to_Accounts_Date__c.day() + '/' + bk.Submitted_to_Accounts_Date__c.month() + '/' + bk.Submitted_to_Accounts_Date__c.year();  
            }
            if (bk.Submitted_To_Audit_Date__c != null) {
                wrap.submittedToAuditDate = bk.Submitted_To_Audit_Date__c.day() + '/' + bk.Submitted_To_Audit_Date__c.month() + '/' + bk.Submitted_To_Audit_Date__c.year(); 
            }
            if (bk.Submitted_to_Collection_Date__c != null) {
                wrap.submittedToCollectionDate = bk.Submitted_to_Collection_Date__c.day() + '/' + bk.Submitted_to_Collection_Date__c.month() + '/' + bk.Submitted_to_Collection_Date__c.year(); 
            }
            if(bk.Booking_Date__c != null){
                wrap.bookingDate = bk.Booking_Date__c.format('dd/MM/yyyy');
            }
            wrap.soaLink = '/apex/N_CustomerSOAPage?id='+bk.Opportunity__c;
            Integer diffDays = 0;
            Boolean milestoneHit = false;
            long sum = 0;
            if (bookingToPM.containsKey(bk.id)) {
                for(Payment_Milestones__c pm : bookingToPM.get(bk.id)){
                    sum = sum + (long)pm.Total_Installment_New__c;
                    if (sum > (long)bk.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                        Date milestoneDate = pm.Milestone_Due_Date__c;
                        Date startDate = Date.today();
                        Date endDate = milestoneDate;
                        diffDays = endDate.daysBetween(startDate);
                        milestoneHit = true;
                    }
                }
            }
            wrap.due = math.abs(Integer.valueOf(sum - (long) bk.Total_On_Account_Money_With_Registration__c));
            wrap.milestoneDue = sum;
            wrap.futureDemand = (wrap.demands - wrap.milestoneDue > 0) ? wrap.demands - wrap.milestoneDue : 0;
            wrap.age = diffDays; 
            //add raise cancellation date - SOB-525 (aayushi)
            wrap.raisedCancellationDate = bk.Raised_Cancellation_Date__c; 
            
           	wrap.duePercentage = bk.Due_Against_Purchase_price__c;
            wrap.spaExecuteDate = bk.SPA_Executed_Date__c;
            wrap.registrationAmountReceived = bk.Registration_Amount_Paid__c;
            
            bookingWrapperList.add(wrap);
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
        @AuraEnabled public long saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public long milestoneDue;
        @AuraEnabled public long futureDemand;
        @AuraEnabled public long collected;
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
        @AuraEnabled public integer age;
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
        @AuraEnabled public date raisedCancellationDate;//Aayushi - SOB-525 added for showing on ui
        @AuraEnabled public decimal duePercentage;
        @AuraEnabled public date spaExecuteDate;
        @AuraEnabled public decimal registrationAmountReceived;
    }
    
}