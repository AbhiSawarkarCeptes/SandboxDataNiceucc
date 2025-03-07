@isTest
public class TestFinalTerminationNoticeController {
    @isTest
    public static void finalTerminationNoticeTest(){
        
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
        b.Booking_Date__c = system.now().addDays(-10);
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
            Title = 'Final Notice Signed',
            PathOnClient = 'Final Notice Signed.pdf',
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
        List<Booking__c> bookingList = new List<Booking__c>();
        bookingList.add(b);
        Test.startTest();  
        FinalTerminationNoticeController.sendAttachNotice(bookingList);     
        Test.stopTest();
    }

}