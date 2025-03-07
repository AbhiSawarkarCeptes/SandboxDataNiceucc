@isTest
public class BookingTriggerHelper_Test {
	@isTest
    static void testMethod1() {
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
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        insert uhw;
        
        Payment_Request__c prTest = new Payment_Request__c();
        prTest.Mode__c = 'Credit Card';
        prTest.Status__c = 'Approved';
        prTest.Enquiry__c = enq.Id;
        prTest.Property__c = prop.Id;
        prTest.Offer__c = offer.Id;
        prTest.Mobile_Mode_App__c = 'Website';
        prTest.Mode_Option__c = 'Multi Mode';
        prTest.Towards_Other_Charges_Amount__c = 500;
        prTest.Towards_Pre_Registration_Amount__c = 500;
        prTest.Towards_Unit_Price_Amount__c = 500;
        prTest.Payment_Request_Wrapper__c = uhw.Id;
        prTest.currency__c = 'USD';
        prTest.Amount__c = 500;
        prTest.Enquiry_Source__c = 'Web';
        insert prTest;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,Booked_Date__c = System.Today());
        insert book;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
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
		Test.startTest();        
        insert payList;
        

        BookingTriggerHelper.createRecordIntPay(new List<Payment_Request__c>{prTest});
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        book.PropStrength__Super_Area__c = 1000;
        book.Differentiate_Brokerage_on_Other_Charge__c = 1000;
        book.Home_Orientation_Docs_Received__c = true;
        book.Home_Orientation_Attended_By__c = 'POA';
        book.Home_Orientation_Undertaking_Receive_Dt__c = System.now();
        book.Early_Handover_Approval__c = 'Yes';
        update book;
        book.Home_Orientation_Slot_Status__c = 'Expired';
        book.Slot_Status__c = 'Confirmed';
        book.Current_Cancellation_Status_By_CRM__c = 'Unit Assigned to Sales Ops Team';
        book.Snag_Rectification_Date__c = System.today();
        book.Qualification_Date__c = System.today();
        book.MOU_Transaction_Exception__c = true;
        book.DSPA_Transaction_Exception__c = TRUE;
        book.SPA_Transaction_Exception__c = true;
        book.Booking_Form_Executed__c = true;
            book.Cancellation_Requested__c = true;
         // update book;
        update book;
        
         PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=book.Id);
        
        temp.Oqood_Fees_Received__c = FALSE;
        temp.Noqoodi_Wallet_Ref_No_Approved__c = FALSE;
        temp.SPA_Executed__c = FALSE;
        temp.PCC_Document_Approved__c = FALSE;
        temp.PropStrength__Status__c = '';
        temp.PCC_Status__c = '';
        
        Map<Id, PropStrength__Application_Booking__c> oldMap = new Map<Id, PropStrength__Application_Booking__c>();
        oldMap.put(temp.Id, temp);
        
        System.debug(book);
        System.debug(oldMap);
                
        BookingTriggerHelper.CreateTask(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendEmailOqoodReceived(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendPCC(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.sendMailToApplicantCC(new List<Id>{book.Id});
        BookingTriggerHelper.sendAuthorizationLetterToApplicants(new Set<Id>{book.Id});
        BookingTriggerHelper.sendWelcomeEmailToApplicant(new Set<Id>{book.Id});
        BookingTriggerHelper.sendMailToExecCRMTitleDeed(new Set<Id>{book.Id});
        BookingTriggerHelper.createPCCDocAtt(new Set<Id>{book.Id});
        BookingTriggerHelper.sendMailToDSPAExecCRM(new Set<Id>{book.Id});
        BookingTriggerHelper.channelRelationIncentiveCalc(new List<PropStrength__Application_Booking__c>{book});
        BookingTriggerHelper.updateMarketingIncentive(new List<PropStrength__Application_Booking__c>{book});
        BookingTriggerHelper.sendMailSaleOpsOnCurrentCancellationStatusChange(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10,  Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', Intl_Broker_New_Customer_Inc__c = 10, CMO_Channel_Relations_Split__c = 10,  Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
         acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Mall Stand';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,Booked_Date__c = System.Today());
        insert book;
        
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
        Test.startTest();
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        update book;
        
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.channelRelationIncentiveCalc(new List<PropStrength__Application_Booking__c>{book});
        BookingTriggerHelper.updateMarketingIncentive(new List<PropStrength__Application_Booking__c>{book});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', Marketing_Incentive__c = 10, CMO_Channel_Relations_Split__c = 10,  Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Telesales';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
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
        
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        update book;
        
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.channelRelationIncentiveCalc(new List<PropStrength__Application_Booking__c>{book});
        BookingTriggerHelper.updateMarketingIncentive(new List<PropStrength__Application_Booking__c>{book});
    }
    
    @isTest
    static void testMethod4() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Digital Marketing Sales (Inc. Influencer)', CMO_Channel_Relations_Split__c = 10,  Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        
        
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
        Test.startTest();
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        update book;
        
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.channelRelationIncentiveCalc(new List<PropStrength__Application_Booking__c>{book});
        BookingTriggerHelper.updateMarketingIncentive(new List<PropStrength__Application_Booking__c>{book});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod5() {
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
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'Third Party Undertaking Letter';
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
        
        Test.startTest();
        
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        book.PropStrength__Super_Area__c = 1000;
        book.Differentiate_Brokerage_on_Other_Charge__c = 1000;
        book.Home_Orientation_Docs_Received__c = true;
        book.Home_Orientation_Attended_By__c = 'Third Party Inspection';
        update book;
        
         PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=book.Id);
        
        temp.Oqood_Fees_Received__c = FALSE;
        temp.Noqoodi_Wallet_Ref_No_Approved__c = FALSE;
        temp.SPA_Executed__c = FALSE;
        temp.PCC_Document_Approved__c = FALSE;
        temp.PropStrength__Status__c = '';
        temp.PCC_Status__c = '';
        
        Map<Id, PropStrength__Application_Booking__c> oldMap = new Map<Id, PropStrength__Application_Booking__c>();
        oldMap.put(temp.Id, temp);
        
        System.debug(book);
        System.debug(oldMap);
        
        BookingTriggerHelper.CreateTask(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendEmailOqoodReceived(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendPCC(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.sendMailToApplicantCC(new List<Id>{book.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod6() {
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'Authorization Letter';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        
        Attachment attachment2 = new Attachment();
    	attachment2.ParentId = book.Id;
    	attachment2.Name = 'Authorized Persons ID';
    	attachment2.Body = Blob.valueOf('Test');
    	insert attachment2;
                
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
        
        Test.startTest();
        
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        book.PropStrength__Super_Area__c = 1000;
        book.Differentiate_Brokerage_on_Other_Charge__c = 1000;
        book.Home_Orientation_Docs_Received__c = true;
        book.Home_Orientation_Attended_By__c = 'Authorised Representative';
        update book;
        
         PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=book.Id);
        
        temp.Oqood_Fees_Received__c = FALSE;
        temp.Noqoodi_Wallet_Ref_No_Approved__c = FALSE;
        temp.SPA_Executed__c = FALSE;
        temp.PCC_Document_Approved__c = FALSE;
        temp.PropStrength__Status__c = '';
        temp.PCC_Status__c = '';
        
        Map<Id, PropStrength__Application_Booking__c> oldMap = new Map<Id, PropStrength__Application_Booking__c>();
        oldMap.put(temp.Id, temp);
        
        System.debug(book);
        System.debug(oldMap);
        
        BookingTriggerHelper.CreateTask(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendEmailOqoodReceived(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendPCC(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.sendMailToApplicantCC(new List<Id>{book.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod7() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(),RERA_Registered__c = false, Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
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
        
        Test.startTest();
        
        book.Noqoodi_Wallet_Ref_No_Approved__c = true;
        book.Oqood_Fees_Received__c = true;
        book.SPA_Executed__c = true;
        book.PCC_Status__c = 'PCC Approved';
        book.PCC_Document_Approved__c = TRUE;
        book.PropStrength__Status__c = 'Audit Approved';
        book.PropStrength__Super_Area__c = 1000;
        book.Differentiate_Brokerage_on_Other_Charge__c = 1000;
        book.Handover_Documents_Received__c = true;
        book.Handover_will_be_taken_by__c = 'POA – Owner';
        update book;
        
         PropStrength__Application_Booking__c temp = new PropStrength__Application_Booking__c(Id=book.Id);
        
        temp.Oqood_Fees_Received__c = FALSE;
        temp.Noqoodi_Wallet_Ref_No_Approved__c = FALSE;
        temp.SPA_Executed__c = FALSE;
        temp.PCC_Document_Approved__c = FALSE;
        temp.PropStrength__Status__c = '';
        temp.PCC_Status__c = '';
        
        Map<Id, PropStrength__Application_Booking__c> oldMap = new Map<Id, PropStrength__Application_Booking__c>();
        oldMap.put(temp.Id, temp);
        
        System.debug(book);
        System.debug(oldMap);
        
        BookingTriggerHelper.CreateTask(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendEmailOqoodReceived(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendPCC(new List<PropStrength__Application_Booking__c>{book}, oldMap);
        BookingTriggerHelper.sendMailPCC(new Set<Id>{book.Id});
        BookingTriggerHelper.sendBookingFormMail(new Set<Id>{book.Id});
        BookingTriggerHelper.sendEmailOfPayment(new Set<Id>{pay5.Id});
        BookingTriggerHelper.sendMailToApplicantCC(new List<Id>{book.Id});
        BookingTriggerHelper.sendTitleDeedFeesPaid(new Set<Id>{book.Id});
        BookingTriggerHelper.sendNotYetScheduleEmail(new Set<Id>{book.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testMethod8() {
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
        
        Payment_Request_Wrapper__c  uhw = new Payment_Request_Wrapper__c();
        uhw.mode__C = 'website';
        uhw.Customer_Name__c = 'Testing';
        uhw.Email__c = 'test@test.com';
        uhw.Mobile_Number__c = '9999999999';
        uhw.Amount__c = 1.00;
        
        insert uhw;
        
        Payment_Request__c prTest = new Payment_Request__c();
        prTest.Mode__c = 'Credit Card';
        prTest.Status__c = 'Approved';
        prTest.Enquiry__c = enq.Id;
        prTest.Property__c = prop.Id;
        prTest.Offer__c = offer.Id;
        prTest.Mobile_Mode_App__c = 'Website';
        prTest.Mode_Option__c = 'Multi Mode';
        prTest.Towards_Other_Charges_Amount__c = 500;
        prTest.Towards_Pre_Registration_Amount__c = 500;
        prTest.Towards_Unit_Price_Amount__c = 500;
        prTest.Payment_Request_Wrapper__c = uhw.Id;
        prTest.currency__c = 'USD';
        prTest.Amount__c = 500;
        prTest.Others__c = 'Title Deed Charges';
        prTest.Enquiry_Source__c = 'Web';
        insert prTest;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = System.Today(),CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        
        prTest.Application_Booking__c = book.Id;
        update prTest;
        
        book.Slot_Scheduled_Date__c = System.Today();
        book.Handover_CRM_Executive_v1__c = 'Ummer Farhan';
        book.Handover_will_be_taken_by__c = 'Owner – Individual';
        book.Slot_Status__c = 'Completed';
        update book;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Title Deed Charges', PropStrength__Income_Charge_Code__c = 'Title Deed Charges', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Title Deed Charges');
        insert inc;
        
        Test.startTest();
        BookingTriggerHelper.createRecordIntPay(new List<Payment_Request__c>{prTest});
        Test.stopTest();
    }
        @isTest 
    public static void testAppBook(){
        User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

        Master_Project__c Mproj = new Master_Project__c(
       Name='test proj',
           Project_Code__c ='1234',
           Incentive_Calculation__c = 2
       );
       insert Mproj;
       
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
       
       Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
       insert iss;
       
       Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
       
       Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
       insert iss1;
       
       Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
       
       Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
       insert iss2;
       
        Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
       insert iss5;
       Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
       
       Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
       insert iss3;

       PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id,RERA_Registered__c = false);
       insert proj;
       
       PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
       insert tower;
       
       Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
       insert iteam;
       
       PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
       insert propType;
       
       PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
       insert cont;
       
       PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
       insert ppd;
       
       PropStrength__Request__c enq  = new PropStrength__Request__c();
       enq.PropStrength__Primary_Contact__c = cont.Id;
       enq.PropStrength__Request_Source__c = 'Loyalty Sales';
       insert enq;
       
       List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
       PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
             PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
       PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
       PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
       offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

       insert offrList;
       
       PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
       insert pre;
       
       PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
       insert sche;
       
       List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
       PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),PropStrength__Discount_Type__c = 'Loyalty Sales',CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
             PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
       PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
       PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
       appbookList.add(book1);
       appbookList.add(book2);
       appbookList.add(book3);
       insert appbookList;
       
       Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
       insert ip;
       
       Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
       insert ip2;
       
       Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
       insert ip3;
       
       Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
       insert ip4;
       
       Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
       insert ip5;
       
       Test.startTest();
               
       PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
       insert appDetail;
       
       PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
       insert ppd1;
       
       List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
      
       
       PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
       payList.add(pay);
       
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
       payList.add(pay1);
       
       PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
       payList.add(pay2);
       
       PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
       payList.add(pay3);
       
       
       insert payList;
               PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
      insert pay4;
           book.Sales_Head_Incentive__c = 1500;
       book.PropStrength__Super_Area__c = 1000;
       book.Sales_Manager_Incentive__c = 1500;
       book.Sales_Director_Incentive__c = 1500;
       book.CMO_Marketing_Incentive__c = 1500;
       book.GM_Marketing_Incentive__c = 1500;
       book.Loyalty_Sales_Executive_Incentive__c = 1500;
       book.Marketing_Head_Incentive__c = 1500;
       book.Promoter_Incentive__c = 1500;
       book.Mall_Team_Lead_Incentive__c = 1500;
       book.TeleSales_Agent_Incentive__c = 1500;
       book.Campaign_Manager_Influence_Incentive__c = 1500;
       book.Digital_Marketing_Head_Incentive__c = 1500;
       book.Team_Lead_Incentive__c = 1500;
       book.TeleSales_Head_Incentive__c = 1500;
       book.TeleSales_Agent_Incentive__c = 1500;
       book.VP_Incentive__c = 1500;
       book.CSO_Incentive__c = 1500;
       update book;
       book.Sales_Manager_Incentive__c = 500;
       book.Sales_Head_Incentive__c = 500;
       book.Sales_Director_Incentive__c = 500;
       book.CMO_Marketing_Incentive__c = 500;
       book.GM_Marketing_Incentive__c = 500;
       book.Loyalty_Sales_Executive_Incentive__c = 500;
       book.Marketing_Head_Incentive__c = 500;
       book.Promoter_Incentive__c = 500;
       book.Mall_Team_Lead_Incentive__c = 500;
       book.TeleSales_Agent_Incentive__c = 500;
       book.Campaign_Manager_Influence_Incentive__c = 500;
       book.Digital_Marketing_Head_Incentive__c = 500;
       book.Team_Lead_Incentive__c = 500;
       book.TeleSales_Head_Incentive__c = 500;
       book.TeleSales_Agent_Incentive__c = 500;
       book.VP_Incentive__c = 500;
       book.CSO_Incentive__c = 500;
       book.DLD_Fees_Due__c = 50;
       update book;

    
    }
    
    @isTest 
    public static void testUpdatePercentageBooking1(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
        PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
        PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
        offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10), PropStrength__Discount_Type__c = 'Loyalty Sales',CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        appbookList.add(book2);
        appbookList.add(book3);
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
       
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay3);
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }
    @isTest 
    public static void testUpdatePercentageBooking2(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales (saving 1% on discount)', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
       /* Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),VP_Sales__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;*/
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(Loyalty_Discount__c = 5, PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
       
        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),PropStrength__Discount_Type__c = 'Loyalty Sales',PropStrength__Discount__c = 4,PropStrength__Property_Type__c =propType.id, CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000,Secondary_Sales_Manager__c = user1.id);
appbookList.add(book);
         insert appbookList;
      book.Secondary_Sales_Manager__c = user1.id;
        update book;
       
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'POA';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        

        
        insert payList;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

         
    }
      @isTest 
    public static void testUpdatePercentageBooking3(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales (with discount)', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id,VP_Sales__c = UserInfo.getUserId(), Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
       

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),PropStrength__Discount__c = 4.5,CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
       
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'POA';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        

        
        
        insert payList;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

               
    }

           @isTest 
    public static void testUpdatePercentageBooking5(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),VP_Sales__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
       
        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000,Secondary_Sales_Manager__c = user1.id);
appbookList.add(book);
         insert appbookList;
      book.Secondary_Sales_Manager__c = user1.id;
        update book;
       
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
       
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        

        
        insert payList;
             book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }
               @isTest 
    public static void testUpdatePercentageBooking6(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
       
        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000,Secondary_Sales_Manager__c = user1.id);
appbookList.add(book);
         insert appbookList;
      book.Secondary_Sales_Manager__c = user1.id;
        update book;
       
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
      
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        

        
        insert payList;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

         
    }
    
      @isTest 
    public static void testUpdatePercentageBooking4(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
               
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),VP_Sales__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
        PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
        PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
        offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        appbookList.add(book2);
        appbookList.add(book3);
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
     
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay3);
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }
    
      @isTest 
    public static void testUpdatePercentageBooking7(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
               
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),VP_Sales__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
        PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
        PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
        offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        appbookList.add(book2);
        appbookList.add(book3);
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
      
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay3);
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }

        @isTest 
    public static void testUpdatePercentageBooking8(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
               
         Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
        PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
        PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
        offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        appbookList.add(book2);
        appbookList.add(book3);
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
       
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay3);
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;

       book.DLD_Fees_Due__c = 50;
       update book;
    }

            @isTest 
    public static void testUpdatePercentageBooking9(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
               
         Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(), CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(90),Secondary_Sales_Manager__c = user1.id );
       
offrList.add(offer);
        offrList.add(offer1);


        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(90), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
       
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'POA';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
     
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }
    @isTest 
    public static void testUpdatePercentageBooking10(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
               
         Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, Campaign_Manager_Influence__c = UserInfo.getUserId(),  CSO__c = UserInfo.getUserId(),Digital_Marketing_Head__c = UserInfo.getUserId(),Loyalty_Sales_Executive__c = UserInfo.getUserId(),Mall_Team_Lead__c = UserInfo.getUserId(),Marketing_Head__c = UserInfo.getUserId(),Promoter__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),Team_Lead__c = UserInfo.getUserId(),TeleSales_Agent__c = UserInfo.getUserId(),TeleSales_Head__c = UserInfo.getUserId(),GM_Marketing__c = UserInfo.getUserId(), CMO_Marketing__c = UserInfo.getUserId());
        insert iteam;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker RERA';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(90),Secondary_Sales_Manager__c = user1.id );
       
offrList.add(offer);
        offrList.add(offer1);


        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(90), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'POA';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
     
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
    }
 
   @isTest 
    public static void testUpdatePercentageBooking11(){
                User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');

         Master_Project__c Mproj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234',
            Incentive_Calculation__c = 2
        );
        insert Mproj;
        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
         Incentive_Slab__c iss5 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(20) , End_Date__c = System.Today().addDays(25),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss5;
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1,Master_Project__c = Mproj.id);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        Incentive_Teams__c iteam = new Incentive_Teams__c(Tower__c = tower.Id, CMO_Channel_Relation__c = UserInfo.getUserId(), CSO__c = UserInfo.getUserId(),RM_Channel_Relation__c = UserInfo.getUserId(),Brand_Evangelist__c = UserInfo.getUserId(),Sales_Director__c = UserInfo.getUserId(),TL_Channel_Relation__c = UserInfo.getUserId(),VP_Channel_Relation__c = UserInfo.getUserId());
        insert iteam;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        List<PropStrength__Offer__c> offrList = new List<PropStrength__Offer__c>();
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Additional_Discount_Given__c = true, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
              PropStrength__Offer__c offer1 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Direct', Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),Secondary_Sales_Manager__c = user1.id );
        PropStrength__Offer__c offer2 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Broker',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10),PropStrength__Broker_Account__c = acc.id,PropStrength__Broker_Contact__c = cont.id);
        PropStrength__Offer__c offer3 = new PropStrength__Offer__c(PropStrength__Offer_Through__c='Loyalty',Additional_Discount_Given__c = false, PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =  System.Today().addDays(-10));
offrList.add(offer);
        offrList.add(offer1);
offrList.add(offer2);
offrList.add(offer3);

        insert offrList;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        List<PropStrength__Application_Booking__c> appbookList = new List<PropStrength__Application_Booking__c>();
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(X9_5_Payment_Received_Date__c = system.today().addDays(-10),PropStrength__Discount_Type__c = 'Loyalty Sales',CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
              PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer1.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer2.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
        PropStrength__Application_Booking__c book3 = new PropStrength__Application_Booking__c(CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = true, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer3.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10),Booked_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__BSP_Specific_Waiver__c=1000);
appbookList.add(book);
        appbookList.add(book1);
        appbookList.add(book2);
        appbookList.add(book3);
        insert appbookList;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
      
        Test.startTest();
                
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
       
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay);
        
PropStrength__Received_Payment__c pay1 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay1);
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book2.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book3.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100000000);
        payList.add(pay3);
        
        
        insert payList;
                PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10000000);
       insert pay4;
            book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        book.DLD_Fees_Due__c = 50;
        update book;

    }
    
         @isTest
    static void testMethod61() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(CMO_Marketing_Split__c = 10, GM_Marketing_Split__c = 10, Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Incentive_Slab__c iss4 = new Incentive_Slab__c(CMO_Marketing_Split__c = 10, GM_Marketing_Split__c = 10, Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15), Days_From__c = 0, Days_To__c = 365, Marketing_Category__c = 'Loyalty Sales (with discount)', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10,Sales_Head_Split__c=10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss4;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(CMO_Marketing_Split__c = 10, GM_Marketing_Split__c = 10, Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10, Approved_Discount_Sales__c = 2, Sales_Head_Split__c=10,Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss2 = new Incentive_Slab__c(CMO_Marketing_Split__c = 10, GM_Marketing_Split__c = 10, Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = salesManagerIncentiveId);
        insert iss2;
        
        Id specialIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Special Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss3 = new Incentive_Slab__c(CMO_Marketing_Split__c = 10, GM_Marketing_Split__c = 10, Indirect_Sales__c=10,Loyalty_Sales__c=10,Direct_Sales__c=10,Brand_Evangelist_Split__c = 10, Sales_Director_Split__c = 5, CSO_Split__c = 10, VP_Split__c = 10,Approved_Discount_Sales__c = 2,Sales_Head_Split__c=10, Start_Date__c=System.Today().addDays(-15) , End_Date__c = System.Today().addDays(15),Days_From__c = 0,  Days_To__c = 365, Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = specialIncentiveId);
        insert iss3;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(NPV__c=9, RERA_Registered__c=false, Special_Incentive_Applicable__c = true, DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = tower.Id, Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
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
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty Sales';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Broker_Contact__c = cont.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Offer_Through__c = 'Broker', PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = system.today().addDays(-10),PropStrength__Discount__c=10,DLD_Fees_Received__c=1000, DLD_Fees_Due__c=500,CSO_Incentive__c = 900, VP_Incentive__c = 900, Sales_Director_Incentive__c = 900, Sales_Head_Incentive__c = 900, Sales_Commission_Eligible_2nd_Half__c = false, Sales_Manager_Incentive__c = 1000, Sales_Head__c = UserInfo.getUserId(), Sales_Manager__c = Userinfo.getUserId(), X20_Payment_Received_Date__c = System.Today(), X10_Payment_Received_Date__c = System.today(), Booking_Form_Verified__c = true, Oqood_Fees_Received__c = true, Sales_Commission_Eligible_1st_Half__c = true, CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-10), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        Incentive_Payouts__c ip = new Incentive_Payouts__c(User_Role__c = 'Sales Head',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip;
        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip2;
        
        Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'VP Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip3;
        
        Incentive_Payouts__c ip4 = new Incentive_Payouts__c(User_Role__c = 'CSO Sales',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip4;
        
        Incentive_Payouts__c ip5 = new Incentive_Payouts__c(User_Role__c = 'Sales Manager',All_Payment_Of_Sale_Inn__c = false,Application_Booking__c = book.Id);
        insert ip5;
        
        Attachment attachment = new Attachment();
    	attachment.ParentId = book.Id;
    	attachment.Name = 'POA';
    	attachment.Body = Blob.valueOf('Test');
    	insert attachment;
        Test.startTest();
                
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
        
        book.Sales_Head_Incentive__c = 1500;
        book.PropStrength__Super_Area__c = 1000;
        book.Sales_Manager_Incentive__c = 1500;
        book.Sales_Director_Incentive__c = 1500;
        book.CMO_Marketing_Incentive__c = 1500;
        book.GM_Marketing_Incentive__c = 1500;
        book.Loyalty_Sales_Executive_Incentive__c = 1500;
        book.Marketing_Head_Incentive__c = 1500;
        book.Promoter_Incentive__c = 1500;
        book.Mall_Team_Lead_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.Campaign_Manager_Influence_Incentive__c = 1500;
        book.Digital_Marketing_Head_Incentive__c = 1500;
        book.Team_Lead_Incentive__c = 1500;
        book.TeleSales_Head_Incentive__c = 1500;
        book.TeleSales_Agent_Incentive__c = 1500;
        book.VP_Incentive__c = 1500;
        book.CSO_Incentive__c = 1500;
        update book;
        book.Sales_Manager_Incentive__c = 500;
        book.Sales_Head_Incentive__c = 500;
        book.Sales_Director_Incentive__c = 500;
        book.CMO_Marketing_Incentive__c = 500;
		book.GM_Marketing_Incentive__c = 500;
        book.Loyalty_Sales_Executive_Incentive__c = 500;
        book.Marketing_Head_Incentive__c = 500;
        book.Promoter_Incentive__c = 500;
        book.Mall_Team_Lead_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.Campaign_Manager_Influence_Incentive__c = 500;
        book.Digital_Marketing_Head_Incentive__c = 500;
        book.Team_Lead_Incentive__c = 500;
        book.TeleSales_Head_Incentive__c = 500;
        book.TeleSales_Agent_Incentive__c = 500;
        book.VP_Incentive__c = 500;
        book.CSO_Incentive__c = 500;
        update book;
        
       // AppBookingTriggerHandler.sendToMobileAPI('a','b',false);
       // AppBookingTriggerHandler.wrapper wrap = new AppBookingTriggerHandler.wrapper();
        
        Test.stopTest();
    }


}