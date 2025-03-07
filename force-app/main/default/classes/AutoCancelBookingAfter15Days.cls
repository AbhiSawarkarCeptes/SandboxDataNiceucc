global class AutoCancelBookingAfter15Days Implements Database.Batchable<sObject>,Schedulable {
    
    global List<Booking__c> start(Database.BatchableContext BC){
        integer dateDay = 01;
        if(test.isRunningTest())dateDay = 3;
        DateTime myDateTime = DateTime.newInstance(2023, 01, dateDay, 0, 0, 0);
        Datetime condieredDateFor2Days = System.today().addDays((-1)*1);
        Date consider2days = Date.newInstance(condieredDateFor2Days.year(), condieredDateFor2Days.month(), condieredDateFor2Days.day());
        Integer cancellationDays = Integer.valueOf(system.label.Auto_Cancellation_Booking);
        Datetime condieredDate = System.today().addDays((-1)*cancellationDays);
       
        Date consideredDate1 = Date.newInstance(condieredDate.year(), condieredDate.month(), condieredDate.day());
        Datetime condieredDate2 = consideredDate1.addDays(1);
        system.debug('consideredDate1=='+consideredDate1);
        system.debug('myDateTime=='+myDateTime);
        
        return  getBookingRecords( consideredDate1, consider2days, myDateTime);
       
    }
    global void execute(SchedulableContext sc)
    {
        database.executebatch(new AutoCancelBookingAfter15Days(), 5);
        
    }
    
    public void  execute(Database.BatchableContext bc, List<Booking__c> bookingList){
        List<opportunity> oppUpdate = new List<opportunity>();
        List<ID> unitIdList = new List<Id>();
        List<Id> oppIdList = new List<ID>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<unit__c> unitUpdate = new List<Unit__c>();
        List<String> invalidEmails = new List<String>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
         List<Error_Log__c> errorLogRecList = new List<Error_Log__c>();
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        Map<Id, Id> bookingIdtoUnitIdMap = new Map<Id, Id>();
        Map<Id, Id> bookingIdtoOppIdMap = new Map<Id, Id>();
        Map<Id, Messaging.SingleEmailMessage> bookingIdtoEmailMap = new Map<Id, Messaging.SingleEmailMessage>();
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        
        System.debug('bookingList ----> ' + bookingList);
        List<Unit_hold__c> uhList = new List<Unit_hold__c>();
        if(bookingList.size()>0){
            List<Payment_Milestones__c> paymentPlan = [SELECT ID,quotation__r.Booking__c,total_installment__c
            FROM Payment_Milestones__c WHERE
            quotation__r.Booking__c IN: bookingList AND Installment__C = 'Booking Amount'];
            Map<Id,Decimal> mapOfBookingToPaymentPlan = new Map<Id,Decimal>();
            for(Payment_Milestones__c pp : paymentPlan){
                mapOfBookingToPaymentPlan.put(pp.quotation__r.Booking__c,pp.total_installment__c);
            }
            Set<Id> bookingToCancel = new Set<Id>();
            Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
            Map<String,List<Payment_Request__c>> mapKeyToPaymentRequestAmount = new Map<String,List<Payment_Request__c>>();
            Set<Id> unitIds = new Set<Id>();
            for(Booking__c booking : bookingList){
                unitIds.add(booking.unit__c);
            }
            for(Payment_Request__c pr : [Select Amount__c,booking__c,unit__c,Email__c,mode__c FROM Payment_Request__c WHERE 
            ((Status__c = 'Approved' AND mode__c != 'International Wire Transfer')
            OR ((Status__c = 'Approved' OR Status__c = 'Submitted to Accounts for Amount Confirmation') 
                AND mode__c = 'International Wire Transfer'))
            AND (Booking__c IN :bookingList 
                 OR Unit__c IN :unitIds)
                 ]){
                    if(pr.booking__c != null){
                        if(!mapKeyToPaymentRequestAmount.containsKey(pr.booking__c+pr.email__c)){
                            mapKeyToPaymentRequestAmount.put(pr.booking__c+pr.email__c, new List<Payment_Request__c>());
                        }
                        mapKeyToPaymentRequestAmount.get(pr.booking__c+pr.email__c).add(pr);
                    }else if(pr.unit__c != null){
                        if(!mapKeyToPaymentRequestAmount.containsKey(pr.unit__c+pr.email__c)){
                            mapKeyToPaymentRequestAmount.put(pr.unit__c+pr.email__c, new List<Payment_Request__c>());
                        }
                        mapKeyToPaymentRequestAmount.get(pr.unit__c+pr.email__c).add(pr);
                    }

            }
            for(Booking__c booking: [SELECT Id, 
                                     Sales_Managers__r.managerid, 
                                     Unit__c,
                                     Unit__r.Name,
                                     Tower__c,
                                     Opportunity__c, 
                                     Project__r.Name,
                                     Primary_Applicant_Name__c,
                                     Primary_Applicant_Email__c,
                                     (SELECT Name, Email_Address__c FROM ApplicantDetails__r WHERE Applicant_Number__c != 'Primary Applicant') ,
                                     (Select Amount__c FROM Payment_Requests__r WHERE 
                                     (Status__c = 'Approved' AND mode__c != 'International Wire Transfer')
                                     OR ((Status__c = 'Approved' OR Status__c = 'Submitted to Accounts for Amount Confirmation') AND mode__c = 'International Wire Transfer'))
                                     FROM Booking__c 
                                     WHERE ID IN :bookingList])
            {
                decimal totalAmount = 0;
                boolean isIwt = false;
                if(mapKeyToPaymentRequestAmount.containsKey(booking.id+booking.Primary_Applicant_Email__c)){
                    for(Payment_Request__c pr : mapKeyToPaymentRequestAmount.get(booking.id+booking.Primary_Applicant_Email__c)){
                        totalAmount += pr.Amount__c;
                        if(pr.mode__c == 'International Wire Transfer'){
                            isIwt = true;
                        }
                    
                    }
                }
                if(mapKeyToPaymentRequestAmount.containsKey(booking.unit__c+booking.Primary_Applicant_Email__c)){
                    for(Payment_Request__c pr : mapKeyToPaymentRequestAmount.get(booking.unit__c+booking.Primary_Applicant_Email__c)){
                        totalAmount += pr.Amount__c;
                        if(pr.mode__c == 'International Wire Transfer'){
                            isIwt = true;
                        }
                    }
                }
               
                if(totalAmount >= mapOfBookingToPaymentPlan.get(booking.id)){
                    continue;
                }
                if(isIwt == true){
                    continue;
                }
                bookingToCancel.add(booking.id);
                for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                    if(!mapOfBookingToAddress.containsKey(booking.id)){
                        mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                    }else{
                        mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                    }
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
            ////SOB-336 end
            for(Booking__c booking1 : bookingList){
                
                if(bookingToCancel.contains(booking1.id)){
                    oppIdList.add(booking1.Opportunity__c);
                    unitIdList.add(booking1.Unit__c);
                    booking1.Status__c = 'Cancelled';
                    booking1.Reason_For_Cancellation_D__c = 'Auto cancellation (15 days policy)';
                    booking1.Cancellation_Date__c = System.now();
                    bookList.add(booking1);
                    
                    //user u = [select id,email from User where id =: booking1.ownerId];    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                    email.setSubject('Cancellation Notice ' +booking1.Unit__r.Name+' '+booking1.Tower__c+' '+booking1.Project__r.Name);
                    List <String> lststringtoaddress = new List<String>();
                    List <String> lstStringccaddress = new List <String>();
                    List <String> lstStringbccaddress = new List <String>();
                    
                    String body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                    'Since you have not made full payment of the instalment amount, as per the terms of the booking form<br/>'+
                    'signed by you for the Unit in accordance with our standard sales policy despite repeated reminders<br/>'
                    +
                    'from our Sales team, the booking is hereby cancelled.<br/><br/>'
                    +
                    'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner,<br/>'
                    +'notwithstanding the possession of any documents with respect to the Units including but not limited to'
                    +'brochures, receipts, or any other marketing material.<br/><br/>'
                    +'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses,<br/>'
                    +'and consequences arising out of or with respect to any compliance procedures or legal actions by any<br/>'
                    +'authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due<br/>'
                    +'to the cancellation of booking.<br/><br/>'
                    +'We regret that the purchase of the Unit could not be completed on this occasion, however, should you<br/>'
                    +'be interested in our range of products, please do feel free to contact our sales team or visit<br/>'
                    +'www.sobha.com. You may also write to us on helpdesk@sobha-me.com if you have any questions.<br/><br/>'
                    +'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'
                    +'Thanks & Regards,<br/>'
                    +'CRM Team<br/>';    
                                      
                    String emailAddressFromBooking = mapOfBookingToAddress.get(booking1.id);
                    if(!string.isBlank(emailAddressFromBooking)){
                        lststringtoaddress.addAll(emailAddressFromBooking.split(','));
                    }
                    if(booking1.Primary_Applicant_Email__c != null && booking1.Primary_Applicant_Email__c != ''){
                        lstStringtoaddress.add(booking1.Primary_Applicant_Email__c);
                    }
                    SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
                    if(booking1.Sales_Head__c != null){
                        lstStringccaddress.add(booking1.Sales_Head__r.email);
                        if(booking1.Sales_Head__r.ManagerId != null)
                            lstStringccaddress.add(booking1.Sales_Head__r.Manager.Email);
                        SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
                    }
                    if(booking1.Secondary_Sales_Head__c!=null && booking1.Secondary_Sales_Head__r.ManagerId != null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Head__r.Manager.Email);
                    }
                    if(booking1.Sales_Managers__c!=null){
                        
                        lstStringccaddress.add(booking1.Sales_Managers__r.email);
                    }
                    if(booking1.Secondary_Sales_Manager__c!=null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Manager__r.email);
                    }
                    if(booking1.Secondary_Sales_Head__c!=null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Head__r.email);
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
                    //email.setbccAddresses(lstStringbccaddress);
                    email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');  
                    bookingIdtoEmailMap.put(booking1.Id, email);
                    system.debug('i am afteremail'+email);
                }
            }
        }
        
        Set<Id> successBookingIdSet = new Set<Id>();
        Set<Id> successUnitIdSet = new Set<Id>();
        Set<Id> successOppIdSet = new Set<Id>();
      
        Database.SaveResult[] srList2 = database.update(bookList, false);
        for (Integer i=0; i < srList2.size(); i++) {
            if (srList2[i].isSuccess()) {
                Id bookingId = srList2[i].getId();
                System.debug(bookingId);
                
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
                    errLogRec.Class__c = 'AutoCancelBookingAfter15Days';
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
                                      Customers__c,
                                      Unit_Hold_min_percentage__c,
                                      Puchase_Price__c 
                                      FROM Unit__c 
                                      Where Id IN : successUnitIdSet];
            
            List<Unit_Hold_Min_Percentage_Mapping__mdt> minPercentageListMdt = [SELECT ID,
                                                                                Max_Purchase_Price__c,
                                                                                Unit_Hold_Min_Percentage__c
                                                                                FROM Unit_Hold_Min_Percentage_Mapping__mdt];
            for(Unit__c unit : unitList){        
                unit.Unit_Status__c = 'Available';
                unit.Reason_for_Cancellation__c = 'Auto Cancellation Booking on Installment payment miss : '+unit.Booking__r.Name+' within 15 days.';
                unit.Booking__c = null;
                unit.Customers__c = null;
                if(!minPercentageListMdt.isEmpty()
                   && unit.Puchase_Price__c <= minPercentageListMdt[0].Max_Purchase_Price__c)   
                {
                    unit.Unit_Hold_min_percentage__c = minPercentageListMdt[0].Unit_Hold_Min_Percentage__c;                   
                }
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
        
        Database.SaveResult[] srList1 = database.insert(uhList, false);
        for (Integer i=0; i < srList1.size(); i++) {
            if (srList1[i].isSuccess()) {
                //System.debug('Unit Hold Inserted Successfully');
            } else {
                for(Database.Error err : srList1[i].getErrors()) {
                    errorLogRecList.add(new Error_Log__c(Class__c = 'AutoCancelBookingAfter15Days',Message__c = uhList[i].Id + ' - ' +  err.getMessage()));
                }
            }
        }
        
        Database.SaveResult[] srList3 = database.update(unitUpdate, false);
        for (Integer i=0; i < srList3.size(); i++) {
            if (srList3[i].isSuccess()) {
                //System.debug('Unit Updated Successfully');
            } else {
                for(Database.Error err : srList3[i].getErrors()) {
                   errorLogRecList.add(new Error_Log__c(Class__c = 'AutoCancelBookingAfter15Days',Message__c = unitUpdate[i].Id + ' - ' +  err.getMessage()));
                }
            }
        }
        
        Database.SaveResult[] srList4 = database.update(oppUpdate, false);
        for (Integer i=0; i < srList4.size(); i++) {
            if (srList4[i].isSuccess()) {
                //System.debug('Opportunity Updated Successfully');
            } else {
                for(Database.Error err : srList4[i].getErrors()) {
                   errorLogRecList.add(new Error_Log__c(Class__c = 'AutoCancelBookingAfter15Days',Message__c = oppUpdate[i].Id + ' - ' +  err.getMessage()));
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
            invalidEmailMessage.setSubject('Invalid customer email in Auto Cancellation - 15 days');
            invalidEmailMessage.setToAddresses(new List<String>{System.label.SobhaSalesOp});
            String body = 'Below bookings didnt get cancelled due to invalid customer email address please take action :- \n';
            for(String email : invalidEmails){
                body = body + email + '\n';
            }
            invalidEmailMessage.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{invalidEmailMessage});  
        }
    }
    
    private static List<Booking__c> getBookingRecords(Date consideredDate1, DateTime consider2days, DateTime myDateTime) {
        return [SELECT ID,
                STATUS__C,
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
                unit__r.Tower__r.name
                FROM Booking__c 
                WHERE Status__c != 'Cancelled'  
                AND (DAY_ONLY(Booking_Date__c) <=:consideredDate1 
                AND createddate >=:myDateTime) 
                //ID = 'a065t000001QolXAAS'
                and( Unit__r.Roadshow_Booking__c = false And Unit__r.No_cancellation_CSO_Approval__c = false
                and unit__r.File_Note__c = false)
               
                LIMIT 50000];
    }
    public void finish(Database.BatchableContext bc) {
       
    }
    
}