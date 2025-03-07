@isTest
public class FileUploadOnOfferController_Test {
   
    @testSetup
    static void setup() {
      
      User u = TestDataFactorySobha.createUser(null);
      insert u;
      Account acc = TestDataFactorySobha.createAccount(null);
      insert acc;
      
      Contact contRec = TestDataFactorySobha.createContact(null);
      insert contRec;
    
      PropStrength__Request__c enqRec  = TestDataFactorySobha.createEnquiry(null);
      insert enqRec;
      
      PropStrength__Projects__c proStrProj = TestDataFactorySobha.createProject(null);
      insert proStrProj;
      
      PropStrength__Property_Type__c proType = TestDataFactorySobha.createPropertyType(null);
      insert proType;
      
      PropStrength__Tower__c proStrTower = TestDataFactorySobha.createTower(null);
      insert proStrTower;
      
      PropStrength__Property__c proStProperty = TestDataFactorySobha.createProperty(null);
      insert proStProperty;
      
      PropStrength__Payment_Plan__c proPStrPayPlan = TestDataFactorySobha.createPaymentPlan(null);   
      insert proPStrPayPlan;   
      
      PropStrength__Offer__c  proStrOffer = TestDataFactorySobha.createOffer(null);
      insert proStrOffer;
    }
    
    @isTest
    static void testMethodPassport() {  
      PropStrength__Offer__c proStr = [SELECT Id FROM PropStrength__Offer__c LIMIT 1];
      FileUploadOnOfferController.updateOfferFields(proStr.Id,'Passport');
    }
    
    @isTest
    static void testMethodVisa() {  
      PropStrength__Offer__c proStr = [SELECT Id FROM PropStrength__Offer__c LIMIT 1];
      FileUploadOnOfferController.updateOfferFields(proStr.Id,'Visa');
    }
    
    @isTest
    static void testMethodEmirates() {  
      PropStrength__Offer__c proStr = [SELECT Id FROM PropStrength__Offer__c LIMIT 1];
      FileUploadOnOfferController.updateOfferFields(proStr.Id,'Emirates');
    }
}