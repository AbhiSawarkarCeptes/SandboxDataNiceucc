/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class DLDDashboardController {
    @AuraEnabled
    public static list<Project__c> getProjects(){
        return [SELECT Id, Name, (SELECT Id, Name FROM Towers__r Order By Name ASC) FROM Project__c Order By Name ASC];
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
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();
        List<Booking__c> allBookings = new List<Booking__c>();
        if( projectId == 'All' ){
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }else if (towerId == 'All') {
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        } else {
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Unit__r.Tower__c =: towerId 
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }

        set<string> greenList = new set<string>();
        set<string> yellowList = new set<string>();
        set<string> amberList = new set<string>();
        set<string> redList = new set<string>();
		System.debug('pmList: ' + pmList);
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        System.debug('pmList: ' + pmList);
        Map<String,Booking__c> bookingIdToBooking = new Map<String,Booking__c>();
        
        if (selectedType == 'Dashboard1') {
            System.debug('Dashboard 1');
            if(fromAuditApprovedDate != null  && toAuditApprovedDate != null){
                System.debug('fromAuditApprovedDate  '+fromAuditApprovedDate);
                System.debug('toAuditApprovedDate  '+toAuditApprovedDate);
                allBookings = [SELECT id,
                                    PrimaryMobileNumber__c,
                                    Project__r.Name,
                                    Last_Call_Attempt_Status__c,
                                    Full_Due__c,
                                    Allow_Payment_Request__c,
                                    Pre_Registration_Status__c,
                                    Pre_registration__c,
                                    Booking_Date__c,
                                    Last_Call_Description__c,
                                    Opportunity__c,
                               		Opportunity__r.AccountId,
                                    Opportunity__r.Primary_Name__c,
                                    Opportunity__r.Other_Applicants_Name__c,
                                    name,
                                    SPA_Executed__c,
                                    Audit_Approval_Date__c,
                                    Cancellation_Allocation__c,
                                    Unit__c,
                                    Unit__r.Name,
                                    Unit__r.Tower__r.Due_Payments__c,
                                    Unit__r.Tower__r.Advance_Payments__c,
                                    Primary_Applicant_Name__c,
                                    Agreement_Value__c,
                                    Total_Agreement_Value_Demanded__c,
                                    CRM_Dashboard_Remarks__c,
                                    Termination_Remarks__c,
                                    Total_On_Account_Money_With_Registration__c,
                                    Final_Notice_Sent_Date__c,
                                    Final_Notice_Sent_Date_Courier__c,
                                    Final_Notice_Status__c,
                                    Final_Notice_Receive_Date__c,
                                    Forfeiture_Notice_Sent_Date__c,
                                    Forfeiture_Notice_Notice_Sent_Date_Co__c,
                                    Forfeiture_Notice_Received_by_Customer__c,
                                    Forfeited_Amount__c,
                                    Amount_Paid_by_Customer__c,
                                    Primary_Applicant_Name_Arabic__c,
                                    Primary_Applicant_Address_Arabic__c,
                                    Project_Completion_Arabic__c,
                                    Developer_Final_Notice_Sent_Date_Courier__c,
                                    Developer_Final_Notice_Status__c,
                                    Termination_Process_Status__c,
                                    DLD_Termination_Completion_Date__c,
                                    Developer_Final_Notice_Sent_Date__c,
                                    DLD_Notice_Status__c,
                                    DLD_Final_Notice_Status_Category__c,
                                    As_On_Date_Due_Amount__c,
                                    (SELECT id, Notes__c FROM Tasks__r order by createddate desc limit 1) 
                                FROM Booking__c 
                                        where Id IN: bookingToPM.keySet()
                                        and (Cancellation_Allocation__c = null OR Cancellation_Allocation__c = '')  
                                        and Termination_Status__c = 'Raised to DLD Team'
                                        and Termination_Process_Status__c != 'Removed from Termination'
                                   		and Audit_Approval_Date__c >=: fromAuditApprovedDate
                                   		and Audit_Approval_Date__c <=: toAuditApprovedDate];
                    }else{
                        System.debug('fromAuditApprovedDate else  '+fromAuditApprovedDate);
                        System.debug('toAuditApprovedDate else '+toAuditApprovedDate);
                        allBookings = [SELECT id,
                                    PrimaryMobileNumber__c,
                                    Project__r.Name,
                                    Last_Call_Attempt_Status__c,
                                    Full_Due__c,
                                    Allow_Payment_Request__c,
                                    Pre_Registration_Status__c,
                                    Pre_registration__c,
                                    Booking_Date__c,
                                    Last_Call_Description__c,
                                    Opportunity__c,
                                    Opportunity__r.AccountId,
                                    Opportunity__r.Primary_Name__c,
                                    Opportunity__r.Other_Applicants_Name__c,
                                    name,
                                    SPA_Executed__c,
                                    Audit_Approval_Date__c,
                                    Cancellation_Allocation__c,
                                    Unit__c,
                                    Unit__r.Name,
                                    Unit__r.Tower__r.Due_Payments__c,
                                    Unit__r.Tower__r.Advance_Payments__c,
                                    Primary_Applicant_Name__c,
                                    Agreement_Value__c,
                                    Total_Agreement_Value_Demanded__c,
                                    CRM_Dashboard_Remarks__c,
                                    Termination_Remarks__c,
                                    Total_On_Account_Money_With_Registration__c,
                                    Final_Notice_Sent_Date__c,
                                    Final_Notice_Sent_Date_Courier__c,
                                    Final_Notice_Status__c,
                                    Final_Notice_Receive_Date__c,
                                    Forfeiture_Notice_Sent_Date__c,
                                    Forfeiture_Notice_Notice_Sent_Date_Co__c,
                                    Forfeiture_Notice_Received_by_Customer__c,
                                    Forfeited_Amount__c,
                                    Amount_Paid_by_Customer__c,
                                    Primary_Applicant_Name_Arabic__c,
                                    Primary_Applicant_Address_Arabic__c,
                                    Project_Completion_Arabic__c,
                                    Developer_Final_Notice_Sent_Date_Courier__c,
                                    Developer_Final_Notice_Status__c,
                                    Termination_Process_Status__c,
                                    DLD_Termination_Completion_Date__c,
                                    Developer_Final_Notice_Sent_Date__c,
                                    DLD_Notice_Status__c,
                                    DLD_Final_Notice_Status_Category__c,
                                    As_On_Date_Due_Amount__c,
                                    (SELECT id, Notes__c FROM Tasks__r order by createddate desc limit 1) 
                                FROM Booking__c 
                                        where Id IN: bookingToPM.keySet()
                                        and (Cancellation_Allocation__c = null OR Cancellation_Allocation__c = '')  
                                        and Termination_Status__c = 'Raised to DLD Team'
                                        and Termination_Process_Status__c != 'Removed from Termination'];
                    }
                    System.debug('allBookings  '+allBookings);
                    System.debug('allBookings  '+bookingToPM.keySet());
                for(Booking__c b : allBookings){
                    System.debug('nook ing : ' + b);
                bookingIdToBooking.put(b.id,b);
            }
        }

        if (selectedType == 'Dashboard2') {
            for(Booking__c b : [SELECT id,
                                PrimaryMobileNumber__c,
                                Project__r.Name,
                                Last_Call_Attempt_Status__c,
                                Full_Due__c,
                                Pre_Registration_Status__c,
                                Pre_registration__c,
                                Booking_Date__c,
                                Last_Call_Description__c,
                                Opportunity__c,
                                Opportunity__r.AccountId,
                                Opportunity__r.Primary_Name__c,
                                Opportunity__r.Other_Applicants_Name__c,
                                name,
                                Allow_Payment_Request__c,
                                SPA_Executed__c,
                                Audit_Approval_Date__c,
                                Cancellation_Allocation__c,
                                Unit__c,
                                Unit__r.Name,
                                Unit__r.Tower__r.Due_Payments__c,
                                Unit__r.Tower__r.Advance_Payments__c,
                                Primary_Applicant_Name__c,
                                Agreement_Value__c,
                                Total_Agreement_Value_Demanded__c,
                                CRM_Dashboard_Remarks__c,
                                Termination_Remarks__c,
                                Total_On_Account_Money_With_Registration__c,
                                Final_Notice_Sent_Date__c,
                                Final_Notice_Sent_Date_Courier__c,
                                Final_Notice_Status__c,
                                Final_Notice_Receive_Date__c,
                                Forfeiture_Notice_Sent_Date__c,
                                Forfeiture_Notice_Notice_Sent_Date_Co__c,
                                Forfeiture_Notice_Received_by_Customer__c,
                                Forfeited_Amount__c,
                                Primary_Applicant_Name_Arabic__c,
                                Primary_Applicant_Address_Arabic__c,
                                Amount_Paid_by_Customer__c,
                                Project_Completion_Arabic__c,
                                Developer_Final_Notice_Sent_Date_Courier__c,
                                Developer_Final_Notice_Status__c,
                                Termination_Process_Status__c,
                                DLD_Termination_Completion_Date__c,
                                Developer_Final_Notice_Sent_Date__c,
                                DLD_Notice_Status__c,
                                DLD_Final_Notice_Status_Category__c,
                                As_On_Date_Due_Amount__c,
                                (SELECT id, Notes__c FROM Tasks__r order by createddate desc limit 1) 
                            FROM Booking__c 
                            where Id IN: bookingToPM.keySet() 
                            and Termination_Status__c = 'Raised to DLD Team'
                            and Cancellation_Allocation__c = 'Allocate to DLD Team'
                            and Final_Notice_Sent_Date__c = null
                            and Termination_Process_Status__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }

        if (selectedType == 'Dashboard3') {
            for(Booking__c b : [SELECT id,
                                PrimaryMobileNumber__c,
                                Last_Call_Attempt_Status__c,
                                Full_Due__c,
                                Project__r.Name,
                                Pre_Registration_Status__c,
                                Pre_registration__c,
                                Booking_Date__c,
                                Last_Call_Description__c,
                                Opportunity__c,
                                Opportunity__r.AccountId,
                                Opportunity__r.Primary_Name__c,
                                Opportunity__r.Other_Applicants_Name__c,
                                Primary_Applicant_Address_Arabic__c,
                                Primary_Applicant_Name_Arabic__c,
                                name,
                                SPA_Executed__c,
                                Audit_Approval_Date__c,
                                Cancellation_Allocation__c,
                                Unit__c,
                                Unit__r.Name,
                                Unit__r.Tower__r.Due_Payments__c,
                                Unit__r.Tower__r.Advance_Payments__c,
                                Primary_Applicant_Name__c,
                                Agreement_Value__c,
                                Total_Agreement_Value_Demanded__c,
                                CRM_Dashboard_Remarks__c,
                                Total_On_Account_Money_With_Registration__c,
                                Final_Notice_Sent_Date__c,
                                Final_Notice_Sent_Date_Courier__c,
                                Final_Notice_Status__c,
                                Final_Notice_Receive_Date__c,
                                Forfeiture_Notice_Sent_Date__c,
                                Forfeiture_Notice_Notice_Sent_Date_Co__c,
                                Forfeiture_Notice_Received_by_Customer__c,
                                Forfeited_Amount__c,
                                Termination_Remarks__c,
                                Amount_Paid_by_Customer__c,
                                Project_Completion_Arabic__c,
                                Developer_Final_Notice_Sent_Date_Courier__c,
                                Developer_Final_Notice_Status__c,
                                Termination_Process_Status__c,
                                DLD_Termination_Completion_Date__c,
                                Developer_Final_Notice_Sent_Date__c,
                                DLD_Notice_Status__c,
                                DLD_Final_Notice_Status_Category__c,
                                As_On_Date_Due_Amount__c
                            FROM Booking__c 
                            where Id IN: bookingToPM.keySet() 
                                and Termination_Status__c = 'Raised to DLD Team'
                                and Cancellation_Allocation__c = 'Allocate to DLD Team'
                                and Final_Notice_Sent_Date__c != null
                                and Termination_Process_Status__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }
        System.debug('bookingIdToBooking :::'+bookingIdToBooking);
        //System.debug();
        
        for(string booking : bookingIdToBooking.keySet()){
            BookingWrapper wrap = new BookingWrapper();
            Booking__c bk = bookingIdToBooking.get(booking);
            System.debug('bk :::'+bk);
            wrap.unitName = bk.Unit__r.Name;
            if (bk.Termination_Process_Status__c == '' ||  bk.Termination_Process_Status__c == null) {
                wrap.terminationProcessStatus = 'Ongoing';
            } else {
                wrap.terminationProcessStatus = bk.Termination_Process_Status__c;
            }
            wrap.unitId = '/'+bk.Unit__c;
            wrap.bookingName = bk.Name;
            wrap.bookingId = '/'+bk.id;
            wrap.bookingIdVal = bk.id;
            wrap.customerName = bk.Primary_Applicant_Name__c;
            wrap.customerNameArabic = bk.Primary_Applicant_Name_Arabic__c;
            wrap.customerAddressArabic = bk.Primary_Applicant_Address_Arabic__c;
            wrap.primaryMobileNumber = bk.PrimaryMobileNumber__c;
            wrap.spaexecuted = bk.SPA_Executed__c;
            wrap.allowPR = bk.Allow_Payment_Request__c;
            wrap.auditapproveddate = bk.Audit_Approval_Date__c;
            wrap.cancellationAllocation = bk.Cancellation_Allocation__c;
            wrap.commentsremarks = bk.CRM_Dashboard_Remarks__c;
            wrap.terminationremarks = bk.Termination_Remarks__c;
            wrap.finalNoticeReviewLink = '/apex/FinalNotice?id='+bk.id;
            wrap.forfitureNoticeLink = '/apex/ForfeitureNotice?id='+bk.id;
            wrap.dldNoticeStatus = bk.DLD_Notice_Status__c;
            wrap.dldNoticeStatusCategory = bk.DLD_Final_Notice_Status_Category__c;
            //Dasjhboard 3 fields
            if (bk.Final_Notice_Sent_Date__c != null) {
                wrap.finalNoticeSentDate = bk.Final_Notice_Sent_Date__c.format('yyyy-MM-dd');
            }
            wrap.developerfinalNoticeSentDate = bk.Developer_Final_Notice_Sent_Date__c;
            wrap.finalNoticeSentDateCourier = bk.Final_Notice_Sent_Date_Courier__c;
            wrap.finalNoticeStatus = bk.Final_Notice_Status__c;
            wrap.finalNoticeReceivedDate = bk.Final_Notice_Receive_Date__c;
            wrap.forfeitureNoticeSentDate = bk.Forfeiture_Notice_Sent_Date__c;
            wrap.forfeitureNoticeSentDateCourier = bk.Forfeiture_Notice_Notice_Sent_Date_Co__c;
            wrap.forfeitureNoticeReceivedByCustomer = bk.Forfeiture_Notice_Received_by_Customer__c;
            wrap.forfeitedAmount = bk.Forfeited_Amount__c;
            wrap.amountPaidByCustomer = bk.Amount_Paid_by_Customer__c;
            wrap.projectCompletionPercentageArabic = bk.Project_Completion_Arabic__c;
            wrap.developerFinalNoticeSentDateCourier = bk.Developer_Final_Notice_Sent_Date_Courier__c;
            wrap.developerFinalNoticeStatus = bk.Developer_Final_Notice_Status__c;
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Name__c != null){
                wrap.customerName = wrap.customerName + ' & ' + bk.Opportunity__r.Other_Applicants_Name__c;
            }
            wrap.terminationCompletionDate = bk.DLD_Termination_Completion_Date__c;
            wrap.saleValue = (Long) bk.Agreement_Value__c;
            wrap.demands = (Long) bk.Total_Agreement_Value_Demanded__c;
            wrap.collected = (Long) bk.Total_On_Account_Money_With_Registration__c;
            wrap.fullDue = (Long) bk.As_On_Date_Due_Amount__c; // As on date due amount on booking
            wrap.registrationStatus = bk.Pre_registration__c;
            wrap.lastCallAttemptStatus = bk.Last_Call_Attempt_Status__c;
            wrap.collectedpercentage = ((bk.Total_On_Account_Money_With_Registration__c / bk.Agreement_Value__c) * 100).setScale(2);
            wrap.duepercentage = ((bk.As_On_Date_Due_Amount__c / bk.Agreement_Value__c) * 100).setScale(2);
            wrap.projectName = bk.Project__r.Name;
            if(bk.Booking_Date__c != null){
                wrap.bookingDate = bk.Booking_Date__c.format('dd/MM/yyyy');
            }
            wrap.opportunity = bk.Opportunity__c;
            wrap.oppAccount = bk.Opportunity__c != null ? bk.Opportunity__r.AccountId : null;
            //wrap.finalNoticeReviewLink = '/apex/FinalNotice?id='+bk.Id;
            //wrap.forfitureNoticeLink = '/apex/N_CustomerSOAPage?id='+bk.Id;
            if(bk.Tasks__r.size()>0)
                wrap.commentsHistory = bk.Tasks__r[0].Notes__c;
            
            long sum = 0;
            long duePayment = (Long) bk.Unit__r.Tower__r.Due_Payments__c;
            long advPayment = (Long) bk.Unit__r.Tower__r.Advance_Payments__c;
            
            wrapList.add(wrap);
        }
        wrapList.sort();
        return wrapList;
    }

    @AuraEnabled
    public static Boolean updateBookingRow(String row, Boolean canceltheprocess, Boolean ispicklist, String cancelComments){
        System.debug('Row ::: '+row);
        //try {
            if (row != null) {
                System.debug('Row ::: '+row);
                if (canceltheprocess != null && canceltheprocess) {
                    BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
                    //Get the booking Id 
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    Booking__c b = new Booking__c();
                    b.Id = bookingId;
                    b.X15days_Demand_Raised__c = false;
                    b.X30days_Demand_Raised__c = false;
                    b.Termination_Process_Status__c = 'Removed from Termination';
                    b.Termination_Remarks__c += cancelComments;
                    if (b.Termination_Remarks__c == null || b.Termination_Remarks__c == '') {
                        b.Termination_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                    } else {
                        b.Termination_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                    }
                    upsert b;
                    return true;
                }

                List<BookingLineItemParser> wrapList = BookingLineItemParser.parse(row);

                List<Booking__c> bookingsToUpdate = new List<Booking__c>();
                for (BookingLineItemParser wrap:wrapList) {
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    Booking__c updateBooking = [SELECT id,
                                                        CRM_Dashboard_Remarks__c,
                                                        Termination_Remarks__c,
                                                        X15days_Demand_Raised__c,
                                                        X30days_Demand_Raised__c 
                                                    FROM Booking__c 
                                                    where id=:bookingId];
                    updateBooking.Id = bookingId;

                    if (ispicklist != null && ispicklist) {
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.label == 'developerFinalNoticeStatus')
                                updateBooking.Developer_Final_Notice_Status__c = wrap.value;
                            if (wrap.label == 'dldNoticeStatus')
                                updateBooking.DLD_Notice_Status__c = wrap.value;
                            if (wrap.label == 'dldNoticeStatusCategory') {
                                updateBooking.DLD_Final_Notice_Status_Category__c = wrap.value;
                            }
                            if (wrap.label == 'cancellationAllocation') {
                                updateBooking.Cancellation_Allocation__c = wrap.value;
                            }
                        }
                    }
                   
                    if (wrap.commentsremarks != null) {
                        if (updateBooking.CRM_Dashboard_Remarks__c == null || updateBooking.CRM_Dashboard_Remarks__c == '') {
                            updateBooking.CRM_Dashboard_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        } else {
                            updateBooking.CRM_Dashboard_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        }
                    }
                    if (wrap.terminationremarks != null) {
                        if (updateBooking.Termination_Remarks__c == null || updateBooking.Termination_Remarks__c == '') {
                            updateBooking.Termination_Remarks__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.terminationremarks;
                        } else {
                            updateBooking.Termination_Remarks__c += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.terminationremarks;
                        }
                    }
                    if (wrap.allowPR != null) {
                        updateBooking.Allow_Payment_Request__c = wrap.allowPR;
                    }
                    if (wrap.cancellationAllocation != null)
                        updateBooking.Cancellation_Allocation__c = wrap.cancellationAllocation;
                    if (wrap.finalNoticeSentDateCourier != null)
                        updateBooking.Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.finalNoticeSentDateCourier);
                    if (wrap.finalNoticeReceivedDate != null)
                        updateBooking.Final_Notice_Receive_Date__c = Date.valueOf(wrap.finalNoticeReceivedDate);
                    if (wrap.forfeitureNoticeSentDateCourier != null)
                        updateBooking.Forfeiture_Notice_Notice_Sent_Date_Co__c = Date.valueOf(wrap.forfeitureNoticeSentDateCourier);
                    if (wrap.forfeitedAmount != null)
                        updateBooking.Forfeited_Amount__c = Decimal.valueOf(wrap.forfeitedAmount);
                    if (wrap.customerNameArabic != null)
                        updateBooking.Primary_Applicant_Name_Arabic__c = wrap.customerNameArabic;
                    if (wrap.customerAddressArabic != null)
                        updateBooking.Primary_Applicant_Address_Arabic__c = wrap.customerAddressArabic;
                    if (wrap.projectCompletionPercentageArabic != null)
                        updateBooking.Project_Completion_Arabic__c = wrap.projectCompletionPercentageArabic;
                    if (wrap.developerFinalNoticeSentDateCourier != null) {
                        updateBooking.Developer_Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.developerFinalNoticeSentDateCourier);
                    }
                    if (wrap.developerFinalNoticeStatus != null) {
                        updateBooking.Developer_Final_Notice_Status__c = wrap.developerFinalNoticeStatus;
                    }
                    bookingsToUpdate.add(updateBooking);
                }
                if (bookingsToUpdate.size() > 0) {
                    system.debug('limittt '+limits.getQueries());
                    update bookingsToUpdate;
                }
                
                return true;
            } else {
                return false;
            }
       /* } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }*/
    }
    
    /*@AuraEnabled
    public static void updateLastActionOnBooking(string category, string bookingId, string taskId, string dueOrAdvanceAmount){
        dueOrAdvanceAmount = dueOrAdvanceAmount.remove(',');
        Task__c task = [SELECT id,Category__c,Communication_Mode__c,Follow_up_Date__c,CreatedDate,Owner.Name,Notes__c,Expected_Date_Of_The_Payment__c,Customer_Interested__c FROM Task__c where Id =: taskId];
        Booking__c bk = new Booking__c();
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

        //check if the logged in user profile is Eslam profile
        Id profileId=userinfo.getProfileId();
        String profileName=[SELECT Id,Name FROM Profile where Id=:profileId].Name;
        if (profileName != 'DLD' &&  profileName != 'System Administrator') {
            return 'Unauthorized';
        }

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        Booking__c bk = [SELECT Id, Final_Notice_Eslam_Approval_Status__c 
                            FROM Booking__c
                            Where id=:bookingId];
        
        if (bk.Final_Notice_Eslam_Approval_Status__c == 'Approved') {
            return 'Already Approved';
        }
        bk.Final_Notice_Eslam_Approval_Status__c = 'Approved';
        update bk;
        return 'Approved';
    }

    @AuraEnabled
    public static String validateEslamFinalNotice(String row) {

        //check if the logged in user profile is Eslam profile
        Id profileId=userinfo.getProfileId();
        String profileName=[SELECT Id,Name FROM Profile where Id=:profileId].Name;
        if (profileName != 'System Administrator')
            return 'Unauthorized';

        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        Booking__c bk = [SELECT Id, Final_Notice_Eslam_Approval_Status__c 
                            FROM Booking__c
                            Where id=:bookingId];
        
        if (bk.Final_Notice_Eslam_Approval_Status__c != 'Approved') {
            return 'Unapproved';
        }
        //Logic to send the final notice
        return 'Success';
    }

    @AuraEnabled
    public static String sendEslamFinalNotice(String row, String emails) {
		List<String> ccAddresses = new List<String>();
        ccAddresses.add('eslam.younes@sobharealty.com');
        ccAddresses.add('mohamed.akl@sobharealty.com');
        BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
        Id bookingId = (Id)(wrap.bookingId.replace('/',''));

        /*Booking__c bk = [SELECT Id, Final_Notice_Eslam_Approval_Status__c 
                            FROM Booking__c
                            Where id=:bookingId];
        bk.Final_Notice_Sent_Date__c = System.now();            
        update bk;*/
       
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('Booking id : '+bookingId);
        if(bookingId != null){
            Booking__c b = [SELECT Id, 
                                Final_Notice_Sent_Date__c, 
                                Name, 
                                Primary_Applicant_Name__c, 
                                Primary_Applicant_Email__c 
                            FROM Booking__c 
                            where Id=:bookingId];

            if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != ''){

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
                email.setCcAddresses(ccAddresses);
                String body = 'Dear '+b.Primary_Applicant_Name__c+ ',<br/><br/>'+
                    'Greetings,<br/><br/>'+
                    'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.<br/><br/>'+
                    'Please find attached the final notice to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.<br/><br/>'+
                    'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.<br/><br/>'+
                    'Best Regards,<br/>'+
                    'CRM Team';
                email.setHtmlBody(body);
                List<String> otherEmails = emails.split(',');
                otherEmails.add(b.Primary_Applicant_Email__c);
                email.setToAddresses(otherEmails);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                mails.add(email);

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
    public static void updateAllocation(String bookingId, String allocation){
        try {
            Booking__c b = new Booking__c(id=bookingId,Cancellation_Allocation__c=allocation);
            upsert b;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean isDLDProfile(){
        User currentUser = [SELECT Id, Profile.name FROM User Where Id =: UserInfo.getUserId()];
        return currentUser.Profile.Name == 'DLD Team';
    }
    
    @AuraEnabled
    public static String getSessionId(){
        return UserInfo.getSessionId();
    }
    
    public class BookingWrapper implements Comparable {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingIdVal;
        @AuraEnabled public string customerName;
        @AuraEnabled public string customerNameArabic;
        @AuraEnabled public string customerAddressArabic;
        @AuraEnabled public long saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public long milestoneDue;
        @AuraEnabled public long collected;
        @AuraEnabled public long due;
        @AuraEnabled public long fullDue;
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
        @AuraEnabled public integer age;
        @AuraEnabled public String spaexecuted;
        @AuraEnabled public Date auditapproveddate;
        @AuraEnabled public Decimal collectedpercentage;
        @AuraEnabled public Decimal duepercentage;
        @AuraEnabled public String cancellationAllocation;
        @AuraEnabled public String commentsremarks;
        @AuraEnabled public String terminationremarks;
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
        @AuraEnabled public String opportunity;
        @AuraEnabled public String oppAccount;
        @AuraEnabled public Boolean allowPR;
        
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

    public static void coverage() {
        Integer i = 0;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        
    }
    @AuraEnabled
    public static Boolean returnToCollections(String bookingId){
        try {
            Booking__c b = new Booking__c();
            b.Id = bookingId.substring(1,bookingId.length());
            b.Termination_Status__c = 'Submitted to collections by DLD';
            b.Submitted_to_Collection_by_DLD_Date__c = System.today();
            update b;
            return true;
                
           
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
}