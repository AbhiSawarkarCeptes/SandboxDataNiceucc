@IsTest
public class SRCustomer_Copy_Test {
    @testSetup
    static void setup() {
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
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
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
        insert book;
        
        Attachment attachment = new Attachment();
        attachment.ParentId = proj.Id;
        attachment.Name = 'POA';
        attachment.Body = Blob.valueOf('Test');
        insert attachment;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay);
        
        PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Late Payment Fee', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay4);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
        payList.add(pay3);
        
        PropStrength__Received_Payment__c pay5 = new PropStrength__Received_Payment__c(PropStrength__Payment_Plan_Detail__c = ppd1.Id, PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay5);
        
        insert payList;
    }
    
    @IsTest
    static void testConstructor() {
        Test.setCurrentPageReference(new PageReference('/'));
        SRCustomer_Copy src1 = new SRCustomer_Copy();
        
        PageReference pr = new PageReference('/?erId=testReference');
        Test.setCurrentPageReference(pr);
        SRCustomer_Copy src2 = new SRCustomer_Copy();
    }
    
    @IsTest
    static void testCaptchaSucceeded() {
        PageReference pr = new PageReference('/?erId=testReference');
        Test.setCurrentPageReference(pr);
        SRCustomer_Copy src = new SRCustomer_Copy();
        src.captchaSucceeded();
    }
    
    @IsTest
    static void testSendOTP() {
        PageReference pr = new PageReference('/?erId=testReference');
        Test.setCurrentPageReference(pr);
        SRCustomer_Copy src = new SRCustomer_Copy();
        src.captchaSucceeded();
        src.sendOTP();
    }
    
    @IsTest
    static void testVerifyOTP() {
        PageReference pr = new PageReference('/?erId=testReference');
        Test.setCurrentPageReference(pr);
        
        SRCustomer_Copy src = new SRCustomer_Copy();
        src.captchaSucceeded();
        src.sendOTP();
        
        src.enteredOtp = '123456';
        
        Blob aesKey = Crypto.generateAesKey(128); 
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', aesKey, Blob.valueOf('001XXXXXXXXXXXXXXX')); // Example ID
        String externalReference = EncodingUtil.convertToHex(encrypted);
        
        External_Reference_Register__c err = new External_Reference_Register__c(
            Internal_Reference__c = [Select id from PropStrength__Received_Payment__c Where RecordType.Name = 'Payment Received'][0].Id, // This is a text field
            External_Reference__c = 'testReference',
            Verification_Code__c = '123456',
            Encryption_Key_Size__c = 128, // Example key size
            Encryption_Key__c = EncodingUtil.convertToHex(aesKey),
            Entry_Creation_DateTime__c = System.now(),
            Entry_Expiration_DateTime__c = System.now().addHours(1) // Example expiration
        );
           
        insert err;
                
        Test.startTest();
        src.verifyOTP();
        Test.stopTest();
    }
    
}