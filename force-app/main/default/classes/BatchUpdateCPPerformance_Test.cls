@istest
public class BatchUpdateCPPerformance_Test {
   @istest
    static void testmethod1(){
       User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        PageReference pRef = Page.CreateQuote;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
        ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
        CreateQuote qController = new CreateQuote();
        qController.startQuote();
        qController.selectedPlan = recordMap.get('PLAN');
        //   qController.continueMethod();
        qController.saveQuote();
             
        Quotation__c q = [Select Id, Name from Quotation__c];
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = q.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.OwnerId = UserInfo.getUserId();

        b.Booking_Approver_Audit__c = 'Accepted';
        b.Agreement_Value__c = 1052700;
        b.Booking_Date_As_Per_The_SBTR__c = System.today().addDays(-5);
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        b.Sobha_Connect__c = sc.Id;
        b.Source_of_Booking__c = 'Sobha Connect';
        b.Qualification_Date__c = system.today();
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        // b.Sobha_Connect__c = null;
         b.Channel_Partner__c = chPartner.Id;
        // b.Source_of_Booking__c = 'Channel Partner';

        insert b;      
        
        test.startTest();
        Opportunity opp = new  Opportunity(id = recordMap.get('OPPORTUNITY'));
        opp.Name = 'Aayushi';
        opp.Walk_In_SC__c = sc.Id;
        opp.date_of_Site_Visit__c = system.today();
        opp.Walk_In_source__c = 'Channel Partner';
        update opp;
       
        Opportunity opp1 = new  Opportunity(id = recordMap.get('OPPORTUNITY'));
        opp1.Name = 'Aayushi';
        opp1.channel_partner__C = chPartner.Id;
        opp1.date_of_Site_Visit__c = system.today().addYEars(-1);
        opp1.Walk_In_source__c = 'Channel Partner';
        update opp1;
        Database.executeBatch(new BatchUpdateCPPerformance(),200);

        Database.executeBatch(new BatchUpdateSCPerformance(),200);
        
        
        test.stopTest();

       
    }
   
    
}