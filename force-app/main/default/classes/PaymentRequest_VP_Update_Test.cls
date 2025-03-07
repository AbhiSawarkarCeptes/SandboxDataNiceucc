@isTest public class PaymentRequest_VP_Update_Test {
    
     @isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordMap.get('UNIT');
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true); 
        insert contentVersion;
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request__c pr = [select Id, Payment_Request_Wrapper__c from Payment_Request__c Limit 1];
        pr.Mode_Option__c = 'Multi Mode';
        pr.Status__c = 'Approved';
        
        PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'United Arab Emirates',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined','false###false###false###false','','','','','','','test######102',false,false,'Marketing#Digital','');
        Payment_Request__c pr1 = [select Id, Payment_Request_Wrapper__c from Payment_Request__c where id !=: pr.id];
        Test.startTest();
         
        list<Payment_Request__c> tmpList = [SELECT Id,VP_For_PR__c,CreatedById FROM Payment_Request__c where Id =:  pr1.Id];
        List<Id> prIdList = new List<Id>();
        for(Payment_Request__c prtest : tmpList){
             prIdList.add(prtest.id);
         }

        PaymentRequest_VP_Update batchInstance = new PaymentRequest_VP_Update(prIdList);

        Database.QueryLocator batchStart = batchInstance.start(null);
        batchInstance.execute(null, tmpList);
        System.assertNotEquals(null, batchStart, 'Batch start method should return a QueryLocator');
        Test.stopTest();
    }

}