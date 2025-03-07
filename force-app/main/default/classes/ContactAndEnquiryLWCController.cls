public class ContactAndEnquiryLWCController {
    
    @AuraEnabled
    public static String createContact(Contact contactData, PropStrength__Request__c enqData) {
        try {
            Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            Id RecordTypeIdContact1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Id guestUserId = UserInfo.getUserId();
            system.debug('contactData.LastName::'+contactData.LastName+'****'+contactData.Phone);
            if(!String.isBlank(contactData.LastName) && 
               !String.isBlank(contactData.Phone) &&
               !String.isBlank(contactData.Email) && !String.isBlank(contactData.Description)) {
                List<Contact> contactList = new List<Contact>();
                if(!String.isBlank(contactData.Phone)) {
                    contactList = [SELECT Id,Phone,Email, Name FROM Contact WHERE (Phone =: contactData.Phone OR Email =: contactData.Email )AND RecordTypeId != :RecordTypeIdContact1];
                    System.debug('--------->' + contactList);
                }
                if(!contactList.isEmpty()) {
                    PropStrength__Request__c oneEnquiry = new PropStrength__Request__c();
                    oneEnquiry.PropStrength__Primary_Contact__c = contactList[0].Id;
                    oneEnquiry.Type_Of_Enquiry__c = enqData.Type_Of_Enquiry__c;
                    oneEnquiry.PropStrength__Request_Source__c = enqData.PropStrength__Request_Source__c;
                    oneEnquiry.PropStrength__Request_Status__c = 'Open';
                    oneEnquiry.Prefered_LAnguage__c = enqData.Prefered_LAnguage__c;
                    oneEnquiry.Sales_Manager__c = UserInfo.getUserId();
                    oneEnquiry.Enquiry_Created_From_Form__c = true;
                    if(enqData.Type_Of_Enquiry__c == 'Indirect') {
                        oneEnquiry.PropStrength__Broker_Account__c = enqData.PropStrength__Broker_Account__c;
                        oneEnquiry.PropStrength__Broker_Contact__c = enqData.PropStrength__Broker_Contact__c;
                    }
                    insert oneEnquiry;
                    return 'Your enquiry for Contact: '+contactList[0].Name +' has been successfully submitted and our team will respond to you as soon as possible.';
                } else {
                    Contact newContact = new Contact();
                    newContact.RecordTypeId = RecordTypeIdContact;
                    newContact.FirstName = contactData.FirstName;
                    newContact.LastName = contactData.LastName;
                    newContact.Email = contactData.Email;
                    newContact.Phone = contactData.Phone;
                    newContact.Description = contactData.Description;
                    newContact.Country_Code__c = contactData.Country_Code__c;
                    newContact.MobilePhone = contactData.Phone;
                    insert newContact;                    
                    System.debug(newContact.Id);
                    System.debug(newContact.OwnerId);
                    System.debug(enqData);
					String enqId =  ContactAndEnquiryLWCController.queryContact(newContact.Id, enqData.Prefered_LAnguage__c, enqData.Type_Of_Enquiry__c, enqData.PropStrength__Request_Source__c, enqData.PropStrength__Broker_Account__c, enqData.PropStrength__Broker_Contact__c);    
                    if(enqId != null && enqId != '') {
                        return 'Your enquiry for Contact: '+newContact.FirstName +' '+newContact.LastName +' has been successfully submitted and our team will respond to you as soon as possible.';
                    }
                }
            }
            return 'Error';
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating contact: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String queryContact(String contId, String lang, String enqtype, String src, String accId, String contactId) {
        if(contId != null) {
            PropStrength__Request__c oneEnquiry = new PropStrength__Request__c();
            oneEnquiry.PropStrength__Primary_Contact__c = contId;
            oneEnquiry.Type_Of_Enquiry__c = enqtype;
            oneEnquiry.PropStrength__Request_Source__c = src;
            oneEnquiry.PropStrength__Request_Status__c = 'Open';
            oneEnquiry.Prefered_LAnguage__c = lang;
            oneEnquiry.Enquiry_Created_From_Form__c = true;
            oneEnquiry.Sales_Manager__c = UserInfo.getUserId();
            if(enqtype == 'Indirect') {
                oneEnquiry.PropStrength__Broker_Account__c = accId;
                oneEnquiry.PropStrength__Broker_Contact__c = contactId;
            }
            insert oneEnquiry;
            return  oneEnquiry.Id;
        }
        return null;
    }
    @AuraEnabled
    public static List<Account> searchBrokerAccount(String searchKeyWrd){
        if(searchKeyWrd != '') {
            searchKeyWrd = '%' + searchKeyWrd + '%';
            return [SELECT Id,Name, RecordTypeId, RecordType.Name,PropStrength__Active__c FROM Account WHERE RecordType.Name = 'Broker' AND PropStrength__Active__c = 'Yes' AND Name LIKE :searchKeyWrd ORDER BY Name ASC];
        } else {
            return [SELECT Id,Name, RecordTypeId, RecordType.Name,PropStrength__Active__c, LastModifiedDate FROM Account WHERE RecordType.Name = 'Broker' AND PropStrength__Active__c = 'Yes' ORDER BY LastModifiedDate DESC LIMIT 100];
        }
    }
    @AuraEnabled
    public static List<Contact> searchBrokerContact(String searchKeyWrd, String accId){
        if(searchKeyWrd != '') {
            searchKeyWrd = '%' + searchKeyWrd + '%';
            return [SELECT Id,Name, RecordTypeId, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Broker' AND AccountId =: accId AND Name LIKE :searchKeyWrd ORDER BY Name ASC];
        } else {
            return [SELECT Id,Name, RecordTypeId, RecordType.Name, LastModifiedDate, AccountId FROM Contact WHERE RecordType.Name = 'Broker' AND AccountId =: accId ORDER BY LastModifiedDate DESC LIMIT 100];
        }
    }
}