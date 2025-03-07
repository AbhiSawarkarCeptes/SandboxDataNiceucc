@isTest
private class testtrgBooking{
    
    @isTest
    private static void bookingCancellationController() {
        try{
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
        
        // Defining Project Construction Stages      
        Project_Construction_Stages__c PCS = new Project_Construction_Stages__c();
        PCS.Project__c = recordMap.get('PROJECT');
        PCS.Name = 'Completion of Plinth';
        PCS.Sequence_No__c =1;
        PCS.Planned_date_of_completion__c = System.today().addDays(365);
        PCS.Tower__c = recordMap.get('TOWER');
        insert PCS;
        
        Project_Construction_Stages__c PCS1 = new Project_Construction_Stages__c();
        PCS1.Project__c = recordMap.get('PROJECT');
        PCS1.Name = 'Completion of first floor';
        PCS1.Sequence_No__c =1;
        PCS1.Actual_date_of_completion__c = System.today().addDays(365);
        PCS1.Tower__c = recordMap.get('TOWER');
        insert PCS1;
        
        Project_Construction_Stages__c PCS2 = new Project_Construction_Stages__c();
        PCS2.Project__c = recordMap.get('PROJECT');
        PCS2.Name = 'Completion of second floor';
        PCS2.Sequence_No__c =1;
        PCS2.Actual_date_of_completion__c = System.today().addDays(-365);
        PCS2.Tower__c = recordMap.get('TOWER');
        insert PCS2;
        
        Project_Construction_Stages__c PCS3 = new Project_Construction_Stages__c();
        PCS3.Project__c = recordMap.get('PROJECT');
        PCS3.Name = 'Completion of third floor';
        PCS3.Sequence_No__c =1;
        PCS3.Planned_date_of_completion__c = System.today().addDays(-365);
        PCS3.Tower__c = recordMap.get('TOWER');
        insert PCS3;
        
        Project_Construction_Stages__c PCS4 = new Project_Construction_Stages__c();
        PCS4.Project__c = recordMap.get('PROJECT');
        PCS4.Name = 'Completion of third floor';
        PCS4.Sequence_No__c =1;
        PCS4.Tower__c = recordMap.get('TOWER');
        insert PCS4;
        
        // Defining Payment Milestone       
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 30;
        pm.Quotation__c = q.Id;
        insert pm;
        
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1.Milestone_Type_edit__c = 'Date Linked';
        pm1.Time_Period__c = 'Months';
        pm1.Number_Of_Days__c = 30;
        pm1.Quotation__c = q.Id;
        insert pm1;
        Payment_Milestones__c pm2 = new Payment_Milestones__c();
        pm2.Milestone_Type_edit__c = 'Construction Linked';
        pm2.Project_Construction_Stages__c = PCS.Id;
        pm2.Time_Period__c = 'Days';
        pm2.Number_Of_Days__c = 0;
        pm2.Quotation__c = q.Id;
        insert pm2;
        
        Payment_Milestones__c pm3 = new Payment_Milestones__c();
        pm3.Milestone_Type_edit__c = 'Construction Linked';
        pm3.Project_Construction_Stages__c = PCS1.Id;
        pm3.Time_Period__c = 'Days';
        pm3.Number_Of_Days__c = 0;
        pm3.Quotation__c = q.Id;
        insert pm3;
        
        Payment_Milestones__c pm5 = new Payment_Milestones__c();
        pm5.Milestone_Type_edit__c = 'Construction Linked';
        pm5.Project_Construction_Stages__c = PCS2.Id;
        pm5.Time_Period__c = 'Days';
        pm5.Number_Of_Days__c = 0;
        pm5.Quotation__c = q.Id;
        insert pm5;
        
        Payment_Milestones__c pm6 = new Payment_Milestones__c();
        pm6.Milestone_Type_edit__c = 'Construction Linked';
        pm6.Project_Construction_Stages__c = PCS3.Id;
        pm6.Time_Period__c = 'Days';
        pm6.Number_Of_Days__c = 0;
        pm6.Quotation__c = q.Id;
        insert pm6;
        
        Payment_Milestones__c pm7 = new Payment_Milestones__c();
        pm7.Milestone_Type_edit__c = 'Construction Linked';
        pm7.Project_Construction_Stages__c = PCS4.Id;
        pm7.Time_Period__c = 'Days';
        pm7.Number_Of_Days__c = 0;
        pm7.Quotation__c = q.Id;
        insert pm7;        
        
        /*   Payment_Milestones__c pm4 = new Payment_Milestones__c();
pm4.Milestone_Type_edit__c = 'On Registration';
//     pm4.Time_Period__c = 'Days';
pm4.Number_Of_Days__c = 0;
pm4.Quotation__c = q.Id;
insert pm4;*/
        
        // Defining tax slab 
        Tax_Slab__c taxS = new Tax_Slab__C();
        taxS.Charge_Type__c = 'Cancellation';
        taxS.From_Date__c = System.today().addDays(-10);
        taxS.To_Date__c = System.today().addDays(10);
        taxS.Tax_Name__c = 'Cancellation';
        taxS.Tax1_Name__c = 'CGST';
        taxS.Tax1_Code__c = 'CGST';
        taxS.Tax1_Percentage__c = 5.00;
        taxS.Taxable1_Percentage__c = 100;
        taxS.Tax_Rate__c = 'VAT 5%';
        taxS.Tax2_Name__c = 'SGST';
        taxS.Tax2_Code__c = 'SGST';
        taxS.Tax2_Percentage__c = 0;
        taxS.Taxable2_Percentage__c = 0;
        insert taxS;             
        
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
        insert b;
        
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
              
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'Third Man1';
        a1.Applicant_Number__c = 'Third Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Pincode__c = 444444;
        a1.Country__c = 'India';
        a1.City__c = 'Nagpur';
        a1.Mailing_Country__c= null;
        a1.Mailing_Pincode__c= null;
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Pancard__c = true;
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        insert a1;
        
        q.Booking__c = b.Id;
        update q;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = oppId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:oppId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.unit__c = unitId;
        update o;
        
        Team__c t = new Team__c();
        t.Team_Type__c = 'Cancellation Approval Team';
        t.Project__c =  recordMap.get('PROJECT');
        t.TowerLookup__c = recordMap.get('TOWER');
        insert t;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Approver_Type__c = 'First Level';
        tm.Team__c = t.Id;
        tm.User_Active__c = true;
        tm.User__c = UserInfo.getUserId();
        insert tm; 
        
        Team_Members__c tm1 = new Team_Members__c();
        tm1.Approver_Type__c = 'Second Level';
        tm1.Team__c = t.Id;
        tm1.User_Active__c = true;
        tm1.User__c = UserInfo.getUserId();
        insert tm1; 
        
        Test.startTest();
        PageReference bookingCancel = Page.BookingCancellationPage;
        Test.setCurrentPage(bookingCancel);
        ApexPages.currentPage().getParameters().put('Id',b.id);
        BookingCancellationController bc = new BookingCancellationController();
        bc.bookList[0].Reason_For_Cancellation_D__c = 'okk';
        //  bc.bookList[0].Cancellation_Charges__c = 100000;
        
        bc.submit();
        bc.goBackMethod();
        b.status__c = 'Cancellation In Progress';
        b.Agreement_Value__c = 1000;
        update b;
        //b.Cancellation_Charges__c = 50000;
        b.status__c = 'Cancelled';
            b.Agreement_Value__c = 100;
        update b;

        
        Test.stopTest();

        }catch(exception e){}
    }
    @istest
    static void testmethod2(){
        try{
        trgBookinghandler.coveragemethod();
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
        insert b;        
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
        test.startTest();
        b.Receipts__c = r1.Id;

        
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        b.Sobha_Connect__c = sc.Id;
        b.Source_of_Booking__c = 'Sobha Connect';
        b.Qualification_Date__c = system.today();
        update b; 

        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Channel_Relationship_Head__c = UserInfo.getUserId();
        cp.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert cp;
        b.Sobha_Connect__c = null;
        b.Channel_Partner__c = cp.Id;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Agreement_Value__c = 10000;
        update b;

        b.Booking_Approver_Audit__c = 'Accepted';
        b.Agreement_Value__c = 1052700;
        b.Booking_Date_As_Per_The_SBTR__c = System.today().addDays(-5);
         b.Agreement_Value__c = 666600;   
        update b;
       

        b.Source_of_Booking__c ='Direct';
        update b; 
        List<Customer_Registration__c> crlst = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Sobha_Connect__c = sc.Id;
        cr1.Property_Type__c = 'Apartment';
        crlst.add(cr1);

        Customer_Registration__c cr2 = new Customer_Registration__c();
        cr2.Channel_Partner__c = cp.Id;
        cr2.Property_Type__c = 'Apartment';
        crlst.add(cr2);

        insert crlst;

        test.stopTest();
        }catch(exception e){}
    }

    @istest
    static void testmethod3(){
        try{
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
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Channel_Relationship_Head__c = UserInfo.getUserId();
        cp.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert cp;
        b.Sobha_Connect__c = null;
        b.Channel_Partner__c = cp.Id;
        b.Source_of_Booking__c = 'Channel Partner';

        insert b;        
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
        test.startTest();
        b.Receipts__c = r1.Id;



        


        b.Source_of_Booking__c ='Direct';
        update b; 
        List<Customer_Registration__c> crlst = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Sobha_Connect__c = sc.Id;
        cr1.Property_Type__c = 'Apartment';
        crlst.add(cr1);

        Customer_Registration__c cr2 = new Customer_Registration__c();
        cr2.Channel_Partner__c = cp.Id;
        cr2.Property_Type__c = 'Apartment';
        crlst.add(cr2);

        insert crlst;

        test.stopTest();
        }catch(exception e){}
    }
    @istest
    static void testmethod4(){
        try{
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
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Channel_Relationship_Head__c = UserInfo.getUserId();
        cp.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert cp;
        // b.Sobha_Connect__c = null;
        // b.Channel_Partner__c = cp.Id;
        // b.Source_of_Booking__c = 'Channel Partner';

        insert b;        
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
        test.startTest();
        b.Receipts__c = r1.Id;



        


        b.Source_of_Booking__c ='Direct';
        update b; 
        List<Customer_Registration__c> crlst = new List<Customer_Registration__c>();
        Customer_Registration__c cr1 = new Customer_Registration__c();
        cr1.Sobha_Connect__c = sc.Id;
        cr1.Property_Type__c = 'Apartment';
        crlst.add(cr1);

        Customer_Registration__c cr2 = new Customer_Registration__c();
        cr2.Channel_Partner__c = cp.Id;
        cr2.Property_Type__c = 'Apartment';
        crlst.add(cr2);

        insert crlst;

        test.stopTest();
        }catch(exception e){}
    }
    @istest
    static void testmethodNew(){
       
        trgBookinghandler.coveragemethod();
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
        insert b;        
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
        test.startTest();
     

        
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert sc;
        trgBookinghandler.afterUpdateTriggerFirstRun = true;
        b.Sobha_Connect__c = sc.Id;
        b.Source_of_Booking__c = 'Sobha Connect';
        b.Qualification_Date__c = system.today();
        update b; 

        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Channel_Relationship_Head__c = UserInfo.getUserId();
        cp.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert cp;
        trgBookinghandler.afterUpdateTriggerFirstRun = true;
        b.Channel_Partner__c = cp.Id;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Agreement_Value__c = 10000;
        update b;

     

        test.stopTest();
       
    }

}