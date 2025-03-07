@isTest
private class CsoAnnouncementBoard_Test {
     @testSetup
    static void setupTestData() {
         CSO_Announcment__c record1 = new CSO_Announcment__c(
           // Name = 'Sample Record 1',
            Title__c = 'Sample Title 1',
            Active__c = false,
            Valid_Till__c = Date.today().addDays(10), 
            Notification__c = 'Sample Notification 1'
        );
        insert record1;
        
         CSO_Announcment__c record2 = new CSO_Announcment__c(
            //Name = 'Sample Record 2',
            Title__c = 'Sample Title 2',
            Active__c = false,
            Valid_Till__c = Date.today().addDays(10), 
            Notification__c = 'Sample Notification 2'
        );
        insert record2;

 List<CSOs_General_Instructions__c> instructionsToInsert = new List<CSOs_General_Instructions__c>();

        // Sample data records
        instructionsToInsert.add(new CSOs_General_Instructions__c(
            Instruction__c = 'Sample Instruction 1',
            Sequence__c = 1,
            Active__c = false
        ));
        instructionsToInsert.add(new CSOs_General_Instructions__c(
            Instruction__c = 'Sample Instruction 2',
            Sequence__c = 2,
            Active__c = false
        ));
        insert instructionsToInsert;
    }

    @isTest
    static void test_getAllActiveAnnouncements() {
        CsoAnnouncementBoard.getAllActiveAnnouncements(2);
    }
    
    @isTest
    static void test_getGeneralInstructions() {
        CsoAnnouncementBoard.getGeneralInstructions();
    }
}