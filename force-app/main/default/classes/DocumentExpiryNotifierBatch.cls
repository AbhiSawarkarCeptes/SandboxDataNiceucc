global class DocumentExpiryNotifierBatch implements Database.Batchable<sObject>, Database.Stateful {
    public static List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>  ();
    public  Set<String> applicationEmailAddressSet = new Set<String> ();
    public static Integer cancellationSpan = Integer.ValueOf(System.Label.DocumentExpiryDays);
    public static List<String> bookingStatusList = new List <String>{'Processed','UnProcessed','Booking In Process'};
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        Date date15DayAgo = system.today().addDays(cancellationSpan);
        string documentExpiryCheck = '( Valid_Until_Passport__c <=:date15DayAgo OR Visa_Copy_Valid_Upto__c <=:date15DayAgo OR Valid_Upto_National_ID__c <=:date15DayAgo OR Non_residency_Letter_Valid_Upto__c <=:date15DayAgo';
        documentExpiryCheck += ' OR Others_Valid_Upto__c <=:date15DayAgo OR Valid_Upto_Emirates_Id__c <=:date15DayAgo)';
        String applicantTypeCheck = ' AND Applicant_Number__c=\'Primary Applicant\'  AND Booking__r.Status__c IN :bookingStatusList AND Booking__r.SPA_Executed__c != \'SPA Executed\' ';
        
        String query = 'Select Id,Name,Booking__r.Name,Unit__r.Name,Valid_Until_Passport__c,Booking__r.Sales_Managers__r.Email,Booking__r.Sales_Head__r.Email,';
        query +='Booking__r.Secondary_Sales_Manager__r.Email,Booking__r.Secondary_Sales_Head__r.Email,Booking__r.Secondary_Sales_Manager_VP__r.Email,';
        query +='Booking__r.Secondary_Sales_Head_VP2__r.Email,Booking__r.Primary_SVP__r.Email,Booking__r.Secondary_SVP__r.Email,Email_Address__c,Visa_Copy_Valid_Upto__c,Valid_Upto_National_ID__c,';
        query +='Non_residency_Letter_Valid_Upto__c,Others_Valid_Upto__c,Valid_Upto_Emirates_Id__c FROM Applicant_Details__c WHERE ';
        return Database.getQueryLocator(query + documentExpiryCheck + applicantTypeCheck);
    } 
    global void execute(Database.BatchableContext BC, List<Applicant_Details__c> appDetail) {
        try{
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@sobharealty.com'];
            String strEmail = '';
            EmailTemplate em = [SELECT Id,HTMLValue FROM EmailTemplate WHERE DeveloperName = 'EmailNotificationDocumentExpiryTemplate']; 
            strEmail = em.HTMLValue;
            List <String> ccAddresses = new List <String>();
            String DocumentExpiryNotifier = System.Label.DocumentExpiryNotifier;
            if(!string.isblank(DocumentExpiryNotifier)){ 
                for(String s : DocumentExpiryNotifier.split(',')){
                    if(!s.containsIgnoreCase('null')){
                        ccAddresses.add(s);
                    }
                }
            }
            String applicationDetail = '' ;
            for(Applicant_Details__c app : appDetail){
                String EmailBody = fetchExpiredDocuments(app);
                if(String.IsNotBlank(EmailBody)){
                    if(!applicationEmailAddressSet.contains(app.Email_Address__c)){
                         system.debug('mailList'+app.Id+EmailBody);
                        strEmail = strEmail.replace('{!ListofRequiredDocuments}',EmailBody);
                        strEmail = strEmail.replace('{!Customer}',app.Name);
                        strEmail = strEmail.replace('{!bookingId}',app.Booking__c != null ? app.Booking__r.Name : '');
                        strEmail = strEmail.replace('{!unitId}',app.Unit__c != null ? app.Unit__r.Name : '');
                        ccAddresses.addall(fetchCCAddress(app));
                        Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[] {app.Email_Address__c};
                            newMail.setToAddresses(toAddresses);
                        newMail.setSubject('KYC Documents Verification');
                        newMail.setOrgWideEmailAddressId(owea.get(0).Id);
                        newMail.setHtmlBody(strEmail);
                        newMail.setCcAddresses(ccAddresses);
                        mailList.add(newMail);
                        applicationEmailAddressSet.add(app.Email_Address__c);
                        applicationDetail += app.Id +' = '+ EmailBody +';';
                    }
                }
            }
             
            if(mailList.size () > 0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                error_log__c er = new error_log__c(Class__c = 'Success : DocumentExpiryNotifierBatch', Message__c = applicationDetail ); 
                Insert er;
            }
        }
        catch(exception e){
            system.debug('e.getmessage()'+e.getmessage() + e.getLinenumber());
            error_log__c er = new error_log__c(Class__c = 'DocumentExpiryNotifierBatch', Message__c = e.getmessage() +'  ' +e.getLinenumber() ); 
            Insert er;
        }
    }
    global void finish(Database.BatchableContext BC) {
        
        
        
        
    }
    public static String fetchExpiredDocuments(Applicant_Details__c app){
        String expiredDocsCsv = '';
        Date date15DayAgo = system.today().addDays(cancellationSpan);
        system.debug('date15DayAgo'+date15DayAgo);
        expiredDocsCsv += app.Valid_Until_Passport__c != null &&  app.Valid_Until_Passport__c.daysBetween(system.today())!=0 &&
            app.Valid_Until_Passport__c <= date15DayAgo && 
            math.mod(app.Valid_Until_Passport__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('Passport Copy - Expiry Date ', app.Valid_Until_Passport__c) : '';
        
        expiredDocsCsv += app.Visa_Copy_Valid_Upto__c != null && app.Visa_Copy_Valid_Upto__c.daysBetween(system.today())!=0 &&
            app.Visa_Copy_Valid_Upto__c <= date15DayAgo && 
            math.mod(app.Visa_Copy_Valid_Upto__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('Visa Copy - Expiry Date ', app.Visa_Copy_Valid_Upto__c) : '';
        
        expiredDocsCsv += app.Valid_Upto_National_ID__c != null &&  app.Valid_Upto_National_ID__c.daysBetween(system.today())!=0 &&
            app.Valid_Upto_National_ID__c <= date15DayAgo && 
            math.mod(app.Valid_Upto_National_ID__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('National ID - Expiry Date ', app.Valid_Upto_National_ID__c) : '';
        
        expiredDocsCsv += app.Non_residency_Letter_Valid_Upto__c != null &&  app.Non_residency_Letter_Valid_Upto__c.daysBetween(system.today())!=0 &&
            app.Non_residency_Letter_Valid_Upto__c <= date15DayAgo && 
            math.mod(app.Non_residency_Letter_Valid_Upto__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('Non-residency Letter - Expiry Date ', app.Non_residency_Letter_Valid_Upto__c) : '';
        
        expiredDocsCsv += app.Others_Valid_Upto__c != null &&  app.Others_Valid_Upto__c.daysBetween(system.today())!=0 &&
            app.Others_Valid_Upto__c <= date15DayAgo && 
            math.mod(app.Others_Valid_Upto__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('Others Valid - Expiry Date ', app.Others_Valid_Upto__c): '' ;
        
        expiredDocsCsv += app.Valid_Upto_Emirates_Id__c != null &&  app.Valid_Upto_Emirates_Id__c.daysBetween(system.today())!=0 &&
            app.Valid_Upto_Emirates_Id__c <= date15DayAgo && 
            math.mod(app.Valid_Upto_Emirates_Id__c.daysBetween(System.Today()), 15) == 0 ? checkIfExpired('Emirates Id - Expiry Date ', app.Valid_Upto_Emirates_Id__c) : '';
        
        return expiredDocsCsv;
        
    }
    
    public static String checkIfExpired(String docName,Date expireDate){
        String docStatus = '';
        return docStatus += docName + ' : ' + String.valueOf(expireDate).removeEnd(' 00:00:00') + '<br/>';
    }
    public static List <String> fetchCCAddress (Applicant_Details__c app){
        List <String> ccAddresses = new List<String>();
        Set <String> ccAddressesNew = new set <String>{app.Booking__r.Sales_Head__r.Email,app.Booking__r.Sales_Managers__r.Email,app.Booking__r.Secondary_Sales_Manager__r.Email,app.Booking__r.Secondary_Sales_Head__r.Email,
            app.Booking__r.Secondary_Sales_Manager_VP__r.Email,app.Booking__r.Secondary_Sales_Head_VP2__r.Email,app.Booking__r.Primary_SVP__r.Email,app.Booking__r.Secondary_SVP__r.Email}; 
                ccAddressesNew.remove(null);  
        for(String s : ccAddressesNew){
            ccAddresses.add(s);
        } 
        
        return  ccAddresses;
    }  
    
}