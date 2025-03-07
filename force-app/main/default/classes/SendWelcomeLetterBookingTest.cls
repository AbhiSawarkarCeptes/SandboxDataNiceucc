@isTest
public class SendWelcomeLetterBookingTest 
{
    @isTest static void setup() 
    {
        List<Demand__c> demandList = new List<Demand__c>();
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;  
        
        // account creation 
        Account objac = new Account();
        objac.FirstName = 'Shock';
        objac.LastName = 'Wave';
        objac.Correspondence_Address__c = 'Delhi';
        objac.Category__c = 'General';
        objac.Unit__c = unitId;
        objac=RDSCommon.CreateAccount(objac);
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Hitesh';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = objac.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Project__c = recordIdMap.get('PROJECT'); 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Booking__c b = new Booking__c();
        
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test1@test1.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        b.Qualification_Date__c = date.today();
        b.Agreement_Value__c =1200000;
        // b.Paid_Amount_For_Process__c = 1000000;
        b.Booking_Approver_Audit__c = 'Accepted';
        b.Welcome_Mail_Sent_Date__c = NULL;
        insert b;
        Receipt__c rec = new Receipt__c();
        rec.Amount_Rs__c=1000000;
        rec.Booking__c = b.Id;
        rec.Receipt_Status__c = 'Cleared';
        rec.Consider_for_Paid_Percentage__c = False;
        rec.Is_Reversed_Receipt__c = False;
        insert rec;
        Booking__C book = [Select id, Name, Paid_Percentage__c from Booking__C];
        
        Booking__C book1 = [SELECT Id, Booking_Approver_Audit__c, Welcome_Mail_Sent_Date__c  FROM Booking__c
                            WHERE Qualification_Date__c = today AND Paid_Percentage__c >= 9.5
                            AND Booking_Approver_Audit__c = 'Accepted' AND Welcome_Mail_Sent_Date__c = NULL] ;
        system.debug('Query:::'+ book1);
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = b.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'First Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        
        insert a1;
        
        Test.startTest();
        
        String cronExp = '0 0 11,20 * * ?'; // Run at 11 AM and 8 PM
        SendWelcomeLetterBookingSch schedulableJob = new SendWelcomeLetterBookingSch();
        System.schedule('Test SendWelcomeLetterBookingSch', cronExp, schedulableJob);
        
        //  SendWelcomeLetterBooking.sendWelcomeLetter(new List<Id>{b.id});
        PageReference testPage = Page.welcomeletterpage;
        testPage.getParameters().put('id', String.valueOf(b.Id));
        Test.setCurrentPage(testPage);
        welcomeLetterController wclc = new welcomeLetterController();
        Test.stopTest();
       /* List<Error_Log__c> logs = [SELECT Id, Class__c, Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'One log should be created');
        System.assertEquals('SendWelcomeLetterBookingBatch -- Success', logs[0].Class__c, 'Log class should match');
        System.assert(logs[0].Message__c.contains(b.Id), 'Log message should contain booking Id');*/
    }
}