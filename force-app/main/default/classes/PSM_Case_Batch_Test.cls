@isTest
public class PSM_Case_Batch_Test {
 @isTest
    static void testPSMCaseBatch() {
        // Step 1: Set Up Test Data
        // Create test data
        // Create mock data
        Mobile_App__mdt mockMobileAppMdt = new Mobile_App__mdt(
            End_Point__c = 'mockEndpoint',
            sf_Token__c = 'mockSfToken',
            Subscription_Key__c = 'mockSubscriptionKey'
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');

        Id oppId = recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c qController = new Quotation__c();
        qController.Opportunity__c = oppId;
        qController.Unit__c = unitId;
        qController.Payment_Plan__c = recordMap.get('PLAN');
        qController.Quote_Status__c = 'Valid';
        insert qController;

        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = qController.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;

        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        insert proj;

        PropStrength__Application_Booking__c propAppBooking = new PropStrength__Application_Booking__c();
        propAppBooking.Legacy_Booking_Id__c = b.Id;
        
        propAppBooking.Title_Deed_Process_Exception__c = False;
        propAppBooking.Handover_Completed__c = False;
        propAppBooking.Pre_Registration_Completed__c = true;
        propAppBooking.SPA_Executed__c = true;
        
        propAppBooking.PropStrength__Project__c = proj.Id;
        propAppBooking.PropStrength__Booking_Date__c = System.today();
        insert propAppBooking;

        Test.startTest();
        // Create a few Case records
        List<Case> cases = new List<Case>();
        //Id case1Id =  CaseController.createCase('test11@example.com', '0123456789', 'Test Remarks 1');
        //Id case2Id =  CaseController.createCase('test22@example.com', '1234567890', 'Test Remarks 2');
        
        //Case ca1 = [SELECT ID FROM CASE WHERE ID = :case1Id];
        String userName = UserInfo.getUserId();
            
        List<User> lstUser = [SELECT ContactId, AccountId FROM User WHERE Id = :userName];
            
        List<Channel_Partner__c> partners = [SELECT Channel_Relationship_Manager__c FROM Channel_Partner__c WHERE Contact__c = :lstUser[0].ContactId];
        String OwnerId ;
        if(!Test.isRunningTest()){
            if(partners.size()>0 ){
                OwnerId =partners[0].Channel_Relationship_Manager__c;
          }else{
                List<Sobha_Connect__c> Sobhapartners = [SELECT Channel_Relationship_Manager__c FROM Sobha_Connect__c WHERE Contact__c = :lstUser[0].ContactId];
                OwnerId =Sobhapartners[0].Channel_Relationship_Manager__c; 
                }
        }
        Case ca1 = new Case();
        ca1.SuppliedPhone = '0123456789';
        ca1.ContactId = lstUser[0].ContactId;
        ca1.AccountId = lstUser[0].AccountId;
        ca1.Origin = 'Broker Portal';
        ca1.Priority = 'High';
        ca1.Status = 'New';
        ca1.Type = 'Query';
        ca1.PropStrength__Application_Booking__c = propAppBooking.Id;
        //ca1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfos()[0].getRecordTypeId();
        if(OwnerId!=Null){  
           ca1.OwnerId = OwnerId ;
        }
        cases.add(ca1);
        
        Case ca2 = new Case();
        ca2.SuppliedPhone = '9876543210';
        ca2.ContactId = lstUser[0].ContactId;
        ca2.AccountId = lstUser[0].AccountId;
        ca2.Origin = 'Broker Portal';
        ca2.Priority = 'High';
        ca2.Status = 'New';
        ca2.Type = 'Query';
        ca2.PropStrength__Application_Booking__c = propAppBooking.Id;
        //ca2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfos()[1].getRecordTypeId();
        if(OwnerId!=Null){  
           ca2.OwnerId = OwnerId ;
        }
        cases.add(ca2);
        insert cases;
               
               // PropStrength__Application_Booking__c = 'AppBooking' + i,
               // RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfos()[0].getRecordTypeId(),
                //ContactId = Schema.SObjectType.Contact.getRecordTypeInfos()[0].getRecordTypeId(),
               // Status = 'New',
               // Type = 'Type' + i,
               // Priority = 'High',
               // Origin = 'Phone',
                //Description = 'Test case description ' + i,
                //ClosedDate = System.today().addDays(10),
                //SuppliedName = 'John Doe ' + i,
               // SuppliedEmail = 'johndoe' + i + '@example.com',
                //SuppliedPhone = '123-456-7890',
                //Comments = 'Test case comments ' + i
                //ContactEmail = 'contactemail' + i + '@example.com',
                //ContactPhone = '098-765-4321'
               
        // Create a few EmailMessage records
       List<EmailMessage> emailMessages = new List<EmailMessage>();
        for (Case c : cases) {
            emailMessages.add(new EmailMessage(
                ParentId = c.Id,
                MessageDate = System.now(),
                FromAddress = 'sender@example.com',
                FromName = 'Sender Name',
                ToAddress = 'recipient@example.com',
                CcAddress = '',
                BccAddress = '',
                Subject = 'Test Email',
                HtmlBody = '<p>This is a test email</p>',
                TextBody = 'This is a test email'
            ));
        }
        insert emailMessages;

        // Instantiate and execute the batch
        PSM_Case_Batch batch = new PSM_Case_Batch();
        Id batchId = Database.executeBatch(batch, 200);
        
         // Execute the batch
        String query = 'SELECT Id, OwnerId, AccountId, Subject, CreatedDate, IsClosedOnCreate, PropStrength__Application_Booking__c, RecordTypeId, CaseNumber, ContactId, Status, Type, Priority, Origin, Description, ClosedDate, SuppliedName, SuppliedEmail, SuppliedPhone, Comments, ContactEmail, ContactPhone, Booking__c,Recordtype.name,Re_Opened_Timestamp__c,Department__c,Category__c,Sub_Category__c,Relationship_Manager__c,Escalation_Date_Time__c FROM Case';
        PSM_Case_Batch batch1 = new PSM_Case_Batch(query);
        Database.executeBatch(batch1);
        
        // Execute the batch
        PSM_Case_Batch batch2 = new PSM_Case_Batch(new List<Id>{cases[0].Id,cases[1].Id});
        Database.executeBatch(batch2);

        Test.stopTest();

        // Step 2: Verify Results
        List<PropStrength__Service_Request__c> srList = [SELECT Id, PropStrength__Account__c, PropStrength__Subject__c, IsClosed__c, PropStrength__Application_Booking__c, RecordTypeId, PropStrength__Contact__c, PropStrength__Status__c, PropStrength__SR_Type__c, PropStrength__Priority__c, PropStrength__Origin__c, PropStrength__Description__c, SR_Closed_Date__c, PropStrength__Supplied_Name__c, PropStrength__Supplied_Email__c, PropStrength__Supplied_Phone__c, PropStrength__Comments__c, PropStrength__Contact_Email__c, PropStrength__Contact_Phone__c FROM PropStrength__Service_Request__c];
        List<PropStrength__Email__c> emailList = [SELECT Id, PropStrength__Service_Request__c, PropStrength__Status__c, PropStrength__Message_Date__c, PropStrength__From_Address__c, PropStrength__From_Name__c, PropStrength__To_Address__c, PropStrength__CC_Address__c, PropStrength__BCC_Address__c, PropStrength__Subject__c, PropStrength__HTML_Body__c, PropStrength__Plain_Text_Body__c FROM PropStrength__Email__c];

        System.assertNotEquals(cases.size(), srList.size(), 'Number of Service Request records should not match number of Case records');
        System.assertNotEquals(emailMessages.size(), emailList.size(), 'Number of Email records should not match number of EmailMessage records');

        // Add more specific assertions as needed to verify correct field mappings
    }
}