//Test Class : UnitAutoCancelIntimateCustBatchTest
/* Notification to customer 1 day before canceling the Booking*/

global class UnitAutoCancelIntimateCustBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static List<String> paymentStatusList = new List <String>{'Pending for Accounts Approval','Approved by Accounts','Pending for Sales Ops Approval','Resubmitted to SM/SD','Approved by Sales Ops','Submitted to Accounts for Amount Confirmation','Amount Confirmed by Accounts','Approved','Payment Link sent to Customer','Partially Approved','PR was Approved- Booking is cancelled'};
        public  string bookingListCSV = ''; 
     private List<Id> recordIds=NULL;
    public UnitAutoCancelIntimateCustBatch(List<Id> recordIds ) {
        this.recordIds = recordIds;
    }
    public UnitAutoCancelIntimateCustBatch() {
        
    }
    OrgWideEmailAddress[] noReplyAddress = [select Id from OrgWideEmailAddress where Address = 'noreply@sobharealty.com'];
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        
        Integer less1DayCancellationSpan = Integer.ValueOf(System.Label.UnitAutoCancellationDays) - 1;
        Date bookingDate = System.Today().addDays(-less1DayCancellationSpan);
        String bookingStatusCheck = '(Status__c=\'Processed\' OR Status__c=\'UnProcessed\' OR Status__c=\'Booking In Process\')';
        String unitStatusCheck = 'Unit__r.Unit_Status__c !=\'Sold\' ';
        String unitExceptionCheck = '(Unit__r.No_cancellation_CSO_Approval__c = false AND Unit__r.File_Note__c = false AND Unit__r.Roadshow_Booking__c = false)';
        String bookingDateCheck = 'Booking_Date__c >  2023-01-01T01:02:03Z AND DAY_ONLY(Booking_Date__c) = :bookingDate ' ;
        String walkInSourceCheck = '(Opportunity__r.Walk_in_Source__c != \'Employee\'  AND Opportunity__r.Walk_in_Source__c != \'Management Reference\' )';
        String receiptMode = System.Label.UnitAutoCancellationRecMode;
        String receiptStatus = System.Label.UnitAutoCancellationRecStatus;
        String receiptDebAccount = System.Label.UnitAutoCancellationRecDebAccount;
        String receiptQuery = '(select Id,Total_Amount__c from Receipts__r where Mode__c=' + receiptMode +
            ' AND  Receipt_Status__c =' + receiptStatus + ' AND Debit_Account__c =' + receiptDebAccount + ')';
        String paidPercentValue = System.Label.UnitAutoCancellationPaidPer;
        String paidPercent = '(Paid_Percentage__c<' + paidPercentValue +')';
        String query = 'Select Id,Agreement_Value__c,Opportunity__c,Name,Unit__c,Unit__r.Customers__c,';
        query +='(SELECT Id,Status__c,Amount__c,Mode__c,Currency__c FROM Payment_Requests__r WHERE Status__c IN :paymentStatusList )';
        query +=',(select Id,Total_Amount__c from Receipts__r where Mode__c=\'Credit Note\' AND Receipt_Status__c   = \'Cleared\' AND Debit_Account__c  =\'a182o00001KVlXqAAL\')';
        query += '   FROM Booking__c WHERE ' + paidPercent + ' AND Cancellation_Intimation_Sent__c = false ';
        query +='AND' + bookingStatusCheck  ;
        query += '  AND ' + unitStatusCheck + ' AND '+ unitExceptionCheck + ' AND ' + walkInSourceCheck + ' AND ' + bookingDateCheck ; 
        if (recordIds != null && !recordIds.isEmpty()) {
            query += ' AND Id IN :recordIds';
        }
        
        if(!test.isRunningTest()){
            system.debug('query-->'+query);
            system.debug('Actualquery2-->'+Database.query(query));
            return Database.getQueryLocator(query);  
        }
        else{
            return Database.getQueryLocator('Select Id,Agreement_Value__c,Name,Unit__c,Opportunity__c,Unit__r.Customers__c,'+
                                            '(SELECT Id,Status__c,Amount__c,Mode__c,Currency__c FROM Payment_Requests__r) FROM Booking__c LIMIT 1');    
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> scope) {
        system.debug('scope:'+scope);
        Map<String, String> bookingToUnitIdMap = new  Map<String, String>();
        List<Unit__c> unitsToUpdate = new List<Unit__c>();
        Map<String, String> bookingToOppIdMap = new  Map<String, String>();
        List<Opportunity> customersToUpdate = new List<Opportunity>();
        String noReplyEmail = '';
        
        if ( noReplyAddress.size() > 0 ) {
            noReplyEmail = noReplyAddress.get(0).Id;
        }
        
        system.debug('scope---->'+scope);
        String bookingName = '' ;
        Map<Id,Decimal> bookingPRAmountMap = new Map<Id,Decimal> ();
        Map<Id,Decimal> bookingAgreementValueMap = new Map<Id,Decimal>();
        Map<Id,String> bookingNameMap = new Map<Id,String>();
        
        try {
            Set<Id> opportunityIds = new set<Id>();
            List<Booking__c> bookingList = new List<Booking__c>();
            for(Booking__c obj : scope){
                if(obj.Unit__c !=NULL)
                    bookingToUnitIdMap.put(obj.Id,obj.Unit__c);
                if(obj.Unit__r.Customers__c != NULL)
                    bookingToOppIdMap.put(obj.Id, obj.Unit__r.Customers__c);
                
                system.debug('scope1---->');
                bookingAgreementValueMap.put(obj.Id,obj.Agreement_Value__c);
                bookingNameMap.put(obj.Id,obj.Name);
                
                opportunityIds.add(obj.Opportunity__c);
                Decimal totalAmountOfPR = 0;
                Decimal totalCreditNote = 0;
                /* Booking Level PR SUM Calculation */
                if(obj.Payment_Requests__r.size() > 0){
                    system.debug('scope2---->');
                    for(Payment_Request__c pr : obj.Payment_Requests__r){
                        //if(pr.Status__c.startsWith('Approved') || pr.Status__c.startsWith('Submitted')){
                        
                        if(paymentStatusList.contains(pr.Status__c)){
                            if(pr.Mode__c == 'International Wire Transfer' && pr.Status__c !='Approved'){
                                
                                totalAmountOfPR += getConvertedAmount(pr.Amount__c, pr.Currency__c);
                            }
                            else {
                                totalAmountOfPR += pr.Amount__c;
                            }
                            
                        }
                    }
                    
                }
                /* Booking Level Credit Note SUM Calculation */
                if(obj.Receipts__r.size() > 0){
                    system.debug('Reciepts---->');
                    
                    
                    for(Receipt__c rec : obj.Receipts__r){
                        totalCreditNote += rec.Total_Amount__c;
                    }
                }
                system.debug('totalCreditNote'+totalCreditNote);
                if(obj.Payment_Requests__r.size() > 0 || obj.Receipts__r.size() > 0 )
                {
                    bookingPRAmountMap.put(obj.Id,totalAmountOfPR+totalCreditNote); /* Map Will track the booking & respective PR SUMs and Receipts(Credit notes) here */
                    system.debug('scope3---->'+bookingPRAmountMap);
                }                   
                
            }
            system.debug('bookingToUnitIdMap:'+bookingToUnitIdMap);
            /* NSA Level PR SUM Calculation */
            List<unit_hold_request__c> NSAList = [SELECT Id, Opportunity__r.Booking__c,
                                                  Opportunity__r.Booking__r.Agreement_Value__c,
                                                  Payment_Request__r.Status__c,
                                                  Payment_Request__r.Mode__c,
                                                  Payment_Request__r.Currency__c,
                                                  Payment_Request__r.amount__c ,
                                                  Payment_Request__r.Payment_Request__r.Status__c,
                                                  Payment_Request__r.Payment_Request__r.Mode__c,
                                                  Payment_Request__r.Payment_Request__r.Currency__c,
                                                  Payment_Request__r.Payment_Request__r.amount__c ,
                                                  Opportunity__r.Booking__r.Name
                                                  FROM unit_hold_request__c WHERE Opportunity__c IN :opportunityIds 
                                                  AND Booking__c !=NULL
                                                 ];
            Map<unit_hold_request__c,Decimal> bookingIdandPaymentRequestMap  = new Map<unit_hold_request__c,Decimal>();
            decimal unitLevelPRSum = 0;
            for(unit_hold_request__c obj: NSAList){
                system.debug('scope4---->');
                
                String bookingId = obj.Opportunity__r.Booking__c;
                String nsaBookingName = obj.Opportunity__r.Booking__r.Name;
                bookingNameMap.put(bookingId,nsaBookingName);
                
                if(obj.Payment_Request__c != null && obj.Payment_Request__r.Payment_Request__c != null){
                    if(paymentStatusList.contains(obj.Payment_Request__r.Status__c) &&  obj.Payment_Request__r.Amount__c != null){
                        if(obj.Payment_Request__r.Mode__c == 'International Wire Transfer' && obj.Payment_Request__r.Status__c !='Approved'){
                            unitLevelPRSum += getConvertedAmount(obj.Payment_Request__r.Amount__c,obj.Payment_Request__r.Currency__c);
                            
                        }
                        else{
                            unitLevelPRSum += obj.Payment_Request__r.Amount__c;
                        }
                        
                    }
                    if(paymentStatusList.contains(obj.Payment_Request__r.Payment_Request__r.Status__c) && obj.Payment_Request__r.Payment_Request__r.amount__c != null){
                        if(obj.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' && obj.Payment_Request__r.Payment_Request__r.Status__c !='Approved'){
                            unitLevelPRSum += getConvertedAmount(obj.Payment_Request__r.Payment_Request__r.Amount__c,obj.Payment_Request__r.Payment_Request__r.Currency__c);
                        }else{
                            unitLevelPRSum += obj.Payment_Request__r.Payment_Request__r.Amount__c;
                        }
                    }
                }
                else if(obj.Payment_Request__c != null && obj.Payment_Request__r.Amount__c != null){
                    if(paymentStatusList.contains(obj.Payment_Request__r.Status__c)) {
                        if(obj.Payment_Request__r.Mode__c == 'International Wire Transfer' && obj.Payment_Request__r.Status__c !='Approved'){
                            unitLevelPRSum =  getConvertedAmount(obj.Payment_Request__r.Amount__c,obj.Payment_Request__r.Currency__c); 
                        }
                        else{
                            unitLevelPRSum = obj.Payment_Request__r.Amount__c;
                        }                        
                        
                    }
                }
                if(bookingPRAmountMap.containsKey(bookingId)) {
                    bookingPRAmountMap.put(bookingId, bookingPRAmountMap.get(bookingId) + unitLevelPRSum); /* Map Will track the SUM of booking/unit level PRs here */
                }
                else {
                    bookingPRAmountMap.put(bookingId, unitLevelPRSum);
                }
            }
            system.debug('scope4---->'+bookingPRAmountMap);
            
            if(!bookingPRAmountMap.isEmpty()){
                system.debug('scope5---->');
                
                for(Id bookingID : bookingPRAmountMap.keySet()){
                    system.debug('scope6---->');
                    
                    Decimal aggregatePRSum = bookingPRAmountMap.get(bookingId);
                    Decimal agreementValue = bookingAgreementValueMap.get(bookingId);
                    Decimal prAllocationPercent = 0;
                    system.debug('aggregatePRSum:'+aggregatePRSum);
                    system.debug('agreementValue:'+agreementValue);
                    if(agreementValue!=NULL && aggregatePRSum !=NULL)
                        prAllocationPercent = (aggregatePRSum * 100) / agreementValue; 
                    system.debug('scope8---->'+prAllocationPercent);
                    
                    if(prAllocationPercent < Decimal.ValueOf(System.label.UnitAutoCancellationLimit)){ 
                        system.debug('scope7---->'+prAllocationPercent);
                        
                        Booking__c b = new Booking__c();
                        
                        b.Id = bookingID;
                        b.Cancellation_Intimation_Sent__c = true;
                        
                        if(b.Id !=NULL)
                            bookingList.add(b);
                        
                        bookingName += bookingNameMap.get(bookingId);
                        bookingName +='('+ bookingPRAmountMap.get(bookingId)+')'; //Additional line for testing. to be commented for actual working deployment 
                      
                        
                    }   
                }
                
            }
            if(!bookingList.isEmpty()){
                bookingListCSV += bookingName +',  '; 
                System.debug('bookingList-->'+bookingList);
                Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
                
                if(!bypassSettingInstance.ByPass_Auto_Cancellation_Intimation__c){
                    
                   if(!bookingList.isempty())
                        sendEmailToIntimateCancellation(bookingList,noReplyEmail);
                    Database.update(bookingList); 
                }
                
            }
        }
        catch (Exception e) {
            Error_Log__c trackRec = new Error_Log__c(Class__c = 'UnitAutoCancelIntimateCustBatch -- Error',Message__c = bookingName + '  '+ e.getmessage());
            database.insert(trackRec, false);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        Error_Log__c trackRec = new Error_Log__c();
        trackRec.Class__c = 'UnitAutoCancelIntimateCustBatch -- Success';
        trackRec.Message__c = bookingListCSV ;
        Database.insert(trackRec, false);
    }
    
    //method to convert the amount based on the currency selected
    public static Decimal getConvertedAmount(Decimal amount, String CurrencyForConversion) {
        // Fetch the custom metadata for the given currency
        Currency_Rate__mdt currencyRate = Currency_Rate__mdt.getInstance(CurrencyForConversion);
        
        if (currencyRate != null) {
            // Perform the conversion
            Decimal convertedAmount = amount * currencyRate.Rate__c;
            return convertedAmount;
        } else {
            return amount;
            
        }
    }
    
    
    
    
    public static void sendEmailToIntimateCancellation(List<Booking__c> bookingList,String noReplyEmail){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
        List<Booking__c> bookingToProcess = [SELECT Id, 
                                             Sales_Managers__r.managerid, 
                                             Unit__c,
                                             Unit__r.Name,
                                             Tower__c,
                                             Opportunity__c, 
                                             Project__r.Name,
                                             Primary_Applicant_Name__c,
                                             Primary_Applicant_Email__c,
                                             Paid_Percentage__c,
                                             Agreement_Value__c ,
                                             Sales_Head__r.ManagerId,
                                             Sales_Head__r.Manager.Email,
                                             Secondary_Sales_Head__r.ManagerId,
                                             Secondary_Sales_Head__r.Manager.Email,
                                             Secondary_Sales_Manager_VP__r.email,
                                             Sales_Head__r.email,
                                             Sales_Managers__r.email,
                                             Secondary_Sales_Manager__r.email,
                                             Secondary_Sales_Manager_VP__r.ManagerId,
                                             Secondary_Sales_Head_VP2__r.ManagerId,  
                                             Secondary_Sales_Manager_VP__r.Manager.Email,
                                             Secondary_Sales_Head_VP2__r.Manager.Email,  
                                             unit__r.Customers__c,
                                             Booking_Date__c,
                                             Secondary_Sales_Head__r.email,
                                             unit__r.Tower__r.name,
                                             ownerID
                                             FROM Booking__c 
                                             WHERE ID IN :bookingList];
        for(Booking__c booking: bookingToProcess)
        {
            for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                if(!mapOfBookingToAddress.containsKey(booking.id)){
                    mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                }else{
                    mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                }
            }
        }
        
        Map<Id, String> bookingIdtoEmailAddressMap = new Map<Id, String>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where developername = 'Unit_Auto_Cancellation_15_Days_Intimation'];
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        // List<String> invalidEmails = new List<String>();
        user u = [select id,lastname,email,Manager.email,Manager.Manager.email from User where Id =: bookingToProcess[0].OwnerId];
        Contact dummyContact = new Contact(LastName = u.lastName, Email = u.Email);
        insert dummyContact;
        for(Booking__c booking1 : bookingToProcess){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            if(noReplyEmail != '') {
                email.setOrgWideEmailAddressId(noReplyEmail);
            }
            List <String> lststringtoaddress = new List<String>();
            List <String> lstStringccaddress = new List <String>();
            
            String emailAddressFromBooking = mapOfBookingToAddress.get(booking1.id);
            if(!string.isBlank(emailAddressFromBooking)){ lststringtoaddress.addAll(emailAddressFromBooking.split(',')); }
            
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
            
            if(booking1.Secondary_Sales_Manager_VP__c!=null && booking1.Secondary_Sales_Manager_VP__r.ManagerId != null){ lstStringccaddress.add(booking1.Secondary_Sales_Manager_VP__r.Manager.Email); }
            if(booking1.Secondary_Sales_Head_VP2__c!=null && booking1.Secondary_Sales_Head_VP2__r.ManagerId != null){ lstStringccaddress.add(booking1.Secondary_Sales_Head_VP2__r.Manager.Email); }
            
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
            lstStringccaddress.add(System.label.SobhaHelpdesk);
            lstStringccaddress.add(System.label.SF_Notifications);
           
                    System.debug('lststringtoaddress:'+lststringtoaddress);
            List<String> toAddressEmails = validateEmail(lststringtoaddress);
            
            System.debug('lstStringccaddress:'+lstStringccaddress);
            List<String> ccAddressEmails = validateEmail(lstStringccaddress);
            
            
            email.setToAddresses(toAddressEmails);
            email.setccAddresses(ccAddressEmails);
            email.setTemplateID(emailTemplate.Id); 
            email.setWhatId(booking1.Id);
            email.setTargetObjectId(dummyContact.Id);
            email.setTreatTargetObjectAsRecipient(false);
            email.setsaveAsActivity(false);
            emails.add(email);
            //system.debug('bookingIdtoEmailMap:'+bookingIdtoEmailMap.values());
            system.debug('i am afteremail  creation'+email);
        }
        
        //Messaging.sendEmail(bookingIdtoEmailMap.values());
        Messaging.sendEmail(emails);
        
        system.debug('afteremail  sent');
        delete dummyContact;
        
    }
    
    public static List<String> validateEmail(List<String> emails){
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        List<String>  validatedEmails = new List<String>();
        for(String e : emails){
            Matcher MyMatcher = MyPattern.matcher(e);
            if(MyMatcher.matches()){ validatedEmails.add(e);}
            
        }
        return validatedEmails;
        
    }
    
}