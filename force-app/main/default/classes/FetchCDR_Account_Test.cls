@isTest
public Class FetchCDR_Account_Test{
  public static testMethod void testAutoPopulateNumbers() {
    Test.startTest();
    
    User u = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'Presales'].Id,
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'puser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US');
     u.ManagerId = userInfo.getUserId();
     insert u; 
     System.runAs(u){
      Account acc = new Account();
      acc.Name = 'Test Account';
      acc.Primary_Number__c = '98762342';
      insert acc;
      
      update acc;
     }
    Test.stopTest();
  }
}