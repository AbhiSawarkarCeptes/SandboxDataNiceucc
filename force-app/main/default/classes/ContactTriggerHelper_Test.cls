@isTest
public class ContactTriggerHelper_Test {
    @isTest
    static void testMethod1(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Account acc2 = TestDataFactorySobha.createAccount(null);
        insert acc2;
        Country_Code_Master__c codeMaster = new Country_Code_Master__c();
        codeMaster.Country_Name__c = 'India';
        codeMaster.Country_Code__c = '+91';
        codeMaster.Phone_length__c = 13;
        insert codeMaster;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.Country_Code__c = '+91';
        cont.VCC1__Mobile_Encrypted__c = '123454321';
        cont.AccountId =acc.Id;
        cont.VCC1__Phone_Encrypted__c = '9876543210';
        cont.VCC1__Calling_Number_Encrypted__c = '2345677777';
        cont.CLE__Mobile_Encrypted__c = '1234343434';
        cont.CLE__Phone_Encrypted__c = '2345455234';
        cont.Passport_Number__c = '65432123';
        cont.Emirates_ID__c = '784-1234-1234567-1';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        Contact cont2 = TestDataFactorySobha.createContact(null);
        cont2.Birthdate = System.Today();
        cont2.CLE__Phone_Encrypted__c = '2345455234';
        cont2.CLE__Mobile_Encrypted__c = '23432323';
        cont2.Emirates_ID__c = '784-1234-1234567-1';
        cont2.AccountId =acc.Id;
        cont2.VCC1__Calling_Number_Encrypted__c = '2323232323232';
        cont2.Passport_Number__c = '65432123';
        cont2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont2;
        Contact cont3 = TestDataFactorySobha.createContact(null);
        cont3.Birthdate = System.Today();
        cont3.CLE__Phone_Encrypted__c = '2345455234';
        cont3.CLE__Mobile_Encrypted__c = '23432323';
        cont3.Emirates_ID__c = '784-1234-1214237-1';
        cont3.AccountId =acc.Id;
        cont3.VCC1__Calling_Number_Encrypted__c = '2323232323232';
        cont3.Passport_Number__c = '65432123';
        cont3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont3;
        
        cont.LastName = 'testCont';
        cont.Emirates_ID__c = '784-1234-1214237-1';
        Update cont;
        
        List<Contact> conList = new List<Contact>();
        conList.add(cont);
        cont2.AccountId = acc2.Id;
        conList.add(cont2);
        cont3.AccountId = acc2.Id;
        conList.add(cont3);

        ContactTriggerHelper.updateNameEmailAddress(conList);
    }
}