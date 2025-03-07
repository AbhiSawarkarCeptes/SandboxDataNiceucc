@isTest
public class RequestUnitHoldControllerTest {

    @testSetup
    static void testSetup() {
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha Realty'); 
    }
    
    @isTest
    public static void testSaveAttachments() {
        List<Unit__c> unitList = [SELECT Id from Unit__c LIMIT 2];
        Unit__c unit1 = unitList[0];
        
        Lead thisLead = new Lead();
        thisLead.lastname='Test1';
        thisLead.MobilePhone = '01234567891';
        thisLead.Phone = '01234567891';
        insert thisLead;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'UnitHold.pdf',
            VersionData = Blob.valueOf('TestAgreement'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;
        
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            linkedEntityId = thisLead.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        
        Test.startTest();
        RequestUnitHoldController.saveAttachements(unit1.Id, new List<Id>{testContentDocumentLink.ContentDocumentId});
        Test.stopTest();
    }
    
    @isTest
    public static void testUnitValidation() {
        Unit__c thisUnit = [SELECT Id from Unit__c LIMIT 1];
        Test.startTest();
        RequestUnitHoldController.validateUnitAvailablity(thisUnit.Id);
        Test.stopTest();
    }
}