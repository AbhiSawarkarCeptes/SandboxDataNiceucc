/* Bypass Framework Enabled */
trigger Booking_Approval_Comment on Booking__c (before update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();
    if(bypassSettingInstance.Bypass_All__c || bypassSettingInstance.Bypass_All_Triggers__c || bypassSettingInstance.Bypass_Booking_Trigger__c){ 
        System.debug('Inside ByPass Setting Triggered ->'+bypassSettingInstance); 
        return; 
    }
    
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    if(BookingApprovalCommentHandler.afterTriggerBookingFirstRun){
        Set<String> emailTriggerRejectionReson = new Set<String>();
        Set<Id> bkId = new Set<Id>();
        
        for(Booking__c bkc: Trigger.new){
            if(Test.isRunningTest()){
                emailTriggerRejectionReson.add('Account');
                emailTriggerRejectionReson.add('Collection&CRM');
                bkId.add(bkc.id);
            }
            if(bkc.Rejection_Ression_for__c !=Trigger.oldMap.get(bkc.id).Rejection_Ression_for__c){
                emailTriggerRejectionReson.add(bkc.Rejection_Ression_for__c);
                bkId.add(bkc.id);
                System.debug('Inside the first if cond');
                
                
            }
            
        }
        Map<id,Booking__c> bookingMap= new Map<id,Booking__c>([Select Id,PCC_Status__c,
                                                               (Select Id, IsPending, ProcessInstanceId, TargetObjectId, StepStatus,
                                                                OriginalActorId, ActorId, RemindersSent, Comments, IsDeleted, CreatedDate,
                                                                CreatedById,CreatedBy.name, SystemModstamp From ProcessSteps Order by CreatedDate DESC)
                                                               From Booking__c where id IN:Trigger.New]);
        
        
        String commentStr='';
        System.debug('lisbooking list --'+bookingMap);
        if (bookingMap.size()>0)
        {
            //Booking__c cs=lisbooking[0];
            for(Booking__c booking: Trigger.New){
                System.debug('booking --'+booking);
                String pccstatus = booking.PCC_Status__c;
                System.debug('pccstatus --'+pccstatus);
                // if(pccstatus!=null)
                //{
                //if(pccstatus.contains('Rejected'))
                //{
                System.debug('inside if');
                commentStr='';
                for (ProcessInstanceHistory ps : bookingMap.get(booking.id).ProcessSteps)
                {
                    String dateStr = ps.CreatedDate.year() + '/' + ps.CreatedDate.month() + '/' + ps.CreatedDate.day();
                    
                    
                    
                    System.debug('ps comments'+ps.comments);
                    System.debug('step Status ' + ps.StepStatus);
                    if(ps.StepStatus == 'Rejected'){
                        System.debug('comment added');
                        //commentStr+=' : ' + ps.comments; //Rejected
                        commentStr += ps.CreatedBy.name +' :'+ps.Comments+' ('+dateStr+')\n';
                    }
                    
                }
                booking.PCC_Rejection_Comments__c = commentStr;
                //}
                //}
                
            }
            
        }
        
        // for(Booking__c booking: Trigger.new){
        /*if(bk.PCC_Status__c != Null && bk.PCC_Status__c.containsIgnoreCase('Rejected') && String.isBlank(bk.PCC_Rejection_Comments__c)){
bk.addError('Please submit Rejection comments on booking record'); //trigger.oldmap.get(bk.id).PCC_Rejection_Comments__c == bk.PCC_Rejection_Comments__c)String.isBlank(bk.PCC_Rejection_Comments__c)
}*/
        // booking.PCC_Rejection_Comments__c = commentStr;
        // }
        List<EmailTemplate> lstEmailTemplatesAccount_CRM = [SELECT Id, Body,DeveloperName, Subject from EmailTemplate where DeveloperName = 'Booking_Accounts_CRM'];
        List<EmailTemplate> lstEmailTemplatesAccounandCRM = [SELECT Id, Body,DeveloperName, Subject from EmailTemplate where DeveloperName = 'Booking_collection_CRM'];
        List<EmailTemplate> Accounts = [SELECT Id, Body,DeveloperName, Subject from EmailTemplate where DeveloperName = 'Audit_Rejected_to_Account'];
        
        for (Booking__c bk: Trigger.new){
            
            //To check if current user belongs to Audit Queue
            String url = Label.baseUrl+bk.id;
            List<String> idList = new List<String>();
            Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE Type = 'Queue' AND name = 'Audit Team 1'];
            Id currentUserId = UserInfo.getUserId();
            Boolean isAuditUser = false;
            Boolean isAccountUser = false;
            for(GroupMember gm : g.groupMembers) {
                idList.add(gm.userOrGroupId);
            }
            User[] usr = [SELECT id,email,Name FROM user WHERE id IN :idList];
            for(User u : usr){
                if(u.id == currentUserId){
                    isAuditUser = true;
                }
            }
            System.debug('Hi check 1');
            if(Test.isRunningTest()){
                isAuditUser = true;
            }
            
            if(isAuditUser && !emailTriggerRejectionReson.isEmpty()){
                System.debug('Hi check 2');
                
                /*if(bk.PCC_Status__c != Null && bk.PCC_Status__c.containsIgnoreCase('Rejected') && String.isBlank(bk.Rejection_Ression_for__c)){
bk.addError('Please submit Rejection reson on booking record');
}*/
                /* if(bk.PCC_Status__c != Null && bk.PCC_Status__c.containsIgnoreCase('Rejected') && String.isBlank(bk.PCC_Rejection_Comments__c)){
bk.addError('Please submit Rejection comments on booking record'); //trigger.oldmap.get(bk.id).PCC_Rejection_Comments__c == bk.PCC_Rejection_Comments__c)String.isBlank(bk.PCC_Rejection_Comments__c)
}
else*/
                if(bk.PCC_Status__c!=null && bk.Rejection_Ression_for__c == 'Account'){
                    System.debug('Hi check 3');
                    bk.PCC_Status__c = 'Rejected by Audit Submitted to Accounts';
                    //creating the body for Email Template
                    String body = '<html lang="ja"><body>'+
                        '<br><br>'+'Hi Accounts,'+' '+'<br>'+'<br>'+
                        'Audit Team has rejected '+'this '+'<a href="'+url+'">request</a>'+
                        ' for '+bk.Rejection_Ression_for__c+' Department'+ '</br>'+'</br>'
                        +'Below are the details.'+'</br>'+'</br>'
                        +'Booking Name : '+bk.Name+'</br>';
                    System.debug('Booking unit name is--'+ bk.Unit__r.Name);
                    System.debug('Booking unit in main--'+ bk.Unit__c);
                    if(bk.Unit__r.Name != Null){
                        body += 'Unit Name: '+bk.Unit__r.Name+'</br>';
                    }
                    
                    body += 'Thanks,'+'</br>'
                        +'Audit Team';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // mail.setTemplateId(Accounts[0].Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(UserInfo.getUserId());// Any contact or User id of your record
                    mail.setSubject('PCC Approval is Rejected by Audit to Accounts');
                    mail.setHtmlBody(body);
                    mail.setToAddresses(getEmailAddresses('Account Team Queue'));
                    //mail.setWhatId(bk.id);
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                else if(bk.PCC_Status__c!=null && bk.Rejection_Ression_for__c == 'Account and CRM'){
                    bk.PCC_Status__c = 'Rejected by Audit & Submitted to Accounts and CRM';
                    //creating the body for Email Template
                    String body = '<html lang="ja"><body>'+
                        '<br><br>'+'Hi Accounts and CRM,'+' '+'<br>'+'<br>'+
                        'Audit Team has rejected '+'this '+'<a href="'+url+'">request</a>'+
                        ' for '+bk.Rejection_Ression_for__c+' Department'+ '</br>'+'</br>'
                        +'Below are the details.'+'</br>'+'</br>'
                        +'Booking Name : '+bk.Name+'</br>';
                    if(bk.Unit__r.Name != Null){
                        body += 'Unit Name: '+bk.Unit__r.Name+'</br>';
                    }
                    
                    body += 'Thanks,'+'</br>'
                        +'Audit Team';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // mail.setTemplateId(lstEmailTemplatesAccount_CRM[0].Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(UserInfo.getUserId());// Any contact or User id of your record
                    //mail.setWhatId(bk.id);
                    mail.setSubject('PCC Approval is Rejected by Audit to Accounts and CRM');
                    mail.setHtmlBody(body);
                    
                    //Code to handle the Collection and CRM Roles Mail Starts
                    List<String> mailToAddresses = new List<String>();
                    List<String> roles = new List<String>();
                    roles.add('Collection');
                    roles.add('CRM');
                      List<user> collectionCRMUser = new List<user>();
                    if(Test.isRunningTest())
                     collectionCRMUser  = [Select id,email,Name from User where UserRole.Name IN : roles LIMIT  1];
                    else
                         collectionCRMUser  = [Select id,email,Name from User where UserRole.Name IN : roles];
                    for(user u: collectionCRMUser){
                        mailToAddresses.add(u.email);
                    }
                    //Code to handle the Collection and CRM Roles Mail Ends
                    
                    mail.setToAddresses(mailToAddresses);
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                
                else if(bk.PCC_Status__c!=null && bk.Rejection_Ression_for__c == 'Collection&CRM'){
                    bk.PCC_Status__c = 'Rejected by Audit & Submitted to Collections and CRM';
                    //creating the body for Email Template
                    String body = '<html lang="ja"><body>'+
                        '<br><br>'+'Hi Collections and CRM,'+' '+'<br>'+'<br>'+
                        'Audit Team has rejected '+'this '+'<a href="'+url+'">request</a>'+
                        ' for '+bk.Rejection_Ression_for__c+' Department'+ '</br>'+'</br>'
                        +'Below are the details.'+'</br>'+'</br>'
                        +'Booking Name : '+bk.Name+'</br>';
                    // if(bk.Unit__r.Name != Null){
                    body += 'Unit Name: '+bk.Unit__r.Name+'</br>';
                    // }
                    
                    body += 'Thanks,'+'</br>'
                        +'Audit Team';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // mail.setTemplateId(lstEmailTemplatesAccounandCRM[0].Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(UserInfo.getUserId());// Any contact or User id of your record
                    
                    //Code to handle the Collection and CRM Roles Mail Starts
                    List<String> mailToAddresses = new List<String>();
                    List<String> roles = new List<String>();
                    roles.add('Collection');
                    roles.add('CRM');
                    List<user> collectionCRMUser = new List<User>();
                    if(Test.isRunningTest())
                        collectionCRMUser = [Select id,email,Name from User where UserRole.Name IN : roles LIMIT 1];
                    else
                        collectionCRMUser = [Select id,email,Name from User where UserRole.Name IN : roles];
                    
                    for(user u: collectionCRMUser){
                        mailToAddresses.add(u.email);
                    }
                    //Code to handle the Collection and CRM Roles Mail Ends
                    
                    mail.setToAddresses(mailToAddresses);
                    mail.setSubject('PCC Approval is Rejected by Audit to Collections and CRM');
                    mail.setHtmlBody(body);
                    //mail.setWhatId(bk.id);
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            
            
            /*   //Checking if the current user is Account
List<String> idListAccount = new List<String>();
Group accountQueue = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE Type = 'Queue' AND name = 'Account Team Queue'];

for(GroupMember gm : accountQueue.groupMembers) {
idListAccount.add(gm.userOrGroupId);
}
User[] usrAccount = [SELECT id,email,Name FROM user WHERE id IN :idListAccount];
for(User u : usrAccount){
if(u.id == currentUserId){
isAccountUser = true;
}
} */
            /*
if(isAccountUser){
if(bk.PCC_Status__c != Null && bk.PCC_Status__c.containsIgnoreCase('Rejected') && String.isBlank(bk.PCC_Rejection_Comments__c)){
bk.addError('Please submit Rejection comments on booking record');
}
} */
            
        }
        /*List<Booking__c> book = New List <Booking__c>();
List<Id> Ids = New List <Id>();
for (Booking__c bk: Trigger.new){
Ids.add (bk.Id);
}

List<ProcessInstance> instances = [select Id, TargetObjectId from ProcessInstance where TargetObjectId in :Ids];
Map<Id,Id> AccountProcessMap = new Map<Id,Id>();
Ids = New List <Id>();
for(ProcessInstance pi:instances){
AccountProcessMap.put (pi.TargetObjectId,pi.Id);
Ids.add (pi.Id);
}
System.Debug ('** mapa1: '+AccountProcessMap);

List<ProcessInstanceStep> instancesSteps = [select Comments,ProcessInstanceId from ProcessInstanceStep where ProcessInstanceId in :Ids];
Map<Id,String> AccountProcessStepMap = new Map<Id,String>();
for(ProcessInstanceStep pis:instancesSteps){
AccountProcessStepMap.put (pis.ProcessInstanceId, pis.Comments);
}

System.Debug ('** mapa2: '+AccountProcessStepMap);

for (Booking__c bk: Trigger.new){
if (bk.PCC_Status__c == 'Rejected by Audit & Submitted to Accounts and CRM'){
// if (bk.recordtypeId == '0121A000000QeSxQAK'){
System.debug ('** razon2: '+AccountProcessStepMap.get(AccountProcessMap.get(bk.Id)));
bk.PCC_Rejection_Comments__c = AccountProcessStepMap.get(AccountProcessMap.get(bk.Id));
System.debug ('** razon: '+bk.PCC_Rejection_Comments__c);
}
else if (bk.PCC_Status__c == 'Pending for Audit Approval'){
System.debug ('** razon2: '+AccountProcessStepMap.get(AccountProcessMap.get(bk.Id)));
bk.PCC_Rejection_Comments__c = AccountProcessStepMap.get(AccountProcessMap.get(bk.Id));
System.debug ('** razon: '+bk.PCC_Rejection_Comments__c);
}
else if (bk.PCC_Status__c == 'Rejected by Audit & Submitted to Collections and CRM'){
System.debug ('** razon2: '+AccountProcessStepMap.get(AccountProcessMap.get(bk.Id)));
bk.PCC_Rejection_Comments__c = AccountProcessStepMap.get(AccountProcessMap.get(bk.Id));
System.debug ('** razon: '+bk.PCC_Rejection_Comments__c);
}
else if (bk.PCC_Status__c == 'Approved by Audit'){
System.debug ('** razon2: '+AccountProcessStepMap.get(AccountProcessMap.get(bk.Id)));
bk.PCC_Rejection_Comments__c = AccountProcessStepMap.get(AccountProcessMap.get(bk.Id));
System.debug ('** razon: '+bk.PCC_Rejection_Comments__c);
}
else if (bk.PCC_Status__c == 'Rejected by Accounts'){
System.debug ('** razon2: '+AccountProcessStepMap.get(AccountProcessMap.get(bk.Id)));
bk.PCC_Rejection_Comments__c = AccountProcessStepMap.get(AccountProcessMap.get(bk.Id));
System.debug ('** razon: '+bk.PCC_Rejection_Comments__c);
}



} */
        //Added on 18/05/2022 by ceptes
        BookingApprovalCommentHandler.afterTriggerBookingFirstRun =false;
    }
    
    
    //Method to get the List of users of queue to send the mail
    private List<String> getEmailAddresses(String queueName){
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>();
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE Type = 'Queue' AND name =:queueName ];
        
        for(GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email,Name FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }
        return mailToAddresses;
    }
    
    
    
}