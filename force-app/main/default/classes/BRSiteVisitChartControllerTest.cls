@isTest
public class BRSiteVisitChartControllerTest {
    @isTest
    static void testSiteVisits() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        //UserRole communityUserRole = [SELECT Id FROM UserRole WHERE Name = 'Customer Community Login' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true,
            UserName = 'testuser123455@example.com',
            ContactId = con.Id
            
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        Integer bookCount = BRSiteVisitChartController.getBookingAppartmentsCount();
        Integer bookVillaCount = BRSiteVisitChartController.getBookingVillasCount();
        BRSiteVisitChartController.getBookingData();
        BRSiteVisitChartController.getSitevisits1(new List<Integer>{2024}, new List<Integer>{6});
        BRSiteVisitChartController.getSitevisits(2024, 6);
        BRSiteVisitChartController.getSalesBookings(new List<Integer>{2024}, new List<Integer>{6});
        BRSiteVisitChartController.getBookingDataQuaterly(2024);
        BRSiteVisitChartController.getBookingDataHalfYearly(2024);
        BRSiteVisitChartController.getBookingDataYearly(2024);
        BRSiteVisitChartController.getSitevisitsQuaterly(2024);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Villas'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(null, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Apartment'}, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Villas'}, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(null, 'quarter', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        Test.StopTest();
        
        System.runAs(testUser) {
            BRSiteVisitChartController.getSitevisitsHalfYearly(2024);
            BRSiteVisitChartController.getSitevisitsYearly(2024);
            List<Events__c> eventList = BRSiteVisitChartController.getUpcomingAllEvents();
            BRSiteVisitChartController.getUpcomingEvents('Videoshoot');
            BRSiteVisitChartController.getSitevisitsCountInCurrentMonth();
            BRSiteVisitChartController.getSitevisitsCountLastThreeMonths();
            BRSiteVisitChartController.getSitevisitsCountLastSixMonths();
            BRSiteVisitChartController.getSitevisitsCountInCurrentYear();
            BRSiteVisitChartController.getBookingMonthlyData(6,7);
            BRSiteVisitChartController.getBookingMonthlyData(6,7);
            BRSiteVisitChartController.getSitevisitsMonthlyData(1,7);
        }
        BRSiteVisitChartController.getBookingFormSPAUrl(appBook.Id);
       // BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        //  BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        //  BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Apartment'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        
    }
    
    @isTest
    static void testSiteVisits2() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        //UserRole communityUserRole = [SELECT Id FROM UserRole WHERE Name = 'Customer Community Login' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con.Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        Integer bookCount = BRSiteVisitChartController.getBookingAppartmentsCount();
        Integer bookVillaCount = BRSiteVisitChartController.getBookingVillasCount();
        BRSiteVisitChartController.getBookingData();
        BRSiteVisitChartController.getSitevisits1(new List<Integer>{2024}, new List<Integer>{6});
        BRSiteVisitChartController.getSitevisits(2024, 6);
        BRSiteVisitChartController.getSalesBookings(new List<Integer>{2024}, new List<Integer>{6});
        BRSiteVisitChartController.getBookingDataQuaterly(2024);
        BRSiteVisitChartController.getBookingDataHalfYearly(2024);
        BRSiteVisitChartController.getBookingDataYearly(2024);
        BRSiteVisitChartController.getSitevisitsQuaterly(2024);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Villas'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(null, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Apartment'}, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Villas'}, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(null, 'year', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Apartment'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>{1,2,3}, new List<String>{'Villas','Others', 'Apartment'});
        Test.StopTest();
        
        System.runAs(testUser) {
            BRSiteVisitChartController.getSitevisitsHalfYearly(2024);
            BRSiteVisitChartController.getSitevisitsYearly(2024);
            List<Events__c> eventList = BRSiteVisitChartController.getUpcomingAllEvents();
            BRSiteVisitChartController.getUpcomingEvents('Open Houses');
            BRSiteVisitChartController.getUpcomingEvents('Road Shows');
            
            BRSiteVisitChartController.getUpcomingEvents('Business Trip');
            BRSiteVisitChartController.getUpcomingEvents('All');
            
            BRSiteVisitChartController.getSitevisitsCountInCurrentMonth();
            BRSiteVisitChartController.getSitevisitsCountLastThreeMonths();
            BRSiteVisitChartController.getSitevisitsCountLastSixMonths();
            BRSiteVisitChartController.getSitevisitsCountInCurrentYear();
            BRSiteVisitChartController.getBookingMonthlyData(6,7);
            // BRSiteVisitChartController.getBookingMonthlyData(6,7);
            // BRSiteVisitChartController.getSitevisitsMonthlyData(1,7);
        }
        /*  BRSiteVisitChartController.getBookingFormSPAUrl(appBook.Id);
BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
*/
        
    }
    
    @isTest
    static void testSiteVisit() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.AccountId = acc1.Id;
        cont.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Customer'].Id;
        insert cont;
        
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        con.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@exampleqweqwe.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@exampleqweqew.com',
            ContactId = con.Id
            // AccountId = acc.Id,
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        System.runAs(testUser) {
            Customer_Registration__c cr1 = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
            cr1.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
            cr1.First_Name__c = 'Test First Name';
            cr1.Last_Name__c = 'Test Last Name';
            cr1.Broker_Contact__c = con.Id;
            cr1.Property_Type__c = 'Apartment';
            insert cr1;
            Test.setCreatedDate(cr1.Id, DateTime.newInstance(2024, 02, 02));
            
            BRSiteVisitChartController.getSitevisitsCountInCurrentMonth();
            BRSiteVisitChartController.getSitevisitsCountLastThreeMonths();
            BRSiteVisitChartController.getSitevisitsCountLastSixMonths();
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>{1,2,3}, new List<String>{'Villas','Others'});
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>{1,2,3}, new List<String>());
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>(), new List<String>{'Villas','Others', 'Apartment'});
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>(), new List<String>{'Villas','Apartment'});
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>(), new List<String>{'Others'});
            BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>(), new List<String>{'Villas','Others'});
        
            BRSiteVisitChartController.getBookingsTotalInCurrentMonth();
            BRSiteVisitChartController.getBookingsTotalInLastThreeMonths();
            BRSiteVisitChartController.getBookingsTotalInLastSixMonths();
            BRSiteVisitChartController.getBookingsTotalInCurrentYear();
            BRSiteVisitChartController.getBookingDataDetails();
            BRSiteVisitChartController.getBookingFormUrl(cr1.Id, '');
                   // BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);

            //BRSiteVisitChartController.getBookingFormSPAUrl(cr1.Id);
            //BRSiteVisitChartController.getBookingCount();
        }
    }
    
    @isTest
    public static void testfetchEmailTemplateInfo() {
        Test.startTest();
        BRSiteVisitChartController.TemplateInfo temp = BRSiteVisitChartController.fetchEmailTemplateInfo('Notification_To_Audit_Team_Queue');
        Test.stopTest();
    }
    
    @isTest
    static void testSiteVisits3() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con2.Id
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        proj.Hide_From_3rd_Party__c = false;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appbook.PropStrength__Booking_Date__c = system.today();
        appbook.PropStrength__Project__c = proj.id;
        appbook.PropStrength__Broker_Contact__c = con2.id;
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        Integer bookCount = BRSiteVisitChartController.getBookingAppartmentsCount();
        Integer bookVillaCount = BRSiteVisitChartController.getBookingVillasCount();
        BRSiteVisitChartController.getBookingData();
        BRSiteVisitChartController.getSitevisits1(new List<Integer>{Date.today().year()}, new List<Integer>{Date.today().month()});
        BRSiteVisitChartController.getUpcomingAllEvents();
        BRSiteVisitChartController.getSitevisitsCountInCurrentMonth();
        BRSiteVisitChartController.getSitevisitsCountInCurrentYear();
        BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>{1,2,3}, new List<String>{'Villas','Apartment'});
        BRSiteVisitChartController.getBookingsInSelectedMonth(new List<integer>{2024}, new List<integer>{1,2,3}, new List<String>{'Others'});
        BRSiteVisitChartController.getBookingsTotalInCurrentMonth();
        BRSiteVisitChartController.getBookingsTotalInCurrentYear();
        //getSitevisitsCountLastThreeMonths
        //getSitevisitsCountLastSixMonths
        //getBookingsTotalInLastThreeMonths
        //getBookingsTotalInLastSixMonths
        Test.StopTest();
        System.runAs(testUser) {
            //getBookingFormUrl
            BRSiteVisitChartController.getSitevisits1(new List<Integer>{Date.today().year()}, new List<Integer>{Date.today().month()});
            BRSiteVisitChartController.getSalesBookings(new List<Integer>{Date.today().year()}, new List<Integer>{Date.today().month()});
        }
        
        
    }
    @isTest
    static void testSiteVisits123() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con.Id
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        
        
        // BRSiteVisitChartController.getBookingFormSPAUrl(appBook.Id);
        //BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Others', 'Apartment'}, 'month', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        
    }  
    
    @isTest
    static void testSiteVisits4() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con.Id
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        
        
        System.runAs(testUser) {
            
            BRSiteVisitChartController.getSitevisitsMonthlyData(1,7);
        }
        BRSiteVisitChartController.getBookingFormSPAUrl(appBook.Id);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment', 'Others'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        BRSiteVisitChartController.getBookingCount(new List<String>{'Villas', 'Apartment'}, 'biyear', new List<integer>{1,5}, new List<integer>{1,2,3}, 3);
        
        
    }
    
    @isTest
    static void testgetBookingFormUrl() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con.Id
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        PropStrength__Transaction_Requests__c tr = new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'SPA Executed', RecordTypeId=Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId(), PropStrength__Application_Booking__c = appBook.Id, PropStrength__Refund_Type__c ='Termination Refund',
                                                                                             
                                                                                             Termination_Refund_Status__c ='');
        trList.add(tr);
        insert trList;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        
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
        cdl.LinkedEntityId = appBook.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        conList.add(cdl);
        
        Insert conList;
        
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'SPA%.pdf',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList1= new list<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl1= New ContentDocumentLink();
        cdl1.LinkedEntityId = tr.id;
        cdl1.ContentDocumentId = documents1[0].Id;
        cdl1.shareType = 'V';
        //insert cdl;
        conList1.add(cdl1);
        
        Insert conList1;
        
        BRSiteVisitChartController.getBookingFormUrl(appBook.id, 'title');
        BRSiteVisitChartController.getBookingFormSPAUrl(appBook.id);
    }
    
    
    @isTest
    static void testSiteVisits5() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con2.Id
            
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        proj.Hide_From_3rd_Party__c = false;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appbook.PropStrength__Booking_Date__c = system.today();
        appbook.PropStrength__Project__c = proj.id;
        appbook.PropStrength__Broker_Contact__c = con2.id;
        appbook.PropStrength__Booking_Through__c ='Broker';
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        List<Customer_Registration__c> siteVisits = BRSiteVisitChartController.SiteVisits();
        System.assertNotEquals(null, siteVisits, 'Site visits should not be null');
        Integer bookCount = BRSiteVisitChartController.getBookingAppartmentsCount();
        Integer bookVillaCount = BRSiteVisitChartController.getBookingVillasCount();
        BRSiteVisitChartController.getBookingData();
        BRSiteVisitChartController.getSitevisits1(new List<Integer>{Date.today().year()}, new List<Integer>{Date.today().month()});
        BRSiteVisitChartController.getUpcomingAllEvents();
        BRSiteVisitChartController.getSitevisitsCountInCurrentMonth();
        BRSiteVisitChartController.getSitevisitsCountInCurrentYear();
        BRSiteVisitChartController.getBookingsTotalInCurrentMonth();
        BRSiteVisitChartController.getBookingsTotalInCurrentYear();
        //getSitevisitsCountLastThreeMonths
        //getSitevisitsCountLastSixMonths
        //getBookingsTotalInLastThreeMonths
        //getBookingsTotalInLastSixMonths
        Test.StopTest();
        System.runAs(testUser) {
            //getBookingFormUrl
            BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Apartment','Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Apartment'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(new List<String>{'Apartment','Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            // BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            //  BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(null, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            
                  }
        
    }
    
    @isTest
    static void testSiteVisits6() {
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.PropStrength__Broker_Type__c = 'Standard';
        acc1.Broker_Sub_Type__c = 'Broker International';
        insert acc1;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Broker'].Id;
        insert acc;
        Contact con = TestDataFactorySobha.createContact(null);
        insert con;
        Contact con2 = TestDataFactorySobha.createContact(null);
        con2.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Broker'].Id;
        insert con2;
        User testUser = new User(
            Alias = 'tuser1',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName='Testing11',
            LanguageLocaleKey='en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE name =: 'Customer Community Login' Or name =: 'Customer Community Login User Clone' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive=true,
            UserName = 'testuser123455@example.com',
            ContactId = con2.Id
            //UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1].Id
        );
        insert testUser;
        
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Registration__c cr = new Customer_Registration__c();//TestDataFactorySobha.createCustomerRegistration(null);
        cr.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Customer_Registration__c' AND Name = 'Site Visit'].Id;
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Broker_Contact__c = con2.Id;
        cr.Property_Type__c = 'Apartment';
        insert cr;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c();
        proj.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        proj.PropStrength__Active__c = true;
        proj.T_link_Demand_Days__c = 1;
        proj.Grace_Days_Time_Linked__c = 5;
        proj.Grace_Days__c = 5;
        proj.Hide_From_3rd_Party__c = false;
        insert proj;
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        propTypeRec.PropStrength__Project__c = proj.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        insert propTypeRec;
        
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        appbook.PropStrength__Booking_Date__c = system.today();
        appbook.PropStrength__Project__c = proj.id;
        appbook.PropStrength__Broker_Contact__c = con2.id;
        appbook.PropStrength__Booking_Through__c ='Broker';
        insert appBook;
        
        
        List<Events__c> evntlst = new List<Events__c>();
        Events__c evnt = new Events__c();
        evnt.Sales_Manager__c = testUser.id;
        evnt.Name = 'Video Shoot';
        evnt.Date_Of_Event__c = System.today().addDays(15);
        evnt.Stay_Start_Date__c = System.today().addDays(16);
        Id devRecordTypeId1 = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        evnt.RecordTypeId = devRecordTypeId1;
        evnt.Broker_Account__c = acc1.id;
        evntlst.add(evnt);
        insert evntlst;
        
        
        Test.StopTest();
        System.runAs(testUser) {
            
            BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Apartment','Others'}, 'quarter',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Apartment'}, 'quarter',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(new List<String>{'Apartment','Others'}, 'quarter',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            // BRSiteVisitChartController.getBookingCount(new List<String>{'Villas','Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            //  BRSiteVisitChartController.getBookingCount(new List<String>{'Others'}, 'month',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            BRSiteVisitChartController.getBookingCount(null, 'quarter',new List<Integer>{Date.today().year()},new List<Integer>{Date.today().month()},Date.today().year());
            
            // BRSiteVisitChartController.getSalesBookings(new List<Integer>{Date.today().year()}, new List<Integer>{Date.today().month()});
        }
        
    }
}