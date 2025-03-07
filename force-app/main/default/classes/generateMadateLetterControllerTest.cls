@isTest
public class generateMadateLetterControllerTest 
{
	 @isTest static void setup() 
     {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        chPartner.Seller_Representative__c = UserInfo.getUserId();
        insert chPartner;
        Sobha_Connect__c scPartner = new Sobha_Connect__c();
        scPartner.Name__c = 'Test Sobha';
         scPartner.Mobile_No__c = '9550898778';
         scpartner.Address__c = 'test';
         //scpartner.Agreement_Date__c = System.today();
         scpartner.Email_Id__c='test1@test1.com';   
         insert scpartner;
        Test.startTest();
         generateMadateLetterController.sendpolicyLetter(new List<Id>{chPartner.id});
         GenerateMandateLetterSCController.sendpolicyLetter(new List<Id>{scPartner.id});
        Test.stopTest();
     }
}