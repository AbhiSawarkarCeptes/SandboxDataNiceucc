@isTest
public class ComposeEmailController_Test {
    @isTest
    static void testMethod1(){
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
        proj.Accounts_Executive__c = u.Id;
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
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        
        PropStrength__Request__c enq3  = new PropStrength__Request__c();
        enq3.PropStrength__Primary_Contact__c = cont.Id;
        insert enq3;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = cont.FirstName;
        enq2.PropStrength__Last_Name__c =cont.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = appBook.id;
        enq2.PropStrength__Project__c = proj.id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test Comments : Query Resolved';
        insert enq2;
        
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Service_Request__c = enq2.id;
        eml.PropStrength__Subject__c ='Re:test email';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        
        insert eml;
        PageReference pageRef = Page.ComposeEmail;
        ApexPages.currentPage().getParameters().put('action', 'Test');
        ApexPages.currentPage().getParameters().put('emailId', String.valueOf(eml.Id));
        ApexPages.currentPage().getParameters().put('objName', 'bookRequest');
        ApexPages.currentPage().getParameters().put('objId', String.valueOf(enq2.Id));
        ComposeEmailController comps = new ComposeEmailController();
        
        //comps.objectName = '';
        
        
        Test.StopTest();
        
    }
    @isTest
    static void testMethod2(){
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
        proj.Accounts_Executive__c = u.Id;
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
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = appBook.Id);
        insert appDetail;
        
        PropStrength__Request__c enq3  = new PropStrength__Request__c();
        enq3.PropStrength__Primary_Contact__c = cont.Id;
        insert enq3;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = cont.FirstName;
        enq2.PropStrength__Last_Name__c =cont.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = appBook.id;
        enq2.PropStrength__Project__c = proj.id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test Comments : Query Resolved';
        insert enq2;
        
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Service_Request__c = null;
        eml.PropStrength__Subject__c ='Re:test email';
        eml.PropStrength__Assign_To__c = cont.Id;
        eml.PropStrength__CC_Address__c = 'test123@gmail.com';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        
        insert eml;
        
        Attachment attachment = new Attachment();
        attachment.ParentId = eml.Id;
        attachment.Name = 'POA';
        attachment.Body = Blob.valueOf('Test');
        insert attachment;
        
        PageReference pageRef = Page.ComposeEmail;
        ApexPages.currentPage().getParameters().put('action', 'reply');
        ApexPages.currentPage().getParameters().put('emailId', String.valueOf(eml.Id));
        ApexPages.currentPage().getParameters().put('objName', 'appDetail');
        ApexPages.currentPage().getParameters().put('objId', String.valueOf(appDetail.Id));
        ApexPages.currentPage().getParameters().put('isDraft', 'True');
        ApexPages.currentPage().getParameters().put('attachmentIds', JSON.serialize(new List<Id>{attachment.Id}));
        ComposeEmailController comps = new ComposeEmailController();
        
        //comps.objectName = '';
        ApexPages.currentPage().getParameters().put('action', 'replyToAll');
        ApexPages.currentPage().getParameters().put('emailId', String.valueOf(eml.Id));
        ApexPages.currentPage().getParameters().put('objName', 'contact');
        ApexPages.currentPage().getParameters().put('objId', String.valueOf(cont.Id));
        ApexPages.currentPage().getParameters().put('isDraft', 'True');
        ApexPages.currentPage().getParameters().put('attachmentIds', JSON.serialize(new List<Id>{attachment.Id}));
        ComposeEmailController comps1 = new ComposeEmailController();
        
        comps.selectedCCAddress = '';
        comps.selectedBCCAddress = '';
        
        comps.onChangeCCAddress();
        comps.onChangeBCCAddress();
        
        comps.onChangeFromAddress();
        comps.setTemplates('Unit Hold Notification');
        
        EMailTemplate templateToReturn = [Select Subject,id,HtmlValue from EMailTemplate LIMIT 1];
        comps.setTemplatesBody(String.valueOf(templateToReturn.Id));
        comps.onChangeTemplates();
        comps.selectedTemplate = String.valueOf(templateToReturn.Id);
        comps.onChangeTemplates();
        comps.getTemplateList();
        
        ApexPages.currentPage().getParameters().put('colValue', String.ValueOf(0));
        comps.deleteAttachment();
        
        comps.upload();
        comps.saveToDraft();
        comps.doCancel();
        comps.sendSRMail();
        //EMailTemplate templateToReturn1 = [Select Subject,id,HtmlValue,Markup from EMailTemplate WHERE Name = 'Welcome Email Template' LIMIT 1];
        User user = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        System.runAs(user) {
            EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'Send_1_Day_Before_Reminder_HO',
            Name = 'Send 1 Day Before Reminder HO',
            TemplateType = 'visualforce',
            Subject = 'Test Email Subject',
            FolderId = UserInfo.getUserId(),
            HtmlValue = '<messaging:emailTemplate> <messaging:htmlEmailBody ><a href="https://www.instagram.com/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZH7&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;</messaging:htmlEmailBody></messaging:emailTemplate>',
            Markup = '<messaging:emailTemplate subject="UNIT {!relatedTo.PropStrength__Application__r.House_Unit_No__c} | {!relatedTo.PropStrength__Application__r.PropStrength__Tower__c} | Welcome to Sobha Realty" recipientType="Contact" relatedToType="PropStrength__Applicant_Detail__c"> <messaging:htmlEmailBody ><a href="https://www.instagram.com/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZH7&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;</messaging:htmlEmailBody></messaging:emailTemplate>' );            
        insert emailTemplate;
        
        comps.selectedEmailTemplate = String.valueOf(emailTemplate.Id);
        comps.onChangeEmailTemplate();
        List<Attachment> attch = new List<Attachment>();
        attch.add(attachment);
        
        comps.existingAttachmentsOnLoad(attch);
        }
        Test.StopTest();
        
    }
}