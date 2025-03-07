public class CRMDashboardControllerClone {
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
    public static list<BookingWrapper> getBookings(string projectId, string towerId, string selectedType){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new map<string, list<PropStrength__Payment_Plan_Details__c>>();
        list<PropStrength__Payment_Plan_Details__c> pmList = new list<PropStrength__Payment_Plan_Details__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();
        
        
        if (towerId == 'All') {
            pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                      PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                      (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where (PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                             PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                             PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                             AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                             AND PropStrength__Application_Booking__c != null) OR 
                      ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Re Allocated To CRM By Collection' OR 
                       PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Allocated to CRM Team' )];
        } else {
            pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                      PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,
                      (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where (PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                             PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                             PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                             AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                             AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                             AND PropStrength__Application_Booking__c != null) OR 
                      ( PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Re Allocated To CRM By Collection' OR 
                       PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Allocated to CRM Team')];
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
        
        Map<String,PropStrength__Application_Booking__c> bookingIdToBooking = new Map<String,PropStrength__Application_Booking__c>();
        
        if (selectedType == 'Dashboard1') {            
            for(PropStrength__Application_Booking__c b : [select id,Resubmitted_by_DLD_Reason__c,Termination_Process_Status__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                                                          Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                                                          PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                                                          PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                                                          PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                          Forfeiture_Notice_Notice_Sent_Date_Cour__c,
                                                          Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,Termination_Process_Status_for_CRM__c,
                                                          PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet() 
                                                          AND (Cancellation_Allocation__c = 'Allocate to CRM Team' OR Cancellation_Allocation__c = 'Re Allocated To CRM By Collection')
                                                          and Termination_Process_Status_for_CRM__c != 'Removed from Termination' ]){
                                                              bookingIdToBooking.put(b.id,b);
                                                          }                
            
        }
        
        if (selectedType == 'Dashboard2') {
            for(PropStrength__Application_Booking__c b : [select id,Termination_Process_Status__c,Resubmitted_by_DLD_Reason__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                                                          Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                                                          PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                                                          PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                                                          PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                          Forfeiture_Notice_Notice_Sent_Date_Cour__c,
                                                          Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,Termination_Process_Status_for_CRM__c,
                                                          PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet()
                                                          AND  Cancellation_Allocation__c = 'Internal Cancellation'
                                                          and Termination_Process_Status_for_CRM__c != 'Removed from Termination']){
                                                              bookingIdToBooking.put(b.id,b);
                                                          }
        }
        
        if (selectedType == 'Dashboard3') {
            for(PropStrength__Application_Booking__c b : [select id,Termination_Process_Status__c,Resubmitted_by_DLD_Reason__c,PropStrength__Total_Payment_Received__c,PropStrength__Total_Paid_Percent__c,
                                                          Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c,PropStrength__Total_Payment_Due__c,PropStrength__Total_Due_Percent__c,Allow_Payment_Request__c,CRM_Dashboard_Remarks__c,
                                                          PropStrength__Primary_Customer__r.MobilePhone,SPA_Status__c,Title_Deed_Status__c, Pre_Registration_Status__c,Submitted_to_DLD_for_Termination_Date__c,Final_Notice_Sent_Date__c,DLD_Notice_Status__c,DLD_Notice_Status_Category__c,
                                                          PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Project__r.Name,Final_Notice_Sent_Date_Courier__c,Final_Notice_Receive_Date_Courier__c,Approved_for_Termination_Date__c,
                                                          PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,Developer_Final_Notice_Status__c,DLD_Notice_Sent_Date__c,Termination_Remarks__c,
                                                          Forfeiture_Notice_Notice_Sent_Date_Cour__c,
                                                          Project_Completion_Arabic__c, Customer_Address_Arabic__c, Primary_Applicant_Name_Arabic__c,Forfeited_Amount__c,Amount_paid_by_Customer__c,Termination_Process_Status_for_CRM__c,
                                                          PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet()
                                                          and Cancellation_Allocation__c = 'Internal Cancellation'
                                                          and Termination_Process_Status_for_CRM__c != 'Removed from Termination']){
                                                              bookingIdToBooking.put(b.id,b);
                                                          }
        }
        System.debug('bookingIdToBooking :::'+bookingIdToBooking);
        //System.debug();
        
        for(string booking : bookingToPM.keySet()){
            
            PropStrength__Application_Booking__c bk = bookingIdToBooking.get(booking);
            list<PropStrength__Payment_Plan_Details__c> bpm = bookingToPM.get(booking);
            for(PropStrength__Payment_Plan_Details__c ppd : bpm) {
                if(bookingIdToBooking.containskey(booking)){
                    BookingWrapper wrap = new BookingWrapper();
                    // wrap.ppdId = '/'+ppd.Id;
                    // wrap.ppdName = ppd.Name;
                    /*if(bk.PropStrength__Project__r != null)
wrap.projectName = bk.PropStrength__Project__r.Name;*/
                    wrap.spaexecuted = bk.SPA_Status__c != null ? bk.SPA_Status__c : '';
                    wrap.titleDeedStatus = bk.Title_Deed_Status__c != null ? bk.Title_Deed_Status__c : '';
                    wrap.preRegstatus = bk.Pre_Registration_Status__c != null ? bk.Pre_Registration_Status__c : '';
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingName = bk.Name;
                    wrap.crmTerminationProcessStatus = bk.Termination_Process_Status_for_CRM__c;
                    wrap.customerName = bk.PropStrength__Primary_Applicant_Name__c != null ? bk.PropStrength__Primary_Applicant_Name__c : '';
                    wrap.bookingDate = bk.PropStrength__Booking_Date__c != null ? bk.PropStrength__Booking_Date__c.format() : '';
                    wrap.saleValue = bk.PropStrength__Revised_Total_Sales_Consideration__c != null ? bk.PropStrength__Revised_Total_Sales_Consideration__c : 0;
                    //wrap.demandRaised = (ppd.PropStrength__Received_Payments__r.isEmpty() == FALSE) ? 'TRUE' : '';
                    //wrap.milestoneDue = ppd.PropStrength__Amount_Due_Plus_Tax__c != null ? ppd.PropStrength__Amount_Due_Plus_Tax__c : 0;
                    wrap.collected = bk.PropStrength__Total_Payment_Received__c != null ? bk.PropStrength__Total_Payment_Received__c : 0;
                    wrap.collectedpercentage = bk.PropStrength__Total_Paid_Percent__c != null ? bk.PropStrength__Total_Paid_Percent__c : 0;
                    // wrap.age = ppd.Interest_Ageing__c;
                    // wrap.allowPR = bk.Allow_Payment_Request__c;
                    // wrap.customerNameArabic = bk.Primary_Applicant_Name_Arabic__c;
                    // wrap.customerAddressArabic = bk.Customer_Address_Arabic__c;
                    wrap.forfeitedAmount = bk.Forfeited_Amount__c;
                    wrap.amountPaidByCustomer = bk.Amount_paid_by_Customer__c;
                    // wrap.projectCompletionPercentageArabic = bk.Project_Completion_Arabic__c;
                    wrap.finalNoticeSentDateCourier = bk.Final_Notice_Sent_Date_Courier__c;
                    wrap.Due = bk.PropStrength__Total_Payment_Due__c != null ? bk.PropStrength__Total_Payment_Due__c : 0;
                    wrap.finalNoticeSentDate = bk.Final_Notice_Sent_Date__c != null ? bk.Final_Notice_Sent_Date__c.date().format() : '';
                    wrap.developerFinalNoticeSentDateCourier = bk.Final_Notice_Sent_Date_Courier__c;
                    wrap.duepercentage = bk.PropStrength__Total_Due_Percent__c != null ? bk.PropStrength__Total_Due_Percent__c : 0;
                    wrap.developerFinalNoticeStatus = bk.Developer_Final_Notice_Status__c != null ? bk.Developer_Final_Notice_Status__c : '';
                    wrap.finalNoticeReceivedDate = bk.Final_Notice_Receive_Date_Courier__c;
                    wrap.forfeitureNoticeSentDate = bk.DLD_Notice_Sent_Date__c;
                    wrap.forfeitureNoticeSentDateCourier = bk.Forfeiture_Notice_Notice_Sent_Date_Cour__c;
                    wrap.commentsremarks = bk.CRM_Dashboard_Remarks__c;
                    // wrap.terminationremarks = bk.Termination_Remarks__c;
                    // wrap.terminationCompletionDate = bk.Approved_for_Termination_Date__c;
                    // wrap.dldNoticeStatus = bk.DLD_Notice_Status__c != null ? bk.DLD_Notice_Status__c : '';
                    // wrap.dldNoticeStatusCategory = bk.DLD_Notice_Status_Category__c != null ? bk.DLD_Notice_Status_Category__c : '';
                    // wrap.terminationProcessStatus = bk.Termination_Process_Status__c;
                    wrap.auditapproveddate = bk.Submitted_to_DLD_for_Termination_Date__c;
                    // wrap.balance = ppd.PropStrength__Balance__c != null ? ppd.PropStrength__Balance__c : 0;
                    wrap.registrationStatus = bk.Pre_Registration_Completed__c ? 'TRUE' : 'FALSE';
                    wrap.soaLink = '/apex/SOALetterHTML?id='+ppd.PropStrength__Application_Booking__c;
                    System.debug('wrap.collected*----'+wrap.collected);
                    wrapList.add(wrap);
                }
            }
        }
        return wrapList;
        
    }
    
    @AuraEnabled
    public static Boolean updateBookingRow(String row, Boolean canceltheprocess, Boolean ispicklist, String cancelComments){
        System.debug('Row ::: '+row);
        try {
            if (row != null) {
                System.debug('Row ::: '+row);
                if (canceltheprocess != null && canceltheprocess) {
                    BookingLineItemParser wrap = (BookingLineItemParser)(JSON.deserialize(row,BookingLineItemParser.class));
                    //Get the booking Id 
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    PropStrength__Application_Booking__c book = [SELECT Id, Tr_Rejected_by_CRM_Reason__c FROM PropStrength__Application_Booking__c WHERE Id = :bookingId];
                    PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c();
                    b.Id = bookingId;
                    //b.X15days_Demand_Raised__c = false;
                    //b.X30days_Demand_Raised__c = false;
                    b.Termination_Process_Status_for_CRM__c = 'Removed from Termination';
                    if (book.Tr_Rejected_by_CRM_Reason__c == null || book.Tr_Rejected_by_CRM_Reason__c == '') {
                        b.Tr_Rejected_by_CRM_Reason__c = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+cancelComments;
                    } else {
                        b.Tr_Rejected_by_CRM_Reason__c = book.Tr_Rejected_by_CRM_Reason__c + '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+cancelComments;
                    }
                    upsert b;
                    return true;
                }
                
                List<BookingLineItemParser> wrapList = BookingLineItemParser.parse(row);
                
                List<PropStrength__Application_Booking__c> bookingsToUpdate = new List<PropStrength__Application_Booking__c>();
                for (BookingLineItemParser wrap:wrapList) {
                    Id bookingId = (Id)(wrap.bookingId.replace('/',''));
                    System.debug(ispicklist+'--bookingId*---'+bookingId);
                    PropStrength__Application_Booking__c updateBooking = [Select id,
                                                CRM_Dashboard_Remarks__c,
                                                X15days_Demand_Raised__c,
                                                Submitted_to_MD_Office_Remarks__c,
                                                X30days_Demand_Raised__c 
                                                From PropStrength__Application_Booking__c 
                                                where id=:bookingId];
                    updateBooking.Id = bookingId;
                    
                    if (ispicklist) {
                        if (wrap.label != '' && wrap.label != null) {
                            if (wrap.cancellationAllocation != null)
                                updateBooking.Cancellation_Allocation__c = wrap.cancellationAllocation;
                            if (wrap.label == 'finalNoticeStatus')
                                updateBooking.Developer_Final_Notice_Status__c = wrap.value;
                            if (wrap.label == 'forfeitureNoticeReceivedByCustomer')
                                updateBooking.Forfeiture_Notice_Received_by_Customer__c = wrap.value;
                            if (wrap.label == 'amountPaidByCustomer') {
                                updateBooking.Amount_Paid_by_Customer_if_Resolved_or__c = wrap.value;
                                
                            }
                            if (wrap.label == 'cancellationAllocation') {
                                updateBooking.Cancellation_Allocation__c = wrap.value;
                                updateBooking.Customer_Initiated_Termination__c = true;
                            } else if(wrap.label.containsIgnoreCase('cancellationAllocation')) {
                                updateBooking.Cancellation_Allocation__c = wrap.value;
                                String val = updateBooking.Submitted_to_MD_Office_Remarks__c;
                                if (updateBooking.Submitted_to_MD_Office_Remarks__c == null || updateBooking.Submitted_to_MD_Office_Remarks__c == '') {
                                    val = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.label.split('##')[1];
                                } else {
                                    val += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.label.split('##')[1];
                                }
                                updateBooking.Submitted_to_MD_Office_Remarks__c = val;
                                updateBooking.Customer_Initiated_Termination__c = true;
                            }
                                
                        }                         
                    }
                    
                    if (wrap.commentsremarks != null) {
                        String val = updateBooking.CRM_Dashboard_Remarks__c;
                        if (updateBooking.CRM_Dashboard_Remarks__c == null || updateBooking.CRM_Dashboard_Remarks__c == '') {
                            val = '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        } else {
                            val += '\n'+UserInfo.getName() + '-'+ System.today().format() + '-'+wrap.commentsremarks;
                        }
                        updateBooking.CRM_Dashboard_Remarks__c = val;
                    }
                    if (wrap.cancellationAllocation != null)
                        updateBooking.Cancellation_Allocation__c = wrap.cancellationAllocation;
                    if (wrap.finalNoticeSentDateCourier != null)
                        updateBooking.Final_Notice_Sent_Date_Courier__c = Date.valueOf(wrap.finalNoticeSentDateCourier);
                    if (wrap.finalNoticeReceivedDate != null)
                        updateBooking.Final_Notice_Receive_Date_Courier__c = Date.valueOf(wrap.finalNoticeReceivedDate);
                    if (wrap.forfeitureNoticeSentDateCourier != null)
                        updateBooking.Forfeiture_Notice_Notice_Sent_Date_Cour__c = Date.valueOf(wrap.forfeitureNoticeSentDateCourier);
                    if (wrap.forfeitedAmount != null)
                        updateBooking.Forfeited_Amount__c = Decimal.valueOf(wrap.forfeitedAmount);

                    if(updateBooking.Cancellation_Allocation__c == 'Allocate to Account Team') {
                        updateBooking.Submitted_to_Accounts_for_Termination__c = System.Today();
                    }
                    bookingsToUpdate.add(updateBooking);
                }
                System.debug('Row ::123: '+row);
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
            PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(id=bookingId,Cancellation_Allocation__c=allocation);
            upsert b;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*@AuraEnabled
public static void sendEmail(string bookingId){
Booking__c bk = [select id,Due_Payments__c,Unit__r.Tower__r.UnRegister_Project__c,Project_Name__c,Unit__r.Name,Last_Call_Attempt_Status__c,Primary_Applicant_Email__c,Opportunity__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Primary_Applicant_Name__c from PropStrength__Application_Booking__c where id =: bookingId];
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
        @AuraEnabled public Decimal saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public long milestoneDue;
        @AuraEnabled public decimal collected;
        @AuraEnabled public decimal due;
        @AuraEnabled public decimal fullDue;
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
        @AuraEnabled public String titleDeedStatus;
        @AuraEnabled public String preRegstatus;
        @AuraEnabled public Date auditapproveddate;
        @AuraEnabled public Decimal collectedpercentage;
        @AuraEnabled public Decimal duepercentage;
        @AuraEnabled public String cancellationAllocation;
        @AuraEnabled public String commentsremarks;
        @AuraEnabled public String finalNoticeSentDate;
        @AuraEnabled public Date finalNoticeSentDateCourier;
        @AuraEnabled public String developerFinalNoticeStatus;
        @AuraEnabled public Date developerFinalNoticeSentDateCourier;
        @AuraEnabled public String finalNoticeStatus;
        @AuraEnabled public Date finalNoticeReceivedDate;
        @AuraEnabled public Date forfeitureNoticeSentDate;
        @AuraEnabled public Date forfeitureNoticeSentDateCourier;
        @AuraEnabled public String forfeitureNoticeReceivedByCustomer;
        @AuraEnabled public Decimal forfeitedAmount;
        @AuraEnabled public String amountPaidByCustomer;
        @AuraEnabled public String finalNoticeReviewLink;
        @AuraEnabled public String crmTerminationProcessStatus;
        
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