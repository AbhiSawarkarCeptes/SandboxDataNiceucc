@isTest
public class SendBulkHandoverNotice_Test {
      
         @isTest
    Public  static void SendReminderAndExpireEmailTest1(){
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        propType.Upkeep_Charge_Amount_Per_Month__c = 100;
        propType.Refurbishment_Charge_Amount_Per_Month__c = 100;
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Category__c = 'Villas';
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appBook.HO_Appointment_Exception__c = True;
        appBook.Unit_Readiness_Date__c = Date.today();
        appBook.Unit_Handover_Date__c = Date.today().addDays(1);
        appBook.Handover_Notice_Sent__c = false;
        appBook.PropStrength__Primary_Customer__c = cont.Id;
        appBook.Handover_will_be_taken_by__c = 'POA – Owner';
        appBook.POA_Email_Address__c = 'test@gmail.com';
         Test.startTest();
        insert appBook;
        
        List<Id> towerIds = new List<Id>();
        List<PropStrength__Tower__c> towerList = [SELECT Id FROM PropStrength__Tower__c];
        for(PropStrength__Tower__c towerRec : towerList){
            towerIds.add(towerRec.Id);
        }
        
       
        SendBulkHandoverNotice.sendEnvelopeMethod(towerIds);
        }
}