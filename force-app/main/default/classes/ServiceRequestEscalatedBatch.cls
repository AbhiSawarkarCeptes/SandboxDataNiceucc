/*********************************************************************
 * Class Name  :   ServiceRequestEscalatedBatch
 * Description :   Batch Class For send mail after 8 hours for service request escalation
 * Created Date:   11/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 11/01/2024
 *********************************************************************/
public class ServiceRequestEscalatedBatch implements DataBase.batchable <SObject>,Schedulable{
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, PropStrength__Status__c, CreatedDate, OwnerId 
                                        FROM PropStrength__Service_Request__c 
                                        WHERE Escalated_Case__c = FALSE AND 
                                        (PropStrength__Status__c = 'New' OR PropStrength__Status__c = 'Open' OR PropStrength__Status__c = 'Not Started')]);
    }
    
    public void execute(SchedulableContext context) {
        ServiceRequestEscalatedBatch batch = new ServiceRequestEscalatedBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Service_Request__c> scope){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Default'].get(0);
        Set<Id> userId = new Set<Id>();

        for(PropStrength__Service_Request__c sr: scope){
            Datetime nowDate = sr.CreatedDate;
            System.debug(nowDate);
            Long runInterval = 8*60*60*1000;
            Datetime cmpDate = BusinessHours.add(bh.Id, nowDate, runInterval);
            System.debug(cmpDate);
            System.debug(System.now());
            Long millisecondsDifference = System.now().getTime() - cmpDate.getTime();
            Integer hoursDifference = (Integer)millisecondsDifference / (1000 * 60 * 60);
            System.debug('hoursDifference***'+hoursDifference);
            if(hoursDifference >= 8){
                userId.add(sr.OwnerId);
            }
        }
        System.debug('userId****');  
        System.debug(userId);
        
        Map<Id,User> mapUser = new Map<Id,User>([SELECT Id,Manager.email,name, ManagerId FROM User WHERE Id IN : userId AND email != null]);
        if(!scope.isEmpty()) {
            List<PropStrength__Service_Request__c> updateSrList = new List<PropStrength__Service_Request__c>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templatelist ;
            Id TempId;
            String searchTxt = 'Escalated_Service_Request';
            templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = :searchTxt limit 1];
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            for(PropStrength__Service_Request__c sr : scope) {
                if(mapUser.containsKey(sr.OwnerId)) {
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    emails.setWhatId(sr.Id);
                    emails.setToAddresses( new String[] {mapUser.get(sr.OwnerId).Manager.Email} ); 
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(mapUser.get(sr.OwnerId).ManagerId);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                    updateSrList.add(new PropStrength__Service_Request__c(Id=sr.Id, Escalated_Case__c = true));
                }
            }

            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                    update updateSrList;
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        System.schedule('ServiceRequestEscalatedBatch_Hourly'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new ServiceRequestEscalatedBatch() );
    }
}