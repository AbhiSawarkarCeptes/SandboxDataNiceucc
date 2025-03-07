@isTest
public class StandLeadTriggerTest {
   @IsTest
   static void testStandLeadTrigger(){
       
       Test.startTest();
       Project__C prj = new Project__C();
       prj.Name = 'Sobha Hartland';
       prj.Project_Code__c = '442';
       insert prj;
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u2 = new User(Alias = 'saUser', Email='newuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='saUser@testorg.com');
       
       insert u2;
       //system.runAs(u2){
       Stand_Lead__c sl = new Stand_Lead__c();
       sl.Willing_to_meet_this_week__c = 'No';
       sl.Last_Name__c = 'testing12';
       sl.Email__c = 'abc@gmail.com';
       sl.Mobile_Country_Code__c = '+91';
       sl.Contact_Number__c = '34567898765';
       sl.Nationality__c = 'Indian';
       sl.Sales_manager__c = u2.id;
       
       insert sl;
       Stand_Lead__c s3 = new Stand_Lead__c();
       s3.Willing_to_meet_this_week__c = 'No';
       s3.Last_Name__c = 'testing13';
       s3.Email__c = 'abcd@gmail.com';
       s3.Mobile_Country_Code__c = '+91';
       s3.Contact_Number__c = '3456789765';
       s3.Nationality__c = 'Indian';
       s3.Sales_manager__c = u2.id;
       insert s3;
      
       List<Stand_Lead__c> sllead = [select id , Lead__c from Stand_Lead__c ];
       system.debug('leaddebug' + sllead);
       Shoba_Default_Settings__mdt sobhametadata = [SELECT Mall_Stand_Manager_Id__c,
                                                    QualifiedApiName
                                                    FROM Shoba_Default_Settings__mdt 
                                                    WHERE QualifiedApiName = 'Org_Defaults'
                                                    LIMIT 1];
       
       String standManagerId = sobhametadata.Mall_Stand_Manager_Id__c;
       Test.stopTest();
    
   }
}