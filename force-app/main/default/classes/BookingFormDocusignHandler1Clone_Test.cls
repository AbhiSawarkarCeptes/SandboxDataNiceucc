@isTest
public class BookingFormDocusignHandler1Clone_Test {    
    @isTest
    public static void testTestDataFactory() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
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
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true,Send_for_Docusign__c=true,  PropStrength__Application__c = appBook.Id);
        insert appDetail;
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
        TestDataFactorySobha.docusignEnvelopeType = 'Booking Form';
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
        BookingFormDocusignHandler1Clone.sendEnvelopeMethod1(new List<Id>{appBook.Id});
        BookingFormDocusignHandler.sendEnvelopeMethod(new List<Id>{appBook.Id});
        BookingFormDocusignHandlerClone.sendEnvelopeMethod(new List<Id>{appBook.Id});
        //BookingFormDocusignUtil.getApplicants(appBook.Id);
        Test.StopTest();
    }
    
    @isTest
    public static void testTestDataFactory2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
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
        appBook.POA_Name__c = 'Test POA';
        appBook.POA_Email_Address__c = 'test@poa12345.com';
        appBook.POA_Mobile_Number__c = '9632587410';
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
        
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Booking Form';
        des.dfsle__Status__c='Sent';
        des.Application_Booking__c=appBook.Id;
        insert des;
        des.dfsle__DocuSignId__c=des.Id;
        update des;
        
        dfsle__RecipientStatus__c r = new dfsle__RecipientStatus__c();
        r.dfsle__EnvelopeStatus__c = des.Id;
        r.dfsle__Sequence__c = 1;
        r.dfsle__Email__c = 'test@test.com';
        r.dfsle__RoutingOrder__c = 1;
        insert r;
        
        dfsle__RecipientStatus__c drs = [SELECT Id, name, dfsle__EnvelopeStatus__c, dfsle__Sequence__c, dfsle__Email__c, dfsle__RoutingOrder__c FROM dfsle__RecipientStatus__c WHERE Id = :r.Id];
        
        Docusign_Recipient_Status_Sobha__c drsSobha = new Docusign_Recipient_Status_Sobha__c();
        drsSobha.DocuSign_Envelope_Status__c = drs.dfsle__EnvelopeStatus__c;
        drsSobha.DocuSignEnvelope__c = drs.dfsle__EnvelopeStatus__c;
        drsSobha.Name = drs.Name;
        drsSobha.Email__c = drs.dfsle__Email__c;
        drsSobha.Routing_Order__c = drs.dfsle__RoutingOrder__c;
        insert drsSobha;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = appBook.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        BookingFormDocusignHandler.sendEnvelopeMethod(new List<Id>{appBook.Id});
        BookingFormDocusignHandlerClone.sendEnvelopeMethod(new List<Id>{appBook.Id});
        Map<String, String> emailToRoleMap = new Map<String, String>();
        emailToRoleMap.put(r.dfsle__Email__c+'_'+r.dfsle__RoutingOrder__c, 'POA');
        BookingFormDocusignUtilClone.docusignPostProcessing(des.Id, appBook.Id, null, emailToRoleMap, 1);
        //BookingFormDocusignUtil.docusignPostProcessing(des.Id, appBook.Id, null, emailToRoleMap, 1);
        
        Docusign_Recipient_Status_Sobha__c dseSobha = [SELECT Id FROM Docusign_Recipient_Status_Sobha__c LIMIT 1];
        BookingFormDocusignUtilClone.getDocusignRecipientStatusSobha(dseSobha.Id);
        BookingFormDocusignUtilClone.createDocusignRecipientStatusSobhaRecords(new List<dfsle__RecipientStatus__c>{r});
        //BookingFormDocusignUtil.getFileId(appBook.Id);
        //BookingFormDocusignUtil.getDocusignRecipientStatusSobha(dseSobha.Id);
        //BookingFormDocusignUtil.createDocusignRecipientStatusSobhaRecords(new List<dfsle__RecipientStatus__c>{r});
        //BookingFormDocusignUtil.getAuditBody('Test', 'Test 2');
        //BookingFormDocusignUtil.validateAndUpdatePhoneNumber('9658231472');
        Test.StopTest();
    }
}