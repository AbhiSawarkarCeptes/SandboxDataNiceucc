@isTest
public class ProformaInvoiceEnqController_Test {
    
    @isTest
    public static void testfirst(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq1 = TestDataFactorySobha.createEnquiry(null);        
        insert enq1;
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
        
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Selected_Property_Ids__c = prop.id;
        insert enq;
        Proforma_Invoice__c invoice = new Proforma_Invoice__c();
        invoice.Enquiry__c = enq.Id;        
        insert invoice;
        Group salesOpsTeamGroup = [SELECT Id FROM Group WHERE Name= 'RFP Sales Ops Team' LIMIT 1];
        Group vpGroup = [SELECT Id FROM Group WHERE Name= 'RFP Sales Ops VP Director' LIMIT 1];
        // Avoid mixed DML using runAs
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = salesOpsTeamGroup.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm;
            GroupMember gm1 = new GroupMember(GroupId = vpGroup.Id, UserOrGroupId = UserInfo.getUserId());
            insert gm1;
        }
       Test.StartTest();
        ProformaInvoiceEnqController.getOpportunity(enq.Id);
        ProformaInvoiceEnqController.getProperty(prop.Id);
        ProformaInvoiceEnqController.objectName(enq.Id);
        ProformaInvoiceEnqController.getBooking(appBook.Id);
        ProformaInvoiceEnqController.checkPDFGeneration(enq.Id);
        ProformaInvoiceEnqController.generatePDFForBooking(appBook.Id, 1);
        ProformaInvoiceEnqController.generatePDF(new List<Id>{invoice.Id});
        ProformaInvoiceEnqController.sendEmailAfterApproval(invoice.Id);
        ProformaInvoiceEnqController.generatePDF(enq.Id,'200',2,222);
        ProformaInvoiceEnqController.generatePDF2(enq.Id,'200',2,222);
        ProformaInvoiceEnqController.generatePDF3(enq.Id,'200',2,222);        
        ProformaInvoiceEnqController.updateParent('DLD Amount',enq.Id,false);
        ProformaInvoiceEnqController.updateParent('DLD Amount',appBook.Id,true);
        try{
        ProformaInvoiceEnqController.createAndSubmit(enq1.Id,'200',2,200,false);
             }catch(exception e){}
        try{
        ProformaInvoiceEnqController.createAndSubmit(appBook.Id,'200',2,200,true);
        }catch(exception e){}
        
        test.stoptest();
    }

}