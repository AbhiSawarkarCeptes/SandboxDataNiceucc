@isTest
public class DemandLetterController_Test {

    @isTest
    Public  static void DemandLetterControllerTest(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        proj.Project_Registration_Date__c = System.now().Date();
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
        //appBook.PropStrength__Total_Payment_Received__c = 60;
        //appBook.PropStrength__Revised_Total_Sales_Consideration__c = 10;
        //appBook.PropStrength__Total_Service_Tax_due_on_Booking__c = 5;
        appBook.PropStrength__Status__c = 'Audit Approved';
        appBook.PropStrength__Active__c = True;
        appBook.Booking_Form_Executed__c = True;
        appBook.PropStrength__Applicant_Email__c = 'test123@gmail.com';
        appBook.PropStrength__Total_Basic_Sales_Price__c = 10;
        
        Test.startTest();
        insert appBook;
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = appBook.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        insert pay;
        
        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = appBook.Id, PropStrength__Payment_Due_Date__c = System.Today()+60);
        insert ppd;
       /* Attachment attachment = new Attachment();
    	attachment.ParentId = appBook.Id;
    	attachment.Name = 'Welcome Letter.pdf';
    	attachment.Body = Blob.valueOf('Test Data');  	
    	insert(attachment);*/
        
        //PropStrength__Application_Booking__c appBookRecord = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        DemandLetterController dmdLttrCntrl = new DemandLetterController();
        DemandLetterController.sendMailWithPDF(appBook.Id);
        Test.stopTest();
 
    }
    
    @isTest
    public static void testAttachmentPart(){
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
        //appBook.PropStrength__Total_Payment_Received__c = 60;
        //appBook.PropStrength__Revised_Total_Sales_Consideration__c = 10;
        //appBook.PropStrength__Total_Service_Tax_due_on_Booking__c = 5;
        appBook.PropStrength__Status__c = 'Audit Approved';
        appBook.PropStrength__Active__c = True;
        appBook.PropStrength__Applicant_Email__c = 'test1234@gmail.com';
        appBook.Booking_Form_Executed__c = True;
        appBook.PropStrength__Total_Basic_Sales_Price__c = 10;
        
        Test.startTest();
        insert appBook;
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = appBook.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        insert pay;
        
        PropStrength__Payment_Plan_Details__c ppd = new PropStrength__Payment_Plan_Details__c(PropStrength__Application_Booking__c = appBook.Id, PropStrength__Payment_Due_Date__c = System.Today()+60);
        insert ppd;
        Attachment attachment = new Attachment();
    	attachment.ParentId = appBook.Id;
    	attachment.Name = 'Welcome Letter.pdf';
    	attachment.Body = Blob.valueOf('Test Data');  
        insert attachment;
        Attachment attachment2 = new Attachment();
    	attachment2.ParentId = appBook.Id;
    	attachment2.Name = 'Pre-Registration Notice.pdf';
    	attachment2.Body = Blob.valueOf('Test Data');  
        insert attachment2;
        Attachment attachment3 = new Attachment();
    	attachment3.ParentId = appBook.Id;
    	attachment3.Name = 'Sales Booking Form.pdf';
    	attachment3.Body = Blob.valueOf('Test Data');  
        insert attachment3;
        //insert new List<Attachment>{attachment, attachment2, attachment3};
        
        //PropStrength__Application_Booking__c appBookRecord = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        DemandLetterController dmdLttrCntrl = new DemandLetterController();
        DemandLetterController.sendMailWithPDF(appBook.Id);
        appBook.PropStrength__Total_Basic_Sales_Price__c = 12;
        update appBook;
        DemandLetterController.sendMailWithPDF(appBook.Id);
        Test.stopTest();
        
    }
    
}