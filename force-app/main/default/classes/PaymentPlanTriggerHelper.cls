/*********************************************************************
 * Class Name  :   PaymentPlanTriggerHelper
 * Description :   Helper Class For PaymentPlanTrigger
 * Created Date:   27/12/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 27/12/2023
 *********************************************************************/
public class PaymentPlanTriggerHelper {
    //Added by Nishank Manwani on 27-Dec-2023 to fill Check_Valid_Till__c 
    public static void fillCheckValidTill(List<PropStrength__Payment_Plan__c> ppList) {
        for(PropStrength__Payment_Plan__c pp : ppList) {
            if(pp.Check_Valid_Till__c == null && pp.PropStrength__Active__c) {
                pp.Check_Valid_Till__c = System.Today();
            }
        }
    }
}