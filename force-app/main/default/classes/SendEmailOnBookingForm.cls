//TestClass: TestSendEmailOnBookingForm
global class SendEmailOnBookingForm Implements Schedulable {
     public static List<String> bookingNames=NULL;
    
    global void execute(SchedulableContext sc)
    {
        insertBookings(bookingNames);   
    }
    
    public void insertBookings(List<String> bookingNames) {
        
        Shoba_Default_Settings__mdt sobhaSettings = [SELECT booking_cancellation_days__c 
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        Shoba_Default_Settings__mdt siniyaSettings = [SELECT booking_cancellation_days__c 
                                                      FROM Shoba_Default_Settings__mdt 
                                                      WHERE QualifiedApiName = 'Sobha_Siniya_Island'
                                                      LIMIT 1];
        
        List<opportunity> oppUpdate = new List<opportunity>();
        List<ID> unitIdList = new List<Id>();
        List<Id> oppIdList = new List<ID>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<unit__c> unitUpdate = new List<Unit__c>();
        List<String> invalidEmails = new List<String>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
       
        //DateTime myDateTime = DateTime.newInstance(2024, 9, 25, 4, 0, 0); // need to uncomment
        Integer sobhaCancellationDays = Integer.valueOf(sobhaSettings.booking_cancellation_days__c)-1;
        Integer siniyaCancellationDays = Integer.valueOf(siniyaSettings.booking_cancellation_days__c)-1;
        Datetime sobhaConsideredDateTime = System.today().addDays((-1)*sobhaCancellationDays);
        Datetime siniyaConsideredDateTime = System.today().addDays((-1)*siniyaCancellationDays);
        List<Error_Log__c> errorLogRecList = new List<Error_Log__c>();
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        String excemptionTowerName = System.label.ExcemtionTower;
        Datetime condieredDateFor2Days = System.today().addDays((-1)*1);
        Date consider2days = Date.newInstance(condieredDateFor2Days.year(), condieredDateFor2Days.month(), condieredDateFor2Days.day());
        
        Date sobhaConsideredDate = Date.newInstance(sobhaConsideredDateTime.year(), sobhaConsideredDateTime.month(), sobhaConsideredDateTime.day());
        Date siniyaConsideredDate = Date.newInstance(siniyaConsideredDateTime.year(), siniyaConsideredDateTime.month(), siniyaConsideredDateTime.day());
        //Datetime condieredDate2 = consideredDate1.addDays(1);
        //Integer bookingFormDays = 7;
        Integer bookingFormDays;
        List<Booking__c> bookingList = new List<Booking__c>();
        
        Map<Id, Id> bookingIdSMIdMap = new Map<Id, Id>();
        Map<Id, Id> bookingIdtoUnitIdMap = new Map<Id, Id>();
        Map<Id, Id> bookingIdtoOppIdMap = new Map<Id, Id>();
        Map<Id, Messaging.SingleEmailMessage> bookingIdtoEmailMap = new Map<Id, Messaging.SingleEmailMessage>();
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        
        system.debug('Eureka1 : ' + excemptionTowerName);
        system.debug('Eureka2 : ' + sobhaConsideredDate);
        system.debug('Eureka2 : ' + sobhaConsideredDate);
        system.debug('Eureka3 : ' + consider2days);
       
        
        
        bookingList = getBookingRecords(excemptionTowerName, sobhaConsideredDate,siniyaConsideredDate, consider2days,bookingNames);
        System.debug('bookingList ----> ' + bookingList);
        
        List<Unit_hold__c> uhList = new List<Unit_hold__c>();
        if(bookingList.size()>0){
            //SOB-336 start
            Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
            for(Booking__c booking: [SELECT Id, 
                                     Sales_Managers__r.managerid, 
                                     Unit__c,
                                     Unit__r.Name,
                                     Tower__c,
                                     Opportunity__c, 
                                     Project__r.Name,
                                     Primary_Applicant_Name__c,
                                     Primary_Applicant_Email__c,
                                     (SELECT Name, Email_Address__c FROM ApplicantDetails__r WHERE Applicant_Number__c != 'Primary Applicant') 
                                     FROM Booking__c 
                                     WHERE ID IN :bookingList])
            {
                
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
            System.debug('bookingIdSMIdMap ----> ' + bookingIdSMIdMap);
            System.debug('bookingIdtoUnitIdMap ----> ' + bookingIdtoUnitIdMap);
            System.debug('bookingIdtoOppIdMap ----> ' + bookingIdtoOppIdMap);
            ////SOB-336 end
            for(Booking__c booking1 : bookingList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Cancellation Notice ' +booking1.Unit__r.Name+' '+booking1.Tower__c+' '+booking1.Project__r.Name);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                List <String> lstStringbccaddress = new List <String>();
                String body='';
                if( booking1.Project__r.Name == 'Sobha Siniya Island')
                {
                    bookingFormDays = Integer.valueOf(siniyaSettings.booking_cancellation_days__c);
                    body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'We refer to the unit '+booking1.Unit__r.Name+','+' Sobha Siniya Island – '+booking1.Tower__c+'.<br/><br/>'+
                        'Since we have not received signed booking form for unit blocked, the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                        'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts, or any other marketing material.<br/><br/>'+
                        'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses, and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                        'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on customercare@sobhasiniyaisland.com if you have any questions.<br/><br/>'+
                        'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha Siniya Island.'; 
                }
                else
                {
                    bookingFormDays = Integer.valueOf(sobhaSettings.booking_cancellation_days__c);
                    
                    body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'We refer to the unit '+booking1.Unit__r.Name+','+' Sobha Hartland – '+booking1.Tower__c+'.<br/><br/>'+
                        'Since we have not received signed booking form for unit blocked, the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                        'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts, or any other marketing material.<br/><br/>'+
                        'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses, and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                        'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on '+System.label.SobhaHelpdesk+' if you have any questions.<br/><br/>'+
                        'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha LLC';    
                }
                
                if((booking1.Signed_Status__c == null || booking1.Signed_Status__c == '') && booking1.Status__c =='UnProcessed'){
                    oppIdList.add(booking1.Opportunity__c);
                    unitIdList.add(booking1.Unit__c);
                    booking1.Status__c = 'Cancelled';
                    //booking1.Reason_For_Cancellation_D__c = 'Auto cancellation (7 days policy)';
                    booking1.Reason_For_Cancellation_D__c = 'Auto cancellation ('+bookingFormDays+' days policy)';
                    //booking1.Unit__c=null;
                    //booking1.Opportunity__c=null;
                    booking1.Cancellation_Date__c = System.now();
                    
                    bookList.add(booking1);
                    
                    //user u = [select id,email from User where id =: booking1.ownerId];    
                    //if(u.Email != null && u.Email != ''){
                    
                    //lstStringtoaddress.add(u.Email);  
                    //}                   
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
                        
                        if(booking1.unit__r.Tower__r.name == excemptionTowerName){
                            bookingFormDays = 2;
                        }
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
                errorLogRecList.addAll(logError(bookList[i],srList2[i]));
            }
        }
        System.debug('successBookingIdSet ----> ' + successBookingIdSet);
        System.debug('successUnitIdSet ----> ' + successUnitIdSet);
        System.debug('successOppIdSet ----> ' + successOppIdSet);
        
        if(successBookingIdSet.size() > 0) {
            for(Id bookingId : successBookingIdSet) {
                unit_hold__c uh = new unit_hold__c();
                If(bookingIdSMIdMap.containsKey(bookingId)) {
                    uh.sales_director__c = bookingIdSMIdMap.get(bookingId);
                }
                If(bookingIdtoUnitIdMap.containsKey(bookingId)) {
                    uh.unit__c = bookingIdtoUnitIdMap.get(bookingId);
                }
                uh.status__c = 'active';
                uh.Booking__c = bookingId;
                uh.Reason__c = 'Booking form not uploaded in '+ bookingFormDays +' days';
                
                uhList.add(uh);  
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
               
                //unit.Reason_for_Cancellation__c = 'Non-submission of Signed Booking Form for Booking Id: '+unit.Booking__r.Name+' within 7 days.';
                unit.Reason_for_Cancellation__c = 'Non-submission of Signed Booking Form for Booking Id: '+unit.Booking__r.Name+' within '+bookingFormDays+ 'days.';
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
                opp.S_Active__c = false;
                opp.Status__c = 'Inactive';
                
                oppUpdate.add(opp);
                
            }
        }
        
        Database.SaveResult[] srList1 = database.insert(uhList, false);
        for (Integer i=0; i < srList1.size(); i++) {
            if (srList1[i].isSuccess()) {
                //System.debug('Unit Hold Inserted Successfully');
            } else {
                errorLogRecList.addAll(logError(uhList[i],srList1[i]));
            }
        }
        
        Database.SaveResult[] srList3 = database.update(unitUpdate, false);
        for (Integer i=0; i < srList3.size(); i++) {
            if (srList3[i].isSuccess()) {
                //System.debug('Unit Updated Successfully');
            } else {
                errorLogRecList.addAll(logError(unitUpdate[i],srList3[i]));
                
            }
        }
        
        Database.SaveResult[] srList4 = database.update(oppUpdate, false);
        for (Integer i=0; i < srList4.size(); i++) {
            if (srList4[i].isSuccess()) {
                //System.debug('Opportunity Updated Successfully');
            } else {
                errorLogRecList.addAll(logError(oppUpdate[i],srList4[i]));
                
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
            invalidEmailMessage.setSubject('Invalid customer email in no SBF uploaded booking');
            invalidEmailMessage.setToAddresses(new List<String>{System.label.SobhaSalesOp});
            String body = 'Below bookings didnt get cancelled due to invalid customer email address please take action :- \n';
            for(String email : invalidEmails){
                body = body + email + '\n';
            }
            invalidEmailMessage.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{invalidEmailMessage});  
        }
    }
    
    private static List<Booking__c> getBookingRecords(String excemptionTowerName,DateTime sobhaConsideredDate, DateTime siniyaConsideredDate, DateTime consider2days, List<String> bookingNames) {
         DateTime sobhaMyDateTime = DateTime.newInstance(2024, 9, 25, 0, 0, 0);
         DateTime siniyaMyDateTime = DateTime.newInstance(2024, 10, 25, 0, 0, 0);
        System.debug('excemptionTowerName:'+excemptionTowerName);
        System.debug('siniyaConsideredDate:'+ siniyaConsideredDate);
        System.debug('sobhaConsideredDate:'+ sobhaConsideredDate);
        System.debug('consider2days:'+consider2days);
        
            
            if(Test.isRunningTest()) {
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
                        unit__r.Tower__r.name,
                        Unit__r.Tower__r.Project__r.Name
                        FROM Booking__c 
                        LIMIT 50000];
            }
        else if(bookingNames==NULL){
            return  [SELECT ID,
                     STATUS__C,
                     Opportunity__c,
                     opportunity__r.StageName,
                     opportunity__r.Unit__c,
                     unit__r.Booking__c,
                     Name,
                     Unit__r.Unit_Status__c,
                     Signed_Status__c,
                     Unit__c, Tower__c,
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
                     Unit__r.Tower__r.Project__r.Name
                     FROM Booking__c 
                     WHERE Status__c = 'UnProcessed'  
                     AND (
                         //-- Condition for non Siniya projects 
                         (unit__r.Tower__r.name != :excemptionTowerName 
                          AND unit__r.Tower__r.Project__r.Name != 'Sobha Siniya Island' 
                          AND Booking_Date__c < :sobhaConsideredDate 
                          AND Booking_Date__c >= :sobhaMyDateTime)
                         OR 
                         //-- Condition for Siniya projects
                         (unit__r.Tower__r.Project__r.Name = 'Sobha Siniya Island' 
                          AND Booking_Date__c < :siniyaConsideredDate 
                          AND Booking_Date__c >= :siniyaMyDateTime)
                         OR
                         //-- Condition for exemption tower 
                         (unit__r.Tower__r.name = :excemptionTowerName 
                          AND Booking_Date__c <= :consider2days 
                          AND (Booking_Date__c >= :sobhaMyDateTime OR Booking_Date__c >= :siniyaMyDateTime))
                     )
                     AND (Signed_Status__c = null OR Signed_Status__c = '')
                    LIMIT 50000];
        } else
        { 
            return  [SELECT ID,
                     STATUS__C,
                     Opportunity__c,
                     opportunity__r.StageName,
                     opportunity__r.Unit__c,
                     unit__r.Booking__c,
                     Name,
                     Unit__r.Unit_Status__c,
                     Signed_Status__c,
                     Unit__c, Tower__c,
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
                     Unit__r.Tower__r.Project__r.Name
                     FROM Booking__c 
                     WHERE Status__c = 'UnProcessed'  
                   AND Name IN : bookingNames];
            }
        
    }
    
    public static  List<Error_Log__c> logError(SObject obj,Database.SaveResult srList){
        List<Error_Log__c> errorLogRecList = new   List<Error_Log__c>();     
        for(Database.Error err : srList.getErrors()) {
            Error_Log__c errLogRec = new Error_Log__c();
            errLogRec.Class__c = 'SendEmailOnBookingForm-Error';
            errLogRec.Message__c = obj.Id + ' - ' +  err.getMessage();
            errorLogRecList.add(errLogRec);
            
        }
        return errorLogRecList;
    }
    
}