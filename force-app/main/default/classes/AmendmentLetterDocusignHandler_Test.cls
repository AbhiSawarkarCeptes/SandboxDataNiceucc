@isTest
public class AmendmentLetterDocusignHandler_Test {
	@isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Email_ID_1__c = 'test@12345account.com';
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.MobilePhone = '9632871410';
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
        appBook.SPA_Transaction_Exception__c = true;
        insert appBook;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        TestDataFactorySobha.recordTypeName = 'DSPA Process';
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);
        insert transReq;
        TestDataFactorySobha.docusignEnvelopeType = 'Amendment Letter';
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion2.Id];
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = acc.id;
        cdl2.ContentDocumentId = documents2[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;
        
        Document__c doc = new Document__c();
        doc.Authorized_Signatory_1_Email__c = 'test@123.com';
        doc.Document_Type__c = 'Amendment Letter';
        doc.Application_Booking__c = appBook.Id;
        doc.Authorized_Signatory_2_Email__c = 'test@123.com';
        doc.Authorized_Signatory_3_Email__c = 'test@123.com';
        doc.Authorized_Signatory_4_Email__c = 'test@123.com';
        doc.Authorized_Signatory_5_Email__c = 'test@123.com';
        doc.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByName().get('Seller Representative').getRecordTypeId();
        insert doc;
        
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Amendment Letter';
        des.dfsle__Status__c='Sent';
        des.Application_Booking__c=appBook.Id;
        des.Broker_Account__c=acc.Id;
        des.Transaction_Request__c = transReq.Id;
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
        
        Docusign_Recipient_Status_Sobha__c dseSobha = [SELECT Id FROM Docusign_Recipient_Status_Sobha__c LIMIT 1];
        
        Map<String, String> emailToRoleMap = new Map<String, String>();
        emailToRoleMap.put(r.dfsle__Email__c+'_'+r.dfsle__RoutingOrder__c, 'POA');
        
        AmendmentLetterDocusignHandler.sendEnvelopeMethod(new List<Id>{acc.Id});
        AmendmentLetterDocusignHandler.forForSigningFuture2(acc.Id);
        AmendmentLetterDocusignUtil.docusignPostProcessing(des.Id, acc.Id, null, emailToRoleMap);
        AmendmentLetterDocusignUtil.getDocusignRecipientStatusSobha(dseSobha.Id);
        AmendmentLetterDocusignUtil.createDocusignRecipientStatusSobhaRecords(new List<dfsle__RecipientStatus__c>{r});
        Test.StopTest();
    }
    
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Al_Siniya_Partner__c = true;
        acc.Email_ID_1__c = 'test@12345account.com';
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.MobilePhone = '9632871410';
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
        appBook.SPA_Transaction_Exception__c = true;
        insert appBook;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        TestDataFactorySobha.recordTypeName = 'DSPA Process';
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);
        insert transReq;
        TestDataFactorySobha.docusignEnvelopeType = 'Amendment Letter';
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Amendment Document - Letter.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion2.Id];
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = acc.id;
        cdl2.ContentDocumentId = documents2[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;
        
        Document__c doc = new Document__c();
        doc.Authorized_Signatory_1_Email__c = 'test@123.com';
        doc.Document_Type__c = 'Amendment Letter';
        doc.Application_Booking__c = appBook.Id;
        doc.Authorized_Signatory_2_Email__c = 'test@123.com';
        doc.Authorized_Signatory_3_Email__c = 'test@123.com';
        doc.Authorized_Signatory_4_Email__c = 'test@123.com';
        doc.Authorized_Signatory_5_Email__c = 'test@123.com';
        doc.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByName().get('Seller Representative').getRecordTypeId();
        insert doc;
        
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Amendment Letter';
        des.dfsle__Status__c='Sent';
        des.Application_Booking__c=appBook.Id;
        des.Broker_Account__c=acc.Id;
        des.Transaction_Request__c = transReq.Id;
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
        
        Docusign_Recipient_Status_Sobha__c dseSobha = [SELECT Id FROM Docusign_Recipient_Status_Sobha__c LIMIT 1];
        
        Map<String, String> emailToRoleMap = new Map<String, String>();
        emailToRoleMap.put(r.dfsle__Email__c+'_'+r.dfsle__RoutingOrder__c, 'POA');
        
        AmendmentLetterDocusignHandler.sendEnvelopeMethod(new List<Id>{acc.Id});
        AmendmentLetterDocusignUtil.docusignPostProcessing(des.Id, acc.Id, null, emailToRoleMap);
        AmendmentLetterDocusignUtil.getDocusignRecipientStatusSobha(dseSobha.Id);
        AmendmentLetterDocusignUtil.createDocusignRecipientStatusSobhaRecords(new List<dfsle__RecipientStatus__c>{r});
        Test.StopTest();
    }
}