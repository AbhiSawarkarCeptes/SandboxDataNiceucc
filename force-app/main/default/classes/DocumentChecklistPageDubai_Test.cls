@isTest
public with sharing class DocumentChecklistPageDubai_Test {
    @TestSetup
    public static void makeData() {
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
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.Mailing_Address_same_as_PermanentAddress__c = true;
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

        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Status__c = 'Completed', CRM_Executive__c=UserInfo.getUserId(), PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
    }


    @isTest
    static void documentChecklistPageDubaiControllerTest() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        PropStrength__Application_Booking__c booking = [SELECT Id, PropStrength__Status__c FROM PropStrength__Application_Booking__c];

        List<PropStrength__Applicant_Detail__c> appDetails = new List<PropStrength__Applicant_Detail__c>();
        for(Integer i=0; i<8; i++) {
            PropStrength__Applicant_Detail__c appDetailData = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = booking.Id);
            appDetails.add(appDetailData);
        }         
        insert appDetails;

        Test.setCurrentPageReference(new PageReference('/apex/DocumentChecklistPageDubaiController_PS'));
        ApexPages.currentPage().getParameters().put('id', booking.Id);
        DocumentChecklistPageDubaiController_PS controller = new DocumentChecklistPageDubaiController_PS();
    }

    
    @isTest
    static void documentChecklistPageDubaiControllerNegative() {
        Contact cont1 = [SELECT Id, Mailing_Address_same_as_PermanentAddress__c FROM Contact LIMIT 1];
        cont1.Mailing_Address_same_as_PermanentAddress__c = false;
        cont1.MailingState = 'Dubai'; 
        update cont1;

        PropStrength__Application_Booking__c booking = [SELECT Id, PropStrength__Status__c FROM PropStrength__Application_Booking__c];
        booking.PropStrength__Primary_Customer__c =cont1.Id;
        update booking;

        List<PropStrength__Applicant_Detail__c> appDetails = new List<PropStrength__Applicant_Detail__c>();
        for(Integer i=0; i<8; i++) {
            PropStrength__Applicant_Detail__c appDetailData = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont1.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = booking.Id);
            appDetails.add(appDetailData);
        }         
        insert appDetails;

        Test.setCurrentPageReference(new PageReference('/apex/DocumentChecklistPageDubaiController_PS'));
        ApexPages.currentPage().getParameters().put('id', booking.Id);

        DocumentChecklistPageDubaiController_PS controller = new DocumentChecklistPageDubaiController_PS();
    }

    
    @isTest
    static void documentChecklistPageSaveArray() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<PropStrength__Application_Booking__c> bookingLst =[SELECT Id, Sales_Manager__c, CreatedById, LastModifiedDate, Name, PropStrength__Status__c, PropStrength__Project__c, PropStrength__Project__r.Name, PropStrength__Offer__c, PropStrength__Offer__r.Physical_document_received__c, PropStrength__Property__c, 
                        PropStrength__Property__r.PropStrength__Unit_Status__c, Verification_status__c, PropStrength__Broker_Account__c,
                        PropStrength__Total_Agreement_Amount__c, No_of_Earmarked_Parking__c,No_of_Additional_Parking__c, 
                        PropStrength__Property__r.PropStrength__Tower__c,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                        Sub_Source__c, PropStrength__Booking_Date__c, PropStrength__Offer__r.name,PropStrength__Property__r.PropStrength__Unit_Type__c,
                        PropStrength__Offer__r.PropStrength__Broker_Account__r.Salutation, PropStrength__Property__r.Name, PropStrength__Property__r.PropStrength__Chargeable_Area__c,                
                        PropStrength__Property__r.PropStrength__Floor_Number__c, PropStrength__Property__r.PropStrength__House_Unit_No__c 
                        FROM PropStrength__Application_Booking__c];
        bookingLst[0].PropStrength__Status__c = 'Completed'; 
        update bookingLst;  

        Test.setCurrentPageReference(new PageReference('/apex/DocumentChecklistPageDubaiController_PS'));
        ApexPages.currentPage().getParameters().put('bookingid', bookingLst[0].Id);  

        DocumentChecklistPageDubaiController_PS controller = new DocumentChecklistPageDubaiController_PS(); 
        controller.lstBooking = bookingLst;       
        controller.ArrayApplicant1String = 'Test1,Test2,Test3,Test4,false,Test6,Test7,Test8,Test9,Test10,Test11,Test12';
        PageReference pg1 = controller.saveArray();  
    }
    
    @isTest
    static void documentChecklistPageDubaiControllerReject() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact cont = [SELECT Id FROM Contact LIMIT 1];
       
        List<PropStrength__Application_Booking__c> bookingLst =[SELECT Id, Sales_Manager__c, CreatedById, LastModifiedDate, Name, PropStrength__Status__c, PropStrength__Project__c, PropStrength__Project__r.Name, PropStrength__Offer__c, PropStrength__Offer__r.Physical_document_received__c, PropStrength__Property__c, 
                        PropStrength__Property__r.PropStrength__Unit_Status__c, Verification_status__c, PropStrength__Broker_Account__c,
                        PropStrength__Total_Agreement_Amount__c, No_of_Earmarked_Parking__c,No_of_Additional_Parking__c, 
                        PropStrength__Property__r.PropStrength__Tower__c,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                        Sub_Source__c, PropStrength__Booking_Date__c, PropStrength__Offer__r.name,PropStrength__Property__r.PropStrength__Unit_Type__c,
                        PropStrength__Offer__r.PropStrength__Broker_Account__r.Salutation, PropStrength__Property__r.Name, PropStrength__Property__r.PropStrength__Chargeable_Area__c,                
                        PropStrength__Property__r.PropStrength__Floor_Number__c, PropStrength__Property__r.PropStrength__House_Unit_No__c 
                        FROM PropStrength__Application_Booking__c];

        bookingLst[0].PropStrength__Status__c = 'Completed'; 
        update bookingLst;
        Test.setCurrentPageReference(new PageReference('/apex/DocumentChecklistPageDubaiController_PS'));
        ApexPages.currentPage().getParameters().put('bookingid', bookingLst[0].Id);

        DocumentChecklistPageDubaiController_PS controller = new DocumentChecklistPageDubaiController_PS(); 
        controller.lstBooking = bookingLst;  
        controller.d1 = false;
        controller.d2 = false;
        controller.d3 = false;
        controller.d4 = false;
        controller.d5 = false;
        controller.d6 = false;
        controller.d7 = false;
        controller.d8 = false;
        controller.d9 = false;
        controller.d10 = false;
        controller.d11 = false;
        controller.drow1 = 'Test';
        controller.drow2 = 'Test';
        controller.drow3 = 'Test';
        controller.drow4 = 'Test';
        controller.drow5 = 'Test';
        controller.drow6 = 'Test';
        controller.drow7 = 'Test';
        controller.drow8 = 'Test';
        controller.drow9 = 'Test';
        controller.drow10 = 'Test';
        controller.drow11 = 'Test';
        controller.btnReject();
    }

        
    @isTest
    static void documentChecklistPageDubaiControllerAccept() {
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        PropStrength__Application_Booking__c booking = [SELECT Id, PropStrength__Status__c FROM PropStrength__Application_Booking__c];
        booking.PropStrength__Status__c = 'Completed'; 
        update booking;
        Test.setCurrentPageReference(new PageReference('/apex/DocumentChecklistPageDubaiController_PS'));
        ApexPages.currentPage().getParameters().put('bookingid', booking.Id);
        DocumentChecklistPageDubaiController_PS controller = new DocumentChecklistPageDubaiController_PS();
        PageReference pg1 = controller.Accept();
    }

}