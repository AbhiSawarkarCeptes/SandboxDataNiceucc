@istest
public class eventtrgrhandlerTest {
   @istest
    static void testmethod1(){
       User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        PageReference pRef = Page.CreateQuote;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
        ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
        CreateQuote qController = new CreateQuote();
        qController.startQuote();
        qController.selectedPlan = recordMap.get('PLAN');
        //   qController.continueMethod();
        qController.saveQuote();
             
        Quotation__c q = [Select Id, Name from Quotation__c];
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = q.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.OwnerId = UserInfo.getUserId();

        b.Booking_Approver_Audit__c = 'Accepted';
        b.Agreement_Value__c = 1052700;
        b.Booking_Date_As_Per_The_SBTR__c = System.today().addDays(-5);
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        b.Sobha_Connect__c = sc.Id;
        b.Source_of_Booking__c = 'Sobha Connect';
        b.Qualification_Date__c = system.today();
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        // b.Sobha_Connect__c = null;
         b.Channel_Partner__c = chPartner.Id;
        // b.Source_of_Booking__c = 'Channel Partner';

        insert b;      
        /*Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        insert r1;
       
        b.Receipts__c = r1.Id;   
        List<Customer_Registration__c> crlst = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Sobha_Connect__c = sc.Id;
        cr1.Property_Type__c = 'Apartment';
        cr1.Site_Visit_Rating__c='warm';
        cr1.Visit_Next_Action__c='Follow up';
        cr1.Booking__c = b.Id;
        cr1.SM_Next_Action_Date__c=system.today().adddays(2);
        crlst.add(cr1);
        Customer_Registration__c cr2 = new Customer_Registration__c();
        cr2.Channel_Partner__c = chPartner.Id;
        cr2.Property_Type__c = 'Apartment';
        cr2.Site_Visit_Rating__c='warm';
        cr2.Visit_Next_Action__c='Follow up';
        cr2.SM_Next_Action_Date__c=system.today().adddays(2);
        cr2.Booking__c = b.Id;
        crlst.add(cr2);
        insert crlst;*/
        test.startTest();
        Opportunity opp = new  Opportunity(id = recordMap.get('OPPORTUNITY'));
        opp.Name = 'Aayushi';
        opp.Walk_In_SC__c = sc.Id;
        opp.date_of_Site_Visit__c = system.today();
        opp.Walk_In_source__c = 'Channel Partner';
        update opp;
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = u.id;
        evnt.Name = 'Road Shows';
        evnt.Date_Of_Event__c = System.today().addDays(22);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        evnt.Bypass_Validation_Rule__c = true;
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Channel_Partner__c = chPartner.id;
        //evnt.Sobha_Connect__c = sc.id;
        evnt.Event_Approved_status__c = 'The event has been approved by Sales Director';
        evntlst.add(evnt);
            
         evnt = new Events__c();
        evnt.Name = 'Road Shows';
        evnt.Sales_Manager__c = u.id;
        evnt.Bypass_Validation_Rule__c = true;
        evnt.Date_Of_Event__c = System.today().addDays(22);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        Id devRecordTypeId9 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId9;
        evnt.Channel_Partner__c = chPartner.id;
        //evnt.Sobha_Connect__c = sc.id;
         evnt.invoice_uploaded__c = false;
        evnt.Event_Approved_status__c = 'The event has been approved by VP';
            evnt.type_of_road_Show__c = 'Digital Roadshow';
        evntlst.add(evnt);
        
        evnt = new Events__c();
        evnt.Sales_Manager__c = u.id;
        evnt.Bypass_Validation_Rule__c = true;
        evnt.Name = 'Brokers Training';
        evnt.Date_Of_Event__c = System.today().addDays(22);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        Id devRecordTypeId2 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Training').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId2;
             evnt.invoice_uploaded__c = true;
            evnt.Channel_Partner__c = chPartner.id;
        
       // evnt.Event_Approved_status__c = 'The event has been approved by Manish Goenka';
        evntlst.add(evnt);
            
             evnt = new Events__c();
             evnt.Sales_Manager__c = u.id;
             evnt.Bypass_Validation_Rule__c = true;
        evnt.Name = 'Brokers Training';
        evnt.Date_Of_Event__c = System.today().addDays(22);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        Id devRecordTypeId7 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Training').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId7;
             evnt.invoice_uploaded__c = true;
            evnt.Sobha_Connect__c = sc.Id;        
     /*   evnt.Event_Approved_status__c = 'The event has been approved by Manish Goenka';
        evnt.Bypass_Validation_Rule__c = true; */
        evntlst.add(evnt);
        
        evnt = new Events__c();
        evnt.Sales_Manager__c = u.id;
        evnt.Bypass_Validation_Rule__c = true;
        evnt.Name = 'Open Houses';
        evnt.Date_Of_Event__c = System.today().addDays(22);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        evnt.Stay_End_Date__c = System.today().addDays(23);
        Id devRecordTypeId3 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId3;
            evnt.Channel_Partner__c = chPartner.id;
            evnt.Bypass_Validation_Rule__c = true;
         evnt.invoice_uploaded__c = true;
        evnt.Event_Approved_status__c = 'The event has been approved by VP';
        evntlst.add(evnt);
            
            evnt = new Events__c();
            evnt.Sales_Manager__c = u.id;
            evnt.Bypass_Validation_Rule__c = true;
            evnt.Name = 'Open Houses';
            evnt.Date_Of_Event__c = System.today().addDays(31);
            evnt.Stay_Start_Date__c = System.today().addDays(16);
            evnt.Stay_End_Date__c = System.today().addDays(23);
            Id devRecordTypeId4 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
            evnt.RecordTypeId = devRecordTypeId3;
            evnt.Channel_Partner__c = chPartner.id;
        
            evnt.invoice_uploaded__c = false;
            evnt.Event_Approved_status__c = 'The event has been approved by GM Hospitality';
           
            evntlst.add(evnt);
            
             evnt = new Events__c();
             evnt.Sales_Manager__c = u.id;
             evnt.Bypass_Validation_Rule__c = true;
            evnt.Name = 'Open Houses';
            evnt.Date_Of_Event__c = System.today().addDays(31);
            evnt.Stay_Start_Date__c = System.today().addDays(16);
            evnt.Stay_End_Date__c = System.today().addDays(23);
            Id devRecordTypeId5 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
            evnt.RecordTypeId = devRecordTypeId5;
            evnt.Channel_Partner__c = chPartner.id;
        
            evnt.invoice_uploaded__c = true;
            evnt.Event_Approved_status__c = 'The event has been approved by CRM OPs after Invoice Approval';
            evntlst.add(evnt);

        insert evntlst;
         system.debug('eventlist' + evntlst);
           
        b.Campaign_Code__c = evntlst[0].Id;
        update b;
        Opportunity opp1 = new  Opportunity(id = recordMap.get('OPPORTUNITY'));
        opp1.Name = 'Aayushi';
        opp1.channel_partner__C = chPartner.Id;
        opp1.date_of_Site_Visit__c = system.today().addYEars(-1);
        opp1.Walk_In_source__c = 'Channel Partner';
        update opp1;
        evntlst[0].Event_Approved_status__c = 'Pending With Sales Director';
        evntlst[0].channel_partner__c = null;
        evntlst[0].Sobha_Connect__c = sc.ID;
        
        update evntlst[0];
        evntlst[0].channel_partner__c = chPartner.Id;
        evntlst[0].Sobha_Connect__c = null;
        
        update evntlst[0];
        evntlst[0].Sales_Vp__C = UserInfo.getUserId();
        
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Sales Director';
        update evntlst[0];
        eventtrgrhandler.stopSaleSiteCalculation = true;
        
        evntlst[0].Event_Approved_status__c = 'The event has been approved by VP';
         
        update evntlst[0];
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Channel Relationship Manager';
        update evntlst[0];
       // evntlst[0].Event_Approved_status__c = 'The event has been approved by Ashish Parakh';
     //   update evntlst[0];
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Avin Anil';
        update evntlst[0];
        //evntlst[0].Sobha_Connect__c = sc.Id;
       // evntlst[1].Sobha_Connect__c = sc.Id;
       // evntlst[2].Sobha_Connect__c = sc.Id;
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Sales Director';   
        //evntlst[1].Event_Approved_status__c = 'The event has been approved by Avin Anil';    
        //evntlst[2].Event_Approved_status__c = 'The event has been approved by Ashish Parakh';    
           evntlst[0].type_of_road_Show__c = 'Digital Roadshow';
        update evntlst;
        evntlst[0].Event_Approved_status__c = 'The event has been approved by VP';   
        //evntlst[1].Event_Approved_status__c = 'The event has been approved by Avin Anil';    
        //evntlst[2].Event_Approved_status__c = 'The event has been approved by Ashish Parakh';    
           evntlst[0].type_of_road_Show__c = 'Digital Roadshow';
        update evntlst;
        evntlst[0].Event_Approved_status__c = 'Pending With Sales Director';   
        //evntlst[1].Event_Approved_status__c = 'The event has been approved by Avin Anil';    
        //evntlst[2].Event_Approved_status__c = 'The event has been approved by Ashish Parakh';    
           evntlst[0].type_of_road_Show__c = 'Digital Roadshow';
        update evntlst;
        evntlst[0].Channel_Partner__c =  chPartner.id;
        evntlst[1].Channel_Partner__c =  chPartner.id;
        evntlst[2].Channel_Partner__c =  chPartner.id;
            evntlst[0].type_of_road_Show__c ='Digital Roadshow';
            evntlst[1].type_of_road_Show__c = '';
            evntlst[2].type_of_road_Show__c = '';
           
        update evntlst;
         Map<Id,Events__c> EventMap = new Map<Id,Events__c>();
        Events__c evnts = new Events__c();
        evnts.Sales_Manager__c = u.id;
        
        evnts.Event_Approved_status__c = 'The event has been approved by GM Hospitality';
        evnts.Name = 'Open Houses';
            evnts.Date_Of_Event__c = System.today().addDays(22);
            evnts.Stay_Start_Date__c = System.today().addDays(16);
            evnts.Stay_End_Date__c = System.today().addDays(23);
            Id devRecordTypeId11 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
            evnts.RecordTypeId = devRecordTypeId11;
            evnts.Channel_Partner__c = chPartner.id;        
            evnts.invoice_uploaded__c = true;
        insert evnts;
        List<Events__c> eventlist = new List<Events__c>();
        for(Events__c evt : [select id ,Event_Approved_status__c from Events__c where id =: evntlst[0].id ]){
                EventMap.put(evt.id,evt);    
                
        }
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Invoice Uploaded By GM Hospitality',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        evntlst[0].invoice_uploaded__c = true;
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Avin Anil';
        evntlst[0].type_of_road_Show__c = 'Digital Roadshow';
        update evntlst[0];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('evntlst[0].id' + evntlst[0].id);
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = evntlst[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
       
        
        eventlist.add(evntlst[0]);
        system.debug('eventdebug' + eventlist + '///' + EventMap);
        eventtrgrhandler.sendEmailForDigitalShow(eventlist,EventMap);
        evntlst[0].invoice_uploaded__c = true;
        evntlst[0].Event_Approved_status__c = 'The event has been approved by GM Hospitality';
        update evntlst[0];
        evntlst[0].type_of_road_Show__c = null;
        evntlst[0].Event_Approved_status__c = 'The event has been approved by Ashish Parakh';
        update evntlst[0];
        eventManagementForVPController.eventWithinCurrentMonth();
        
        test.stopTest();

       
    }
   @istest
   static void testMethod02(){
    User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
      
       List<Events__c> evntlst = new list<Events__c>();
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        PageReference pRef = Page.CreateQuote;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
        ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));
        CreateQuote qController = new CreateQuote();
        qController.startQuote();
        qController.selectedPlan = recordMap.get('PLAN');
        //   qController.continueMethod();
        qController.saveQuote();
             
        Quotation__c q = [Select Id, Name from Quotation__c];
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = q.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.OwnerId = UserInfo.getUserId();

        b.Booking_Approver_Audit__c = 'Accepted';
        b.Agreement_Value__c = 1052700;
        b.Booking_Date_As_Per_The_SBTR__c = System.today().addDays(-5);
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        b.Sobha_Connect__c = sc.Id;
        b.Source_of_Booking__c = 'Sobha Connect';
        b.Qualification_Date__c = system.today();
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        // b.Sobha_Connect__c = null;
         b.Channel_Partner__c = chPartner.Id;
        // b.Source_of_Booking__c = 'Channel Partner';

        insert b;      
        test.startTest();  
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cheque';
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        insert r1;
       
        b.Receipts__c = r1.Id;   
        List<Customer_Registration__c> crlst = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Sobha_Connect__c = sc.Id;
        cr1.Property_Type__c = 'Apartment';
        cr1.Site_Visit_Rating__c='warm';
        cr1.Visit_Next_Action__c='Follow up';
        cr1.Booking__c = b.Id;
        cr1.SM_Next_Action_Date__c=system.today().adddays(2);
        crlst.add(cr1);
        Customer_Registration__c cr2 = new Customer_Registration__c();
        cr2.Channel_Partner__c = chPartner.Id;
        cr2.Property_Type__c = 'Apartment';
        cr2.Site_Visit_Rating__c='warm';
        cr2.Visit_Next_Action__c='Follow up';
        cr2.SM_Next_Action_Date__c=system.today().adddays(2);
        cr2.Booking__c = b.Id;
        crlst.add(cr2);
        insert crlst;
       Events__c evnt = new Events__c();
       evnt.Sales_Manager__c = u.id;
        
       evnt.Name = 'Road Shows';
       evnt.Date_Of_Event__c = System.today().addDays(27);//start date
       evnt.End_Date_Of_Event__c = System.today().addDays(29);
       evnt.Bypass_Validation_Rule__c = true;
       Id devRecordTypeId9 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
       evnt.RecordTypeId = devRecordTypeId9;
       evnt.Channel_Partner__c = chPartner.id;
       //evnt.Sobha_Connect__c = sc.id;
       evnt.invoice_uploaded__c = false;
       evnt.Event_Approved_status__c = 'The event has been approved by VP';
       evnt.type_of_road_Show__c = 'Digital Roadshow';
       evnt.Date_Of_Event__c = system.today().addDays(31);
       evntlst.add(evnt);
       
        Events__c evnt1 = new Events__c();
        evnt1.Sales_Manager__c = u.id;
        
       evnt1.Name = 'Road Shows';
       evnt.Date_Of_Event__c = System.today().addDays(27);//start date
       evnt.End_Date_Of_Event__c = System.today().addDays(29);
       evnt.Bypass_Validation_Rule__c = true;
       Id devRecordTypeId91 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
       evnt1.RecordTypeId = devRecordTypeId9;
       evnt1.Channel_Partner__c = chPartner.id;
       evnt1.Bypass_Validation_Rule__c = true;
       //evnt.Sobha_Connect__c = sc.id;
       evnt1.invoice_uploaded__c = false;
       evnt1.Event_Approved_status__c = 'The event has been approved by VP';
       evnt1.type_of_road_Show__c = 'Digital Roadshow';
       evnt1.Date_Of_Event__c = system.today().addDays(31);
       evntlst.add(evnt1);
       insert evntlst;
       eventtrgrhandler.validateEventInsert(evntlst);
       evnt1.invoice_uploaded__c = true;
       evnt1.Event_Approved_status__c = 'The event has been approved by GM Hospitality';
       update evnt1;
       evnt1.Event_Approved_status__c = 'The event has been approved by Ashish Parakh';
       update evnt1;
       /*evnt1.Event_Approved_status__c = 'The event has been approved by Manish Goenka';
       update evnt1;*/
       Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
       evnt1.RecordTypeId = devRecordTypeId1;
     
       evnt1.Event_Approved_status__c = 'Approved by CMO';
       update evnt1;
       evnt1.Event_Approved_status__c = 'Pending With CHRM manager TL';
       evnt1.No_Of_Pax_Attending__c = 3;
       try{
      
       update evnt1;
       }catch(exception e){
        
       }
       test.stopTest();
    }
    
 /*   @istest
   static void testMethod03(){
		 User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
      
       List<Events__c> evntlst = new list<Events__c>();
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        PageReference pRef = Page.CreateQuote;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('oppId',recordMap.get('OPPORTUNITY'));
        ApexPages.currentPage().getParameters().put('Id',recordMap.get('UNIT'));

CreateQuote qController = new CreateQuote();
        qController.startQuote();
        qController.selectedPlan = recordMap.get('PLAN');
        //   qController.continueMethod();
        qController.saveQuote();
             
        Quotation__c q = [Select Id, Name from Quotation__c];
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
		
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
       
       Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
       
       Events__c evnt = new Events__c();
       evnt.Sales_Manager__c = u.id;
        
       evnt.Name = 'Road Shows';
       evnt.Date_Of_Event__c = System.today().addDays(27);//start date
       evnt.End_Date_Of_Event__c = System.today().addDays(29);
       evnt.Bypass_Validation_Rule__c = true;
       Id devRecordTypeId9 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
       evnt.RecordTypeId = devRecordTypeId9;
       evnt.Channel_Partner__c = chPartner.id;
       //evnt.Sobha_Connect__c = sc.id;
       evnt.invoice_uploaded__c = false;
       evnt.Event_Approved_status__c = 'The event has been approved by VP';
       evnt.type_of_road_Show__c = 'Digital Roadshow';
       evnt.Date_Of_Event__c = system.today().addDays(31);
       evntlst.add(evnt);
       
       Events__c evnt1 = new Events__c();
        evnt1.Sales_Manager__c = u.id;
        
       evnt1.Name = 'Road Shows';
       evnt.Date_Of_Event__c = System.today().addDays(27);//start date
       evnt.End_Date_Of_Event__c = System.today().addDays(29);
       evnt.Bypass_Validation_Rule__c = true;
       Id devRecordTypeId91 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
       evnt1.RecordTypeId = devRecordTypeId9;
       evnt1.Channel_Partner__c = chPartner.id;
       evnt1.Bypass_Validation_Rule__c = true;
       //evnt.Sobha_Connect__c = sc.id;
       evnt1.invoice_uploaded__c = false;
       evnt1.Event_Approved_status__c = 'The event has been approved by VP';
       evnt1.type_of_road_Show__c = 'Digital Roadshow';
       evnt1.Date_Of_Event__c = system.today().addDays(31);
       evntlst.add(evnt1);
       insert evntlst;
        Map<Id,Events__c> EventMap = new Map<Id,Events__c>();
       for(Events__c evt : [select id ,Event_Approved_status__c from Events__c where id =: evntlst[0].id ]){
                EventMap.put(evt.id,evt);    
        }
       eventtrgrhandler.eventStatusUpdate(evntlst,EventMap);
   } */
    
}