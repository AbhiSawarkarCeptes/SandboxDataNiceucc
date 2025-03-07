@isTest
public class UploadHandoverNotice_Test {
    
    @isTest
    public static void test1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact con = new Contact();
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        con.FirstName='Jatin';
        con.LastName = 'Net';
        con.PropStrength__Income_Tax_permanent_Account_No__c = '123';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.Email = 'test@test.com';
        con.MailingCountry = 'India';
        con.MailingState = 'Delhi';
        con.MailingPostalCode ='1234';
        con.MobilePhone = '9034207006';
        insert con;
        
        PropStrength__Projects__c PSProject = new PropStrength__Projects__c ();
        PSProject .name = 'Forreste';
        PSProject.PropStrength__Project_Code__c ='test';
        PSProject.PropStrength__Type_of_Project__c = 'Retail';
        PSProject.PropStrength__Status__c = 'Planning';            
        insert PSProject;
        
        PropStrength__Request__c tempReq = new PropStrength__Request__c();
        tempReq.PropStrength__Request_Source__c = 'Kisok/data-sheet';
        tempReq.PropStrength__Project__c = PSProject.id;
        tempReq.PropStrength__Request_Status__c = 'Open';
        tempReq.PropStrength__Primary_Contact__c = con.id;        
        insert tempReq ; 
        
        PropStrength__Offer__c offr = new PropStrength__Offer__c();
        offr.PropStrength__Offer_Close_Date__c = system.today();
        offr.PropStrength__Status__c = 'Open';
        offr.RecordTypeId = Schema.SObjectType.PropStrength__Offer__c.getRecordTypeInfosByName().get('Mobile Page').getRecordTypeId();
        offr.PropStrength__Primary_Contact__c = con.id;
        offr.PropStrength__Project__c = PSProject.id;
        offr.PropStrength__Request__c = tempReq.Id;        
        insert offr;
        
        Attachment newAttachment = new Attachment();
        newAttachment.ParentId = offr.Id;
        newAttachment.Body = Blob.valueOf('milestone');
        newAttachment.Name = 'Kyc Document - Test';
        newAttachment.IsPrivate = false;
        insert newAttachment;
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  PSProject.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        List<PropStrength__Property_Type__c> propTypeList = new List<PropStrength__Property_Type__c>();
        propTypeList.add(new PropStrength__Property_Type__c(PropStrength__Project__c = PSProject.Id, PropStrength__Active__c = true, PropStrength__Area__c = 500, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '2 BHK'));
        propTypeList.add(new PropStrength__Property_Type__c(PropStrength__Project__c = PSProject.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BHK'));
        insert propTypeList;
        
        List<PropStrength__Floor__c> floorList = new List<PropStrength__Floor__c>();
        floorList.add(new PropStrength__Floor__c(PropStrength__Floor_Name__c = 'Ground',PropStrength__Floor_Code__c = 'A-Ground', PropStrength__Tower__c = tower.Id, PropStrength__Active__c = true, PropStrength__Floor_Number__c = 0));
        floorList.add(new PropStrength__Floor__c(PropStrength__Floor_Name__c = '1st Floor',PropStrength__Floor_Code__c = 'A-1st Floor', PropStrength__Tower__c = tower.Id, PropStrength__Active__c = true, PropStrength__Floor_Number__c = 1));
       	insert floorList;
        
        List<PropStrength__Property__c> propList = new List<PropStrength__Property__c>();
        propList.add(new PropStrength__Property__c(PropStrength__Property_Alloted_Through_Offer__c = false,PropStrength__Tower__c = tower.Id, PropStrength__Floor__c =floorList[0].Id, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propTypeList[0].Id, PropStrength__Project_Name__c = PSProject.Id, PropStrength__Active__c = true));
        propList.add(new PropStrength__Property__c(PropStrength__Property_Alloted_Through_Offer__c = false, PropStrength__Tower__c = tower.Id, PropStrength__Floor__c =floorList[1].Id, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propTypeList[1].Id, PropStrength__Project_Name__c = PSProject.Id, PropStrength__Active__c = true));
        insert propList;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Sales_Head_Incentive__c=10,PropStrength__Property__c=propList[0].Id,
                                                                                             PropStrength__Primary_Customer__c = con.Id,PropStrength__Offer__c=offr.Id,
                                                                                             PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Broker', 
                                                                                             PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = PSProject.Id);
        insert book;
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Type__c = '1st Applicant',
                                                                                            PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, 
                                                                                            PropStrength__Application__c = book.Id,PropStrength__Applicant_Acc__c = con.id);
        insert appDetail;
        Test.startTest();
        PageReference pageRef = Page.UploadHandoverNotice;
        pageRef.getParameters().put('kycUploadId', String.valueOf(offr.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(offr);
		UploadHandoverNoticeController architectController = new UploadHandoverNoticeController(controller);
        System.debug('Test.setCurrentPage(pageRef) : '+pageRef);
        //architectController.offerId = pageRef.getParameters().put('kycUploadId', String.valueOf(offr.Id));
       // System.debug('architectController.offerId : '+architectController.offerId);
        architectController.pageName = 'Upload Kyc Documents';
        architectController.otherAttachmentsSelectionCount = 2;
        architectController.attachmentSelected = 1;
        architectController.documentType = 'Test';
        architectController.fileExtention = 'Test';
        architectController.fileName = 'Kyc Document';
        architectController.base64 = 'Test';
        architectController.fileType = 'Test';
        architectController.Counter = 'Demo';
        architectController.selectedValues();
        architectController.saveAttachmentFun();
        architectController.afterAttachmentMessage();
        architectController.towerId = tower.Id;
        architectController.addAttachemtOne(tower.Id,'test','test','.pdf');
        architectController.addAttachemtTwo(tower.Id,'test','test','.pdf');
        Test.stopTest();
    }
}