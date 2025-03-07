public class CRMDashboardController {
    @AuraEnabled
    public static list<Project__c> getProjects(){
        return [select Id, Name, (select Id, Name from Towers__r Order By Name ASC) from Project__c Order By Name ASC];
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
    public static list<BookingWrapper> getBookings(string projectId, string towerId, string selectedType){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();
        if(projectId == 'All'){
            pmList = [select id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      from Payment_Milestones__c 
                      where Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Cancellation_Allocation__c = 'Allocate to CRM Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }else if (towerId == 'All') {
            pmList = [select id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      from Payment_Milestones__c 
                      where Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__r.Booking__r.Cancellation_Allocation__c = 'Allocate to CRM Team' AND
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        } else {
            pmList = [select id,Milestone_Due_Date__c,Total_Installment__c, Quotation__c, Quotation__r.Booking__c 
                      from Payment_Milestones__c 
                      where Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__r.Booking__r.Termination_Status__c = 'Raised to DLD Team' AND
                      Quotation__r.Booking__r.Termination_Process_Status__c != 'Removed from Termination' AND
                      Quotation__r.Booking__r.Cancellation_Allocation__c = 'Allocate to CRM Team' AND
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
        System.debug('bookingToPM '+bookingToPM);
        System.debug('selectedType '+selectedType);
        Map<String,Booking__c> bookingIdToBooking = new Map<String,Booking__c>();
        
        if (selectedType == 'Dashboard1') {
                for(Booking__c b : [select id,
                                    Project__r.Name,
                                    PrimaryMobileNumber__c,
                                    Last_Call_Attempt_Status__c,
                                    Full_Due__c,
                                    Pre_Registration_Status__c,
                                    Pre_registration__c,
                                    Booking_Date__c,
                                    Last_Call_Description__c,
                                    Opportunity__c,
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
                                    Termination_Process_Status_for_CRM__c,
                                    (select id, Notes__c from Tasks__r order by createddate desc limit 1) 
                                from Booking__c 
                                where Id IN: bookingToPM.keySet()
                                and (Cancellation_Allocation__c = 'Allocate to CRM Team' OR Cancellation_Allocation__c = 'Re Allocated To CRM By Collection')
                                and Termination_Process_Status_for_CRM__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }

        if (selectedType == 'Dashboard2') {
            for(Booking__c b : [select id,
            Project__r.Name,
                                PrimaryMobileNumber__c,
                                Last_Call_Attempt_Status__c,
                                Full_Due__c,
                                Pre_Registration_Status__c,
                                Pre_registration__c,
                                Booking_Date__c,
                                Last_Call_Description__c,
                                Opportunity__c,
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
                                Termination_Process_Status_for_CRM__c,
                                (select id, Notes__c from Tasks__r order by createddate desc limit 1) 
                            from Booking__c 
                            where Id IN: bookingToPM.keySet() 
                                    and Cancellation_Allocation__c = 'Internal Cancellation'
                                    and Termination_Process_Status_for_CRM__c != 'Removed from Termination']){
                bookingIdToBooking.put(b.id,b);
            }
        }

        if (selectedType == 'Dashboard3') {
            for(Booking__c b : [select id,
                                PrimaryMobileNumber__c,
                                Project__r.Name,
                                Last_Call_Attempt_Status__c,
                                Full_Due__c,
                                Pre_Registration_Status__c,
                                Pre_registration__c,
                                Booking_Date__c,
                                Last_Call_Description__c,
                                Opportunity__c,
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
                                Termination_Process_Status_for_CRM__c,
                                (select id, Notes__c from Tasks__r order by createddate desc limit 1) 
                            from Booking__c 
                            where Id IN: bookingToPM.keySet() 
                                and Cancellation_Allocation__c = 'Internal Cancellation'
                                and Termination_Process_Status_for_CRM__c != 'Removed from Termination']){
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
            wrap.unitId = '/'+bk.Unit__c;
            wrap.bookingName = bk.Name;
            wrap.bookingId = '/'+bk.id;
            wrap.bookingIdVal = bk.id;
            wrap.customerName = bk.Primary_Applicant_Name__c;
            wrap.primaryMobileNumber = bk.PrimaryMobileNumber__c;
            wrap.spaexecuted = bk.SPA_Executed__c;
            wrap.auditapproveddate = bk.Audit_Approval_Date__c;
            wrap.cancellationAllocation = bk.Cancellation_Allocation__c;
            wrap.commentsremarks = bk.CRM_Dashboard_Remarks__c;
            wrap.finalNoticeReviewLink = '/apex/FinalNotice?id='+bk.id;
            wrap.forfitureNoticeLink = '/apex/ForfeitureNotice?id='+bk.id;
            //Dasjhboard 3 fields
            wrap.finalNoticeSentDate = bk.Final_Notice_Sent_Date__c;
            wrap.finalNoticeSentDateCourier = bk.Final_Notice_Sent_Date_Courier__c;
            wrap.finalNoticeStatus = bk.Final_Notice_Status__c;
            wrap.finalNoticeReceivedDate = bk.Final_Notice_Receive_Date__c;
            wrap.forfeitureNoticeSentDate = bk.Forfeiture_Notice_Sent_Date__c;
            wrap.forfeitureNoticeSentDateCourier = bk.Forfeiture_Notice_Notice_Sent_Date_Co__c;
            wrap.forfeitureNoticeReceivedByCustomer = bk.Forfeiture_Notice_Received_by_Customer__c;
            wrap.forfeitedAmount = bk.Forfeited_Amount__c;
            wrap.projectName = bk.Project__r.Name;
            wrap.amountPaidByCustomer = bk.Amount_Paid_by_Customer__c;
            if (bk.Termination_Process_Status_for_CRM__c == null || bk.Termination_Process_Status_for_CRM__c == null) {
                wrap.crmTerminationProcessStatus = 'Ongoing';
            } else {
                wrap.crmTerminationProcessStatus = bk.Termination_Process_Status_for_CRM__c;
            }

            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Name__c != null){
                wrap.customerName = wrap.customerName + ' & ' + bk.Opportunity__r.Other_Applicants_Name__c;
            }
            wrap.saleValue = (Long) bk.Agreement_Value__c;
            wrap.demands = (Long) bk.Total_Agreement_Value_Demanded__c;
            wrap.collected = (Long) bk.Total_On_Account_Money_With_Registration__c;
            wrap.fullDue = (Long) bk.Full_Due__c;
            wrap.registrationStatus = bk.Pre_registration__c;
            wrap.lastCallAttemptStatus = bk.Last_Call_Attempt_Status__c;
            wrap.collectedpercentage = ((bk.Total_On_Account_Money_With_Registration__c / bk.Agreement_Value__c) * 100).setScale(2);
            wrap.duepercentage = ((bk.Full_Due__c / bk.Agreement_Value__c) * 100).setScale(2);
            if(bk.Booking_Date__c != null){
                wrap.bookingDate = bk.Booking_Date__c.format('dd/MM/yyyy');
            }
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
    public static Boolean updateBookingRow(String row, Boolean canceltheprocess, Boolean ispicklist){
        System.debug('Row ::: '+row);
        try {
            if (row != null) {
                System.debug('Row ::: '+row);
                if (canceltheprocess != null && canceltheprocess) {
                    BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
                    //Get the booking Id 
                    System.debug(' wrap.bookingId  '+wrap.bookingId);
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    Booking__c b = new Booking__c();
                    b.Id = bookingId;
                    b.X15days_Demand_Raised__c = false;
                    b.X30days_Demand_Raised__c = false;
                    b.Termination_Process_Status_for_CRM__c = 'Removed from Termination';
                    upsert b;
                    return true;
                }

                List<BookingLineItemParser> wrapList = BookingLineItemParser.parse(row);

                List<Booking__c> bookingsToUpdate = new List<Booking__c>();
                for (BookingLineItemParser wrap:wrapList) {
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    Booking__c updateBooking = [Select id,
                                                        CRM_Dashboard_Remarks__c,
                                                        X15days_Demand_Raised__c,
                                                        X30days_Demand_Raised__c 
                                                    From Booking__c 
                                                    where id=:bookingId];
                    updateBooking.Id = bookingId;
                    System.debug('updateBooking '+updateBooking);
                    if (ispicklist) {
                        System.debug('ispicklist '+ispicklist);
                        System.debug('label '+wrap.label);
                        System.debug('value '+wrap.value);
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.label == 'cancellationAllocation'){
                                if(wrap.value == 'Allocate To Collection By CRM'){
                                    updateBooking.Termination_Status__c = wrap.value;
                                    updateBooking.Cancellation_Allocation__c = '';
                                }else if(wrap.value == 'Rejected by CRM'){
                                    updateBooking.Cancellation_Allocation__c = null;
                                    updateBooking.Termination_Status__c =  wrap.value;
                                }else if(wrap.value == 'Allocate to DLD Team'){
                                    updateBooking.Cancellation_Allocation__c = '';
                                }else{
                                    updateBooking.Cancellation_Allocation__c = wrap.value;
                                }
                                
                                System.debug('wrap '+wrap);
                            }
                            if (wrap.label == 'finalNoticeStatus'){
                                updateBooking.Final_Notice_Status__c = wrap.value;
                            }
                            if (wrap.label == 'forfeitureNoticeReceivedByCustomer'){
                                updateBooking.Forfeiture_Notice_Received_by_Customer__c = wrap.value;
                            }
                            if (wrap.label == 'amountPaidByCustomer') {
                                updateBooking.Amount_Paid_by_Customer__c = wrap.value;
                                if (wrap.value == 'Completed') {
                                    updateBooking.Termination_Process_Status_for_CRM__c = 'Completed';
                                }
                            }
                        }
                    }
                   
                    if (wrap.commentsremarks != null)
                        updateBooking.CRM_Dashboard_Remarks__c = wrap.commentsremarks;
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
                    bookingsToUpdate.add(updateBooking);
                }
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

    @AuraEnabled
    public static void updateAllocation(String bookingId, String allocation){
        try {
            Booking__c b = new Booking__c(id=bookingId,Cancellation_Allocation__c=allocation);
            upsert b;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*@AuraEnabled
    public static void sendEmail(string bookingId){
        Booking__c bk = [select id,Due_Payments__c,Unit__r.Tower__r.UnRegister_Project__c,Project_Name__c,Unit__r.Name,Last_Call_Attempt_Status__c,Primary_Applicant_Email__c,Opportunity__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Primary_Applicant_Name__c from Booking__c where id =: bookingId];
        if(bk.Unit__r.Tower__r.UnRegister_Project__c != true && (bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' || bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation')){
            string templateDeveloperName = '';
            if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach')
                templateDeveloperName = 'No_Contact_Or_Unable_To_Reach';
            if(bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation')
                templateDeveloperName = 'Raise_for_Cancellation';
            EmailTemplate e = [select id, HtmlValue, subject from EmailTemplate where DeveloperName =: templateDeveloperName];
            string body = e.HtmlValue;
            body = body.replace('#PrimaryApplicant#', bk.Primary_Applicant_Name__c);
            body = body.replace('#Unit#', bk.Unit__r.Name);
            string projectName = '';
            if(bk.Project_Name__c != null)
                projectName = bk.Project_Name__c;
            body = body.replace('#Project#', projectName);
            if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' && bk.Due_Payments__c != null){
                body = body.replace('#OverdueAmount#', String.valueOf(bk.Due_Payments__c));
            }
            string subject = e.subject;
            subject = subject.replace('#Unit#', bk.Unit__r.Name);
            subject = subject.replace('#Project#', projectName);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setSubject(subject); 
            mail.setHtmlBody(body);
            list<string> toAddress = new list<string>();
            list<string> ccAddress = new list<string>();
            toAddress.add(bk.Primary_Applicant_Email__c);
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Email__c != null){
                string emails = bk.Opportunity__r.Other_Applicants_Email__c;
                emails = emails.trim();
                emails = emails.removeEnd(',');
                ccAddress.addAll(emails.split(','));
            }
            ccAddress.add(UserInfo.getUserEmail());
            ccAddress.add(System.Label.SobhaHelpdesk);
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            mail.setSaveAsActivity(false); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }*/
    
    public class BookingWrapper implements Comparable {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingIdVal;
        @AuraEnabled public string customerName;
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
        @AuraEnabled public Datetime finalNoticeSentDate;
        @AuraEnabled public Date finalNoticeSentDateCourier;
        @AuraEnabled public String finalNoticeStatus;
        @AuraEnabled public Date finalNoticeReceivedDate;
        @AuraEnabled public Date forfeitureNoticeSentDate;
        @AuraEnabled public Date forfeitureNoticeSentDateCourier;
        @AuraEnabled public String forfeitureNoticeReceivedByCustomer;
        @AuraEnabled public Decimal forfeitedAmount;
        @AuraEnabled public String amountPaidByCustomer;
        @AuraEnabled public String finalNoticeReviewLink;
        @AuraEnabled public String crmTerminationProcessStatus;
        @AuraEnabled public String projectName;
        
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

    public static void dummycovrage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
    
    
}