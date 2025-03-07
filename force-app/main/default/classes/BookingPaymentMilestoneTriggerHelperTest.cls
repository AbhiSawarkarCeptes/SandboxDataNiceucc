@isTest
public class BookingPaymentMilestoneTriggerHelperTest {
   @isTest static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen',PropStrength__Property_Type__c = '3 BR + S');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Expiry_Date__c = system.today()+3;
        acc.PropStrength__Broker_Type__c = 'Sobha Connect';
        acc.VAT_Registration_Status__c ='Yes';
        acc.VAT_Applicable_From__c = system.today()+2;
        // insert acc;
        
        
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc1.Expiry_Date__c = system.today()+3;
        
        List<Account> accList = new List<Account>();
        accList.add(acc);
        accList.add(acc1);
        insert accList;
        
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
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = true, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,Booked_Date__c =system.today());
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        PropStrength__Brokerage_Scheme__c scheme = new PropStrength__Brokerage_Scheme__c(PropStrength__Scheme_Name__c = 'Test Brokerage Scheme' , PropStrength__Standard_Brokerage_BSP__c = 2,PropStrength__Active__c = true ,Approval_Status__c = 'Approved',PropStrength__Start_Date__c = system.today()-3 , PropStrength__End_Date__c = system.today()+3,Percentage_of_POP_Received_Date__c =11);
        insert scheme;
        PropStrength__Additional_Brokerage_Slab__c borkSlab = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =50,PropStrength__Range_From__c = 150,PropStrength__Type__c ='Amount',PropStrength__Property_Type__c ='3 BR + S',PropStrength__Additional_Brokerage__c=15);
        insert borkSlab;
       // PropStrength__Additional_Brokerage_Slab__c borkSlab2 = new PropStrength__Additional_Brokerage_Slab__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Name = 'Additional Brokerage',PropStrength__Active__c = true,PropStrength__Effective_end_Date__c =System.today()-2,PropStrength__Effective_Start_Date__c =System.today()-5,PropStrength__Range_To__c =200,PropStrength__Range_From__c = 0,PropStrength__Type__c ='Unit Count', PropStrength__Property_Type__c ='3 BR + S',PropStrength__Additional_Brokerage__c=15);
       // insert borkSlab2;
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Brokerage_Release_Schedule_Line_Item__c lineItem = new PropStrength__Brokerage_Release_Schedule_Line_Item__c(PropStrength__Brokerage_Schedule_Name__c = sche.id, Name ='On collection of 10%',PropStrength__Brokerage_Due__c=40,PropStrength__Brokerage_Schedule_Type__c = 'Standard',PropStrength__Amount_Paid_By_Customer__c= 9.5,DLD_Fee_Received__c=true,Booking_Form_Audit_Approved__c = true );
        insert lineItem ;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(Booked_Date__c = system.today(),PropStrength__Brokerage_Scheme__c = scheme.Id,Mortgage_Case__c = false,PCC_Document_Approved__c = false,Title_Deed_Transfer_Executed__c = false,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-3), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' , PropStrength__Broker_Account__c = acc.Id,PropStrength__Brokerage_Release_Schedule__c = sche.Id,Sobha_Connect_Verified__c='Verified',Total_Payment_Receive_Percent__c = 12,DLD_Fees_Due__c=1150,DLD_Fees_Received__c=1250,Booking_Form_Verified__c = true,PropStrength__Brokerage_BSP__c=15,PropStrength__Brokerage_On_Other_Charges__c=12,PropStrength__Property_Type__c =propType.id );
        insert book;
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'DLD Fees', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId());
        insert pay2;
        
        book.PropStrength__Super_Area__c = 1300;
        update book;
        system.debug(book.PropStrength__Payments_Cheques__r.size());
       /* PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Scheme__c = scheme.Id,Mortgage_Case__c = false,PCC_Document_Approved__c = false,Title_Deed_Transfer_Executed__c = false,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-3), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 100, PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' , PropStrength__Broker_Account__c = acc1.Id,PropStrength__Brokerage_Release_Schedule__c = sche.Id,Sobha_Connect_Verified__c='Verified');
        insert book1;*/
        
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = book.Id;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
    }
}