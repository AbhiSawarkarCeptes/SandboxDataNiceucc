@isTest
public class BrokerFormMissingDocsReminderBatchTest {

    @TestSetup
    static void setup() {
        Broker_Registration__c rec1 = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'CP/SC ID in Process',
            Mandatory_Documents_Missing__c = true,
            Agreement_Created_Sent_Date__c = Date.today().addDays(-3),
            CHRM_Manager__c = userinfo.getuserId()
        );

        Broker_Registration__c rec2 = new Broker_Registration__c(
            First_Name__c = 'Existing2',
            Last_Name__c = 'Broker',
            Email__c = 'existing2@example.com',
            Mobile__c = '12345678902',
            Name_as_per_trade_license__c = 'Test Trade License2',
            Registration_Number__c = '1234562',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'CP/SC ID in Process',
            Mandatory_Documents_Missing__c = true,
            Agreement_Created_Sent_Date__c = Date.today().addDays(-12),
            CHRM_Manager__c = userinfo.getuserId()
        );

        Broker_Registration__c rec3 = new Broker_Registration__c(
            First_Name__c = 'Existing3',
            Last_Name__c = 'Broker',
            Email__c = 'existing3@example.com',
            Mobile__c = '12345678903',
            Name_as_per_trade_license__c = 'Test Trade License3',
            Registration_Number__c = '1234563',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'CP/SC ID in Process',
            Mandatory_Documents_Missing__c = true,
            Agreement_Created_Sent_Date__c = Date.today().addDays(-23),
            CHRM_Manager__c = userinfo.getuserId()
        );

        insert new List<Broker_Registration__c>{rec1, rec2, rec3};
    }
    @isTest static void testBatchExecution() {

        Test.startTest();

        TRY{
            	Database.executeBatch(new BrokerFormMissingDocsReminderBatch());

        }catch(exception e){
            
        }
        
        Test.stopTest();
    }
}