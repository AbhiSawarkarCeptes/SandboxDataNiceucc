@isTest
public class CustomerRegistrationHandlerTest {

    @isTest
    public static void beforeInsertTest(){
        List<Customer_Registration__c> crList = DataUtility.getSiteVisitForms();
        List<Sobha_Connect__c> scList = DataUtility.getSobhaConnect();
        List<Channel_Partner__c> cpList = DataUtility.getChannelPartner();
        List<Integration_Info__c> cfiList = DataUtility.getCustomer_Registration();
        crList[0].Alternate_Mobile_Number__c = '1111111123';
        crList[0].Sobha_Connect__c = scList[0].Id;
        crList[0].Channel_Partner__c = cpList[0].Id;
        update crList;
    }
    
    @isTest
    public static void testAPI(){
        List<Customer_Registration__c> crList = DataUtility.getSiteVisitForms();
        List<Sobha_Connect__c> scList = DataUtility.getSobhaConnect();
        List<Channel_Partner__c> cpList = DataUtility.getChannelPartner();
        List<Integration_Info__c> cfiList = DataUtility.getCustomer_Registration();
        crList[0].Alternate_Mobile_Number__c = '1111111123';
        crList[0].Sobha_Connect__c = scList[0].Id;
        crList[0].Channel_Partner__c = cpList[0].Id;
        update crList;
        customerregistrationhandler.sendToTokenAPI(crList[0].Id);
    }
}