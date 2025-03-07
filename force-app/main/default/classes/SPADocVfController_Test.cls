@isTest
public class SPADocVfController_Test {
    @testSetup static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;

        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(SPA_Execution_Date__c = null, PropStrength__Active__c = true, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-50), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id,  SPA_Transaction_Exception__c = true);
        insert book;  
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, SPA_Created__c = false);
        insert tr;
    }
    @isTest
    static void getTransaction() {
        PropStrength__Transaction_Requests__c trRec = [SELECT Id, SPA_Created__c FROM PropStrength__Transaction_Requests__c LIMIT 1];
        PageReference myVfPage = Page.SPADocVf;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Id',trRec.Id);
        SPADocVfController spaVf = new SPADocVfController();
        PageReference pf = spaVf.docancel();
    }
}