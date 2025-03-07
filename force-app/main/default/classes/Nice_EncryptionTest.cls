/***************************************************************************
Class  Name    : Nice_EncryptionUtility
Covers         : Nice_EncryptionTest
Author         : Abhijeet
*****************************************************************************/
@isTest
private class Nice_EncryptionTest {
    
    @isTest
    private static void testSuccess() {
        
        Test.startTest();
        
        String phoneNumber = '+918838391997';
        String encryptedNumber = Nice_EncryptionUtility.encryptPhoneNumber(phoneNumber);
        String decryptedNumber = Nice_EncryptionUtility.decryptPhoneNumber(encryptedNumber);
        String randomNum = Nice_EncryptionUtility.generateRandomNumber(5);
        
        Assert.isNotNull(encryptedNumber);
        Assert.isNotNull(randomNum);
      
        Test.stopTest();
        
    }
    
    @isTest
    private static void testFailure() {
        
        Test.startTest();
        
        String encryptedNumber = Nice_EncryptionUtility.encryptPhoneNumber('');
        String decryptedNumber = Nice_EncryptionUtility.decryptPhoneNumber('');
        
        Assert.isNull(encryptedNumber);
        Assert.isNull(decryptedNumber);
        
        try {
            Nice_EncryptionUtility.generateRandomNumber(-1);
        } Catch (Exception ex) {
            Assert.isNotNull(ex);
        }
        
        Test.stopTest();
        
    }
    
}