/*
 Created By : Anil Bhati
 Creaded date : 16 Aug 2023
 Description :  Account Expiry information mail to account onwer.
*/
global class SendAccountExpiryMailSchBatch implements Schedulable {
	
    global void execute(SchedulableContext sc){
        sendMail();
    }
    
    public void sendMail(){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> ();
        	Date expiryAfter_15_days = Date.Today().addDays(15);
        	Date expiryAfter_30_days = Date.Today().addDays(30);
        	Id recordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        List<Account> accList = [Select id, Name, Owner.name, Owner.Email, Expiry_Date__c from Account where RecordTypeID =: recordTypeId and (Expiry_Date__c =: expiryAfter_15_days or Expiry_Date__c =: expiryAfter_30_days) ];
        
        for(Account acc : accList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String [] toAddress = new String[]{acc.Owner.Email};
            String expiryDate = (acc.Expiry_Date__c).day() + '-' + (acc.Expiry_Date__c).month() + '-' + (acc.Expiry_Date__c).year();
            email.setToAddresses(toAddress);
            
            email.setSubject('Account contract Expiry notification');
   
            email.setHtmlBody('Hello ' + acc.Owner.Name + 
                              ', <br/> <br/> This is to inform you that your Broker Account\'s <b>"' + acc.Name + 
                              '"</b> Contract is going to expire on <b>' + expiryDate + 
                              '</b>. <br/> Request you to please take the needful actions. <br/> <br/> Account link - '+
                              URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id + '<br/> <br/>Thank you !! <br/><br/> Sobha Reality ');
            
            emails.add(email);
        }
        try{
            if(emails.size()>0 && emails != null)
            {
            Messaging.sendEmail(emails, false);
            }
        }
        catch(Exception e){
            System.debug('Mail send execption' + e.getMessage());
        }
        
    }
}