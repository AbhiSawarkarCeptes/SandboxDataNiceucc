@isTest
public class GenerateMandateVfControllerTest {

    @isTest static void setup() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Seller_Representative__c = UserInfo.getUserId();
        insert chPartner;
        
        //AddMandateLetterToFiles testAccPlan = new AddMandateLetterToFiles(sc);
        
        PageReference pageRef = Page.AddMandateLetterToFiles;
        pageRef.getParameters().put('Id', String.valueOf(chPartner.Id));
        
         Test.startTest();
        PageReference performaInvoicePage = Page.AddMandateLetterToFiles;
        Test.setCurrentPage(performaInvoicePage);
        ApexPages.currentPage().getParameters().put('id',chPartner.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(chPartner);
        GenerateMandateVfController controller = new GenerateMandateVfController(sc);
        controller.addPDFtoFiles();
        Test.stopTest();
        
    }
}