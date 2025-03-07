@isTest
public class RecordVisitVfController_isTest {
    @IsTest
    static void onLoad(){
        
        Test.startTest();
        Account acc = new Account(Name='test acc');
        insert acc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        RecordVisitVfController testAccPlan = new RecordVisitVfController(sc);
        
        PageReference pageRef = Page.RecordVisitAccount;
        pageRef.getParameters().put('id', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.onload();
        Record_Visit__c rv = [Select id from Record_Visit__c];
        system.assertNotEquals(null, rv);
        Test.stopTest();
        
    }
}