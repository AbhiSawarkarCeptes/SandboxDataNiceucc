@istest
public class LookupSearchComponentControllerTest {
	@isTest
    private static void getResultTest(){
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
       //.Booking__c = b.Id;
        //Customers__c = opp.Id;
        u.Unit_Status__c='Available';
        update u;
        
        LookupSearchComponentController.getResults('Unit__c', 'Unit_Status__c','Available');
        LookupSearchComponentController.getRecord(u.id,'Unit_Status__c','Unit__c');
    }
}