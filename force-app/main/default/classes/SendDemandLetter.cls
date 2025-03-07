public class SendDemandLetter {
	@Future(Callout=True)
    public static void sendMail(Set<Id> payIdset) {
        List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
        system.debug('finish::'+payIdset);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];

        List<String> sendTo = new List<String>(); 
        List<String> ccList = new List<String>(); 
        List<Attachment> insertList = new List<Attachment>();
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        if(!payIdset.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentList = [SELECT Id,PropStrength__Payment_Date__c,PropStrength__Application_Booking__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__c,
                                                                   PropStrength__Application_Booking__r.PropStrength__Project__r.PropStrength__Grace_Days__c, RecordType.Name
                                                                   FROM PropStrength__Received_Payment__c
                                                                   WHERE Id IN: payIdset];
            if(!paymentList.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentList) {
                    bookingIds.add(pay.PropStrength__Application_Booking__c);
                }
                if(!bookingIds.isEmpty()) {
                    for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Application__c
                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                       WHERE PropStrength__Application__c IN: bookingIds 
                                                                       AND PropStrength__Active__c =: true 
                                                                       AND PropStrength__Applicant_Acc__c != null]) {
                                                                           if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                                                                               List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                                                                               newPLI.add(appLicant);
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                                                                           } else {
                                                                               applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                                                                           }
                                                                       }
                }
                if(!applicantListMap.isEmpty()) {
                    for(PropStrength__Received_Payment__c pay : paymentList) {
                        PageReference pdf = Page.Demand_Letter;
                        Blob b;
                        if (pdf != null) {
                            pdf.getParameters().put('id', pay.Id); // Replace 'id' with the actual parameter name
                        }
                        try {
                            // Render the PDF content
                            if(Test.isRunningTest()) {
                                b = Blob.valueOf('test');
                            } else {
                                b = pdf.getContent();
                            }
                        } catch (VisualforceException e) {
                            System.debug('Error generating PDF content: ' + e.getMessage());
                            // Handle the exception appropriately
                        }
                        Attachment att = new Attachment();
                        att.ParentId = pay.Id;
                        att.Name = 'Demand Letter.pdf';
                        att.Body = b;
                        insertList.add(att);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
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
                    }
                    if(!attachmentMap.isEmpty()) {
                        system.debug('attachmentMap::'+attachmentMap);
                        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                             FROM EmailTemplate 
                                                             WHERE DeveloperName =: 'Demand_Letter_Email'];
                        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            if(applicantListMap.containskey(ppd.PropStrength__Application_Booking__c)){
                                for(PropStrength__Applicant_Detail__c applicant : applicantListMap.get(ppd.PropStrength__Application_Booking__c)) {
                                    if(applicant.PropStrength__Type__c == '1st Applicant') {
                                        sendTo.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                    if(applicant.PropStrength__Type__c != '1st Applicant') {
                                        ccList.add(applicant.PropStrength__Applicant_Email__c);
                                    }
                                }
                            }
                        }
                        for(PropStrength__Received_Payment__c ppd : paymentList) {
                            String frmsrcSOA = '/apex/SOALetter?Id=' + ppd.PropStrength__Application_Booking__c;
                            PageReference pSOA = new PageReference(frmsrcSOA);
                            Blob content;
                            try {
                                // Render the PDF content
                                if(Test.isRunningTest()) {
                                    content = Blob.valueOf('test');
                                } else {
                                    content = pSOA.getContentAsPDF();
                                }
                            } catch (VisualforceException e) {
                                System.debug('Error generating PDF content: ' + e.getMessage());
                                // Handle the exception appropriately
                            }
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(!sendTo.isEmpty()) {
                                email.setToAddresses(sendTo);
                            }
                            if(!ccList.isEmpty()) {
                                email.setCcAddresses(ccList);
                            }
                            email.setWhatId(ppd.id);
                            email.setTargetObjectId(ppd.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                            email.setTreatTargetObjectAsRecipient(False);
                            if (owea.size() > 0) {
                                email.setOrgWideEmailAddressId(owea.get(0).Id);
                            }

                            
                            email.saveAsActivity = true;
                            email.setTemplateId(tempId);
                            if(attachmentMap.containskey(ppd.Id)){
                                for(Attachment att : attachmentMap.get(ppd.Id)) {
                                    if(att.Name == 'Demand Letter.pdf') {
                                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                        efa.setFileName('Demand Letter.pdf');
                                        efa.setBody(att.Body);
                                        efalst.add(efa);
                                    }
                                }
                            }
                            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                            efa.setFileName('Statement Of Account.pdf');
                            efa.setBody(content);
                            efalst.add(efa);
                            if(!efalst.isEmpty()) {
                                email.setFileAttachments(efalst);
                            }
                            mails.add(email); 
                        }
                        try {
                            if(!mails.isEmpty()){
                                Messaging.sendEmail(mails);
                            }
                        } catch(Exception e){
                            System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                            System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                        }
                    }
                }
            }
        }
    }
}