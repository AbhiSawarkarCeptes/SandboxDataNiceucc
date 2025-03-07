@isTest
public class SendDemandLetterBatch_Test {
     @TestSetup static void setup(){
          
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
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
        insert appBook;
        
        PropStrength__Received_Payment__c recPay = TestDataFactorySobha.createPayment(null);
        insert recPay;
        
        PropStrength__Transaction_Requests__c trRec = TestDataFactorySobha.createTransactionRequest(null);
        
        trRec.Upkeep_Charges__c = NULL;
        trRec.Refurbishment_Charges_Batch__c = NULL;
        trRec.Handover_Completed_Date__c = NULL;
        trRec.Handover_Notice_Sent_Date__c = Date.Today().addDays(-40);
        insert trRec;
     
     }
     
      @isTest
    Public  static void SendDemandLetterBatchTest(){
        
        SendDemandLetterBatch sb = new SendDemandLetterBatch();
        Database.executeBatch(sb);
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, sb); 
     }
     
       @isTest
    Public  static void SendDemandLetterBatchTest2(){
           Test.startTest();
         List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Customer_Transfer_Type__c FROM PropStrength__Transaction_Requests__c];
         trList[0].Refurbishment_Charges_Batch__c = 0;
         trList[0].Handover_Notice_Sent_Date__c = Date.Today().addDays(-100);
         UPDATE trList;
        SendDemandLetterBatch sb = new SendDemandLetterBatch();
        Database.executeBatch(sb);
        Test.stopTest();
        
     }
     
      @isTest
    Public  static void SendDemandLetterBatchTest3(){
           Test.startTest();
         List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Customer_Transfer_Type__c FROM PropStrength__Transaction_Requests__c];
         trList[0].Refurbishment_Charges_Batch__c = 1;
         trList[0].Handover_Notice_Sent_Date__c = Date.Today().addDays(-130);
         UPDATE trList;
        SendDemandLetterBatch sb = new SendDemandLetterBatch();
        Database.executeBatch(sb);
        Test.stopTest();
        
     }
     
       @isTest
    Public  static void SendDemandLetterBatchTest4(){
           Test.startTest();
         List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Customer_Transfer_Type__c FROM PropStrength__Transaction_Requests__c];
         trList[0].Refurbishment_Charges_Batch__c = 0;
         trList[0].Handover_Notice_Sent_Date__c = Date.Today().addDays(-375);
         UPDATE trList;
         
         PropStrength__Property__c prRecord = [SELECT Id,PropStrength__Category__c FROM PropStrength__Property__c];
         prRecord.PropStrength__Category__c = 'Plots';
         UPDATE prRecord;
         
        SendDemandLetterBatch sb = new SendDemandLetterBatch();
        Database.executeBatch(sb);
        Test.stopTest();
        
     }
     
      @isTest
    Public  static void SendDemandLetterBatchTest5(){
           Test.startTest();
         List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Customer_Transfer_Type__c FROM PropStrength__Transaction_Requests__c];
         trList[0].Refurbishment_Charges_Batch__c = 1;
         trList[0].Handover_Notice_Sent_Date__c = Date.Today().addDays(-405);
         UPDATE trList;
         
         PropStrength__Property__c prRecord = [SELECT Id,PropStrength__Category__c FROM PropStrength__Property__c];
         prRecord.PropStrength__Category__c = 'Plots';
         UPDATE prRecord;
         
        SendDemandLetterBatch sb = new SendDemandLetterBatch();
        Database.executeBatch(sb);
        Test.stopTest();
        
     }
}