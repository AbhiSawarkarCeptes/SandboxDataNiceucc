@isTest
public class DeleteOldBrokerRegistrationsTest {

    @testSetup
    static void setup() {
        // Create test records
        List<Broker_Registration__c> registrations = new List<Broker_Registration__c>();
        DateTime now = DateTime.now();
       	Id BrokerRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
      

        for (Integer i = 0; i < 10; i++) {
            Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = NULL,
                recordTypeId = BrokerRecordTypeId,
           
            Broker_Category__c = 'Broker - RERA'
        );
        registrations.add( testBrokerRegistration);
        }

        insert registrations;
    }

   
    @isTest
    static void testSchedulableClass() {
       
        Test.startTest();
        
           String sch = '0 0 23 * * ?';
        System.schedule('TestDeleteOldBrokerRegistrationsJob',sch,new ScheduleDeleteOldBrokerRegistrations());

      
        List<Broker_Registration__c> remainingRecords = [SELECT Id FROM Broker_Registration__c ];
         system.debug('remainingRecords:'+remainingRecords);
      // System.assertEquals(0, remainingRecords.size(), 'Expected 0 records to remain');

        Test.stopTest();

      

        // Verify that records with blank Registration_Number__c are deleted
       
    }
}