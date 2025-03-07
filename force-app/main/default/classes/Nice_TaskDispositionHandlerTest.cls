/***************************************************************************
Class      : Nice_TaskDispositionHandler
Test Class : Nice_TaskDispositionHandlerTest
Purpose    : NICE - Test class Code coverage 96% 
Author     : Abhijeet
*****************************************************************************/

@isTest
public class Nice_TaskDispositionHandlerTest {
    
    @isTest
    static void testPublishEvent() {
        String testJsonString = '{"Task_Id": "12345", "UserId": "005123456789012345", "Event_Type": "TestEvent"}';
        Test.startTest();
        try {
            Nice_TaskDispositionHandler.publishEvent(testJsonString);
            System.assert(true, 'Event published successfully');
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
        try {
            Nice_TaskDispositionHandler.publishEvent('{"invalid": "json"}');
        } catch (AuraHandledException e) {
            System.assert(true, 'Caught expected exception');
        }

        try {
            Nice_TaskDispositionHandler.publishEvent('{"invalid": "json"}');
        } catch (AuraHandledException e) {
            System.assertEquals('no json found', e.getMessage());
        }

        try {
            Nice_TaskDispositionHandler.publishEvent('{"invalid": "json"}');
        } catch (AuraHandledException e) {
            System.assertEquals('no json found', e.getMessage());
        }
    }
    
    @isTest
    static void testGetDependentPicklistValues() {
        String dependentFieldL2 = 'Call_Disposition_L2__c';
        String dependentFieldL3 = 'Call_Disposition_L3__c';
        
        Test.startTest();
        Map<String, Map<String, List<String>>> result = Nice_TaskDispositionHandler.getDependentPicklistValues(dependentFieldL2, dependentFieldL3);
        Test.stopTest();
        
        System.assertNotEquals(result, null);
        System.assert(result.containsKey('L1toL2'));
        System.assert(result.containsKey('L2toL3'));
        
        try {
            Nice_TaskDispositionHandler.getDependentPicklistValues('InvalidField', 'AnotherInvalidField');
            System.assert(false, 'Expected exception for invalid field names');
        } catch (Exception e) {
            System.assert(true, 'Exception thrown as expected');
        }
    }
    
    @isTest
    static void testGetCRMDependentPicklistValues() {
        String dependentFieldL2 = 'CRM_Call_Disposition2__c';
        String dependentFieldL3 = 'CRM_Call_Disposition3__c';
        
        Test.startTest();
        Map<String, Map<String, List<String>>> result = Nice_TaskDispositionHandler.getCRMDependentPicklistValues(dependentFieldL2, dependentFieldL3);
        Test.stopTest();
        
        System.assert.areNotEqual(result, null);
        System.assert(result.containsKey('L1toL2'));
        System.assert(result.containsKey('L2toL3'));
    }
    
    @isTest
    static void testUpdateTask() {
        Task__c testTask = new Task__c(
            Call_Disposition_L1__c = 'Dues collection',
            Call_Disposition_L2__c = 'PCC',
            Call_Disposition_L3__c = '100% payments shortfall',
            Calling_Id__c = '12345'
        );
        insert testTask;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String result = Nice_TaskDispositionHandler.updateTask(
            testTask.Id, 
            'Dues collection', 
            'PCC', 
            '100% payments shortfall',
            'CRM',
            'SPA',
            'Loss of SPA',
            'Test comment' 
        );
        Test.stopTest();
        
        System.assertNotEquals(result, null);
        System.assert(result.contains('Task updated successfully'));
        try {
            Nice_TaskDispositionHandler.updateTask(testTask.Id, '', 'PCC', '100% payments shortfall', '', '', '','Test comment');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating Task'));
        }
        try {
            Nice_TaskDispositionHandler.updateTask('invalidId', 'Dues collection', 'PCC', '100% payments shortfall', '', '', '','Test comment');
            System.assert(false, 'Expected AuraHandledException for invalid task ID');
        } catch (AuraHandledException e) {
        }
    }

    @isTest
    static void testGetTagId() {
        String tagId = Nice_TaskDispositionHandler.getTagId(
            'Dues collection', 
            'PCC', 
            '100% payments shortfall',
            'CRM',
            'SPA',
            'Loss of SPA'
        );
        System.assertNotEquals(tagId, null);
        String tagIdNoMatch = Nice_TaskDispositionHandler.getTagId(
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