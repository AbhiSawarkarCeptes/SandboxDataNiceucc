@isTest
public class UnitRequestHoldLWCControllerTest {
    @testSetup
    static void setup() {
        User usr = TestDataFactorySobha.createUser(NULL);
        
        Account testAccount = new Account(Name = 'Test Account', recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId());
        
        insert testAccount;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        List<PropStrength__Property__c> propList = new List<PropStrength__Property__c>();
        for(Integer i=0; i<5; i++) {
            PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__House_Unit_No__c='test1',Not_for_Sale__c = false,PropStrength__Allotted__c =false,PropStrength__Property_Alloted_Through_Offer__c =false, PropStrength__Property_on_hold_for_Reallocation__c = false, Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
            propList.add(prop);
        }
        insert propList;           
    }
    
    @isTest
    static void testSearchProjectRecord() {
        Test.startTest();
        List<PropStrength__Projects__c> result = UnitRequestHoldLWCController.searchProjectRecord('Test Project');
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0);
        Test.stopTest();
    }
    
    @isTest
    static void testSearchUnit() {
        Test.startTest();
        List<PropStrength__Property__c> result = UnitRequestHoldLWCController.searchUnit('Unit1', [SELECT Id FROM PropStrength__Projects__c LIMIT 1].Id);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void testSearchUnit1() {
        Test.startTest();
        List<PropStrength__Property__c> result = UnitRequestHoldLWCController.searchUnit(null, [SELECT Id FROM PropStrength__Projects__c LIMIT 1].Id);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void testUploadFile() {
        Test.startTest();
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String filename = 'TestFile.txt';
        String recordId = [SELECT Id FROM PropStrength__Property__c LIMIT 1].Id;
        String result = UnitRequestHoldLWCController.uploadFile(base64, filename, recordId);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }

    @isTest
    static void testUpdatePropertyOnHoldValue() {
        Test.startTest();
        PropStrength__Property__c property = [SELECT Id, PropStrength__Property_on_hold_for_Reallocation__c FROM PropStrength__Property__c LIMIT 1];
        property.PropStrength__Property_on_hold_for_Reallocation__c = true;
        update property;

        List<PropStrength__Property__c> propertyList = new List<PropStrength__Property__c> { property };
        UnitRequestHoldLWCController.updatePropertyOnHoldValue(propertyList);
        
        PropStrength__Property__c updatedProperty = [SELECT Id, PropStrength__Property_on_hold_for_Reallocation__c FROM PropStrength__Property__c WHERE Id = :property.Id];
        System.assertEquals(true, updatedProperty.PropStrength__Property_on_hold_for_Reallocation__c);
        Test.stopTest();
    }

    @isTest
    static void testSendMailToHoldRequester() {
        Test.startTest();          
        List<PropStrength__Property__c> property = [SELECT Id,PropStrength__Property_on_hold_for_Reallocation__c,PropStrength__Property_Type__c, Hold_Requester__c FROM PropStrength__Property__c];  
        UnitRequestHoldLWCController.sendMailToHoldRequester(property[0].Id);
        Test.stopTest();
    }

    @isTest
    static void testCreateUnitHoldRecord() {
        Test.startTest();
        String result = UnitRequestHoldLWCController.createUnitHoldRecord('John Doe', '2024-07-30T00:00:00Z', [SELECT Id FROM PropStrength__Property__c LIMIT 1].Id);
        System.assertNotEquals(null, result);
        
        Test.stopTest();
    }
    @isTest
    static void testCreateUnitHoldRecord1() {
        Test.startTest();
         UserRole salesHeadRole = new UserRole(
            Name = 'Sales Head',
            DeveloperName = 'SalesHead'
        );
        insert salesHeadRole;
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
         User salesHead = new User(
            Alias = 'shead',
            Email = 'shead@example.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = salesHeadRole.Id,
            UserName = 'shead@example.com',
            LastName = 'Head',
            FirstName = 'Sales'
        );
        insert salesHead;

        String result = UnitRequestHoldLWCController.createUnitHoldRecord('John Parker', '2024-07-30T00:00:00Z', [SELECT Id FROM PropStrength__Property__c LIMIT 1].Id);
        System.assertNotEquals(null, result);
        Test.stopTest();
    }
}