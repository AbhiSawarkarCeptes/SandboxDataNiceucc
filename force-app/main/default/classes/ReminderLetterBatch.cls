global class ReminderLetterBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id ,Name,Reminder_Count__c,
                                         PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                         PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email,
                                         PropStrength__Application_Booking__r.PropStrength__Project__c,PropStrength__Balance__c,
                                         PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c,
                                         X1st_Reminder_Date__c,X1st_Reminder_Sent__c,X2nd_Reminder_Date__c,X2nd_Reminder_Sent__c,
                                         X3rd_Reminder_Date__c,X3rd_Reminder_Sent__c,X4th_Reminder_Date__c,X4th_Reminder_Sent__c,
                                         Last_Reminder_Date__c,Last_Reminder_Sent__c
                                         FROM PropStrength__Received_Payment__c 
                                         WHERE RecordType.Name =: 'Payment Due' AND 
                                         PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c = false AND PropStrength__Payment_Plan_Detail__r.Do_Not_Raise_Demand__c = FALSE 
                                         AND PropStrength__Application_Booking__c != null 
                                         AND PropStrength__Application_Booking__r.PropStrength__Active__c =: true 
                                         AND PropStrength__Application_Booking__r.Do_Not_Send_Reminder__c =: false 
                                         AND PropStrength__Application_Booking__r.PropStrength__Project__r.Do_Not_Send_Reminder__c =: false AND
                                         PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.Do_Not_Send_Reminder__c =: false
                                         AND PropStrength__Is_Reversal_Created__c =: false
                                         AND PropStrength__Balance__c > 0 
                                         AND PropStrength__Demand_Generation_Date__c != null
                                         AND PropStrength__Demand_Generated__c =: true 
                                         AND ((X1st_Reminder_Date__c =: Date.Today() 
                                               AND X1st_Reminder_Sent__c =: false) OR 
                                              (X2nd_Reminder_Date__c =: Date.Today() 
                                               AND X2nd_Reminder_Sent__c =: false
                                               AND X1st_Reminder_Sent__c =: true) OR
                                              (X3rd_Reminder_Date__c =: Date.Today() 
                                               AND X3rd_Reminder_Sent__c =: false
                                               AND X2nd_Reminder_Sent__c =: true
                                               AND X1st_Reminder_Sent__c =: true) OR
                                              (X4th_Reminder_Date__c =: Date.today() 
                                               AND X4th_Reminder_Sent__c =: false
                                               AND X1st_Reminder_Sent__c =: true
                                               AND X2nd_Reminder_Sent__c =: true
                                               AND X3rd_Reminder_Sent__c =: true) OR
                                              (Last_Reminder_Date__c =: Date.today() 
                                               //AND Last_Reminder_Sent__c =: false
                                               AND X1st_Reminder_Sent__c =: true
                                               AND X2nd_Reminder_Sent__c =: true
                                               AND X3rd_Reminder_Sent__c =: true
                                               AND X4th_Reminder_Sent__c =: true))]);
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Received_Payment__c> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


        List<String> sendTo = new List<String>(); 
        Map<Id,List<Attachment>> attachmentMap = new Map<Id,List<Attachment>>();
        set<Id> ppdIds = new set<Id>();
        List<Attachment> insertList = new List<Attachment>();
        List<String> ccList = new List<String>(); 
        Set<Id> bookingIds = new Set<Id>(); 
        Map<Id,List<PropStrength__Applicant_Detail__c>> applicantListMap = new Map<Id,List<PropStrength__Applicant_Detail__c>>();
        Integer i = 0;
        Integer j = 0;
        for(PropStrength__Received_Payment__c payment : scope) {
            if(payment.X1st_Reminder_Date__c == Date.today() && 
               payment.X1st_Reminder_Sent__c == false) {
                   i = 1;
                   PageReference pdf = Page.ReminderDueNotice;
                    pdf.getParameters().put('id', String.valueOf(payment.Id));
                   
                   Blob b ;
                   if(Test.isRunningTest()){
                       b = blob.valueOf('Unit.Test');
                   }else{
                       b = pdf.getContent();
                   }
                    Attachment att = new Attachment();
                    att.ParentId = payment.Id;
                    att.Name = 'Reminder Letter ' + i + '.pdf';
                    att.Body = b;
                    insertList.add(att);
               } else if(payment.X1st_Reminder_Sent__c == true && 
                         payment.X2nd_Reminder_Date__c == Date.Today() && 
                         payment.X2nd_Reminder_Sent__c == false) {
                             i = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1: null);
                             PageReference pdf = Page.ReminderDueNotice;
                             pdf.getParameters().put('id', String.valueOf(payment.Id));
                             Blob b ;
                             if(Test.isRunningTest()){
                                 b = blob.valueOf('Unit.Test');
                             }else{
                                 b = pdf.getContent();
                             }
                             Attachment att = new Attachment();
                             att.ParentId = payment.Id;
                             att.Name = 'Reminder Letter '+i+'.pdf';
                             att.Body = b;
                             insertList.add(att);
                         } else if(payment.X1st_Reminder_Sent__c == true && 
                                   payment.X2nd_Reminder_Sent__c == true && 
                                   payment.X3rd_Reminder_Date__c == Date.today() && 
                                   payment.X3rd_Reminder_Sent__c == false) {
                                       i = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1 : null);
                                       PageReference pdf = Page.ReminderDueNotice;
                                pdf.getParameters().put('id', String.valueOf(payment.Id));
                               
                                       Blob b ;
                                       if(Test.isRunningTest()){
                                           b = blob.valueOf('Unit.Test');
                                       }else{
                                           b = pdf.getContent();
                                       }
                                       Attachment att = new Attachment();
                                       att.ParentId = payment.Id;
                                       att.Name = 'Reminder Letter '+i+'.pdf';
                                       att.Body = b;
                                       insertList.add(att);
                                   } else if(payment.X1st_Reminder_Sent__c == true && 
                                             payment.X2nd_Reminder_Sent__c == true && 
                                             payment.X4th_Reminder_Date__c == Date.today() && 
                                             payment.X3rd_Reminder_Sent__c == true && 
                                             payment.X4th_Reminder_Sent__c == false) {
                                                 i = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1 : null);
                                                 PageReference pdf = Page.ReminderDueNotice;
                                pdf.getParameters().put('id', String.valueOf(payment.Id));
                                                 Blob b ;
                                                 if(Test.isRunningTest()){
                                                     b = blob.valueOf('Unit.Test');
                                                 }else{
                                                     b = pdf.getContent();
                                                 }
                              
                                                 Attachment att = new Attachment();
                                                 att.ParentId = payment.Id;
                                                 att.Name = 'Reminder Letter '+i+'.pdf';
                                                 att.Body = b;
                                                 insertList.add(att);
                                             }  else if(payment.Last_Reminder_Sent__c == false && 
                                                        payment.X1st_Reminder_Sent__c == true && 
                                                        payment.X2nd_Reminder_Sent__c == true && 
                                                        payment.Last_Reminder_Date__c == Date.today() && 
                                                        payment.X3rd_Reminder_Sent__c == true && 
                                                        payment.X4th_Reminder_Sent__c == true) {
                                                            i = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1 : null);
                                                            PageReference pdf = Page.ReminderDueNotice;
                                pdf.getParameters().put('id', String.valueOf(payment.Id));
                               
                                                            Blob b ;
                                                            if(Test.isRunningTest()){
                                                                b = blob.valueOf('Unit.Test');
                                                            }else{
                                                                b = pdf.getContent();
                                                            }
                                                            Attachment att = new Attachment();
                                                            att.ParentId = payment.Id;
                                                            att.Name = 'Reminder Letter '+i+'.pdf';
                                                            att.Body = b;
                                                            insertList.add(att);
                                                        } else if(payment.Last_Reminder_Sent__c == true && 
                                                                  payment.X1st_Reminder_Sent__c == true && 
                                                                  payment.X2nd_Reminder_Sent__c == true && 
                                                                  payment.Last_Reminder_Date__c == Date.today() && 
                                                                  payment.X3rd_Reminder_Sent__c == true && 
                                                                  payment.X4th_Reminder_Sent__c == true) {
                                                                      i = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1 : null);
                                                                      PageReference pdf = Page.ReminderDueNotice;
                                pdf.getParameters().put('id', String.valueOf(payment.Id));
                                                                      Blob b ;
                                                                      if(Test.isRunningTest()){
                                                                          b = blob.valueOf('Unit.Test');
                                                                      }else{
                                                                          b = pdf.getContent();
                                                                      }
                                                                      Attachment att = new Attachment();
                                                                      att.ParentId = payment.Id;
                                                                      att.Name = 'Reminder Letter '+i+'.pdf';
                                                                      att.Body = b;
                                                                      insertList.add(att);
                                                                  }
            
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
        system.debug('attachmentMap::'+attachmentMap.size());
        if(!attachmentMap.isEmpty()) {
            system.debug('attachmentMap::'+attachmentMap);
            
            for(PropStrength__Received_Payment__c pay : scope) {
                bookingIds.add(pay.PropStrength__Application_Booking__c);
            }
            if(!bookingIds.isEmpty()) {
                for(PropStrength__Applicant_Detail__c appLicant : [SELECT Id,PropStrength__Application__c,PropStrength__Applicant_Email__c,PropStrength__Type__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c IN: bookingIds AND PropStrength__Active__c =: true AND PropStrength__Applicant_Acc__c != null]) {
                    if(applicantListMap.containskey(appLicant.PropStrength__Application__c)) {
                        List<PropStrength__Applicant_Detail__c> newPLI = applicantListMap.get(appLicant.PropStrength__Application__c);
                        newPLI.add(appLicant);
                        applicantListMap.put(appLicant.PropStrength__Application__c, newPLI);
                    } else {
                        applicantListMap.put(appLicant.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{appLicant});
                    }
                }
            }
            system.debug('applicantListMap::'+applicantListMap);
            if(!applicantListMap.isEmpty()) {
                for(PropStrength__Received_Payment__c ppd : scope) {
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
                for(PropStrength__Received_Payment__c payment : scope) {
                    List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
                    if(!payment.X1st_Reminder_Sent__c || !payment.X2nd_Reminder_Sent__c) {
                        emailTemplate=[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                       FROM EmailTemplate 
                                       WHERE DeveloperName =: 'Demand_Reminder'];                
                    } else if(!payment.X3rd_Reminder_Sent__c) {
                        emailTemplate=[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                       FROM EmailTemplate 
                                       WHERE DeveloperName =: 'Demand_Reminder_With_Interest_Calculation'];       
                    } else {
                        emailTemplate=[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                       FROM EmailTemplate 
                                       WHERE DeveloperName =: 'Demand_Reminder_With_Interest'];       
                    }
                    String tempId = '';
                    if(emailTemplate.Size() > 0)
                        tempId = emailTemplate[0].Id;
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(!sendTo.isEmpty()) {
                        email.setToAddresses(sendTo);
                    }
                    if(!ccList.isEmpty()) {
                        email.setCcAddresses(ccList);
                    }
                    email.setWhatId(payment.id);
                    email.setTargetObjectId(payment.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                    email.setTreatTargetObjectAsRecipient(False);
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    email.saveAsActivity = true;
                    email.setTemplateId(tempId);
                    if(attachmentMap.containskey(payment.Id)){
                        for(Attachment att : attachmentMap.get(payment.Id)) {
                            j = (payment.Reminder_Count__c != null ? Integer.valueOf(payment.Reminder_Count__c)  + 1 : 1);
                            system.debug('j::'+j);
                            if(att.Name == 'Reminder Letter '+j+'.pdf') {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(att.Name);
                                efa.setBody(att.Body);
                                efalst.add(efa);
                            }
                            system.debug('efalst::'+efalst);
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
                        List<PropStrength__Received_Payment__c> updateList = new List<PropStrength__Received_Payment__c>();
                        for(PropStrength__Received_Payment__c payment : scope) {
                            if(payment.X1st_Reminder_Date__c == Date.today() && 
                               payment.X1st_Reminder_Sent__c == false) {
                                   PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                   pay.Id = payment.Id;
                                   pay.X1st_Reminder_Sent__c = true;
                                   pay.Reminder_Count__c = 1;
                                   updateList.add(pay);
                               } else if(payment.X1st_Reminder_Sent__c == true && 
                                         payment.X2nd_Reminder_Date__c == Date.Today() && 
                                         payment.X2nd_Reminder_Sent__c == false) {
                                             PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                             pay.Id = payment.Id;
                                             pay.X2nd_Reminder_Sent__c = true;
                                             pay.Reminder_Count__c = payment.Reminder_Count__c + 1;
                                             updateList.add(pay);
                                         } else if(payment.X1st_Reminder_Sent__c == true && 
                                                   payment.X2nd_Reminder_Sent__c == true && 
                                                   payment.X3rd_Reminder_Date__c == Date.today() && 
                                                   payment.X3rd_Reminder_Sent__c == false) {
                                                       PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                                       pay.Id = payment.Id;
                                                       pay.X3rd_Reminder_Sent__c = true;
                                                       pay.Reminder_Count__c = payment.Reminder_Count__c + 1;
                                                       updateList.add(pay);
                                                   } else if(payment.X1st_Reminder_Sent__c == true && 
                                                             payment.X2nd_Reminder_Sent__c == true && 
                                                             payment.X4th_Reminder_Date__c == Date.today() && 
                                                             payment.X3rd_Reminder_Sent__c == true && 
                                                             payment.X4th_Reminder_Sent__c == false) {
                                                                 PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                                                 pay.Id = payment.Id;
                                                                 pay.X4th_Reminder_Sent__c = true;
                                                                 pay.Reminder_Count__c = payment.Reminder_Count__c + 1;
                                                                 pay.Last_Reminder_Date__c = Date.today().addDays(1);
                                                                 updateList.add(pay);
                                                             } else if(payment.Last_Reminder_Sent__c == false && 
                                                                       payment.X1st_Reminder_Sent__c == true && 
                                                                       payment.X2nd_Reminder_Sent__c == true && 
                                                                       payment.Last_Reminder_Date__c == Date.today() && 
                                                                       payment.X3rd_Reminder_Sent__c == true && 
                                                                       payment.X4th_Reminder_Sent__c == true) {
                                                                           PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                                                           pay.Id = payment.Id;
                                                                           pay.Last_Reminder_Date__c = Date.today().addDays(1);
                                                                           pay.Reminder_Count__c = payment.Reminder_Count__c + 1;
                                                                           pay.Last_Reminder_Sent__c = true;
                                                                           updateList.add(pay);
                                                                       } else if(payment.Last_Reminder_Sent__c == true && 
                                                                                 payment.X1st_Reminder_Sent__c == true && 
                                                                                 payment.X2nd_Reminder_Sent__c == true && 
                                                                                 payment.Last_Reminder_Date__c == Date.today() && 
                                                                                 payment.X3rd_Reminder_Sent__c == true && 
                                                                                 payment.X4th_Reminder_Sent__c == true) {
                                                                                     PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c();
                                                                                     pay.Id = payment.Id;
                                                                                     pay.Last_Reminder_Date__c = Date.today().addDays(1);
                                                                                     pay.Reminder_Count__c = payment.Reminder_Count__c + 1;
                                                                                     updateList.add(pay);
                                                                                 }
                            
                            
                        }
                        if(!updateList.isEmpty()) {
                            Update updateList;
                            system.debug('updateList::'+updateList);
                        }
                    }
                } catch(Exception e){
                    System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                    System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}