@isTest
public class OpportunityTriggerTest {

    @isTest
    static void testInsertOpp() {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System administrator' LIMIT 1];

        // Create Presales Head user
        User managerUser = new User(
            FirstName = 'Manager',
            LastName = 'New',
            Email = 'ManagerNew@example.com.invalid',
            ProfileId = adminProfile.Id,
            IsActive = true,
            Username = 'ManagerNew@example.com.invalid',
            Alias = 'preHd',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles'           
        );
        insert managerUser;
        
        Account acc = new Account(Name='test acc');
        insert acc;
        
        // Call the method to update Lead status
        Test.startTest();
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        objOpportunity.Secondary_Sales_Manager__c = UserInfo.getUserId();
        insert objOpportunity;
        
        objOpportunity.Secondary_Sales_Manager__c = managerUser.Id;
        update objOpportunity;
        
        Test.stopTest();

    }
    
    @isTest
    static void testUpdateLeadStatus() {
        
        Lead lead = new Lead(Last_Call_Attempt_Status__c = 'Not Attempted',LastName ='Web engage', MobilePhone = '0000',Phone = '0001');
        insert lead;
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(lead.id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Call the method to update Lead status
        Test.startTest();
        opp.Last_Call_Attempt_Status__c = 'TEST';
        update opp;
        Test.stopTest();

    }

}