@isTest
public class ContactAndEnquiryLWCController_Test {
    @isTest
    static void testContactAndEnquiryLWCControllerCase1() {
        Account acc = new Account(Name = 'Dummy Account');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        PropStrength__Request__c request = new PropStrength__Request__c();
        request.PropStrength__Request_Status__c = 'Open';
        request.Prefered_LAnguage__c = 'Arabic';
        
        Contact testContact1 = new Contact();
        testContact1.FirstName = 'John';
        testContact1.LastName = 'Doe';
        testContact1.Email = 'test@example.com';
        testContact1.Phone = '1234567890';
        testContact1.Description = 'Test description';
        insert testContact1;
    
        Test.startTest();
        ContactAndEnquiryLWCController.createContact(testContact1 , request);
        Test.stopTest();
        
        /*Contact testContact = new Contact();
        testContact.FirstName = 'John1';
        testContact.LastName = 'Doe1';
        testContact.Email = 'test1@example.com';
        testContact.Phone = '1234167890';
        testContact.Description = 'Test description1';
        insert testContact;*/
    
        //List<Contact> conList = [SELECT ID , FirstName , LastName , Email ,Phone , Description FROM Contact WHERE Email =: testContact.Email ];
        //conList.add(testContact1);
        //conList.add(testContact);
        //ContactAndEnquiryLWCController.createContact(testContact);

        
        Integer contactCount = [SELECT COUNT() FROM Contact WHERE FirstName = 'John' AND LastName = 'Doe'];
        System.assertEquals(1, contactCount, 'A new contact should be created.');

    }
    @isTest
    static void testContactAndEnquiryLWCControllerCase2() {
        Account acc = new Account(Name = 'Dummy Account');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        PropStrength__Request__c request = new PropStrength__Request__c();
        request.PropStrength__Request_Status__c = 'Open';
        request.Prefered_LAnguage__c = 'Arabic';
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Alex';
        testContact.LastName = 'Kor';
        testContact.Email = 'Kor123@gmail.com';
        testContact.Phone = '12345890';
        testContact.Description = 'Test Description for Kor';
        //insert testContact;
        
        Test.startTest();
        ContactAndEnquiryLWCController.createContact(testContact , request);
        Test.stopTest();
        List<Account> accList = ContactAndEnquiryLWCController.searchBrokerAccount('');
        List<Account> accList2 = ContactAndEnquiryLWCController.searchBrokerAccount('Dum');
        List<Contact> conList = ContactAndEnquiryLWCController.searchBrokerContact('', acc.Id);
        List<Contact> conList2 = ContactAndEnquiryLWCController.searchBrokerContact('D', acc.Id);
        /*Contact testContact = new Contact();
        testContact.FirstName = 'John1';
        testContact.LastName = 'Doe1';
        testContact.Email = 'test1@example.com';
        testContact.Phone = '1234167890';
        testContact.Description = 'Test description1';
        insert testContact;*/
    }
}