/*********************************************************************
 * Class Name  :   BrokerDetailFormController_Test
 * Description :   Test class for the BrokerDetailFormController Class
 * Created Date:   07/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 07/07/2023
 *********************************************************************/
@isTest
public class BrokerDetailFormController_Test {

    @testSetup 
    static void setupDate() {
       User u = TestDataFactorySobha.createUser(null);
       insert u;

       Account acc = BrokerDetailFormController.accountRecMethod('true','Company', String.ValueOf(u.ID), '','Test Account1','125245', 'Channel Partner','','1236789','test1@gamil.com', '1112331','','01/01/2025','01/01/2026','test1@gamil.com', '{"1":"{"FirstName":"","LastName":"test","Email":"","Phone":""}"}','+91','US','Test1@gamil.com');
    }

    @isTest
    static void testMethod1() {

       User u = TestDataFactorySobha.createUser(null);
       insert u;

       Account acc = BrokerDetailFormController.accountRecMethod('true','Company', String.ValueOf(u.ID), '','Test Account','125145', 'Channel Partner','','123456789','test@gamil.com', '11111','','01/01/2025','01/01/2026','test@gamil.com', '{"1":"{"FirstName":"","LastName":"test","Email":"","Phone":""}"}','+91','US','Test@gamil.com');
       String st = BrokerDetailFormController.registartionNoValidate('1112331');

    }
    
    @isTest
    static void testSendMailToChannelPartner() {
       Account acc = [SELECT Id FROM Account LIMIT 1];
       Test.StartTest();
           BrokerDetailFormController.sendMailToChannelPartner(acc.Id);
       Test.StopTest();
    }  
    
    
    @isTest
    static void testformatDate(){
       String dateStr = '01-01-2026';
       Test.StartTest();
          String str = BrokerDetailFormController.formatDate(dateStr);
       Test.StopTest();
    }
    
    @isTest
    static void testGetChrmEmail(){
       Test.StartTest();
          String str = BrokerDetailFormController.getChrmEmail(Userinfo.getUserId());
       Test.StopTest();
    }
    
    @isTest
    static void testSearchSalesManager(){
       User u = [SELECT ID,Name FROM User LIMIT 1];
       Test.StartTest();
          List<User> usr= BrokerDetailFormController.searchSalesManager(u.Name);
       Test.StopTest();
    }
}