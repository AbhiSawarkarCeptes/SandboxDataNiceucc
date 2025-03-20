/***************************************************************************
Class      : Nice_TaskDispositionHandler
Test Class : Nice_TaskDispositionHandlerTest
Purpose    : NICE - Test class Code coverage 86% 
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
    }

    @isTest
    static void testUpdateTask() {
        Task__c testTask = new Task__c(
            Call_Disposition_L1__c = 'CRM',
            Call_Disposition_L2__c = 'SPA',
            Call_Disposition_L3__c = 'SPA Received',
            Calling_ID__c = '12345'
        );
        insert testTask;
        
        Test.startTest();
        String result = Nice_TaskDispositionHandler.updateTask(
            testTask.Id, 'CRM', 'SPA', 'SPA Received', 'Test comment'
        );
        Test.stopTest();
        
        System.assertNotEquals(result, null, 'The response should not be null');
        System.assert(result.contains('Task updated successfully'), 'Expected success message in response');
        
        try {
            Nice_TaskDispositionHandler.updateTask('nonExistingId', 'CRM', 'SPA', 'SPA Received', 'Test comment');
            System.assert(false, 'Expected exception not thrown for non-existing task');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating Task'), 'Expected specific error message');
        }
    }

    @isTest
    static void testSendTagIdOnTaskUpdate() {
        // Create a request object
        Nice_TaskDispositionHandler.TaskUpdateRequest request = new Nice_TaskDispositionHandler.TaskUpdateRequest();
        request.taskId = '12345';
        request.callingId = '67890';
        request.tagId = 'TAG001';

        // Create a List<TaskUpdateRequest>
        List<Nice_TaskDispositionHandler.TaskUpdateRequest> requestList = new List<Nice_TaskDispositionHandler.TaskUpdateRequest>();
        requestList.add(request);

        Test.startTest();
        List<String> responses = Nice_TaskDispositionHandler.sendTagIdOnTaskUpdate(requestList); // ✅ FIXED - Passing single list
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assert(responses[0] != null && responses[0].contains('Task updated successfully'), 'Expected success response');

        // Test case with missing callingId
        requestList.clear();
        request = new Nice_TaskDispositionHandler.TaskUpdateRequest();
        request.taskId = '12345';
        request.callingId = null; // Missing callingId
        request.tagId = 'TAG001';
        requestList.add(request);

        responses = Nice_TaskDispositionHandler.sendTagIdOnTaskUpdate(requestList); // ✅ FIXED - Single list
        System.assertEquals(1, responses.size());
        System.assertEquals(null, responses[0], 'Expected null response for missing callingId');
    }
}
