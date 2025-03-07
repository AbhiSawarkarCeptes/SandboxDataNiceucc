public class ApplicantEmailsToBookingBatch implements Database.Batchable<sObject>,Database.stateful {
    public Integer successRec = 0; 
    public Integer failedRec = 0; 
    public Integer totalRec = 0;
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,Email_Address__c, Booking__c,Applicant_Number__c from Applicant_Details__c  where Booking__r.Status__c !=\'Cancelled\' and  booking__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Applicant_Details__c> applicationList){
        Map<Id,Booking__c> bookingMapToUpdate = new Map<Id,Booking__c>();
        for(Applicant_Details__c appl : applicationList) {
            Booking__c book = bookingMapToUpdate.containsKey(appl.Booking__c) ? bookingMapToUpdate.get(appl.Booking__c) : new Booking__c();
            String emailAddress = appl.Email_Address__c;
            book.Id = appl.booking__c;
            switch on appl.Applicant_Number__c {
                when 'Fifth Applicant' {		
                   book.EmailAddress__c = emailAddress;
                }	
                when 'Fourth Applicant' {		
                    book.Email_Address_4__c = emailAddress;
                }
                when 'Third Applicant' {		
                    book.Email_Address_3__c = emailAddress;
                }
                when 'Second Applicant' {
                   book.Email_Address_2__c = emailAddress; 
                }
                when else {		  
                    book.Primary_Applicant_Email__c = emailAddress;
                }
            } 
            bookingMapToUpdate.put(book.Id,book);
           
        }
        totalRec += bookingMapToUpdate.keySet().size();
         List<Database.SaveResult> results = Database.update(bookingMapToUpdate.values(), false);
            for (Database.SaveResult result : results) {
                if (result.isSuccess()){
                    successRec++;
                }else{
                    failedRec++;
                }
            }
       
    }
    
    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                          from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email, System.label.AbdulRahmanEmail,System.label.BhavishyaMuradiaEmail,System.label.LeemaDhalEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('ApplicantEmailsToBookingBatch' + a.Status);
        mail.setPlainTextBody('records processed ' + totalRec +   ' with '+ failedRec + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}