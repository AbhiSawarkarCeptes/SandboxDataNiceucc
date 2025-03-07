@isTest
public class NOCTitleDeedDownloadCnt_Test {
    
    @isTest static void saveAttTest(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        insert con;

        PropStrength__Assignment_Group_Name__c assgmtGroup = TestDataFactorySobha.createAssignmentGroup(null);
        insert assgmtGroup;

        PropStrength__Request__c request = TestDataFactorySobha.createEnquiry(null);
        insert request;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;

        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;

        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;
        
        PropStrength__Transaction_Requests__c transRequest = TestDataFactorySobha.createTransactionRequest(null);
        transRequest.PropStrength__Status__c = 'SPA/DSPA Sent to New Customer';
        insert transRequest;
        
        PageReference pageRef = Page.NOCTitleDeedDownload;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', transRequest.Id);
        ApexPages.currentPage().getParameters().put('frmLgtng', 'true');
    
        Test.startTest();
        NOCTitleDeedDownloadCnt nocObj = new NOCTitleDeedDownloadCnt();
        nocObj.saveAtt();
        Test.stopTest();
    }
}