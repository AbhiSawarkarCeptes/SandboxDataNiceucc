@isTest public class BookingUploadSignedDocumentsTest {
    @isTest public static void test1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Name__c = 'Test';
        insert b;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Booking__c = b.Id;
        ad.Applicant_Number__c = 'Primary Applicant';
        insert ad;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Primary Applicant',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents1 = [SELECT Id, LatestPublishedVersionId FROM ContentDocument];
        documents1[0].title = 'Primary Applicant';
        update documents1;
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
       
        DocumentVerificationController.getRelatedFilesByRecordId(b.Id);
        
        BookingUploadSignedDocumentsController.getApplicationDetails(b.Id);
       BookingUploadSignedDocumentsController.getApplicantDetails(ad.Id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Primary Applicant Passport Copy',ad.Id,b.id);
        DocumentVerificationController.verifyDocuments(new List<String>{'Primary Applicant Passport Copy'},b.id);
        Test.startTest(); 
       
        DocumentVerificationController.verifyDocuments(new List<String>{},b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Power of Attorney',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Visa Copy',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Others',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Emirates Id',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Non-residency Letter',ad.Id,b.id);
         
        BookingUploadSignedDocumentsController.sendEmail(b.Id, 'Booking_Form_Submitted');
        b.Signed_Status__c = 'Resubmit to Submitter';
        update b;
        BookingUploadSignedDocumentsController.sendEmail(b.Id, 'Booking_Form_Submitted_SM');

        Sobha_Settings__c sett = new Sobha_Settings__c();
        sett.SBF_Last_Used_User__c = '12345678';
        insert sett;
        //BookingUploadSignedDocumentsController.updateSBEUser(b.Id);
        Test.stopTest();
    }
    @isTest public static void test2(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Name__c = 'Test';
        insert b;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Booking__c = b.Id;
        ad.Applicant_Number__c = 'Second Applicant';
        insert ad;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        Test.startTest(); 
        BookingUploadSignedDocumentsController.getApplicationDetails(b.Id);
       BookingUploadSignedDocumentsController.getApplicantDetails(ad.Id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Second Applicant Passport Copy',ad.Id,b.id);
        DocumentVerificationController.getRelatedFilesByRecordId(b.Id);
        DocumentVerificationController.verifyDocuments(new List<String>{'Second Applicant Passport Copy'},b.id);
        DocumentVerificationController.verifyDocuments(new List<String>{'Second Applicant Power of Attorney','Second Applicant Visa Copy','Second Applicant Others','Second Applicant Emirates Id','Second Applicant Non-residency Letter'},b.id);
        
        Test.stopTest();
    }
    
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
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
    
    private static Payment_Milestones__c createPaymentMilestone(Id quote) {
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 300000000;          
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
    @isTest public static void test3(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Name__c = 'Test';
        insert b;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Booking__c = b.Id;
        ad.Applicant_Number__c = 'Primary Applicant';
        insert ad;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Primary Applicant',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents1 = [SELECT Id, LatestPublishedVersionId FROM ContentDocument];
        documents1[0].title = 'Primary Applicant';
        update documents1;
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
       
        DocumentVerificationController.getRelatedFilesByRecordId(b.Id);
        
        BookingUploadSignedDocumentsController.getApplicationDetails(b.Id);
       BookingUploadSignedDocumentsController.getApplicantDetails(ad.Id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Primary Applicant Passport Copy',ad.Id,b.id);
        Test.startTest(); 
       
        DocumentVerificationController.verifyDocuments(new List<String>{'Primary Applicant Passport Copy'},b.id);
        DocumentVerificationController.verifyDocuments(new List<String>{},b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Power of Attorney',ad.Id,b.id);
         BookingUploadSignedDocumentsController.updateContentDocumentTitle('National Id',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Registration License',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Passport Copy of Authorized Signatory',ad.Id,b.id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Certificate of Incorporation',ad.Id,b.id);
       
       Test.stopTest();
    }
    @isTest public static void test4(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC'); 
        Id towerId = recordMap.get('TOWER');
        Id clusterId = recordMap.get('CLUSTER');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        pm1.Charge_1_Lookup__c = projCharges; 
        
        List<Booking__c> bList = new List<Booking__c>();
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.Status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Current_Status__c = 'Audit Accepted';
        b.Primary_Applicant_Name__c = 'Test';
        insert b;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Booking__c = b.Id;
        ad.Applicant_Number__c = 'Primary Applicant';
        insert ad;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'Primary Applicant',
            PathOnClient   = 'pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        List<ContentDocument> documents1 = [SELECT Id, LatestPublishedVersionId FROM ContentDocument];
        documents1[0].title = 'Primary Applicant';
        update documents1;
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
       
        DocumentVerificationController.getRelatedFilesByRecordId(b.Id);
        
        BookingUploadSignedDocumentsController.getApplicationDetails(b.Id);
       BookingUploadSignedDocumentsController.getApplicantDetails(ad.Id);
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Primary Applicant Passport Copy',ad.Id,b.id);
        Test.startTest(); 
       
        BookingUploadSignedDocumentsController.updateContentDocumentTitle('Certificate of Incorporation',ad.Id,b.id);
       
        BookingUploadSignedDocumentsController.sendEmail(b.Id, 'Booking_Form_Submitted');
        b.Signed_Status__c = 'Resubmit to Submitter';
        update b;
        BookingUploadSignedDocumentsController.sendEmail(b.Id, 'Booking_Form_Submitted_SM');

        Sobha_Settings__c sett = new Sobha_Settings__c();
        sett.SBF_Last_Used_User__c = '12345678';
        insert sett;
        BookingUploadSignedDocumentsController.updateSBEUser(b.Id);
        Test.stopTest();
    }
}