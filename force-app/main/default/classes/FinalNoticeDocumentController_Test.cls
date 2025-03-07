@isTest
public class FinalNoticeDocumentController_Test {
    @isTest
    Public  static void getFinalTest(){
       	Test.startTest();      
        PageReference pRef = Page.FinalNoticeDocument;
        Test.setcurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('id', '123456');
        FinalNoticeDocumentController sr = new FinalNoticeDocumentController();
        Test.stopTest();
    }
}