@isTest
public class TransferLetterButtonController_Test {
     @TestSetup static void setup(){
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        PropStrength__Transaction_Requests__c trRec = TestDataFactorySobha.createTransactionRequest(null);
        trRec.PropStrength__Customer_Transfer_Type__c = 'No Title Transfer';
        trRec.PropStrength__Status__c = 'Assignment: Update Applicants & Verify Applicants';
        insert trRec;
        
         Attachment attachment = new Attachment();
        attachment.ParentId = trRec.Id;
        attachment.Name = 'Transfer Letter.pdf';
        attachment.Body = Blob.valueOf('Test');
        insert attachment;
        
         Attachment attachment2 = new Attachment();
        attachment2.ParentId = trRec.Id;
        attachment2.Name = 'Transfer & Assignment Agreement.pdf';
        attachment2.Body = Blob.valueOf('Test');
        insert attachment2;
     }
     
    @isTest
    Public  static void TransferLetterButtonControllerTest(){
        List<PropStrength__Transaction_Requests__c> trList = [SELECT Id FROM PropStrength__Transaction_Requests__c];
        ApexPages.currentPage().getParameters().put('id' ,trList[0].id);
        Test.startTest();
        TransferLetterButtonController tranfBtnCntrl = new TransferLetterButtonController();
        tranfBtnCntrl.docancel();
        tranfBtnCntrl.savepdf();
        Test.stopTest();
     }
     
      @isTest
    Public  static void TransferLetterButtonControllerTest2(){
        List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Customer_Transfer_Type__c FROM PropStrength__Transaction_Requests__c];
        Test.startTest();
        trList[0].PropStrength__Customer_Transfer_Type__c = 'Title Transfer';
        UPDATE trList;
        ApexPages.currentPage().getParameters().put('id' ,trList[0].id);
        TransferLetterButtonController tranfBtnCntrl = new TransferLetterButtonController();
        tranfBtnCntrl.savepdf();
        Test.stopTest();
     }
}