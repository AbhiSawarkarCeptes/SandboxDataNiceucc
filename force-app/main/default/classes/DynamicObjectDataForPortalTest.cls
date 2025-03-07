@isTest 
public class DynamicObjectDataForPortalTest {
    @isTest
    static void testGetRecords() {
        BR_Document_History__c brd= new BR_Document_History__c();
        brd.Expiry_date__c=Date.Today().addDays(-2);
        brd.File_Name__c='TestFile.pdf';
        brd.File_Type__c='RERA Certificate';
        insert brd;
        DynamicObjectDataForPortalLWCController.getContactInfo();
        DynamicObjectDataForPortalLWCController.getRecords('BR_Document_History__c','File_Name__c','File_Name__c!=null');
        DynamicObjectDataForPortalLWCController.getLabels('BR_Document_History__c','File_Name__c');
        DynamicObjectDataForPortalLWCController.getContactsDataCount();
    }
}