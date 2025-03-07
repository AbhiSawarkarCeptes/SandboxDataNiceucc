//TestClass:TestCancelBookingOnNonSubmissionOfTwoPer
global class CancelBookingOnNonSubmissionOfTwoPercent Implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        insertBookings();   
    }
    
    public void insertBookings() {
        
        Shoba_Default_Settings__mdt sobhaSettings = [SELECT Booking_Cancellation_Days_for_2__c 
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        
        List<opportunity> oppUpdate = new List<opportunity>();
        List<ID> unitIdList = new List<Id>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<unit__c> unitUpdate = new List<Unit__c>();
        List<String> invalidEmails = new List<String>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Integer bookingCancellationDaysFor2Percent  = Integer.valueOf(sobhaSettings.Booking_Cancellation_Days_for_2__c);
        Datetime bookingCancellationDateTimeFor2Percent;
        if(!Test.isRunningTest())
            bookingCancellationDateTimeFor2Percent = System.today().addDays((-1)*bookingCancellationDaysFor2Percent);
        else
            bookingCancellationDateTimeFor2Percent = System.today().addDays((-1)*14);
        List<Error_Log__c> errorLogRecList = new List<Error_Log__c>();
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        Date bookingCancellationDateFor2Percent = Date.newInstance(bookingCancellationDateTimeFor2Percent.year(), bookingCancellationDateTimeFor2Percent.month(), bookingCancellationDateTimeFor2Percent.day());
        List<Booking__c> bookingList = new List<Booking__c>();
        
        Map<Id, Id> bookingIdSMIdMap = new Map<Id, Id>();
        Map<Id, Id> bookingIdtoUnitIdMap = new Map<Id, Id>();
        Map<Id, Id> bookingIdtoOppIdMap = new Map<Id, Id>();
        Map<Id, Messaging.SingleEmailMessage> bookingIdtoEmailMap = new Map<Id, Messaging.SingleEmailMessage>();
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        
        bookingList = getBookingRecords(bookingCancellationDateFor2Percent);
        System.debug('booking List'+bookingList);
        List<Unit_hold__c> uhList = new List<Unit_hold__c>();
        if(bookingList.size()>0){
            Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
            set<string> bookingNames = new set<string>();
            map<string,decimal> bookingToMoneyReceived = new map<string,decimal>();
            
            for(Booking__c booking: bookingList)
            {
                bookingNames.add(booking.Name);
                for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                    if(!mapOfBookingToAddress.containsKey(booking.id)){
                        mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                    }else{
                        mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                    }
                }
                if(booking.Sales_Managers__c != null && booking.Sales_Managers__r.managerid != null) {
                    bookingIdSMIdMap.put(booking.Id, booking.Sales_Managers__r.managerid);
                }
                if(booking.Unit__c != null) {
                    bookingIdtoUnitIdMap.put(booking.Id, booking.Unit__c);
                }
                if(booking.Opportunity__c != null) {
                    bookingIdtoOppIdMap.put(booking.Id, booking.Opportunity__c);
                }
                if(booking.Primary_Applicant_Email__c != null) {
                    bookingIdtoEmailAddressMap.put(booking.Id, booking.Primary_Applicant_Email__c);
                }
                
            }
            
            for(Booking__c b : bookingList){
                unitIdList.add(b.Unit__c);
                b.Status__c = 'Cancelled';
                b.Reason_For_Cancellation_D__c = '15 days - 2%';
                
                b.Cancellation_Date__c = System.now();
                bookList.add(b);
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Cancellation Notice ' +b.Unit__r.Name+' '+b.Tower__c+' '+b.Project__r.Name);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                List <String> lstStringbccaddress = new List <String>();
                
                String body =  'Dear ' + b.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                    
                    'We refer to the Blocking Amount paid by you for the unit '+b.Unit__r.Name+', '+b.Project__r.Name+' – '+b.Tower__c+'.<br/><br/>'+
                    'Since you have not made full payment of the instalment amount, as per the terms of the booking form signed by you for the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                    'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts or any other marketing material.<br/><br/>'+
                    'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                    'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on '+System.label.SobhaHelpdesk+' if you have any questions.<br/><br/>'+
                    'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                    
                    'Thanks & Regards,<br/><br/>'+
                    'Sobha LLC'; 
                
                String emailAddressFromBooking = mapOfBookingToAddress.get(b.id);
                if(!string.isBlank(emailAddressFromBooking)){
                    lststringtoaddress.addAll(emailAddressFromBooking.split(','));
                }
                if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != ''){
                    lstStringtoaddress.add(b.Primary_Applicant_Email__c);
                }
                if(b.Sales_Head__c != null){
                    lstStringccaddress.add(b.Sales_Head__r.email);
                    if(b.Sales_Head__r.ManagerId != null)
                        lstStringccaddress.add(b.Sales_Head__r.Manager.Email);
                }
                if(b.Secondary_Sales_Head__c!=null && b.Secondary_Sales_Head__r.ManagerId != null){
                    lstStringccaddress.add(b.Secondary_Sales_Head__r.Manager.Email);
                }
                if(b.Sales_Managers__c!=null){
                    lstStringccaddress.add(b.Sales_Managers__r.email);
                }
                if(b.Secondary_Sales_Manager__c!=null){
                    lstStringccaddress.add(b.Secondary_Sales_Manager__r.email);
                }
                if(b.Secondary_Sales_Head__c!=null){
                    lstStringccaddress.add(b.Secondary_Sales_Head__r.email);
                }
                
                lstStringccaddress.add(System.label.SobhaSalesOp);
                List<String> toAddressEmails = new List<String>();
                for(String toEmail : lststringtoaddress){
                    Matcher MyMatcher = MyPattern.matcher(toEmail);
                    if(!MyMatcher.matches()){
                        invalidEmails.add(toEmail);
                    }else{
                        toAddressEmails.add(toEmail);
                    }
                }
                List<String> ccAddressEmails = new List<String>();
                for(String ccEmail : lstStringccaddress){
                    Matcher MyMatcher = MyPattern.matcher(ccEmail);
                    if(!MyMatcher.matches()){
                        invalidEmails.add(ccEmail);
                    }else{
                        ccAddressEmails.add(ccEmail);
                    }
                }
                
                email.setToAddresses(toAddressEmails);
                email.setccAddresses(ccAddressEmails);
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');  
                bookingIdtoEmailMap.put(b.Id, email);
            }
        }
        
        Set<Id> successBookingIdSet = new Set<Id>();
        Set<Id> successUnitIdSet = new Set<Id>();
        Set<Id> successOppIdSet = new Set<Id>();
        Database.SaveResult[] srList2 = database.update(bookList, false);
        for (Integer i=0; i < srList2.size(); i++) {
            if (srList2[i].isSuccess()) {
                Id bookingId = srList2[i].getId();                
                if(bookingId != null) {
                    successBookingIdSet.add(bookingId);
                }
                If(bookingIdtoUnitIdMap.containsKey(bookingId)) {
                    successUnitIdSet.add(bookingIdtoUnitIdMap.get(bookingId));
                }
                if(bookingIdtoOppIdMap.containsKey(bookingId)) {
                    successOppIdSet.add(bookingIdtoOppIdMap.get(bookingId));
                }
            } else {
                for(Database.Error err : srList2[i].getErrors()) {
                    Error_Log__c errLogRec = new Error_Log__c();
                    errLogRec.Class__c = 'CancelBookingOnNonSubmissionOfTwoPercent';
                    errLogRec.Message__c = bookList[i].Id + ' - ' +  err.getMessage();
                    errorLogRecList.add(errLogRec);
                }
            }
        }
        
        if(successUnitIdSet.size() >0 ){
            List<Unit__c> unitList = [SELECT ID,
                                      Unit_Status__c,
                                      Booking__c,
                                      Booking__r.Name,
                                      Booking__r.paid_percentage__c,
                                      Customers__c,
                                      Unit_Hold_min_percentage__c,
                                      Puchase_Price__c 
                                      FROM Unit__c 
                                      Where Id IN : successUnitIdSet];
            
            for(Unit__c unit : unitList){        
                unit.Unit_Status__c = 'Available';
                unit.Reason_for_Cancellation__c = 'Non-submission of 2% of the unit purchase price for Booking Id: '+unit.Booking__r.Name+' within 14 days.';
                
                unit.Booking__c = null;
                unit.Customers__c = null;
                unitUpdate.add(unit); 
                
            }
        }
        
        if(successOppIdSet.size()>0){
            
            List<Opportunity> oppList = [SELECT ID,UNIT__C,StageName FROM Opportunity Where id IN:successOppIdSet];
            for(Opportunity opp : oppList){
                opp.Unit__c = null;
                opp.StageName = 'Cancelled';
                oppUpdate.add(opp);
            }
        }
        
        Database.SaveResult[] srList3 = database.update(unitUpdate, false);
        for (Integer i=0; i < srList3.size(); i++) {
            if (srList3[i].isSuccess()) {
                //System.debug('Unit Updated Successfully');
            } else {
                for(Database.Error err : srList3[i].getErrors()) {
                    Error_Log__c errLogRec = new Error_Log__c();
                    errLogRec.Class__c = 'CancelBookingOnNonSubmissionOfTwoPercent';
                    errLogRec.Message__c = unitUpdate[i].Id + ' - ' +  err.getMessage();
                    errorLogRecList.add(errLogRec);
                }
            }
        }
        
        Database.SaveResult[] srList4 = database.update(oppUpdate, false);
        for (Integer i=0; i < srList4.size(); i++) {
            if (srList4[i].isSuccess()) {
                //System.debug('Opportunity Updated Successfully');
            } else {
                for(Database.Error err : srList4[i].getErrors()) {
                    Error_Log__c errLogRec = new Error_Log__c(); errLogRec.Class__c = 'CancelBookingOnNonSubmissionOfTwoPercent'; errLogRec.Message__c = oppUpdate[i].Id + ' - ' +  err.getMessage(); errorLogRecList.add(errLogRec);
                }
            }
        }
        
        if(errorLogRecList.size() > 0) {
            database.insert(errorLogRecList, false);
        }
        
        for(Id bookingId : successBookingIdSet) {
            if(bookingIdtoEmailAddressMap.get(bookingId) != null && bookingIdtoEmailAddressMap.get(bookingId) != ''){
                if(bookingIdtoEmailMap.containsKey(bookingId) && bookingIdtoEmailMap.get(bookingId) != null){
                    emails.add(bookingIdtoEmailMap.get(bookingId));
                }
            }
        }
        
        Messaging.sendEmail(emails);
        
        if(!invalidEmails.isEmpty()){
            Messaging.SingleEmailMessage invalidEmailMessage = new Messaging.SingleEmailMessage();      
            invalidEmailMessage.setSubject('Invalid customer email found while cancelling bookings for non-submission of 2% of the unit purchase price within 14 days');
            invalidEmailMessage.setToAddresses(new List<String>{System.label.SobhaSalesOp});
            String body = 'Below bookings didnt get cancelled due to invalid customer email address please take action :- \n';
            for(String email : invalidEmails){ body = body + email + '\n';}
            invalidEmailMessage.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{invalidEmailMessage});  
        }
    }
    
    private static List<Booking__c> getBookingRecords(Date bookingCancellationDateFor2Percent) {
        DateTime firstJan2023 = DateTime.newInstance(2023, 1, 1, 0, 0, 0);
        System.debug('booking cancellation : '+bookingCancellationDateFor2Percent);
        System.debug('firstJan2023 : '+firstJan2023);
         List<String> byPassProjectList = new List<String>();
        if (Label.Projects_To_Bypass_BookingCancellation != null) {
                byPassProjectList = Label.Projects_To_Bypass_BookingCancellation.split(',');
            }
        return [SELECT ID,
                STATUS__c,
                Opportunity__c,
                opportunity__r.StageName,
                opportunity__r.Unit__c,
                unit__r.Booking__c,
                Name,
                Unit__r.Unit_Status__c,
                Signed_Status__c,
                Unit__c,Tower__c,
                Project__c,
                Primary_Applicant_Name__c,
                OwnerId,
                Primary_Applicant_Email__c,
                Sales_Head__c,
                Secondary_Sales_Manager_VP__c,
                Sales_Head__r.ManagerId,
                Sales_Head__r.Manager.Email,
                Secondary_Sales_Head__r.ManagerId,
                Secondary_Sales_Head__r.Manager.Email,
                Secondary_Sales_Manager_VP__r.email,
                Sales_Head__r.email,
                Unit__r.Name,
                Project__r.Name,
                Sales_Managers__r.email,
                Secondary_Sales_Manager__r.email,
                unit__r.Customers__c,
                Booking_Date__c,
                Secondary_Sales_Head__r.email,
                Sales_Managers__r.managerid,
                unit__r.Tower__r.name,
                Unit__r.Tower__r.Project__r.Name,
                Unit__r.Puchase_Price__c,paid_percentage__C,
                (SELECT Name, Email_Address__c FROM ApplicantDetails__r WHERE Applicant_Number__c != 'Primary Applicant')
                FROM Booking__c 
                WHERE Status__c != 'Cancelled' and 
                Booking_Date__c >=: firstJan2023 
                AND DAY_ONLY(Booking_Date__c) =: bookingCancellationDateFor2Percent  
                AND (Paid_Percentage__c < 2
                     and( Unit__r.Roadshow_Booking__c = false And Unit__r.No_cancellation_CSO_Approval__c = false
                         and unit__r.File_Note__c = false))
                AND Unit__r.Tower__r.Project__r.Name NOT IN  :byPassProjectList
                
                LIMIT 50000];
    }
    
}