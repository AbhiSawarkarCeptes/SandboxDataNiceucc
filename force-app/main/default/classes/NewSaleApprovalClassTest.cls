@isTest public class NewSaleApprovalClassTest {
    @TestSetup
    static void makeData(){
        Map<String, Id> recordIdMap = TestDataFactory.createMasterProject('Test Project');
        Id unitId = recordIdMap.get('UNIT');

        Account acc = new Account(Name='test acc');
        insert acc;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = objOpportunity.id;
        // b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';  
        b.Primary_Applicant_Email__c ='test_invalid@gmail.com';
        Test.startTest();
        insert b;
        
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man1';
        a1.Booking__c = b.Id;
        a1.Applicant_Number__c = 'Primary Applicant';
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
        Applicant_Details__c a2 = new Applicant_Details__c();
        a2.Name = 'First Man1';
        a2.Booking__c = b.Id;
        a2.Applicant_Number__c = 'Second Applicant';
        a2.DOB__c = system.today();
        a2.Permanent_Address__c = 'Pike Street, New World, 45000';
        a2.Country__c = 'India';
        a2.Mobile_Number__c = '909090903';
        a2.Email_Address__c = 'newman@justnow3.com';
        a2.Nationality__c = 'Indian';
        a2.Type_Of_Applicant__c  = 'Individual Buyer';
        a2.Subtype_Of_Applicant__c = 'Indian National';
        a2.Address_Proof__c = true;
        a2.Address_Proof_Document__c = 'xyz';
        a2.Address_Proof_Number__c = 'pqr';
        a2.One_Passport_Size_Color_Photograph__c = true;
        Applicant_Details__c a3 = new Applicant_Details__c();
        a3.Name = 'First Man1';
        a3.Booking__c = b.Id;
        a3.Applicant_Number__c = 'Third Applicant';
        a3.DOB__c = system.today();
        a3.Permanent_Address__c = 'Pike Street, New World, 45000';
        a3.Country__c = 'India';
        a3.Mobile_Number__c = '909090903';
        a3.Email_Address__c = 'newman@justnow3.com';
        a3.Nationality__c = 'Indian';
        a3.Type_Of_Applicant__c  = 'Individual Buyer';
        a3.Subtype_Of_Applicant__c = 'Indian National';
        a3.Address_Proof__c = true;
        a3.Address_Proof_Document__c = 'xyz';
        a3.Address_Proof_Number__c = 'pqr';
        a3.One_Passport_Size_Color_Photograph__c = true;
        insert new List<Applicant_Details__c>{a1,a2,a3};
            Test.stopTest();
    }
    
    @isTest public static void test1(){
        Id unitId = [select id from unit__c limit 1].id;
        Id bookingId = [select id from booking__c limit 1].id;

        Test.StartTest();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Primary Applicant - Passport Copy',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        Blacklisted_Customer__c bc = new Blacklisted_Customer__c();
        bc.Blacklisted__c = true;
        bc.Name = 'name';
        bc.From_Date__c = system.today()+5;
        insert bc;
        
        //PaymentRequestFormController.createPaymentRequest('name','email@test.com','9999999999','p12345','Cheque','AED','12345','12345',string.valueOf(system.today()),null,'1000',string.valueOf(system.today()),'UAE',1,new list<string>{unitId},'undefined','undefined','undefined','undefined','undefined',false,'','','','','','','',false,false,'Marketing#Digital','');
        Payment_Request__c pr = new payment_request__c();
        pr.unit__c = unitId;
        pr.Mode_Option__c = 'Multi Mode';
        pr.Status__c = 'Approved';
        pr.Secondary_Mode__c = 'OTC Deposits';
        pr.Sales_Manager__c = userinfo.getuserId();
        pr.Mode__c='Website';
        pr.Mobile_Number__c='9876543210';
        pr.Emirates_Id_Passport_Number__c = '12345';
        pr.Name__c = 'name';
        insert pr;
        
        unit_hold_request__c newSale = new unit_hold_request__c();
        newSale.Applicant_Name1__c='name';
        newSale.Approval_Status__c='Pending';
        newSale.payment_request__c = pr.id;
        newSale.Client_Phone_No__c = '8903823';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_123@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
        newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.Sales_Head_Value__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        newSale.dld_amount__c = 100;
        newSale.dp_amount__c = 100;
        insert newSale; 
      
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conDoc;
        contentDocumentLink.LinkedEntityId = newSale.id;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'InternalUsers';
        insert contentDocumentLink;
        newSale.booking__c = bookingId;
        update newSale;
        NewSaleApprovalClass.updatePRWithNewSaleApproval(new List<Id>{newSale.Id});
        Test.StopTest();
    }
    @isTest public static void test2()
    {
        Blacklisted_Customer__c bc = new Blacklisted_Customer__c();
        bc.Blacklisted__c = true;
        bc.Name = 'name';
        bc.From_Date__c = system.today()+5;
        insert bc;

        Test.StartTest();
        Id unitId = [select id from unit__c limit 1].id;
        Payment_Request__c pr = new payment_request__c();
        pr.unit__c = unitId;
        pr.Mode_Option__c = 'Multi Mode';
        pr.Status__c = 'Approved';
        pr.Secondary_Mode__c = 'OTC Deposits';
        pr.Sales_Manager__c = userinfo.getuserId();
        pr.Mode__c='Website';
        pr.Mobile_Number__c='9876543211';
        pr.Emirates_Id_Passport_Number__c = '12345';
        pr.Name__c = 'name';
        insert pr;
        
        unit_hold_request__c newSale = new unit_hold_request__c();
        newSale.Applicant_Name1__c='name';
        newSale.Approval_Status__c='Pending';
        newSale.payment_request__c = pr.id;
        newSale.Client_Phone_No__c = '89038231';
        newSale.Client_Address__c ='test address';
        newSale.Deal_Type_Wholesale_Retail__c ='Retail';
        newSale.Client_E_mail_Address__c ='test_1234@gmail.com';
        newSale.Agent_Name__c ='test agent name';
        newSale.Remarks_If_Any__c ='test';
        newSale.Discount_from_Sobha_If_Applicable__c = 10;
        newSale.Sales_Head_VP__c = UserInfo.getUserId();
        newSale.Sales_Head_Value__c = UserInfo.getUserId();
        newSale.How_Many_Applicants__c = 'One Applicant';
        newSale.dld_amount__c = 200;
        newSale.dp_amount__c = 200;
        insert newSale;
        Opportunity opp = [Select Id from Opportunity Limit 1];
        unit_hold_request__c  newSale1 = [Select Id,Opportunity__c from unit_hold_request__c Limit 1];
        newSale1.Opportunity__c=opp.Id;
        update newSale1;
        Test.StopTest();
    }
}