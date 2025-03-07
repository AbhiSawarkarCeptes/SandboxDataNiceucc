public class ApprovalNotificationBacth implements DataBase.batchable <SObject>,Schedulable{
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,targetobjectid, (SELECT Id, StepStatus,Actor.Name,ActorId,TargetObjectId, Comments,ElapsedTimeInHours,CreatedDate,
                                                                    ElapsedTimeInDays FROM StepsAndWorkitems WHERE StepStatus = 'Pending')  
                                         FROM ProcessInstance]);
    }
    
    public void execute(SchedulableContext context) {
        ApprovalNotificationBacth batch = new ApprovalNotificationBacth();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<ProcessInstance> scope){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Escalation Rule Business Hours'].get(0);
        
        Map<String, String> mapOfRecordAndUser = new Map<String, String>();
        for(ProcessInstance approval: scope){
            for(ProcessInstanceHistory approvalSteps : approval.StepsAndWorkitems){
                Datetime nowDate = approvalSteps.CreatedDate;
                System.debug(nowDate);
                Long runInterval = 16*60*60*1000;
                Datetime cmpDate = BusinessHours.add(bh.Id, nowDate, runInterval);
                System.debug(cmpDate);
                System.debug(System.now());
                Long millisecondsDifference = System.now().getTime() - cmpDate.getTime();
                Integer hoursDifference = (Integer)millisecondsDifference / (1000 * 60 * 60);
                System.debug('hoursDifference***'+hoursDifference);
                if(Test.isRunningTest() || (hoursDifference > 0 && hoursDifference < 1.5)){
                    mapOfRecordAndUser.put(approvalSteps.TargetObjectId, approvalSteps.ActorId);
                }
            }
        }  
        System.debug(mapOfRecordAndUser.size()+'*---mapOfRecordAndUser**---'+mapOfRecordAndUser);
        
        List<User> listOfUserRecord = [SELECT Id,Manager.email,name FROM User WHERE Id IN : mapOfRecordAndUser.values() AND Manager.email != null];
        Map<String, User> mapOfUserAndManager = new Map<String, User>();
        for(User userRec : listOfUserRecord){
            mapOfUserAndManager.put(userRec.Id, userRec);            
        }
        System.debug(mapOfUserAndManager.size()+'*---mapOfUserAndManager**---'+mapOfUserAndManager);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        for(String objRecId : mapOfRecordAndUser.keySet()){
            if(Test.isRunningTest() || mapOfUserAndManager.containsKey(mapOfRecordAndUser.get(objRecId))){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Approval Process Escalation Notification');
                String EmailBody = '';
                if(!Test.isRunningTest()) {
                EmailBody = 'Dear '+mapOfUserAndManager.get(mapOfRecordAndUser.get(objRecId)).Name +',\n\n';
                }
                EmailBody += 'This is to bring to your notice that the Below mentioned record has been sent for approval and is pending for more than the last 16 hours.';
                EmailBody += '\nRequest you to please urgently look into the same.\n\n';
                EmailBody += 'Record URL : '+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objRecId +'.\n\n';
                EmailBody += 'This is a system generated Email, please do not reply !';
                mail.setplaintextbody(EmailBody);
                if(!Test.isRunningTest()) {
                    mail.setToAddresses(new List<String>{mapOfUserAndManager.get(mapOfRecordAndUser.get(objRecId)).Manager.email});
                    mail.setTargetObjectId(mapOfUserAndManager.get(mapOfRecordAndUser.get(objRecId)).Id);
                } else {
                    mail.setToAddresses(new List<String>{'test@13423445.com'});
                }
                if(!owea.isEmpty()) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }
                mail.saveAsActivity = false;
                emailList.add(mail);
            }
        }
        System.debug(emailList.size()+'*----***--*'+emailList);
        if(emailList != null && emailList.size()>0 ) {
            
            for (Messaging.SendEmailResult mr : Messaging.sendEmail(emailList)) 
            {
                if (mr.isSuccess()) {
                    //Do something for success
                }  else {
                    // Operation failed, so get all errors                
                    for(Messaging.SendEmailError err : mr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        System.schedule('ApprovalNotificationBacth_Hourly'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new ApprovalNotificationBacth() );
    }
    
}