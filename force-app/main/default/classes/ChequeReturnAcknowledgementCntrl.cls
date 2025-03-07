public class ChequeReturnAcknowledgementCntrl {
    public Interim_Payments__c intRec {get;set;}
    public List<PropStrength__Applicant_Detail__c> appDetail {get;set;}

    public ChequeReturnAcknowledgementCntrl() {
        String interimPayRecId = ApexPages.currentPage().getParameters().get('id');
        intRec = new Interim_Payments__c();
        appDetail = new List<PropStrength__Applicant_Detail__c>();

        if(interimPayRecId != null && interimPayRecId != '') {
            intRec = [SELECT Id, Name, Application_Booking_Interim__c, Application_Booking_Interim__r.House_Unit_No__c, Application_Booking_Interim__r.Project_Name__c, 
                        Cheque_Demand_Draft_Number_Interim__c, Payment_Date_Interim__c, Amount_Interim__c 
                    FROM Interim_Payments__c WHERE Id = :interimPayRecId];

            appDetail = [SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Acc__r.Passport_No__c, PropStrength__Applicant_Acc__r.PropStrength__Nationality__c 
                        FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c = :intRec.Application_Booking_Interim__c AND PropStrength__Active__c = TRUE];
        }
    }
}