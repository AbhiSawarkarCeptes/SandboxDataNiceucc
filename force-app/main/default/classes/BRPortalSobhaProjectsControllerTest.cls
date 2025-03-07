@isTest
private class BRPortalSobhaProjectsControllerTest {
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
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false);
        insert prop;
        
        Test.startTest();
             List<PropStrength__Property__c> result = BRPortalSobhaProjectsController.getUnits(
          new List<String>{proj.Id},
            new List<String>{'2 BR'} ,
            new List<String>{'500 – 1000 Sq. Ft','1000 – 1500 Sq. Ft'},          // 0 and areas not 0 
            new List<String>{'AED 1 Million – AED 2 Million','AED 2 Million – AED 3 Million'},          // Example price
            new List<String>{'Apartments','Villas','Others'},          // Example propertyType // without other
            new List<String>{},          // Example subProjects
            new List<String>{},          // Example unitTypes
            new List<String>{},          // Example floors
            new List<String>{},          // Example unitNames
            new List<String>{},          // Example variants
            new List<String>{'Above 6000','Above 7000','Above 80000'},          // Example areas
            new List<String>{}  // prices ,
    );// Example prices
        Test.stopTest();
    }
    
    @isTest
    static void testGetUnits() {
         Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Projects__c proj2 = TestDataFactorySobha.createProject(null);
        insert proj2;
        
        Amenity__c amt = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Project_PS__c = proj.Id);
        insert amt;
        Amenity__c amt2 = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Project_PS__c = proj2.Id);
        insert amt2;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;

        Test.startTest();
        List<PropStrength__Property__c> result = BRPortalSobhaProjectsController.getUnits(
            new List<String>{proj.Id}, // Example projectId
            new List<String>{'2 BR'},    // Example config
            new List<String>{'500 – 1000 Sq. Ft','1000 – 1500 Sq. Ft'},          // Example area
            new List<String>{'AED 1 Million – AED 2 Million','AED 2 Million – AED 3 Million'},          // Example price
            new List<String>{'Apartments','Villas','Others'},          // Example propertyType
            new List<String>{proj2.Id},          // Example subProjects
            new List<String>{},          // Example unitTypes
            new List<String>{},          // Example floors
            new List<String>{},          // Example unitNames
            new List<String>{},          // Example variants
            new List<String>{},          // Example areas
            new List<String>{}           // Example prices
        );
        Test.stopTest();

        // Assertions
       // System.assertEquals(1, result.size(), 'Expected one unit in the result');
      //  System.assertEquals('Test Unit', result[0].Name, 'Unexpected unit name');
    }
    
        @isTest
    public static void testMethod2() {
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
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false, PropStrength__Super_Area__c = 1000);
        insert prop;
            
      PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 50));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'DLD Fees', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        
        Quote__c qu = new Quote__c(Property__c = prop.id);
        insert Qu;
        
        
        Test.startTest();
             String result = BRPortalSobhaProjectsController.createQuotation(prop.id, 'name', 'abc@gmail.com');// Example prices
        Test.stopTest();
    }
    
        
        @isTest
    public static void testMethod4() {
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
         PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false, PropStrength__Tower__c =tower.Id, PropStrength__Super_Area__c = 500);
        insert prop;
        
              
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan', Tower__c = tower.id,PropStrength__Tower__c = tower.id);
        insert ppd;
        
            
      PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
              PropStrength__Other_Charges__c poc1 = new PropStrength__Other_Charges__c(Name = 'PLC1', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC1');
         insert poc1;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500, PropStrength__Rate_per_unit_Area__c = 50));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc1.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'DLD Fees', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        
        
        Test.startTest();
             String result = BRPortalSobhaProjectsController.createQuotation(prop.id, 'name', 'abc@gmail.com');// Example prices
        Test.stopTest();
    }

       @isTest
    public static void testMethod3() {
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
         PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false, PropStrength__Tower__c =tower.Id);
        insert prop;
        
      PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
        List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500));
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));
        insert ppc;
        
        List<PropStrength__Income_Charges__c> icList = new List<PropStrength__Income_Charges__c>();
        icList.add(new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property', Display_on_Quotation__c = true));
        icList.add(new PropStrength__Income_Charges__c(Name='DLD Fees',PropStrength__Rate_Per_Unit_Area__c = 0.0, PropStrength__Income_Charge_Code__c = 'DLD Fees', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'DLD Fees', Display_on_Quotation__c = true,Charge__c = 5));
        insert icList;
        
        Test.startTest();
             String result = BRPortalSobhaProjectsController.createQuotation(prop.id, 'name', 'abc@gmail.com');// Example prices
        Test.stopTest();
    }

    @isTest
    static void testGetAllProjects() {
        // Test data setup
        // Create test projects
        Project__c project = new Project__c(
            Name = 'Test Project',
            Project_Code__c ='123'
        );
        insert project;

        Master_Project__c proj = new Master_Project__c(
        Name='test proj',
            Project_Code__c ='1234'
        );
        insert proj;
        // Call the method
        Test.startTest();
        List<Master_Project__c> result = BRPortalSobhaProjectsController.getAllProjects();
        Test.stopTest();

    }
    
    @isTest
    static void testGetSubProjectDetails() {
        // Test data setup
        PropStrength__Projects__c subProj = TestDataFactorySobha.createProject(null);
        insert subProj;

        Amenity__c amt = new Amenity__c(Name ='TestAMT', Type__c='Swimming Pool', Project_PS__c = subProj.Id);
        insert amt;
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = subProj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = subProj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false, PropStrength__Rate_per_unit_area__c = 10, PropStrength__Super_Area__c = 1000);
        insert prop;
        
        // Call the method
        Test.startTest();
        BRPortalSobhaProjectsController.SubProjectDetails result = BRPortalSobhaProjectsController.getSubProjectDetails(subProj.Id);
        Test.stopTest();

        
    }
    
     @isTest
    static void testCreateQuotation() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        // Test data setup
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Tower__c = recordIdMap.get('TOWER')
        );
        insert unit;

        // Call the method
        Test.startTest();
      //  String quotationId = BRPortalSobhaProjectsController.createQuotation(unit.Id,'Aravind', 'aravind@test.com');
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateExportTracker() {
        // Test data setup
        Project__c prj = new Project__c(
            Name = 'TEST Project'
        );

        // Call the method
        Test.startTest();
        Data_Download_Tracker__c  tracker = BRPortalSobhaProjectsController.createExportTracker(prj.Id, UserInfo.getUserId(), 'Filter');
        Test.stopTest();

       
    }

    @isTest
    static void testGetRelatedFiles() {
        // Test data setup
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Brochure form.pdf',
            PathOnClient = 'Brochure form.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = proj.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        conList.add(cdl);

        PropStrength__Projects__c proj1 = TestDataFactorySobha.createProject(null);
        insert proj1;
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Collateral form.pdf',
            PathOnClient = 'Collateral form.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList1 = new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = proj1.id;
        cdl1.ContentDocumentId = documents1[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        // Calling the method
        Test.startTest();
        String fileId = BRPortalSobhaProjectsController.getRelatedFiles('Collateral form.pdf', proj1.Id);
        String fileId1 = BRPortalSobhaProjectsController.getRelatedFiles('Brochure form.pdf', proj.Id);
        String fileId2 = BRPortalSobhaProjectsController.getRelatedFiles('Collateral form.pdf', proj.Id);

        Test.stopTest();
        
    }
    
      @isTest
    public static void testMethod11() {
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
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true, PropStrength__Unit_Status__c = 'Available', For_Direct_Sale__c=false);
        insert prop;
        
        Test.startTest();
             List<PropStrength__Property__c> result = BRPortalSobhaProjectsController.getUnits(
          new List<String>{proj.Id},
            new List<String>{'2 BR'} ,
            new List<String>{'500 – 1000 Sq. Ft','1000 – 1500 Sq. Ft'},          // 0 and areas not 0 
            new List<String>{'AED 1 Million – AED 2 Million','AED 2 Million – AED 3 Million'},          // Example price
            new List<String>{'Apartments'},          // Example propertyType // without other
            new List<String>{},          // Example subProjects
            new List<String>{},          // Example unitTypes
            new List<String>{'1','2'},          // Example floors
            new List<String>{'unit1', 'unit 2'},          // Example unitNames
            new List<String>{'variant1, variant2'},          // Example variants
            new List<String>{'Above 6000','Above 7000','Above 80000'},          // Example areas
            new List<String>{''}  // prices ,
    );// Example prices
        Test.stopTest();
    }

    @isTest
    static void testcreateQuotation1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        List<Quote__c> quoteList = new List<Quote__c>(); 
        PropStrength__Projects__c proStrProj = TestDataFactorySobha.createProject(null);
        insert proStrProj;
        PropStrength__Payment_Plan__c proPStrPayPlan = TestDataFactorySobha.createPaymentPlan(null);   
        proPStrPayPlan.PropStrength__Tower__c = tower.id;
        insert proPStrPayPlan;                  

        //1 !String.isEmpty(unitId) & !quoteList.isEmpty()
        Quote__c q = new Quote__c(Customer_Name__c ='Customer_Name',Customer_Email__c='abc@gmail.com',Property__c = prop.id,Basic_Sale_Price_Original__c = 10000, Basic_Sale_Price_Modified__c = 9000, Discount_Amount__c = 1000, Total_Discount__c = 1000,Quote_for_Multi_Properties__c = true,Payment_Plan__c =proPStrPayPlan.Id,Discount_Type__c = 'Discount');
        BRPortalSobhaProjectsController.createQuotation(prop.id,'name','abc@gmail.com');

        //2 propList[0].PropStrength__Tower__c != null) &  not ppList.isEmpty()
        
 
        PropStrength__Property__c prop1 = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop1;

        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'DLD Fees',Display_on_Quotation__c = true);
        insert inc;

        PropStrength__Income_Charges__c inc1 = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'Transfer Of Property',Display_on_Quotation__c = true,PropStrength__Rate_Per_Unit_Area__c=400);
        insert inc1;

        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
        
         List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop1.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500)); //,PropStrength__Other_Charges_Code_Name__c='otherCharges1'
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop1.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));//PropStrength__Other_Charges_Code_Name__c='otherCharges2'
        insert ppc;
        BRPortalSobhaProjectsController.createQuotation(prop1.id,'name','abc@gmail.com');


        

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan',Tower__c = tower.id,PropStrength__Tower__c = tower.id);
        insert ppd;

        // 3 ppList.isEmpty()
         PropStrength__Property__c prop2 = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop2;
        
       // PropStrength__Payment_Plan__c ppd1 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan13', PropStrength__Active__c = true, Name = 'Test Plan 1');
       // insert ppd1;

        BRPortalSobhaProjectsController.createQuotation(prop2.id,'name','abc@gmail.com');
       
    }

    @isTest
    static void testcreateQuotation2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true,T_link_Demand_Days__c = 1,Grace_Days_Time_Linked__c = 5,Grace_Days__c =5);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        List<Quote__c> quoteList = new List<Quote__c>(); 
        PropStrength__Projects__c proStrProj = TestDataFactorySobha.createProject(null);
        insert proStrProj;
        PropStrength__Payment_Plan__c proPStrPayPlan = TestDataFactorySobha.createPaymentPlan(null);   
        insert proPStrPayPlan;                  

        //1 !String.isEmpty(unitId) & !quoteList.isEmpty()
        Quote__c q = new Quote__c(Customer_Name__c ='Customer_Name',Customer_Email__c='abc@gmail.com',Property__c = prop.id,Basic_Sale_Price_Original__c = 10000, Basic_Sale_Price_Modified__c = 9000, Discount_Amount__c = 1000, Total_Discount__c = 1000,Quote_for_Multi_Properties__c = true,Payment_Plan__c =proPStrPayPlan.Id,Discount_Type__c = 'Discount');
        BRPortalSobhaProjectsController.createQuotation('','name','abc@gmail.com');

        //2 propList[0].PropStrength__Tower__c != null) &  not ppList.isEmpty()
        
 
        PropStrength__Property__c prop1 = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop1;

        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'DLD Fees',Display_on_Quotation__c = true);
        insert inc;

        PropStrength__Income_Charges__c inc1 = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Flexible').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Flexible', PropStrength__Category__c = 'Transfer Of Property',Display_on_Quotation__c = true,PropStrength__Rate_Per_Unit_Area__c=400);
        insert inc1;

        PropStrength__Other_Charges__c poc = new PropStrength__Other_Charges__c(Name = 'PLC', PropStrength__Active__c = true,PropStrength__Project__c = proj.Id, PropStrength__Other_Charge_Code__c = 'PLC');
         insert poc;
        
         List<PropStrength__Property_Charges__c> ppc = new List<PropStrength__Property_Charges__c>();
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop1.Id, PropStrength__Type__c = 'Fixed', PropStrength__Active__c = true, PropStrength__Fixed_Charge__c = 500)); //,PropStrength__Other_Charges_Code_Name__c='otherCharges1'
        ppc.add(new PropStrength__Property_Charges__c(PropStrength__Other_Charges__c = poc.Id, PropStrength__Property__c = prop1.Id, PropStrength__Type__c = 'Flexible', PropStrength__Active__c = true, PropStrength__Rate_per_unit_Area__c = 50));//PropStrength__Other_Charges_Code_Name__c='otherCharges2'
        insert ppc;
        BRPortalSobhaProjectsController.createQuotation(prop1.id,'name','abc@gmail.com');


        

        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan',Tower__c = tower.id);
        insert ppd;

        // 3 ppList.isEmpty()
         PropStrength__Property__c prop2 = new PropStrength__Property__c(Plot_Location_Plan_Uploaded__c =  System.Today(),Master_Plan_Uploaded__c = System.Today(),PropStrength__Tower__c =tower.Id, Annexure_Document_Uploaded__c = System.Today(),Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop2;
        
       // PropStrength__Payment_Plan__c ppd1 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan13', PropStrength__Active__c = true, Name = 'Test Plan 1');
       // insert ppd1;

        BRPortalSobhaProjectsController.createQuotation(prop2.id,'name','abc@gmail.com');
       
    }
}