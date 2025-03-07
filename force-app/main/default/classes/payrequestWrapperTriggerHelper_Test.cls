@isTest
public class payrequestWrapperTriggerHelper_Test {
	@isTest
    static void testupdateMode(){
        Payment_Request_Wrapper__c wrap = new Payment_Request_Wrapper__c();
        wrap.Mobile_Mode_App__c = 'Website';
        insert wrap;
    }
}