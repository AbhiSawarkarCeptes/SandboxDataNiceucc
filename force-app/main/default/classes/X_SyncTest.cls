@isTest public class X_SyncTest {
    static Id oppId;
    static Id unitId;
    static Id towerid;
    static Id projectid;
    static Applicant_Details__c ad1;
    static Demand__c d;
    
    static void createData(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject(('P'+Crypto.getRandomLong()).substring(0,5));
        oppId = recordMap.get('OPPORTUNITY'); 
        unitId = recordMap.get('UNIT');
        towerid = recordMap.get('TOWER');
        projectid = recordMap.get('PROJECT');
        
        Quotation__c quote = new Quotation__c();        
        quote.Opportunity__c = oppId ;
        quote.Payment_Plan__c = recordMap.get('PLAN') ;
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
        pm.Milestone_Due_Date__c = System.today() +2 ;
        insert pm;     
        //Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);     
        
        Account acc = new Account();
        acc.LastName = 'testName';
        insert acc;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        insert b;
        
        quote.Booking__c = b.Id;
        update quote;      
        
        Unit__c unit = [SELECT id,Name,Booking__r.Name FROM Unit__c WHERE id = :unitId];       
		
        delete [SELECT id FROM Unit__c WHERE id != :unit.Id AND Name = :unit.Name];
        
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        ad1 = new Applicant_Details__c();
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
        
        List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
        pmList = [select id,name from Payment_Milestones__c where Quotation__c =: quote.id];
        List<ProjectCharges__c> pc = new list<ProjectCharges__c>();
        pc = [select id,name from ProjectCharges__c where name ='Basic'];
        
        d = new Demand__c();
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
        d.Demand_Status__c = '';
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        insert d;
        /*
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = projectId;
        r1.Project_Unit__c = unitId;
        r1.Opportunity__c = oppId;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = false;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Amount_Rs__c = 200000;
        r1.Amount_Advanced__c = 0;
        r1.mode__c = 'Cash';
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c = b.Id;
        r1.Receipt_Status__c = 'Cleared';
        insert r1;
		*/
        //System.debug('createData() unitCount - '+[SELECT count() FROM Unit__c]);
        /*
        List<Xpedeon_Data_Dump__c> xdds = new List<Xpedeon_Data_Dump__c>();
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Customer Master',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Customer_Code__c = 'C12345',Xpedeon_Customer_Name__c = 'abc'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Project Code',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Project_Code__c = '123456'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Unit Type',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Unit_Type__c = 'Plot'));
        insert xdds;
        System.debug('createData() xdds - '+xdds);*/
    }
    
    @isTest static void testSyncScheduler(){
        Test.startTest();
        createData();
        System.schedule('Xpedeon Data Sync','0 0 18 * * ?',new X_SyncScheduler());
        Test.stopTest();
    }
    
    @isTest static void testSyncSchedulerBatch(){
        Test.startTest();
        createData();
        System.schedule('Xpedeon Data Sync','0 0 18 * * ?',new X_SyncScheduler(new X_SyncBatch(new List<Integer>{1,2,3,4,5,6})));
        Test.stopTest();
    }
    
    @isTest static void testSyncBatch(){
        Test.startTest();
        createData();
        insert new List<Xpedeon_Sync_Delegate__c>{
            new Xpedeon_Sync_Delegate__c(Tower__c = towerId,Sync_Status__c = 'Ready',Sequence_Number__c = 1),
                new Xpedeon_Sync_Delegate__c(Unit__c = unitId,Sync_Status__c = 'Ready',Sequence_Number__c = 2),
                new Xpedeon_Sync_Delegate__c(Applicant_Details__c = ad1.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 3),
                new Xpedeon_Sync_Delegate__c(Demand__c = d.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 4)
        };
        X_SyncBatch xs = new X_SyncBatch(new List<Id>());
        xs = new X_SyncBatch(new Set<Id>());
        xs = new X_SyncBatch();
        Database.BatchableContext dbc;
        xs.start(dbc);
        xs.execute(dbc,[SELECT id,Tower__c,Unit__c,Applicant_Details__c,Demand__c FROM Xpedeon_Sync_Delegate__c]);
        xs.finish(dbc);
        Test.stopTest();
    }
    
    @isTest static void testSyncService(){
        Test.startTest();
        createData();
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>{
            //new Xpedeon_Sync_Delegate__c(Tower__c = towerId,Sync_Status__c = 'Ready',Sequence_Number__c = 1),
                //new Xpedeon_Sync_Delegate__c(Unit__c = unitId,Sync_Status__c = 'Ready',Sequence_Number__c = 2),
                new Xpedeon_Sync_Delegate__c(Applicant_Details__c = ad1.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 3),
                new Xpedeon_Sync_Delegate__c(Demand__c = d.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 4)
                //new Xpedeon_Sync_Delegate__c(Demand__c = d.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 6)
        };
            insert xsds;
        
        for(Xpedeon_Sync_Delegate__c xsd : xsds){
            
            
            //Id sourceRecordId = String.isNotBlank(xsd.Tower__c) ? xsd.Tower__c : String.isNotBlank(xsd.Unit__c) ? xsd.Unit__c : String.isNotBlank(xsd.Applicant_Details__c) ? xsd.Applicant_Details__c : String.isNotBlank(xsd.Demand__c) ? xsd.Demand__c : String.isNotBlank(xsd.Payment_Request__c) ? xsd.Payment_Request__c : String.isNotBlank(xsd.Receipt__c) ? xsd.Receipt__c : NULL;
            Id sourceRecordId;
            if(String.isNotBlank(xsd.Tower__c)){
                sourceRecordId = xsd.Tower__c;
            }else if(String.isNotBlank(xsd.Unit__c)){
                sourceRecordId = xsd.Unit__c;
            }else if(String.isNotBlank(xsd.Applicant_Details__c)){
                sourceRecordId = xsd.Applicant_Details__c;
            }else if(String.isNotBlank(xsd.Demand__c)){
                sourceRecordId = xsd.Demand__c;
            }else if(String.isNotBlank(xsd.Payment_Request__c)){
                sourceRecordId = xsd.Payment_Request__c;
            }else if(String.isNotBlank(xsd.Receipt__c)){
                sourceRecordId = xsd.Receipt__c;
            }
            
            if(String.isBlank(sourceRecordId)) continue;
            X_Service service = new X_Service(new X_Service.X_APIData(sourceRecordId,'POST',xsd.Id)); 
            Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
            service.sync();
        }
        Test.stopTest();
    }
    
    @isTest static void testSyncServiceSequenceNumbers(){
        Test.startTest();
        createData();
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>{
            //new Xpedeon_Sync_Delegate__c(Tower__c = towerId,Sync_Status__c = 'Ready',Sequence_Number__c = 1),
                //new Xpedeon_Sync_Delegate__c(Unit__c = unitId,Sync_Status__c = 'Ready',Sequence_Number__c = 2),
                new Xpedeon_Sync_Delegate__c(Applicant_Details__c = ad1.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 3),
                new Xpedeon_Sync_Delegate__c(Demand__c = d.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 4)
                //new Xpedeon_Sync_Delegate__c(Demand__c = d.Id,Sync_Status__c = 'Ready',Sequence_Number__c = 6)
        };
            insert xsds;
        
        for(Xpedeon_Sync_Delegate__c xsd : xsds){
            
            
            //Id sourceRecordId = String.isNotBlank(xsd.Tower__c) ? xsd.Tower__c : String.isNotBlank(xsd.Unit__c) ? xsd.Unit__c : String.isNotBlank(xsd.Applicant_Details__c) ? xsd.Applicant_Details__c : String.isNotBlank(xsd.Demand__c) ? xsd.Demand__c : String.isNotBlank(xsd.Payment_Request__c) ? xsd.Payment_Request__c : String.isNotBlank(xsd.Receipt__c) ? xsd.Receipt__c : NULL;
            Id sourceRecordId;
            if(String.isNotBlank(xsd.Tower__c)){
                sourceRecordId = xsd.Tower__c;
            }else if(String.isNotBlank(xsd.Unit__c)){
                sourceRecordId = xsd.Unit__c;
            }else if(String.isNotBlank(xsd.Applicant_Details__c)){
                sourceRecordId = xsd.Applicant_Details__c;
            }else if(String.isNotBlank(xsd.Demand__c)){
                sourceRecordId = xsd.Demand__c;
            }else if(String.isNotBlank(xsd.Payment_Request__c)){
                sourceRecordId = xsd.Payment_Request__c;
            }else if(String.isNotBlank(xsd.Receipt__c)){
                sourceRecordId = xsd.Receipt__c;
            }
            
            Database.BatchableContext bc;
            X_SyncBatch xsb = new X_SyncBatch(new Set<Integer>{1,2,3,4,5,6});
			xsb.start(bc);
            if(String.isBlank(sourceRecordId)) continue;
            X_Service service = new X_Service(new X_Service.X_APIData(sourceRecordId,'POST',xsd.Id)); 
            Test.setMock(HttpCalloutMock.class, new X_MockData.MockHttpResponseGenerator());
            service.sync();
        }
        Test.stopTest();
    }
}