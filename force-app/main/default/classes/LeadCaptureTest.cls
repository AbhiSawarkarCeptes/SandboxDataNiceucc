@isTest
public class LeadCaptureTest {
    @isTest
    static void testLeadCaptEventDateValidation() {
        // Create test Channel Partner record
        Channel_Partner__c testChannelPartner = new Channel_Partner__c(
            Name = 'Test Channel Partner'
        );
        insert testChannelPartner;
        
        // Create test Event__c record with a Channel Partner
        Events__c testEventWithChannelPartner = new Events__c(
            Name = 'Test Event with Channel Partner',
            Date_Of_Event__c = Date.today().addDays(2),
            End_Date_Of_Event__c = Date.today().addDays(3),
            Channel_Partner__c = testChannelPartner.Id,
         //   City_Country__c = 'Test City, Test Country',
            sales_manager__c = UserInfo.getUserId()
        );
        insert testEventWithChannelPartner;
        
        Events__c thisEvents = [SELECT id,Campaign_Code__c from Events__c LIMIT 1];
        String campaignCodeDynamic = thisEvents.Campaign_Code__c;
        
        // Create test Lead_Capture__c record related to the test Event with Channel Partner
		List<Lead_Capture__C> testLeadCaptures = new List<Lead_Capture__c>();
        Lead_Capture__c testLeadCapture = new Lead_Capture__c(
            Name__c = 'Test Lead Capture',
            Mobile_Number__c ='1212121212',
            Campaign_Code__c = '2024-08-31/SINGAPORE/Road Shows/FOOT PRINT REAL ESTATE BROKER',
            Broker_Name__c ='FOOT PRINT REAL ESTATE BROKER'
        );
        testLeadCaptures.add(testLeadCapture);
        
        Lead_Capture__c testLeadCapture1 = new Lead_Capture__c(
            Name__c = 'Test Lead Capture1',
            Mobile_Number__c ='1313131313',
            Campaign_Code__c =  '2024-08-31/SINGAPORE/Road Shows/FOOT PRINT REAL ESTATE BROKER',
            Broker_Name__c ='FOOT PRINT REAL ESTATE BROKER'
        );
        testLeadCaptures.add(testLeadCapture1);
        
        Test.startTest();
        insert testLeadCaptures;
        Test.stopTest();
        
        // Verify that no error was added to the Lead_Capture__c record
        System.assertEquals(1, [SELECT count() FROM Lead_Capture__c WHERE Id = :testLeadCapture.Id AND IsDeleted = false]);
         }
}