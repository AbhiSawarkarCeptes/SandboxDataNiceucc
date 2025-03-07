@isTest
public Class AutoPopulateNumbers_Test{
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
     u.BitVoice_Agent_Ext__c = '1111';
     insert u; 
     
     System.runAs(u){
     
       Incoming_Call__c ic = new Incoming_Call__c();
       ic.Agent_Extension__c = '1111';
       ic.countryCode__c = '971';
       ic.Phone_Number__c = '0545549067';
       ic.UID__c = '5d1228e446877';
       insert ic;
       System.assertEquals(ic.UID__c,'5d1228e446877');
       List<Lead_Auto_Convert_Status__c> lacList = new List<Lead_Auto_Convert_Status__c>();
        Lead_Auto_Convert_Status__c lac = new Lead_Auto_Convert_Status__c();
        lac.Name = 'home presentation';lacList.add(lac);
        Lead_Auto_Convert_Status__c lac1 = new Lead_Auto_Convert_Status__c();
        lac1.Name = 'meeting fixed';lacList.add(lac1);
        Lead_Auto_Convert_Status__c lac2 = new Lead_Auto_Convert_Status__c();
        lac2.Name = 'office presentation';lacList.add(lac2);
        Lead_Auto_Convert_Status__c lac3 = new Lead_Auto_Convert_Status__c();
        lac3.Name = 'tele-meeting fixed';lacList.add(lac3);
        Lead_Auto_Convert_Status__c lac4 = new Lead_Auto_Convert_Status__c();
        lac4.Name = 'visit confirmed';lacList.add(lac4);
        
        insert lacList;
     
        Lead leadRecord = new Lead();
        leadRecord.lastName = 'Satish';
        leadRecord.MobilePhone = '8987898765';
        leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
        leadRecord.Primary_Number__c = '8976543456';
        insert leadRecord;
        
        Lead temp = [Select Id From Lead Where Id = :leadRecord.Id];
        
        update temp;
        
        //update leadRecord;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadRecord.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
       
    }    
    Test.stopTest();
  }
}