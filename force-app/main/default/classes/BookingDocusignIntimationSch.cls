//TestClass: TestBookingDocusignIntimationSch
global class BookingDocusignIntimationSch Implements Schedulable {
    public static List<String> bookingNames=NULL;
     public static List<String> invalidEmails = new List<String>();
    global void execute(SchedulableContext sc)
    {
        intimateCancellation(bookingNames);   
    }
    
    public static void intimateCancellation(List<String> bookingNames) {
        
        Shoba_Default_Settings__mdt sobhaSettings = [SELECT booking_cancellation_days__c 
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        Shoba_Default_Settings__mdt siniyaSettings = [SELECT booking_cancellation_days__c 
                                                      FROM Shoba_Default_Settings__mdt 
                                                      WHERE QualifiedApiName = 'Sobha_Siniya_Island'
                                                      LIMIT 1];
        
        
        List<ID> unitIdList = new List<Id>();
        List<Id> oppIdList = new List<ID>();
        List<Booking__c> bookList = new List<Booking__c>();
        
       
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        
        Integer sobhaCancellationDays = Integer.valueOf(sobhaSettings.booking_cancellation_days__c)-2;
        Integer siniyaCancellationDays = Integer.valueOf(siniyaSettings.booking_cancellation_days__c)-2;
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
		Integer bookingFormDays;
        List<Booking__c> bookingList = new List<Booking__c>();
        
        Map<Id, Messaging.SingleEmailMessage> bookingIdtoEmailMap = new Map<Id, Messaging.SingleEmailMessage>();
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        
        system.debug('Eureka1 : ' + excemptionTowerName);
        system.debug('Eureka2 : ' + sobhaConsideredDate);
        system.debug('Eureka2 : ' + sobhaConsideredDate);
        system.debug('Eureka3 : ' + consider2days);
        
        
        
        bookingList = getBookingRecords(excemptionTowerName, sobhaConsideredDate.addDays(-1),siniyaConsideredDate.addDays(-1), consider2days,bookingNames);
        System.debug('bookingList ----> ' + bookingList);
        
        List<Unit_hold__c> uhList = new List<Unit_hold__c>();
        if(bookingList.size()>0){
            //SOB-336 start
            Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
            for(Booking__c booking: bookingList)
               /* [SELECT Id, 
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
                                     WHERE ID IN :bookingList])*/
            {
                
                for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                    if(!mapOfBookingToAddress.containsKey(booking.id)){
                        mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                    }else{
                        mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                    }
                }
                  if(booking.Primary_Applicant_Email__c != null) {
                    bookingIdtoEmailAddressMap.put(booking.Id, booking.Primary_Applicant_Email__c);
                }
                
            }
           
          
            for(Booking__c booking1 : bookingList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Intimation on Non-Submission of Signed booking form: ' +booking1.Unit__r.Name+' '+booking1.Tower__c+' '+booking1.Project__r.Name);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                String body='';
                if( booking1.Project__r.Name == 'Sobha Siniya Island')
                {
                    bookingFormDays = Integer.valueOf(siniyaSettings.booking_cancellation_days__c);
                    body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'This is to inform you that the booking form with Booking ID '+booking1.Name+' for Unit #'+booking1.unit__r.Name+
                        ' has been sent through DocuSign. Please note that the booking form will be cancelled if not signed by end of today.!<br/><br/>'+
                        'If you have already signed the booking form, please disregard this message and confirm with us so we can update our records.<br/><br/>'+
                        'If you have any questions, feel free to contact our sales team or visit '+ 
                         '<a href="https://www.sobharealty.com">www.sobharealty.com</a>.' +
                        ' You can also reach us at customercare@sobhasiniyaisland.com.</br></br>'+
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha Siniya Island.'; 
                }
                else
                {
                    bookingFormDays = Integer.valueOf(sobhaSettings.booking_cancellation_days__c);
                    
                    body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'This is to inform you that the booking form with Booking ID '+booking1.Name+' for Unit #'+booking1.unit__r.Name+
                        ' has been sent through DocuSign. Please note that the booking form will be cancelled if not signed by end of today.!<br/><br/>'+
                        'If you have already signed the booking form, please disregard this message and confirm with us so we can update our records.<br/><br/>'+
                        'If you have any questions, feel free to contact our sales team or visit '+ 
                        '<a href="https://www.sobharealty.com" >www.sobharealty.come</a>.' +
                        ' You can also reach us at '+System.label.SobhaHelpdesk+'.</br></br>'+
                        
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha LLC';    
                }
                
                if((booking1.Signed_Status__c == null || booking1.Signed_Status__c == '') && booking1.Status__c =='UnProcessed'){
                    //oppIdList.add(booking1.Opportunity__c);
                    //unitIdList.add(booking1.Unit__c);
                    booking1.DS_Intimation_Date__c = System.now();
                    
                    bookList.add(booking1);
                    
                    String emailAddressFromBooking = mapOfBookingToAddress.get(booking1.id);
                    if(!string.isBlank(emailAddressFromBooking)){
                        lststringtoaddress.addAll(emailAddressFromBooking.split(','));
                    }
                    if(booking1.Primary_Applicant_Email__c != null && booking1.Primary_Applicant_Email__c != ''){
                        lstStringtoaddress.add(booking1.Primary_Applicant_Email__c);
                    }
                    
                     if(booking1.Sales_Managers__c!=null){
                        
                        /*if(booking1.unit__r.Tower__r.name == excemptionTowerName){
                            bookingFormDays = 2;
                        }*/
                        SYSTEM.DEBUG('I AM EMAIL salesMAanager'+booking1.Sales_Managers__r.email);
                        lstStringccaddress.add(booking1.Sales_Managers__r.email);
                    }
                    
                   
                   
                    if(booking1.Sales_Head__c != null){
                        lstStringccaddress.add(booking1.Sales_Head__r.email);
					SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
                    }
                    
					if(booking1.Secondary_Sales_Manager_VP__c != null){
						lstStringccaddress.add(booking1.Secondary_Sales_Manager_VP__r.email);
					SYSTEM.DEBUG('I AM EMAILVP'+booking1.Secondary_Sales_Manager_VP__r.email);
                    }
                    
                    
                    lstStringccaddress.add(System.label.SobhaSalesOp);
                    
                    List<String> toAddressEmails = validateEmail(lststringtoaddress);
                    /*for(String toEmail : lststringtoaddress){
                        Matcher MyMatcher = MyPattern.matcher(toEmail);
                        if(!MyMatcher.matches()){
                            invalidEmails.add(toEmail);
                        }else{
                            toAddressEmails.add(toEmail);
                        }
                    }*/
                    List<String> ccAddressEmails = validateEmail(lstStringccaddress);
                    /*for(String ccEmail : lstStringccaddress){
                        Matcher MyMatcher = MyPattern.matcher(ccEmail);
                        if(!MyMatcher.matches()){
                            invalidEmails.add(ccEmail);
                        }else{
                            ccAddressEmails.add(ccEmail);
                        }
                    }*/
                    
                    
                    email.setToAddresses(toAddressEmails);
                    email.setccAddresses(ccAddressEmails);
                    
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
                
            } else { 
                errorLogRecList.addAll(logError(bookList[i],srList2[i]));
            }
        }
        System.debug('successBookingIdSet ----> ' + successBookingIdSet);
        
        
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
            String body = 'Could not send Cancllation Intimation mail to these bookings due to invalid customer email address please take action :- \n';
            for(String email : invalidEmails){
                body = body + email + '\n';
            }
            invalidEmailMessage.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{invalidEmailMessage});  
        }
    }
    
    private static List<Booking__c> getBookingRecords(String excemptionTowerName,Date sobhaConsideredDate, Date siniyaConsideredDate, Date consider2days, List<String> bookingNames) {
        Date sobhaMyDateTime = Date.newInstance(2024, 9, 25);
        Date siniyaMyDateTime = Date.newInstance(2024, 10, 25);
        System.debug('excemptionTowerName:'+excemptionTowerName);
        System.debug('siniyaConsideredDate:'+ siniyaConsideredDate);
        System.debug('sobhaConsideredDate:'+ sobhaConsideredDate);
        System.debug('consider2days:'+consider2days);
        
        
        if(Test.isRunningTest()) {
            return [SELECT  ID,
                    STATUS__C,
                    Opportunity__c,
                    Opportunity__r.StageName,
                    Opportunity__r.Unit__c,
                    Unit__r.Booking__c,
                    Name,
                    Unit__r.Unit_Status__c,
                    Signed_Status__c,
                    Unit__c,
                    Tower__c,
                    Project__c,
                    Primary_Applicant_Name__c,
                    OwnerId,
                    Primary_Applicant_Email__c,
                    Sales_Head__c,
                    Sales_Head__r.ManagerId,
                    Sales_Head__r.Manager.Email,
                    Secondary_Sales_Manager_VP__c,
                    Sales_Head__r.Email,
                    Unit__r.Name,
                    Project__r.Name,
                    Sales_Managers__r.Email,
                    Secondary_Sales_Manager__r.Email,
                    Secondary_Sales_Manager_VP__r.email,
                    Unit__r.Customers__c,
                    Booking_Date__c,
                    Sales_Managers__r.ManagerId,
                    Unit__r.Tower__r.Name,
                    Unit__r.Tower__r.Project__r.Name,
                    (SELECT Name, Email_Address__c FROM ApplicantDetails__r 
                     WHERE Applicant_Number__c != 'Primary Applicant') 
                    FROM Booking__c
                    LIMIT 50000];
        }
        else if(bookingNames==NULL){
            return  [SELECT  ID,
                     STATUS__C,
                     Opportunity__c,
                     Opportunity__r.StageName,
                     Opportunity__r.Unit__c,
                     Unit__r.Booking__c,
                     Name,
                     Unit__r.Unit_Status__c,
                     Signed_Status__c,
                     Unit__c,
                     Tower__c,
                     Project__c,
                     Primary_Applicant_Name__c,
                     OwnerId,
                     Primary_Applicant_Email__c,
                     Sales_Head__c,
                     Sales_Head__r.ManagerId,
                     Sales_Head__r.Manager.Email,
                     Secondary_Sales_Manager_VP__r.email,
                     Secondary_Sales_Manager_VP__c,
                     Sales_Head__r.Email,
                     Unit__r.Name,
                     Project__r.Name,
                     Sales_Managers__r.Email,
                     Secondary_Sales_Manager__r.Email,
                     Unit__r.Customers__c,
                     Booking_Date__c,
                     Sales_Managers__r.ManagerId,
                     Unit__r.Tower__r.Name,
                     Unit__r.Tower__r.Project__r.Name,
                     (SELECT Name, Email_Address__c FROM ApplicantDetails__r 
                      WHERE Applicant_Number__c != 'Primary Applicant') 
                     FROM Booking__c 
                     
                     WHERE Status__c = 'UnProcessed'  
                     AND DS_Intimation_Date__c = NULL
                     AND (
                         //-- Condition for non Siniya projects 
                         (unit__r.Tower__r.name != :excemptionTowerName 
                          AND unit__r.Tower__r.Project__r.Name != 'Sobha Siniya Island' 
                          AND DAY_ONLY(Booking_Date__c) = :sobhaConsideredDate 
                          AND DAY_ONLY(Booking_Date__c) >= :sobhaMyDateTime)
                         OR 
                         //-- Condition for Siniya projects
                         (unit__r.Tower__r.Project__r.Name = 'Sobha Siniya Island' 
                          AND DAY_ONLY(Booking_Date__c) = :siniyaConsideredDate 
                          AND DAY_ONLY(Booking_Date__c) >= :siniyaMyDateTime)
                         OR
                         //-- Condition for exemption tower 
                         (unit__r.Tower__r.name = :excemptionTowerName 
                          AND DAY_ONLY(Booking_Date__c) = :consider2days 
                          AND ( DAY_ONLY(Booking_Date__c) >= :sobhaMyDateTime OR DAY_ONLY(Booking_Date__c) >= :siniyaMyDateTime))
                     )
                     AND (Signed_Status__c = null OR Signed_Status__c = '')
                     LIMIT 50000];
        } else
        { 
            return  [SELECT  ID,
                STATUS__C,
                Opportunity__c,
                Opportunity__r.StageName,
                Opportunity__r.Unit__c,
                Unit__r.Booking__c,
                Name,
                Unit__r.Unit_Status__c,
                Signed_Status__c,
                Unit__c,
                Tower__c,
                Project__c,
                Primary_Applicant_Name__c,
                OwnerId,
                Primary_Applicant_Email__c,
                Sales_Head__c,
                Secondary_Sales_Manager_VP__c,
                Sales_Head__r.ManagerId,
                Sales_Head__r.Manager.Email,
				Secondary_Sales_Manager_VP__r.Email,
                Sales_Head__r.Email,
                Unit__r.Name,
                Project__r.Name,
                Sales_Managers__r.Email,
                Secondary_Sales_Manager__r.Email,
                Unit__r.Customers__c,
                Booking_Date__c,
                Sales_Managers__r.ManagerId,
                Unit__r.Tower__r.Name,
                Unit__r.Tower__r.Project__r.Name,
                    (SELECT Name, Email_Address__c FROM ApplicantDetails__r 
                     WHERE Applicant_Number__c != 'Primary Applicant') 
        		FROM Booking__c 
                WHERE Status__c = 'UnProcessed'  
                AND DS_Intimation_Date__c =NULL
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
    
    public static List<String> validateEmail(List<String> emails){
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        List<String>  validatedEmails = new List<String>();
        
        for(String toEmail : emails){
                        Matcher MyMatcher = MyPattern.matcher(toEmail);
                        if(!MyMatcher.matches()){
                            invalidEmails.add(toEmail);
                        }else{
                            validatedEmails.add(toEmail);
                        }
                    }
        for(String em : emails){
            Matcher MyMatcher = MyPattern.matcher(em);
            if(MyMatcher.matches()){ validatedEmails.add(em);}
            
        }
        return validatedEmails;
        
    }
    
}