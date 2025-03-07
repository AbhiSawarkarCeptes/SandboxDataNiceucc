@isTest
public class SVsearchController_Test {
    @isTest
    public static void TestSVsearchControllerID(){
        PropStrength__Projects__c propProject = TestDataFactorySobha.createProject(null);
        insert propProject;
        
        SVsearchController sc = new SVsearchController();
        sc.strProjectId = '';
        sc.MobilePhone = '123456789';
        sc.Email = 'test123@gmail.com';
        sc.enqSource = 'rtyuihjk';
        sc.strError = 'Please Select A Project';
        
        PageReference pref = sc.searchAllLead();       
        
        Test.startTest();
        SVsearchController sv = new SVsearchController();
        Test.stopTest();
    }
    @isTest
    public static void TestSVsearchControllerEmail(){
        PropStrength__Projects__c propProject = TestDataFactorySobha.createProject(null);
        insert propProject;
        
        SVsearchController sc = new SVsearchController();
        sc.strProjectId = propProject.Id;
        sc.MobilePhone = '';
        sc.Email = 'test123@gmail.com';
        sc.enqSource = 'rtyuihjk';
        sc.strError = 'Please Enter Mobile Number';
        
        PageReference pref = sc.searchAllLead();       
        
        Test.startTest();
        SVsearchController sv = new SVsearchController();
        Test.stopTest();
    }
    @isTest
    public static void TestSVsearchControllerPhone(){
        PropStrength__Projects__c propProject = TestDataFactorySobha.createProject(null);
        insert propProject;
        
        SVsearchController sc = new SVsearchController();
        sc.strProjectId = propProject.Id;
        sc.MobilePhone = '123456789';
        sc.Email = '';
        sc.enqSource = 'rtyuihjk';
        sc.strError = 'Please Enter Email Address';
        
        PageReference pref = sc.searchAllLead();       
        
        Test.startTest();
        SVsearchController sv = new SVsearchController();
        Test.stopTest();
    }
    @isTest
    public static void TestSVsearchControllerEndSource(){
        PropStrength__Projects__c propProject = TestDataFactorySobha.createProject(null);
        insert propProject;
        
        SVsearchController sc = new SVsearchController();
        sc.strProjectId = propProject.Id;
        sc.MobilePhone = '123456789';
        sc.Email = 'test123@gmail.com';
        sc.enqSource = '';
        sc.strError = 'Please Enter Enquiry Source';
        
        PageReference pref = sc.searchAllLead();       
        
        Test.startTest();
        SVsearchController sv = new SVsearchController();
        Test.stopTest();
    }
    @isTest
    public static void TestSVsearchControllerEndCase(){
        PropStrength__Projects__c propProject = TestDataFactorySobha.createProject(null);
        insert propProject;
        
        SVsearchController sc = new SVsearchController();
        sc.strProjectId = propProject.Id;
        sc.MobilePhone = '123456789';
        sc.Email = 'test123@gmail.com';
        sc.enqSource = 'rtyuijk';
        //sc.strError = 'Please Enter Enquiry Source';
        List<PropStrength__Request__c> enq = [SELECT Id, PropStrength__Primary_Contact__c FROM PropStrength__Request__c WHERE PropStrength__Project__c = :propProject.Id AND PropStrength__Primary_Contact__r.Email = : sc.Email AND PropStrength__Primary_Contact__r.MobilePhone = : sc.MobilePhone ANd PropStrength__Request_Source__c = : sc.enqSource];
        PageReference pref = sc.searchAllLead();       
        
        Test.startTest();
        SVsearchController sv = new SVsearchController();
        Test.stopTest();
    }
}