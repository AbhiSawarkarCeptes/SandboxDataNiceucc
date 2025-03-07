@isTest
public class SendHandoverNoticeBatchTest {

    @isTest
    static void testSendHandoverNoticeBatch(){
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');    
            
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Unit__c objPUU;
        Unit__c objPUU1;
        Car_Park__c objCP1;
        Car_Park__c objCP2;
            
        Opportunity opp1 = new Opportunity();
           opp1.Name= 'test';
            opp1.StageName='Qualification';
            opp1.CloseDate=System.Today();
            insert opp1;
        
        objpr = new Project__c();
        //objpr = createProject('Xa_prj','111');
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
        
        Tower__c t1 = new Tower__c(Name = TowerName__mdt.getInstance('Tower').TowerName__c);
        insert t1;
         
        Quotation__c q = new Quotation__c();
        q.Quote_Status__c = 'Valid';
        q.Payment_Plan__c = pl.id;
        //q.Unit__c = objPUU.Id;
        q.Opportunity__c = opp1.Id;
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
        
        objPUU = new Unit__c();  
        List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, objpr.Id);
        objPUU = uList[0];       
            
        objPUU1 = new Unit__c();  
        objPUU1 = uList[1];       
                              
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        /////////////// Added by Neha on 21/1/19 Starts Here  
        String p = 'System Administrator';
        Profile pro = [SELECT Name, Id FROM PROFILE WHERE Name = :p];  
        
       // User u = [SELECT Id FROM User WHERE UserName LIKE '%ankur.pd@stetig.in%'];
        
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
        //u1.ManagerId = u.Id;        
        insert u1; 
         
        Unit__c unit = new Unit__c(Name='test unit') ;
        unit.Unit_Status__c ='Available';  
        unit.Customers__c = opp1.id;
        insert unit;
            
        Booking__c bks = new Booking__C();
        //bks.Opportunity__c = objcustomer11.Id;
        bks.Quotation__c = q.Id;
        bks.Booking_Date__c = System.Today();
        bks.Agreement_Value__c = 3000000;
        bks.PCC_Rejection_Comments__c = 'booking';
        //bks.PCC_Rejection_Comments__c = 'Rejected';
        //bks.PCC_Status__c ='Rejected';
        bks.Tower__c = t1.Id;
        bks.Handover_Date__c  = date.valueOf(handoverDate__mdt.getInstance('handoverDate').handoverDate__c);
        bks.Unit__c = unitId;  
        bks.PCC_Status__c = 'Approved by Audit';
        bks.Rejection_Ression_for__c = 'Account';
        bks.Primary_Applicant_Email__c = 'test@test.com';
        insert bks;
          System.debug('the booking unit is--'+ bks.Unit__c);
        
         Unit__c newUnit = [Select Id, Name From Unit__c Where Id =: unitId];
         newUnit.Name ='Name Changed';
         newUnit.Booking__c	 = bks.id;
         update newUnit;
            
            
        bks.PCC_Rejection_Comments__c ='tyyuyui';
        bks.Rejection_Ression_for__c = 'Account and CRM';
        bks.Unit__c = newUnit.id;
        
        Test.startTest();
        List<Booking__c> books = [select id,Tower_Name__c, Handover_Date__c, Dewa_Number__c, Unit__c, Primary_Applicant_Email__c,Unit__r.Name, Owner.Name,Owner.Email,Unit__r.Tower__r.Name,Project__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Date_of_Completion__c,Opportunity__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Primary_Name__c, Opportunity__r.Permanent_Address__c, Opportunity__r.Primary_Phone__c, Opportunity__r.Primary_Email__c  from Booking__c];
        System.debug('books : ' + books);
        SendHandoverNoticeBatch sendHandOverNoticeBatch = new SendHandoverNoticeBatch();
        Database.executeBatch(sendHandOverNoticeBatch);
        Test.stopTest();
    }
}