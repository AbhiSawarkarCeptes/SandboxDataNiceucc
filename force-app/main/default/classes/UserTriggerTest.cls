@isTest
private class UserTriggerTest {

    @isTest
    static void testUserDeactivationWithLeadsOpps() {
        // Query existing Presales rolePresales Agent
        UserRole presalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Presales_Agent' LIMIT 1];

        
         // Create users with Presales profile
        Profile presalesProfile = [SELECT Id FROM Profile WHERE Name = 'Presales' LIMIT 1];
        Profile presalesHeadProfile = [SELECT Id FROM Profile WHERE Name = 'Presales Head' LIMIT 1];

         // Create Presales Head user
        User presalesHead = new User(
            FirstName = 'Presales',
            LastName = 'Head',
            Email = 'presaleshead@example.com',
            ProfileId = presalesHeadProfile.Id,
            IsActive = true,
            Username = 'presaleshead@example.com',
            Alias = 'preHd',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles'           
        );
        insert presalesHead;

       
        User user1 = new User(
            FirstName = 'TSA',
            LastName = 'User1',
            Email = 'preSalesUser1@example.com',
            ProfileId = presalesProfile.Id,
            UserRoleID = presalesRole.Id,
            IsActive = true,
            ManagerId = presalesHead.Id,
            Username = 'preSalesUser1@example.com',
            Alias = 'preS1',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles'        

           
        );
        insert user1;
          system.debug('owner:'+user1.ID);

        User user2 = new User(
            FirstName = 'TSA',
            LastName = 'User2',
            Email = 'preSalesUser2@example.com',
            ProfileId = presalesProfile.Id,
            UserRoleID = presalesRole.Id,
            IsActive = true,
            ManagerId = presalesHead.Id,
            Username = 'preSalesUser2@example.com',
            Alias = 'preS2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles' 
            
        );
        insert user2;
       
        User user3 = new User(
            FirstName = 'TSA',
            LastName = 'User3',
            Email = 'preSalesUser3@example.com',
            ProfileId = presalesProfile.Id,
            UserRoleID = presalesRole.Id,
            IsActive = true,
            ManagerId = presalesHead.Id,
            Username = 'preSalesUser3@example.com',
            Alias = 'preS3',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles' 
            
        );
        insert user3;


       
        // Create leads and opportunities owned by User1

               
         List<Lead> leads = new List<Lead>();

        
        system.runAs(new User(Id = UserInfo.getUserId())) {
            leads = TestDataFactory.createLead(10);
            // account creation 
             Account acc = new Account();
             acc.FirstName = 'Shock';
             acc.LastName = 'Wave';
             acc.Correspondence_Address__c = 'Delhi';
             acc.Category__c = 'General';
        
            insert acc;
        
        	List<Opportunity> opps = new List<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.name='Test 1';
            opp.StageName='Qualification';
            opp.CloseDate=system.today();
            opp.Status__c ='Active';
            opp.Sales_Manager__c = 'SM2@g.com';
            opp.Walk_in_Source__c =  'Self-Initiative'; 
            opp.Channel_Partner_Contact_Person__c = 'Test New'; 
            opp.presales_agent__c = user1.Id;
            opp.ownerId=user1.Id;
            opp.AccountId = acc.Id;
        	 opps.add(opp);
            
            Opportunity opp1 = new Opportunity();
            opp1.name='Test 1';
            opp1.StageName='Qualification';
            opp1.CloseDate=system.today();
            opp1.Status__c ='Active';
            opp1.Sales_Manager__c = 'SM2@g.com';
            opp1.Walk_in_Source__c =  'Self-Initiative'; 
            opp1.Channel_Partner_Contact_Person__c = 'Test New'; 
            opp1.presales_agent__c = user1.Id;
            opp1.ownerId=user1.Id;
            opp1.AccountId = acc.Id;
        		opps.add(opp1); 
            insert opps;
            
        
        List<Lead> leadToUpdateOwner = new List<Lead>();
       
        //change lead owners
       for( Lead  lead : leads){
           lead.OwnerId=user1.Id;
           lead.presales_agent__c=user1.Id;
           lead.Last_Call_Attempt_Status__c =' new Lead';
           lead.status = 'Open';
           leadToUpdateOwner.add(lead);
        }
       update leadToUpdateOwner;
                system.debug('leads:'+ [SELECT Id, OwnerId FROM Lead WHERE IsConverted = FALSE
                                    AND Presales_Agent__c = :user1.id 
                                    AND (Last_Call_Attempt_Status__c != 'Junk Lead' OR Status != 'Junk Lead')]);
        
        
		Test.startTest();

        // Deactivate User1 or User2 (or both) to simulate user deactivation
        system.runAs(new User(Id = UserInfo.getUserId())) {
            user1.IsActive = false;
            update user1;
        }

        Test.stopTest();
     }
        //assertion to check if Lead owner changed
        List<Lead> changedLeads = [SELECT Id, OwnerId,Presales_Agent__c FROM Lead ];
          System.assertEquals(true,user1.ID != changedLeads[0].ownerId,'User not changed on lead');
        
        //assertion to check if Opportunity reassigned
        List<Opportunity> changedOpps = [SELECT Id, OwnerId,Account.ownerId,Presales_Agent__c FROM Opportunity ];
                     system.debug('oppowner:'+changedOpps[0].presales_Agent__c);
       
        System.assertEquals(true,user1.ID != changedOpps[0].presales_Agent__c,'PresalseAgent not changed on Opportunity');
        System.assertEquals(true,user1.ID != changedOpps[0].Account.ownerId,'Account owner not changed on Opportunity');
    }
}