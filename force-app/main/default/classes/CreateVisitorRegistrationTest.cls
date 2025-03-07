@istest
public class CreateVisitorRegistrationTest {
    @testsetup
    public static void makeData(){
        Project__c objProject = new Project__c();
        objProject.name = 'Sobha Hartland';
        objProject.Project_Code__c='P253';
        insert objProject;
    }
    public testmethod static void postNewWalkInLead() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
		String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"FileContent\":\"FileContent\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\",\"DocumentId\":\"d123"}]';
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
        Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c, Alternate_Mobile_Number__c, AlternateEmail_Address__c from Visitor_Registration__c];
        VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id,  visitor.DocumentId__c, visitor.File_Content__c,visitor.Alternate_Mobile_Number__c, visitor.AlternateEmail_Address__c );
        Account objAccount = [SELECT ID,NAME FROM ACCOUNT];
        Contact objContact = [SELECT ID,NAME FROM CONTACT];
        Opportunity objOpportunity = [SELECT ID,NAME FROM OPPORTUNITY];
        Customer_Registration__c objCustomerRegistration = [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c];
        VisitorDashboardController.getContentDocumentId(visitor.Id);
        VisitorDashboardController.acceptRejectVisitor(visitor.Id,'Rejected',false);
        Assert.areEqual('John Test', objAccount.Name, 'Expected Account needs to be created with name Jhon');
        Assert.areEqual('John Test', objContact.Name, 'Expected Contact needs to be created with name Jhon');
        Assert.areEqual('John', objCustomerRegistration.First_Name__c, 'Expected Customer Registration name to be created with name Jhon');
        System.debug('Account ->'+ objAccount);
        System.debug('Contact ->'+ objContact);
        System.debug('Opportunity ->'+ objOpportunity);
        System.debug('Customer Registration ->'+ objCustomerRegistration);
    }
    public testmethod static void postExistingLeadWalkIn() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        Lead objLead = new Lead();
        objLead.FirstName = 'John';
        objLead.LastName = 'Test';
        objLead.Email = 'John@test.com';
        objLead.MobilePhone = '8579171110';
        objLead.RDS_Alternate_Email_Id__c = 'jhon.deo@test.com';
        insert objLead;
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"jhon.deo@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
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
        Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c from Visitor_Registration__c];
        VisitorDashboardController.acceptRejectVisitor(visitor.Id,'Accepted',false);
        List<Account> lstAccount = [SELECT ID,NAME FROM ACCOUNT];
        List<Contact> lstContact = [SELECT ID,NAME FROM CONTACT];
        List<Opportunity> lstOpportunity = [SELECT ID,NAME FROM OPPORTUNITY];
        list<Customer_Registration__c> objCustomerRegistration = [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c];
        System.debug('Account ->'+ lstAccount);
        System.debug('Contact ->'+ lstContact);
        System.debug('Opportunity ->'+ lstOpportunity);
        System.debug('Customer Registration ->'+ objCustomerRegistration[0]);
        Assert.areEqual('John Test', lstAccount[0].Name, 'Expected Account needs to be created with name Jhon');
        Assert.areEqual('John Test', lstContact[0].Name, 'Expected Contact needs to be created with name Jhon');
        Assert.areEqual('John', objCustomerRegistration[0].First_Name__c, 'Expected Customer Registration name to be created with name Jhon');
    }
    public testmethod static void postExistingLeadWithProjectWalkIn() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        Lead objLead = new Lead();
        objLead.FirstName = 'John';
        objLead.LastName = 'Test';
        objLead.Email = 'John@test.com';
        objLead.MobilePhone = '8579171110';
        objLead.RDS_Alternate_Email_Id__c = 'jhon.deo@test.com';
        objLead.Project__c = [SELECT ID FROM PROJECT__C].ID;
        insert objLead;
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"jhon.deo@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
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
        Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c,Alternate_Mobile_Number__c, AlternateEmail_Address__c from Visitor_Registration__c];
        VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id, visitor.DocumentId__c, visitor.File_Content__c,visitor.Alternate_Mobile_Number__c, visitor.AlternateEmail_Address__c);
        List<Account> lstAccount = [SELECT ID,NAME FROM ACCOUNT];
        List<Contact> lstContact = [SELECT ID,NAME FROM CONTACT];
        List<Opportunity> lstOpportunity = [SELECT ID,NAME FROM OPPORTUNITY];
        Customer_Registration__c objCustomerRegistration = [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c];
        System.debug('Account ->'+ lstAccount);
        System.debug('Contact ->'+ lstContact);
        System.debug('Opportunity ->'+ lstOpportunity);
        System.debug('Customer Registration ->'+ objCustomerRegistration);
        Assert.areEqual('John Test', lstAccount[0].Name, 'Expected Account needs to be created with name Jhon');
        Assert.areEqual('John Test', lstContact[0].Name, 'Expected Contact needs to be created with name Jhon');
        Assert.areEqual('John', objCustomerRegistration.First_Name__c, 'Expected Customer Registration name to be created with name Jhon');
    }
    public testmethod static void postExistingAccountWalkIn() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        Account objAccount = new Account();
        objAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        objAccount.FirstName = 'John';
        objAccount.LastName = 'Test';
        objAccount.PersonMobilePhone = '8579171110';
        objAccount.Phone = '8579171110';
        objAccount.PersonEmail = 'John@test.com';
        insert objAccount;
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"jhon.deo@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
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
        Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c,Alternate_Mobile_Number__c,AlternateEmail_Address__c from Visitor_Registration__c];
        VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id, visitor.DocumentId__c, visitor.File_Content__c,visitor.Alternate_Mobile_Number__c, visitor.AlternateEmail_Address__c);
        List<Account> lstAccount = [SELECT ID,NAME FROM ACCOUNT];
        List<Contact> lstContact = [SELECT ID,NAME FROM CONTACT];
        List<Opportunity> lstOpportunity = [SELECT ID,NAME FROM OPPORTUNITY];
        Customer_Registration__c objCustomerRegistration = [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c];
        System.debug('Account ->'+ lstAccount);
        System.debug('Contact ->'+ lstContact);
        System.debug('Opportunity ->'+ lstOpportunity);
        System.debug('Customer Registration ->'+ [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c]);
        Assert.areEqual('John Test', lstAccount[0].Name, 'Expected Account needs to be created with name Jhon');
        Assert.areEqual('John Test', lstContact[0].Name, 'Expected Contact needs to be created with name Jhon');
        Assert.areEqual('John', objCustomerRegistration.First_Name__c, 'Expected Customer Registration name to be created with name Jhon');
    }
    public testmethod static void postExistingAccountOpportunityWalkIn() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        Account objAccount = new Account();
        objAccount.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE DEVELOPERNAME = 'PersonAccount'].ID;
        objAccount.FirstName = 'John';
        objAccount.LastName = 'Test';
        objAccount.PersonMobilePhone = '8579171110';
        objAccount.Phone = '8579171110';
        objAccount.PersonEmail = 'John@test.com';
        insert objAccount;
        Opportunity opp = new Opportunity();
        opp.Name = 'John';
        opp.AccountId = objAccount.Id;
        opp.Project__c = [SELECT ID FROM Project__c].ID;
        opp.StageName = 'Site Visit Done';
        Date currentDate = Date.today();
        Date oneMonthLater = currentDate.addMonths(1);
        opp.CloseDate = oneMonthLater;
        insert opp;
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"jhon.deo@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
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
        Visitor_Registration__c visitor = [select Id,Project_Name__c,Email__c,Mobile__c,File_Content__c,DocumentId__c,Alternate_Mobile_Number__c,AlternateEmail_Address__c from Visitor_Registration__c];
        VisitorDashboardController.submitVisitor(visitor.Project_Name__c,visitor.Email__c,visitor.Mobile__c,visitor.Id, visitor.DocumentId__c, visitor.File_Content__c,visitor.Alternate_Mobile_Number__c, visitor.AlternateEmail_Address__c);
        List<Account> lstAccount = [SELECT ID,NAME FROM ACCOUNT];
        List<Contact> lstContact = [SELECT ID,NAME FROM CONTACT];
        List<Opportunity> lstOpportunity = [SELECT ID,NAME FROM OPPORTUNITY];
        Customer_Registration__c objCustomerRegistration = [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c];
        System.debug('Account ->'+ lstAccount);
        System.debug('Contact ->'+ lstContact);
        System.debug('Opportunity ->'+ lstOpportunity);
        System.debug('Customer Registration ->'+ [SELECT ID,NAME,First_Name__c FROM Customer_Registration__c]);
        Assert.areEqual('John Test', lstAccount[0].Name, 'Expected Account needs to be created with name Jhon');
        Assert.areEqual('John Test', lstContact[0].Name, 'Expected Contact needs to be created with name Jhon');
        Assert.areEqual('John', objCustomerRegistration.First_Name__c, 'Expected Customer Registration name to be created with name Jhon');
    }
    public testmethod static void postFirstNameException() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        String reqBody = '[{\"First_Name\":\"\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CreateVisitorRegistration.ResponseWrapper objResponseFirstNameError = CreateVisitorRegistration.doPost();
        Test.stopTest();
        //Assert.areEqual('First Name can not be null', objResponseFirstNameError.message, 'Expected Error message must be return as First Name can not be null.');
    }
    public testmethod static void postMobileException() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        String reqBody = '[{\"First_Name\":\"Jhon\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CreateVisitorRegistration.ResponseWrapper objResponseFirstNameError = CreateVisitorRegistration.doPost();
        Test.stopTest();
        //Assert.areEqual('Mobile can not be null', objResponseFirstNameError.message, 'Expected Error message must be return as Mobile can not be null.');
    }
     public testmethod static void postJSONException() {
         Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
         
        String reqBody = '[{\"First_Name:\"Jhon\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CreateVisitorRegistration.ResponseWrapper objResponseFirstNameError = CreateVisitorRegistration.doPost();
        Test.stopTest();
        Assert.isTrue([SELECT ID FROM Error_Log__c].Size() > 0);
    }
    public testmethod static void postEmailException() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        String reqBody = '[{\"First_Name\":\"Jhon\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        CreateVisitorRegistration.ResponseWrapper objResponseFirstNameError = CreateVisitorRegistration.doPost();
        Test.stopTest();
        //Assert.areEqual('Email can not be null', objResponseFirstNameError.message, 'Expected Error message must be return as Email can not be null.');
    }
    public testmethod static void postGetListOfVisitors() {
        Channel_Partner__c chPartner = new Channel_Partner__c();
        chPartner.Name = 'Test Channel Partner';
        chPartner.Expiry_Date__c = System.today();
        chPartner.Channel_Relationship_Manager__c = UserInfo.getUserId();
        chPartner.Email_ID_1__c='test@test.com';
        insert chPartner;
        
        Channel_Partner__c chp = [Select Id,Channel_Partner_Id__c From Channel_Partner__c Where Id =: chPartner.Id ];
        
        String reqBody = '[{\"First_Name\":\"John\",\"Last_Name\":\"Test\",\"Country\":\"India\",\"Nationality\":\"Indian\",\"Email\":\"John@test.com\",\"Mobile\":\"8579171110\",\"UAE_Resident\":\"true\",\"Address\":\"BangaloreAirportRoad\",\"City\":\"Bangalore\",\"Interested_In\":\"Villa\",\"Purpose_Of_Purchase\":\"Investment\",\"Remarks\":\"IneedaVillaatanycost.\",\"Source\":\"Walk-in\",\"Agent_Name\":\"AravindKumar\",\"Agent_Id\":\"'+chp.Channel_Partner_Id__c+'\",\"Company\":\"Ceptes\",\"Sales_Advisor\":\"AbdulKumar\",\"Alternate_Email\":\"vvkkmrnew10@test.com\",\"Alternate_Mobile\":\"8579171110\",\"Designation\":\"Acountant\",\"Existing_Sobha_Owner\":\"No\",\"Occupation\":\"Salaried\",\"Project_Name\":\"Sobha Hartland\",\"Visiting_On_Behalf_Of\":\"Self\",\"Residential_Status\":\"UAE Resident\"}]';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/pushVisitorRegistration'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody= Blob.valueOf(reqBody);
        RestContext.request = req;
        RestContext.response= res;
        CreateVisitorRegistration.doPost();
        Test.startTest();
        VisitorDashboardController.getVisitors();
        Test.stopTest();
        List<Visitor_Registration__c> lstVisitor = [SELECT ID FROM Visitor_Registration__c];
        Assert.isTrue(lstVisitor.Size() > 0);
    }
}