/*
 Created By : Anil Bhati
 Creaded date : 22 Aug 2023
 Description : Scheme expiry notification in Sobha Sandbox.
*/

global class SendSchemeExpiryMailSchBatch implements Schedulable {
    global void execute(SchedulableContext sc){
        sendMail();
    }
    
	public void sendMail(){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> ();
        Date expiryDate = Date.Today().addDays(3);
        List<PropStrength__Brokerage_Scheme__c> schemeList = [Select id, PropStrength__Scheme_Name__c, PropStrength__End_Date__c from PropStrength__Brokerage_Scheme__c where PropStrength__End_Date__c  =: expiryDate ];
        List<user> mailusers = [Select id, name, Email from user where Name = 'CloudSteer Admin' or Name = 'Amit Mishra CS'];
        List<String> toAddress = new List<String>();
        
        for(User u : mailusers){
            toAddress.add(u.Email);
        }
        
        for(PropStrength__Brokerage_Scheme__c scheme : schemeList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            String expDate = (scheme.PropStrength__End_Date__c).year() + '-' + (scheme.PropStrength__End_Date__c).month() + '-' + (scheme.PropStrength__End_Date__c).day();
            email.setToAddresses(toAddress);
            
            email.setSubject('Expiring Brokerage Scheme Alert');
   
            email.setHtmlBody('Hello Team, <br/> <br/> We hope this email finds you well. We wanted to bring to your attention that the brokerage scheme, <b>"' + 
                              scheme.PropStrength__Scheme_Name__c + 
                              '"</b>  will be expiring on <b>' + expDate + 
                              '</b>. <br/> <br/> To take advantage of this scheme before it expires, please click on the following link: '+
                              URL.getSalesforceBaseUrl().toExternalForm() + '/' + scheme.Id + '<br/> <br/>Thank you for your attention to this matter. <br/><br/> Best regards, <br/><br/> Sobha Reality');
            
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