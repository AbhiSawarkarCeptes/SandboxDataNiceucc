public without sharing class TerminationDLDLWCController {
    @AuraEnabled
    public static list<PropStrength__Projects__c> getProjects(){
        return [select Id, Name, (select Id, PropStrength__Tower_Name__c from PropStrength__Towers__r Order By Name ASC) from PropStrength__Projects__c Order By Name ASC];
    }

    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Task__c.Category__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
    }
    
    @AuraEnabled
    public static list<BookingWrapper> getBookings(string projectId, string towerId, string selectedType, Date fromAuditApprovedDate, Date toAuditApprovedDate){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new map<string, list<PropStrength__Payment_Plan_Details__c>>();
        list<PropStrength__Payment_Plan_Details__c> pmList = new list<PropStrength__Payment_Plan_Details__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();

        
        if (towerId == 'All') {
            if(projectId == 'All' || projectId == '' || projectId == null) {
                pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__c != null AND ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Submitted to DLD' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Raised to DLD Team' )];
            } else {
                pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Submitted to DLD' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Raised to DLD Team' )];
            }
        } else {
            if(projectId == 'All' || projectId == '' || projectId == null) {
                pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                      AND PropStrength__Application_Booking__c != null AND ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Submitted to DLD' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Raised to DLD Team')];
            } else {
                pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Submitted to DLD' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Raised to DLD Team')];
            }
        }

        set<string> greenList = new set<string>();
        set<string> yellowList = new set<string>();
        set<string> amberList = new set<string>();
        set<string> redList = new set<string>();

        Date finalPymtDt;
        for(PropStrength__Payment_Plan_Details__c pm : pmList){
            if(!bookingToPM.containsKey(pm.PropStrength__Application_Booking__c)) {
                            bookingToPM.put(pm.PropStrength__Application_Booking__c, new List<PropStrength__Payment_Plan_Details__c>{pm});
                        } else {
                            finalPymtDt = bookingToPM.get(pm.PropStrength__Application_Booking__c)[0].PropStrength__Final_Payment_Date__c;
                            if(finalPymtDt == null && pm.PropStrength__Final_Payment_Date__c != null) {
                                bookingToPM.get(pm.PropStrength__Application_Booking__c).set(0, pm);
                            } else if(finalPymtDt != null && pm.PropStrength__Final_Payment_Date__c != null && pm.PropStrength__Final_Payment_Date__c < finalPymtDt) {
                                bookingToPM.get(pm.PropStrength__Application_Booking__c).set(0, pm);
                            }
                        }
        }
        
        System.debug('bookingToPM****');
        System.debug(bookingToPM);
        Map<String,PropStrength__Application_Booking__c> bookingIdToBooking = new Map<String,PropStrength__Application_Booking__c>();
        
        if (selectedType == 'Dashboard1') {
            System.debug('Dashboard 1');
            if(fromAuditApprovedDate != null  && toAuditApprovedDate != null){
                System.debug('fromAuditApprovedDate  '+fromAuditApprovedDate);
                for(PropStrength__Application_Booking__c b : [select id,Resubmitted_by_DLD_Reason__c,Termination_Process_Status__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,
                 PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c, Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                 PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                 PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                 Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Amount_paid_by_Customer__c,Forfeited_Amount__c,                                             
                 PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet() 
                                                              AND (Cancellation_Allocation__c = null OR Cancellation_Allocation__c = '')  
                                        and Termination_Process_Status__c != 'Removed from Termination' and Submitted_to_DLD_for_Termination_Date__c >=: fromAuditApprovedDate
                                   		and Submitted_to_DLD_for_Termination_Date__c <=: toAuditApprovedDate ]){
                bookingIdToBooking.put(b.id,b);
                                        }
            }
            else{
                System.debug('fromAuditApprovedDate  '+fromAuditApprovedDate);
                for(PropStrength__Application_Booking__c b : [select id,Resubmitted_by_DLD_Reason__c,Termination_Process_Status__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                 PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                 PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                 PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                              Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,
                 PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet() 
                                                              AND (Cancellation_Allocation__c = null OR Cancellation_Allocation__c = '')  
                                        and Termination_Process_Status__c != 'Removed from Termination' ]){
                bookingIdToBooking.put(b.id,b);
                                        }                
            }
        }

        if (selectedType == 'Dashboard2') {
            for(PropStrength__Application_Booking__c b : [select id,Termination_Process_Status__c,Resubmitted_by_DLD_Reason__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                 PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                 PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                 PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                          Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,
                 PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet()
                            and Cancellation_Allocation__c = 'Allocate to DLD Team'
                            and Final_Notice_Sent_Date__c = null
                            and Termination_Process_Status__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }

        if (selectedType == 'Dashboard3') {
            for(PropStrength__Application_Booking__c b : [select id,Termination_Process_Status__c,Resubmitted_by_DLD_Reason__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                 PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                 PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                 PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                          Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,
                 PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet()
                                and Cancellation_Allocation__c = 'Allocate to DLD Team'
                                and Final_Notice_Sent_Date__c != null
                                and Termination_Process_Status__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }
        System.debug('bookingIdToBooking :::'+bookingIdToBooking);
        //System.debug();
        
        for(string booking : bookingToPM.keySet()){
            
            PropStrength__Application_Booking__c bk = bookingIdToBooking.get(booking);
            if(bk != null) {
                list<PropStrength__Payment_Plan_Details__c> bpm = bookingToPM.get(booking);
                for(PropStrength__Payment_Plan_Details__c ppd : bpm) {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    if(bk.PropStrength__Project__c != null)
                    wrap.projectName = bk.PropStrength__Project__r.Name;
                    wrap.spaexecuted = bk.SPA_Status__c != null ? bk.SPA_Status__c : '';
                    wrap.preRegstatus = bk.Pre_Registration_Status__c != null ? bk.Pre_Registration_Status__c : '';
                    wrap.titleDeedStatus = bk.Title_Deed_Status__c != null ? bk.Title_Deed_Status__c : '';
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingName = bk.Name;
                    wrap.customerName = bk.PropStrength__Primary_Applicant_Name__c != null ? bk.PropStrength__Primary_Applicant_Name__c : '';
                    wrap.bookingDate = bk.PropStrength__Booking_Date__c != null ? bk.PropStrength__Booking_Date__c.format() : '';
                    wrap.saleValue = bk.PropStrength__Revised_Total_Sales_Consideration__c != null ? bk.PropStrength__Revised_Total_Sales_Consideration__c : 0;
                    wrap.demandRaised = (ppd.PropStrength__Received_Payments__r.isEmpty() == FALSE) ? 'TRUE' : '';
                    wrap.milestoneDue = ppd.PropStrength__Amount_Due_Plus_Tax__c != null ? ppd.PropStrength__Amount_Due_Plus_Tax__c : 0;
                    wrap.collected = bk.PropStrength__Total_Payment_Received__c != null ? bk.PropStrength__Total_Payment_Received__c : 0;
                    wrap.collectedpercentage = bk.PropStrength__Total_Paid_Percent__c != null ? bk.PropStrength__Total_Paid_Percent__c : 0;
                    wrap.age = ppd.Interest_Ageing__c;
                    wrap.allowPR = bk.Allow_Payment_Request__c;
                    wrap.customerNameArabic = bk.Primary_Applicant_Name_Arabic__c;
                    wrap.customerAddressArabic = bk.Customer_Address_Arabic__c;
                    wrap.forfeitedAmount = bk.Forfeited_Amount__c;
                    wrap.amountPaidByCustomer = bk.Amount_paid_by_Customer__c;
                    wrap.projectCompletionPercentageArabic = bk.Project_Completion_Arabic__c;
                    wrap.fullDue = bk.PropStrength__Total_Payment_Due__c != null ? bk.PropStrength__Total_Payment_Due__c : 0;
                    wrap.finalNoticeSentDate = bk.Final_Notice_Sent_Date__c != null ? bk.Final_Notice_Sent_Date__c.date().format() : '';
                    wrap.developerFinalNoticeSentDateCourier = bk.Final_Notice_Sent_Date_Courier__c;
                    wrap.duepercentage = bk.PropStrength__Total_Due_Percent__c != null ? bk.PropStrength__Total_Due_Percent__c : 0;
                    wrap.developerFinalNoticeStatus = bk.Developer_Final_Notice_Status__c != null ? bk.Developer_Final_Notice_Status__c : '';
                    wrap.finalNoticeReceivedDate = bk.Final_Notice_Receive_Date_Courier__c;
                    wrap.forfeitureNoticeSentDate = bk.DLD_Notice_Sent_Date__c;
                    //wrap.commentsremarks = bk.CRM_Dashboard_Remarks__c;
                    //wrap.terminationremarks = bk.Termination_Remarks__c;
                    wrap.terminationCompletionDate = bk.Approved_for_Termination_Date__c;
                    wrap.dldNoticeStatus = bk.DLD_Notice_Status__c != null ? bk.DLD_Notice_Status__c : '';
                    wrap.dldNoticeStatusCategory = bk.DLD_Notice_Status_Category__c != null ? bk.DLD_Notice_Status_Category__c : '';
                    wrap.terminationProcessStatus = bk.Termination_Process_Status__c;
                    wrap.auditapproveddate = bk.Submitted_to_DLD_for_Termination_Date__c;
                    wrap.balance = ppd.PropStrength__Balance__c != null ? ppd.PropStrength__Balance__c : 0;
                    wrap.registrationStatus = bk.Pre_Registration_Completed__c ? 'TRUE' : 'FALSE';
                    wrap.soaLink = '/apex/SOALetterHTML?id='+ppd.PropStrength__Application_Booking__c;
                    wrapList.add(wrap);
                }
            }
        }
        return wrapList;
    }

    @AuraEnabled
    public static Boolean updateBookingRow(String row, Boolean canceltheprocess, Boolean ispicklist, String cancelComments, Boolean isdate,
                                           boolean istext, boolean isboolean, boolean isSubmitprocess){
        System.debug('Row ::: '+row+'*----'+cancelComments+'---'+ispicklist);
        try {
            if (row != null) {
                System.debug('Row ::: '+row);
                if (canceltheprocess != null && canceltheprocess) {
                    BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
                    //Get the booking Id 
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    PropStrength__Application_Booking__c book = [SELECT Id, Termination_Remarks__c FROM PropStrength__Application_Booking__c WHERE Id = :bookingId];
                    PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c();
                    b.Id = bookingId;
                    //b.X15days_Demand_Raised__c = false;
                    //b.X30days_Demand_Raised__c = false;
                    b.Termination_Process_Status__c = 'Removed from Termination';

                    if (book.Termination_Remarks__c == null || book.Termination_Remarks__c == '') {
                        b.Termination_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+cancelComments;
                    } else {
                        b.Termination_Remarks__c = book.Termination_Remarks__c + '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+cancelComments;
                    }

                    if (b.Termination_Remarks__c == null || b.Termination_Remarks__c == '') {
                        if (book.Termination_Remarks__c == null || book.Termination_Remarks__c == '') {
                            b.Termination_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        } else {
                            b.Termination_Remarks__c = book.Termination_Remarks__c + '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        }
                    } else {
                        b.Termination_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                    }
                    
                    upsert b;
                    return true;
                }

                List<BookingLineItemParser> wrapList = BookingLineItemParser.parse(row);

                List<PropStrength__Application_Booking__c> bookingsToUpdate = new List<PropStrength__Application_Booking__c>();
                for (BookingLineItemParser wrap:wrapList) {
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    PropStrength__Application_Booking__c updateBooking = [Select id, Termination_Remarks__c,  CRM_Dashboard_Remarks__c  
                                                    From PropStrength__Application_Booking__c 
                                                    where id=:bookingId];
                    updateBooking.Id = bookingId;

                    if (ispicklist != null && ispicklist) {
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.label == 'developerFinalNoticeStatus')
                                updateBooking.Developer_Final_Notice_Status__c = wrap.value;
                            if (wrap.label == 'dldNoticeStatus')
                                updateBooking.DLD_Notice_Status__c = wrap.value;
                            if (wrap.label == 'dldNoticeStatusCategory') {
                                updateBooking.DLD_Notice_Status_Category__c = wrap.value;
                            }
                            if (wrap.label == 'cancellationAllocation') {
                                 updateBooking.Cancellation_Allocation__c = wrap.value;
                                if(wrap.value == 'Allocate to Collection Team'){
                                    updateBooking.Termination_Process_Status__c = 'Resubmitted to Collections by DLD';
                                }
                            }
                            if (wrap.label == 'amountPaidByCustomerlabel') {
                                updateBooking.Amount_paid_by_Customer__c = wrap.value;
                            }
                        }
                    }
                    System.debug(isDate);
                    System.debug(wrap);
                    if(isdate != null && isdate) {
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.label == 'finalNoticeReceivedDatelabel')
                                updateBooking.Final_Notice_Receive_Date_Courier__c = Date.valueOf(wrap.value);
                            if (wrap.label == 'developerFinalNoticeSentDateCourierlabel')
                                updateBooking.Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.value);
                        }
                    }
                    
                    if(istext != null && istext) {
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.label == 'terminationremarkslabel') {
                                if (updateBooking.Termination_Remarks__c == null || updateBooking.Termination_Remarks__c == '') {
                                    updateBooking.Termination_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.value;
                                } else {
                                    updateBooking.Termination_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.value;
                                }
                            }
                            if (wrap.label == 'CommentsRemarkslabel') {
                                if (updateBooking.CRM_Dashboard_Remarks__c == null || updateBooking.CRM_Dashboard_Remarks__c == '') {
                                    updateBooking.CRM_Dashboard_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.value;
                                } else {
                                    updateBooking.CRM_Dashboard_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.value;
                                }
                            }
                            if (wrap.label == 'customerNameArabiclabel')
                                updateBooking.Primary_Applicant_Name_Arabic__c = wrap.value;
                            if (wrap.label == 'customerAddressArabiclabel')
                                updateBooking.Customer_Address_Arabic__c = wrap.value;
                            if (wrap.label == 'projectCompletionPercentageArabiclabel')
                                updateBooking.Project_Completion_Arabic__c = wrap.value;
                            if (wrap.label == 'forfeitedAmountlabel')
                                updateBooking.Forfeited_Amount__c = Decimal.valueof(wrap.value);
                        }
                    }
                    
                    if(isboolean != null && isboolean) {                        
                                updateBooking.Allow_Payment_Request__c = boolean.valueof(wrap.value);                        
                    }                    
                    
                    if(isSubmitprocess != null && isSubmitprocess) {                        
                          updateBooking.Termination_Process_Status__c = 'Approved for Termination';
						  updateBooking.Approved_for_Termination_Date__c = System.today();	                        
                    }
                    if (wrap.commentsremarks != null) {
                        /*if (updateBooking.CRM_Dashboard_Remarks__c == null || updateBooking.CRM_Dashboard_Remarks__c == '') {
                            updateBooking.CRM_Dashboard_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        } else {
                            updateBooking.CRM_Dashboard_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        }*/
                    }
                    if (wrap.cancellationAllocation != null)
                        //updateBooking.Cancellation_Allocation__c = wrap.cancellationAllocation;
                    if (wrap.finalNoticeSentDateCourier != null)
                        //updateBooking.Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.finalNoticeSentDateCourier);
                    if (wrap.finalNoticeReceivedDate != null)
                        updateBooking.Final_Notice_Receive_Date_Courier__c = Date.valueOf(wrap.finalNoticeReceivedDate);
                    if (wrap.forfeitureNoticeSentDateCourier != null)
                        //updateBooking.Forfeiture_Notice_Notice_Sent_Date_Co__c = Date.valueOf(wrap.forfeitureNoticeSentDateCourier);
                    if (wrap.forfeitedAmount != null)
                        //updateBooking.PropStrength__Forfeiture_Amount__c = Decimal.valueOf(wrap.forfeitedAmount);
                    if (wrap.customerNameArabic != null)
                        //updateBooking.Primary_Applicant_Name_Arabic__c = wrap.customerNameArabic;
                    if (wrap.customerAddressArabic != null)
                        //updateBooking.Primary_Applicant_Address_Arabic__c = wrap.customerAddressArabic;
                    if (wrap.projectCompletionPercentageArabic != null)
                        //updateBooking.Project_Completion_Arabic__c = wrap.projectCompletionPercentageArabic;
                    if (wrap.developerFinalNoticeSentDateCourier != null) {
                        updateBooking.Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.developerFinalNoticeSentDateCourier);
                    }
                    if (wrap.developerFinalNoticeStatus != null) {
                        updateBooking.Developer_Final_Notice_Status__c = wrap.developerFinalNoticeStatus;
                    }
                    bookingsToUpdate.add(updateBooking);
                }
                System.debug('bookingsToUpdate*----'+bookingsToUpdate);
                if (bookingsToUpdate.size() > 0) {
                    update bookingsToUpdate;
                }
                
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*@AuraEnabled
    public static void updateLastActionOnBooking(string category, string bookingId, string taskId, string dueOrAdvanceAmount){
        dueOrAdvanceAmount = dueOrAdvanceAmount.remove(',');
        Task__c task = [select id,Category__c,Communication_Mode__c,Follow_up_Date__c,CreatedDate,Owner.Name,Notes__c,Expected_Date_Of_The_Payment__c,Customer_Interested__c from Task__c where Id =: taskId];
        PropStrength__Application_Booking__c bk = new PropStrength__Application_Booking__c();
        bk.Id = bookingId;
        bk.Category__c = category;
        bk.Last_Call_Attempt_Date__c = task.CreatedDate;
        bk.Last_Call_Attempt_Status__c = task.Category__c;
        bk.Last_Call_Description__c = task.Notes__c;
        bk.Last_Action_Type__c = task.Communication_Mode__c;
        bk.Next_Action_Date__c = task.Follow_up_Date__c;
        bk.Due_Advance_Amount__c = Long.valueOf(dueOrAdvanceAmount);
        if(task.Customer_Interested__c == 'Yes'){
            bk.Next_Action_Date__c = task.Expected_Date_Of_The_Payment__c;
        }
        bk.Last_Call_Attempted_By__c = task.Owner.Name;
        update bk;
    }*/

    @AuraEnabled
    public static String approveEslamFinalNotice(String row) {
        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        PropStrength__Application_Booking__c bk = [Select Id, Final_Notice_Approved__c From PropStrength__Application_Booking__c Where id=:bookingId];
        
        if (bk.Final_Notice_Approved__c) {
            return 'Already Approved';
        }
        bk.Final_Notice_Approved__c = TRUE;
        update bk;
        return 'Approved';
    }

    @AuraEnabled
    public static String cancelTheProcess(String row) {
        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        PropStrength__Application_Booking__c bk = [Select Id, Termination_Process_Status__c From PropStrength__Application_Booking__c Where id=:bookingId];
        
        if (bk.Termination_Process_Status__c == 'Termination Cancelled') {
            return 'Already Cancelled';
        }
        bk.Termination_Process_Status__c = 'Termination Cancelled';
        update bk;
        return 'Cancelled';
    }

    @AuraEnabled
    public static String validateEslamFinalNotice(String row) {

        /*check if the logged in user profile is Eslam profile
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if (profileName != 'System Administrator')
            return 'Unauthorized';*/

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        PropStrength__Application_Booking__c bk = [Select Id, (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r) 
                            From PropStrength__Application_Booking__c
                            Where id=:bookingId];
        
        /*if (bk.Final_Notice_Eslam_Approval_Status__c != 'Approved') {
            return 'Unapproved';
        }*/
        //Logic to send the final notice/
        if(!bk.PropStrength__Applicant_Details__r.isEmpty()) {
            List<EmailMessage> activityList = new List<EmailMessage>();

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(PropStrength__Applicant_Detail__c appDet : bk.PropStrength__Applicant_Details__r) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/FinalNoticeDocument?id='+bookingId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                mail.setSubject('Final Notice Document');
                mail.setplaintextbody('Dear '+appDet.PropStrength__Customer_Name__c+',\n\nHere you can find your Final Notice Document.\nWe look forward to serving you in the future.\n\n\nBest regards,\nSOBHA LLC');
                mail.setToAddresses(new List<String>{appDet.PropStrength__Applicant_Email__c});
                
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('Final Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);

                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = appDet.PropStrength__Applicant_Email__c;
                newEmail.Subject = 'Final Notice Document';
                newEmail.TextBody = mail.getPlainTextBody();
                newEmail.RelatedToId = bookingId;
                newEmail.Status = '3';
                activityList.add(newEmail);
            }
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    // Messaging.sendEmail(emailList);
                    
                    // insert activityList;

                    // bk.Final_Notice_Sent_Date__c = System.Now();
                    // update bk;
                }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
                return 'Success';
        } else {
            return 'Applicants not present';
        }
    }

    @AuraEnabled
    public static String validateEslamDLDNotice(String row) {

        /*check if the logged in user profile is Eslam profile
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if (profileName != 'System Administrator')
            return 'Unauthorized';*/

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        PropStrength__Application_Booking__c bk = [Select Id, (SELECT Id, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r) 
                            From PropStrength__Application_Booking__c
                            Where id=:bookingId];
        
        /*if (bk.Final_Notice_Eslam_Approval_Status__c != 'Approved') {
            return 'Unapproved';
        }*/
        //Logic to send the final notice/
        if(!bk.PropStrength__Applicant_Details__r.isEmpty()) {
            List<EmailMessage> activityList = new List<EmailMessage>();

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(PropStrength__Applicant_Detail__c appDet : bk.PropStrength__Applicant_Details__r) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String frmsrc = '/apex/DLDNoticeDocument?id='+bookingId;
                PageReference p1 = new PageReference(frmsrc);
                blob content;
                if(Test.isRunningTest()) { 
                    content = blob.valueOf('Unit.Test');
                } else {
                    content = p1.getContentAsPDF();
                }
                System.debug(content);
                mail.setSubject('DLD Notice Document');
                mail.setplaintextbody('Dear '+appDet.PropStrength__Customer_Name__c+',\n\nHere you can find your DLD Notice Document.\nWe look forward to serving you in the future.\n\n\nBest regards,\nSOBHA LLC');
                mail.setToAddresses(new List<String>{appDet.PropStrength__Applicant_Email__c});
                
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setFileName('DLD Notice.pdf');
                efa1.setBody(content);   
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
                System.debug(mail);
                emailList.add(mail);

                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = appDet.PropStrength__Applicant_Email__c;
                newEmail.Subject = 'DLD Notice Document';
                newEmail.TextBody = mail.getPlainTextBody();
                newEmail.RelatedToId = bookingId;
                newEmail.Status = '3';
                activityList.add(newEmail);
            }
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    // Messaging.sendEmail(emailList);
                    
                    // insert activityList;

                    // bk.DLD_Notice_Sent_Date__c = System.Today();
                    // update bk;
                }
                }catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
                return 'Success';
        } else {
            return 'Applicants not present';
        }
    }

    @AuraEnabled
    public static String sendEslamFinalNotice(String row, String emails) {

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        /*PropStrength__Application_Booking__c bk = [Select Id, Final_Notice_Eslam_Approval_Status__c 
                            From PropStrength__Application_Booking__c
                            Where id=:bookingId];
        bk.Final_Notice_Sent_Date__c = System.now();            
        update bk;*/
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('Booking id : '+bookingId);
        if(bookingId != null){
            PropStrength__Application_Booking__c b = [select Id, 
                                Name, 
                                PropStrength__Primary_Applicant_Name__c, 
                                PropStrength__Applicant_Email__c 
                            From PropStrength__Application_Booking__c 
                            where Id=:bookingId];

            if(b.PropStrength__Applicant_Email__c != null && b.PropStrength__Applicant_Email__c != ''){

                List<ContentDocumentLink> condoclink = [SELECT ContentDocumentId 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId =:b.Id and ContentDocument.title = 'Final Notice'];
                
                if (condoclink.size() < 1) {
                    return 'error';
                }

                List<ContentVersion> cvList = [SELECT VersionData, FileExtension 
                                                    FROM ContentVersion 
                                                    WHERE ContentDocumentId = :condoclink[0].ContentDocumentId 
                                                    AND IsLatest = true];

                Blob fileData = cvList[0].VersionData;

                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(fileData);
                attach.setFileName('FinalNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setSubject('Final Notice For '+b.Name);
                String body = 'Dear '+b.PropStrength__Primary_Applicant_Name__c+ ',<br/><br/>'+
                    'Greetings,<br/><br/>'+
                    'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.<br/><br/>'+
                    'Please find attached the final notice to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.<br/><br/>'+
                    'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.<br/><br/>'+
                    'Best Regards,<br/>'+
                    'CRM Team';
                email.setHtmlBody(body);
                List<String> otherEmails = emails.split(',');
                otherEmails.add(b.PropStrength__Applicant_Email__c);
                email.setToAddresses(otherEmails);
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                mails.add(email);


                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = b.PropStrength__Applicant_Email__c;
                newEmail.Subject = 'Final Notice Document';
                newEmail.TextBody = body;
                newEmail.RelatedToId = bookingId;
                newEmail.Status = '3';
                insert newEmail;


                b.Final_Notice_Sent_Date__c = System.now();            
                update b;
            }
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
            
        }
    

        return 'Success';
    }

    @AuraEnabled
    public static String sendEslamDLDNotice(String row, String emails) {

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        /*PropStrength__Application_Booking__c bk = [Select Id, Final_Notice_Eslam_Approval_Status__c 
                            From PropStrength__Application_Booking__c
                            Where id=:bookingId];
        bk.Final_Notice_Sent_Date__c = System.now();            
        update bk;*/
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('Booking id : '+bookingId);
        if(bookingId != null){
            PropStrength__Application_Booking__c b = [select Id, 
                                Name, 
                                PropStrength__Primary_Applicant_Name__c, 
                                PropStrength__Applicant_Email__c 
                            From PropStrength__Application_Booking__c 
                            where Id=:bookingId];

            if(b.PropStrength__Applicant_Email__c != null && b.PropStrength__Applicant_Email__c != ''){

                List<ContentDocumentLink> condoclink = [SELECT ContentDocumentId 
                                                        FROM ContentDocumentLink 
                                                        WHERE LinkedEntityId =:b.Id and ContentDocument.title = 'DLD Notice'];
                
                if (condoclink.size() < 1) {
                    return 'error';
                }

                List<ContentVersion> cvList = [SELECT VersionData, FileExtension 
                                                    FROM ContentVersion 
                                                    WHERE ContentDocumentId = :condoclink[0].ContentDocumentId 
                                                    AND IsLatest = true];

                Blob fileData = cvList[0].VersionData;

                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(fileData);
                attach.setFileName('DLDNotice.pdf');
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setSubject('DLD Notice For '+b.Name);
                String body = 'Dear '+b.PropStrength__Primary_Applicant_Name__c+ ',<br/><br/>'+
                    'Greetings,<br/><br/>'+
                    'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.<br/><br/>'+
                    'Please find attached the DLD notice to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.<br/><br/>'+
                    'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.<br/><br/>'+
                    'Best Regards,<br/>'+
                    'CRM Team';
                email.setHtmlBody(body);
                List<String> otherEmails = new List<String>();
                if(emails != null)
                   otherEmails =  emails.split(',');
                otherEmails.add(b.PropStrength__Applicant_Email__c);
                email.setToAddresses(otherEmails);
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                mails.add(email);

                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = b.PropStrength__Applicant_Email__c;
                newEmail.Subject = 'DLD Notice Document';
                newEmail.TextBody = body;
                newEmail.RelatedToId = bookingId;
                newEmail.Status = '3';
                insert newEmail;

                b.DLD_Notice_Sent_Date__c = System.Today();
                update b;
            }
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);

            
        }
    

        return 'Success';
    }
    
    @AuraEnabled
    public static void updateAllocation(String bookingId, String allocation){
        try {
            PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId); //Cancellation_Allocation__c=allocation
            upsert b;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateBookingTerminationStatus(String row, String status){
        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));
        System.debug(bookingId);
        System.debug(status);
        if(status == 'Approve') {
            PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId, Termination_Process_Status__c = 'Approved for Termination', Approved_for_Termination_Date__c = System.Today());
            update b;
        } else if(status == 'Resubmit') {
            PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId, Termination_Process_Status__c = 'Resubmitted to Audit');
            update b;
        }
    }

    @AuraEnabled
    public static void updateBookingTerminationStatusMultiple(List<String> bookingIdsList, String status){
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        for(String bookingId : bookingIdsList) {
            System.debug(bookingId);
            System.debug(status);
            if(status.contains('Approve')) {
                PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId, Termination_Process_Status__c = 'Approved for Termination', Approved_for_Termination_Date__c = System.Today());
                updateList.add(b);
            } else if(status.contains('Resubmit')) {
                PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId, Termination_Process_Status__c = 'Resubmitted to Audit');
                updateList.add(b);
            }
        }
        if(!updateList.isEmpty()) {
            update updateList;
        }
    }
    
    @AuraEnabled
    public static boolean returnToCollections(String bookingId){
       try {
            PropStrength__Application_Booking__c bookRec = new PropStrength__Application_Booking__c();
            bookRec.Id = bookingId.substring(1,bookingId.length());
            bookRec.Termination_Process_Status__c = 'Submitted to collections by DLD';
            bookRec.Submitted_to_Collection_by_DLD_Date__c = System.today();
            update bookRec;
            return true;
                
           
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

	@AuraEnabled
    public static boolean isDLDProfile(){
        User currentUser = [SELECT Id, Profile.name FROM User Where Id =: UserInfo.getUserId()];
        return currentUser.Profile.Name == 'DLD Team';
    }	
    
    public class BookingWrapper implements Comparable {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public boolean allowPR;
        @AuraEnabled public string bookingIdVal;
        @AuraEnabled public string customerName;
        @AuraEnabled public string customerNameArabic;
        @AuraEnabled public string customerAddressArabic;
        @AuraEnabled public Decimal saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public Decimal milestoneDue;
        @AuraEnabled public Decimal collected;
        @AuraEnabled public long due;
        @AuraEnabled public Decimal fullDue;
        @AuraEnabled public string category;
        @AuraEnabled public string commentsHistory;
        @AuraEnabled public string soaLink;
        //@AuraEnabled public string finalNoticeLink;
        @AuraEnabled public string forfitureNoticeLink;
        @AuraEnabled public string registrationStatus;
        @AuraEnabled public string bookingDate;
        @AuraEnabled public string bucketColor;
        @AuraEnabled public string lastCallAttemptStatus;
        @AuraEnabled public string primaryMobileNumber;
        @AuraEnabled public Decimal age;
        @AuraEnabled public String spaexecuted;
        @AuraEnabled public String titleDeedStatus;
        @AuraEnabled public String preRegstatus;
        @AuraEnabled public Date auditapproveddate;
        @AuraEnabled public Decimal collectedpercentage;
        @AuraEnabled public Decimal duepercentage;
        @AuraEnabled public String cancellationAllocation;
        @AuraEnabled public String commentsremarks;
        @AuraEnabled public String finalNoticeSentDate;
        @AuraEnabled public Datetime developerfinalNoticeSentDate;
        @AuraEnabled public Date finalNoticeSentDateCourier;
        @AuraEnabled public String finalNoticeStatus;
        @AuraEnabled public Date finalNoticeReceivedDate;
        @AuraEnabled public Date forfeitureNoticeSentDate;
        @AuraEnabled public Date forfeitureNoticeSentDateCourier;
        @AuraEnabled public String forfeitureNoticeReceivedByCustomer;
        @AuraEnabled public Decimal forfeitedAmount;
        @AuraEnabled public String amountPaidByCustomer;
        @AuraEnabled public String finalNoticeReviewLink;
        @AuraEnabled public String projectCompletionPercentageArabic;
        @AuraEnabled public Date developerFinalNoticeSentDateCourier;
        @AuraEnabled public String developerFinalNoticeStatus;
        @AuraEnabled public String terminationProcessStatus;
        @AuraEnabled public Date terminationCompletionDate;
        @AuraEnabled public String dldNoticeStatus;
        @AuraEnabled public String dldNoticeStatusCategory;
        @AuraEnabled public String projectName;
        @AuraEnabled public string demandRaised;
        @AuraEnabled public string terminationremarks;
        @AuraEnabled public Decimal balance;
        @AuraEnabled public String ppdId;
        @AuraEnabled public String ppdName;
        
        public BookingWrapper(){
            unitName = '';
            unitId = '';
            bookingName = '';
            bookingId = '';
            bookingIdVal = '';
            customerName = '';
            saleValue = 0;
            demands = 0;
            milestoneDue = 0;
            collected = 0;
            due = 0;
            fullDue = 0;
            category = '';
            commentsHistory = '';
            soaLink = '';
            registrationStatus = '';
            bookingDate = '';
            bucketColor = '';
            lastCallAttemptStatus = '';
            spaexecuted = '';
            preRegstatus = '';
            titleDeedStatus = '';
            demandRaised = '';
            balance = 0;
            ppdId = '';
            ppdName = '';
        }

        
        /*public void setCollected(String value) {
            value = value.replace(',','');
            this.collected = Decimal.valueOf(value);
        }*/
        
        public Integer compareTo(Object objToCompare) {
            if(category == 'Advance Payments')
                return Integer.valueOf(((BookingWrapper)objToCompare).fullDue - fullDue);
            else
                return Integer.valueOf(((BookingWrapper)objToCompare).due - due);
        }
    }
}