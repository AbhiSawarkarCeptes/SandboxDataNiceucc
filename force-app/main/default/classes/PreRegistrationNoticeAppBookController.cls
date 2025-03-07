public class PreRegistrationNoticeAppBookController {
    public PropStrength__Applicant_Detail__c appDet {get;set;}

    public PreRegistrationNoticeAppBookController() {
        String appDetId = '';
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
            appDetId = ApexPages.currentPage().getParameters().get('id');             
            appDet = [SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Address__c, 
                        PropStrength__Applicant_Mobile__c, PropStrength__Applicant_Email__c, PropStrength__Application__r.Project_Name__c, 
                        PropStrength__Application__r.House_Unit_No__c, PropStrength__Application__r.PropStrength__Revised_Agreement_Amount__c, 
                        PropStrength__Application__r.Oqood_Fees_Amount__c 
                        FROM PropStrength__Applicant_Detail__c WHERE Id = :appDetId]; 
        } else {
            appDet = new PropStrength__Applicant_Detail__c();
        }        
    }
}