@isTest
private  Class TestDemands {
    
    @isTest
    private static void demands() {
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Stage_of_Booking__c = 'Booked';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;  
        b.PCC_Status__c = 'Pending for Audit Approval';
        insert b; 
        
        quote.Booking__c = b.Id;
        update quote;      
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = projectId ;
        objRec.Opportunity__c = optyId;
        objRec.Project_Unit__c = unitId;
        objRec.Booking__c = b.Id; // Neha
        objRec.Receipt_No_Manual__c = '12';
        objRec.Receipt_Status__c = 'Processed';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Total_Amount__c = 100;
        objRec.Manual_Receipt_Date__c = System.today();
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec; 
        
        b.Receipts__c = objRec.id;
        update b;
        
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId ;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = optyId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 8400;
        r2.Booking__c = b.Id; // Neha
        insert r2;    
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        /*Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r2.id;       
        insert fr1;*/
        Test.startTest();
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = b.Id;
        applicantDetailsList.add(ad1);
        //insert ad1;
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = b.Id;
        applicantDetailsList.add(ad2);
        //insert ad2;
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = b.Id;
        applicantDetailsList.add(ad3);
        //insert ad3;
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = b.Id;
        applicantDetailsList.add(ad4);
        //insert ad4;
        
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
        ad5.Booking__c = b.Id;
        applicantDetailsList.add(ad5);
        insert applicantDetailsList;
        
        quote.Booking__c = b.Id;
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        update o;
        
        pm.Collection_Status__c = 'Submitted';
        pm.Finance_Status__c = 'Accepted';
        pm.Audit_Status__c = 'Accepted';
        pm.CFO_Status__c = 'Accepted';
        update pm;
        
        
        PageReference SendDemand = Page.SendDemand;
        Test.setCurrentPage(SendDemand);
        Demands d = new Demands();
        
        ApexPages.currentPage().getParameters().put('towerName','Sobha');
        ApexPages.currentPage().getParameters().put('projectName',tower.Name);
        d.getCustomersTowerWise();
        d.sUnit = u.Name;
        d.narrowResults();
        d.Customername = o.Name;
        d.quickSearch();
        //d.raiseMultipleDemands();
        d.groupDemandPreviewId = u.Id;
        PageReference previewPage = d.showPreview();
        Test.setCurrentPage(previewPage);
        //DemandView dView = new DemandView();
        d.raiseGroupDemand();
        //   PageReference calInterst = Page.CalculateInterest;
        //   Test.setCurrentPage(calInterst);
        //   ApexPages.currentPage().getParameters().put('id',b.id);
        //  calculateInterest cI = new calculateInterest();
        //  cI.calculateInterest();
        Test.stopTest();           
    }
    
    @isTest
    private static void demands1() {
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);        
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
        pm.Collection_Status__c = 'Submitted';
        pm.Finance_Status__c = 'Accepted';
        pm.Audit_Status__c = 'Accepted';
        pm.CFO_Status__c = 'Accepted';       
        update pm;      
        
        pm.Charge_1_Lookup__c = projCharges;
        update pm;     
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId ;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.PCC_Status__c = 'Rejected by Accounts';
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = optyId;
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
        
        b.Receipts__c = r1.id;
        
        update b;
        
        /* Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = optyId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r2.Amount_Rs__c = 8400;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'Cheque';
        r2.Currency__c = 'Indian Rupee';
        r2.Booking__c = b.Id;
        insert r2;
        
        Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r1.id;       
        insert fr1;*/
        Test.startTest();
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
        
        quote.Booking__c = b.Id;
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        update o;       
        
        PageReference SendDemand = Page.SendDemand;
        Test.setCurrentPage(SendDemand);
        Demands d = new Demands();
        
        ApexPages.currentPage().getParameters().put('towerName',tower.Name);
        ApexPages.currentPage().getParameters().put('projectName','Sobha');
        d.getCustomersTowerWise();
        d.Beginning();
        d.Next();
        d.Previous();
        d.End();
        d.getDisablePrevious();
        d.getDisableNext();
        d.getTotal_size();
        d.getPageNumber();
        d.getTotalPages();
        d.Beginning();        
        d.groupDemandPreviewId = u.Id;
        d.singleDemandPreviewId = [Select Id, Name from Payment_Milestones__c LIMIT 1].Id;
        DemandView dView = new DemandView();
        d.raisePerMilestoneDemand();
        d.CustomerWrapperMap.get(unitId).groupSelect = true;
        
        PageReference pageRef2 = Page.SendDemandMail;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('unitId', u.Id);
        ApexPages.currentPage().getParameters().put('invoiceDueDate', system.today().format());
        ApexPages.currentPage().getParameters().put('invoiceNumber', '2502');
        ApexPages.currentPage().getParameters().put('milestoneId', d.singleDemandPreviewId);
        SendDemandMail sd = new SendDemandMail();       
        Test.stopTest();            
    }
    
    @isTest
    private static void demands2() {    
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);        
        
        //Payment_Milestones__c pm = createPaymentMilestone(quote.Id); 
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Number_Of_Days__c = 15;
        update pm1;       
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId ;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.PCC_Status__c = 'Approved by Audit';
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = optyId;
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
        
       Test.startTest();
        
        b.Receipts__c = r1.Id;
        update b;
        
        /*Finance_Report_Records__c fr1 = new Finance_Report_Records__c();
        fr1.Receipt__c=r1.id;       
        insert fr1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = optyId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r2.Amount_Rs__c = 8400;
        r2.Amount_Advanced__c = 0;
        r2.mode__c = 'Cheque';
        r2.Currency__c = 'Indian Rupee';
        r2.Booking__c = b.Id;
        insert r2;     */       
        
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
        
        quote.Booking__c = b.Id;
        update quote;
         
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        update o;
        
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        pmList = [select id,name from Payment_Milestones__c where Quotation__c =: quote.id];
        List<ProjectCharges__c> pc = new list<ProjectCharges__c>();
        pc = [select id,name from ProjectCharges__c where name ='Basic'];
        
        Demand__c d = new Demand__c();
        d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = b.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        
        insert d;
        
        d.demand_Status__c = 'Raised';
        Update d;
        
        d.demand_Status__c = 'Reversed';
        Update d;
      
        
        DemandManagementServices.getAllPreviousDemand(unitId);
        Test.stopTest(); 
        /*Receipt_Details__c rd = new Receipt_Details__c();
        rd.Status__c = 'Valid';
        rd.Transaction_Date__c = system.today();
        rd.Demand__c = d.Id;
        rd.Total_Amount_Apportined__c = 100000; 
        rd.Total_Tax_Apportioned__c = 10000;
        rd.Charges_Apportioned__c = 10000;
        rd.Taxes_Apportioned__c = 10000;
        rd.Receipts__c = r1.Id;
        rd.Interest_Amount_Paid__c = 1000;
        rd.Tax_on_Interest_Paid__c = 1000;
        rd.Interest_Amount_Waived__c = 500;
        rd.Tax_On_Interest_Waived__c = 500;
        rd.Debit_Tax_Apportioned__c = 10000;
        rd.Charge_1_Amount_Apportioned__c = 10000;
        rd.Charge_1_Tax_Apportioned__c = 1000;
        rd.Charge_2_Amount_Apportioned__c = 10000;
        rd.Charge_2_Tax_Apportioned__c = 1000;
        insert rd;
        Ledger__c lNew = new Ledger__c();
        lNew.Activity__c='Debit';
        lNew.Amount__c = 5000;
        lNew.Demand__c = d.Id;
        insert lNew;
        Test.startTest();
        List<Id> demandIdList = new List<Id>();
        List<Demand__c> demandList = [SELECT ID FROM Demand__c];
        for(Demand__c dList : demandList){
            demandIdList.add(dList.Id);
        }
        TriggerDemandHandler.cleanUpLedgersAfterReversal(demandIdList);**/
                   
    }
    @isTest
    private static void demands3() {    
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);        
        
        //Payment_Milestones__c pm = createPaymentMilestone(quote.Id); 
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Number_Of_Days__c = 15;
        update pm1;       
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId ;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.PCC_Status__c = 'Approved by Audit';
        insert b;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = optyId;
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
        //update b;
        
               
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
        
        quote.Booking__c = b.Id;
        update quote;
         
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        update o;
        
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        pmList = [select id,name from Payment_Milestones__c where Quotation__c =: quote.id];
        List<ProjectCharges__c> pc = new list<ProjectCharges__c>();
        pc = [select id,name from ProjectCharges__c where name ='Basic'];
        
        Demand__c d = new Demand__c();
        d.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = b.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        
        insert d;
        
        d.demand_Status__c = 'Raised';
        //Update d;
        
        d.demand_Status__c = 'Reversed';
        //Update d;
        
		Test.startTest();        
        /* Demand__c d1 = new Demand__c();
        d1.Payment_Milestones__c = pmList[0].id;
        d1.Quotation__c = quote.id;
        d1.Booking__c = b.id;
        d1.Invoice_Date__c = system.today();
        d1.Due_Date__c = system.today(); 
        d1.Debit_Demanded__c = 1000;
        d1.Debit_Paid__c = 20;
        d1.Debit_Type__c = 'Cheque Bounce';
        d1.Debit_Tax_Demanded__c = 100;
        d1.Debit_Tax_Paid__c = 20;
        d1.Debit_SGST__c = 50;
        d1.Agreement_Value_Paid__c=400;
        d1.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d1.Debit_CGST__c = 50;
        insert d1;
        
        d1.Demand_Status__c = 'Reversed';
        update d1;*/
        
        //DemandManagementServices.getAllPreviousDemand(unitId);
        Receipt_Details__c rd = new Receipt_Details__c();
        rd.Status__c = 'Valid';
        rd.Transaction_Date__c = system.today();
        rd.Demand__c = d.Id;
        rd.Total_Amount_Apportined__c = 100000; 
        rd.Total_Tax_Apportioned__c = 10000;
        rd.Charges_Apportioned__c = 10000;
        rd.Taxes_Apportioned__c = 10000;
        rd.Receipts__c = r1.Id;
        rd.Interest_Amount_Paid__c = 1000;
        rd.Tax_on_Interest_Paid__c = 1000;
        rd.Interest_Amount_Waived__c = 500;
        rd.Tax_On_Interest_Waived__c = 500;
        rd.Debit_Tax_Apportioned__c = 10000;
        rd.Charge_1_Amount_Apportioned__c = 10000;
        rd.Charge_1_Tax_Apportioned__c = 1000;
        rd.Charge_2_Amount_Apportioned__c = 10000;
        rd.Charge_2_Tax_Apportioned__c = 1000;
        insert rd;
        Ledger__c lNew = new Ledger__c();
        lNew.Activity__c='Debit';
        lNew.Amount__c = 5000;
        lNew.Demand__c = d.Id;
        insert lNew;
        
        List<Id> demandIdList = new List<Id>();
        List<Demand__c> demandList = [SELECT ID FROM Demand__c];
        for(Demand__c dList : demandList){
            demandIdList.add(dList.Id);
        }
        TriggerDemandHandler.cleanUpLedgersAfterReversal(demandIdList);
        Test.stopTest();            
    }
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
        
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    } 
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 10000;  
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 2475;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;                  
    }             
}