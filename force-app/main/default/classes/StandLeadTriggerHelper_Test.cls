@isTest
public class StandLeadTriggerHelper_Test {
    @testSetup
    static void setupTestData() {
        // Create test data for Stand_Lead__c objects
        List<Stand_Lead__c> leads = new List<Stand_Lead__c>();
        
        Test.startTest();
       Project__C prj = new Project__C();
       prj.Name = 'Sobha Hartland';
       prj.Project_Code__c = '442';
       insert prj;
      
        leads.add(new Stand_Lead__c(
            FirstName__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com',
            Contact_Number__c = '1234567890',
            Re_Process__c = true,
            Country__c = 'USA',
            Language__c = 'English',
            Interested_Project__c = 'Sobha Hartland',
            Willing_to_meet_this_week__c = 'Yes'
        ));

        leads.add(new Stand_Lead__c(
            FirstName__c = 'Jane',
            Last_Name__c = 'Smith',
            Email__c = 'jane.smith@example.com',
            Contact_Number__c = '0987654321',
            Re_Process__c = true,
            Country__c = 'Canada',
            Language__c = 'French',
            Interested_Project__c = 'Sobha Hartland',
            Willing_to_meet_this_week__c = 'Later'
        ));

        insert leads;
        
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Contact con1 = TestDataFactorySobha.createContact(null);
        con1.VCC1__Email_Encrypted__c = leads[0].Email__c;
        con1.VCC1__Phone_Encrypted__c = null;
        
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.VCC1__Email_Encrypted__c = leads[1].Email__c;
        con2.VCC1__Mobile_Encrypted__c = null;
        
        List<Contact> conList = new List<Contact>{con1,con2};
        
        insert conList;
        
        
    }

    @isTest
    static void testCreateEnquiry() {
		List<Stand_Lead__c> leads = [SELECT Id, FirstName__c, Last_Name__c, Email__c, Enquiry__c,Contact_Number__c, Re_Process__c, Country__c, Language__c, Interested_Project__c, Willing_to_meet_this_week__c, Mobile_Country_Code__c, Promoter__c, Stand_Location__c, Accompanied_By__c, Meeting_Type__c, Tour_Date_Time__c, Sales_manager__c FROM Stand_Lead__c];
        Map<Id, Stand_Lead__c> oldStandMap = new Map<Id, Stand_Lead__c>();

        for (Stand_Lead__c lead : leads) {
            oldStandMap.put(lead.Id, new Stand_Lead__c(
                Id = lead.Id,
                Re_Process__c = false
            ));
        }
		 
        
        
        // Call the createEnquiry method
        Test.startTest();
        update oldStandMap.values();
        StandLeadTriggerHelper.createEnquiry(leads, null);
        Test.stopTest();

    }
}