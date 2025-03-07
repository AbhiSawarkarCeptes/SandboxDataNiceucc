@isTest
public class SendSchemeExpiryMailSchBatch_Test {
    
    @TestSetup
    static void setup() {
        // Creating test users
        User adminUser = TestDataFactorySobha.createUser(null);
        insert adminUser;

        User amitMishra = TestDataFactorySobha.createUser(null);
        amitMishra.LastName = 'Amit Mishra CS';
        insert amitMishra;

        // Creating test Brokerage Scheme
        PropStrength__Brokerage_Scheme__c scheme = new PropStrength__Brokerage_Scheme__c(
            PropStrength__Scheme_Name__c = 'Test Scheme',
            PropStrength__End_Date__c = Date.today().addDays(3)
        );
        insert scheme;
    }

    @isTest
    static void testSendMail() {
        SendSchemeExpiryMailSchBatch scheduler = new SendSchemeExpiryMailSchBatch();
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();
    }
}