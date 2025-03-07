@isTest
private  Class TestVFControllers {
    @isTest
    private static void InventoryViewTest() {
        
        Project__c p = createProject('Xa_prj','111');
        
        //create Clusters
        List<Cluster__c> cList = TestDataFactory.createClusters(2, p.Id);
        
        //create Towers
        List<Tower__c> tList = TestDataFactory.createTowers(2, p.Id);
        
        //create Units
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, p.Id);
        
        Test.startTest();
        PageReference pRef = Page.S_InventoryMatrixview;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('projectsent',p.Id);
        ApexPages.currentPage().getParameters().put('towersent',tList[0].Id);
        
        S_InventoryMatrix invController = new S_InventoryMatrix();
        invController.selectedVal = p.Id;
        invController.SelectedClusterId = cList[0].Id;
        invController.selectedTower = tList[0].Id;
        invController.selectedstatus = '';
        invController.selectedConf = uList[0].Id ;
        invController.sold = true;
        invController.open = true;
        invController.booked = true;
        invController.reserved = true;
        invController.blocked = true;      
        invController.onebhk = true;
        invController.twobhk = true;
        invController.threebhk = true;
        invController.fourbhk = true;
        invController.fivebhk = true;
        InventoryMatrix_Utility.getUnitAllocatedSM(uList[0].Id );
        List<SelectOption> pl = invController.getProjects;
        List<SelectOption> tl = invController.getTowers; 
        List<SelectOption> clusterNames = invController.getClusterNames; 
        List<SelectOption> projectUnitTypes = invController.getProjectunittype; 
        List<Decimal> floorSeq = invController.floorDescSeqList;
        Map<Decimal, List<Unit__c>> UnitMap = invController.JMap;      
        Test.stopTest();
    }
    
    public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode);
        insert objProject;
        return objProject;
    }
    
    public static Cluster__c createCluster(Id pr){
        Cluster__c cl = new Cluster__c ();
        cl.Project__c = pr;
        cl.MAHA_RERA_No__c = '12334';
        insert cl;
        return cl;
    }    
    
    /*@isTest
    private static void documentCheckListRejectTest(){  
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        
        objpr = new Project__c();
        objpr.Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        objPUU = new Unit__c ();  
        objPUU.Name = 'TestUnit';      
        objPUU.Project__c = objpr.Id;       
        objPUU.Unit_Status__c ='Booked';
        insert objPUU;
        
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
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;         
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.Unit__c  =objPUU.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objCustomer.Physical_document_received__c = true;
        insert objcustomer;
        
        objPUU.Unit_Status__c= 'Booked'; // Neha Changed BIP to Booked
        update objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';        
        q.Unit__c = objPUU.Id;        
        q.Opportunity__c = objcustomer.Id;       
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;      
        q.Payment_Plan__c = pl.id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
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
        
        
        objBooking = new Booking__c();
        objBooking.Project__c= objpr.Id;
        objBooking.Opportunity__c =objcustomer.id;
        objBooking.Unit__c = objPUU.id;
        objBooking.Status__c='Booking In Process';
        objBooking.quotation__c = q.id;
        objBooking.Booking_Date__c = system.today();
        objBooking.Sales_Managers__c = UserInfo.getUserId();
        objBooking.OwnerId = UserInfo.getUserId();
        objBooking.Stage_of_Booking__c  = 'Booked';
        objBooking.Verification_status__c = 'Not Started';
        objBooking.Agreement_Value__c = 2500000;
        insert objBooking;        
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = objpr.Id;
        objRec.Opportunity__c = objcustomer.Id;
        objRec.Project_Unit__c = objPUU.Id;
        objRec.Booking__c = objBooking.Id; // Neha
        objRec.Receipt_Status__c = 'Cleared';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Amount_Rs__c = 100000;
        objRec.Total_Amount__c = 100000;
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        //     objRec.Opportunity_Email_id__c = 'test@test.com';
        insert objRec; 
        
        objBooking.Receipts__c = objRec.id;
        update objBooking;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Amount_Rs__c = 100000;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Receipt_Status__c = 'Cleared';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 140000;
        r2.Booking__c = objBooking.Id; // Neha
        insert r2;  
        
        list<Applicant_Details__c> applicantDetails = new list<Applicant_Details__c>();
        
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = objBooking.Id;
        applicantDetails.add(ad1);
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = objBooking.Id;
        applicantDetails.add(ad2);
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = objBooking.Id;
        applicantDetails.add(ad3);
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = objBooking.Id;
        applicantDetails.add(ad4);
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = objBooking.Id;
        applicantDetails.add(ad5);
        insert applicantDetails;
        
        PageReference processPage = Page.S_ProcessDocumentVerification;
        Test.setCurrentPage(processPage);
        S_ProcessDocumentVerification processController = new S_ProcessDocumentVerification();
        processController.processRowNo =string.valueOf(0);
        processController.assignRowNo =string.valueOf(0);
        processController.ReleaseRowNo =string.valueOf(0); // Neha
        processController.Process();
        //processController.Assign();
        Test.startTest(); 
        PageReference dcPage = Page.DocumentChecklistPageDubai;
        Test.setCurrentPage(dcPage);
        ApexPages.currentPage().getParameters().put('id',objBooking.Id);
        DocumentChecklistPageDubaiController dcpC = new DocumentChecklistPageDubaiController();
        Document_Checklist_Header__c dch = new Document_Checklist_Header__c();
        dcpC.ArrayApplicant1String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,name is incorrect,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,address is incorrect,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324,true, ,true,Email Address (Should be mentioned),N/A,a@k.com ,true,,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,incorrect,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,incorrect,true,One Passport Size Color Photograph.,N/A,N/A,false,incorrect';
        dcpC.ArrayApplicant2String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,name is incorrect,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,address is incorrect,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324,true, ,true,Email Address (Should be mentioned),N/A,a@k.com ,true,,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,incorrect,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,incorrect,true,One Passport Size Color Photograph.,N/A,N/A,false,incorrect';
        dcpC.ArrayApplicant3String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,name is incorrect,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,address is incorrect,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324,true, ,true,Email Address (Should be mentioned),N/A,a@k.com ,true,,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,incorrect,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,incorrect,true,One Passport Size Color Photograph.,N/A,N/A,false,incorrect';
        dcpC.ArrayApplicant4String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,name is incorrect,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,address is incorrect,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324,true, ,true,Email Address (Should be mentioned),N/A,a@k.com ,true,,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,incorrect,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,incorrect,true,One Passport Size Color Photograph.,N/A,N/A,false,incorrect';
        dcpC.ArrayApplicant5String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,name is incorrect,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,address is incorrect,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324,true, ,true,Email Address (Should be mentioned),N/A,a@k.com ,true,,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,incorrect,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,incorrect,true,One Passport Size Color Photograph.,N/A,N/A,false,incorrect';
        dcpC.checklistHeader.Rejection_Remarks__c = 'testing ok';        
        dcpC.saveArray();
        
        // calling the rejected documents page from here.
        PageReference rejPage = Page.RejectedDocumentsPage;
        Test.setCurrentPage(rejPage);
        ApexPages.currentPage().getParameters().put('DocumentHeaderId',dcpC.checklistHeader.Id);
        RejectedDocumentsController rejC = new RejectedDocumentsController();
        rejC.save();
        rejC.Accept();
        rejC.btnReject();
        Test.stopTest();
    }*/
    
    
    /*@isTest
    private static void documentCheckListRejected(){  
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c  objPUU;
        
        objpr = new Project__c();
        objpr.Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        objPUU = new Unit__c ();  
        objPUU.Name = 'TestUnit';      
        objPUU.Project__c = objpr.Id;      
        objPUU.Unit_Status__c ='Available';
        insert objPUU;
        
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
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.Unit__c =objPUU.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objCustomer.Physical_document_received__c = true;
        insert objcustomer;
        
        objPUU.Unit_Status__c= 'BIP - RM Verification';
        update objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';       
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;      
        q.Payment_Plan__c = pl.id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
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
        
        objBooking = new Booking__c();
        objBooking .Project__c= objpr.Id;
        objBooking.Opportunity__c =objcustomer.id;
        objBooking.Unit__c = objPUU.id;
        objBooking.Carpet_Area__c =1500;
        objBooking.Effective_From__c=System.today();
        objBooking.Status__c='UnProcessed';
        objBooking.UnitChange__c=false;
        objBooking.quotation__c = q.id;
        objBooking.Booking_Date__c = system.today();
        objBooking.Agreement_Value__c = 10000;
        objBooking.Sales_Managers__c = UserInfo.getUserId();
        objBooking.OwnerId = UserInfo.getUserId();
        insert objBooking;
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = objpr.Id;
        objRec.Opportunity__c = objcustomer.Id;
        objRec.Project_Unit__c = objPUU.Id;
        objRec.Receipt_No_Manual__c = '12';
        objRec.Receipt_Status__c = 'Processed';
        objRec.Additional_Info__c = 'Testing';
        objRec.Cheque_DD_Amount_Rs__c = 100;
        objRec.Direct__c = true;
        objRec.Mode__c = 'Local Cheque';
        objRec.Branch__c = 'Noida';
        objRec.RTGS__c = '123';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Total_Amount__c = 100;
        objRec.Manual_Receipt_Date__c = System.today();
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Discount_Value__c = 1;
        objRec.Discount_to_begiven_on_Timely_payment__c    = 'As Amount';
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        objRec.Opportunity_Email_id__c = 'test@test.com';
        objRec.Booking__c = objBooking.Id; // Neha
        insert objRec; 
        
        objBooking.Receipts__c = objRec.id;  // Neha
        update objBooking;  // Neha
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 8400;
        r2.Booking__c = objBooking.Id; // Neha
        insert r2;               
        
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = objBooking.Id;
        insert ad1;
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = objBooking.Id;
        insert ad2;
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = objBooking.Id;
        insert ad3;
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = objBooking.Id;
        insert ad4;
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = objBooking.Id;
        insert ad5;
        Test.startTest();
        PageReference dcPage = Page.DocumentChecklistPageDubai;
        Test.setCurrentPage(dcPage);
        ApexPages.currentPage().getParameters().put('id',objBooking.Id);
        DocumentChecklistPageDubaiController dcpC = new DocumentChecklistPageDubaiController();
        dcPC.d1=False;
        dcPC.d2=False;
        dcPC.d3=False;
        dcPC.d4=False;
        dcPC.d5=False;
        dcPC.d6=False;
        dcPC.d7=False;
        dcPC.d8=False;
        dcPC.d9=False;
        dcPC.d10=False;
        dcPC.d11=False;   
        dcpC.btnReject();
        ApexPages.currentPage().getParameters().put('id',objBooking.Id);
        DocumentChecklistPageDubaiController dcpCNew = new DocumentChecklistPageDubaiController();
        dcpCNew.d1=False;
        dcpCNew.d2=False;
        dcpCNew.d3=False;
        dcpCNew.d4=False;
        dcpCNew.d5=False;
        dcpCNew.d6=False;
        dcpCNew.d7=False;
        dcpCNew.d8=False;
        dcpCNew.d9=False;
        dcpCNew.d10=False;
        dcpCNew.d11=False;    
        dcpCNew.ArrayApplicant1String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324 ,true,true,Email Address (Should be mentioned),N/A,a@k.com ,true,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,true,One Passport Size Color Photograph.,N/A,N/A,false';
        dcpCNew.ArrayApplicant2String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324 ,true,true,Email Address (Should be mentioned),N/A,a@k.com ,true,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,true,One Passport Size Color Photograph.,N/A,N/A,false';
        dcpCNew.ArrayApplicant3String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324 ,true,true,Email Address (Should be mentioned),N/A,a@k.com ,true,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,true,One Passport Size Color Photograph.,N/A,N/A,false';
        dcpCNew.ArrayApplicant4String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324 ,true,true,Email Address (Should be mentioned),N/A,a@k.com ,true,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,true,One Passport Size Color Photograph.,N/A,N/A,false';
        dcpCNew.ArrayApplicant5String ='true,Name : Clearly written and matches with SFDC Booking,N/A,Mr.sdfdf,false,true,Permanent address : Clearly written and matches with SFDC Booking,N/A,fsdfsd Pincode :234234Country :Australia,false,true,Mailing/Correspondance address : If different - should be mentioned clearly and matches with SFDC,N/A, Pincode : Country :,true,true,Mobile No ( Should be mentioned with 10 digits),N/A,324324 ,true,true,Email Address (Should be mentioned),N/A,a@k.com ,true,true,PAN :Numbers on photocopy matches with: SFDC and Booking form Name on PAN matches with SFDC and Booking form completely,N/A,23432,false,true,Permanent Address : ( The following should match with SFDC data) Type of address proof document Address on photocopy Name on address proof matches with Name Address matches with permanent address.,Driving License,23432,false,true,One Passport Size Color Photograph.,N/A,N/A,false';
        dcpCNew.checklistHeader.Rejection_Remarks__c = 'testing ok';
        
        Test.stopTest();
    }
    
    
    @isTest
    private static void documentCheckListAcceptTest(){  
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        
        objpr = new Project__c();
        objpr.Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        objPUU = new Unit__c ();  
        objPUU.Name = 'TestUnit';      
        objPUU.Project__c = objpr.Id;       
        objPUU.Unit_Status__c ='Available';
        insert objPUU;
        
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
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.Unit__c =objPUU.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objCustomer.Physical_document_received__c = true;
        insert objcustomer;
        
        objPUU.Unit_Status__c= 'BIP - RM Verification';
        update objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';       
        q.Unit__c = objPUU.Id;
        q.Opportunity__c = objcustomer.Id;        
        q.Payment_Plan__c = pl.id;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
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
        
        objBooking = new Booking__c();
        objBooking .Project__c= objpr.Id;
        objBooking.Opportunity__c =objcustomer.id;
        objBooking.Unit__c = objPUU.id;
        objBooking.Carpet_Area__c =1500;
        objBooking.Effective_From__c=System.today();
        objBooking.Status__c='UnProcessed';
        objBooking.UnitChange__c=false;
        objBooking.quotation__c = q.id;
        objBooking.Booking_Date__c = system.today();
        objBooking.Agreement_Value__c = 10000;
        objBooking.Sales_Managers__c = UserInfo.getUserId();
        objBooking.OwnerId = UserInfo.getUserId();
        insert objBooking;
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = objpr.Id;
        objRec.Opportunity__c = objcustomer.Id;
        objRec.Project_Unit__c = objPUU.Id;
        objRec.Receipt_No_Manual__c = '12';
        objRec.Receipt_Status__c = 'Processed';
        objRec.Additional_Info__c = 'Testing';
        objRec.Cheque_DD_Amount_Rs__c = 100;
        objRec.Direct__c = true;
        objRec.Mode__c = 'Local Cheque';
        objRec.Branch__c = 'Noida';
        objRec.RTGS__c = '123';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Total_Amount__c = 100;
        objRec.Manual_Receipt_Date__c = System.today();
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Discount_Value__c = 1;
        objRec.Discount_to_begiven_on_Timely_payment__c    = 'As Amount';
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        objRec.Opportunity_Email_id__c = 'test@test.com';
        objRec.Booking__c = objBooking.Id; //Neha
        insert objRec; 
        
        objBooking.Receipts__c = objRec.id; //Neha
        update objBooking; // Neha
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 8400;
        r2.Booking__c = objBooking.Id; //Neha
        insert r2;     
        
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = objBooking.Id;
        insert ad1;
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = objBooking.Id;
        insert ad2;
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = objBooking.Id;
        insert ad3;
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = objBooking.Id;
        insert ad4;
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = objBooking.Id;
        insert ad5;
        Test.startTest();
        PageReference dcPage = Page.DocumentChecklistPageDubai;
        Test.setCurrentPage(dcPage);
        ApexPages.currentPage().getParameters().put('id',objBooking.Id);
        DocumentChecklistPageDubaiController dcpC = new DocumentChecklistPageDubaiController();
        dcpC.Accept();
        
        Test.stopTest();
    }*/
    
    //@isTest
    /*  private static void welcomeCallTest(){  
User a1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');        

Test.startTest();
Opportunity objcustomer;
Booking__c objBooking;
Project__c objpr;
Unit__c objPUU;
profile pf;

objpr = new Project__c();
objpr.Project_Code__c = 'T31';
objpr.Name = 'TestProject';
objpr.RDS_Short_Name__c = 'T';
objpr.Start_Date__c = System.today().addDays(-5);
objpr.Project_CRM_Lead__c = a1.id;
objpr.Project_Site_Head__c = a1.id;
objpr.RDS_Interest_Rate__c = 12;

insert objpr;

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
pl.Project__c = objpr.id; 
pl.NoofMilestones__c = 25;
pl.Charge1Name__c = 'Basic';
pl.Charge_1_Total__c = 100;
insert pl;  

objPUU = new Unit__c();  
objPUU.Name = 'TestUnit';      
objPUU.Project__c = objpr.Id;
objPUU.Carpet_Area__c = 425;
objPUU.Chargeable_Area__c = 923;
objPUU.Configuration__c = '2BHK';
objPUU.Unit_Status__c = 'Available';
objPUU.Active_Inactive__c = 'Active';
objPUU.Floor__c = 1;

insert objPUU;

Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);

objcustomer= new Opportunity();
objcustomer.Project__c=objpr.id;
objcustomer.name='Test 1';
objcustomer.StageName='Open';
objcustomer.Unit__c=objPUU.id;  
objcustomer.CloseDate=system.today();
objcustomer.Status__c ='Active';
objCustomer.AccountId = a.Id;
insert objcustomer;

objPUU.Unit_Status__c= 'Welcome Call Pending';
update objPUU;

Quotation__c q = new Quotation__c();
q.Quote_Status__c = 'Valid';
q.Payment_Plan__c = pl.id;
q.Unit__c = objPUU.Id;
q.Opportunity__c = objcustomer.Id;        
q.Token_Amount__c =110000;
q.ST_Token_Amount__c = 1000;
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

objBooking = new Booking__c();
objBooking.Project__c= objpr.Id;
objBooking.Opportunity__c =objcustomer.id;
objBooking.Unit__c = objPUU.id;
objBooking.Carpet_Area__c =1500;
objBooking.Effective_From__c=System.today();
objBooking.Status__c='Booking In Process';
objBooking.UnitChange__c=false;
objBooking.quotation__c = q.id;
objBooking.Booking_Date__c = system.today();
objBooking.Sales_Managers__c = UserInfo.getUserId();
objBooking.OwnerId = UserInfo.getUserId();
objBooking.Agreement_Value__c = 3000000;
insert objBooking;

Receipt__c r1 = new Receipt__c();
r1.Cheque_DD_Amount_Rs__c = 200000;
r1.Cheque_DD__c = '908888';
r1.Cheque_DD_Date__c = system.today();
r1.Project__c = objpr.Id;
r1.Project_Unit__c = objPUU.Id;
r1.Opportunity__c = objcustomer.Id;
r1.CheckReceipt__c = true;
r1.Token_Amount_Receipt__c = true;
r1.Physically_Cheque_Received__c = true;
r1.Approval_Status__c = 'Approved';
r1.Receipt_Date__c = system.today();
r1.DraweeBank__c = 'Axis Bank';
r1.Total_Amount__c = 200000;
r1.Booking__c = objBooking.Id; //Neha
insert r1;

Receipt__c r2 = new Receipt__c();
r2.Cheque_DD_Amount_Rs__c = 8400;
r2.Cheque_DD__c = '9088881';
r2.Cheque_DD_Date__c = system.today();
r2.Project__c = objpr.Id;
r2.Project_Unit__c = objPUU.Id;
r2.Opportunity__c = objcustomer.Id;
r2.CheckReceipt__c = true;
r2.Physically_Cheque_Received__c = true;
r2.Approval_Status__c = 'Approved';
r2.Receipt_Date__c = system.today();
r2.DraweeBank__c = 'CITI';
r2.Total_Amount__c = 8400;
r2.Booking__c = objBooking.Id; //Neha
insert r2;

Receipt__c objRec = new Receipt__c();
objRec.Project__c = objpr.Id;
objRec.Opportunity__c = objcustomer.Id;
objRec.Project_Unit__c = objPUU.Id;
objRec.Receipt_No_Manual__c = '12';
objRec.Receipt_Status__c = 'Processed';
objRec.Additional_Info__c = 'Testing';
objRec.Cheque_DD_Amount_Rs__c = 100;
objRec.Direct__c = true;
objRec.Mode__c = 'Local Cheque';
objRec.Branch__c = 'Noida';
objRec.RTGS__c = '123';
objRec.Cheque_DD__c = '12';
objRec.Remarks__c = true;
objRec.Total_Amount__c = 100;
objRec.Manual_Receipt_Date__c = System.today();
objRec.Receipt_Date__c = System.today().addDays(-1);
objRec.Cheque_DD_Date__c = System.today();
objRec.Discount_Value__c = 1;
objRec.Project_Unit__c = objPUU.Id;
objRec.Discount_to_begiven_on_Timely_payment__c    = 'As Amount';
objRec.Token_Amount_Receipt__c = true;
objRec.On_Account_Money__c = 0;
objRec.Currency__c = 'Indian Rupee';
objRec.Opportunity_Email_id__c = 'test@test.com';
objRec.Booking__c = objBooking.Id; //Neha
insert objRec; 

objBooking.Receipts__c = objRec.id; //Neha
update objBooking;  //Neha

Applicant_Details__c ad1 = new Applicant_Details__c();
ad1.Name = 'A One';
ad1.Type_Of_Applicant__c = 'Individual Buyer';
ad1.Subtype_Of_Applicant__c = 'Indian National';
ad1.One_Passport_Size_Color_Photograph__c = true;
ad1.Permanent_Address__c = 'Perma Addressia';
ad1.Email_Address__c = 'a1.one@gmail.com';
ad1.Mobile_Number__c = '989898989';
ad1.DOB__c = system.today().addMonths(-12);
ad1.Booking__c = objBooking.Id;

insert ad1;

Applicant_Details__c ad2 = new Applicant_Details__c();
ad2.Name = 'A Four';
ad2.Type_Of_Applicant__c = 'Individual Buyer';
ad2.Subtype_Of_Applicant__c = 'Indian National';
ad2.One_Passport_Size_Color_Photograph__c = true;
ad2.Permanent_Address__c = 'Perma Addressia';
ad2.Email_Address__c = 'a2.one@gmail.com';
ad2.Mobile_Number__c = '8080808080';
ad2.DOB__c = system.today().addMonths(-12);
ad2.Booking__c = objBooking.Id;
insert ad2;

Applicant_Details__c ad3 = new Applicant_Details__c();
ad3.Name = 'A Three';
ad3.Type_Of_Applicant__c = 'Individual Buyer';
ad3.Subtype_Of_Applicant__c = 'Indian National';
ad3.One_Passport_Size_Color_Photograph__c = true;
ad3.Permanent_Address__c = 'Perma Addressia';
ad3.Email_Address__c = 'a3.one@gmail.com';
ad3.Mobile_Number__c = '9090909090';
ad3.DOB__c = system.today().addMonths(-12);
ad3.Booking__c = objBooking.Id;
insert ad3;

Applicant_Details__c ad4 = new Applicant_Details__c();
ad4.Name = 'A Four';
ad4.Type_Of_Applicant__c = 'Individual Buyer';
ad4.Subtype_Of_Applicant__c = 'Indian National';
ad4.One_Passport_Size_Color_Photograph__c = true;
ad4.Permanent_Address__c = 'Perma Addressia';
ad4.Email_Address__c = 'a3.one@gmail.com';
ad4.Mobile_Number__c = '9090909090';
ad4.DOB__c = system.today().addMonths(-12);
ad4.Booking__c = objBooking.Id;
insert ad4;

Applicant_Details__c ad5 = new Applicant_Details__c();
ad5.Name = 'A Five';
ad5.Type_Of_Applicant__c = 'Individual Buyer';
ad5.Subtype_Of_Applicant__c = 'Indian National';
ad5.One_Passport_Size_Color_Photograph__c = true;
ad5.Permanent_Address__c = 'Perma Addressia';
ad5.Email_Address__c = 'a3.one@gmail.com';
ad5.Mobile_Number__c = '9090909090';
ad5.DOB__c = system.today().addMonths(-12);
ad5.Applicant_Number__c = 'Primary Applicant';
ad5.PancardNo__c = 'PA101010';
ad5.Address_Proof_Document__c = 'Driving License';
ad5.Address_Proof_Number__c = 'addkdljf';
ad5.Booking__c = objBooking.Id;
insert ad5;

objPUU.Unit_Status__c= 'Welcome Call Pending';
update objPUU;

PageReference pickwcPage = Page.S_PickWelcomeCall;
Test.setCurrentPage(pickwcPage);

S_WelcomeCallController objWCC = new S_WelcomeCallController();
objWCC.ProcessRowNo='0';
objWCC.ReleaseRowNo='0';
objWCC.AssignRowNo='0';

objWCC.Process();

PageReference wcPage = Page.S_WelcomeCallPage;
Test.setCurrentPage(wcPage);
ApexPages.currentPage().getParameters().put('id',objBooking.Id);
S_WelcomeCallPageController wc = new S_WelcomeCallPageController();
wc.objWCC1 = New Welcome_Call_Checklist__c();
wc.objWCC2 = New Welcome_Call_Checklist__c();
wc.objWCC3 = New Welcome_Call_Checklist__c();
wc.objWCC4 = New Welcome_Call_Checklist__c();
wc.objWCC5 = New Welcome_Call_Checklist__c();
wc.objWCC6 = New Welcome_Call_Checklist__c();
wc.objWCC36 = New Welcome_Call_Checklist__c();
wc.objWCC44 = New Welcome_Call_Checklist__c();
wc.objWCC45 = New Welcome_Call_Checklist__c();
wc.objWCC46 = New Welcome_Call_Checklist__c();
wc.objWCC52 = New Welcome_Call_Checklist__c();
wc.objWCC53 = New Welcome_Call_Checklist__c();
wc.objWCC54 = New Welcome_Call_Checklist__c();
wc.objWCC7 = New Welcome_Call_Checklist__c();
wc.objWCC31 = New Welcome_Call_Checklist__c();
wc.objWCC32 = New Welcome_Call_Checklist__c();
wc.objWCC35 = New Welcome_Call_Checklist__c();
wc.objWCC34 = New Welcome_Call_Checklist__c();
wc.objWCC37 = New Welcome_Call_Checklist__c();
wc.objWCC39 = New Welcome_Call_Checklist__c();
wc.objWCC40 = New Welcome_Call_Checklist__c();
wc.objWCC47 = New Welcome_Call_Checklist__c();
wc.objWCC48 = New Welcome_Call_Checklist__c();
wc.objWCC49 = New Welcome_Call_Checklist__c();
wc.objWCC50 = New Welcome_Call_Checklist__c();
wc.objWCC51 = New Welcome_Call_Checklist__c();
wc.objWCC57 = New Welcome_Call_Checklist__c();
wc.objWCC58 = New Welcome_Call_Checklist__c();

wc.objWCC1.Verify__c = true;
wc.objWCC4.Verify__c = true;
wc.objWCC6.Verify__c = true;
wc.objWCC3.Verify__c = true;
wc.objWCC5.Verify__c = true;
wc.objWCC2.Verify__c = true;
wc.objWCC36.Verify__c = true;
wc.objWCC44.Verify__c = true;
wc.objWCC45.Funding__c = 'Self Funded';
wc.objWCC46.Delivery_of_Invoices_and_receipts__c = 'Printed via Courier';
wc.objWCC52.Verify__c = true;
wc.objWCC53.Verify__c = true;
wc.objWCC54.Verify__c = true;
wc.objTask.ActivityDate = system.today();
wc.objTask.ReminderDateTime = system.now();
wc.objWCC1.Verify__c = true;
wc.objWCC2.Verify__c = true; 
wc.objWCC3.Verify__c = true;
wc.objWCC4.Verify__c = true;
wc.objWCC5.Verify__c = true;
wc.objWCC6.Verify__c = true;
wc.objWCC7.Verify__c = true;

wc.objWCC31.Verify__c = true;
wc.objWCC32.Verify__c = true; 
wc.objWCC34.Verify__c = true;
wc.objWCC35.Verify__c = true;
wc.objWCC36.Verify__c = true;
wc.objWCC37.Verify__c = true;
wc.objWCC39.Verify__c = true;
wc.objWCC40.Verify__c = true;
wc.objWCC44.Verify__c = true; 
wc.objWCC45.Verify__c = true;
wc.objWCC46.Verify__c = true;
wc.objWCC47.Verify__c = true;
wc.objWCC48.Verify__c = true;
wc.objWCC49.Verify__c = true;
wc.objWCC50.Verify__c = true; 
wc.objWCC51.Verify__c = true;
wc.objWCC52.Verify__c = true;
wc.objWCC53.Verify__c = true;
wc.objWCC54.Verify__c = true;
wc.objWCD.Call_Disposion__c ='Hold';
wc.objWCD.Call_Disposition_L2__c= 'Non - Contactable';
wc.objWCD.Call_Disposition_L3__c= 'Call Back';
wc.strcoOwner = '';
wc.strcoOwner2 = '';
wc.strcoOwner3 = '';
wc.strcoOwner4 = '';       
wc.objWCC57.Verify__c = true;
wc.objWCC58.Verify__c = true;

wc.Submit(); 

PageReference wcPage1 = Page.S_WelcomeCallPage;
Test.setCurrentPage(wcPage1);
ApexPages.currentPage().getParameters().put('id',objBooking.Id);
S_WelcomeCallPageController wc1 = new S_WelcomeCallPageController();
wc1.objWCC1.Verify__c = true;
wc1.objWCC4.Verify__c = true;
wc1.objWCC6.Verify__c = true;
wc1.objWCC3.Verify__c = true;
wc1.objWCC5.Verify__c = true;
wc1.objWCC2.Verify__c = true;
wc1.objWCC36.Verify__c = true;
wc1.objWCC36.Verify__c = true;
wc1.objWCC44.Verify__c = true;
wc1.objWCC45.Funding__c = 'Self Funded';
wc1.objWCC46.Delivery_of_Invoices_and_receipts__c = 'Printed via Courier';
wc1.AgreementValue = 1000000;
wc1.objWCC52.Verify__c = true;
wc1.objWCC53.Verify__c = true;
wc1.objWCC54.Verify__c = true;
wc1.objTask.ActivityDate = system.today();
wc1.objTask.ReminderDateTime = system.now();
wc1.objWCC1.Verify__c = true;
wc1.objWCC2.Verify__c = true; 
wc1.objWCC3.Verify__c = true;
wc1.objWCC4.Verify__c = true;
wc1.objWCC5.Verify__c = true;
wc1.objWCC6.Verify__c = true;
wc1.objWCC7.Verify__c = true;

wc1.objWCC31.Verify__c = true;
wc1.objWCC32.Verify__c = true; 
wc1.objWCC34.Verify__c = true;
wc1.objWCC35.Verify__c = true;
wc1.objWCC36.Verify__c = true;
wc1.objWCC37.Verify__c = true;
wc1.objWCC39.Verify__c = true;
wc1.objWCC40.Verify__c = true;
wc1.objWCC44.Verify__c = true; 
wc1.objWCC45.Verify__c = true;
wc1.objWCC46.Verify__c = true;
wc1.objWCC47.Verify__c = true;
wc1.objWCC48.Verify__c = true;
wc1.objWCC49.Verify__c = true;
wc1.objWCC50.Verify__c = true; 
wc1.objWCC51.Verify__c = true;
wc1.objWCC52.Verify__c = true;
wc1.objWCC53.Verify__c = true;
wc1.objWCC54.Verify__c = true;
wc1.objWCD.Call_Disposion__c ='Hold';
wc.objWCD.Call_Disposition_L3__c= 'Call Back';
wc1.strcoOwner = 'abcd';
wc1.strcoOwner2 = 'xyz';
wc1.strcoOwner3 = 'pqr';
wc1.strcoOwner4 = 'zsd';
wc1.Submit();

Test.stopTest();

PageReference wcPage2 = Page.S_WelcomeCallPage;
Test.setCurrentPage(wcPage2);
ApexPages.currentPage().getParameters().put('id',objBooking.Id);
S_WelcomeCallPageController wc2 = new S_WelcomeCallPageController();
wc2.objWCC1.Verify__c = true;
wc2.objWCC2.Verify__c = true;
wc2.objWCC3.Verify__c = true;
wc2.objWCC4.Verify__c = true;
wc2.objWCC5.Verify__c = true;
wc2.objWCC6.Verify__c = true;
wc2.objWCC7.Verify__c = true;

wc2.objWCC31.Verify__c = true;
wc2.objWCC32.Verify__c = true; 
wc2.objWCC34.Verify__c = true;
wc2.objWCC35.Verify__c = true;
wc2.objWCC36.Verify__c = true;
wc2.objWCC37.Verify__c = true;
wc2.objWCC40.Verify__c = true;
wc2.objWCC44.Verify__c = true; 
wc2.objWCC45.Verify__c = true; 
wc2.objWCC45.Funding__c = 'Bank Loan';
wc2.objWCC45.Bank_Loan_Status__c = 'Need help to apply';
wc2.objWCC46.Verify__c = true; 
wc2.objWCC46.Delivery_of_Invoices_and_receipts__c = 'Soft copy via email and hardcopy';
wc2.objWCC47.Verify__c = true;
wc2.objWCC48.Verify__c = true;
wc2.objWCC49.Verify__c = true;
wc2.objWCC50.Verify__c = true; 
wc2.objWCC51.Verify__c = true;
wc2.objWCC52.Verify__c = true;
wc2.objWCC53.Verify__c = true;
wc2.objWCC54.Verify__c = true;
wc2.AgreementValue = 0;
wc2.objTask.ActivityDate = system.today();
wc2.objTask.ReminderDateTime = system.now();        
wc2.objWCD.Remark__c = 'Call has been accepted';
wc2.objWCD.Call_Disposion__c ='Accept';
wc2.Submit();

objPUU.Unit_Status__c= 'Welcome Call Pending';
update objPUU;

Unit__c pu = [Select Id, Name from Unit__c where Id =: objPUU.Id];
objBooking.Unit__c = pu.Id;
objBooking.Call_Disposition__c = 'Hold';
update objBooking;

Booking__c bk = [Select Id , Name from booking__c where Id =: objBooking.Id];

S_WelcomeCallController objWCC1 = new S_WelcomeCallController();
objWCC1.ProcessRowNo='0';
objWCC1.ReleaseRowNo='0';
objWCC1.AssignRowNo='0';      
objWCC1.Process();

PageReference wcPage0 = Page.S_WelcomeCallPage;
Test.setCurrentPage(wcPage0);
ApexPages.currentPage().getParameters().put('id',bk.Id);
S_WelcomeCallPageController wc0 = new S_WelcomeCallPageController();
wc0.objWCC1.Verify__c = true;
wc0.objWCC4.Verify__c = true;
wc0.objWCC6.Verify__c = true;
wc0.objWCC3.Verify__c = true;
wc0.objWCC5.Verify__c = true;
wc0.objWCC2.Verify__c = true;
wc0.objWCC36.Verify__c = true;
wc0.objWCC36.Verify__c = true;
wc0.objWCC44.Verify__c = true;
wc0.objWCC45.Funding__c = 'Self Funded';
wc0.objWCC46.Delivery_of_Invoices_and_receipts__c = 'Printed via Courier';
wc0.objWCC52.Verify__c = true;
wc0.objWCC53.Verify__c = true;
wc0.objWCC54.Verify__c = true;
wc0.objTask.ActivityDate = system.today();
wc0.objTask.ReminderDateTime = system.now();
wc0.objWCC1.Verify__c = true;
wc0.objWCC2.Verify__c = true; 
wc0.objWCC3.Verify__c = true;
wc0.objWCC4.Verify__c = true;
wc0.objWCC5.Verify__c = true;
wc0.objWCC6.Verify__c = true;
wc0.objWCC7.Verify__c = true;       
wc0.objWCC32.Verify__c = true; 
wc0.objWCC34.Verify__c = true;
wc0.objWCC35.Verify__c = true;
wc0.objWCC36.Verify__c = true;
wc0.objWCC37.Verify__c = true;
wc0.objWCC39.Verify__c = true;
wc0.objWCC40.Verify__c = true;
wc0.objWCC44.Verify__c = true; 
wc0.objWCC45.Verify__c = true;
wc0.objWCC46.Verify__c = true;
wc0.objWCC47.Verify__c = true;
wc0.objWCC48.Verify__c = true;
wc0.objWCC49.Verify__c = true;
wc0.objWCC50.Verify__c = true; 
wc0.objWCC51.Verify__c = true;
wc0.objWCC52.Verify__c = true;
wc0.objWCC53.Verify__c = true;
wc0.objWCC54.Verify__c = true;
wc0.objWCD.Call_Disposion__c ='Reject';
wc0.objopp.Reason_For_Rejection__c = 'Not mine';
wc0.Submit();
wc0.Accept();
wc0.showRejectReason();
wc0.showPopup();
wc0.closePopup();

PageReference wcrPage = Page.WelcomeCallRejectedPage;
Test.setCurrentPage(wcrPage);
ApexPages.currentPage().getParameters().put('WCHid','a1JR0000000KWW7MAO');
WelcomeCallRejectedPageController wcr = new WelcomeCallRejectedPageController();       
}*/ 
    
    @isTest
    private static void BlockTest() {
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@twgtest.com', '9876544441', false);
        Project__c objpr = new Project__c();
        objpr = createProject('Xa_prj','111');
        
        //create Clusters
        List<Cluster__c> cList = TestDataFactory.createClusters(2, objpr.Id);
        //create Tower
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        
        //create Opportunity
        Opportunity objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.Unit__c=uList[0].id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = acc.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
        Test.startTest();
        PageReference pRef = Page.BlockingPage;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('optyid',objcustomer.Id);
        ApexPages.currentPage().getParameters().put('unitId',uList[0].Id);
        ApexPages.currentPage().getParameters().put('action', 'Blocked');
        Blocking_Detail__c block = new Blocking_Detail__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(block);
        BlockingExtension be = new BlockingExtension(sc);
        be.setAccDtls();
        be.save();
        Unit__c blockedUnit = [Select Id, Customers__c,IsUnblockUnit__c from Unit__c where id= :uList[0].Id];
        
        Blocking_Detail__c blocked = TestDataFactory.createBlockRecord(objcustomer.Id, acc.Id, uList[1].Id, 'Blocked');
        PageReference pRef1 = Page.BlockingPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('unitId',uList[1].Id);
        ApexPages.currentPage().getParameters().put('action', 'Released');
        Blocking_Detail__c block1 = new Blocking_Detail__c();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(block1);
        BlockingExtension be1 = new BlockingExtension(sc1);
        be1.setAccDtls();
        be1.save();
        Blocking_Detail__c updatedBlock = [Select Id, Status__c, Opportunity__c from Blocking_Detail__c where id= :blocked.Id];
        blockedUnit.IsUnblockUnit__c = true;
        update blockedUnit;
        Test.stopTest();
    }
}