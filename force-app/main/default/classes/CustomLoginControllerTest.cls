@isTest
private class CustomLoginControllerTest {

    @isTest
    static void testConstructor() {
        CustomLoginController controller = new CustomLoginController();
        
        System.assertNotEquals(null, controller.orgId, 'Organization Id should not be null');
        System.assertNotEquals(null, controller.siteURL, 'Site URL should not be null');
        System.assertNotEquals(null, controller.startURL, 'Start URL should not be null');
        System.assertNotEquals(null, controller.authProviders, 'Auth providers should not be null');
        // Add more assertions as needed
    }
    
    @isTest
    static void testForgotPassword() {
        CustomLoginController controller = new CustomLoginController();
        // Set up required data for the test
        
        // Test when password is successfully forgotten
        Test.startTest();
        controller.usernameForgot = 'test@example.com';
        controller.forgotPassword();
        Test.stopTest();
        // Assert expected behavior
        
        // Test when password is not successfully forgotten
        // Add more test scenarios as needed
    }
    
    @isTest
    static void testLogin() {
        CustomLoginController controller = new CustomLoginController();
        // Set up required data for the test
        
        // Test login method with valid and invalid credentials
        Test.startTest();
        controller.username = 'test@example.com';
        controller.password = 'testpassword';
        controller.startURL = '/home';
        PageReference result = controller.login();
        Test.stopTest();
        // Assert expected behavior
        
        // Add more test scenarios as needed
    }
    
    @isTest
    static void testGetEncodedSiteUrl() {
        CustomLoginController controller = new CustomLoginController();
        // Set up required data for the test
        
        String encodedSiteUrl = controller.getEncodedSiteUrl();
        // Assert expected behavior
    }
    
    @isTest
    static void testGetEncodedStartUrl() {
        CustomLoginController controller = new CustomLoginController();
        // Set up required data for the test
        
        String encodedStartUrl = controller.getEncodedStartUrl();
       
    }
    
    
    
}