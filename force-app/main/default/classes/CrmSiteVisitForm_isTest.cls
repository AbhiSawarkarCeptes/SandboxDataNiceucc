@isTest
public class CrmSiteVisitForm_isTest {
    
    @isTest
    public static void CRMSiteVisitTest() {
        Project__c objpr;
        
        Unit__c objPUU1;
        objpr = new Project__c();
        objpr = createProject('Xa_prj2','1111');
        List<Tower__c> tList = TestDataFactory.createTowers(2, objpr.Id);
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        Payment_Plan__c pl = new  Payment_Plan__c();
        pl.name = 'Standard Plan';
        pl.Plan_Code__c = '003';
        pl.Tower__c = tList[0].id;
        pl.Project__c = objpr.id; 
        pl.NoofMilestones__c = 25;
        pl.Charge1Name__c = 'Basic';
        pl.Charge_1_Total__c = 100;
        insert pl;               
        
        opportunity objcustomer= new Opportunity();
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
        q.Unit__c = objPUU1.Id;
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
        bks.Opportunity__c = objcustomer.Id;
        bks.Quotation__c = q.Id;
        bks.Booking_Date__c = System.Today();
        bks.Agreement_Value__c = 3000000;
        insert bks;
        CRMSiteVisitController.getBookingData(bks.id,objPUU1.Id);
        //CRMSiteVisitController.getUnitData(objPUU1.Id);
        Id RecordTypeId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByDeveloperName().get('CRM_Site_Visit').getRecordTypeId();
        CRMSiteVisitController.getRecordTypeId('CRM_Site_Visit');
    }
    
     public static Project__c createProject(String ProjName, String ProjectCode){
        Project__c objProject = new Project__c(Name = ProjName, Project_Code__c = projectCode, Service_Tax_Required_On_Token_Amount__c = true);
        insert objProject;
        return objProject;
    }  

}