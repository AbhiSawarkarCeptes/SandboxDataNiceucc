/*********************************************************************
 * Class Name  :   CheckEnquirySubStatusEveryDay
 * Description :   Batch class to check enquiry Sub Status status and run every day
 * Created Date:   16/05/2024
 * Authored By :   CloudSteer Technology Pvt Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Gourav Gour
   Last Modified By :   Gourav Gour 16/05/2024
 *********************************************************************/
public class CheckEnquirySubStatusEveryDay implements DataBase.batchable <SObject>,Schedulable{
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Last_Call_Attempt_Status__c, CreatedDate, 
                                        PropStrength__Request_Status__c, Enquiry_Sub_Status__c, DaysCount_Follow_Up_Status__c FROM PropStrength__Request__c 
                                        WHERE PropStrength__Request_Status__c = 'Qualified' AND Enquiry_Sub_Status__c = 'Follow-up']);
    }
    
    public void execute(SchedulableContext context) {
        CheckEnquirySubStatusEveryDay batch = new CheckEnquirySubStatusEveryDay();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Request__c> scope){
        if(!scope.isEmpty()) {
            List<PropStrength__Request__c> updEnqRecList = new List<PropStrength__Request__c>();

            for(PropStrength__Request__c req : scope) {
                if(req.DaysCount_Follow_Up_Status__c == null || req.DaysCount_Follow_Up_Status__c == 0) {
                    updEnqRecList.add(new PropStrength__Request__c(Id = req.Id, DaysCount_Follow_Up_Status__c = 1));
                }
                else {
                    Integer dayCount = Integer.valueof(req.DaysCount_Follow_Up_Status__c) + 1;
                    updEnqRecList.add(new PropStrength__Request__c(Id = req.Id, DaysCount_Follow_Up_Status__c = dayCount));
                }
            }

            System.debug('updEnqRecList***');
            System.debug(updEnqRecList);

            if (!updEnqRecList.isEmpty()) {
                update updEnqRecList;
            }
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
    }
}