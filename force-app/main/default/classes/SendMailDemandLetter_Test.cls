@isTest
public class SendMailDemandLetter_Test {     
    @isTest
    public static void testMathod() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
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
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        pay.PropStrength__Actual_Payment_Date__c = System.today().addDays(2);
        insert pay;
        pay.PropStrength__Actual_Payment_Date__c = System.today().addDays(2);
        Map<Id, PropStrength__Application_Booking__c> appBookMap;
        appBookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id, PropStrength__Applicant_Acc__r.Email, PropStrength__Applicant_Acc__r.Name FROM PropStrength__Applicant_Details__r) FROM PropStrength__Application_Booking__c]);
       
        List<PropStrength__Received_Payment__c> recPayment = [SELECT Id,PropStrength__Actual_Payment_Date__c FROM PropStrength__Received_Payment__c WHERE Id =: pay.Id];
         Set<Id> recPayIds =  new Set<Id>();
        for(PropStrength__Received_Payment__c recPayRecord : recPayment){
            recPayIds.add(recPayRecord.Id);
        }
        SendMailDemandLetter sb = new SendMailDemandLetter(recPayIds,appBookMap);
        Database.executeBatch(sb);
        Test.stopTest();
        
     }
}