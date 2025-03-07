@isTest
public class BookingApprovalTriggerHandlerTest {
    @isTest
    static void testMethod1() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Account acc = new Account(Name='test acc');
        insert acc;
        profile prof = [select id from profile where name = 'System Administrator'];
        
        User testUserc = new User(
           Alias = 'standard', Email='standarduse1111r@testorg.com',  
           EmailEncodingKey='UTF-8', LastName='Testing11', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = prof.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='testUser111A@testorganise.com'); 
       insert testUserc;
       User usr = new User();
       usr.LastName = 'teststandlead099';
       usr.Alias = 'test111';
       usr.ManagerId = testUserc.id;
       usr.Email = 'abctttt@gmail.com';
       usr.Username = 'abctttt@gmail.com';
       usr.CommunityNickname = 'User16801622611294507700';
       usr.EmailEncodingKey = 'UTF-8';
       usr.LanguageLocaleKey = 'en_US';
       usr.LocaleSidKey = 'en_US';
       usr.ProfileId  = prof.id;
       usr.TimeZoneSidKey  = 'America/New_York';
       
       insert usr;
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        objOpportunity.ownerId = testUserc.id;
        objOpportunity.Secondary_Sales_Manager__c = usr.id;
        insert objOpportunity;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = objOpportunity.id;
        // b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';  
        b.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        insert b;
        
        b.Sales_Managers__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        update b;
        b.SM_SD_Change_Status__c = 'Approved by Saima';
        update b;
        b.SM_SD_Change_Status__c = 'Rejected by Saima';
        update b;
        
    }
}