public class ReminderDueNoticeController {
    public PropStrength__Received_Payment__c pay {get;set;}
    public String applicantName {get;set;}
    public String numberInWord {get;set;}
    public Bank_GL__c bankDet {get;set;}
    public String recId;
    
    public ReminderDueNoticeController() {
        recId = ApexPages.currentPage().getParameters().get('id'); 
        pay = new PropStrength__Received_Payment__c();
        if(recId != null && recId != '') {
            pay = [SELECT Id, PropStrength__Balance__c, PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.SPA_Execution_Date__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Completion_Certificate_Date__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry FROM PropStrength__Received_Payment__c WHERE Id = :recId];
            applicantName = [SELECT Id, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c = :pay.PropStrength__Application_Booking__c AND PropStrength__Type__c = '1st Applicant' LIMIT 1].PropStrength__Customer_Name__c;
            bankDet = [SELECT Id, Bank_Account_Type__c, Beneficiary__c, Account_Number__c, IBAN__c, Swift_Code__c, Bank_Name__c FROM Bank_GL__c WHERE Bank_Account_Type__c = 'Escrow Account' AND Project__c = :pay.PropStrength__Application_Booking__r.PropStrength__Project__c];
            numberInWord = NumberToWordsConverter.convertToWords(pay.PropStrength__Balance__c);
        }
    }
}