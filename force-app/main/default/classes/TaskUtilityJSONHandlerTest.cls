@isTest
public class TaskUtilityJSONHandlerTest {
    
    @isTest
    static void testPublishEvent() {
        // Test positive scenario
        String testJsonString = '{"Task_Id": "12345", "UserId": "005123456789012345", "Event_Type": "TestEvent"}';
        
        Test.startTest();
        try {
            TaskUtilityJSONHandler.publishEvent(testJsonString);
            System.assert(true, 'Event published successfully');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        // Test invalid JSON scenario
        try {
            TaskUtilityJSONHandler.publishEvent('{"invalid": "json"');
            System.assert(false, 'Expected JSONException for invalid JSON');
        } catch (AuraHandledException e) {
            System.assert(true, 'Caught expected exception');
        }


        // Test negative scenario (empty JSON string)
        try {
            TaskUtilityJSONHandler.publishEvent('');
            System.assert(false, 'Expected AuraHandledException for empty JSON string');
        } catch (AuraHandledException e) {
            System.assertEquals('no json found', e.getMessage());
        }
        
        // Test negative scenario (null JSON string)
        try {
            TaskUtilityJSONHandler.publishEvent(null);
            System.assert(false, 'Expected AuraHandledException for null JSON string');
        } catch (AuraHandledException e) {
            System.assertEquals('no json found', e.getMessage());
        }
    }
    
    @isTest
    static void testGetDependentPicklistValues() {
        // Test positive scenario
        String dependentFieldL2 = 'Call_Disposition_L2__c';
        String dependentFieldL3 = 'Call_Disposition_L3__c';
        
        Test.startTest();
        Map<String, Map<String, List<String>>> result = TaskUtilityJSONHandler.getDependentPicklistValues(dependentFieldL2, dependentFieldL3);
        Test.stopTest();
        
        System.assertNotEquals(result, null);
        System.assert(result.containsKey('L1toL2'));
        System.assert(result.containsKey('L2toL3'));
        
        // Test negative scenario (invalid field names)
        try {
            TaskUtilityJSONHandler.getDependentPicklistValues('InvalidField', 'AnotherInvalidField');
            System.assert(false, 'Expected exception for invalid field names');
        } catch (Exception e) {
            System.assert(true, 'Exception thrown as expected');
        }
    }
    
    @isTest
    static void testGetCRMDependentPicklistValues() {
        // Test positive scenario
        String dependentFieldL2 = 'CRM_Call_Disposition2__c';
        String dependentFieldL3 = 'CRM_Call_Disposition3__c';
        
        Test.startTest();
        Map<String, Map<String, List<String>>> result = TaskUtilityJSONHandler.getCRMDependentPicklistValues(dependentFieldL2, dependentFieldL3);
        Test.stopTest();
        
        System.assertNotEquals(result, null);
        System.assert(result.containsKey('L1toL2'));
        System.assert(result.containsKey('L2toL3'));
    }
    
    @isTest
    static void testUpdateTask() {
        // Create a test Task record
        Task__c testTask = new Task__c(
            Call_Disposition_L1__c = 'Dues collection',
            Call_Disposition_L2__c = 'PCC',
            Call_Disposition_L3__c = '100% payments shortfall',
            Calling_Id__c = '12345'
        );
        insert testTask;
        
        // Mock the web service callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test positive scenario
        Test.startTest();
        String result = TaskUtilityJSONHandler.updateTask(
            testTask.Id, 
            'Dues collection', 
            'PCC', 
            '100% payments shortfall',
            'CRM_Dues collection',
            'CRM_PCC',
            'CRM_100% payments shortfall'
        );
        Test.stopTest();
        
        System.assertNotEquals(result, null);
        System.assert(result.contains('Task updated successfully'));
        
        // Test negative scenario (missing Call_Disposition_L1 value)
        try {
            TaskUtilityJSONHandler.updateTask(testTask.Id, '', 'PCC', '100% payments shortfall', '', '', '');
            System.assert(false, 'Expected AuraHandledException for missing L1 disposition');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating Task'));
        }
        
        // Test negative scenario (invalid task ID)
        try {
            TaskUtilityJSONHandler.updateTask('invalidId', 'Dues collection', 'PCC', '100% payments shortfall', '', '', '');
            System.assert(false, 'Expected AuraHandledException for invalid task ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating Task'));
        }
    }

    @isTest
    static void testGetTagId() {
        // Test positive scenario
        String tagId = TaskUtilityJSONHandler.getTagId(
            'Dues collection', 
            'PCC', 
            '100% payments shortfall',
            'CRM_Dues collection',
            'CRM_PCC',
            'CRM_100% payments shortfall'
        );
        System.assertNotEquals(tagId, null);

        // Test negative scenario (no matching metadata record)
        String tagIdNoMatch = TaskUtilityJSONHandler.getTagId(
            'Nonexistent Disposition', 
            'Disposition 2', 
            'Disposition 3',
            'CRM_Nonexistent',
            'CRM_Disposition2',
            'CRM_Disposition3'
        );
        System.assertEquals(tagIdNoMatch, null);
    }
}

@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(200);
        return res;
    }
}
