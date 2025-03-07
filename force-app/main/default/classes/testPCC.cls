@isTest(seeAllData = true)
private with sharing class testPCC {
    @isTest
    static void testMethod1(){
        List<Booking__c> dlst = [SELECT id FROM Booking__c ];
        List<id> isldt = new List<id>();
        isldt.add(dlst[0].id);
       PageReference pageRef = Page.PCCVFPAGE;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('bookingId', isldt[0]);
        PCC controller = new PCC();
    }    
}