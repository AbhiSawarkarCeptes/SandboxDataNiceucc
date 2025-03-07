@isTest
public class ServiceRequestTriggerHelper_Test {

    @testSetup 
    static void createData(){
        PropStrength__Projects__c project = TestDataFactorySobha.createProject(null);
        insert project;

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        Contact con = TestDataFactorySobha.createContact(null);
        con.Email = 'username@test.com';
        insert con;

        PropStrength__Assignment_Group_Name__c assgmtGroup = TestDataFactorySobha.createAssignmentGroup(null);
        insert assgmtGroup;

        PropStrength__Request__c request = TestDataFactorySobha.createEnquiry(null);
        insert request;
        
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;

        PropStrength__Property__c property = TestDataFactorySobha.createProperty(null);
        insert property;
        
        PropStrength__Payment_Plan__c paymentPlan = TestDataFactorySobha.createPaymentPlan(null);
        insert paymentPlan;

        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;

        PropStrength__Brokerage_Scheme__c brokerageScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brokerageScheme;

        PropStrength__Application_Booking__c appBookObj = TestDataFactorySobha.createApplicationBooking(null);
        insert appBookObj;
    }
    @isTest
    public static void testMethod1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();

        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Collections Queue';
        groupName.PropStrength__Type__c = 'Service Request';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Service Request';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        
        insert grpNameList;

        User user1 = TestDataFactory.createUserSysAdmin('Onet1t2t2','Galvat323322323ron', 'galvatr112121on1@radius.com', 'galvatron1@r45454adius.com');
        User user2 = TestDataFactory.createUserSysAdmin('One2333333','Galvat32323ron2', 'galvatron1212114566@radius.com', 'galvatro45454545n12345@radius.com');

        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;

        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;

        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        assignmentGroup.Name = 'Test1';
        assignmentGroup.PropStrength__Assignment_Group__c = grpNameList[0].Id;
        
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = grpNameList[0].Id;

        PropStrength__Group_Member__c assignmentGroup2 = new PropStrength__Group_Member__c();
        assignmentGroup2.PropStrength__User__c = user1.Id;
        assignmentGroup2.Rank__c = 1;
        assignmentGroup2.PropStrength__Order__c = 1;
        assignmentGroup2.PropStrength__Active__c = 'True';
        assignmentGroup2.Name = 'Test2';
        assignmentGroup2.PropStrength__Last_Assigned__c = true;
        assignmentGroup2.PropStrength__Assignment_Group__c = grpNameList[1].Id;
        
        PropStrength__Group_Member__c assignmentGroup3 = new PropStrength__Group_Member__c();
        assignmentGroup3.PropStrength__User__c = user2.Id;
        assignmentGroup3.Rank__c = 2;
        assignmentGroup3.PropStrength__Order__c = 2;
        assignmentGroup3.PropStrength__Active__c = 'True';
        assignmentGroup3.Name = 'Presales Agent1';
        assignmentGroup3.PropStrength__Assignment_Group__c = grpNameList[1].Id;

        insert new List<PropStrength__Group_Member__c>{assignmentGroup,assignmentGroup1,assignmentGroup2,assignmentGroup3};

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='test@test.com',
                        
                        EmailEncodingKey='UTF-8', LastName='Email admin', LanguageLocaleKey='en_US',
                        
                        LocaleSidKey='en_US', ProfileId = p.Id,City = 'Meerut',
                        
                        TimeZoneSidKey='America/Los_Angeles', UserName='gggtestmldl@test.com');
        
        insert u;
        
        
        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2345t';
        con.Ownerid = u.id;
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;
        
        Service_Request_SLA__c serviceReq = new Service_Request_SLA__c();
        serviceReq.Priority__c = 1;
        serviceReq.SR_Sub_Category__c = 'Inspection'; 
        serviceReq.Category__c = 'Handover';
        insert serviceReq;
        
        Service_Request_SLA__c serviceReq2 = new Service_Request_SLA__c();
        serviceReq2.Priority__c = 2;
        serviceReq2.SR_Sub_Category__c = 'Inspection'; 
        serviceReq2.Category__c = 'Handover';
        insert serviceReq2;
       
        Service_Request_SLA__c serviceReq3 = new Service_Request_SLA__c();
        serviceReq3.Priority__c = 2;
        serviceReq3.SR_Sub_Category__c = 'Inspection'; 
        serviceReq3.Category__c = 'Handover';
        insert serviceReq3;
        
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        
        PropStrength__Service_Request__c enq1 = new PropStrength__Service_Request__c();
        enq1.PropStrength__Apply_Assignment_Rule__c = true;
        enq1.PropStrength__First_Name__c = con.FirstName;
        enq1.PropStrength__Last_Name__c =con.LastName;
        enq1.PropStrength__Status__c = 'Closed';
        enq1.PropStrength__Project__c = pro.id;
        enq1.PropStrength__Origin__c = 'Email';
        enq1.To_Email_Address__c = 'collections@sobharealty.com';
        enq1.PropStrength__Application_Booking__c = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        try{
            insert enq1;       
        }catch(Exception ex){}
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = con.FirstName;
        enq2.PropStrength__Last_Name__c =con.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Project__c = pro.id;
        enq2.PropStrength__Origin__c = 'Email';
        enq2.To_Email_Address__c = 'collections@sobharealty.com';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'comment';
        enq2.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;        
        insert enq2;

        PropStrength__Service_Request__c enq3  = new PropStrength__Service_Request__c();
        enq3.PropStrength__Apply_Assignment_Rule__c = true;
        enq3.PropStrength__First_Name__c = con.FirstName;
        enq3.PropStrength__Last_Name__c =con.LastName;
        enq3.PropStrength__Status__c = 'Closed';
        enq3.PropStrength__Project__c = pro.id;
        enq3.PropStrength__Origin__c = 'Email';
        enq3.To_Email_Address__c = 'support@sobharealty.com';
        enq3.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        enq3.SR_Category__c = 'Handover';
        enq3.SR_Sub_Category__c = 'Inspection';
        try{ 
            insert enq3;        
        }catch(Exception ex){}
        
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Request_Origin__c = 'Mobile App';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test';
        try{        
            update enq2;
         }catch(Exception ex){} 
         
        enq2.PropStrength__Status__c = 'Reopened';
        try{        
            update enq2;
         }catch(Exception ex){}      
        
        ServiceRequestTriggerHelper.pushProfileCaseAPI(new Set<Id>{enq3.Id, enq2.Id});
        
        enq3.SR_Category__c = 'AC';
        enq3.SR_Sub_Category__c = 'Thermostat';
        try{ 
            update enq3;        
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod110() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();

        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Collections Queue';
        groupName.PropStrength__Type__c = 'Service Request';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Service Request';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        
        PropStrength__Assignment_Group_Name__c groupName3 = new PropStrength__Assignment_Group_Name__c();
        groupName3.Name = 'Siniya Island SR Assignment Group';
        groupName3.PropStrength__Type__c = 'Service Request';
        groupName3.PropStrength__Active__c = true;
        grpNameList.add(groupName3);
        
        insert grpNameList;

        User user1 = TestDataFactory.createUserSysAdmin('Onet1t2t2','Galvat323322323ron', 'galvatr112121on1@radius.com', 'galvatron1@r45454adius.com');
        User user2 = TestDataFactory.createUserSysAdmin('One2333333','Galvat32323ron2', 'galvatron1212114566@radius.com', 'galvatro45454545n12345@radius.com');

        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;

        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;

        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        assignmentGroup.Name = 'Test1';
        assignmentGroup.PropStrength__Assignment_Group__c = grpNameList[0].Id;
        
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = grpNameList[0].Id;

        PropStrength__Group_Member__c assignmentGroup2 = new PropStrength__Group_Member__c();
        assignmentGroup2.PropStrength__User__c = user1.Id;
        assignmentGroup2.Rank__c = 1;
        assignmentGroup2.PropStrength__Order__c = 1;
        assignmentGroup2.PropStrength__Active__c = 'True';
        assignmentGroup2.Name = 'Test2';
        assignmentGroup2.PropStrength__Last_Assigned__c = true;
        assignmentGroup2.PropStrength__Assignment_Group__c = grpNameList[1].Id;
        
        PropStrength__Group_Member__c assignmentGroup3 = new PropStrength__Group_Member__c();
        assignmentGroup3.PropStrength__User__c = user2.Id;
        assignmentGroup3.Rank__c = 2;
        assignmentGroup3.PropStrength__Order__c = 2;
        assignmentGroup3.PropStrength__Active__c = 'True';
        assignmentGroup3.Name = 'Presales Agent1';
        assignmentGroup3.PropStrength__Assignment_Group__c = grpNameList[1].Id;
        
        PropStrength__Group_Member__c assignmentGroup4 = new PropStrength__Group_Member__c();
        assignmentGroup4.PropStrength__User__c = user1.Id;
        assignmentGroup4.Rank__c = 1;
        assignmentGroup4.PropStrength__Order__c = 1;
        assignmentGroup4.PropStrength__Active__c = 'True';
        assignmentGroup4.Name = 'Test4';
        assignmentGroup4.PropStrength__Last_Assigned__c = true;
        assignmentGroup4.PropStrength__Assignment_Group__c = grpNameList[2].Id;
        
        PropStrength__Group_Member__c assignmentGroup5 = new PropStrength__Group_Member__c();
        assignmentGroup5.PropStrength__User__c = user2.Id;
        assignmentGroup5.Rank__c = 2;
        assignmentGroup5.PropStrength__Order__c = 2;
        assignmentGroup5.PropStrength__Active__c = 'True';
        assignmentGroup5.Name = 'Presales Agent5';
        assignmentGroup5.PropStrength__Assignment_Group__c = grpNameList[2].Id;

        insert new List<PropStrength__Group_Member__c>{assignmentGroup,assignmentGroup1,assignmentGroup2,assignmentGroup3, assignmentGroup4, assignmentGroup5};

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='test@test.com',
                        
                        EmailEncodingKey='UTF-8', LastName='Email admin', LanguageLocaleKey='en_US',
                        
                        LocaleSidKey='en_US', ProfileId = p.Id,City = 'Meerut',
                        
                        TimeZoneSidKey='America/Los_Angeles', UserName='gggtestmldl@test.com');
        
        insert u;
        
        
        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2345t';
        con.Ownerid = u.id;
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;
        
        Service_Request_SLA__c serviceReq = new Service_Request_SLA__c();
        serviceReq.Priority__c = 1;
        serviceReq.SR_Sub_Category__c = 'Inspection'; 
        serviceReq.Category__c = 'Handover';
        insert serviceReq;
        
        Service_Request_SLA__c serviceReq2 = new Service_Request_SLA__c();
        serviceReq2.Priority__c = 2;
        serviceReq2.SR_Sub_Category__c = 'Inspection'; 
        serviceReq2.Category__c = 'Handover';
        insert serviceReq2;
       
        Service_Request_SLA__c serviceReq3 = new Service_Request_SLA__c();
        serviceReq3.Priority__c = 2;
        serviceReq3.SR_Sub_Category__c = 'Inspection'; 
        serviceReq3.Category__c = 'Handover';
        insert serviceReq3;
        
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        
        PropStrength__Service_Request__c enq1 = new PropStrength__Service_Request__c();
        enq1.PropStrength__Apply_Assignment_Rule__c = true;
        enq1.PropStrength__First_Name__c = con.FirstName;
        enq1.PropStrength__Last_Name__c =con.LastName;
        enq1.PropStrength__Status__c = 'Closed';
        enq1.PropStrength__Project__c = pro.id;
        enq1.PropStrength__Origin__c = 'Email';
        enq1.To_Email_Address__c = 'customercare@SobhaSiniyaIsland.com';
        enq1.PropStrength__Application_Booking__c = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1].Id;
        try{
            insert enq1;       
        }catch(Exception ex){}
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = con.FirstName;
        enq2.PropStrength__Last_Name__c =con.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Project__c = pro.id;
        enq2.PropStrength__Origin__c = 'Email';
        enq2.To_Email_Address__c = 'collections@sobharealty.com';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'comment';
        enq2.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;        
        insert enq2;

        PropStrength__Service_Request__c enq3  = new PropStrength__Service_Request__c();
        enq3.PropStrength__Apply_Assignment_Rule__c = true;
        enq3.PropStrength__First_Name__c = con.FirstName;
        enq3.PropStrength__Last_Name__c =con.LastName;
        enq3.PropStrength__Status__c = 'Closed';
        enq3.PropStrength__Project__c = pro.id;
        enq3.PropStrength__Origin__c = 'Email';
        enq3.To_Email_Address__c = 'support@sobharealty.com';
        enq3.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        enq3.SR_Category__c = 'Handover';
        enq3.SR_Sub_Category__c = 'Inspection';
        try{ 
            insert enq3;        
        }catch(Exception ex){}
        
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Request_Origin__c = 'Mobile App';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'Test';
        try{        
            update enq2;
         }catch(Exception ex){} 
         
        enq2.PropStrength__Status__c = 'Reopened';
        try{        
            update enq2;
         }catch(Exception ex){}      
        
        ServiceRequestTriggerHelper.pushProfileCaseAPI(new Set<Id>{enq3.Id, enq2.Id});
        
        enq3.SR_Category__c = 'AC';
        enq3.SR_Sub_Category__c = 'Thermostat';
        try{ 
            update enq3;        
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2() {
        Test.startTest();
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        mock.statusCode = 500;
        Test.setMock(HttpCalloutMock.class, mock);
        List<PropStrength__Assignment_Group_Name__c> grpNameList = new List<PropStrength__Assignment_Group_Name__c>();

        PropStrength__Assignment_Group_Name__c groupName = new PropStrength__Assignment_Group_Name__c();
        groupName.Name = 'Collections Queue';
        groupName.PropStrength__Type__c = 'Service Request';
        groupName.PropStrength__Active__c = true;
        grpNameList.add(groupName);

        PropStrength__Assignment_Group_Name__c groupName2 = new PropStrength__Assignment_Group_Name__c();
        groupName2.Name = 'Main Queue';
        groupName2.PropStrength__Type__c = 'Service Request';
        groupName2.PropStrength__Active__c = true;
        grpNameList.add(groupName2);
        
        insert grpNameList;

        User user1 = TestDataFactory.createUserSysAdmin('Onet1t2t2','Galvat323322323ron', 'galvatr112121on1@radius.com', 'galvatron1@r45454adius.com');
        User user2 = TestDataFactory.createUserSysAdmin('One2333333','Galvat32323ron2', 'galvatron1212114566@radius.com', 'galvatro45454545n12345@radius.com');

        user1.PropStrength__Assignment_Group_Active__c = true;
        user1.IsActive = true;
        update user1;

        user2.PropStrength__Assignment_Group_Active__c = true;
        user2.IsActive = true;
        update user2;

        PropStrength__Group_Member__c assignmentGroup = new PropStrength__Group_Member__c();
        assignmentGroup.PropStrength__User__c = user1.Id;
        assignmentGroup.Rank__c = 1;
        assignmentGroup.PropStrength__Order__c = 1;
        assignmentGroup.PropStrength__Active__c = 'True';
        assignmentGroup.PropStrength__Last_Assigned__c = true;
        assignmentGroup.Name = 'Test1';
        assignmentGroup.PropStrength__Assignment_Group__c = grpNameList[0].Id;
        
        PropStrength__Group_Member__c assignmentGroup1 = new PropStrength__Group_Member__c();
        assignmentGroup1.PropStrength__User__c = user2.Id;
        assignmentGroup1.Rank__c = 2;
        assignmentGroup1.PropStrength__Order__c = 2;
        assignmentGroup1.PropStrength__Active__c = 'True';
        assignmentGroup1.Name = 'Presales Agent';
        assignmentGroup1.PropStrength__Assignment_Group__c = grpNameList[0].Id;

        PropStrength__Group_Member__c assignmentGroup2 = new PropStrength__Group_Member__c();
        assignmentGroup2.PropStrength__User__c = user1.Id;
        assignmentGroup2.Rank__c = 1;
        assignmentGroup2.PropStrength__Order__c = 1;
        assignmentGroup2.PropStrength__Active__c = 'True';
        assignmentGroup2.Name = 'Test2';
        assignmentGroup2.PropStrength__Last_Assigned__c = true;
        assignmentGroup2.PropStrength__Assignment_Group__c = grpNameList[1].Id;
        
        PropStrength__Group_Member__c assignmentGroup3 = new PropStrength__Group_Member__c();
        assignmentGroup3.PropStrength__User__c = user2.Id;
        assignmentGroup3.Rank__c = 2;
        assignmentGroup3.PropStrength__Order__c = 2;
        assignmentGroup3.PropStrength__Active__c = 'True';
        assignmentGroup3.Name = 'Presales Agent1';
        assignmentGroup3.PropStrength__Assignment_Group__c = grpNameList[1].Id;

        insert new List<PropStrength__Group_Member__c>{assignmentGroup,assignmentGroup1,assignmentGroup2,assignmentGroup3};

        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='test@test.com',
                        
                        EmailEncodingKey='UTF-8', LastName='Email admin', LanguageLocaleKey='en_US',
                        
                        LocaleSidKey='en_US', ProfileId = p.Id,City = 'Meerut',
                        
                        TimeZoneSidKey='America/Los_Angeles', UserName='gggtestmldl@test.com');
        
        insert u;
        
        
        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2345t';
        con.Ownerid = u.id;
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;
        
        Service_Request_SLA__c serviceReq = new Service_Request_SLA__c();
        serviceReq.Priority__c = 1;
        serviceReq.SR_Sub_Category__c = 'Inspection'; 
        serviceReq.Category__c = 'Handover';
        insert serviceReq;
        
        Service_Request_SLA__c serviceReq2 = new Service_Request_SLA__c();
        serviceReq2.Priority__c = 2;
        serviceReq2.SR_Sub_Category__c = 'Oqood Request';
        serviceReq2.Category__c = 'Pre registration'; 
        insert serviceReq2;
        
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = con.FirstName;
        enq2.PropStrength__Last_Name__c =con.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Project__c = pro.id;
        enq2.PropStrength__Origin__c = 'Email';
        enq2.To_Email_Address__c = 'collections@sobharealty.com';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'comment';
        enq2.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;        
        insert enq2;

        PropStrength__Service_Request__c enq3  = new PropStrength__Service_Request__c();
        enq3.PropStrength__Apply_Assignment_Rule__c = true;
        enq3.PropStrength__First_Name__c = con.FirstName;
        enq3.PropStrength__Last_Name__c =con.LastName;
        enq3.PropStrength__Status__c = 'Closed';
        enq3.PropStrength__Project__c = pro.id;
        enq3.PropStrength__Origin__c = 'Email';
        enq3.To_Email_Address__c = 'support@sobharealty.com';
        enq3.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        enq3.SR_Category__c = 'Handover';
        enq3.SR_Sub_Category__c = 'Inspection';
        try{ 
            insert enq3;        
        }catch(Exception ex){}  
        
        PropStrength__Service_Request__c enq4  = new PropStrength__Service_Request__c();
        enq4.PropStrength__Apply_Assignment_Rule__c = true;
        enq4.PropStrength__First_Name__c = con.FirstName;
        enq4.PropStrength__Last_Name__c =con.LastName;
        enq4.PropStrength__Status__c = 'Closed';
        enq4.PropStrength__Project__c = pro.id;
        enq4.PropStrength__Origin__c = 'Email';
        enq4.To_Email_Address__c = 'collections@sobharealty.com';
        enq4.Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        enq4.SR_Category__c = 'Pre registration';
        enq4.SR_Sub_Category__c = 'Oqood Request';
        try{ 
            insert enq4;        
        }catch(Exception ex){}   
        
        
        ServiceRequestTriggerHelper.pushProfileCaseAPI(new Set<Id>{enq3.Id, enq2.Id});
        
        enq2.SR_Category__c = 'Handover';
        enq2.SR_Sub_Category__c = 'Inspection';
        try{ 
            update enq2;        
        }catch(Exception ex){}
        
        Test.stopTest();
    }
    
    @isTest static void runOnceTest(){
        Test.startTest();
        ServiceRequestTriggerHelper.runOnce();
        ServiceRequestTriggerHelper.runOnce();
        Test.stopTest();        
    }
}