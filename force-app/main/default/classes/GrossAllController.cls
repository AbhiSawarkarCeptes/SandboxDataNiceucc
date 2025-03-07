public class GrossAllController {
    @AuraEnabled
    public static list<PropStrength__Projects__c> getProjects(){
        return [select Id, Name, (select Id, PropStrength__Tower_Name__c from PropStrength__Towers__r Order By Name ASC) from PropStrength__Projects__c Order By Name ASC];
    }

    @AuraEnabled
    public static list<BookingWrapper> getBookingsByBucket(string projectId, string towerId, string selectedType, string bucketColor){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new map<string, list<PropStrength__Payment_Plan_Details__c>>();
        list<PropStrength__Payment_Plan_Details__c> pmList = new list<PropStrength__Payment_Plan_Details__c>();
        boolean searchByCategory = false;
        
        if(selectedType == 'Gross All' && towerId == 'All'){
            pmList = [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c, 
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND (PropStrength__Application_Booking__r.Termination_Process_Status__c = '' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Accounts' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Resubmitted to Collections' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Audit' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Termination Cancelled')];
        } else if(selectedType == 'Gross All'){
            pmList = [select id,Name,House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c, 
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c 
                      where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                      PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                      AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: projectId 
                      AND PropStrength__Application_Booking__c != null AND (PropStrength__Application_Booking__r.Termination_Process_Status__c = '' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Accounts' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Resubmitted to Collections' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Audit' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Termination Cancelled')];
        }
        
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
        
        map<string,PropStrength__Application_Booking__c> bookingIdToBooking = new map<string,PropStrength__Application_Booking__c>();
        
        for(PropStrength__Application_Booking__c b : [select id,Termination_Process_Status__c,Pre_Registration_Completed__c, 
                                                        PropStrength__Revised_Total_Sales_Consideration__c, 
                                                        PropStrength__Primary_Customer__r.MobilePhone, 
                                                        PropStrength__Booking_Date__c,name,PropStrength__Property__c,
                                                        PropStrength__Property__r.PropStrength__Property_Name__c,
                                                        PropStrength__Primary_Applicant_Name__c,
                                                        PropStrength__Total_Agreement_Amount__c, 
                                                        PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c 
                                                        from PropStrength__Application_Booking__c 
                                                        where Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }
        System.debug(bucketColor);
        for(string booking : bookingToPM.keySet()){
            PropStrength__Application_Booking__c bk = bookingIdToBooking.get(booking);
            list<PropStrength__Payment_Plan_Details__c> bpm = bookingToPM.get(booking);
            for(PropStrength__Payment_Plan_Details__c ppd : bpm) {
                if((ppd.Interest_Ageing__c == null && bucketColor == 'Green') || (ppd.Interest_Ageing__c != null && ppd.Interest_Ageing__c <= 30 && bucketColor == 'Green')) {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingIdVal = ppd.PropStrength__Application_Booking__c != null ? ppd.PropStrength__Application_Booking__c : '';
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
                    wrap.primaryMobileNumber = bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c != null ? bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c : '';
                    wrap.termStatus = bk.Termination_Process_Status__c != null ? bk.Termination_Process_Status__c : '';
                    wrapList.add(wrap);
                }
                if(ppd.Interest_Ageing__c != null && ppd.Interest_Ageing__c >=31 && ppd.Interest_Ageing__c <= 60  && bucketColor == 'Yellow') {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingIdVal = ppd.PropStrength__Application_Booking__c != null ? ppd.PropStrength__Application_Booking__c : '';
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
                    wrap.primaryMobileNumber = bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c != null ? bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c : '';
                    wrap.termStatus = bk.Termination_Process_Status__c != null ? bk.Termination_Process_Status__c : '';
                    wrapList.add(wrap);
                }
                if(ppd.Interest_Ageing__c != null && ppd.Interest_Ageing__c >=61 && ppd.Interest_Ageing__c <= 90  && bucketColor == 'Amber') {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingIdVal = ppd.PropStrength__Application_Booking__c != null ? ppd.PropStrength__Application_Booking__c : '';
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
                    wrap.primaryMobileNumber = bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c != null ? bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c : '';
                    wrap.termStatus = bk.Termination_Process_Status__c != null ? bk.Termination_Process_Status__c : '';
                    wrapList.add(wrap);
                }
                if(ppd.Interest_Ageing__c != null && ppd.Interest_Ageing__c >= 91 && bucketColor == 'Red') {
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingIdVal = ppd.PropStrength__Application_Booking__c != null ? ppd.PropStrength__Application_Booking__c : '';
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
                    wrap.primaryMobileNumber = bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c != null ? bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c : '';
                    wrap.termStatus = bk.Termination_Process_Status__c != null ? bk.Termination_Process_Status__c : '';
                    wrapList.add(wrap);
                }
                if(bucketColor == 'White'){
                    BookingWrapper wrap = new BookingWrapper();
                    wrap.ppdId = '/'+ppd.Id;
                    wrap.ppdName = ppd.Name;
                    wrap.unitId = '/'+ppd.PropStrength__Application_Booking__r.PropStrength__Property__c;
                    wrap.unitName = ppd.House_Unit_No__c != null ? ppd.House_Unit_No__c : '';
                    wrap.bookingId = ppd.PropStrength__Application_Booking__c != null ? '/'+ppd.PropStrength__Application_Booking__c : '';
                    wrap.bookingIdVal = ppd.PropStrength__Application_Booking__c != null ? ppd.PropStrength__Application_Booking__c : '';
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
                    wrap.primaryMobileNumber = bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c != null ? bk.PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c : '';
                    wrap.termStatus = bk.Termination_Process_Status__c != null ? bk.Termination_Process_Status__c : '';
                    wrapList.add(wrap);
                }
            }
        }
        System.debug(wrapList);
        return wrapList;
    }
    
    @AuraEnabled
    public static list<PropStrength__Application_Booking__c> getBookings(string projectId, string towerId){
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>();
        if(towerId != null && towerId != ''){

            bookingList = [ SELECT id,Termination_Process_Status__c,Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Primary_Customer__r.MobilePhone, 
                PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,PropStrength__Total_Agreement_Amount__c, PropStrength__Total_Payment_Due__c,
                PropStrength__Total_Payment_Received__c, PropStrength__Outstanding_Balance__c, PropStrength__Outstanding_Balance_Excluding_Waiver__c, Income_Charge_Due_Without_DLD__c, PropStrength__Super_Area__c, PropStrength__Rate_Per_Unit_Area__c,
                Income_Charge_Received_Without_DLD__c, Income_Charge_Outstanding_Without_DLD__c, DLD_Fees_Due__c, DLD_Fees_Received__c, DLD_Outstanding__c, PropStrength__Original_Super_Area__c, PropStrength__Original_Total_Basic_Sales_Price__c, 
                PropStrength__Original_Other_Charges_Total__c, PropStrength__Total_Basic_Sales_Price__c, PropStrength__Other_Charges_Total__c, Total_Recurring_Interest_Till_Date__c, Days_Remaining_for_Next_Interest_Demand__c, Total_Interest_Due_Till_Date__c,
                Total_Interest_Received_Till_Date__c,Oqood_Fees_Amount__c, PropStrength__Total_Sales_Consideration__c, PropStrength__Total_Application_Amount_with_Tax__c,PropStrength__Applicant_Mobile__c,
                PropStrength__Revised_Agreement_Amount__c, PropStrength__Booking_Amount_Received__c, Do_Not_Raise_Demand__c, House_Unit_No__c,
                (SELECT Id,Name,PropStrength__Balance__c,PropStrength__Amount_Due_Plus_Tax__c,PropStrength__Amount_Paid__c,PropStrength__Total_Amount_Due__c,PropStrength__Amount_Percent__c,PropStrength__Total_Service_Tax_on_PPD__c,
                PropStrength__Booking_Amount_PPD__c,PropStrength__Is_Milestone_Completed__c, PropStrength__Approval_Status__c, PropStrength__Other_Charges_as_COP__c, PropStrength__Amount_Due__c, PropStrength__Total_Other_Charges_Dues__c,
                PropStrength__Service_Tax_on_Other_Charges__c, PropStrength__Total_Amount_Due_with_Service_Tax__c, PropStrength__Final_Payment_Date__c, PropStrength__Rate_of_Interest__c ,
                Interest_Ageing__c,Recurring_Interest_Till_date__c,PropStrength__Payment_Due_Date__c FROM  PropStrength__Payment_Plan_Details__r WHERE PropStrength__Payment_Due_Date__c < = TODAY AND PropStrength__Is_Milestone_Completed__c = TRUE ORDER BY PropStrength__Payment_Due_Date__c DESC ),
                PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c =: projectId AND PropStrength__Property__r.PropStrength__Tower__c =: towerId];
        }else{
            bookingList = [ SELECT id,Termination_Process_Status__c,Pre_Registration_Completed__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Primary_Customer__r.MobilePhone, 
                PropStrength__Booking_Date__c,name,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Primary_Applicant_Name__c,PropStrength__Total_Agreement_Amount__c, PropStrength__Total_Payment_Due__c,
                PropStrength__Total_Payment_Received__c, PropStrength__Outstanding_Balance__c, PropStrength__Outstanding_Balance_Excluding_Waiver__c, Income_Charge_Due_Without_DLD__c, PropStrength__Super_Area__c, PropStrength__Rate_Per_Unit_Area__c,
                Income_Charge_Received_Without_DLD__c, Income_Charge_Outstanding_Without_DLD__c, DLD_Fees_Due__c, DLD_Fees_Received__c, DLD_Outstanding__c, PropStrength__Original_Super_Area__c, PropStrength__Original_Total_Basic_Sales_Price__c, 
                PropStrength__Original_Other_Charges_Total__c, PropStrength__Total_Basic_Sales_Price__c, PropStrength__Other_Charges_Total__c, Total_Recurring_Interest_Till_Date__c, Days_Remaining_for_Next_Interest_Demand__c, Total_Interest_Due_Till_Date__c,
                Total_Interest_Received_Till_Date__c,Oqood_Fees_Amount__c, PropStrength__Total_Sales_Consideration__c, PropStrength__Total_Application_Amount_with_Tax__c,PropStrength__Applicant_Mobile__c,
                PropStrength__Revised_Agreement_Amount__c, PropStrength__Booking_Amount_Received__c, Do_Not_Raise_Demand__c, House_Unit_No__c,
                (SELECT Id,Name,PropStrength__Balance__c,PropStrength__Amount_Due_Plus_Tax__c,PropStrength__Amount_Paid__c,PropStrength__Total_Amount_Due__c,PropStrength__Amount_Percent__c,PropStrength__Total_Service_Tax_on_PPD__c,
                PropStrength__Booking_Amount_PPD__c,PropStrength__Is_Milestone_Completed__c, PropStrength__Approval_Status__c, PropStrength__Other_Charges_as_COP__c, PropStrength__Amount_Due__c, PropStrength__Total_Other_Charges_Dues__c,
                PropStrength__Service_Tax_on_Other_Charges__c, PropStrength__Total_Amount_Due_with_Service_Tax__c, PropStrength__Final_Payment_Date__c, PropStrength__Rate_of_Interest__c ,
                Interest_Ageing__c,Recurring_Interest_Till_date__c,PropStrength__Payment_Due_Date__c FROM  PropStrength__Payment_Plan_Details__r WHERE PropStrength__Payment_Due_Date__c < = TODAY AND PropStrength__Is_Milestone_Completed__c = TRUE ORDER BY PropStrength__Payment_Due_Date__c DESC),
                PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c =: projectId ];
        }
        return bookingList;
    }
    
    @AuraEnabled
    public static void updateLastActionOnBooking(string category, string bookingId, string taskId, string dueOrAdvanceAmount){
        dueOrAdvanceAmount = dueOrAdvanceAmount.remove(',');
        Task taskRec = [select id,CreatedDate,Owner.Name from Task where Id =: taskId];
        PropStrength__Application_Booking__c bk = new PropStrength__Application_Booking__c();
        bk.Id = bookingId;
        //bk.Category__c = category;
        //bk.Last_Call_Attempt_Date__c = task.CreatedDate;
        //bk.Last_Call_Attempt_Status__c = task.Category__c;
        //bk.Last_Call_Description__c = task.Notes__c;
        //bk.Last_Action_Type__c = task.Communication_Mode__c;
        //bk.Next_Action_Date__c = task.Follow_up_Date__c;
        //bk.Due_Advance_Amount__c = Long.valueOf(dueOrAdvanceAmount);
        /*if(task.Customer_Interested__c == 'Yes'){
            bk.Next_Action_Date__c = task.Expected_Date_Of_The_Payment__c;
        }*/
        //bk.Last_Call_Attempted_By__c = task.Owner.Name;
        //update bk;
    }

    @AuraEnabled
    public static string createTaskOnCall(string bookingId){
        Task t = new Task();
        t.WhatId = bookingId;
        insert t;
        return t.Id;
    }
    
    @AuraEnabled
    public static void sendEmail(string bookingId){
        
        PropStrength__Application_Booking__c bk = [select id,Project_Name__c,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Applicant_Email__c,PropStrength__Primary_Applicant_Name__c from PropStrength__Application_Booking__c where id =: bookingId];
        //if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' || bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation'){
            string templateDeveloperName = '';
            /*if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach')
                templateDeveloperName = 'No_Contact_Or_Unable_To_Reach';
            if(bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation')
                templateDeveloperName = 'Raise_for_Cancellation';*/

        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


            EmailTemplate e = [select id, HtmlValue, Subject from EmailTemplate where DeveloperName =: templateDeveloperName];
            string body = e.HtmlValue;
            body = body.replace('#PrimaryApplicant#', bk.PropStrength__Primary_Applicant_Name__c);
            body = body.replace('#Unit#', bk.PropStrength__Property__r.PropStrength__Property_Name__c);
            string projectName = '';
            if(bk.Project_Name__c != null)
                projectName = bk.Project_Name__c;
            body = body.replace('#Project#', projectName);
            /*if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' && bk.Due_Payments__c != null){
                body = body.replace('#OverdueAmount#', String.valueOf(bk.Due_Payments__c));
            }*/
            string subject = e.subject;
            subject = subject.replace('#Unit#', bk.PropStrength__Property__r.PropStrength__Property_Name__c);
            subject = subject.replace('#Project#', projectName);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setSubject(subject); 
            mail.setHtmlBody(body);
            list<string> toAddress = new list<string>();
            list<string> ccAddress = new list<string>();
            toAddress.add(bk.PropStrength__Applicant_Email__c);
            /*if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Email__c != null){
                string emails = bk.Opportunity__r.Other_Applicants_Email__c;
                emails = emails.trim();
                emails = emails.removeEnd(',');
                ccAddress.addAll(emails.split(','));
            }*/
            ccAddress.add(UserInfo.getUserEmail());
            ccAddress.add(System.Label.SobhaHelpdesk);
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setSaveAsActivity(false); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //}
    }

    @AuraEnabled
    public static Boolean sendBankDetailsEmail(String unitId){
        Boolean result = false;
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        PropStrength__Property__c u = [Select id,(SELECT Id, PropStrength__Applicant_Email__c FROM PropStrength__Application_Booking__r) From PropStrength__Property__c where id=:unitId];
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = 'Bank Account Details ticker'];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(UserInfo.getUserId());
        //message.setSenderDisplayName('Sobha');
        //message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setCcAddresses(new String[] { 'helpdesk@sobharealty.com' });
        message.setSaveAsActivity(false);
        message.setTreatTargetObjectAsRecipient(false);
        if (owea.size() > 0) {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
        message.setTemplateID(et.Id);
        message.setWhatId(unitId);
        for(PropStrength__Application_Booking__c book : u.PropStrength__Application_Booking__r) {
        message.toAddresses = new String[] { book.PropStrength__Applicant_Email__c};
        }

        Messaging.SingleEmailMessage[] messages = new   
        List<Messaging.SingleEmailMessage> {message};

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    @future
    public static void createTask(list<string> bkIds){
        list<PropStrength__Application_Booking__c> bkListToCreateTask = [select id from PropStrength__Application_Booking__c where Id IN: bkIds];
        list<PropStrength__Broker_Payment_Milestone__c> pmList = new list<PropStrength__Broker_Payment_Milestone__c>();
        map<string, list<PropStrength__Broker_Payment_Milestone__c>> bookingToPM = new map<string, list<PropStrength__Broker_Payment_Milestone__c>>();
        pmList = [select id,PropStrength__Total_Brokerage_Due__c, PropStrength__Booking_ID__c from PropStrength__Broker_Payment_Milestone__c where PropStrength__Booking_ID__r.PropStrength__Status__c != 'Rejected' AND PropStrength__Booking_ID__r.PropStrength__Status__c = 'Audit Approved' AND PropStrength__Due_Date__c != null AND PropStrength__Due_Date__c <= TODAY AND PropStrength__Booking_ID__c IN: bkListToCreateTask];
        for(PropStrength__Broker_Payment_Milestone__c pm : pmList){
            if(bookingToPM.containsKey(pm.PropStrength__Booking_ID__c)){
                list<PropStrength__Broker_Payment_Milestone__c> pms = bookingToPM.get(pm.PropStrength__Booking_ID__c);
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Booking_ID__c,pms);
            }
            else{
                list<PropStrength__Broker_Payment_Milestone__c> pms = new list<PropStrength__Broker_Payment_Milestone__c>();
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Booking_ID__c,pms);
            }
        }
        Map<String,Long> bookingIdToAdvanceAmount = new Map<String,Long>();
        List<Task> tasksToCreate = new List<Task>();
        for(PropStrength__Application_Booking__c booking : bkListToCreateTask){
            if(bookingToPM.containsKey(booking.Id)){
                long sum = 0;
                long amount = 0;
                boolean isCreateTask = false;
                for(PropStrength__Broker_Payment_Milestone__c pm : bookingToPM.get(booking.Id)){
                    sum = sum + (long)pm.PropStrength__Total_Brokerage_Due__c;
                }
                //long totalOnAccountMoneyWithRegistration = (long)booking.Total_On_Account_Money_With_Registration__c;
                long totalOnAccountMoneyWithRegistration = 0;
                if(totalOnAccountMoneyWithRegistration >= sum){ 
                    amount = totalOnAccountMoneyWithRegistration-sum;
                    isCreateTask = true;
                }
                /*else if(((sum - totalOnAccountMoneyWithRegistration) > 0 && (sum - totalOnAccountMoneyWithRegistration) <= booking.Unit__r.Tower__r.Advance_Payments__c)){
                    amount = sum - totalOnAccountMoneyWithRegistration;
                    isCreateTask = true;
                }*/
                if(isCreateTask){
                    Task t = new Task();
                    //t.Category__c = 'Not Pitched';
                    t.WhatId = booking.Id;
                    //t.Notes__c = 'Not Pitched';
                    tasksToCreate.add(t);
                    bookingIdToAdvanceAmount.put(booking.Id,amount);
                }
            }
        }
        if(tasksToCreate.size()>0){
            insert tasksToCreate;
        }
        if(bookingIdToAdvanceAmount.size()>0){
            GrossAllController.updateTaskDetailsOnBooking(bookingIdToAdvanceAmount); 
        }
    }
    
    public static void updateTaskDetailsOnBooking(Map<String,Long> bookingIdToAdvanceAmount){
        list<PropStrength__Application_Booking__c> bkListToUpdate = new list<PropStrength__Application_Booking__c>();
        for(string bookingId : bookingIdToAdvanceAmount.keySet()){
            PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c(Id=bookingId);
            //b.Category__c = 'Advance Payments';
            //b.Last_Call_Attempt_Date__c = System.now();
            //b.Last_Call_Attempt_Status__c = 'Not Pitched';
            //b.Last_Call_Description__c = 'Not Pitched';
            //b.Due_Advance_Amount__c = bookingIdToAdvanceAmount.get(bookingId);
            //b.Last_Call_Attempted_By__c = 'System Automated';
            bkListToUpdate.add(b);
        }
        //update bkListToUpdate;
    }

    @AuraEnabled
    public static list<string> getMonthList(){
        list<string> monthList = new list<string>();
        List<PropStrength__Broker_Payment_Milestone__c> pmList = [select id,PropStrength__Due_Date__c,PropStrength__Total_Brokerage_Due__c, PropStrength__Booking_ID__c, 
                                                PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Tower__c from PropStrength__Broker_Payment_Milestone__c WHERE 
                                                PropStrength__Booking_ID__c != null AND PropStrength__Due_Date__c != null AND 
                                                PropStrength__Due_Date__c = NEXT_N_MONTHS:6 
                                                AND PropStrength__Booking_ID__r.PropStrength__Property__c != null ORDER BY PropStrength__Due_Date__c ASC]; //PropStrength__Booking_ID__r.PropStrength__Status__c = 'Processed'
        map<integer,string> monthNumberToMonthName = new map<integer,string>();
        monthNumberToMonthName.put(1,'JAN');
        monthNumberToMonthName.put(2,'FEB');
        monthNumberToMonthName.put(3,'MAR');
        monthNumberToMonthName.put(4,'APR');
        monthNumberToMonthName.put(5,'MAY');
        monthNumberToMonthName.put(6,'JUN');
        monthNumberToMonthName.put(7,'JUL');
        monthNumberToMonthName.put(8,'AUG');
        monthNumberToMonthName.put(9,'SEP');
        monthNumberToMonthName.put(10,'OCT');
        monthNumberToMonthName.put(11,'NOV');
        monthNumberToMonthName.put(12,'DEC');
        for(PropStrength__Broker_Payment_Milestone__c p : pmList){
            Date dueDate = p.PropStrength__Due_Date__c;
            string str = monthNumberToMonthName.get(dueDate.month()) + ' ' + string.valueOf(dueDate.year());
            if(!monthList.contains(str))
                monthList.add(str);
        }
        return monthList;
    }

    @AuraEnabled
    public static String ppdSubmitted(List<String> selectedBooking){
        System.debug(selectedBooking);
        if(!selectedBooking.isEmpty()) {
            List<PropStrength__Application_Booking__c> book = [SELECT Id, PropStrength__Total_Due_Percent__c FROM PropStrength__Application_Booking__c WHERE Id IN :selectedBooking];
            if(!book.isEmpty()) {
                List<PropStrength__Application_Booking__c> bookingUpdateList = new List<PropStrength__Application_Booking__c>();
                Boolean flag = false;
                for(PropStrength__Application_Booking__c bookId : book) {
                    PropStrength__Payment_Plan_Details__c ppd = searchPpd(bookId.Id);
                    System.debug(ppd.Id);
                    System.debug(ppd.Interest_Ageing__c);
                    if(bookId.PropStrength__Total_Due_Percent__c == null || ppd.Interest_Ageing__c == null || bookId.PropStrength__Total_Due_Percent__c < 10 || ppd.Interest_Ageing__c < 30) {
                        flag = true;
                    } else {
                        bookingUpdateList.add(new PropStrength__Application_Booking__c(Id = bookId.Id, Termination_Process_Status__c = 'Submitted to Accounts', Submitted_to_Accounts_for_Termination__c=System.Today()));
                    }
                }
                if(!bookingUpdateList.isEmpty()) {
                    update bookingUpdateList;
                }
                System.debug(flag);
                if(flag) {
                    return 'failure';
                } else {
                    return 'success';
                }
            }
        }
        return '';
    }

    private static PropStrength__Payment_Plan_Details__c searchPpd(String bookId){
        List<PropStrength__Application_Booking__c> book = [SELECT Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Project_Name__c FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
        if(!book.isEmpty()) {
            List<PropStrength__Payment_Plan_Details__c> pmList = [select id,PropStrength__Application_Booking__c,Interest_Ageing__c, PropStrength__Final_Payment_Date__c
                    from PropStrength__Payment_Plan_Details__c 
                    where PropStrength__Application_Booking__r.PropStrength__Status__c = 'Audit Approved' AND 
                    PropStrength__Application_Booking__r.PropStrength__Active__c = TRUE AND 
                    PropStrength__Application_Booking__c = :bookId AND
                    PropStrength__Balance__c > 0 AND PropStrength__Is_Milestone_Completed__c = TRUE
                    AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: book[0].PropStrength__Property__r.PropStrength__Tower__c 
                    AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =: book[0].PropStrength__Property__r.PropStrength__Project_Name__c 
                    AND PropStrength__Application_Booking__c != null AND (PropStrength__Application_Booking__r.Termination_Process_Status__c = '' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Accounts' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Resubmitted to Collections' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Rejected by Audit' OR PropStrength__Application_Booking__r.Termination_Process_Status__c = 'Termination Cancelled')];
            
                   System.debug(pmList);
                    Map<string, list<PropStrength__Payment_Plan_Details__c>> bookingToPM = new Map<string, list<PropStrength__Payment_Plan_Details__c>>();
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
                   System.debug(bookingToPM);

            if(!bookingToPM.isEmpty()) {
                Set<String> bpmMapSet = bookingToPM.keySet();
                String firstInd = '';
                for(String temp : bpmMapSet) {
                    firstInd = temp;
                    break;
                }
                return bookingToPM.get(firstInd)[0];
            }
        }
        return null;
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getTowerData(string towerId){
        map<string,ExecutiveCategoryData> towerDataMap = new map<string,ExecutiveCategoryData>();
        map<string,ExecutiveCategoryData> tempDataMap = new map<string,ExecutiveCategoryData>();
        list<string> monthList = new list<string>();
        List<PropStrength__Broker_Payment_Milestone__c> pmList = [select id,PropStrength__Due_Date__c,PropStrength__Total_Brokerage_Due__c, PropStrength__Booking_ID__c, 
                                        PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Tower__c from PropStrength__Broker_Payment_Milestone__c WHERE 
                                        PropStrength__Booking_ID__c != null AND PropStrength__Due_Date__c != null AND 
                                        PropStrength__Due_Date__c = NEXT_N_MONTHS:6 
                                        AND PropStrength__Booking_ID__r.PropStrength__Property__c != null ORDER BY PropStrength__Due_Date__c ASC]; //PropStrength__Booking_ID__r.PropStrength__Status__c = 'Processed'
            
        map<string,long> projectToFutureDues = new map<string,long>();
        map<string,list<long>> projectToFutureDueList = new map<string,list<long>>();

        for(PropStrength__Broker_Payment_Milestone__c p : pmList){
            Date dueDate = p.PropStrength__Due_Date__c;
            string str = string.valueOf(dueDate.month()) + '-' + string.valueOf(dueDate.year());
            if(!monthList.contains(str))
                monthList.add(str);
            string pId = p.PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Tower__c + '##' + str;
            if(projectToFutureDues.containsKey(pId)){
                long dueAmt = projectToFutureDues.get(pId);
                dueAmt = (p.PropStrength__Total_Brokerage_Due__c != null)?(dueAmt + (long)p.PropStrength__Total_Brokerage_Due__c):dueAmt; 
                projectToFutureDues.put(pId, dueAmt);
            }
            else{
                long dueAmt = (p.PropStrength__Total_Brokerage_Due__c != null)?(long)p.PropStrength__Total_Brokerage_Due__c:0;
                projectToFutureDues.put(pId, dueAmt);
            }
        }
        map<string,long> projectToFutureDuesNew = new map<string,long>();
        set<string> keyList = projectToFutureDues.keySet();
        for(string pId : projectToFutureDues.keySet()){
            string actualPId = pId.split('##')[0];
            string tmp = pId.split('##')[1];
            integer mon = Integer.valueOf(tmp.split('-')[0]);
            integer yer = Integer.valueOf(tmp.split('-')[1]);
            Date yr = Date.newInstance(yer, mon, 1);
            for(string str : monthList){
                string key = actualPId+'##'+str;
                integer mon1 = Integer.valueOf(str.split('-')[0]);
                integer yer1 = Integer.valueOf(str.split('-')[1]);
                Date yrr = Date.newInstance(yer1, mon1, 1);
                if((yrr <= yr)){
                    if(!keyList.contains(key)){
                        if(!projectToFutureDuesNew.containsKey(key))
                            projectToFutureDuesNew.put(key, 0);
                    }
                    if(yrr == yr) break;
                }
            }
            projectToFutureDuesNew.put(pId,projectToFutureDues.get(pId));
        }
        for(string pId : projectToFutureDuesNew.keySet()){
            string actualPId = pId.split('##')[0];
            if(projectToFutureDueList.containsKey(actualPId)){
                list<long> dueList = projectToFutureDueList.get(actualPId);
                dueList.add(projectToFutureDuesNew.get(pId));
                projectToFutureDueList.put(actualPId,dueList);
            }
            else{
                projectToFutureDueList.put(actualPId, new list<long>{projectToFutureDuesNew.get(pId)});
            }
        }

        List<PropStrength__Application_Booking__c> bookings = new List<PropStrength__Application_Booking__c>();
        if(towerId == 'All'){
            bookings = [Select Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where PropStrength__Property__r.PropStrength__Tower__c != null and PropStrength__Status__c != 'Rejected' and PropStrength__Status__c = 'Audit Approved'];
        }
        else {
            bookings = [Select Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where PropStrength__Property__r.PropStrength__Tower__c != null and PropStrength__Property__r.PropStrength__Tower__c =: towerId and PropStrength__Status__c != 'Rejected' and PropStrength__Status__c = 'Audit Approved'];
        }

        for(PropStrength__Application_Booking__c b : bookings){
            if(towerDataMap.containsKey(b.PropStrength__Property__r.PropStrength__Tower__c)){
                ExecutiveCategoryData d = towerDataMap.get(b.PropStrength__Property__r.PropStrength__Tower__c);
                d.categoryCount = d.categoryCount + 1;
                //d.saleValue = (b.Agreement_Value__c!=null)?(d.saleValue + (Long)b.Agreement_Value__c):d.saleValue;
                d.saleValue = 0;
                //d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)b.Total_On_Account_Money_With_Registration__c):d.collected;
                d.collected = 0;
                //d.due = (b.Due_Payments__c!=null)?(d.due + (Long)b.Due_Payments__c):d.due;
                d.due = 0;
                towerDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, d);
            }
            else {
                ExecutiveCategoryData d = new ExecutiveCategoryData();
                d.towerId = b.PropStrength__Property__r.PropStrength__Tower__c;
                d.towerName = b.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c;
                d.categoryCount = 1;
                //d.saleValue = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                d.saleValue = 0;
                //d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                d.collected = 0;
                //d.due = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                d.due = 0;
                towerDataMap.put(b.PropStrength__Property__r.PropStrength__Tower__c, d);
            }
        }
        for(string tId : towerDataMap.keySet()){
            ExecutiveCategoryData ecd = towerDataMap.get(tId);
            if(projectToFutureDueList.containsKey(tId)){
                ecd.futureMonthlyDues = projectToFutureDueList.get(tId);
            }
            else{
                list<long> tmpFutureDues = new list<long>();
                for(string str : monthList){
                    tmpFutureDues.add(0);
                }
                ecd.futureMonthlyDues = tmpFutureDues;
            }
            integer s = ecd.futureMonthlyDues.size();
            for(integer i=s; i<monthList.size(); i++){
                ecd.futureMonthlyDues.add(0);
            }
            tempDataMap.put(tId,ecd);
        }
        return tempDataMap.values();
    }

    @AuraEnabled
    public static List<ExecutiveTargetData> getTargetData(){
        List<ExecutiveTargetData> data = new List<ExecutiveTargetData>();
        map<string,ExecutiveTargetData> targetDataMap = new map<string,ExecutiveTargetData>();
        List<Receipt__c> receipts = new List<Receipt__c>();
        /*receipts = [Select Id,GL_Date__c,Total_Amount__c, Registration_Collection_Control_Report__c,Booking__r.Unit__r.Tower__r.Name,Booking__r.Unit__r.Tower__c,Booking__r.Unit__r.Tower__r.Target__c from Receipt__c where PropStrength__Application_Booking__c != null and PropStrength__Application_Booking__r.PropStrength__Property__c != null and Booking__r.Unit__r.Tower__c != null and GL_Date__c = THIS_MONTH and Receipt_Status__c = 'Cleared' and Booking__r.Paid_Percentage__c >= 10];
        for(Receipt__c r : receipts){
            if(targetDataMap.containsKey(r.Booking__r.Unit__r.Tower__c)){
                ExecutiveTargetData exeData = targetDataMap.get(r.Booking__r.Unit__r.Tower__c);
                exeData.achieved = exeData.achieved + (Long) (r.Total_Amount__c - r.Registration_Collection_Control_Report__c);
                targetDataMap.put(r.Booking__r.Unit__r.Tower__c, exeData);
            }
            else{
                ExecutiveTargetData exeData = new ExecutiveTargetData();
                exeData.towerId = r.Booking__r.Unit__r.Tower__c;
                exeData.towerName = r.Booking__r.Unit__r.Tower__r.Name;
                exeData.target = (r.Booking__r.Unit__r.Tower__r.Target__c != null)?(Long)r.Booking__r.Unit__r.Tower__r.Target__c:0;
                exeData.achieved = (Long) (r.Total_Amount__c - r.Registration_Collection_Control_Report__c);
                targetDataMap.put(r.Booking__r.Unit__r.Tower__c, exeData);
            }
        }
        map<string,ExecutiveTargetData> finalTargetDataMap = new map<string,ExecutiveTargetData>();
        Long totalTarget = 0;
        Long totalAcheived = 0;
        for(string tower : targetDataMap.keySet()){
            ExecutiveTargetData exeData = targetDataMap.get(tower);
            Decimal totalAcheivedD = (Decimal)exeData.achieved;
            Decimal totalTargetD = (Decimal)exeData.target;
            Decimal achievedPercentage = 0;
            if(totalTargetD != 0 && totalTargetD != null)
                achievedPercentage = totalAcheivedD.divide(totalTargetD, 2);
            exeData.achievedPercentage = achievedPercentage;
            finalTargetDataMap.put(tower, exeData);
            totalAcheived = totalAcheived + exeData.achieved;
        }
        List<Tower__c> towers = [select Id,Name,Target__c from Tower__c];
        for(Tower__c t : towers){
            if(t.Target__c != null){
                totalTarget = totalTarget + (Long)t.Target__c;
            }
        }
        Decimal totalAcheivedD = (Decimal)totalAcheived;
        Decimal totalTargetD = (Decimal)totalTarget;
        Decimal totalAchievedPercentage = 0;
        if(totalTargetD != 0 && totalTargetD != null)
            totalAchievedPercentage = totalAcheivedD.divide(totalTargetD, 2);
        ExecutiveTargetData exeDataAll = new ExecutiveTargetData();
        exeDataAll.towerId = 'All';
        exeDataAll.towerName = 'All';
        exeDataAll.target = totalTarget;
        exeDataAll.achieved = totalAcheived;
        exeDataAll.achievedPercentage = totalAchievedPercentage;
        finalTargetDataMap.put('All', exeDataAll);

        map<string,ExecutiveTargetData> dataMap = new map<string,ExecutiveTargetData>();
        for(Tower__c t : towers){
            if(finalTargetDataMap.containsKey(t.Id)){
                dataMap.put(t.Id,finalTargetDataMap.get(t.Id));
            }
            else{
                ExecutiveTargetData ob = new ExecutiveTargetData();
                ob.target = (t.Target__c != null)?(Long)t.Target__c : 0;
                ob.achieved = 0;
                ob.achievedPercentage = 0;
                ob.towerId = t.Id;
                ob.towerName = t.Name;
                dataMap.put(t.Id,ob);
            }
        }
        dataMap.put('All', exeDataAll);

        return dataMap.values();*/
        return data;
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getCategoryData(string towerId){
        map<string,ExecutiveCategoryData> categorytDataMap = new map<string,ExecutiveCategoryData>();
        ExecutiveCategoryData serviced = new ExecutiveCategoryData();
        serviced.fontWeight = 'font-weight: bold';
        serviced.category = 'Serviced';
        categorytDataMap.put('Serviced',serviced);
        ExecutiveCategoryData unserviced = new ExecutiveCategoryData();
        unserviced.fontWeight = 'font-weight: bold';
        unserviced.category = 'Unserved';
        categorytDataMap.put('Unserved',unserviced);
        ExecutiveCategoryData grandTotal = new ExecutiveCategoryData();
        grandTotal.fontWeight = 'font-weight: bold';
        grandTotal.category = 'Grand Total';
        categorytDataMap.put('Grand Total',grandTotal);
        List<PropStrength__Application_Booking__c> bookings = new List<PropStrength__Application_Booking__c>();
        if(towerId == 'All'){
            bookings = [Select Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where PropStrength__Status__c != 'Rejected' and PropStrength__Status__c = 'Audit Approved'];
        }
        else {
            bookings = [Select Id, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Total_Agreement_Amount__c from PropStrength__Application_Booking__c where PropStrength__Property__r.PropStrength__Tower__c =: towerId and PropStrength__Status__c != 'Rejected' and PropStrength__Status__c = 'Audit Approved'];
        }

        for(PropStrength__Application_Booking__c b : bookings){
            /*if(b.Last_Call_Attempt_Status__c != null){
                if(categorytDataMap.containsKey(b.Last_Call_Attempt_Status__c)){
                    ExecutiveCategoryData d = categorytDataMap.get(b.Last_Call_Attempt_Status__c);
                    d.categoryCount = d.categoryCount + 1;
                    d.saleValue = (b.Agreement_Value__c!=null)?(d.saleValue + (Long)b.Agreement_Value__c):d.saleValue;
                    d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)b.Total_On_Account_Money_With_Registration__c):d.collected;
                    d.due = (b.Due_Payments__c!=null)?(d.due + (Long)b.Due_Payments__c):d.due;
                    categorytDataMap.put(b.Last_Call_Attempt_Status__c, d);
                }
                else {
                    ExecutiveCategoryData d = new ExecutiveCategoryData();
                    d.fontWeight = 'font-weight: normal';
                    d.towerId = b.Unit__r.Tower__c;
                    d.towerName = b.Unit__r.Tower__r.Name;
                    d.category = b.Last_Call_Attempt_Status__c;
                    d.categoryCount = 1;
                    d.saleValue = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                    d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                    d.due = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                    categorytDataMap.put(b.Last_Call_Attempt_Status__c, d);
                }
                ExecutiveCategoryData served = categorytDataMap.get('Serviced');
                served.categoryCount = served.categoryCount + 1;
                served.saleValue = (b.Agreement_Value__c!=null)?(served.saleValue + (Long)b.Agreement_Value__c):served.saleValue;
                served.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(served.collected + (Long)b.Total_On_Account_Money_With_Registration__c):served.collected;
                served.due = (b.Due_Payments__c!=null)?(served.due + (Long)b.Due_Payments__c):served.due;
                categorytDataMap.put('Serviced', served);
            }
            else{
                ExecutiveCategoryData unserved = categorytDataMap.get('Unserved');
                unserved.categoryCount = unserved.categoryCount + 1;
                unserved.saleValue = (b.Agreement_Value__c!=null)?(unserved.saleValue + (Long)b.Agreement_Value__c):unserved.saleValue;
                unserved.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(unserved.collected + (Long)b.Total_On_Account_Money_With_Registration__c):unserved.collected;
                unserved.due = (b.Due_Payments__c!=null)?(unserved.due + (Long)b.Due_Payments__c):unserved.due;
                categorytDataMap.put('Unserved', unserved);
            }*/
            ExecutiveCategoryData total = categorytDataMap.get('Grand Total');
            total.categoryCount = total.categoryCount + 1;
            //total.saleValue = (b.Agreement_Value__c!=null)?(total.saleValue + (Long)b.Agreement_Value__c):total.saleValue;
            total.saleValue = 0;
            //total.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(total.collected + (Long)b.Total_On_Account_Money_With_Registration__c):total.collected;
            total.collected = 0;
            //total.due = (b.Due_Payments__c!=null)?(total.due + (Long)b.Due_Payments__c):total.due;
            total.due = 0;
            categorytDataMap.put('Grand Total', total);
        }
        map<string,ExecutiveCategoryData> categorytDataMapTemp = new map<string,ExecutiveCategoryData>();
        categorytDataMapTemp.put('Serviced',categorytDataMap.get('Serviced'));
        for(string str : categorytDataMap.keySet()){
            if(str != 'Serviced' && str != 'Unserved' && str != 'Grand Total'){
                categorytDataMapTemp.put(str,categorytDataMap.get(str));
            }
        }
        categorytDataMapTemp.put('Unserved',categorytDataMap.get('Unserved'));
        categorytDataMapTemp.put('Grand Total',categorytDataMap.get('Grand Total'));
        return categorytDataMapTemp.values();
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getAgeingData(string towerId){
        map<string,ExecutiveCategoryData> categorytDataMap = new map<string,ExecutiveCategoryData>();
        list<PropStrength__Broker_Payment_Milestone__c> pmList = new list<PropStrength__Broker_Payment_Milestone__c>();
        map<string, list<PropStrength__Broker_Payment_Milestone__c>> bookingToPM = new map<string, list<PropStrength__Broker_Payment_Milestone__c>>();
        if(towerId == 'All'){
            pmList = [select id,PropStrength__Due_Date__c,PropStrength__Total_Brokerage_Due__c, PropStrength__Booking_ID__c
                      from PropStrength__Broker_Payment_Milestone__c 
                      where PropStrength__Booking_ID__r.PropStrength__Status__c != 'Rejected' AND 
                      PropStrength__Booking_ID__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Due_Date__c != null AND 
                      PropStrength__Due_Date__c <= TODAY 
                      AND PropStrength__Booking_ID__c != null 
                      ORDER BY PropStrength__Due_Date__c ASC];
        }
        else{
            pmList = [select id,PropStrength__Due_Date__c,PropStrength__Total_Brokerage_Due__c, PropStrength__Booking_ID__c
                      from PropStrength__Broker_Payment_Milestone__c 
                      where PropStrength__Booking_ID__r.PropStrength__Status__c != 'Rejected' AND 
                      PropStrength__Booking_ID__r.PropStrength__Status__c = 'Audit Approved' AND 
                      PropStrength__Due_Date__c != null AND 
                      PropStrength__Due_Date__c <= TODAY 
                      AND PropStrength__Booking_ID__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId 
                      AND PropStrength__Booking_ID__c != null 
                      ORDER BY PropStrength__Due_Date__c ASC];
        }
        
        for(PropStrength__Broker_Payment_Milestone__c pm : pmList){
            if(bookingToPM.containsKey(pm.PropStrength__Booking_ID__c)){
                list<PropStrength__Broker_Payment_Milestone__c> pms = bookingToPM.get(pm.PropStrength__Booking_ID__c);
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Booking_ID__c,pms);
            }
            else{
                list<PropStrength__Broker_Payment_Milestone__c> pms = new list<PropStrength__Broker_Payment_Milestone__c>();
                pms.add(pm);
                bookingToPM.put(pm.PropStrength__Booking_ID__c,pms);
            }
        }

        map<string,PropStrength__Application_Booking__c> bookingIdToBooking = new map<string,PropStrength__Application_Booking__c>();
        for(PropStrength__Application_Booking__c b : [select id,PropStrength__Primary_Customer__r.MobilePhone,PropStrength__Property__r.PropStrength__Tower__c,
                            PropStrength__Booking_Date__c,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                            Name,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Property_Name__c,
                            PropStrength__Primary_Applicant_Name__c,PropStrength__Total_Agreement_Amount__c, 
                            PropStrength__Primary_Customer__r.VCC1__Mobile_Encrypted__c 
                            from PropStrength__Application_Booking__c where Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }

        for(string booking : bookingToPM.keySet()){
            PropStrength__Application_Booking__c bk = bookingIdToBooking.get(booking);
            Integer diffDays = 0;
            long sum = 0;
        	Boolean milestoneHit = false;
            String ageingColor = '';
            if(bookingToPM.containsKey(booking)){
                for(PropStrength__Broker_Payment_Milestone__c pm : bookingToPM.get(booking)){
                    sum = sum + (long)pm.PropStrength__Total_Brokerage_Due__c;
                    /*if (sum > (long)bk.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                        Date milestoneDate = pm.PropStrength__Due_Date__c;
                        Date startDate = Date.today();
                        Date endDate = milestoneDate;
                        diffDays = endDate.daysBetween(startDate);
                        milestoneHit = true;
                    }*/
                }
            }
            if (diffDays <= 30) {
                ageingColor = 'Green';                        
            } else if (diffDays > 30 && diffDays <= 60) {
                ageingColor = 'Yellow';  
            } else if (diffDays > 60 && diffDays <= 90) {
                ageingColor = 'Amber';  
            } else if(diffDays > 90){
                ageingColor = 'Red';  
            }
            if(categorytDataMap.containsKey(ageingColor)){
                ExecutiveCategoryData d = categorytDataMap.get(ageingColor);
                d.categoryCount = d.categoryCount + 1;
                //d.saleValue = (bk.Agreement_Value__c!=null)?(d.saleValue + (Long)bk.Agreement_Value__c):d.saleValue;
                d.saleValue = 0;
                //d.collected = (bk.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)bk.Total_On_Account_Money_With_Registration__c):d.collected;
                d.collected = 0;
                //d.due = (bk.Due_Payments__c!=null)?(d.due + (Long)bk.Due_Payments__c):d.due;
                d.due = 0;
                categorytDataMap.put(ageingColor, d);
            }
            else {
                ExecutiveCategoryData d = new ExecutiveCategoryData();
                d.towerId = bk.PropStrength__Property__r.PropStrength__Tower__c;
                d.towerName = bk.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c;
                d.category = ageingColor;
                d.categoryCount = 1;
                //d.saleValue = (bk.Agreement_Value__c!=null)?(Long)bk.Agreement_Value__c:0;
                d.saleValue = 0;
                //d.collected = (bk.Total_On_Account_Money_With_Registration__c!=null)?(Long)bk.Total_On_Account_Money_With_Registration__c:0;
                d.collected = 0;
                //d.due = (bk.Due_Payments__c!=null)?(Long)bk.Due_Payments__c:0;
                d.due = 0;
                categorytDataMap.put(ageingColor, d);
            }
        }
        map<string,ExecutiveCategoryData> categorytDataMapTemp = new map<string,ExecutiveCategoryData>();
        if(categorytDataMap.containsKey('Green'))
            categorytDataMapTemp.put('Green (< 30 Days)', categorytDataMap.get('Green'));
        if(categorytDataMap.containsKey('Yellow'))
            categorytDataMapTemp.put('Yellow (31-60 Days)', categorytDataMap.get('Yellow'));
        if(categorytDataMap.containsKey('Amber'))
            categorytDataMapTemp.put('Amber (61-90 Days)', categorytDataMap.get('Amber'));
        if(categorytDataMap.containsKey('Red'))
            categorytDataMapTemp.put('Red (> 91 Days)', categorytDataMap.get('Red'));

        categorytDataMap = new map<string,ExecutiveCategoryData>();

        for(string key : categorytDataMapTemp.keySet()){
            ExecutiveCategoryData ecd = categorytDataMapTemp.get(key);
            ecd.category = key;
            categorytDataMap.put(key, ecd);
        }
        return categorytDataMap.values();
    }

    public class ExecutiveCategoryData {
        @AuraEnabled public string towerId;
        @AuraEnabled public string towerName;
        @AuraEnabled public string category;
        @AuraEnabled public Integer categoryCount;
        @AuraEnabled public Long saleValue;
        @AuraEnabled public Long collected;
        @AuraEnabled public Long due;
        @AuraEnabled public string fontWeight;
        @AuraEnabled public list<long> futureMonthlyDues;

        ExecutiveCategoryData(){
            towerId = '';
            towerName = '';
            category = '';
            categoryCount = 0;
            saleValue = 0;
            collected = 0;
            due = 0;
            fontWeight = '';
            futureMonthlyDues = new list<long>();
        }
    }

    public class ExecutiveTargetData {
        @AuraEnabled public string towerId;
        @AuraEnabled public string towerName;
        @AuraEnabled public long target;
        @AuraEnabled public long achieved;
        @AuraEnabled public Decimal achievedPercentage;
        public ExecutiveTargetData(){
            towerId = '';
            towerName = '';
            target = 0;
            achieved = 0;
            achievedPercentage = 0;
        }
    }
    
    public class BookingWrapper implements Comparable {
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
        @AuraEnabled public string demandRaised;
        @AuraEnabled public Decimal balance;
        @AuraEnabled public String ppdId;
        @AuraEnabled public String ppdName;
        @AuraEnabled public String termStatus;
        
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
            demandRaised = '';
            balance = 0;
            ppdId = '';
            ppdName = '';
            termStatus = '';
        }
        
        public Integer compareTo(Object objToCompare) {
            if(category == 'Advance Payments')
                return Integer.valueOf(((BookingWrapper)objToCompare).fullDue - fullDue);
            else
                return Integer.valueOf(((BookingWrapper)objToCompare).due - due);
        }
    }
}