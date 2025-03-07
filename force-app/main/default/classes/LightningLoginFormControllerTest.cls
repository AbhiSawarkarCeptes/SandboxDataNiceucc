@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
 @IsTest
 static void testGetForgotPasswordUrl() {
  String result = LightningLoginFormController.getForgotPasswordUrl();
 }

@isTest
    static void testLogin() {
        String testUsername = 'testuser@example.com';
        String testPassword = 'password123';
        String testStartUrl = '/home/home.jsp';

        Test.startTest();
        String result = LightningLoginFormController.login(testUsername, testPassword, testStartUrl);
        Test.stopTest();
    }

    @isTest
    static void testSetExperienceId() {
        String testExpId = '0EXxx0000004CyO';

        Test.startTest();
        String result = LightningLoginFormController.setExperienceId(testExpId);
        Test.stopTest();
    }

}