@isTest
public class HandoverOfPossessionDocusignHandler_Test {
    @testSetup
    static void setup() {
        // Create a test booking record
       /* PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c(
            Handover_will_be_taken_by__c = 'Owner – Individual',
            PropStrength__Primary_Customer__c = null, // Add appropriate values here
            PropStrength__Primary_Customer__r = new Account(
                PropStrength__Account_Type__c = 'Individual',
                Name = 'Test Customer',
                Email = 'testcustomer@example.com',
                MobilePhone = '1234567890'
            )
        );
        insert booking;*/
        
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        cont.PropStrength__Account_Type__c = 'Individual';
        cont.MobilePhone = '123456789';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        book.Handover_will_be_taken_by__c = 'Owner – Individual';
        insert book;
        

        // Create a test ContentVersion record
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Sample content for the document'),
            ContentLocation = 'S', // Specify 'S' for Salesforce Files
            ContentDocumentId = null // This will be null when inserting
        );
        insert cv;

        // Create Docusign settings metadata
        
    }

    @isTest
    static void testSendEnvelopeMethod() {
        // Retrieve the test booking
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        // Call the InvocableMethod
        List<Id> bookingIds = new List<Id> { booking.Id };
        Test.startTest();
        HandoverOfPossessionDocusignHandler.sendEnvelopeMethod(bookingIds);
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeMethod2() {
        // Retrieve the test booking
        
        Contact con = [Select Id,PropStrength__Account_Type__c From Contact LIMIT 1];
        con.PropStrength__Account_Type__c = 'Company';
        con.Authorised_Representative_Name__c = 'Test';
        con.Authorised_Representative_Passport_No__c =  '123';
        update con;
        
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        booking.Handover_will_be_taken_by__c = 'Owner – Company';
        update booking;
        // Call the InvocableMethod
        List<Id> bookingIds = new List<Id> { booking.Id };
        Test.startTest();
        HandoverOfPossessionDocusignHandler.sendEnvelopeMethod(bookingIds);
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeMethod3() {
        // Retrieve the test booking
        
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        booking.Handover_will_be_taken_by__c = 'POA – Owner';
        booking.POA_Email_Address__c = 'testmail@test.com';
        booking.POA_Mobile_Number__c = '123456789';
        booking.POA_Name__c = 'test POA';
        update booking;
        // Call the InvocableMethod
        List<Id> bookingIds = new List<Id> { booking.Id };
        Test.startTest();
        HandoverOfPossessionDocusignHandler.sendEnvelopeMethod(bookingIds);
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeMethod4() {
        // Retrieve the test booking
        
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        booking.Handover_will_be_taken_by__c = 'POA – Company';
        booking.POA_Email_Address__c = 'testmail@test.com';
        booking.POA_Mobile_Number__c = '123456789';
        booking.POA_Name__c = 'test POA';
        update booking;
        // Call the InvocableMethod
        List<Id> bookingIds = new List<Id> { booking.Id };
        Test.startTest();
        HandoverOfPossessionDocusignHandler.sendEnvelopeMethod(bookingIds);
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeMethodCatch() {
        // Retrieve the test booking
        
        Contact con = [Select Id,PropStrength__Account_Type__c,MobilePhone From Contact LIMIT 1];
        con.MobilePhone = null;
        update con;
        
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        // Call the InvocableMethod
        List<Id> bookingIds = new List<Id> { booking.Id };
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        HandoverOfPossessionDocusignHandler.sendEnvelopeMethod(bookingIds);
        Test.stopTest();
    }
    
}