@isTest
public class X_MasterDataLoadBatchTest {
    
    static void createData(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject(('P'+Crypto.getRandomLong()).substring(0,5));
        Id oppId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
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
        
        Unit__c unit = [SELECT id,Name,Booking__r.Name FROM Unit__c WHERE id = :unitId];       
		
        delete [SELECT id FROM Unit__c WHERE id != :unit.Id AND Name = :unit.Name];
        //System.debug('createData() unitCount - '+[SELECT count() FROM Unit__c]);
        
        List<Xpedeon_Data_Dump__c> xdds = new List<Xpedeon_Data_Dump__c>();
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Customer Master',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Customer_Code__c = 'C12345',Xpedeon_Customer_Name__c = 'abc'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Project Code',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Project_Code__c = '123456'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Unit Type',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Unit_Type__c = 'Plot'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Phase Code',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Phase_Code__c = 'qwerty'));
        xdds.add(new Xpedeon_Data_Dump__c(Job_Name__c = 'Project Code Unit',Unit_Name__c = Unit.Name,Booking_Name__c = unit.booking__r.Name,Xpedeon_Project_Code__c = 'qwerty'));
        insert xdds;
        System.debug('createData() xdds - '+xdds);
    }
    	
    @isTest
    static void runTestCM(){
        createData();
        Test.startTest();
        X_MasterDataLoadBatch.runTheBatch('Customer Master',3);
        Test.stopTest();
    }
    
    @isTest
    static void runTestPC(){
        createData();
        Test.startTest();
        X_MasterDataLoadBatch.runTheBatch('Project Code',3);
        Test.stopTest();
    }
    
    @isTest
    static void runTestUT(){
        createData();
        Test.startTest();
        X_MasterDataLoadBatch.runTheBatch('Unit Type',3);
        Test.stopTest();
    }
    
    @isTest
    static void runTestPhaseCode(){
        createData();
        Test.startTest();
        X_MasterDataLoadBatch.runTheBatch('Phase Code',3);
        Test.stopTest();
    }
    @isTest
    static void runTestProjectCodeUnit(){
        createData();
        Test.startTest();
        X_MasterDataLoadBatch.runTheBatch('Project Code Unit',3);
        Test.stopTest();
    }
}