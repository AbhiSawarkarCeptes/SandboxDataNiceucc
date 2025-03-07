@isTest
public class GenerateCpScIdControllerTest {

    @IsTest
    static void testGenerate1() {
        Broker_Registration__c existingRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Broker_Created_Date__c = system.today(),
            Agreement_Created_Sent_Date__c = system.today()
        );
        insert existingRecord;

        GenerateCpScIdController.generate(existingRecord.Id);
    }

    @IsTest
    static void testGenerate2() {
        Broker_Registration__c existingRecord = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Sobha Connect - Intnl - Company',
            Broker_Created_Date__c = system.today(),
            Agreement_Created_Sent_Date__c = system.today()
        );
        insert existingRecord;

        GenerateCpScIdController.generate(existingRecord.Id);
    }
}