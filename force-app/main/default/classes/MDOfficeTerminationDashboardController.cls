public without sharing class  MDOfficeTerminationDashboardController {
    
    
    @AuraEnabled
    public static List<BookingWrapper> bookingListWithOverDue(String projectId,String towerId,List<String> terminationStatus) {
        Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPPD = new Map<String,List<PropStrength__Payment_Plan_Details__c>>();
        Map<Id, PropStrength__Application_Booking__c> bookingMap = new Map<Id, PropStrength__Application_Booking__c>();
        System.debug(projectId+'---*--'+towerId+'*---*--'+terminationStatus);
        if(terminationStatus.size() > 0 && terminationStatus[0] == 'Resubmitted to accounts by collections'){
            terminationStatus.add('Resubmitted to Accounts');
        }
        if(terminationStatus.size() > 0 && terminationStatus[0] == 'Resubmitted by audit to accounts'){
            terminationStatus.add('Resubmitted to Collection and Accounts by audit');
        }
        System.debug(projectId+'---*--'+towerId+'*---*--'+terminationStatus);
        if (towerId != 'All') {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                        PropStrength__Total_Agreement_Amount__c,Submitted_to_MD_Office_Remarks__c, Submitted_To_MD_Office_Termination_Date__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Collection_Reason__c,Resubmitted_by_Audit_Reason__c
                        ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,
                        PropStrength__Revised_Agreement_Amount__c,Final_Notice_Sent_Date__c,Tr_Audit_Approval_Remarks__c, Tr_Accounts_Approval_Remarks__c,Oqood_Fees_Received__c,SPA_Execution_Date__c,                                                 
                        PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                        Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved' 
                        and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId and PropStrength__Property__r.PropStrength__Tower__c =: towerId AND Customer_Initiated_Termination__c = true  and Cancellation_Allocation__c IN :terminationStatus]);
        } else {
            bookingMap  = new Map<Id, PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                    PropStrength__Total_Agreement_Amount__c,Submitted_to_MD_Office_Remarks__c, Submitted_To_MD_Office_Termination_Date__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Audit_Reason__c
                    ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,
                    PropStrength__Revised_Agreement_Amount__c,Final_Notice_Sent_Date__c,Resubmitted_by_Collection_Reason__c,Tr_Audit_Approval_Remarks__c, Tr_Accounts_Approval_Remarks__c,Oqood_Fees_Received__c,SPA_Execution_Date__c,                                                 
                    PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                    Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c where  PropStrength__Status__c ='Audit Approved'  
                    and PropStrength__Property__r.PropStrength__Project_Name__c =:projectId AND Customer_Initiated_Termination__c = true   AND Cancellation_Allocation__c IN :terminationStatus]);
        }
        
        if (towerId != 'All') {
        Date finalPymtDt;
        for(PropStrength__Payment_Plan_Details__c paymentPlanDetail : [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,PropStrength__Payment_Due_Date__c,
                    PropStrength__Total_Amount_Due_with_Service_Tax__c,Demand_Sent__c,PropStrength__Amount_Percent__c,                                                    
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
                    PropStrength__Total_Amount_Due_with_Service_Tax__c,Demand_Sent__c,PropStrength__Amount_Percent__c,                                                 
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
        List<PropStrength__Application_Booking__c> bookingListToUpdate = new List<PropStrength__Application_Booking__c>();
        string profileID = UserInfo.getProfileId();
        System.debug(terminationStatus+'--Termination_Rejection_Reason__c*---'+reasonValue);
        System.debug(terminationStatus+'-****---'+submitedToWhom);
        List<Booking__Share> bookShareToInsert = new List<Booking__Share>();

        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_To_CRM_On_MD_Approval'];
        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        List<String> sendTo = new List<String>();

        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Business_Process_CRM_Queue'];
        
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Business_Process_CRM_Queue')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        if(gmList[0].group.Email != null){
            sendTo.add(gmList[0].group.Email);
        }
        
        for (PropStrength__Application_Booking__c book : [select id,Resubmitted_by_Accounts_Reason__c, TR_Reason__c,CRM_Dashboard_Remarks__c,MD_Office_Approval_Remarks__c,CRM_Executive__c,PropStrength__Agreement_Termination_Reason__c,Termination_Process_Status__c,Name from PropStrength__Application_Booking__c where id in: bookingIdList]) {
                                    System.debug(terminationStatus+'--book.Termination_Process_Status__c*---'+book.Termination_Process_Status__c);
                                    if (submitedToWhom == 'Audit' ) {
                                        if (terminationStatus == 'Approved with full refund##Allocate to CRM Team' || terminationStatus == 'Approved with deduction##Allocate to CRM Team') {
                                            List<String> temp = terminationStatus.split('##');
                                            terminationStatus = temp[1];
                                            String val = book.MD_Office_Approval_Remarks__c;
                                            if (book.MD_Office_Approval_Remarks__c == null || book.MD_Office_Approval_Remarks__c == '') {
                                                val = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            } else {
                                                val += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            }

                                            String val2 = book.CRM_Dashboard_Remarks__c;
                                            if (book.CRM_Dashboard_Remarks__c == null || book.CRM_Dashboard_Remarks__c == '') {
                                                val2 = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            } else {
                                                val2 += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            }
                                            bookingListToUpdate.add(new PropStrength__Application_Booking__c(Id=book.Id, Customer_Initiated_Termination__c = true, Cancellation_Allocation__c = terminationStatus,MD_Office_Approval_Remarks__c = val, CRM_Dashboard_Remarks__c = val2, MD_Office_Approval_Date__c = System.now(), MD_Office_Approval_Category__c = temp[0]));
                                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                            email.setToAddresses(sendTo);
                                            email.setWhatId(book.Id);
                                            email.setTargetObjectId(book.CRM_Executive__c);
                                            email.setTreatTargetObjectAsRecipient(False);
                                            email.setSaveAsActivity(true); 
                                            email.setTemplateId(tempId);
                                            mails.add(email); 
                                        }
                                    } else {
                                        if (terminationStatus == 'Allocate to CRM Team') {
                                            book.Cancellation_Allocation__c = terminationStatus;
                                            String val = book.CRM_Dashboard_Remarks__c;
                                            if (book.CRM_Dashboard_Remarks__c == null || book.CRM_Dashboard_Remarks__c == '') {
                                                val = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            } else {
                                                val += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            }
                                            book.CRM_Dashboard_Remarks__c = val;
                                            book.Submitted_To_CRM_by_MD_Date__c = System.now();
                                            book.Customer_Initiated_Termination__c = true;
                                        } else if(terminationStatus == 'Resubmitted to collections by accounts'){
                                            book.Termination_Process_Status__c = terminationStatus;
                                            book.Cancellation_Allocation__c = '';
                                            if (book.Resubmitted_by_Accounts_Reason__c == null || book.Resubmitted_by_Accounts_Reason__c == '') {
                                                book.Resubmitted_by_Accounts_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            } else {
                                                book.Resubmitted_by_Accounts_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            }
                                            book.Submitted_To_Collection_By_MD_Date__c = System.now();
                                            book.Customer_Initiated_Termination__c = true;
                                        } else if(terminationStatus == 'Removed from Termination') {
                                            book.Termination_Process_Status__c = terminationStatus;
                                            book.Cancellation_Allocation__c = '';
                                            if (book.TR_Reason__c == null || book.TR_Reason__c == '') {
                                                book.TR_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            } else {
                                                book.TR_Reason__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+reasonValue;
                                            }
                                            book.MD_Office_Rejection_Date__c = System.now();
                                            book.Customer_Initiated_Termination__c = true;
                                        }
                                        bookingListToUpdate.add(book);
                                    }
                                }
                                if(!bookingListToUpdate.isEmpty()) {
                                    update bookingListToUpdate;

                                    try {
                                        if(!mails.isEmpty()){
                                            Messaging.sendEmail(mails);
                                        }
                                    } Catch(Exception e){
                                        System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                                        System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
                                    }
                                }
        
    }
    @TestVisible
    private static List<BookingWrapper> createBookingWrapper(Map<Id, PropStrength__Application_Booking__c> bookingMap ,Map<string,List<PropStrength__Payment_Plan_Details__c>> bookingToPM,String terminateStatus  ) {
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
                    
                    wrap.purchasePrice = bk.PropStrength__Revised_Agreement_Amount__c;
                    wrap.demands = ppd.PropStrength__Total_Amount_Due_with_Service_Tax__c != null ? ppd.PropStrength__Total_Amount_Due_with_Service_Tax__c : 0;
                    wrap.submittedToAuditDate = ppd.Demand_Sent__c;
                    wrap.terminationNotice = bk.Final_Notice_Sent_Date__c != null ? bk.Final_Notice_Sent_Date__c.date() : null;
                    System.debug(wrap.demands+'**--collected---'+wrap.collected);
                    wrap.due = wrap.demands - wrap.collected; 
                    wrap.collectionResubmissionComment = bk.Resubmitted_by_Collection_Reason__c;
                    wrap.accountResubmissionComment = bk.Tr_Accounts_Approval_Remarks__c;                    
                    wrap.auditResubmissionComment = bk.Tr_Audit_Approval_Remarks__c;
                    wrap.duePercentage = ppd.PropStrength__Amount_Percent__c;
                    wrap.spaExecuteDate = bk.SPA_Execution_Date__c;
                    if(bk.Oqood_Fees_Received__c)
                     wrap.registrationAmountReceived = 'Yes';
                    else
                       wrap.registrationAmountReceived = 'No'; 
                    
                    
                    wrap.terminationRemarks = bk.Submitted_to_MD_Office_Remarks__c;
                    wrap.submittedToCollectionDate = ppd.PropStrength__Payment_Due_Date__c;
                    wrap.fullDue = ppd.PropStrength__Balance__c;
                    wrap.balance = ppd.PropStrength__Balance__c != null ? ppd.PropStrength__Balance__c : 0;
                    wrap.registrationStatus = bk.Pre_Registration_Completed__c ? 'TRUE' : 'FALSE';
                    wrap.soaLink = '/apex/SOALetterHTML?id='+ppd.PropStrength__Application_Booking__c;
                    wrap.submittedToAccountDate = bk.Submitted_To_MD_Office_Termination_Date__c != null ? bk.Submitted_To_MD_Office_Termination_Date__c.date().format() : '';
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
        @AuraEnabled public Decimal demands;
        @AuraEnabled public date terminationNotice;
        @AuraEnabled public Decimal milestoneDue;
        @AuraEnabled public Decimal collected;
        @AuraEnabled public Decimal due;
        @AuraEnabled public Decimal fullDue;
        @AuraEnabled public string category;
        @AuraEnabled public dateTime spaExecuteDate;
        @AuraEnabled public decimal duePercentage;
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
        @AuraEnabled public Date submittedToAuditDate;
        @AuraEnabled public date submittedToCollectionDate;
        @AuraEnabled public String auditResubmissionComment;
        @AuraEnabled public String accountResubmissionComment;
        @AuraEnabled public String registrationAmountReceived;
        @AuraEnabled public String collectionResubmissionComment;
        @AuraEnabled public Decimal purchasePrice;
        @AuraEnabled public long demandsRaised;
        @AuraEnabled public long amountCollected;
        @AuraEnabled public long outstandingAmount;
        @AuraEnabled public string demandRaised;
        @AuraEnabled public Decimal balance;
        @AuraEnabled public String ppdId;
        @AuraEnabled public String ppdName;
    }
    
}