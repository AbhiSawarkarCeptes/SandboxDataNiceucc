@isTest
public class CompletionnoticeControllertest {
    @isTest
    public static void CompletionnoticeControllertest(){
        
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
        b.Cluster__c = 'Phase I - Building 1';
        b.Is_Booking_Form_Attached__c = true;
        
        insert b;
        
        Test.startTest();
        List <Booking__c> bookList = [SELECT Id FROM Booking__c];
        List <Id> bookId = new List <Id>();
        bookId.add(bookList[0].Id);

        // For CompletionNoticeController added by vamsi   
               
            PageReference pRef = Page.CompletionNoticevfpage;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('Id', optyId );
            CompletionNoticeController pr = new CompletionNoticeController();
            Test.stopTest();

         }   
    
}