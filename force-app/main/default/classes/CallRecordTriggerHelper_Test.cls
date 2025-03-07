@isTest
public class CallRecordTriggerHelper_Test {
    @isTest
    static void testMethod1(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '4567890123', VCC1__Phone_Encrypted__c = '4567890123', Country_Code__c = '+91');
        insert testContact;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', 
                                                                        DLD_Executive__c = UserInfo.getUserId(), 
                                                                        Name = 'Test Project', 
                                                                        PropStrength__Active__c = true, 
                                                                        T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = testContact.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert enq; 
        
        VCC1__Inbound_Notification__c inno = new VCC1__Inbound_Notification__c();
        inno.VCC1__Agent_User__c = u.id;
        inno.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inno.VCC1__Dialed_Number__c = '1100220021';
        inno.VCC1__Record_Id__c = testcontact.id;
        inno.VCC1__Type__c = 'Call Start';
        inno.VCC1__Call_Type__c = 'Inbound';
        inno.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        inno.VCC1__Call_hopped__c = true;
        insert inno;
        
        VCC1__Inbound_Notification__c inbo = new VCC1__Inbound_Notification__c();
        inbo.VCC1__Agent_User__c = u.id;
        inbo.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inbo.VCC1__Dialed_Number__c = '1100220021';
        inbo.VCC1__Record_Id__c = testcontact.id;
        inbo.VCC1__Type__c = 'Call End';
        inbo.VCC1__Call_Type__c = 'Inbound';
        inbo.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert inbo;
        System.assert(inbo.id != null);
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book2;
        
        VCC1__Call_Record__c vcr = new VCC1__Call_Record__c();
        vcr.VCC1__Call_Type__c = 'Inbound';
        vcr.VCC1__Status__c = 'Received';
        vcr.VCC1__Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        vcr.VCC1__Contact__c = testcontact.id;
        vcr.VCC1__Recording_URL__c = 'www.google.com';
        vcr.VCC1__Call_Start_IBN__c = inno.Id;
        vcr.VCC1__Call_End_IBN__c = inbo.Id;
        insert vcr;
        
        vcr.VCC1__Status__c = 'Missed';
        vcr.Application_Booking__c = book2.Id;
        update vcr;
        
         VCC1__Inbound_Notification__c innos = new VCC1__Inbound_Notification__c();
        innos.VCC1__Agent_User__c = u.id;
        innos.VCC1__Calling_Number_Encrypted__c = '4567890123';
        innos.VCC1__Dialed_Number__c = '1100220021';
        innos.VCC1__Record_Id__c = testcontact.id;
        innos.VCC1__Type__c = 'Call Start';
        innos.VCC1__Call_Type__c = 'Outbound';
        innos.VCC1__Call_id__c = 'u33hwc-cbhuwc';
        innos.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert innos;
        
        VCC1__Call_Record__c vcrRec = new VCC1__Call_Record__c();
        vcrRec.VCC1__Call_Type__c = 'Outbound';
        vcrRec.VCC1__Status__c = 'Received';
        vcrRec.VCC1__Call_Id__c = 'u33hwc-cbhuwc';
        vcrRec.VCC1__Contact__c = testcontact.id;
        vcrRec.VCC1__Recording_URL__c = 'www.google.com';
        vcrRec.VCC1__Call_Start_IBN__c = inno.Id;
        vcrRec.VCC1__Call_End_IBN__c = inbo.Id;
        vcrRec.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert vcrRec;
        Test.StopTest();
        
        
    }
    
    @isTest
    static void testMethod2(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '4567890123', VCC1__Phone_Encrypted__c = '4567890123', Country_Code__c = '+91');
        insert testContact;
        
         Master_Project__c Mproj = new Master_Project__c(
       Name='test proj',
           Project_Code__c ='1234',
           Incentive_Calculation__c = 2,
             Siniya_Island_Project__c = true
       );
       insert Mproj;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', 
                                                                        DLD_Executive__c = UserInfo.getUserId(), 
                                                                        Name = 'Test Project', 
                                                                       Master_Project__c = Mproj.Id, 
                                                                        PropStrength__Active__c = true, 
                                                                        T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = testContact.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert enq; 
        
        VCC1__Inbound_Notification__c inno = new VCC1__Inbound_Notification__c();
        inno.VCC1__Agent_User__c = u.id;
        inno.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inno.VCC1__Dialed_Number__c = '1100220021';
        inno.VCC1__Record_Id__c = testcontact.id;
        inno.VCC1__Type__c = 'Call Start';
        inno.VCC1__Call_Type__c = 'Inbound';
        inno.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        inno.VCC1__Call_hopped__c = true;
        insert inno;
        
        VCC1__Inbound_Notification__c inbo = new VCC1__Inbound_Notification__c();
        inbo.VCC1__Agent_User__c = u.id;
        inbo.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inbo.VCC1__Dialed_Number__c = '1100220021';
        inbo.VCC1__Record_Id__c = testcontact.id;
        inbo.VCC1__Type__c = 'Call End';
        inbo.VCC1__Call_Type__c = 'Inbound';
        inbo.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert inbo;
        System.assert(inbo.id != null);
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Application_Booking__c book2 = new PropStrength__Application_Booking__c(CRM_Executive__c=UserInfo.getUserId(),PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book2;
        PropStrength__Applicant_Detail__c appDetail2 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book2.Id);
        insert appDetail2;
        
        VCC1__Call_Record__c vcr = new VCC1__Call_Record__c();
        vcr.VCC1__Call_Type__c = 'Inbound';
        vcr.VCC1__Status__c = 'Received';
        vcr.VCC1__Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        vcr.VCC1__Contact__c = testcontact.id;
        vcr.VCC1__Recording_URL__c = 'www.google.com';
        vcr.VCC1__Call_Start_IBN__c = inno.Id;
        vcr.VCC1__Call_End_IBN__c = inbo.Id;
        insert vcr;
        
        vcr.VCC1__Status__c = 'Missed';
        vcr.Application_Booking__c = book2.Id;
        update vcr;
        
         VCC1__Inbound_Notification__c innos = new VCC1__Inbound_Notification__c();
        innos.VCC1__Agent_User__c = u.id;
        innos.VCC1__Calling_Number_Encrypted__c = '4567890123';
        innos.VCC1__Dialed_Number__c = '1100220021';
        innos.VCC1__Record_Id__c = testcontact.id;
        innos.VCC1__Type__c = 'Call Start';
        innos.VCC1__Call_Type__c = 'Outbound';
        innos.VCC1__Call_id__c = 'u33hwc-cbhuwc';
        innos.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert innos;
        
        VCC1__Call_Record__c vcrRec = new VCC1__Call_Record__c();
        vcrRec.VCC1__Call_Type__c = 'Outbound';
        vcrRec.VCC1__Status__c = 'Received';
        vcrRec.VCC1__Call_Id__c = 'u33hwc-cbhuwc';
        vcrRec.VCC1__Contact__c = testcontact.id;
        vcrRec.VCC1__Recording_URL__c = 'www.google.com';
        vcrRec.VCC1__Call_Start_IBN__c = inno.Id;
        vcrRec.VCC1__Call_End_IBN__c = inbo.Id;
        vcrRec.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert vcrRec;
        Test.StopTest();
        
        
    }
}