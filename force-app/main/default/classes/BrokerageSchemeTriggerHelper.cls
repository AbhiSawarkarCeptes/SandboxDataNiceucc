/*********************************************************************
 * Class Name  :   BrokerageSchemeTriggerHelper
 * Description :   Helper Class For BrokerageSchemeTrigger
 * Created Date:   28/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 28/12/2023
 *********************************************************************/
public class BrokerageSchemeTriggerHelper {
    //Added by Nishank Manwani on 28-Dec-2023 to fill Check_End_Date__c 
    public static void fillCheckEndDate(List<PropStrength__Brokerage_Scheme__c> bsList) {
        for(PropStrength__Brokerage_Scheme__c bs : bsList) {
            if(bs.Check_End_Date__c == null && bs.PropStrength__Active__c) {
                bs.Check_End_Date__c = System.Today();
            }
        }
    }
}