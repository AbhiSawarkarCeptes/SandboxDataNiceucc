@isTest
public class TransactionRequestTriggerHelper_Test { 
	@isTest
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        User usr = TestDataFactorySobha.createUser(NULL);
        Insert usr;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=usr.id,Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
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
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
        insert prop;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
       PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
        PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
        MOU_Transaction_Exception__c = true,Title_Deed_Process_Exception__c = true,CRM_Executive__c=usr.id);
        insert book;
        Test.startTest(); 

        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
        

        PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=FALSE, PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10, PropStrength__Project__c = proj.Id, MOU_Executed__c = TRUE);
        insert book1;
        
        PropStrength__Applicant_Detail__c appDetail1 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        insert appDetail1;
        
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
//trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer', PropStrength__Refund_Type__c = 'Advance Refund'));
       // trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer', DLD_Certificate_Uploaded__c = FALSE));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval',DCR_Created__c = false,DSPA_Created__c = false, RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('DSPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'Title Transfer'));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book1.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'No Title Transfer'));
        
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('MOU Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
       
       
        trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Title Deed Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer'));
       // trList.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id));
        
		System.debug('trList :' + trList);
        insert trList;
        
        Attachment a1 = new Attachment();
        a1.parentid = trList[6].Id;
        a1.name = 'test.pdf';
        a1.body = Blob.valueOf('UNIT.TEST');
        //a1.content =  Blob.valueOf('UNIT.TEST');
        Insert a1; 
        
        List<PropStrength__Transaction_Requests__c> updTrList = new List<PropStrength__Transaction_Requests__c>();
        updTrList.add(new PropStrength__Transaction_Requests__c(Id = trList[2].Id, Oqood_Certificate_No__c = '123456'));
        updTrList.add(new PropStrength__Transaction_Requests__c(Id = trList[3].Id, DSPA_Created__c = TRUE, DCR_Created__c = TRUE,Oqood_Certificate_No__c = '123456', DLD_Certificate_Uploaded__c = false, DLD_Certificate_Uploaded_Date__c = System.Today()));
        updTrList.add(new PropStrength__Transaction_Requests__c(Id = trList[4].Id, PropStrength__Status__c = 'MOU Executed', MOU_Created__c = TRUE));
        updTrList.add(new PropStrength__Transaction_Requests__c(Id = trList[5].Id, MOU_Verified_by_Development_Legal_Team__c = TRUE, MOU_Created__c = TRUE));
        updTrList.add(new PropStrength__Transaction_Requests__c(Id = trList[6].Id, Title_Deed_Uploaded__c = false,DSR_Generated_Date__c=Date.Today(),DSR_Signing_Requested_from_CRM_Team__c=false));
       

        UPDATE updTrList;
        
        updTrList[4].Title_Deed_Uploaded__c=true;
        UPDATE updTrList[4];
        
        Test.stopTest();
    } 
    @isTest
    public static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
  Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
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
        
      PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c =tower.Id ,PropStrength__House_Unit_No__c='test1',Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
       
       PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id, PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
        PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
        MOU_Transaction_Exception__c = true,SPA_Executed__c =  false,PCC_Document_Approved__c = true , Pre_Registration_Transaction_Exception__c =true, PropStrength__Booking_Date__c = System.Today());
        insert book;

        PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id);
        insert appDetail;
       

        
        
              
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
      PropStrength__Application_Booking__c book1 = new PropStrength__Application_Booking__c(SPA_Transaction_Exception__c=true,MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id, PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
        PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
        MOU_Transaction_Exception__c = true,SPA_Executed__c =  false,PCC_Document_Approved__c = true , PropStrength__Booking_Date__c = System.Today());
        insert book1;
         
        PropStrength__Applicant_Detail__c appDetail2 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = cont.Id, PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        insert appDetail2;
        
       // PropStrength__Applicant_Detail__c appDetail2 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = cont.Id, PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = false, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
       // insert appDetail2;
        
      
        
        PropStrength__Applicant_Detail__c appDetail3 = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c = cont.Id, PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book1.Id);
        insert appDetail3;
        
        PropStrength__Received_Payment__c pay2 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 10);
        
        PropStrength__Received_Payment__c pay3 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10);
        PropStrength__Received_Payment__c pay4 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId(), PropStrength__Amount__c = 10);
        
        PropStrength__Received_Payment__c pay5 = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Installment', PropStrength__Application_Booking__c = book1.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 10);
        Test.startTest();
        insert new LIst<PropStrength__Received_Payment__c>{pay2,pay3,pay4,pay5};
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        PropStrength__Transaction_Requests__c tr1 = new PropStrength__Transaction_Requests__c(PropStrength__Credit_Waiver_Amount__c = 100,PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Credit Waiver').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer');
        trList.add(tr1);
        PropStrength__Transaction_Requests__c tr2 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Addition / Deletion of Name').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer');
       	trList.add(tr2);        
        PropStrength__Transaction_Requests__c tr3 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'Title Transfer');
        trList.add(tr3);
        PropStrength__Transaction_Requests__c tr4 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Transfer Of Property').getRecordTypeId(), PropStrength__Application_Booking__c = book1.Id, New_Buyer_s_Documents_Received__c = TRUE, PropStrength__Customer_Transfer_Type__c = 'No Title Transfer');
        trList.add(tr4);
		PropStrength__Transaction_Requests__c tr5 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book1.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer');
        trList.add(tr5);        
        PropStrength__Transaction_Requests__c tr6 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id);
        trList.add(tr6);        
        PropStrength__Transaction_Requests__c tr7 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', 
                                                                                              RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Advance Payment Rebate').getRecordTypeId(), 
                                                                                              PropStrength__Application_Booking__c = book.Id);
       // trList.add(tr7);
        PropStrength__Transaction_Requests__c tr8 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id);
        trList.add(tr8);
        PropStrength__Transaction_Requests__c tr9 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Handover').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id,Undertaking_Documents_Shared__c = true);
        trList.add(tr9);
        PropStrength__Transaction_Requests__c tr10 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Pre-Registration Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer', DLD_Certificate_Uploaded__c = FALSE,DLD_Certificate_Uploaded_Date__c = System.Now()-1,Oqood_Certificate_No__c ='1');
       	trList.add(tr10);
        PropStrength__Transaction_Requests__c tr11 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = book1.Id, PropStrength__Customer_Transfer_Type__c = 'Customer Transfer',Digi_Signed_SPA_Received_From_Customer__c = true);
        trList.add(tr11);
        PropStrength__Transaction_Requests__c tr12 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Change In Payment Plan').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id,Transaction_Fee__c = 100,Transaction_Fee_Type__c = 'Amount');
        trList.add(tr12);
        PropStrength__Transaction_Requests__c tr13 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Mortgage Process').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id,Transaction_Fee__c = 100,Transaction_Fee_Type__c = 'Amount');
        trList.add(tr13);
     
        insert trList;
     
      

        
        
        Map<Id,PropStrength__Transaction_Requests__c> mapOfTR1 = new Map<Id,PropStrength__Transaction_Requests__c>();
        mapOfTR1.put(tr11.Id,tr5);
       // TransactionRequestTriggerHelper.submitForApproval(new List<PropStrength__Transaction_Requests__c>{tr11},mapOfTR1);

        Map<Id,PropStrength__Transaction_Requests__c> mapOfTR2 = new Map<Id,PropStrength__Transaction_Requests__c>();
        mapOfTR2.put(tr9.Id,tr8);
       	TransactionRequestTriggerHelper.sendMailOnUndertakingDocumentsShared(new List<PropStrength__Transaction_Requests__c>{tr9},mapOfTR2);
        
        tr3.New_Buyer_s_Documents_Received__c = false;
        tr3.PropStrength__Status__c = 'Audit Approved';
        
        tr4.New_Buyer_s_Documents_Received__c = false;
        tr4.Mortgage_Amount__c = 1000;
        tr4.PropStrength__Status__c = 'Mortgage Fees Approved';

        tr1.PropStrength__Status__c = 'Request Completed';
        tr5.PropStrength__Status__c = 'SPA Executed';
        //tr7.PropStrength__Status__c = 'Request Completed';
        tr8.PropStrength__Status__c = 'Request Completed';
        tr12.PropStrength__Status__c = 'Payment Plan Change:Payment Plan Approved,Update Milestones and Service Tax';
        tr13.PropStrength__Status__c = 'Rejected by Audit Team';
        
        tr8.Handover_Document_Shared__c = true;
        tr10.Oqood_Certificate_No__c = '2';
        
       // update new List<PropStrength__Transaction_Requests__c>{tr1,tr3,tr4,tr5,tr7,tr8,tr9,tr10,tr12,tr13}; 
        update new List<PropStrength__Transaction_Requests__c>{tr1,tr3,tr4,tr5,tr8,tr9,tr10,tr12,tr13}; 
      
        tr3.New_Buyer_s_Documents_Received__c = true;
        tr4.New_Buyer_s_Documents_Received__c = true;
        tr4.Mortgage_Fees_Received__c = true;
        tr5.PropStrength__Status__c = 'NOC Generated';
        tr5.NOC_Handed_Over_to_Customer__c = true;
        
        update new List<PropStrength__Transaction_Requests__c>{tr3,tr4,tr5}; 
            
        Test.stopTest();
    } 
}