@isTest
public class unitTransferTest {

    @isTest
    public static void testUnitTransfer() {
        Account acc = new Account(Name='test acc');
        insert acc;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        objOpportunity.Secondary_Sales_Manager__c = UserInfo.getUserId();
        insert objOpportunity;
        
        Test.startTest();
        PageReference pRef = Page.unitTransfer;
        Test.setCurrentPage(pRef);   
        
        ApexPages.currentPage().getParameters().put('oppId', objOpportunity.id);
        unitTransfer uTransfer = new unitTransfer();
        unitTransfer.dummyMethod();

        Test.stoptest();
    }
}