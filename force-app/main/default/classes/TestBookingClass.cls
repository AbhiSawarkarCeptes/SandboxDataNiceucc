@isTest
private  Class TestBookingClass {
    
    @isTest
    private static void BookingTest() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        Car_Park__c objCP1;
        Car_Park__c objCP2;
        
        objpr = new Project__c();
        objpr = createProject('Xa_prj','111');
        List<Cluster__c> cList = TestDataFactory.createClusters(2, objpr.Id);       
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        
        ProjectCharges__c projchrg1 = new ProjectCharges__c();
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = objpr.id;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Agreement Value';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1; 
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;                               
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];        
        
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];       
        
        objCP1 = new Car_Park__c ();
        objCP1.Status__c = 'Available';
        objCP1.Category__c = 'Additional';
        objCP1.Type__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Park__c ();
        objCP2.Status__c = 'Available';
        objCP2.Category__c = 'Additional';
        objCP2.Type__c = 'Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;                       
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        /////////////// Added by Neha on 21/1/19 Starts Here  
        String p = 'System Administrator';
        Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
        
        User u = [SELECT Id FROM User LIMIT 1];
        
        User u1 = new User();
        u1.LastName = 'Test123';
        u1.Email = 'test123@gmail.com';
        u1.Username = 'test12345610223@stetig.in';
        u1.Alias = 'tes1';
        u1.CommunityNickname = 'Test1209';                            
        u1.MobilePhone = '1234567894';
        u1.ProfileId = pro.Id;
        u1.Phone = '1234567894';              
        u1.IsActive = true; 
        u1.TimeZoneSidKey = 'Asia/Kolkata';   
        u1.LocaleSidKey = 'en_IN';      
        u1.LanguageLocaleKey = 'en_US'; 
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ManagerId = u.Id;        
        insert u1;          
        
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name = 'CP1';
        cp.Contact_Person__c = 'Test1';
        cp.Sales_Manager__c = u1.Id;
        cp.Sales_Manager_s_Line_Manager__c = u1.Id;
        cp.Channel_Relationship_Head__c = u1.Id; 
        cp.Channel_Relationship_Manager__c = u1.Id;
        cp.Alternate_Mobile__c = '9999998990';
        cp.Email_ID_1__c = 'test.a@g.com';
        cp.Email_ID_2__c = 'test.a@g.com';
        cp.Mobile_No__c = '9999998990';
        cp.Office_No__c = '9999998990';
        cp.Phone__c = '9999998990';
        insert cp;
        
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Name__c = 'Sobha Connect';
        sc.Mobile_No__c = '1741854512';
        sc.Contact_Person__c = 'Test1 Test2'; 
        insert sc;  
        /////////////// Added by Neha on 21/1/19 Ends Here        
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Walk_in_Source__c = 'Channel Partner'; // Added by Neha on 21/1/19
        objcustomer.Walk_In_CP__c = cp.Id; // Added by Neha on 21/1/19
        objcustomer.Channel_Partner_Contact_Person__c = 'Test New'; // Added by Neha on 21/1/19
        objCustomer.Sales_Manager_lookup__c = Userinfo.getUserId();
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        objcustomer1.Walk_in_Source__c = 'Sobha Connect';
        insert objcustomer1;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;       
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;  
        q.Final_Approved_Date__c = System.today().addDays(5);  // Added by Neha on 25/2/19     
        q.Quote_Status__c = 'Valid';  // Added by Neha on 25/2/19
        q.Allow_booking_without_full_token__c = TRUE;
        q.Total_Agreement_Value_Bucket__c = 60422880;
        q.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
        q.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
        q.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
        q.Car_Park_Type_1__c = 'Tandem';
        q.Car_Park_Type_2__c = 'Open';
        q.Car_Park_Type_3__c = 'Stack';
        q.Car_Park_Count_1__c = 1;
        q.Car_Park_Count_2__c = 1;
        q.Car_Park_Count_3__c = 1;
        insert q;      
        EmailOptOutBooking__c cs = new EmailOptOutBooking__c();
        cs.Name='Send Email On Booking Creation';
        cs.Send_Welcome_Email__c = true;
		insert cs;
        ///// Added by Neha on 26/7/19 Starts here        
        PageReference pRef2 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',null);
        ApexPages.currentPage().getParameters().put('projectId',null);
        BookingClassDubai bokC = new BookingClassDubai();  
        
        PageReference pRef3 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef3);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId', objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',null);
        BookingClassDubai bokC1 = new BookingClassDubai();   
        
        PageReference pRef4 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef4);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId', null);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClassDubai bokC2 = new BookingClassDubai();         
        ///// Added by Neha on 26/7/19 Ends here  
        
        PageReference pRef1 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClassDubai bookC1 = new BookingClassDubai();
        bookC1.i = 0;
        List <SelectOption> sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.getTokenAmount();
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'UAE';
        bookC1.applicant.Mobile_Number__c = '909090900';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident';        
        bookC1.addressCheck = true; 
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Name = 'Second Man';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mobile_Number__c = '909090900';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'UAE Resident';       
        bookC1.addressCheckApplicant2 = true;
        bookC1.save();
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Name = 'Third Man';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';        
        bookC1.applicant3.Country__c = 'India';        
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'UAE Resident';        
        bookC1.addressCheckApplicant3 = false;
        bookC1.save();
        
        bookC1.applicant4.Name ='Fourth Man';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.Country__c = 'India';      
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Non-UAE Resident';
        bookC1.applicant4.Mobile_Number__C = '1245784512';
        bookC1.applicant4.Email_Address__c = 'fourapp@stetig.in';
        bookC1.addressCheckApplicant4 = false;
        bookC1.save();
        
        bookC1.applicant5.Name ='Fifth Man';
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';       
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.Nationality__c = 'Indian';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Non-UAE Resident';  
        bookC1.applicant5.Mobile_Number__C = '1245784513';
        bookC1.applicant5.Email_Address__c = 'fiveapp@stetig.in';      
        bookC1.addressCheckApplicant5 = false;
        bookC1.save();
        
        Test.startTest();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fourth Man';
        bookC1.save();
        Test.stopTest();       
    }
    
    @isTest
    private static void BookingTest2222() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        Car_Park__c objCP1;
        
        objpr = new Project__c();
        objpr = createProject('Xa_prj2','1111');
        List<Cluster__c> cList = TestDataFactory.createClusters(2, objpr.Id);       
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);     
        
        ProjectCharges__c projchrg1 = new ProjectCharges__c();
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = objpr.id;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Agreement Value';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1; 
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;       
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];
        
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];
        
        objCP1 = new Car_Park__c ();
        objCP1.Status__c = 'Available';
        objCP1.Category__c = 'Additional';
        objCP1.Type__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;       
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        EmailOptOutBooking__c cs = new EmailOptOutBooking__c();
        cs.Name='Send Email On Booking Creation';
        cs.Send_Welcome_Email__c = true;
		insert cs;
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        insert objcustomer1;
        
        Opportunity objcustomer11 = new Opportunity();
        objcustomer11.Project__c=objpr.id;
        objcustomer11.name='Test 11';
        objcustomer11.StageName='Qualification';
        objcustomer11.Unit__c=objPUU1.id;  
        objcustomer11.CloseDate=system.today();
        objcustomer11.Status__c ='Active';
        objcustomer11.AccountId = a.Id;
        insert objcustomer11;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Final_Approved_Date__c = System.today().addDays(5);  // Added by Neha on 25/2/19     
        q.Quote_Status__c = 'Valid';  // Added by Neha on 25/2/19
        q.Allow_booking_without_full_token__c = TRUE;
        q.Total_Agreement_Value_Bucket__c = 60422880;
        q.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
        q.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
        q.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
        q.Car_Park_Type_1__c = '';
        q.Car_Park_Type_2__c = '';
        q.Car_Park_Type_3__c = '';
        q.Car_Park_Count_1__c = 0;
        q.Car_Park_Count_2__c = 0;
        q.Car_Park_Count_3__c = 0;
        insert q;
        
        Booking__c bks = new Booking__C();
        bks.Opportunity__c = objcustomer11.Id;
        bks.Quotation__c = q.Id;
        bks.Booking_Date__c = System.Today();
        bks.Agreement_Value__c = 3000000;
        insert bks;
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = bks.Id;
        a1.Applicant_Number__c = 'Secondary Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        insert a1;
        Project_Construction_Stages__c pgs = new Project_Construction_Stages__c();
        pgs.Planned_date_of_completion__c = System.today().addDays(30);
        pgs.Project__c = objpr.id;
        pgs.Tower__c = tList[0].id;
        pgs.Name = 'On Plinth';
        insert pgs;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Milestone_Name__c = 'Application Money1';
        pm.Number_Of_Days__c = 0;
        pm.Milestone_Due_Date__c = System.Today().addDays(10);
        pm.Quotation__c = q.Id;
        insert pm;
        
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1.Milestone_Type_edit__c = 'Construction Linked';
        pm1.Milestone_Name__c = 'On Plinth';
        pm1.Project_Construction_Stages__c = pgs.Id;
        pm1.Number_Of_Days__c = 0;
        pm1.Milestone_Due_Date__c = System.Today().addDays(10);
        pm1.Quotation__c = q.Id;
        insert pm1;
        
        Test.startTest();
        PageReference pRef1 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClassDubai bookC1 = new BookingClassDubai();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.getTokenAmount();
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        bookC1.boookingObj.Mode_of_Funding__c = 'Self';
        bookC1.dateOfOfferPossesion = system.today().addDays(2);
        bookC1.receiptlist[0].Mode__c = 'Cheque';
        bookC1.receiptlist[0].Cheque_DD__c = '908888';
        bookC1.receiptlist[0].Cheque_DD_Date__c = system.today();
        bookC1.receiptlist[0].Total_Amount__c = 1000000;
        bookC1.receiptlist[0].Currency__c = 'Indian Rupee';
        bookC1.receiptlist[0].DraweeBank__c = 'Akola Urban Co-operative Bank';
        
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.City__c = 'Nagpur'; 
        bookC1.applicant.Mailing_Country__c= 'UAE';
        bookC1.applicant.Mobile_Number__c = '909090901';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.applicant.Passport_Copy__c = true;  // Changed by Neha on 21/1/19
        bookC1.applicant.Emirates_ID__c = true;  // Changed by Neha on 21/1/19
        bookC1.applicant.Passport_Copy_Details__c = 'abc';  // Changed by Neha on 21/1/19
        bookC1.applicant.Emirates_ID_Details__c = 'pqr';  // Changed by Neha on 21/1/19
        bookC1.addressCheck = true; 
        bookC1.firstApplicantDOB = system.today().addDays(-2);
        bookC1.applicant.Preferred_address_for_all_correspondence__c = 'Permanent';
        bookC1.getaddressstatus();
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Name = 'Second Man1';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mobile_Number__c = '909090902';
        bookC1.applicant2.Email_Address__c = 'newman@justnow2.com';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Non-UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Passport_Copy__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant2.National_ID__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant2.Passport_Copy_Details__c = 'xyz'; // Changed by Neha on 21/1/19
        bookC1.applicant2.National_ID_Details__c = 'pqr'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Valid_Until_Passport__c = System.today().addDays(5); // Changed by Neha on 21/1/19
        bookC1.applicant2.Valid_Upto_National_ID__c = System.today().addDays(10); // Changed by Neha on 21/1/19 
        bookC1.addressCheckApplicant2 = true;
        bookC1.getaddressstatus();
        bookC1.save();
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Name = 'Third Man2';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Corporate Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant3.Subtype_Of_Applicant__c = Constants.COMPANIES_INCORPORATED_IN_FREE_ZONE; // Changed by Neha on 21/1/19
        bookC1.applicant3.Certificate_of_Incorporation__c = false; // Changed by Neha on 21/1/19
        bookC1.applicant3.Certificate_of_Good_Standing_and_Certifi__c = false; // Changed by Neha on 21/1/19
        bookC1.applicant3.Passport_Copy_of_Authorized_Signatory__c  = false; // Changed by Neha on 21/1/19
        bookC1.applicant3.Memoradum_Articles_of_Association__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant3.PancardNo__c = '123456789102'; // Changed by Neha on 21/1/19
        bookC1.addressCheckApplicant3 = false;
       
        bookC1.applicant4.Name ='Fourth Man2';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Corporate Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Companies incorporated in the UAE'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Registration_License__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant4.Passport_Copy_of_Authorized_Signatory__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant4.Registration_License_Details__c = '1234567891'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Passport_Copy_of_Authorized_Signatory_De__c = 'test'; // Changed by Neha on 21/1/19
        bookC1.addressCheckApplicant4 = false;
        
        bookC1.applicant5.Name ='Fifth Man2';
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.Nationality__c = 'Indian';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Non-UAE Resident';        
        bookC1.addressCheckApplicant5 = false;        
        
        
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fourth Man';
        Test.stopTest();       
    }
    
    @isTest
    private static void BookingTest3333() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Unit__c objPUU;
        Unit__c objPUU1;
        Car_Park__c objCP1;
        
        Project__c objpr = new Project__c(Name = 'Xa_prj2', Project_Code__c = '2222');
        insert objpr;       
        
        //create Towers
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        
        EmailOptOutBooking__c cs = new EmailOptOutBooking__c();
        cs.Name='Send Email On Booking Creation';
        cs.Send_Welcome_Email__c = true;
		insert cs;
        
        ProjectCharges__c projchrg1 = new ProjectCharges__c();
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = objpr.id;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Agreement Value';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1; 
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];        
        
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];       
        
        objCP1 = new Car_Park__c ();
        objCP1.Status__c = 'Available';
        objCP1.Category__c = 'Additional';
        objCP1.Type__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        ///  objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        ///   objcustomer1.Duplicate_Project_Unit_Request__c = false;
        ///    objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;
        q.Token_Amount__c =110000;
        q.Final_Approved_Date__c = System.today().addDays(5);  // Added by Neha on 25/2/19     
        q.Quote_Status__c = 'Valid';  // Added by Neha on 25/2/19
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Total_Agreement_Value_Bucket__c = 60422880;
        q.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
        q.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
        q.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
        q.Car_Park_Type_1__c = '';
        q.Car_Park_Type_2__c = '';
        q.Car_Park_Type_3__c = '';
        q.Car_Park_Count_1__c = 0;
        q.Car_Park_Count_2__c = 0;
        q.Car_Park_Count_3__c = 0;
        insert q;
        
        PageReference pRef1 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClassDubai bookC1 = new BookingClassDubai();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.getTokenAmount();
        //   bookC1.getReceiptDetails();
        bookC1.boookingObj.Application_No__c = '';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = '';
        bookC1.boookingObj.Mode_of_Funding__c = 'Self';
        bookC1.dateOfOfferPossesion = system.today().addDays(2);
        bookC1.receiptlist[0].DraweeBank__c ='Other';
        bookC1.save();
        bookC1.receiptlist[0].Mode__c = 'Cheque';
        bookC1.receiptlist[0].Cheque_DD__c = '908888';
        bookC1.receiptlist[0].Cheque_DD_Date__c = system.today();
        bookC1.receiptlist[0].Total_Amount__c = 1000000;
        bookC1.receiptlist[0].Currency__c = 'Indian Rupee';
        bookC1.receiptlist[0].DraweeBank__c = 'Akola Urban Co-operative Bank';
        bookC1.addressCheck = False;
        bookC1.save();
        bookC1.applicant.Mailing_Country__c = 'UAE';
        bookC1.save();
        bookC1.boookingObj.Application_No__c = '';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.save();
        bookC1.boookingObj.Application_No__c = '';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.save();
        bookC1.boookingObj.Application_No__c = '';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.save();
        bookC1.boookingObj.Application_No__c = '';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.save();       
        
        bookC1.applicant.Subtype_Of_Applicant__c = 'Non-UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = Constants.COMPANIES_INCORPORATED_IN_FREE_ZONE; // Changed by Neha on 21/1/19
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Companies incorporated in the UAE'; // Changed by Neha on 21/1/19
        bookC1.save();              
        
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man1';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'UAE';
        bookC1.applicant.Mobile_Number__c = '909090901';
        bookC1.applicant.Email_Address__c = 'newman@justnow1.com';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.applicant.Passport_Copy__c = true;  // Changed by Neha on 21/1/19
        bookC1.applicant.Emirates_ID__c = true;  // Changed by Neha on 21/1/19
        bookC1.applicant.Passport_Copy_Details__c = 'abc';  // Changed by Neha on 21/1/19
        bookC1.applicant.Emirates_ID_Details__c = 'pqr';  // Changed by Neha on 21/1/19
        bookC1.addressCheck = true; 
        bookC1.firstApplicantDOB = system.today().addDays(-2);
        bookC1.applicant.Preferred_address_for_all_correspondence__c = 'Permanent';
        bookC1.getaddressstatus(); 
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Name = 'Second Man1';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mobile_Number__c = '909090902';
        bookC1.applicant2.Email_Address__c = 'newman@justnow2.com';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Subtype_Of_Applicant__c = 'UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Passport_Copy__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant2.Emirates_ID__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant2.Passport_Copy_Details__c = 'xyz'; // Changed by Neha on 21/1/19
        bookC1.applicant2.Emirates_ID_Details__c = 'pqr'; // Changed by Neha on 21/1/19
        bookC1.addressCheckApplicant2 = true;
        bookC1.getaddressstatus();
        
        // bookC1.applicant3.Name = 'Third Man1';
        bookC1.applicant4.Name = 'Fourth Man1';
        bookC1.applicant5.Name = 'Fifth Man1';
        bookC1.addressCheckApplicant3 = true;
        bookC1.getaddressstatus();
        bookC1.addressCheckApplicant4 = true;
        bookC1.getaddressstatus();
        bookC1.addressCheckApplicant5 = true;
        bookC1.getaddressstatus();
        
        bookC1.applicant3.Name = 'Six Man1';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.City__c = 'Nagpur';
        bookC1.applicant3.Mailing_Country__c= null;
        bookC1.applicant3.Mobile_Number__c = '909090903';
        bookC1.applicant3.Email_Address__c = 'newman@justnow3.com';
        bookC1.applicant3.Nationality__c = 'Indian';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant3.Subtype_Of_Applicant__c = 'UAE Resident'; // Changed by Neha on 21/1/19
        bookC1.applicant3.Passport_Copy__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant3.Emirates_ID__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant3.Passport_Copy_Details__c = 'xyz'; // Changed by Neha on 21/1/19
        bookC1.applicant3.Emirates_ID_Details__c = 'pqr'; // Changed by Neha on 21/1/19
        bookC1.addressCheckApplicant3 = true;
        bookC1.getaddressstatus();
        bookC1.save();        
    }   
    
    @isTest
    private static void BookingTest4444() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        //Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        //       Project_Unit_Type__c objPUT;
        Car_Park__c objCP1;
        Car_Park__c objCP2;
        Car_Park__c objCP3;
        Car_Park__c objCP4;
        Car_Park__c objCP5;
        
        Project__c objpr = new Project__c(Name = 'Xa_prj2', Project_Code__c = '2222');
        insert objpr;
        
        EmailOptOutBooking__c cs = new EmailOptOutBooking__c();
        cs.Name='Send Email On Booking Creation';
        cs.Send_Welcome_Email__c = true;
		insert cs;
        
        //create Towers
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        
        ProjectCharges__c projchrg1 = new ProjectCharges__c();
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = objpr.id;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Agreement Value';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1; 
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];
               
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];
               
        objCP1 = new Car_Park__c ();
        objCP1.Status__c = 'Available';
        objCP1.Category__c = 'Additional';
        objCP1.Type__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Park__c ();
        objCP2.Status__c = 'Available';
        objCP2.Category__c = 'Additional';
        objCP2.Type__c = 'Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;      
        
        objCP4 = new Car_Park__c ();
        objCP4.Status__c = 'Available';
        objCP4.Category__c = 'Additional';
        objCP4.Type__c = 'Stack';
        objCP4.Project__c = objpr.Id;
        insert objCP4;      
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        insert objcustomer1;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Final_Approved_Date__c = System.today().addDays(5);  // Added by Neha on 25/2/19     
        q.Quote_Status__c = 'Valid';  // Added by Neha on 25/2/19
        q.Allow_booking_without_full_token__c = TRUE;
        q.Total_Agreement_Value_Bucket__c = 60422880;
        q.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
        q.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
        q.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
        q.Car_Park_Type_1__c = '';
        q.Car_Park_Type_2__c = '';
        q.Car_Park_Type_3__c = '';
        q.Car_Park_Count_1__c = 0;
        q.Car_Park_Count_2__c = 0;
        q.Car_Park_Count_3__c = 0;
        insert q;
        
        PageReference pRef1 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClassDubai bookC1 = new BookingClassDubai();
        bookC1.i = 0;
        List <SelectOption> sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.getTokenAmount();
        bookC1.boookingObj.Application_No__c = '11111';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234567890';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'test@test.in';
        bookC1.boookingObj.Mode_of_Funding__c = 'Self';
        bookC1.dateOfOfferPossesion = system.today().addDays(2);
        
        bookC1.receiptlist[0].Mode__c = 'Cheque';
        bookC1.receiptlist[0].Cheque_DD__c = '908888';
        bookC1.receiptlist[0].Cheque_DD_Date__c = system.today();
        bookC1.receiptlist[0].Total_Amount__c = 1000000;
        bookC1.receiptlist[0].Currency__c = 'Indian Rupee';
        bookC1.receiptlist[0].DraweeBank__c = 'Akola Urban Co-operative Bank';
        
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man1';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Country__c = 'UAE'; // Changed by Neha on 3/2/19
        bookC1.applicant.Mailing_Country__c= 'UAE'; // Changed by Neha on 3/2/19
        bookC1.applicant.Mobile_Number__c = '909090901';
        bookC1.applicant.Email_Address__c = 'newman@justnow1.com';
        bookC1.applicant.Nationality__c = 'Indian';   
        //// Added by Neha on 19/1/19 Starts Here    
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident';
        bookC1.applicant.Passport_Copy__c = false;
        bookC1.applicant.Power_of_Attorney__c = true;
        bookC1.applicant.Others__c = true;
        bookC1.applicant.Power_of_Attorney__c = true;
        bookC1.applicant.Non_residency_Letter__c = true;
        ////// Added by Neha Ends Here          
        bookC1.addressCheck = true; 
        bookC1.firstApplicantDOB = system.today().addDays(-2);
        bookC1.applicant.Preferred_address_for_all_correspondence__c = 'Permanent';
        bookC1.getaddressstatus();         
        
        bookC1.applicant3.Name = 'Third Man1';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.City__c = 'Nagpur';
        bookC1.applicant3.Mailing_Country__c= null;
        bookC1.applicant3.Mobile_Number__c = '909090903';
        bookC1.applicant3.Email_Address__c = 'newman@justnow3.com';
        bookC1.applicant3.Nationality__c = 'Indian';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'UAE Resident';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.Address_Proof__c = true;
        bookC1.applicant3.Address_Proof_Document__c = 'xyz';
        bookC1.applicant3.Address_Proof_Number__c = 'pqr';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant3 = true;
        bookC1.getaddressstatus();
        bookC1.save();        
        
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.applicant4.Name = 'Third Man4';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.DOB__c = system.today();
        bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.City__c = 'Nagpur';
        bookC1.applicant4.Mailing_Country__c= 'UAE';
        bookC1.applicant4.Mobile_Number__c = '909090903';
        bookC1.applicant4.Email_Address__c = 'newman@justnow4.com';
        bookC1.applicant4.Nationality__c = 'Indian';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Purchaser'; // Neha
        bookC1.applicant4.Subtype_Of_Applicant__c = 'UAE Resident'; // Neha
        bookC1.applicant4.Passport_Copy__c = true;
        bookC1.applicant4.Emirates_ID__c = true;
        bookC1.applicant4.Passport_Copy_Details__c = 'xyz';
        bookC1.applicant4.Valid_Until_Passport__c = System.today().addDays(5);
        bookC1.applicant4.Emirates_ID_Details__c = 'pqr';
        bookC1.applicant4.Visa_Copy__c = true;
        bookC1.applicant4.Visa_Copy_Valid_Upto__c = System.today().addDays(5);
        bookC1.addressCheckApplicant4 = true;
        bookC1.getaddressstatus();
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.applicant4.Name = 'Third Man5';
        bookC1.save();
        
    }
    ////////////// Method Added by Neha on 21/1/19 to insert all the applicants with all details and without error for Dubai KYC Documents
    @isTest
    private static void BookingTestNewDubai() {    
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        Car_Park__c objCP1;
        
        EmailOptOutBooking__c cs = new EmailOptOutBooking__c();
        cs.Name='Send Email On Booking Creation';
        cs.Send_Welcome_Email__c = true;
		insert cs;
        objpr = new Project__c();
        objpr = createProject('Xa_prj2','1111');
        List<Cluster__c> cList = TestDataFactory.createClusters(2, objpr.Id);       
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        
        ProjectCharges__c projchrg1 = new ProjectCharges__c();
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = objpr.id;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Agreement Value';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1; 
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;       
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];
        
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];
        
        objCP1 = new Car_Park__c ();
        objCP1.Status__c = 'Available';
        objCP1.Category__c = 'Additional';
        objCP1.Type__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        Test.startTest();
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        objcustomer.Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        insert objcustomer;              
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objCustomer.Id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Final_Approved_Date__c = System.today().addDays(5);  // Added by Neha on 25/2/19     
        q.Quote_Status__c = 'Valid';  // Added by Neha on 25/2/19
        q.Total_Agreement_Value_Bucket__c = 60422880;
        q.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
        q.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
        q.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
        q.Car_Park_Type_1__c = '';
        q.Car_Park_Type_2__c = '';
        q.Car_Park_Type_3__c = '';
        q.Car_Park_Count_1__c = 0;
        q.Car_Park_Count_2__c = 0;
        q.Car_Park_Count_3__c = 0;
        insert q;
        
        Booking__c bks = new Booking__C();
        bks.Opportunity__c = objCustomer.Id;
        bks.Quotation__c = q.Id;
        bks.Booking_Date__c = System.Today();
        bks.Agreement_Value__c = 3000000;
        insert bks;
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = bks.Id;
        a1.Applicant_Number__c = 'Secondary Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
        insert a1;
        Project_Construction_Stages__c pgs = new Project_Construction_Stages__c();
        pgs.Planned_date_of_completion__c = System.today().addDays(30);
        pgs.Project__c = objpr.id;
        pgs.Tower__c = tList[0].id;
        pgs.Name = 'On Plinth';
        insert pgs;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Milestone_Name__c = 'Application Money1';
        pm.Number_Of_Days__c = 0;
        pm.Milestone_Due_Date__c = System.Today().addDays(10);
        pm.Quotation__c = q.Id;
        insert pm;
        
        Payment_Milestones__c pm1 = new Payment_Milestones__c();
        pm1.Milestone_Type_edit__c = 'Construction Linked';
        pm1.Milestone_Name__c = 'On Plinth';
        pm1.Project_Construction_Stages__c = pgs.Id;
        pm1.Number_Of_Days__c = 0;
        pm1.Milestone_Due_Date__c = System.Today().addDays(10);
        pm1.Quotation__c = q.Id;
        insert pm1;
        
        Account_Master__c a13 = new Account_Master__c();
        a13.Name = 'Cash';
        a13.Account_Number__c = '123456';
        a13.Type__c = 'Others';
        insert a13;
        
        Account_Master__c a12 = new Account_Master__c();
        a12.Name = 'Trade Receivable';
        a12.Account_Number__c = '213456';
        a12.Type__c = 'Others';
        insert a12;
        
        Account_Master__c a11 = new Account_Master__c();
        a11.Name = 'Vat 5% Payable';
        a11.Account_Number__c = '123456';
        a11.Type__c = 'VAT';
        a11.Tax_Rate__c = 'VAT 5%';
        insert a11;
        
        PageReference pRef1 = Page.BookingPageFormDubai;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        
        BookingClassDubai bookC1 = new BookingClassDubai();
        bookC1.i = 0;
        List <SelectOption> sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.getTokenAmount();
        bookc1.selectedCountryName = 'India';
        bookc1.selectedStateName = 'Andhra Pradesh';
        bookc1.selectedCityName = 'Guntur';
        bookc1.countryapplicantData = 'applicant1';
        bookc1.stateapplicantData = 'applicant1';
        bookc1.cityapplicantData = 'applicant1';
        bookc1.getCountryRelatedState();
        bookc1.getCountryRelatedCity();
        bookc1.getCity();
        bookc1.countryapplicantData = 'applicant2';
        bookc1.stateapplicantData = 'applicant2';
        bookc1.cityapplicantData = 'applicant2';
        bookc1.getCountryRelatedState();
        bookc1.getCountryRelatedCity();
        bookc1.getCity();
         bookc1.countryapplicantData = 'applicant3';
        bookc1.stateapplicantData = 'applicant3';
        bookc1.cityapplicantData = 'applicant3';
        bookc1.getCountryRelatedState();
        bookc1.getCountryRelatedCity();
        bookc1.getCity();
         bookc1.countryapplicantData = 'applicant4';
        bookc1.stateapplicantData = 'applicant4';
        bookc1.cityapplicantData = 'applicant4';
        bookc1.getCountryRelatedState();
        bookc1.getCountryRelatedCity();
        bookc1.getCity();
        
        //  bookC1.getReceiptDetails();
        BookingClassDubai.getLegalEntityDetails(objPUU.id, objpr.id);
        bookC1.Cancel();
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        bookC1.boookingObj.Mode_of_Funding__c = 'Self';
        bookC1.boookingObj.Stage_of_Booking__c = 'EOI';
        bookC1.dateOfOfferPossesion = system.today().addDays(2);
        bookC1.receiptlist[0].Mode__c = 'Cheque';
        bookC1.receiptlist[0].Cheque_DD__c = '908888';
        bookC1.receiptlist[0].Cheque_DD_Date__c = system.today();
        bookC1.receiptlist[0].Total_Amount__c = 1000000;
        bookC1.receiptlist[0].Currency__c = 'Indian Rupee';
        bookC1.receiptlist[0].DraweeBank__c = 'Akola Urban Co-operative Bank';
        
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man1';
        bookC1.applicant.Applicant_Number__c = 'Primary Applicant';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.State__c = 'Maharashtra';
        bookC1.applicant.City__c = 'Nagpur'; 
        bookC1.applicant.Mailing_Country__c= 'UAE';
        bookC1.applicant.Mobile_Number__c = '909090901';
        bookC1.applicant.Email_Address__c = 'newman@justnow1.com';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant.Subtype_Of_Applicant__c = 'UAE Resident';
        bookC1.applicant.Passport_Copy__c = true; 
        bookC1.applicant.Passport_Copy_Details__c = 'abc';
        bookC1.applicant.Valid_Until_Passport__c = System.today().addDays(15);
        bookC1.applicant.Visa_Copy__c = true; 
        bookC1.applicant.Visa_Copy_Valid_Upto__c = System.today().addDays(20);
        bookC1.applicant.Emirates_ID__c = true;
        bookC1.applicant.Emirates_ID_Details__c = 'pqr'; 
        bookC1.addressCheck = true; 
        bookC1.firstApplicantDOB = system.today().addDays(-2);
        bookC1.applicant.Preferred_address_for_all_correspondence__c = 'Permanent';
        bookC1.applicant.Mailing_Address_same_as_PermanentAddress__c = true;
        bookC1.getaddressstatus();
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Name = 'Second Man1';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mobile_Number__c = '909090902';
        bookC1.applicant2.Email_Address__c = 'newman@justnow2.com';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Purchaser'; 
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Non-UAE Resident';
        bookC1.applicant2.Passport_Copy__c = true; 
        bookC1.applicant2.Passport_Copy_Details__c = 'xyz'; 
        bookC1.applicant2.Valid_Until_Passport__c = System.today().addDays(5);
        bookC1.applicant2.National_ID__c = true; 
        bookC1.applicant2.National_ID_Details__c = 'pqr';
        bookC1.applicant2.Valid_Upto_National_ID__c = System.today().addDays(10);
        bookC1.addressCheckApplicant2 = true;
        bookC1.secondApplicantDOB = system.today().addDays(-5);
        bookC1.getaddressstatus();
        bookC1.save();    
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Name = 'Third Man2';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';        
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c = 'Maharashtra';        
        bookC1.applicant3.Mobile_Number__c = '909090900';
        bookC1.applicant3.Email_Address__c = 'newman@justnow.com';        
        bookC1.applicant3.Type_Of_Applicant__c  = 'Corporate Purchaser';
        bookC1.applicant3.Subtype_Of_Applicant__c = Constants.COMPANIES_INCORPORATED_IN_FREE_ZONE;
        bookC1.applicant3.Certificate_of_Incorporation__c = true;
        bookC1.applicant3.Certificate_of_Incorporation_Details__c = 'abc';
        bookC1.applicant3.Certificate_of_Good_Standing_and_Certifi__c = true;
        bookC1.applicant3.Certificate_of_Standing_Incumbe_Detail__c = 'xyz';
        bookC1.applicant3.Passport_Copy_of_Authorized_Signatory__c  = true; 
        bookC1.applicant3.Passport_Copy_of_Authorized_Signatory_De__c = 'efg';
        bookC1.applicant3.Memoradum_Articles_of_Association__c = true; 
        bookC1.applicant3.Memoradum_Articles_of_Association_Deta__c = 'pqr';
        bookC1.applicant3.Mailing_Address_same_as_PermanentAddress__c = true;
        bookC1.addressCheckApplicant3 = true;
        bookC1.thirdApplicantDOB = system.today().addDays(-5);
        // bookC1.save();
        
        // applicant4 to required fields validation simulation        
        bookC1.applicant4.Name ='Fourth Man2';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';       
        bookC1.applicant4.Country__c = 'India';        
        bookC1.applicant4.Mobile_Number__c = '909090900';
        bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Corporate Purchaser'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Companies incorporated in the UAE'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Registration_License__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant4.Passport_Copy_of_Authorized_Signatory__c = true; // Changed by Neha on 21/1/19
        bookC1.applicant4.Registration_License_Details__c = '1234567891'; // Changed by Neha on 21/1/19
        bookC1.applicant4.Passport_Copy_of_Authorized_Signatory_De__c = 'test'; // Changed by Neha on 21/1/19
        bookC1.addressCheckApplicant4 = true;
        bookC1.fourthApplicantDOB = system.today().addDays(-2);
        // bookC1.save();
        
        bookC1.applicant5.Name ='Fifth Man2';
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';       
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.Mobile_Number__c = '909090900';
        bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Nationality__c = 'Indian';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Purchaser';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'UAE Resident';
        bookC1.applicant5.Pancard__c = false;
        bookC1.applicant5.PassportNumber__c = true;
        bookC1.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant5.Address_Proof__c = false;
        bookC1.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant5.PancardNo__c = '';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c = false;
        bookC1.applicant5.Address_Proof_Document__c = '';
        bookC1.applicant5.Address_Proof_Number__c  = '';
        bookC1.addressCheckApplicant5 = true;
        bookC1.fifthApplicantDOB = system.today().addDays(-2);       
        // bookC1.save();
        
        
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        //   bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        //   bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        //   bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fourth Man';
        //    bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fifth Man';
        //    bookC1.save();
        
        bookC1.applicant.Name = '';
        bookC1.applicant.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant.Others_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant.Visa_Copy_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant.Valid_Upto_Emirates_Id__c = System.today().addDays(-1);
        bookC1.applicant.Valid_Upto_National_ID__c = System.today().addDays(-1);
        bookC1.applicant.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);

        bookC1.applicant.Mobile_County_Code__c = '+91';
        bookC1.applicant.Type_Of_Applicant__c = 'Corporate Purchaser';
        
        bookC1.applicant2.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant2.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant2.Others_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant2.Visa_Copy_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant2.Valid_Upto_Emirates_Id__c = System.today().addDays(-1);
        bookC1.applicant2.Valid_Upto_National_ID__c = System.today().addDays(-1);
        bookC1.applicant2.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant2.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);

        bookC1.applicant2.Mobile_County_Code__c = '+91';
        bookC1.applicant2.Type_Of_Applicant__c = 'Corporate Purchaser';
        
        bookC1.applicant3.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant3.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant3.Others_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant3.Visa_Copy_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant3.Valid_Upto_Emirates_Id__c = System.today().addDays(-1);
        bookC1.applicant3.Valid_Upto_National_ID__c = System.today().addDays(-1);
        bookC1.applicant3.Valid_Until_Passport__c = System.today().addDays(-1);
        bookC1.applicant3.Non_residency_Letter_Valid_Upto__c = System.today().addDays(-1);
        bookC1.applicant3.Mobile_County_Code__c = '+91';
        bookC1.applicant3.Type_Of_Applicant__c = 'Corporate Purchaser';
        bookC1.save();
       
        Test.stopTest();        
    } 
    public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode, Service_Tax_Required_On_Token_Amount__c = true);
        insert objProject;
        return objProject;
    }             
}