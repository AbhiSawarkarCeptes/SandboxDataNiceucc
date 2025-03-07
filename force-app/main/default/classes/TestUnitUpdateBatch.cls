@isTest

private class TestUnitUpdateBatch{

@istest
   private static void updateUnitTest(){    
        Project__c pro; 
        List<Cluster__c> cList;
        List<Tower__c> tList;
        
        pro = TestDataFactory.createProject('Sobha_project', '123'); // create project
 
        cList = TestDataFactory.createClusters(3, pro.Id); // create cluster
       
        tList = TestDataFactory.createTowers(4, pro.Id); // create tower 
    
        Unit__c u = new Unit__c();
        u.Name = '1101';
        u.Unit_Status__c = 'Available';
        u.Configuration__c = '3 BHK';
        u.Chargeable_Area__c = 1234;
        u.Project_Property_Type__c = 'Residential';
        u.Project__c = pro.Id;
        u.Tower__c = tList[0].Id;
        u.Charge_1_Name__c = 'Basic';
        u.Charge_1_Amount__c = 123456;
        u.Charge_1_Bucket__c = 'Agreement Value';
        u.Charge_2_Name__c = 'PLC';
        u.Charge_2_Amount__c = 12345;
        u.Charge_2_Bucket__c = 'Agreement Value';
        u.Charge_3_Name__c = 'Floor Rise';
        u.Charge_3_Amount__c = 1234;
        u.Charge_3_Bucket__c = 'Agreement Value';
        u.Charge_4_Name__c = 'Knowledge Fees';
        u.Charge_4_Amount__c = 40;
        u.Charge_4_Bucket__c = 'Stamp Duty and Registration';
        u.Charge_5_Name__c = 'DLD Admin Fees';
        u.Charge_5_Amount__c = 12345;
        u.Charge_5_Bucket__c = 'Stamp Duty and Registration';
        u.Charge_6_Name__c = 'Corner Premium';
        u.Charge_6_Amount__c = 1234;
        u.Charge_6_Bucket__c = 'Agreement Value';       
        
        insert u;
        
        Test.startTest();
        UnitUpdateBatch uub = new UnitUpdateBatch();
        uub.execute(null);
        
        Test.stopTest();
    }
   }