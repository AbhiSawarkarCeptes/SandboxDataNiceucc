@isTest
public class ContentDocumentLinkTriggerHelper_test {
    @isTest
    public static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        User user1 = TestDataFactory.createUserSysAdmin('On1e','Galvatr11on', 'galvat1111ron1@radius.com', 'g11alvatron1@radius.com');
        User user2 = TestDataFactory.createUserSysAdmin('On22e','Galvatro22n', 'galvat33ron14566@radius.com', 'g22alvatron12345@radius.com');
        
        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;
        
        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;
        
        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'SBF Assignment';
        insert groupName;
        
        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.Name = 'TestQueue';
        assignmentGroup.PropStrength__Assignment_Group__c = groupName.Id;
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        insert assignmentGroup;
        
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = groupName.Id;
        insert assignmentGroup1;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
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
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        // PropStrength__Applicant_Detail__c appDetail = new PropStrength__Applicant_Detail__c(PropStrength__Applicant_Acc__c=cont.Id,PropStrength__Type__c = '1st Applicant', PropStrength__Active__c = true, PropStrength__Non_Resident__c = true, PropStrength__Application__c = book.Id, Send_for_Docusign__c = true);
        // insert appDetail;
        
        // PropStrength__Applicant_Detail__c appDetailName = [SELECT Id, Name FROM PropStrength__Applicant_Detail__c WHERE Id = :appDetail.Id];
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                             Termination_Refund_Status__c ='');
        trList.add(tr);
        //insert tr;
        
        PropStrength__Transaction_Requests__c tr1 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                              Termination_Refund_Status__c ='Resubmit to Audit Review');
        trList.add(tr1);
        
        PropStrength__Transaction_Requests__c tr2 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                              Termination_Refund_Status__c ='Resubmit to Account Manager review');
        trList.add(tr2);
        
        PropStrength__Transaction_Requests__c tr3 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                              Termination_Refund_Status__c ='Resubmit to Treasury review');
        trList.add(tr3);
        
        PropStrength__Transaction_Requests__c tr4 = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Sent for Approval', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Refund').getRecordTypeId(), PropStrength__Application_Booking__c = book.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                              Termination_Refund_Status__c ='Resubmit to Respective department team member');
        trList.add(tr4);
        
        insert trList;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        Test.startTest();
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tr1.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        Insert conList;
        
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = book.Id;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = br.id;
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        Test.stopTest();
    }
    
    @testsetup
    public static void makeData(){
        Project__c objProject = new Project__c();
        objProject.name = 'Sobha Hartland';
        objProject.Project_Code__c='P253';
        insert objProject;
    }
    public testmethod static void testMethod2() {
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.DocumentId__c = '123456';
        insert enq;
        
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"FileContent\":\"FileContent\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"A12345\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\",\"DocumentId\":\"d123"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CreateVisitorRegistration.doPost();
        Test.stopTest();
        
        Sobha_Connect__c sobhaCon = TestDataFactorySobha.createSobhaConnect(null);
        insert sobhaCon;
        Customer_Registration__c customerReg = TestDataFactorySobha.createCustomerRegistration(null);
        insert customerReg;
        
        
        Visitor_Registration__c visitor = [select Id,First_Name__c, Site_Visit_Form__c, Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c from Visitor_Registration__c];
        //VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id,  visitor.DocumentId__c, visitor.File_Content__c);
        VisitorDashboardController.getContentDocumentId(visitor.Id);
        VisitorDashboardController.acceptRejectVisitor(visitor.Id,'Rejected',false);
        visitor.DocumentId__c = '123456';
        visitor.Site_Visit_Form__c = customerReg.id;
        update visitor;
        List<Visitor_Registration__c> vrList = new List<Visitor_Registration__c>();
        vrList.add(visitor);
        ContentVersion contentVersion = new ContentVersion(
            Title = visitor.First_Name__c,
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        List<ContentDocumentLink> existingLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :visitor.Id AND ContentDocumentId = :documents[0].Id];
        System.debug('existingLinks:::'+existingLinks);
        if (existingLinks.isEmpty()) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = visitor.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            conList.add(cdl);
        }
        Insert conList;
        
    }
    
    @isTest
    public static void testMethod3(){
        User u = [select id from user where userrole.name like '%Sales Manager%' limit 1];
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = u.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Channel_Partner__c = chPartner.id;
        evnt.Broker_Account__c = acc.id;
        //evnt.Event_Approved_status__c = System.Label.Event_Approved_Status;//'The event has been approved by Sales Director';
        insert evnt;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Booking form.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        Insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = evnt.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
    }
}