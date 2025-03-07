@isTest
public class VatUploadController_Test {
    
    @isTest static void uploadFileTest(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Test.startTest();
        VatUploadController.uploadFile('Blob File Content', 'Sample', acc.Id);
        Test.stopTest();
    }
}