/*********************************************************************
 * Class Name  :   RefundDashboardLWCController
 * Description :   Helper Class of RefundDashboardLWC (LWC Component)
 * Created Date:   05/06/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 05/06/2024
 *********************************************************************/
public class RefundDashboardLWCController {
    @AuraEnabled
    public static list<PropStrength__Projects__c> getProjects(){
        return [select Id, Name, (select Id, PropStrength__Tower_Name__c from PropStrength__Towers__r Order By Name ASC) from PropStrength__Projects__c Order By Name ASC];
    }
}