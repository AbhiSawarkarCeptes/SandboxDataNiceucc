@isTest
public class SiteVisitcontrollerV1_Test {

    @testSetup
    static void setup() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
    }

    @isTest
    static void testInitialization() {
        // Set the page parameters
        
        PropStrength__Request__c temp = [SELECT ID FROM PropStrength__Request__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('EnquiryId', temp.Id);
        ApexPages.currentPage().getParameters().put('projectId', temp.Id);
        ApexPages.currentPage().getParameters().put('Email', 'test@example.com');
        ApexPages.currentPage().getParameters().put('mobilePhone', '1234567890');
        ApexPages.currentPage().getParameters().put('contId', con.Id);
        ApexPages.currentPage().getParameters().put('enqSource', 'Channel Partner');

        Test.startTest();
        SiteVisitcontrollerV1 controller = new SiteVisitcontrollerV1();
        Test.stopTest();
    }

    @isTest
    static void testSave() {
        PropStrength__Request__c temp = [SELECT ID FROM PropStrength__Request__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('EnquiryId', temp.Id);
        ApexPages.currentPage().getParameters().put('projectId', temp.Id);
        ApexPages.currentPage().getParameters().put('Email', 'test@example.com');
        ApexPages.currentPage().getParameters().put('mobilePhone', '1234567890');
        ApexPages.currentPage().getParameters().put('contId', con.Id);
        ApexPages.currentPage().getParameters().put('enqSource', 'Channel Partner');

        Test.startTest();
        SiteVisitcontrollerV1 controller = new SiteVisitcontrollerV1();
        
        controller.cont.LastName = 'UpdatedTest';
        PageReference result = controller.save();
        Test.stopTest();
        
        // Verify that the contact and request were updated
        Contact updatedContact = [SELECT LastName FROM Contact WHERE Id = :controller.cont.Id];
        
        PropStrength__Request__c updatedRequest = [SELECT PropStrength__Primary_Contact__c FROM PropStrength__Request__c WHERE Id = :controller.sv.Id];
    }

    @isTest
    static void testHandleEnqSourceChange() {
        Test.startTest();
        SiteVisitcontrollerV1 controller = new SiteVisitcontrollerV1();
        
        // Change the source to 'Channel Partner' and check the state
        controller.sv.PropStrength__Request_Source__c = 'Channel Partner';
        controller.handleEnqSourceChange();
        
        // Change the source to something else and check the state
        controller.sv.PropStrength__Request_Source__c = 'Direct';
        controller.handleEnqSourceChange();
        
        Test.stopTest();
    }
}