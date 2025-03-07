/*********************************************************************
 * Class Name  :   CheckBrokerageSchemeEndDateEveryday
 * Description :   Check Brokerage Scheme's End Date Everyday to deactive the Brokerage Scheme
 * Created Date:   28/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 28/12/2023
 *********************************************************************/
public class CheckBrokerageSchemeEndDateEveryday {
    @InvocableMethod
    public static void updateActiveCheckboxOnBS(List<PropStrength__Brokerage_Scheme__c> bsIdRec) {
        try{
            List<PropStrength__Brokerage_Scheme__c> bsList = [select Id,PropStrength__End_Date__c FROM PropStrength__Brokerage_Scheme__c where Id =: bsIdRec[0].Id];
            if(!bsList.isEmpty()){
                List<PropStrength__Brokerage_Scheme__c> updBsRecList = new List<PropStrength__Brokerage_Scheme__c>();
                PropStrength__Brokerage_Scheme__c brkSch = bsList[0];
                if(brkSch.PropStrength__End_Date__c != null ) {
                    if(System.Today().daysBetween(brkSch.PropStrength__End_Date__c) < 0) {
                        updBsRecList.add(new PropStrength__Brokerage_Scheme__c(Id = brkSch.Id, PropStrength__Active__c = False, Check_End_Date__c = null));   
                    } else {
                        updBsRecList.add(new PropStrength__Brokerage_Scheme__c(Id = brkSch.Id, Check_End_Date__c = System.Today()));   
                    }  
                }
                System.debug('updBsRecList::'+updBsRecList);
                if(!updBsRecList.isEmpty()) {
                    update updBsRecList;
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
}