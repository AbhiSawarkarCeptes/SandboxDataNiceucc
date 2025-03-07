public class TerminationDashboardLwcController {
    @AuraEnabled
    public static list<PropStrength__Projects__c> getProjects(){
        return [select Id, Name, (select Id, PropStrength__Tower_Name__c from PropStrength__Towers__r Order By Name ASC) from PropStrength__Projects__c Order By Name ASC];
    }
}