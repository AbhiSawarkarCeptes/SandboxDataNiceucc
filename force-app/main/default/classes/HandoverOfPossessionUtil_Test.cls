@isTest
public class HandoverOfPossessionUtil_Test {
    
    @TestSetup
    public static void makeData(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        
        
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');
        User user2 = TestDataFactory.createUserSysAdmin('On22e','Galvatro22n', 'galvat33ron14566@radius.com', 'g22alvatron12345@radius.com');
        
        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;
        
        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;
        
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'SBF Assignment';
        insert groupName;
        
        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.Name = 'TestQueue';
        assignmentGroup.PropStrength__Assignment_Group__c = groupName.Id;
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        insert assignmentGroup;
        
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = groupName.Id;
        insert assignmentGroup1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'TestAgreement',
            VersionData = Blob.valueOf('TestAgreement'),
            PathOnCLient = 'Path'
        );
        insert testContentVersion;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = book.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        Test.stopTest();
    }
    
    
    @isTest
    public static void testMethod1() {
        
        PropStrength__Application_Booking__c book = [select id from PropStrength__Application_Booking__c limit 1];
        Test.startTest();
        HandoverOfPossessionUtil.getBooking(book.id);
        Test.stopTest();
    }
    
    @isTest
    public static void testDocusignPostProcessing(){
        PropStrength__Application_Booking__c book = [select id from PropStrength__Application_Booking__c limit 1];
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordMap.get('OPPORTUNITY');
        q.Unit__c = recordMap.get('UNIT');
        q.Payment_Plan__c = recordMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;    
        
        
        dfsle__EnvelopeStatus__c statusRecord = new dfsle__EnvelopeStatus__c();
        statusRecord.dfsle__Status__c = 'Sent';
        statusRecord.dfsle__DocuSignId__c = '12345';
        insert statusRecord;
        
        dfsle__Envelope__c envelopeRecord = new dfsle__Envelope__c();
        envelopeRecord.dfsle__DocuSignId__c = '12345';
        insert envelopeRecord;
        
        dfsle__RecipientStatus__c drs = new dfsle__RecipientStatus__c(Name = 'Sales Head', Envelope_Recipient_Type__c = 'Sales manager', dfsle__RoutingOrder__c = 1, dfsle__Email__c = 'test@gmail.com', dfsle__Status__c = 'Completed', dfsle__EnvelopeStatus__c = statusRecord.Id);
        insert drs;
        Map<String, String> emailToRoleMap = new Map<String, String>();
        emailToRoleMap.put(drs.dfsle__Email__c+'_'+drs.dfsle__RoutingOrder__c, drs.Envelope_Recipient_Type__c);
        id myDocId = [SELECT ContentDocumentId FROM ContentVersion limit 1].ContentDocumentId;
        
        Docusign_Recipient_Status_Sobha__c drsSobha = new Docusign_Recipient_Status_Sobha__c();
       
        drsSobha.Completed__c = drs.dfsle__Completed__c;
       
       
        drsSobha.Name = drs.Name;
        drsSobha.Email__c = drs.dfsle__Email__c;
        if(drs.Envelope_Recipient_Type__c != null && drs.Envelope_Recipient_Type__c != '')
            drsSobha.Envelope_Recipient_Type__c = drs.Envelope_Recipient_Type__c;
        if(drs.Envelope_Type__c != null && drs.Envelope_Type__c != '')
            drsSobha.Envelope_Type__c = drs.Envelope_Type__c;
        drsSobha.Last_Applicant__c = drs.Last_Applicant__c;
        drsSobha.DocuSign_Envelope_Status__c = statusRecord.Id;
        drsSobha.DocuSignEnvelope__c = statusRecord.Id;
        
        
        drsSobha.Sent__c = drs.dfsle__Sent__c;
        drsSobha.Sequence__c = drs.dfsle__Sequence__c;
        drsSobha.Status__c = drs.dfsle__Status__c;
        drsSobha.Type__c = drs.dfsle__Type__c;
        drsSobha.Docusign_Broker_Registration__c = drs.Docusign_Broker_Registration__c;
        insert drsSobha;
        

        
        Test.startTest();
        HandoverOfPossessionUtil.docusignPostProcessing('12345', book.Id, myDocId, emailToRoleMap);
        HandoverOfPossessionUtil.getDocusignRecipientStatusSobha(statusRecord.Id);
        HandoverOfPossessionUtil.getDocusignRecipientStatusSobhaByKey(new Set<Id>{statusRecord.Id});
        HandoverOfPossessionUtil.createDocusignRecipientStatusSobhaRecords([select id, Application_Booking__c, dfsle__Completed__c, dfsle__Reason__c, dfsle__EnvelopeStatus__c, Name, dfsle__Email__c, Envelope_Recipient_Type__c, Envelope_Type__c, Last_Applicant__c, dfsle__LastStatusUpdate__c, dfsle__RoutingOrder__c, dfsle__SourceId__c, dfsle__Sent__c, dfsle__Sequence__c, dfsle__Status__c, dfsle__Type__c from dfsle__RecipientStatus__c]);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetFileId(){
        PropStrength__Application_Booking__c book = [select id from PropStrength__Application_Booking__c where  PropStrength__Booking_Through__c = 'Broker' limit 1];
        HandoverOfPossessionUtil.getFileId(book.Id);
    }
    
    @isTest
    public static void testOtherMethod(){
        HandoverOfPossessionUtil.docusignEmailBody();
        HandoverOfPossessionUtil.getSMSDBody('testbook', 'testUnit');
        HandoverOfPossessionUtil.getSalesOperationBody('testbook', 'testUnit');
        HandoverOfPossessionUtil.getAuditBody('testbook', 'testUnit');
        HandoverOfPossessionUtil.validateAndUpdatePhoneNumber('123546895');
    }

    
}