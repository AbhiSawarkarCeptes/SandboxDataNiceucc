/*********************************************************************
 * Class Name  :   CheckPaymentPlanValidTillEveryday
 * Description :   Check Payment Plan Valid Till Everyday to deactive the Payment Plan
 * Created Date:   27/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 27/12/2023
 *********************************************************************/
public class CheckPaymentPlanValidTillEveryday {
    @InvocableMethod
    public static void updateActiveCheckboxOnPP(List<PropStrength__Payment_Plan__c> ppIdRec) {
        try{
            List<PropStrength__Payment_Plan__c> ppList = [select Id,Valid_Till__c FROM PropStrength__Payment_Plan__c where Id =: ppIdRec[0].Id];
            if(!ppList.isEmpty()){
                List<PropStrength__Payment_Plan__c> updPpRecList = new List<PropStrength__Payment_Plan__c>();
                PropStrength__Payment_Plan__c paymntPln = ppList[0];
                if(paymntPln.Valid_Till__c != null ) {
                    if(System.Today().daysBetween(paymntPln.Valid_Till__c) < 0) {
                        updPpRecList.add(new PropStrength__Payment_Plan__c(Id = paymntPln.Id, PropStrength__Active__c = False, Check_Valid_Till__c = null));   
                    } else {
                        updPpRecList.add(new PropStrength__Payment_Plan__c(Id = paymntPln.Id, Check_Valid_Till__c = System.Today()));   
                    }  
                }
                System.debug('updPpRecList::'+updPpRecList);
                if(!updPpRecList.isEmpty()) {
                    update updPpRecList;
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
}