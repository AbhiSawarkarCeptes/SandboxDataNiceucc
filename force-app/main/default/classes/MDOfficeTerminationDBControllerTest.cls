@isTest
public class MDOfficeTerminationDBControllerTest {
    
    @TestSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        Id salesManagerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Sales Manager Incentive').getRecordTypeId();
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        List<Incentive_Slab__c> iss = new List<Incentive_Slab__c>();
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = salesManagerIncentiveId));
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = marketingIncentiveId));
        iss.add(new Incentive_Slab__c(Indirect_Sales__c=10, Direct_Sales__c=10, Approved_Discount_Sales__c=10, Loyalty_Sales__c = 10, Intl_Broker_New_Customer_Inc__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 10, VP_Channel_Relations_Split__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Sales_Director_Split__c = 10, Loyalty_Sales_Executive_Split__c = 10, Telesales_Agent_Split__c = 10, Mall_Team_Lead_Split__c = 10, Promoter_Split__c = 10, Marketing_Head_Split__c = 10, TeleSales_Head_Split__c = 10, Team_Lead_Split__c = 10, Digital_Marketing_Head_Split__c = 10, Campaign_Manager_Split__c = 10, Days_To__c = 365, Days_From__c = 1, CSO_Split__c = 10, VP_Split__c = 10, Sales_Head_Split__c = 10, RecordTypeId = channelPartnerIncentiveId));
        insert iss; 
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        PropStrength__Brokerage_Scheme__c scheme = new PropStrength__Brokerage_Scheme__c(PropStrength__Scheme_Name__c = 'Test Brokerage Scheme' , PropStrength__Standard_Brokerage_BSP__c = 2,PropStrength__Active__c = true ,Approval_Status__c = 'Approved');
        insert scheme;
        PropStrength__Additional_Brokerage_Slab__c borkSlab = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =200,PropStrength__Range_From__c = 2,PropStrength__Type__c ='Amount');
        insert borkSlab;
        PropStrength__Additional_Brokerage_Slab__c borkSlab2 = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =200,PropStrength__Range_From__c = 2,PropStrength__Type__c ='Unit Count');
        insert borkSlab2;
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Mortgage_Case__c = false,PCC_Document_Approved__c = false,Title_Deed_Transfer_Executed__c = false,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-3), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' , PropStrength__Broker_Account__c = acc.Id,Customer_Initiated_Termination__c = true);
        insert book;
        
        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Mortgage_Case__c = false,PCC_Document_Approved__c = false,Title_Deed_Transfer_Executed__c = false,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-3), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' , PropStrength__Broker_Account__c = acc.Id,Customer_Initiated_Termination__c = true);
        insert book1;
        System.debug('book --> '+book.PropStrength__Total_Basic_Sales_Price__c);
        System.debug('book --> '+book.PropStrength__Revised_Total_Sales_Consideration__c);
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(Milestone_Completion_Approved_On__c = System.today(),PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123',PropStrength__Is_TimeLinked_Plan__c = false,PropStrength__Milestone_Type__c ='Construction Linked',PropStrength__Status__c='Completed');
        insert mileSt;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Milestone__c = mileSt.Id,PropStrength__Is_Milestone_Completed__c = true, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today(),PropStrength__Amount_Due__c = 11000,PropStrength__Approval_Status__c = 'Approved',PropStrength__Service_Tax_Due_on_BSP__c=11000,PropStrength__Input_Tax_Credit_Percentage__c=0, PropStrength__Education_Cess_on_BSP__c = 1000);
        insert ppd1;
        system.debug('balance heere'+ppd1.PropStrength__Balance__c);
        system.debug('PropStrength__Amount_Due_Plus_Tax__c here' +ppd1.PropStrength__Amount_Due_Plus_Tax__c);
        system.debug('PropStrength__Total_ITC_on_Other_Charges__c' +ppd1.PropStrength__Total_ITC_on_Other_Charges__c);
        system.debug('PropStrength__Total_OCP_Credit_Amount__c here' +ppd1.PropStrength__Total_OCP_Credit_Amount__c);
        system.debug('PropStrength__Total_BSP_Credit_Note__c '+ppd1.PropStrength__Total_BSP_Credit_Note__c);
       // system.debug('PropStrength__Total_OCP_Credit_Amount__c here +'ppd1.PropStrength__Total_OCP_Credit_Amount__c);
        system.debug('PropStrength__Amount_Paid__c here'+ppd1.PropStrength__Amount_Paid__c);
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay3);
        insert payList;
    }
    
    @isTest
    public static void testMethod1(){
       List<PropStrength__Projects__c> projList = [select id from PropStrength__Projects__c];
        List<PropStrength__Tower__c> towerList = [Select id from PropStrength__Tower__c];
        List<PropStrength__Application_Booking__c> bookingList = [select id from PropStrength__Application_Booking__c];
        test.starttest();
        Map<Id,PropStrength__Application_Booking__c> mapOfBook = new Map<Id,PropStrength__Application_Booking__c>([select id,PropStrength__Property__r.PropStrength__Property_Name__c,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Project_Name__r.Name,PropStrength__Property__r.PropStrength__Project_Name__c,Name,
                        PropStrength__Total_Agreement_Amount__c,Submitted_to_MD_Office_Remarks__c, Submitted_To_MD_Office_Termination_Date__c, Submitted_to_Accounts_for_Termination__c,Resubmitted_by_Collection_Reason__c,Resubmitted_by_Audit_Reason__c
                        ,SPA_Executed__c,PropStrength__Total_Payment_Due__c,PropStrength__Primary_Applicant_Name__c,
                        PropStrength__Revised_Agreement_Amount__c,Final_Notice_Sent_Date__c,Tr_Audit_Approval_Remarks__c, Tr_Accounts_Approval_Remarks__c,Oqood_Fees_Received__c,SPA_Execution_Date__c,                                                 
                        PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.PropStrength__Revised_Total_Sales_Consideration__c,Pre_Registration_Completed__c,
                        Termination_Process_Status__c,PropStrength__Agreement_Termination_Reason__c from PropStrength__Application_Booking__c]);
        list<PropStrength__Payment_Plan_Details__c> listOfppd = [select id,Name, House_Unit_No__c,PropStrength__Application_Booking__c, PropStrength__Amount_Due_Plus_Tax__c, PropStrength__Amount_Paid__c, 
                    PropStrength__Balance__c, Interest_Ageing__c,PropStrength__Application_Booking__r.PropStrength__Property__c,PropStrength__Final_Payment_Date__c,PropStrength__Payment_Due_Date__c,
                    PropStrength__Total_Amount_Due_with_Service_Tax__c,Demand_Sent__c,PropStrength__Amount_Percent__c,                                                 
                    (SELECT Id, PropStrength__Demand_Generated__c FROM PropStrength__Received_Payments__r WHERE RecordType.Name = 'Payment Due' AND PropStrength__Demand_Generated__c = TRUE)
                      from PropStrength__Payment_Plan_Details__c ];
        Map<string,List<PropStrength__Payment_Plan_Details__c>> mapOfppd= new Map<string,List<PropStrength__Payment_Plan_Details__c>>();
        mapOfppd.put(bookingList[0].Id,listOfppd);
        
        MDOfficeTerminationDashboardController.bookingListWithOverDue(projList[0].id, towerList[0].id, new List<String>{'Resubmitted to accounts by collections'});
        MDOfficeTerminationDashboardController.bookingListWithOverDue(projList[0].id, towerList[0].id, new List<String>{'Resubmitted by audit to accounts'});
        MDOfficeTerminationDashboardController.bookingListWithOverDue(projList[0].id, 'All', new List<String>{'Resubmitted to accounts by collections'});
        MDOfficeTerminationDashboardController.bookingListWithOverDue(projList[0].id, 'All', new List<String>{'Resubmitted by audit to accounts'});
        MDOfficeTerminationDashboardController.submittedToAccount(new List<String>{bookingList[0].id, bookingList[1].id}, 'Approved with full refund##Allocate to CRM Team','reasonhere','Audit','None');
        MDOfficeTerminationDashboardController.submittedToAccount(new List<String>{bookingList[0].id, bookingList[1].id}, 'Allocate to CRM Team','reasonhere','submitedToWhom','None');
        MDOfficeTerminationDashboardController.submittedToAccount(new List<String>{bookingList[0].id, bookingList[1].id}, 'Resubmitted to collections by accounts','reasonhere','submitedToWhom','None');
        MDOfficeTerminationDashboardController.submittedToAccount(new List<String>{bookingList[0].id, bookingList[1].id}, 'Removed from Termination','reasonhere','submitedToWhom','None');
        MDOfficeTerminationDashboardController.createBookingWrapper(mapOfBook,mapOfppd, '');
        
        Test.stopTest();
    }
    
    @istest
    static void test2() {
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
      
        List<String> terminationStatus = new List<String>{'Submitted to Audit','Rejected by audit'};
            
            PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project 1', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Tower__c propTower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower1', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A2');
        INSERT propTower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen1');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c = propTower.Id,Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test 1';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test 1' + DateTime.now();
        cont.LastName = 'testKYCForm 2';
        cont.Email = 'test2@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan1234', PropStrength__Active__c = true, Name = 'Test Plan 1');
        insert ppd;
        test.startTest();
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1),Termination_Process_Status__c = 'Submitted to Audit', PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__Property__c = prop.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true);
        insert book;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        insert ppd1;
        
        //PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Is_Milestone_Completed__c = TRUE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today()+60, PropStrength__Approval_Status__c = 'Approved');
        //insert ppd1;

        
        MDOfficeTerminationDashboardController.bookingListWithOverDue(proj.Id,propTower.Id,terminationStatus); 
        System.debug('proj.Id>>'+proj.Id);
        System.debug('propTower.Id>>'+propTower.Id);
        System.debug('terminationStatus'+terminationStatus);
        test.stopTest();

      
    }

}