@isTest
private  Class TestCustomerDocumentClass {
 
 
 @isTest
    private static void customerDocumentTest() {
        Project__c objpr;
        Unit__c objPUU;
        
        Legal_Entity__c le =  new Legal_Entity__c();
        le.Name = 'Entity1';
        le.Account_Name_Flat_Cost__c = 'Entity1';
        le.Account_Name_Service_Tax__c = 'Entity1';
        le.Account_Number_Flat_Cost__c = 12345678;
        le.Account_Number_Service_tax__c = 987654321;
        le.RDS_Address1__c = 'Add1';
        le.Bank_Name_Flat_Cost__c = 'HDFC';
        le.CIN__c = '11223344';
        le.RDS_City__c = 'Mumbai';
        le.IFSC_Code_Flat_Cost__c = '1234456789';
        le.IFSC_Code_Service_Tax__c = '2345678956';
        le.MICR_Code_Flat_Cost__c = '12345678-09';
        le.RDS_PAN_No__c = 'AIBXK00900';
        le.RDS_Service_Tax_No__c = 'XBCVZ9001000000';
        le.RDS_Status__c = 'true';
        insert le;                
        
        objpr = new Project__c();
        objpr.Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        Cluster__c cl = new Cluster__c();
        cl.name = 'testCluster';
        cl.Project__c = objpr.id;
        insert cl;
        
        Tower__c tr = new Tower__C();
        tr.name = 'testTower';
        tr.Project__c = objpr.id;
        tr.Cluster__c = cl.id;
        insert tr;        
        
        objPUU = new Unit__c ();  
        objPUU.Name = 'TestUnit';      
        objPUU.Project__c = objpr.id;
        objPUU.Unit_Status__c ='BIP - RM Verification';
        objPUU.Tower__c = tr.id;
        objPUU.Actual_Area_value__c = 499;
        objPUU.Chargeable_Area__c = 499;
        objPUU.Active_Inactive__c = 'Active';
        objPUU.Carpet_Area__c = 333;
        objPUU.Legal_Entity__c = le.id;
        objPUU.Configuration__c = '2BHK';
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
        pl.Tower__c = tr.id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.Unit__c = objPUU.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
               
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
        
        Booking__c objBooking = new Booking__c();
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
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = objBooking.Id;
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
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        r2.Booking__c = objBooking.Id;
        insert r2;
       
        objBooking.Receipts__c = r1.id;        
        update objBooking;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Salutation__c = 'Mr.';
        ad.Name = 'TestApp1';
        ad.Applicant_Number__c = 'Primary Applicant';
        ad.Booking__c = objBooking.id;
        ad.Type_Of_Applicant__c = 'Individual Purchaser';
        ad.Subtype_Of_Applicant__c = 'UAE Resident';
        ad.Permanent_Address__c = 'Mumbai';
        ad.State__c = 'Maharashtra';
        ad.Nationality__c = 'Indian';
        ad.Mailing_Address_same_as_PermanentAddress__c = true;
        ad.Opportunity__c = objcustomer.id;
        ad.Passport_Copy__c = true;
        ad.Power_of_Attorney__c = true;
        ad.Visa_Copy__c = true;
        ad.Others__c = true;
        ad.Emirates_ID__c = true;        
        insert ad;
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Salutation__c = 'Mr.';
        ad2.Name = 'TestApp2';
        ad2.Applicant_Number__c = 'Second Applicant';
        ad2.Booking__c = objBooking.id;
        ad2.Type_Of_Applicant__c = 'Individual Purchaser';
        ad2.Subtype_Of_Applicant__c = 'Non-UAE Resident';
        ad2.Permanent_Address__c = 'Mumbai';
        ad2.State__c = 'Maharashtra';
        ad2.Nationality__c = 'Indian';
        ad2.Passport_Copy__c = true;
        ad2.Power_of_Attorney__c = true;
        ad2.National_ID__c = true;
        ad2.Non_residency_Letter__c = true;
        ad2.Others__c = true;
        insert ad2;
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Salutation__c = 'Mr.';
        ad3.Name = 'TestApp3';
        ad3.Applicant_Number__c = 'Fifth Applicant';
        ad3.Booking__c = objBooking.id;
        ad3.Type_Of_Applicant__c = 'Corporate Purchaser';
        ad3.Subtype_Of_Applicant__c = 'Companies incorporated in permitted jurisdictions';
        ad3.Permanent_Address__c = 'Mumbai';
        ad3.State__c = 'Maharashtra';
        ad3.Nationality__c = 'Indian';
        ad3.Mailing_Address_same_as_PermanentAddress__c = true;
        ad3.Opportunity__c = objcustomer.id;
        ad3.Memoradum_Articles_of_Association__c= true;
        ad3.Certificate_of_Incorporation__c = true;
        ad3.Certificate_of_Good_Standing_and_Certifi__c = true;
        ad3.Passport_Copy_of_Authorized_Signatory__c = true;
        ad3.Registration_License__c = true;
        ad3.Others__c = true;       
        insert ad3;
        
        Attachment attach = new Attachment();
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Self-attested copy of Pan Card'); 
        attach.body=bodyBlob; 
        attach.parentId=ad.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach; 
        
        Attachment attach2 = new Attachment();
        attach2.Name = 'Unit Test Attachment'; 
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment'); 
        attach2.body = bodyBlob2; 
        attach2.parentId = objcustomer.Id; 
        attach2.ContentType = 'application/msword'; 
        attach2.IsPrivate = false; 
        attach2.Description = 'Test'; 
        insert attach2; 
            
        Test.startTest();
        PageReference pRef1 = Page.CustomerDocumentPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        CustomerDocumentsControllerDubai doc1 = new CustomerDocumentsControllerDubai();
        doc1.selectedApplicant = ad2.id;
        doc1.selectedDocument = 'Passport Copy';
        doc1.blobfile = Blob.valueOf('Passport Copy'); 
        doc1.showMethod();
        doc1.Cancel();
        doc1.displayHideMethod();
        doc1.uploadFile();
        doc1.refreshMethod();
        Test.stopTest();          
     }
 }