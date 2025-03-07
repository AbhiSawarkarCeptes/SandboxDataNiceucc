public class PaymentCompletionCertificateController {
    public PropStrength__Application_Booking__c book {get;set;}
    public String convertedNumber {get;set;}
    
    public PaymentCompletionCertificateController() {
        book = new PropStrength__Application_Booking__c();
        String bookId = ApexPages.currentPage().getParameters().get('id');
        if(bookId != '' && bookId != null) {
            book = [SELECT Id, PCC_Status__c, PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Outstanding_Balance__c, PropStrength__Total_Paid_Percent__c, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.MailingCountry, PropStrength__Primary_Customer__r.MailingState, PropStrength__Primary_Customer__r.MailingCity, PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Customer__r.Email, PropStrength__Property_Name__c, PropStrength__Tower__c, PropStrength__Project__r.Name, PropStrength__Project__r.Master_Project__r.Name, SPA_Execution_Date__c, PropStrength__Total_Payment_Received__c, PropStrength__Revised_Total_Sales_Consideration__c FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
            convertedNumber = NumberToWordsConverter.convertToWords(book.PropStrength__Total_Payment_Received__c);
        }
    }
}