@isTest
public class TestPreRegistration{
    
    @isTest
    public static void testPreRegistration(){
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        
        Tower__c tow = [SELECT Id, RDS_Company_Code__c, Address__c FROM Tower__c WHERE Id =:towerId];
        tow.RDS_Company_Code__c = recordMap.get('LEGAL ENTITY');
        tow.Address__c = 'Dubai'; 
        update tow;
        
        Quotation__c quote = new Quotation__c();        
        quote.Opportunity__c = optyId;
        quote.Payment_Plan__c = recordMap.get('PLAN');
        quote.Unit__c = unitId;
        quote.Basic_Original_PSF__c = 12;
        quote.Charge1Bucket__c = 'Agreement Value';
        quote.Charge1Name__c = 'Basic';
        quote.Charge1Value__c = 1123;
        quote.Charge2Bucket__c = 'Agreement Value';
        quote.Charge2Name__c = 'Floor Rise';
        quote.Charge2Value__c = 1123;
        
        quote.Charge3Bucket__c = 'Agreement Value';
        quote.Charge3Name__c = 'PLC';
        quote.Charge3Value__c = 1123;
        
        quote.Charge4Bucket__c = 'Other Charges';
        quote.Charge4Name__c = 'test';
        quote.Charge4Value__c = 1123;
        quote.Final_Approved_Date__c = System.today();
        insert quote;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote.Id;
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
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-200);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'test@sobharealty.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Cluster__c = 'GREENS - PHASE I';
        b.Is_Booking_Form_Attached__c = true;
        
        insert b;
        
        Account_Master__c AM = new Account_Master__c();
        AM.Name='Pre registration Payable';
        AM.Account_Number__c ='1245678';
        AM.Type__c='Others';
        AM.Tax_Rate__c ='OUT OF SCOPE';
        insert AM;
        
        Account_Master__c AM1 = new Account_Master__c();
        AM1.Name='Vat Out of Scope';
        AM1.Account_Number__c ='12456790';
        AM1.Type__c='Others';
        AM1.Tax_Rate__c ='OUT OF SCOPE';
        insert AM1;
        
        Account_Master__c AM2 = new Account_Master__c();
        AM2.Name='Trade Receivable';
        AM2.Account_Number__c ='1245666';
        AM2.Type__c='Others';
        AM2.Tax_Rate__c ='OUT OF SCOPE';
        insert AM2;
        
        Demand__c d = new Demand__c();
        d.Milestone_Name__c ='DLD Charges';
        d.Debit_Type__c ='DLD Charges';
        d.Booking__c=b.id;
        d.Total_Amount_Account__c =AM1.id;
        d.Total_Amount_with_Tax_Account__c=AM.id;
        d.Total_Amount_Demanded__c=19500;
        insert d;
        
        Booking__c b2 = new Booking__c();
        b2.Booking_Date__c = system.now().addDays(-200);
        b2.Project__c = projectId;
        b2.Opportunity__c = optyId;
        b2.Unit__c = unitId;
        b2.status__c = 'Processed';
        b2.Quotation__c = quote.Id;
        b2.Primary_Applicant_Email__c = 'test@sobharealty.comalli';
        b2.Future_Correspondence_Contact__c = 'First Applicant';
        b2.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b2.Cluster__c = 'Waves';
        b2.Is_Booking_Form_Attached__c = true;  
        insert b2;
        
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Project Statements Document - CVR',
            PathOnClient = 'Project Statements Document - CVR.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
     
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Booking Form',
            PathOnClient = 'Booking Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title =:contentVersion2.Title];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b.id;
        cd2.ContentDocumentId = documents2[0].Id;
        cd2.shareType = 'V';
        insert cd2;
        
        //create contentdocumentLink record
        ContentVersion contentVersion4 = new ContentVersion(
            Title = 'WAVES PROJECT STATEMENT-FINAL',
            PathOnClient = 'WAVES PROJECT STATEMENT-FINAL.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion4;    
        List<ContentDocument> documents4 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE title=:'WAVES PROJECT STATEMENT-FINAL'];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd4 = New ContentDocumentLink();
        cd4.LinkedEntityId = b2.id;
        cd4.ContentDocumentId = documents4[0].Id;
        cd4.shareType = 'V';
        insert cd4;
        
        Test.startTest();
        List <Booking__c> bookList = [SELECT Id FROM Booking__c];
        List <Id> bookId = new List <Id>();
        bookId.add(bookList[0].Id);
        
        //// For preRegistrationProcess
        preRegistrationProcess.getPaymentMilestones(bookId);
        
        //// For PreRegistrationNoticeController        
        PageReference pRef = Page.PreRegistrationNotice;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        PreRegistrationNoticeController pr = new PreRegistrationNoticeController();
        //For N_N_WelcomeLetterPDFController added by vamsi   
        PageReference pRef1 = Page.N_WelcomeLetterPDF;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        N_WelcomeLetterPDFController pr1 = new N_WelcomeLetterPDFController();
        Test.stopTest();
    }
    //For CompletionNoticeController added by vamsi   
    /*   PageReference pRef2 = Page.CompletionNoticevfpage;
Test.setCurrentPage(pRef1);
ApexPages.currentPage().getParameters().put('Id', b.Id);
CompletionNoticeController pr2 = new CompletionNoticeController();
Test.stopTest();
} */
    
    @isTest
    public static void testPreRegistration1(){
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        
        Tower__c tow = [SELECT Id, RDS_Company_Code__c, Address__c FROM Tower__c WHERE Id =:towerId];
        tow.RDS_Company_Code__c = recordMap.get('LEGAL ENTITY');
        tow.Address__c = 'Dubai'; 
        update tow;
        
        Quotation__c quote = new Quotation__c();        
        quote.Opportunity__c = optyId;
        quote.Payment_Plan__c = recordMap.get('PLAN');
        quote.Unit__c = unitId;
        quote.Basic_Original_PSF__c = 12;
        quote.Charge1Bucket__c = 'Agreement Value';
        quote.Charge1Name__c = 'Basic';
        quote.Charge1Value__c = 1123;
        quote.Charge2Bucket__c = 'Agreement Value';
        quote.Charge2Name__c = 'Floor Rise';
        quote.Charge2Value__c = 1123;
        
        quote.Charge3Bucket__c = 'Agreement Value';
        quote.Charge3Name__c = 'PLC';
        quote.Charge3Value__c = 1123;
        
        quote.Charge4Bucket__c = 'Other Charges';
        quote.Charge4Name__c = 'test';
        quote.Charge4Value__c = 1123;
        quote.Final_Approved_Date__c = System.today();
        insert quote;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote.Id;
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
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-200);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'test@sobharealty.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Cluster__c = 'Waves Grande';
        b.Is_Booking_Form_Attached__c = true;
        
        insert b;
        
        Account_Master__c AM = new Account_Master__c();
        AM.Name='Pre registration Payable';
        AM.Account_Number__c ='1245678';
        AM.Type__c='Others';
        AM.Tax_Rate__c ='OUT OF SCOPE';
        insert AM;
        
        Account_Master__c AM1 = new Account_Master__c();
        AM1.Name='Vat Out of Scope';
        AM1.Account_Number__c ='12456790';
        AM1.Type__c='Others';
        AM1.Tax_Rate__c ='OUT OF SCOPE';
        insert AM1;
        
        Account_Master__c AM2 = new Account_Master__c();
        AM2.Name='Trade Receivable';
        AM2.Account_Number__c ='1245666';
        AM2.Type__c='Others';
        AM2.Tax_Rate__c ='OUT OF SCOPE';
        insert AM2;
        
        Demand__c d = new Demand__c();
        d.Milestone_Name__c ='DLD Charges';
        d.Debit_Type__c ='DLD Charges';
        d.Booking__c=b.id;
        d.Total_Amount_Account__c =AM1.id;
        d.Total_Amount_with_Tax_Account__c=AM.id;
        d.Total_Amount_Demanded__c=19500;
        insert d;
        
       
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Project Statement - Waves Grande',
            PathOnClient = 'Project Statement - Waves Grande.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
     
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Booking Form',
            PathOnClient = 'Booking Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title =:contentVersion2.Title];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b.id;
        cd2.ContentDocumentId = documents2[0].Id;
        cd2.shareType = 'V';
        insert cd2;
        
        //create contentdocumentLink record
        ContentVersion contentVersion4 = new ContentVersion(
            Title = 'WAVES PROJECT STATEMENT-FINAL',
            PathOnClient = 'WAVES PROJECT STATEMENT-FINAL.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion4;    
        List<ContentDocument> documents4 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE title=:'WAVES PROJECT STATEMENT-FINAL'];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd4 = New ContentDocumentLink();
        cd4.LinkedEntityId = b.id;
        cd4.ContentDocumentId = documents4[0].Id;
        cd4.shareType = 'V';
        insert cd4;
        
        Test.startTest();
        List <Booking__c> bookList = [SELECT Id FROM Booking__c];
        List <Id> bookId = new List <Id>();
        bookId.add(bookList[0].Id);
        
        //// For preRegistrationProcess
        preRegistrationProcess.getPaymentMilestones(bookId);
        
        //// For PreRegistrationNoticeController        
        PageReference pRef = Page.PreRegistrationNotice;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        PreRegistrationNoticeController pr = new PreRegistrationNoticeController();
        //For N_N_WelcomeLetterPDFController added by vamsi   
        PageReference pRef1 = Page.N_WelcomeLetterPDF;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        N_WelcomeLetterPDFController pr1 = new N_WelcomeLetterPDFController();
        Test.stopTest();
    }
    
    @isTest
    public static void testPreRegistration2(){
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        Id projectId = recordMap.get('PROJECT');
        
        Tower__c tow = [SELECT Id, RDS_Company_Code__c, Address__c FROM Tower__c WHERE Id =:towerId];
        tow.RDS_Company_Code__c = recordMap.get('LEGAL ENTITY');
        tow.Address__c = 'Dubai'; 
        update tow;
        
        Quotation__c quote = new Quotation__c();        
        quote.Opportunity__c = optyId;
        quote.Payment_Plan__c = recordMap.get('PLAN');
        quote.Unit__c = unitId;
        quote.Basic_Original_PSF__c = 12;
        quote.Charge1Bucket__c = 'Agreement Value';
        quote.Charge1Name__c = 'Basic';
        quote.Charge1Value__c = 1123;
        quote.Charge2Bucket__c = 'Agreement Value';
        quote.Charge2Name__c = 'Floor Rise';
        quote.Charge2Value__c = 1123;
        
        quote.Charge3Bucket__c = 'Agreement Value';
        quote.Charge3Name__c = 'PLC';
        quote.Charge3Value__c = 1123;
        
        quote.Charge4Bucket__c = 'Other Charges';
        quote.Charge4Name__c = 'test';
        quote.Charge4Value__c = 1123;
        quote.Final_Approved_Date__c = System.today();
        insert quote;
        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Charge1Percentage__c = 1;
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote.Id;
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
        
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-200);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'test@sobharealty.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Cluster__c = 'One Park Avenue';
        b.Is_Booking_Form_Attached__c = true;
        
        insert b;
        
        Account_Master__c AM = new Account_Master__c();
        AM.Name='Pre registration Payable';
        AM.Account_Number__c ='1245678';
        AM.Type__c='Others';
        AM.Tax_Rate__c ='OUT OF SCOPE';
        insert AM;
        
        Account_Master__c AM1 = new Account_Master__c();
        AM1.Name='Vat Out of Scope';
        AM1.Account_Number__c ='12456790';
        AM1.Type__c='Others';
        AM1.Tax_Rate__c ='OUT OF SCOPE';
        insert AM1;
        
        Account_Master__c AM2 = new Account_Master__c();
        AM2.Name='Trade Receivable';
        AM2.Account_Number__c ='1245666';
        AM2.Type__c='Others';
        AM2.Tax_Rate__c ='OUT OF SCOPE';
        insert AM2;
        
        Demand__c d = new Demand__c();
        d.Milestone_Name__c ='DLD Charges';
        d.Debit_Type__c ='DLD Charges';
        d.Booking__c=b.id;
        d.Total_Amount_Account__c =AM1.id;
        d.Total_Amount_with_Tax_Account__c=AM.id;
        d.Total_Amount_Demanded__c=19500;
        insert d;
        
       
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Project Statement - Waves Grande',
            PathOnClient = 'Project Statement - Waves Grande.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd1 = New ContentDocumentLink();
        cd1.LinkedEntityId = b.id;
        cd1.ContentDocumentId = documents1[0].Id;
        cd1.shareType = 'V';
        insert cd1;
     
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Booking Form',
            PathOnClient = 'Booking Form.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title =:contentVersion2.Title];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = b.id;
        cd2.ContentDocumentId = documents2[0].Id;
        cd2.shareType = 'V';
        insert cd2;
        
        //create contentdocumentLink record
        ContentVersion contentVersion4 = new ContentVersion(
            Title = 'OPA - Project Statements',
            PathOnClient = 'WAVES PROJECT STATEMENT-FINAL.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion4;    
        List<ContentDocument> documents4 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE title=:'OPA - Project Statements'];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cd4 = New ContentDocumentLink();
        cd4.LinkedEntityId = b.id;
        cd4.ContentDocumentId = documents4[0].Id;
        cd4.shareType = 'V';
        insert cd4;
        
        Test.startTest();
        List <Booking__c> bookList = [SELECT Id FROM Booking__c];
        List <Id> bookId = new List <Id>();
        bookId.add(bookList[0].Id);
        
        //// For preRegistrationProcess
        preRegistrationProcess.getPaymentMilestones(bookId);
        
        //// For PreRegistrationNoticeController        
        PageReference pRef = Page.PreRegistrationNotice;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        PreRegistrationNoticeController pr = new PreRegistrationNoticeController();
        //For N_N_WelcomeLetterPDFController added by vamsi   
        PageReference pRef1 = Page.N_WelcomeLetterPDF;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('Id', b.Id);
        N_WelcomeLetterPDFController pr1 = new N_WelcomeLetterPDFController();
        Test.stopTest();
    }
    
    
    
    
}