@isTest
public class NOCVFPageController_Test {
    @isTest 
    public static void testMethod1(){
        
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
       
        Test.startTest();      
        PageReference pRef= Page.NOCVFPage;
        Test.setcurrentPage(pRef);
        Apexpages.currentPage().getParameters().put('id', acc.Id);
        NOCVFPageController obj = new NOCVFPageController();
        Test.stopTest(); 
    }
    
    @isTest 
    public static void testMethod2(){
        NOCVFPageController obj = new NOCVFPageController();
    }
    
}