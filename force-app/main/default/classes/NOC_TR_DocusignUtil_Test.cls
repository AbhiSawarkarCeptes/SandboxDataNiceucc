@isTest
public class NOC_TR_DocusignUtil_Test {
	@testSetup
    static void setup(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
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
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);
        insert transReq;
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
    }
    
    @isTest
    static void testGetTransactionRequest(){
        PropStrength__Transaction_Requests__c transactionRequest= [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        PropStrength__Transaction_Requests__c result = NOC_TR_DocusignUtil.getTransactionRequest(transactionRequest.Id);
    }
    
    @isTest
    static void testGetFileId(){
        PropStrength__Transaction_Requests__c transactionRequest= [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'NOC Document',
            PathOnClient = 'noc_document.pdf',
            VersionData = Blob.valueOf('Test Document Content'),
            ContentLocation = 'S'
        );
        insert contentVersion;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = transactionRequest.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        
		Id documentId = NOC_TR_DocusignUtil.getFileId(transactionRequest.Id);
    }
    
    @isTest
    static void testDocusignPostProcessing(){
        
        PropStrength__Transaction_Requests__c tr= [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        
        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            dfsle__DocuSignId__c = 'abcdef1234567890',
            Envelope_Type__c = 'NOC TR',
            dfsle__Status__c = 'voided'
        );
        insert envelopeStatus;
        
        dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c(
            dfsle__Email__c = 'recipient@test.com',
            dfsle__RoutingOrder__c = 1,
            dfsle__EnvelopeStatus__c = envelopeStatus.Id,
            Envelope_Type__c = 'NOC TR'
        );
        insert recipientStatus;
        
        Map<String, String> emailToRoleMap = new Map<String, String>{
            'recipient@test.com_1' => ''
        };
            
        Test.startTest();
        	NOC_TR_DocusignUtil.docusignPostProcessing('abcdef1234567890', tr.Id, null, emailToRoleMap);
        Test.stopTest();
        
        /*dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(dfsle__DocuSignId__c = 'envelope_123');
        insert envelopeStatus;
        dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c(
            dfsle__EnvelopeStatus__c = envelopeStatus.Id,
            dfsle__Email__c = 'sushil@cloudsteer.com',
            dfsle__RoutingOrder__c = 1
        );
        insert recipientStatus;
        dfsle__RecipientStatus__c email = [SELECT Id, dfsle__Email__c, dfsle__RoutingOrder__c, Envelope_Recipient_Type__c FROM dfsle__RecipientStatus__c WHERE dfsle__EnvelopeStatus__c = :envelopeStatus.Id LIMIT 1];
        PropStrength__Transaction_Requests__c tr= [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        PropStrength__Transaction_Requests__c transactionRequest= [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        Map<String, String> emailToRoleMap = new Map<String, String>{
            email.dfsle__Email__c => email.Envelope_Recipient_Type__c
        };
        NOC_TR_DocusignUtil.docusignPostProcessing(envelopeStatus.Id, transactionRequest.Id, null, emailToRoleMap);*/
    }
    
    @isTest
    static void testDocusignDocumentControllerEmailBody(){
        String docControllerEmailBody = NOC_TR_DocusignUtil.docusignDocumentControllerEmailBody();
    }
    
    @isTest
    static void testDocusignSellerEmailBody(){
        String docusignSellerEmailBody = NOC_TR_DocusignUtil.docusignSellerEmailBody();
    }
    
    @isTest
    static void testValidateAndUpdatePhoneNumber(){
        String phoneNumber = NOC_TR_DocusignUtil.validateAndUpdatePhoneNumber('9000123545');
    }
    
    @isTest
    static void testGetAuditBody(){
        String auditBody = NOC_TR_DocusignUtil.getAuditBody('bookingName', 'unitName');
    }
    
    @isTest
    static void testDocusignBuyerEmailBody(){
        String docusignBuyerEmailBody = NOC_TR_DocusignUtil.docusignBuyerEmailBody();
    }
    
    @isTest
    static void testDocusignAuthEmailBody(){
        String docusignAuthEmailBody = NOC_TR_DocusignUtil.docusignAuthEmailBody();
    }
}