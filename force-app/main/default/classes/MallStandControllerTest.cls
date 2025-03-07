@isTest public class MallStandControllerTest {
    @isTest public static void updateLocationTest(){
        string invoiceFieldJSON = '{"Mall_Name__c":"MOE"}';
        Test.startTest();
        MallStandController.updateLocation(invoiceFieldJSON);
        MallStandController.validateIfLocationUpdated();
        Test.stopTest();
    }
}