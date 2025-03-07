@isTest
public class TowerTriggerHandlerTest {

    @isTest
    static void testSendToMobileAPI() {
        // Create test data
        Tower__c testTower = new Tower__c();
            testTower.Name = 'Test Tower';
            testTower.Under_Construction__c = false;
            testTower.Completion_Percentage__c = 10;
            // Add other required fields
        
        insert testTower;

        Tower__c testTower1 = new Tower__c();
            testTower.Name = 'Test Tower1';
            testTower.Under_Construction__c = true;
            testTower.Completion_Percentage__c = 9;
        testTower1.Id = testTower.Id;
        
        Amenity__c am = new Amenity__c();
        am.Name = 'test';
        am.Amenity_Name__c = 'Test';
        am.Type__c = 'Theatre';
        am.Tower__c = testTower.Id;
        insert am;
        
        Attractions__c att = new Attractions__c();
        att.Name = 'Twst';
        att.Tower__c = testTower.Id;
        insert att;
        

        
        Map<id,Tower__c> oldMap = new Map<id,Tower__c>();
        oldMap.put(testTower1.id,testTower1);
        // Call the future method
        
        Test.startTest();
        TowerTriggerHandler.sendToMobileAPI(JSON.serialize(new List<Tower__C>{ testTower }), JSON.serialize(oldMap));
        TowerTriggerHandler.sendToMobileAPI(JSON.serialize(new List<Tower__C>{ testTower }), null);
        Test.stopTest();

        // Add assertions based on your expected behavior
        // For example, check if the callout was made successfully and the response is as expected
        // assert...

        // Optionally, add more test cases for different scenarios
    }
}