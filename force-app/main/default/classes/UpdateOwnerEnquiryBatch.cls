//Comment added on 26 December 2023 by Nishank Manwani, this class is converted into flow, So dont execute it
public class UpdateOwnerEnquiryBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, OwnerId, Prefered_LAnguage__c, Assignment_Group__c, Enquiry_Owner_Batch_Update__c, LastModifiedDate, CreatedDate, PropStrength__Request_Status__c FROM PropStrength__Request__c WHERE PropStrength__Request_Status__c = \'Open\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext context) {
        UpdateOwnerEnquiryBatch batch = new UpdateOwnerEnquiryBatch();
        Database.executeBatch(batch);
    }
    
    public void execute(Database.BatchableContext context, List<PropStrength__Request__c> scope) {
        Map<String, PropStrength__Assignment_Group_Name__c> assGrpMap = new Map<String, PropStrength__Assignment_Group_Name__c>([SELECT Id, Name, (SELECT Id, PropStrength__User__c, PropStrength__Order__c FROM PropStrength__Group_Members__r WHERE PropStrength__Active__c = 'TRUE' ORDER BY PropStrength__Order__c) FROM PropStrength__Assignment_Group_Name__c WHERE PropStrength__Active__c = TRUE AND PropStrength__Type__c = 'Enquiry']);
        
        if(!assGrpMap.isEmpty()) {
            List<PropStrength__Request__c> updEnqRecList = new List<PropStrength__Request__c>();
            for(PropStrength__Request__c req : scope) {
                System.debug('req::'+req);
                System.debug(System.now());
                if(req.Enquiry_Owner_Batch_Update__c != null ) {
                    Long millisecondsDifference = System.now().getTime() - req.Enquiry_Owner_Batch_Update__c.getTime();
                    Integer minutesDifference = Integer.valueOf(millisecondsDifference / (1000 * 60));
                    System.debug(minutesDifference);
                    if(req.Enquiry_Owner_Batch_Update__c != null && req.PropStrength__Request_Status__c == 'Open' && req.Assignment_Group__c != null && assGrpMap.containsKey(req.Assignment_Group__c) && minutesDifference >= 20 && minutesDifference <= 30) {
                        Id userId = null;
                        List<PropStrength__Group_Member__c> usersInfo = assGrpMap.get(req.Assignment_Group__c).PropStrength__Group_Members__r;
                        if(!usersInfo.isEmpty()) {
                            Integer cnt = 1;
                            for(Integer i = 0; i < usersInfo.size(); i++) {
                                if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() > cnt) {
                                    userId = usersInfo[i+1].PropStrength__User__c;
                                } else if(usersInfo[i].PropStrength__User__c == req.OwnerId && usersInfo.size() == cnt) {
                                    userId = usersInfo[0].PropStrength__User__c;
                                }
                                cnt++;
                            }
                            System.debug('userId::'+userId);
                            if(userId != null) {
                                updEnqRecList.add(new PropStrength__Request__c(Id = req.Id, Enquiry_Owner_Batch_Update__c = System.now(), OwnerId = userId));   
                            }
                        }
                    }    
                }
            }
            System.debug('updEnqRecList::'+updEnqRecList);
            if(!updEnqRecList.isEmpty()) {
                update updEnqRecList;
            }
        }
    }
    
    public void finish(Database.BatchableContext context) {
        Integer minutesDelay = 1;
        Datetime futureTime = Datetime.now().addMinutes(minutesDelay);
        String cronExp = '0 ' + futureTime.minute() + ' ' + futureTime.hour() + ' ' + futureTime.day() + ' ' + futureTime.month() + ' ? ' + futureTime.year();
        
        System.schedule('Scheduled_Enquiry_Batch_Job'+System.now().addDays(Integer.valueof((Math.random() * 100))), cronExp, new UpdateOwnerEnquiryBatch());
    }
}