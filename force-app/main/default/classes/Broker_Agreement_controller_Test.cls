@isTest
public class Broker_Agreement_controller_Test {
	@isTest
    public static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null); 
        acc.Email_ID_1__c = 'Test@Test.com';
        insert acc;
        PageReference pRef = Page.Broker_Agreement;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        Broker_Agreement_controller bac = new Broker_Agreement_controller();
        PageReference p = bac.backToRecPage();
        PageReference p2 = bac.saveDocFile();
        PageReference p3 = bac.saveAndEmail();
    }
    @isTest
    public static void testMethodElseCover() {
        PageReference pRef = Page.Broker_Agreement;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id','');
        Broker_Agreement_controller bac = new Broker_Agreement_controller();
        PageReference p = bac.backToRecPage();
        PageReference p2 = bac.saveDocFile();
    }
}