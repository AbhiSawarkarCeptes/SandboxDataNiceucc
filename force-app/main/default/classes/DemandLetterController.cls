public class DemandLetterController {
    public Date todayDate{get;set;}
    public DemandLetterController() {
        todayDate = date.today().addDays(-4);
       
    }
    
    @auraEnabled
    public static String sendMailWithPDF(String recordId) {
        String response = '';
        if(!String.isBlank(recordId)) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            //List<String> ccList = new List<String>();  
            List<String> sendTo = new List<String>(); 
            Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
            List<Attachment> attList = new List<Attachment>();
            List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
            String parentIds = '';
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,PropStrength__Applicant_Email__c, Name,PropStrength__Status__c,
                                                                      PropStrength__Project__c,PropStrength__Primary_Customer__c,
                                                                      PropStrength__Project__r.Project_Registration_Date__c,
                                                                      Booking_Form_Executed__c,PropStrength__Total_Paid_Percent__c,
                                                                      PropStrength__Welcome_Letter__c,PropStrength__Welcome_Letter_Note__c
                                                                      FROM PropStrength__Application_Booking__c 
                                                                      WHERE Id =: recordId AND
                                                                      PropStrength__Total_Paid_Percent__c >= 9.50 AND
                                                                      PropStrength__Status__c =: 'Audit Approved' AND
                                                                      PropStrength__Active__c =: true AND
                                                                      Booking_Form_Executed__c =: true];
            system.debug('bookingList::'+bookingList);
            if(!bookingList.isEmpty()) {
                for(PropStrength__Application_Booking__c oneBook : bookingList) {
                    if(oneBook.PropStrength__Welcome_Letter__c == false) {
                        parentIds = oneBook.Id;
                       } else {
                           response = 'Already SEND';
                       }
                }
                if(!String.isBlank(parentIds)) {
                    attList = [SELECT Name,ParentId, Body, ContentType 
                               FROM Attachment WHERE ParentId =: parentIds AND 
                               Name =: 'Welcome Letter.pdf' ORDER BY CreatedDate DESC LIMIT 1];
                    if(!attList.isEmpty()) {
                        delete attList;
                        List<Attachment> insertList = new List<Attachment>();
                        PageReference pdf;
                        pdf =  Page.WelcomeLetter;
                        Blob b;
                        if (Test.IsRunningTest()) {
                            b =Blob.valueOf('UNIT.TEST');
                        } else{
                            b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = parentIds;
                        att.Name = 'Welcome Letter.pdf';
                        att.Body = b;
                        if(att != null) {
                            insert att;
                            if(att.Id != null) {
                                insertList.add(att);
                            }
                        }
                        for(Attachment oneAtt : insertList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    } else {
                        List<Attachment> insertList = new List<Attachment>();
                        PageReference pdf;
                        pdf =  Page.WelcomeLetter;
                        Blob b;
                        if (Test.IsRunningTest()) {
                            b =Blob.valueOf('UNIT.TEST');
                        } else{
                            b = pdf.getContent();
                        }
                        Attachment att = new Attachment();
                        att.ParentId = parentIds;
                        att.Name = 'Welcome Letter.pdf';
                        att.Body = b;
                        if(att != null) {
                            try {
                                insert att;
                                if(att.Id != null) {
                                    insertList.add(att);
                                }
                                system.debug('insertList::'+insertList);
                                for(Attachment oneAtt : insertList) {
                                    if(attachmentMap.containskey(oneAtt.ParentId)) {
                                        List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                        newPLI.add(oneAtt);
                                        attachmentMap.put(oneAtt.ParentId, newPLI);
                                    } else {
                                        attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                                    }
                                }
                            } catch(DMLException ex) {
                                System.debug('Error::'+ex.getMessage());
                            }
                        }
                    }
                }
                if(!String.isBlank(parentIds)) {
                    List<Attachment> existingList = [SELECT Name,ParentId, Body, ContentType 
                                                     FROM Attachment WHERE ParentId =: parentIds AND 
                                                     Name != 'Welcome Letter.pdf'];
                    if(!existingList.isEmpty()) {
                        for(Attachment oneAtt : existingList) {
                            if(attachmentMap.containskey(oneAtt.ParentId)) {
                                List<Attachment> newPLI = attachmentMap.get(oneAtt.ParentId);
                                newPLI.add(oneAtt);
                                attachmentMap.put(oneAtt.ParentId, newPLI);
                            } else {
                                attachmentMap.put(oneAtt.ParentId, new List<Attachment>{oneAtt});
                            }
                        }
                    }
                }
                system.debug('attachmentMap::'+attachmentMap);
                List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     FROM EmailTemplate 
                                                     WHERE DeveloperName =: 'Test_Email'];
                String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : null);
                if(!attachmentMap.isEmpty()) {
                    for(PropStrength__Application_Booking__c oneBook : bookingList) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(oneBook.PropStrength__Applicant_Email__c != null) {
                            sendTo.add(oneBook.PropStrength__Applicant_Email__c);
                        }
                        email.setToAddresses(sendTo);
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        email.setWhatId(oneBook.id);
                        email.setTargetObjectId(oneBook.PropStrength__Primary_Customer__c);
                        email.setTreatTargetObjectAsRecipient(False);
                        email.saveAsActivity = true;
                        email.setTemplateId(tempId);
                        if(attachmentMap.containskey(oneBook.Id)){
                            for(Attachment att : attachmentMap.get(oneBook.Id)) {
                                if(oneBook.PropStrength__Project__c != null && 
                                   oneBook.PropStrength__Project__r.Project_Registration_Date__c != null) {
                                       if(att.Name == 'Pre-Registration Notice.pdf') {
                                           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                           efa.setFileName('Pre-Registration Notice.pdf');
                                           efa.setBody(att.Body);
                                           efalst.add(efa);
                                       }
                                       if(att.Name == 'Sales Booking Form.pdf') {
                                           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                           efa.setFileName('Sales Booking Form.pdf');
                                           efa.setBody(att.Body);
                                           efalst.add(efa);
                                       }
                                       if(att.Name == 'Welcome Letter.pdf') {
                                           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                           efa.setFileName('Welcome Letter.pdf');
                                           efa.setBody(att.Body);
                                           efalst.add(efa);
                                       }
                                   } else {
                                       if(att.Name == 'Welcome Letter.pdf') {
                                           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                           efa.setFileName('Welcome Letter.pdf');
                                           efa.setBody(att.Body);
                                           efalst.add(efa);
                                       }
                                   }
                                if(!efalst.isEmpty()) {
                                    email.setFileAttachments(efalst);
                                }
                            }
                        }
                        mails.add(email); 
                    }
                    try {
                        if(!mails.isEmpty()){
                            Messaging.sendEmail(mails);
                            List<PropStrength__Application_Booking__c> updatebookingList = new List<PropStrength__Application_Booking__c>();
                            for(PropStrength__Application_Booking__c oneBook : bookingList) {
                                oneBook.PropStrength__Welcome_Letter__c = true;
                                if(oneBook.PropStrength__Welcome_Letter_Note__c == null) {
                                    oneBook.PropStrength__Welcome_Letter_Note__c = system.today();
                                }
                                updatebookingList.add(oneBook);
                            }
                            if(!updatebookingList.isEmpty()){
                                Update updatebookingList;
                                if(!updatebookingList.isEmpty()) {
                                    response = 'SUCCESS';
                                }
                            }
                        }
                    } Catch(Exception e){
                        System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                        System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        response = 'ERROR';
                    }
                }
            } else {
                response = 'INCOMPLETE';
            }
        }
        return response;
    }
}