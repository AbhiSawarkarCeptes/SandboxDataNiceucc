public class FinalTerminationNoticeController {
    @InvocableMethod
    public static void sendAttachNotice(List<Booking__c> booking){
        Booking__c b = [SELECT ID,Primary_Applicant_Name__c,unit__r.Name,Booking_Date__c,Primary_Applicant_Address__c,Purchase_Price_Only__c,
                        Name,Milestone_Due_Till_Date__c, Total_On_Account_Money_With_Registration__c,Project_Name__c,OwnerId,SPA_Executed_Date__c,
                        Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Primary_Name__c,unit__c,Opportunity__r.Primary_Email__c,
                        Unit__r.Legal_Entity__r.Name, Opportunity__r.Other_Applicants_Email__c
                        FROM Booking__c
                        WHERE Id =: booking[0].id];
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();  
        List<Id> ContentDocumentids = new List<Id>();
        for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid = :booking[0].id]){
            ContentDocumentids.add(CDLink.ContentDocumentid); 
        }       
        for(ContentVersion cversion : [SELECT title, PathOnClient, FileType, versiondata
                                       FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids AND title LIKE 'Final Notice Signed%']){
                                           blob WOCFbody = cversion.versiondata;
                                           Messaging.Emailfileattachment attach2 = new Messaging.Emailfileattachment();
                                           attach2.setFileName('Final Notice Signed.pdf');
                                           attach2.setBody(WOCFbody);                          
                                           fileAttachments.add(attach2);                     
                                       }                                    
        
        ///// Email              
        String projname='';
        if(b.Unit__r.Legal_Entity__r.Name != '' && b.Unit__r.Legal_Entity__r.Name != null){
            projname = 'in Project' + b.Unit__r.Legal_Entity__r.Name;
        }         
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
        email.setSubject('Land Department Termination Notification: '+'Unit No. ' + b.Unit__r.Name + projname );
        list<string> lststringtoaddress = new list<string>();
        list<string> lststringccaddress = new list<string>();
        String otherApplicants = '';
        String otherEmails = '';
        
        otherEmails = b.opportunity__r.Other_Applicants_Email__c;
        List<String> emailList = new List<String>(); 
        if(b.Opportunity__r.Primary_Email__c!=null && b.Opportunity__r.Primary_Email__c !=''){
            lststringtoaddress.add(b.Opportunity__r.Primary_Email__c);
        }
        if(otherEmails != null && otherEmails != ''){
            emailList = otherEmails.split(',');
        }
        List<string> otherEmailsList = new List<String>();
        if(emailList.size()>0){
            for(String s : emailList){
                if(s.contains('@')){
                    otherEmailsList.add(s);
                    lststringtoaddress.add(s);
                    
                }
            }
        }
        if(b.Opportunity__r.Other_Applicants_Name__c != null){
            otherApplicants = '&'+b.Opportunity__r.Other_Applicants_Name__c;        
        }
        
        String body =  'Dear ' + b.Opportunity__r.Primary_Name__c +' '+otherApplicants+',<br/><br/>' + 
            
            '<b>Greetings,</b><br/><br/>'+
            
            'This is with regards to the unit that you have contracted to purchase in Sobha Hartland.' +'<br/><br/>' +
            'Please find attached the final notice to pay the due amounts. '+
            'Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be cancelled and the paid amount to be forfeited.'+'<br/><br/>' +
            
            'Request you to kindly go through the attached notice, the mentioned amount is for DLD purposes only. '+ 
            'The actual payable amount includes the interest charges as per the last installment notice sent, should you require any additional details please feel free to contact us.'+'<br/><br/>' +
            'Best Regards,<br/>'+
            'CRM | Sobha LLC';
        
        lststringccaddress.add(System.label.SobhaHelpdesk); 
        email.setToAddresses(lststringtoaddress);
        email.setCCAddresses(lststringccaddress);
        email.setHtmlBody(body);
        email.setFileAttachments(fileAttachments);                  
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});           
        
    }
    
    
}