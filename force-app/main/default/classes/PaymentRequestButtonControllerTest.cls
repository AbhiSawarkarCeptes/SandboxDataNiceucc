@isTest public class PaymentRequestButtonControllerTest {
	@isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion; 
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
        pr.Mode_Option__c = 'Multi Mode';
        pr.Status__c = 'Approved';
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: pr.id];
        PaymentRequestButtonController.confirmAmount(100,'100',String.valueOf(system.today()),pr1.Id);
        PaymentRequestButtonController.resubmitToSM(pr1.Id,'Test');
        PaymentRequestButtonController.updatePaymentRequest(pr1.Id,'Test',String.valueOf(system.today()),'Test');
    }
}