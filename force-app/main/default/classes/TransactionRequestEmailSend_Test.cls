@isTest
public class TransactionRequestEmailSend_Test {
    @TestSetup
    static void testdata(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.Birthdate = System.Today();
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        proj.Customer_Care_Email_ID__c = 'crmops@sobharealty.com';
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
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId(), PropStrength__Application_Booking__c = appBook.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
        insert trList;
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        
    }
    
    @IsTest
    static void sendEmailRevisedBookingform_Test(){
        List<PropStrength__Application_Booking__c> propRec = [SELECT Id,PropStrength__Primary_Customer__c,PropStrength__Active__c, PropStrength__Property__c
                                                              FROM PropStrength__Application_Booking__c WHERE PropStrength__Active__c =: true LIMIT 1];
        Set<Id> propIds = new Set<Id>();
		EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'Revised_Booking_form';
        validEmailTemplate.DeveloperName = 'Revised_Booking_form';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        insert validEmailTemplate;        
        propIds.add(propRec[0].PropStrength__Property__c);
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PageReference pdf = Page.RevisedBookingform;
        TransactionRequestEmailSend.sendEmailRevisedBookingform(propIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailDLDCertificate_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Initial contract of sale';
        contentVersion.PathOnClient = 'TestPDF.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        
        TransactionRequestEmailSend.sendEmailDLDCertificate(transIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailDSPA_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'DSPA Letter.pdf';
        contentVersion.PathOnClient = 'DSPA Letter.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        
        TransactionRequestEmailSend.sendEmailDSPA(transIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailLegalDSPA_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'DSPA Letter.pdf';
        contentVersion.PathOnClient = 'DSPA Letter.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        
        TransactionRequestEmailSend.sendEmailLegalDSPA(transIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailSPA_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Signed';
        contentVersion.PathOnClient = 'Signed.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        
        TransactionRequestEmailSend.sendEmailSPA(transIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailMOU_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Signed';
        contentVersion.PathOnClient = 'Signed.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        
        TransactionRequestEmailSend.sendEmailMOU(transIds);
        Test.StopTest();
    }
    
    @IsTest
    static void sendEmailLegalMOU_Test(){
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id,PropStrength__Status__c,PropStrength__Application_Booking__c,
                                                                       PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c
                                                                       FROM PropStrength__Transaction_Requests__c];
        
        Set<Id> transIds = new Set<Id>();
        transIds.add(transactionList[0].Id);
        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Signed';
        contentVersion.PathOnClient = 'Signed.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Data');
        insert contentVersion;
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion.ContentDocumentId;
        contentDocumentLink.LinkedEntityId = transactionList[0].Id;
        contentDocumentLink.ShareType = 'V'; // Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // Visibility
        insert contentDocumentLink;
        Attachment attachment = new Attachment();
        attachment.Name = 'TestAttachment.pdf';
        attachment.Body = Blob.valueOf('Test Data');
        attachment.ParentId = transactionList[0].Id; // Link to the Contact record
        insert attachment;
        TransactionRequestEmailSend.sendEmailLegalMOU(transIds);
        Test.StopTest();
    }
}