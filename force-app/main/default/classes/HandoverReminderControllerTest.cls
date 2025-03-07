@isTest
private class HandoverReminderControllerTest {

    @isTest
    static void testHandoverReminderController() {
        // Test data setup
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');

        // Set the current page parameters to simulate navigating to the page with the opportunity ID
        ApexPages.currentPage().getParameters().put('id', oppId);

        // Test the HandoverReminderController constructor
        Test.startTest();
        HandoverReminderController controller = new HandoverReminderController();
        Test.stopTest();


    }
}