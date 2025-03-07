@isTest
public class BRPortalLoginController_Test {
    @isTest static void loginTest1(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.login();
        Test.stopTest();
    }
    
    @isTest static void loginTest2(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.username = 'Test Username';
        loginObj.password = 'Test Password';
        loginObj.login();
        Test.stopTest();
    }
    
    @isTest static void forgotPasswordTest1(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.forgotPassword();
        Test.stopTest();
    }
    
    @isTest static void forgotPasswordTest2(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.usernameForgot = 'Test Username';
        loginObj.forgotPassword();
        Test.stopTest();
    }
    
    @isTest static void getEncodedSiteUrlTest(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.getEncodedSiteUrl();
        Test.stopTest();
    }
    
    @isTest static void getEncodedStartUrlTest(){
        Test.startTest();
        BRPortalLoginController loginObj = new BRPortalLoginController();
        loginObj.getEncodedStartUrl();
        Test.stopTest();
    }    
}