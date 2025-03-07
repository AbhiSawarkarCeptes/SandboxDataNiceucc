@istest
public class Unit_Holds_For_SM_Cls_Test {
    
    @isTest
    private static void test1(){
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerId = recordMap.get('TOWER');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.Name='pp1';
        pp.NoofMilestones__c =22;
        pp.Tower__c = tower.id;
        insert pp;
        
        Opportunity opp1 = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp1.StageName = 'Booking confirmed';
        opp1.S_Active__c = true;
        opp1.Unit__c = unitId;
        update opp1;
        
        Quotation__c objQuote2 = new Quotation__c();        
        objQuote2.Opportunity__c = opp1.id ;
        objQuote2.Payment_Plan__c = pp.Id ;
        objQuote2.Basic_Original_PSF__c = 12;
        objQuote2.Charge1Bucket__c = 'Agreement Value';
        objQuote2.Charge2Value__c = 1123;
        insert objQuote2;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = recordMap.get('PROJECT');
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = objQuote2.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        b.Primary_Applicant_Email__c = 'test123@stetig.in';
        insert b;
        
        Opportunity opp = [SELECT Id, StageName, S_Active__c, Unit__c, Booking__c FROM Opportunity  WHERE Id = :optyId];
        opp.StageName = 'Booking confirmed';
        opp.S_Active__c = true;
        opp.Unit__c = unitId;
        opp.Booking__c = b.Id;
        update opp;
        
        Test.startTest();
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp.id ;
        objQuote1.Payment_Plan__c = pp.Id ;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        insert objQuote1;
        
        Unit__c u = [SELECT Id FROM Unit__c WHERE Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Booking__c = b.Id;
        u.Customers__c = opp.Id;
        u.Unit_Status__c='Available';
        update u;
        
        list<Account> acc1 = new list<Account>();
        Account acc = new Account();
        acc.Name ='test1';
        //acc.CurrencyIsoCode='';
        acc1.add(acc);
        insert acc1;
        
        list<Units_Hold_For_SM__c> uh1 = new list<Units_Hold_For_SM__c>();
        Units_Hold_For_SM__c uh = new Units_Hold_For_SM__c();
        uh.Payment_Type__c = 'Draft';
        uh.Unit__c = u.id;
        uh.Attachment__c= true;
        uh.index__c =1;
        uh.Sales_Manager__c = UserInfo.getUserId();
        
        uh1.add(uh);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standuser1@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='suman@testorg.com');
        insert u1;
        
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name='test2';
        cp.Contact_Person__c ='test3';
        cp.Sales_Manager__c = u1.Id;
        cp.Channel_Relationship_Manager__c =u1.id;      
        insert cp;
        
        Sobha_Connect__c sc = new Sobha_Connect__c();
        sc.Email_Id__c= 'xyz@gmail.com';
        insert sc;
        
        Blob b1 = Blob.valueOf('Test Data');
        
        Attachment attachment = new Attachment();
        attachment.ParentId = u.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b1;
        
        insert(attachment);
        
        Unit_Holds_For_SM_Cls.Value valueddata = new Unit_Holds_For_SM_Cls.Value();
        valueddata.Body ='testdataa';
        valueddata.ContentType='testcontent';
        valueddata.Name ='testname';
        valueddata.parentID ='testmyname';
        list<Unit_Holds_For_SM_Cls.Value> valueddataList = new List<Unit_Holds_For_SM_Cls.Value>();
        valueddataList.add(valueddata);
        
        Map<String,List<Unit_Holds_For_SM_Cls.Value>> temp = new Map<String,List<Unit_Holds_For_SM_Cls.Value>>();
        temp.put('1',valueddataList);
        String jsonStr = JSON.serialize(temp);
        
        Unit_Holds_For_SM_Cls.saveAccountList(uh1,'test',jsonStr,'test','test','test','test','test','test','test');
        
        Unit_Holds_For_SM_Cls.getOtherTwoFields(cp.id, 'Channel_Partner__c');
        Unit_Holds_For_SM_Cls.getOtherTwoFields(sc.id, 'Sobha_Connect__c');
        Unit_Holds_For_SM_Cls.getOtherTwoFields(u.id, 'Unit__c');
        
        Unit_Holds_For_SM_Cls.getCurrencyPicklistValues();
        Unit_Holds_For_SM_Cls.getUserRole();
        Unit_Holds_For_SM_Cls.unlockUnitHold(u.id);
        Unit_Holds_For_SM_Cls.updateSM(uh1[0].id,UserInfo.getUserId());

        Test.stopTest();
        
    }
}