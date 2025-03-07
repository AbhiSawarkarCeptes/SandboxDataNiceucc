@isTest
public class SPALetterController_Test {
    @TestSetup static void setup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project',RERA_Registered__c= false, PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount',District_Plan_Uploaded__c = system.today(),
                                                                       RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(),
                                                                       PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, 
                                                                       PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.PropStrength__Resident_Status__c = 'Resident Citizen';
        cont.Emirates_ID__c = '784-1234-1111111-1';
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
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Deviation_on_Payment_Plan__c = true,PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, Additional_Discount_Given__c = false, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id,DLD_Amount__c =0);
        insert offer;
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Total_Basic_Sales_Price__c = 10000,PropStrength__Property__c = prop.Id,SPA_Executed__c = false,SPA_Transaction_Exception__c = true,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct',  PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com' );
        insert book;
        
        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Total_Basic_Sales_Price__c = 10000,PropStrength__Property__c = prop.Id,SPA_Executed__c = false,SPA_Transaction_Exception__c = true,PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Project__c = proj.Id,PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test1@gmail.com', POA_Email_Address__c='test123@gmail.com' );
        insert book1;
        test.starttest();
        List<PropStrength__Received_Payment__c> pList = new List<PropStrength__Received_Payment__c>();
		PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 100);
        pList.add(pay3);
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 100);
        pList.add(pay2);
        insert pList;
        PropStrength__Transaction_Requests__c tr = TestDataFactorySobha.createTransactionRequest(null);
        
        tr.RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();
        tr.PropStrength__Application_Booking__c = book.Id;
        insert tr;
        
        PropStrength__Transaction_Requests__c tr1 = TestDataFactorySobha.createTransactionRequest(null);
        tr1.RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId();
    	insert tr1;
        
        List<PropStrength__Applicant_Detail__c> applicantList = new List<PropStrength__Applicant_Detail__c>();
        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        applicantList.add(appDetail);
        
          PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '2nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        applicantList.add(appDetail1);
        
         
          PropStrength__Applicant_Detail__c appDetail2 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1nd Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        applicantList.add(appDetail2);
        
        insert applicantList;
        
          
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tr.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        Insert conList;
       
        
        test.stoptest();
    }
    @isTest
    Public  static void SPALetterControllerTest(){
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'SPA_for_Digi_Sign';
        validEmailTemplate.DeveloperName = 'SPA_for_Digi_Sign';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        
        insert validEmailTemplate;
        List<PropStrength__Transaction_Requests__c> trList = [SELECT Id FROM PropStrength__Transaction_Requests__c];
        ApexPages.currentPage().getParameters().put('id' ,trList[0].id);
        SPALetterController sap = new SPALetterController();
        sap.toEmail = 'Test@gmail.com';
        sap.ccEmail = 'Test1@gmail.com';
        sap.SaveAndEmailPdf();
        sap.docancel();
        sap.getChooserender();
        sap.showPopup();
        sap.closePopup();
        try{
        sap.EmailSPALetter();
        }catch(exception e){
            
        }
          
    }
}