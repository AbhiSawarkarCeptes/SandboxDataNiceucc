/*********************************************************************
* Class Name  :   EnquiryCreationOnEmail
* Description :   Email Service Class to create enquiry while receving mail from client
* Created Date:   01/06/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 01/06/2023
*********************************************************************/
global class EnquiryCreationOnEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        List<PropStrength__Request__c> enqList = [SELECT Id FROM PropStrength__Request__c WHERE PropStrength__Information_Required__c = :email.subject AND PropStrength__Email_Address__c = :email.fromAddress];
        if(enqList.isEmpty()) {
            List<Contact> contList = [SELECT Id, FirstName, LastName, Email, MailingCity, MailingCountry, MobilePhone FROM Contact WHERE Email = :email.fromAddress AND RecordTypeId != :Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId()];
            Contact cont = new Contact();
            if(!contList.isEmpty()) {
                cont = contList[0];
            } else {
                String fromAdd = email.fromAddress;
                cont = new Contact(LastName = fromAdd.substring(0, fromAdd.indexOf('@')), Email = fromAdd, RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId());
                insert cont;
            }
            
            
            PropStrength__Request__c enquiry = new PropStrength__Request__c(PropStrength__Contact_No__c = cont.MobilePhone, PropStrength__Country__c = cont.MailingCountry, PropStrength__City__c = cont.MailingCity, PropStrength__Email_Address__c = cont.Email, PropStrength__Request_Source__c = 'Direct Mail', PropStrength__First_Name__c = cont.FirstName, PropStrength__Last_Name__c = cont.LastName, PropStrength__Primary_Contact__c = cont.Id, PropStrength__Information_Required__c = email.subject, PropStrength__Enquiry_Subject__c = email.subject);
            insert enquiry;
        }
        return result;
    }
}