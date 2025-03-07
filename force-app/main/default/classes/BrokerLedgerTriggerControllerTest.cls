@isTest
public class BrokerLedgerTriggerControllerTest {
    @testSetup
    public static void setUp() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email_ID_1__c ='test@gmail.com';
        insert acc;
        
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.AccountId = acc.ID;
        cont.Email = 'test@test.com';
        insert cont;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        
        PropStrength__Payment_Plan__c ppd = TestDataFactorySobha.createPaymentPlan(null);
        ppd.PropStrength__Project__c = proj.Id;
        insert ppd;
        
        PropStrength__Request__c enq  = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        tower.PropStrength__Project_Name__c = proj.Id; 
        insert tower;
        
        PropStrength__Property_Type__c pType =  TestDataFactorySobha.createPropertyType(null);
        pType.PropStrength__Project__c = proj.Id;
        insert pType;
        
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Tower__c = tower.Id;
        prop.PropStrength__Property_Type__c = pType.Id;
        prop.PropStrength__Project_Name__c = proj.Id;
        insert prop;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.PropStrength__Request__c = enq.Id;
        offer.PropStrength__Payment_Plan__c = ppd.Id;
        offer.PropStrength__Project__c = proj.Id; 
        offer.PropStrength__Property__c = prop.Id; 
        offer.PropStrength__Property_Type__c = pType.Id;
        offer.PropStrength__Primary_Contact__c = cont.Id;
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__Brokerage_BSP__c=1200,PropStrength__Brokerage_On_Other_Charges__c=1400);
        insert book;
        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c();
        book1.id = book.id;
        book1.PropStrength__Super_Area__c=1100;
        update book1;
    }
    @isTest
    public static void testMethod1() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        List<PropStrength__Broker_Ledger__c> newList = new List<PropStrength__Broker_Ledger__c>{new PropStrength__Broker_Ledger__c(id= br.id,PropStrength__Broker_Payment_Milestone__c=bpm1.id)};
            update newList;
        Map<id,PropStrength__Broker_Ledger__c> oldmap = new Map<id,PropStrength__Broker_Ledger__c>([select id from PropStrength__Broker_Ledger__c]);
        BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(newList,oldmap,'update');
        BrokerLedgerTriggerController.callApprovalProcess2(br.id);
        
    }
    
    @isTest
    public static void testMethod2() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        List<PropStrength__Broker_Ledger__c> newList = new List<PropStrength__Broker_Ledger__c>{new PropStrength__Broker_Ledger__c(id= br.id,PropStrength__Broker_Payment_Milestone__c=bpm1.id)};
            update newList;
        Map<id,PropStrength__Broker_Ledger__c> oldmap = new Map<id,PropStrength__Broker_Ledger__c>([select id from PropStrength__Broker_Ledger__c]);
        BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(newList,oldmap,'update');
        BrokerLedgerTriggerController.callApprovalProcess3(br.id);      
    }
    @isTest
    public static void testMethod3() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        List<PropStrength__Broker_Ledger__c> newList = new List<PropStrength__Broker_Ledger__c>{new PropStrength__Broker_Ledger__c(id= br.id,PropStrength__Broker_Payment_Milestone__c=bpm1.id)};
            update newList;
        Map<id,PropStrength__Broker_Ledger__c> oldmap = new Map<id,PropStrength__Broker_Ledger__c>([select id from PropStrength__Broker_Ledger__c]);
        BrokerLedgerTriggerController.maintainRollUpOnBrokerPaymentMS(newList,oldmap,'update');
        BrokerLedgerTriggerController.callApprovalProcess1(br.id);
        
    }
    
      @isTest
    public static void testMethod4() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        List<PropStrength__Broker_Ledger__c> newList = new List<PropStrength__Broker_Ledger__c>{new PropStrength__Broker_Ledger__c(id= br.id,Hold_BrokerLedger__c=true, Hold_by_Demartment__c = 'Hold By MIS', Hold_Reason__c = 'Testing')};
            update newList;
            
    }
    
       @isTest
    public static void testMethod5() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        List<PropStrength__Broker_Ledger__c> newList = new List<PropStrength__Broker_Ledger__c>{new PropStrength__Broker_Ledger__c(id= br.id,PropStrength__Approval_Status__c='Approved by Audit')};
            update newList;
            
    }
    
           @isTest
    public static void testMethod6() {
        Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
        
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email_ID_1__c ='test@gmail.com';
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
     PageReference PDf =  Page.Invoice;
            PDf.getParameters().put('id',br.id);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            
            Blob b ;
            if(Test.IsRunningTest())
                b= Blob.valueOf('This is Test');    
            else
                b= PDf.getContentAsPDF(); 
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = 'Invoice.pdf';
            contentVersion.Title = 'Invoice.pdf';
            contentVersion.VersionData = b;
            insert contentVersion;
            
           Id  myDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = myDocumentId;
            contentDocumentLink.LinkedEntityId = br.id;
            contentDocumentLink.ShareType = 'I';
            contentDocumentLink.Visibility = 'InternalUsers';
            insert contentDocumentLink; 

        BrokerLedgerTriggerController.sendLetterForDocusign(br.id,myDocumentId);
    }
      @isTest
    public static void testMethod7() {
       Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
         
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
        test.startTest();
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      /*  Account acc = TestDataFactorySobha.createAccount(null);
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.Email_ID_1__c = 'test@12345account.com';
        insert acc;*/
      
        //TestDataFactorySobha.docusignEnvelopeType = 'Amendment Letter';
        dfsle__EnvelopeStatus__c envelopeStatus = createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
        
      /*  ContentVersion contentVersion = new ContentVersion(
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
        */
        Document__c doc = new Document__c();
        doc.Authorized_Signatory_1_Email__c = 'test@123.com';
      //  doc.Document_Type__c = 'Invoice';
       // doc.Application_Booking__c = appBook.Id;
        
        doc.Authorized_Signatory_2_Email__c = 'test@123.com';
        doc.Authorized_Signatory_3_Email__c = 'test@123.com';
        doc.Authorized_Signatory_4_Email__c = 'test@123.com';
        doc.Authorized_Signatory_5_Email__c = 'test@123.com';
        doc.RecordTypeId = Schema.SObjectType.Document__c.getRecordTypeInfosByName().get('Seller Representative').getRecordTypeId();
        insert doc;
        
        dfsle__EnvelopeStatus__c des = new dfsle__EnvelopeStatus__c();
        des.Envelope_Type__c='Invoice';
        des.dfsle__Status__c='Sent';
       // des.Application_Booking__c=appBook.Id;
        des.Broker_Account__c=acc.Id;
       // des.Transaction_Request__c = transReq.Id;
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
        
        
        BrokerLedgerDocusignUtilClone.docusignPostProcessing(des.Id, br.Id, null, emailToRoleMap);
       
        Test.StopTest();
            
    } 
      public static dfsle__EnvelopeStatus__c createDocusignEnvelopeStatus(Id envId) {
           Id bookId = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id ;
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = bookId;
        bpm.Differentiate_Brokerage__c = true;
        
        insert bpm;
        
         
        PropStrength__Broker_Payment_Milestone__c bpm1 = new PropStrength__Broker_Payment_Milestone__c();            
        bpm1.PropStrength__Brokerage_Due_Rs__c = 200; 
        bpm1.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm1.PropStrength__Booking_ID__c = bookId;
        bpm1.Differentiate_Brokerage__c = true;
        insert bpm1;
        
       
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        // br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
         

             String docusignEnvelopeStatus =  'Sent';
            String docusignEnvelopeType =  'Invoice';
        
        dfsle__EnvelopeStatus__c envRec = new dfsle__EnvelopeStatus__c();
        if(envId != null) {
            envRec.Id = envId;
        }
        envRec.dfsle__Status__c = docusignEnvelopeStatus;
        envRec.Envelope_Type__c = docusignEnvelopeType;
          envRec.Broker_Ledger__c = br.id ;
       // envRec.Transaction_Request__c = trRec.Id;
       // envRec.Application_Booking__c = appBookRec.Id;

        docusignEnvelopeStatus = null;
        docusignEnvelopeType = null;
        
        return envRec;
    }
}