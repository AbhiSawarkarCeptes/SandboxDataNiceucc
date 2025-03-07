@isTest
public class Test_MB_Mobile_CreateLead {
    
    @TestSetup
    static void testSetup(){
        Project__c pr = new Project__c();
        pr = Mobile_TestUtil.createProject();   
        
        Tower__c tw = new Tower__c ();
        tw = Mobile_TestUtil.createTower(pr.id);
        
        List<Unit__c> unitsList = new List<Unit__c>();
        Unit__c ut = new Unit__c();
        ut = Mobile_TestUtil.createUnit(pr.id,tw.id);  
        unitsList.add(ut);
        
        Unit__c ut1 = new Unit__c();
        ut1 = Mobile_TestUtil.createUnit(pr.id,tw.id);  
        unitsList.add(ut1);
        insert unitsList;
        
        ProjectCharges__c pc = new ProjectCharges__c(Name = 'Basic', Project__c = pr.id, Tower__c = tw.id, active__c = true);
        insert pc;
        
        Payment_Plan__c ppl = new Payment_Plan__c(NoofMilestones__c = 1, Tower__c = tw.id, Status__c = 'Valid', Name = 'Standard Payment Plan');
        insert ppl;
        
        Lead ld = new Lead(LastName='TestLead1', Email='testlead@teser.co');
        insert ld;
    }
    
    @isTest
    static void testMethod1() {
        List<Unit__c> unitList = [Select Id,Tower__c from Unit__c];
        
        Mobile_CreateLead.LeadWrapper qwrap = new Mobile_CreateLead.LeadWrapper();
        qwrap.unitId = unitList[0].Id;
        qwrap.towerId = unitList[0].Tower__c;
        String jsonBody = JSON.serialize(qwrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/registeruser'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res; 
        Test.startTest();
        Mobile_CreateLead.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void testMethodNoUnit() {
        List<Unit__c> unitList = [Select Id,Tower__c from Unit__c];
        
        Mobile_CreateLead.LeadWrapper qwrap = new Mobile_CreateLead.LeadWrapper();
        qwrap.countryCode = '+9710';
        qwrap.mobile = '0503609050';
        qwrap.Email = 'testlead@teser.co';
        qwrap.comments = 'TestComments';
        String jsonBody = JSON.serialize(qwrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/registeruser'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res; 
        Test.startTest();
        Mobile_CreateLead.doPost();
        Test.stopTest();
    }
    
    @isTest
    static void testMethodNoUnitLead() {
        List<Unit__c> unitList = [Select Id,Tower__c from Unit__c];
        
        Mobile_CreateLead.LeadWrapper qwrap = new Mobile_CreateLead.LeadWrapper();
        qwrap.countryCode = '+9710';
        qwrap.mobile = '0503609050';
        qwrap.Email = 'testleads@teser.co';
        qwrap.comments = 'TestComments';
        String jsonBody = JSON.serialize(qwrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/registeruser'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res; 
        Test.startTest();
        Mobile_CreateLead.doPost();
        Test.stopTest();
    }
    
    /*public class QuoteResponseWrapper{
        String towerName;
        String projectName;
        String clusterName;
        String buildingNumber;
        String floorNo;
        String unitType;
        String unitNo;
        String configuration;
        Decimal saleableArea;
        Decimal purchasePrice;
        Decimal preRegistrationFees;
        Decimal preRegistrationCharges;
        Decimal knowledgeFees;
        Decimal oqoodFees;
        //List<PaymentPlanWrapper> payplanDetails;
    }*/

}