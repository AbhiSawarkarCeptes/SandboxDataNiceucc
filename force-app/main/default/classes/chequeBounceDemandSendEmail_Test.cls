@isTest(seeAllData = true)
private with sharing class chequeBounceDemandSendEmail_Test {
    @isTest
    static void testMethod1(){
        List<Demand__c> dlst = [SELECT id,Booking__c FROM Demand__c WHERE Booking__c <> null ];
        List<id> isldt = new List<id>();
        isldt.add(dlst[0].Booking__c);
        chequeBounceDemandSendEmail.sendEmail(isldt);
        PageReference pageRef = Page.demandCheckBounce;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('demandId', isldt[0]);
        demandCheckController controller = new demandCheckController();
    }    
}