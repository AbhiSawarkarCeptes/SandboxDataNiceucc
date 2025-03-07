public class TerminationDashboardControllerLWC {
    
    @AuraEnabled
    public static List<BookingWrapper> bookingListWithOverDue(String projectId,String towerId,List<String> terminationStatus) {
        Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPPD = new Map<String,List<PropStrength__Payment_Plan_Details__c>>();
        Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>();
        System.debug(projectId+'---*--'+towerId+'*---*--'+terminationStatus);
        if(terminationStatus.size() > 0 && terminationStatus[0] == 'Resubmitted to collections by audit'){
            terminationStatus.add('Resubmitted to Collection and Accounts by audit');
        }
        if (towerId != 'All') {
            if(terminationStatus[0] != null) {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                                                                             PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Accounts_Reason__c,Resubmitted_by_CRM_Reason__c,Resubmitted_by_DLD_Reason__c,Tr_Rejected_by_Audit_Reason__c,Tr_Rejected_by_Accounts_Reason__c
                                                                             ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,Resubmitted_by_Audit_Reason__c,
                                                                             PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                                                                             Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved' 
                                                                             and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId and PropStrength__Property__r.PropStrength__Tower__c =: towerId  and Termination_Process_Status__c in: terminationStatus]);
            } else {
                bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                                                                             PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Accounts_Reason__c,Resubmitted_by_CRM_Reason__c,Resubmitted_by_DLD_Reason__c,Tr_Rejected_by_Audit_Reason__c,Tr_Rejected_by_Accounts_Reason__c
                                                                             ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,Resubmitted_by_Audit_Reason__c,
                                                                             PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                                                                             Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved' 
                                                                             and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId and PropStrength__Property__r.PropStrength__Tower__c =: towerId  and Termination_Process_Status__c in: terminationStatus AND X30_days_LP_demand_raised__c != null AND X15_days_LP_demand_raised__c != null]);
            }
        } else {
            if(terminationStatus[0] != null) {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                                                                             PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Accounts_Reason__c,Resubmitted_by_CRM_Reason__c,Resubmitted_by_DLD_Reason__c,Tr_Rejected_by_Audit_Reason__c,Tr_Rejected_by_Accounts_Reason__c
                                                                             ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,Resubmitted_by_Audit_Reason__c,
                                                                             PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                                                                             Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved'  
                                                                             and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId  and Termination_Process_Status__c in: terminationStatus]);
            } else {
                bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                                                                             PropStrength__Total_Agreement_Amount__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Accounts_Reason__c,Resubmitted_by_CRM_Reason__c,Resubmitted_by_DLD_Reason__c,Tr_Rejected_by_Audit_Reason__c,Tr_Rejected_by_Accounts_Reason__c
                                                                             ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,Resubmitted_by_Audit_Reason__c,
                                                                             PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                                                                             Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved'  
                                                                             and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId  and Termination_Process_Status__c in: terminationStatus AND X30_days_LP_demand_raised__c != null AND X15_days_LP_demand_raised__c != null]);
            }
            
        }
        
        if (towerId != 'All') {
            Date finalPymtDt;
            for(PropStrength__Payment_Plan_Details__c paymentPlanDetail : [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                                                                           PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,PropStrength__Payment_Due_Date__c,
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
                                                                           PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,PropStrength__Payment_Due_Date__c,
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
        String terminateState = '';
        if(terminationStatus.Size() > 0)
            terminateState = terminationStatus[0];
        return createBookingWrapper(bookingMap,bookingToPPD,terminateState);
    }
    
    @AuraEnabled 
    public static void submittedToAccount(String[] bookingIdList, String terminationStatus,String reasonValue,String submitedToWhom,String submittedBy) {
        System.debug(terminationStatus+'--Termination_Rejection_Reason__c*---'+reasonValue);
        List<PropStrength__Application_Booking__c> bookingListToUpdate = new List<PropStrength__Application_Booking__c>();
        string profileID = UserInfo.getProfileId();
        List<Booking__Share> bookShareToInsert = new List<Booking__Share>();
        
        for (PropStrength__Application_Booking__c book : [select id,Resubmitted_by_Collection_Reason__c, Tr_Rejected_by_Collection_Reason__c,Customer_Initiated_Termination__c,PropStrength__Agreement_Termination_Reason__c,Termination_Process_Status__c,Name from PropStrength__Application_Booking__c where id in: bookingIdList]) {
            System.debug('submitedToWhom*---'+submitedToWhom);
            
            if (terminationStatus == 'Submitted to Accounts' || terminationStatus == 'Submitted to Audit') {
                book.Termination_Process_Status__c = 'Submitted to Accounts';
                book.Submitted_to_Accounts_for_Termination__c = System.today();
                if (book.Resubmitted_by_Collection_Reason__c == null || book.Resubmitted_by_Collection_Reason__c == '') {
                    book.Resubmitted_by_Collection_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                } else {
                    book.Resubmitted_by_Collection_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                }
            } else if(terminationStatus == 'Rejected by Collections' || terminationStatus == 'Rejected by audit'){
                book.Termination_Process_Status__c = terminationStatus;
                book.Tr_Rejected_by_Collection_Reason__c = reasonValue; 
                if (book.Tr_Rejected_by_Collection_Reason__c == null || book.Tr_Rejected_by_Collection_Reason__c == '') {
                    book.Tr_Rejected_by_Collection_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                } else {
                    book.Tr_Rejected_by_Collection_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                }               
            }else if(terminationStatus == 'Resubmitted to accounts by collections'){
                book.Termination_Process_Status__c = terminationStatus;
                if (book.Resubmitted_by_Collection_Reason__c == null || book.Resubmitted_by_Collection_Reason__c == '') {
                    book.Resubmitted_by_Collection_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                } else {
                    book.Resubmitted_by_Collection_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                }
                book.Submitted_to_Accounts_for_Termination__c = System.today();
                if(book.Customer_Initiated_Termination__c) {
                    book.Cancellation_Allocation__c = 'Allocate to Account Team';
                }
            }
            else if(terminationStatus == 'Resubmitted to audit by collections'){
                book.Termination_Process_Status__c = terminationStatus;
                if (book.Resubmitted_by_Collection_Reason__c == null || book.Resubmitted_by_Collection_Reason__c == '') {
                    book.Resubmitted_by_Collection_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                } else {
                    book.Resubmitted_by_Collection_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                }
                book.Submitted_to_Audit_for_Termination_Date__c = System.Today();
            }           
            else {
                book.Termination_Process_Status__c = terminationStatus;
            }              
            bookingListToUpdate.add(book);
            
        }
        if(!bookingListToUpdate.isEmpty()) {
            update bookingListToUpdate;
        }
        
    }
    
    @TestVisible
    private static List<BookingWrapper> createBookingWrapper(Map<Id, PropStrength__Application_Booking__c> bookingMap ,Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPM, String terminateStatus ) {
        List<BookingWrapper> bookingWrapperList = new List<BookingWrapper>();
        for(String booking : bookingToPM.keySet()){
            PropStrength__Application_Booking__c bk = bookingMap.get(booking);
            list<PropStrength__Payment_Plan_Details__c> bpm = bookingToPM.get(booking);
            if(!bpm.isEmpty()) {
                for(PropStrength__Payment_Plan_Details__c ppd : bpm) {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    if(terminateStatus == 'Resubmitted to Collections by Accounts'){
                        wrap.terminationremarks = bk.Resubmitted_by_Accounts_Reason__c;
                    }
                    else if(terminateStatus == 'Resubmitted to Collections by Audit'){
                        wrap.terminationremarks = bk.Resubmitted_by_Audit_Reason__c;
                    }
                    else if(terminateStatus == 'Rejected by Accounts'){
                        wrap.terminationremarks = bk.Tr_Rejected_by_Accounts_Reason__c;
                    }
                    else if(terminateStatus == 'Rejected by Audit'){
                        wrap.terminationremarks = bk.Tr_Rejected_by_Audit_Reason__c;
                    }
                    else if(terminateStatus == 'Resubmitted to Collections by DLD'){
                        wrap.terminationremarks = bk.Resubmitted_by_DLD_Reason__c;
                    }
                    else if(terminateStatus == 'Resubmitted to Collections by CRM'){
                        wrap.terminationremarks = bk.Resubmitted_by_CRM_Reason__c;
                    }
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
                    wrap.submittedToCollectionDate = ppd.PropStrength__Payment_Due_Date__c;
                    wrap.fullDue = ppd.PropStrength__Balance__c;
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
        @AuraEnabled public Decimal fullDue;
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
        @AuraEnabled public date submittedToCollectionDate;
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