/*********************************************************************
 * Class Name  :   PropertyTriggerHelper_Test
 * Description :   Test Class of PropertyTriggerHelper Class
 * Created Date:   26/05/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 26/05/2023
 *********************************************************************/
@isTest
public class PropertyTriggerHelper_Test {
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
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
        TestDataFactorySobha.recordTypeName = 'Apartment';
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.DLP_Start_Date__c = System.Today();
        prop.DLP_End_Date__c = System.Today().AddDays(2);
        prop.New_Super_Area__c = 1000;
        prop.Annexure_Document_Uploaded__c = System.today().addDays(-2);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.Deviation_on_Payment_Plan__c = true;
        offer.Remarks_For_Deviation__c = 'test Remarks_For_Deviation__c>>>>';
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
        appBook.PropStrength__Active__c = true;
        appBook.PropStrength__Property__c = prop.Id;
        insert appBook;
        Map<Id, PropStrength__Property__c> oldPropMap = new Map<Id, PropStrength__Property__c>();
        oldPropMap.put(prop.Id, prop);
        prop.DLP_Start_Date__c = System.Today().addDays(3);
        prop.DLP_End_Date__c = System.Today().AddDays(6);
        prop.New_Super_Area__c = 100;
        prop.PropStrength__Allotted__c = true;
        prop.Area_Change_Submitted_to_Audit__c = true;
        prop.Annexure_Document_Uploaded__c = System.Today();
        prop.Plot_Location_Plan_Uploaded__c = System.Today();
        prop.Ready_For_Inspection__c = System.Today();
        update prop;
        List<PropStrength__Property__c> propList = New List<PropStrength__Property__c>();
        propList.add(prop);
        PropertyTriggerHelper.unLockAllBookings(propList, oldPropMap);
        PropertyTriggerHelper.SendRevisedBookingform(propList, oldPropMap);
        PropertyTriggerHelper.showErrorOnNewSA(propList, oldPropMap);
        PropertyTriggerHelper.sendMailAuditApproval(new Set<Id>{prop.Id});
        prop.Area_Change_Submitted_to_Audit__c = false; 
        prop.New_Super_Area__c = 105;
        propList.clear();
        propList.add(prop);
        //PropertyTriggerHelper.createTRrecordOnNewSuperArea(propList, oldPropMap);
    }
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
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
        TestDataFactorySobha.recordTypeName = 'Apartment';
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Super_Area__c = 1000;
        prop.New_Super_Area__c = 100;
        insert prop;
        Map<Id, PropStrength__Property__c> oldPropMap = new Map<Id, PropStrength__Property__c>();
        oldPropMap.put(prop.Id, prop);
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.Deviation_on_Payment_Plan__c = true;
        offer.Remarks_For_Deviation__c = 'test Remarks_For_Deviation__c>>>>';
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
        appBook.PropStrength__Active__c = true;
        appBook.PropStrength__Property__c = prop.Id;
        insert appBook;
        
        prop.PropStrength__Super_Area__c = 1000;
        prop.New_Super_Area__c = 1020;
        prop.PropStrength__Allotted__c = true;
        
        try{
            update prop;
        }
        catch(exception e) {
            System.debug('E>>>>>>>>>>>>>>>>>>>'+e);
        }
        
        List<PropStrength__Property__c>  newList = new List<PropStrength__Property__c>();
        newList.add(prop);
        PropertyTriggerHelper.unLockAllBookings(newList, oldPropMap);
        PropertyTriggerHelper.runapprovalProcessOnAllotedCB(newList, oldPropMap);
        PropertyTriggerHelper.showErrorOnNewSA(newList, oldPropMap);
        PropertyTriggerHelper.sendMailOnSaleableChange(newList, oldPropMap);
    }
    @isTest
    static void testMethod3() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
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
        TestDataFactorySobha.recordTypeName = 'Apartment';
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Super_Area__c = 1500;
        prop.New_Super_Area__c = 100;
        insert prop;
        Map<Id, PropStrength__Property__c> oldPropMap = new Map<Id, PropStrength__Property__c>();
        oldPropMap.put(prop.Id, prop);
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.Deviation_on_Payment_Plan__c = true;
        offer.Remarks_For_Deviation__c = 'test Remarks_For_Deviation__c>>>>';
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
        appBook.PropStrength__Active__c = false;
        appBook.PropStrength__Property__c = prop.Id;
        insert appBook;
        
        prop.PropStrength__Super_Area__c = 1000;
        prop.New_Super_Area__c = 1020;
        prop.PropStrength__Allotted__c = true;
        List<PropStrength__Property__c>  newList2 = new List<PropStrength__Property__c>();
        newList2.add(prop);
        
        PropertyTriggerHelper.showErrorOnNewSA(newList2, oldPropMap);
        try{
            update prop;
        }
        catch(exception e) {
            System.debug('E>>>>>>>>>>>>>>>>>>>'+e);
        }
        
        List<PropStrength__Property__c>  newList = new List<PropStrength__Property__c>();
        newList.add(prop);
        PropertyTriggerHelper.unLockAllBookings(newList, oldPropMap);
        PropertyTriggerHelper.runapprovalProcessOnAllotedCB(newList, oldPropMap);
        PropertyTriggerHelper.showErrorOnNewSA(newList, oldPropMap);
        PropertyTriggerHelper.sendMailOnSaleableChange(newList, oldPropMap);
    }
    @isTest
    static void testMethod4() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
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
        TestDataFactorySobha.recordTypeName = 'Apartment';
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Super_Area__c = 1500;
        prop.New_Super_Area__c = 100;
        insert prop;
        Map<Id, PropStrength__Property__c> oldPropMap = new Map<Id, PropStrength__Property__c>();
        oldPropMap.put(prop.Id, prop);
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.Deviation_on_Payment_Plan__c = true;
        offer.Remarks_For_Deviation__c = 'test Remarks_For_Deviation__c>>>>';
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
        appBook.PropStrength__Active__c = false;
        appBook.PropStrength__Property__c = prop.Id;
        insert appBook;
        
        prop.PropStrength__Super_Area__c = 2;
        prop.New_Super_Area__c = 1000;
        prop.PropStrength__Allotted__c = true;
        List<PropStrength__Property__c>  newList2 = new List<PropStrength__Property__c>();
        newList2.add(prop);
        
        PropertyTriggerHelper.showErrorOnNewSA(newList2, oldPropMap);
        try{
            update prop;
        }
        catch(exception e) {
            System.debug('E>>>>>>>>>>>>>>>>>>>'+e);
        }
        
        List<PropStrength__Property__c>  newList = new List<PropStrength__Property__c>();
        newList.add(prop);
        PropertyTriggerHelper.unLockAllBookings(newList, oldPropMap);
        PropertyTriggerHelper.runapprovalProcessOnAllotedCB(newList, oldPropMap);
        PropertyTriggerHelper.showErrorOnNewSA(newList, oldPropMap);
        PropertyTriggerHelper.sendMailOnSaleableChange(newList, oldPropMap);
    }
    
}