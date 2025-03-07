@isTest
public class TowerTriggerHelper_test {
    @TestSetup
    public static void makeData(){
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
        
    }
    
    @isTest
    public static void testUpdate1(){
        List<PropStrength__Tower__c> ptList = [select id, PropStrength__Tower_Name__c from PropStrength__Tower__c];
        for(PropStrength__Tower__c ptc : ptList){
            ptc.PropStrength__Tower_Name__c = ptc.PropStrength__Tower_Name__c + 'TestTowerUpdate';
        }
        
        Amenity__c amt = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Tower_PS__c = ptList[0].Id);
        insert amt;
        
        Attractions__c attr = new Attractions__c(Name ='TestAMT', Attraction_Type__c='Cinemas', Tower_PS__c = ptList[0].Id);
        insert attr;
        update ptLIst;
    }
    
    @isTest
    public static void testUpdate2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<PropStrength__Tower__c> ptList = [select id, PropStrength__Tower_Name__c from PropStrength__Tower__c];
        for(PropStrength__Tower__c ptc : ptList){
            ptc.PropStrength__Tower_Name__c = ptc.PropStrength__Tower_Name__c + 'TestTowerUpdate';
        }
        
        Amenity__c amt = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Tower_PS__c = ptList[0].Id);
        insert amt;
        
        Attractions__c attr = new Attractions__c(Name ='TestAMT', Attraction_Type__c='Cinemas', Tower_PS__c = ptList[0].Id);
        insert attr;
        update ptLIst;
    }
    
    @isTest
    public static void testUpdate3(){
        List<PropStrength__Tower__c> ptList = [select id, PropStrength__Tower_Name__c, PropStrength__Completion_Certificate_Date__c from PropStrength__Tower__c];
        for(PropStrength__Tower__c pt : ptList){
            pt.PropStrength__Completion_Certificate_Date__c = System.now().Date();
        }        
        update ptList;
        
        List<PropStrength__Tower__c> oldPtList = new List<PropStrength__Tower__c>();    
        
        
        oldPtList.addAll(ptList);
        for(PropStrength__Tower__c pt : oldPtList){
            pt.PropStrength__Completion_Certificate_Date__c = System.now().Date().addDays(-7);             
        }        
        TowerTriggerHelper.sendMailForCompletionCertificate(ptList, new Map<Id, PropStrength__Tower__c>(oldPtList));
    }
    
}