/*********************************************************************
 * Class Name  :   CheckEnquiryStatusEveryDay
 * Description :   Batch class to check enquiry status and run every day
 * Created Date:   10/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 02/02/2024
 *********************************************************************/
public class CheckEnquiryStatusEveryDay implements DataBase.batchable <SObject>,Schedulable{
    
    public Database.querylocator start(DataBase.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Check_Enquiry_Status_Daily__c, Last_Call_Attempt_Status__c, CreatedDate, 
                                        PropStrength__Request_Status__c, Enquiry_Idle_Days__c FROM PropStrength__Request__c 
                                        WHERE Check_Enquiry_Status_Daily__c != NULL AND PropStrength__Request_Status__c = 'Open' AND Check_Enquiry_Status_Daily__c = TODAY]);
    }
    
    public void execute(SchedulableContext context) {
        CheckEnquiryStatusEveryDay batch = new CheckEnquiryStatusEveryDay();
        Database.executeBatch(batch);
    }
    
    public void execute(DataBase.BatchableContext BC,List<PropStrength__Request__c> scope){
        if(!scope.isEmpty()) {
            List<PropStrength__Request__c> updEnqRecList = new List<PropStrength__Request__c>();

            for(PropStrength__Request__c req : scope) {
                updEnqRecList.add(new PropStrength__Request__c(Id = req.Id, Check_Enquiry_Status_Daily__c = System.Today().addDays(1), Enquiry_Idle_Days__c = req.CreatedDate.date().daysBetween(System.Today())));
            }

            System.debug('updEnqRecList***');
            System.debug(updEnqRecList);

            if (!updEnqRecList.isEmpty()) {
                update updEnqRecList;
            }
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        System.schedule('CheckEnquiryStatusEveryDay_Daily'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 0 ? * *', new CheckEnquiryStatusEveryDay() );
    }
}