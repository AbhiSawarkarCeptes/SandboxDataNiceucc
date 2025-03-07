@isTest
public class SendEmailToCRMExecutiveSPABatch_Test {
    @TestSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
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
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id,Deviation_on_Payment_Plan__c=true, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Notification_to_CRM_Executive_for_SPA__c = false,SPA_Transaction_Exception__c = true,DSPA_Transaction_Exception__c = true,MOU_Executed__c = true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = true,SPA_Executed__c = true,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' );
        insert book;
        
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(DCR_Created__c = false,DSPA_Created__c = false,RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id);
        insert tr;
        
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(Milestone_Completion_Approved_On__c = System.today(),PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123',PropStrength__Is_TimeLinked_Plan__c = false,PropStrength__Milestone_Type__c ='Construction Linked',PropStrength__Status__c='Completed');
        insert mileSt;
        
        PropStrength__Payment_Plan_Details__c ppd1 = new PropStrength__Payment_Plan_Details__c(PropStrength__Milestone__c = mileSt.Id,PropStrength__Is_Milestone_Completed__c = FALSE, PropStrength__Application_Booking__c = book.Id, PropStrength__Payment_Due_Date__c = System.Today(),PropStrength__Amount_Due__c = 100);
        insert ppd1;
        
        List<PropStrength__Received_Payment__c> payList = new List<PropStrength__Received_Payment__c>();
         PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay2);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Cheque Bouncing Charges', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        payList.add(pay3);
        insert payList;
    }
     @isTest
    Public  static void SendEmailToCRMExecutiveSPABatchTest(){
       	SendEmailToCRMExecutiveSPABatch st = new SendEmailToCRMExecutiveSPABatch();
        Database.executeBatch(st);
        
    }
}