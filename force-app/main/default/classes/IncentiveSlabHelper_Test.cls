@IsTest
private class IncentiveSlabHelper_Test {


    @TestSetup static void setup(){
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
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        incSlab.Start_Date__c = Date.today().addDays(-10);
        incSlab.End_Date__c = Date.today().addDays(10);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.Sales_Incentive_Slab__c = incSlab.Id;
        appBook.PropStrength__Broker_Account__c = acc.Id;
        appBook.PropStrength__Booking_Through__c = 'Broker'; 
        insert appBook;
    }

   /* @IsTest
    static void testUpdateIncentivesOnBooking() {
        List<Incentive_Slab__c> newIncentiveList = [SELECT Id FROM Incentive_Slab__c];
        Test.startTest();
        IncentiveSlabHelper.updateIncentivesOnBooking(newIncentiveList);
        Test.stopTest();
    }*/

    @IsTest
    static void testIncentiveSlabValidation() {

        Incentive_Slab__c incentive1 = [SELECT Id FROM Incentive_Slab__c];
        incentive1.RecordTypeId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        update incentive1;

        Incentive_Slab__c incentive2 = TestDataFactorySobha.createIncentiveSlab(null);
        incentive2.Start_Date__c = Date.today().addDays(11);
        incentive2.End_Date__c = Date.today().addDays(20);
        incentive2.RecordTypeId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        insert incentive2;
        
        Map<Id, Incentive_Slab__c> oldIncentiveMap = new Map<Id, Incentive_Slab__c>{incentive1.Id => incentive1};
        
        Test.startTest();
        try{
            IncentiveSlabHelper.incentiveSlabValidation(new List<Incentive_Slab__c>{incentive2}, oldIncentiveMap);
        }
        catch(exception e){
            System.debug(e);
        }
        Test.stopTest();
    }
}