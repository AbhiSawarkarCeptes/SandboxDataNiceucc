@isTest
public class TestTeleSalesCTI {
    @isTest public static void testTeleSalesCTIInboundAPI_Positive() {
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.Email = 'test@test.com';
        l.MobilePhone = '971502083945';
        l.Presales_Agent__c = UserInfo.getUserId();
        l.ownerID = UserInfo.getUserId();
        insert l;
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTIInboundAPIMock());  
        TeleSalesCTIInboundAPI.CTIInboundWrapper strResp = TeleSalesCTIInboundAPI.doPost();
    }
    
    @isTest public static void testTeleSalesCTIInboundAPI_Negative() {
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTIInboundAPIMock());  
        TeleSalesCTIInboundAPI.CTIInboundWrapper strResp = TeleSalesCTIInboundAPI.doPost();
    }
    
    @isTest public static void testTeleSalesCTICDRAPI_Positive() {
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.Email = 'test@test.com';
        l.MobilePhone = '971502083945';
        l.Presales_Agent__c = UserInfo.getUserId();
        l.ownerID = UserInfo.getUserId();
        insert l;
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTICDRAPIMock());  
        TeleSalesCTICDRAPI.CTICDRAPIWrapper strResp = TeleSalesCTICDRAPI.doPost();
    }
    
    @isTest public static void testTeleSalesCTICDRAPI_Negative() {
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTICDRAPIMock());  
        TeleSalesCTICDRAPI.CTICDRAPIWrapper strResp = TeleSalesCTICDRAPI.doPost();
    }
    
    @isTest public static void testTeleSalesCTIMissCallAPI_Positive() {
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.Email = 'test@test.com';
        l.MobilePhone = '971502083945';
        l.Presales_Agent__c = UserInfo.getUserId();
        l.ownerID = UserInfo.getUserId();
        insert l;
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTIMissCallAPIMock());  
        TeleSalesCTIMissCallAPI.CTIMissedCalldWrapper strResp = TeleSalesCTIMissCallAPI.doPost();
    }
    
    @isTest public static void testTeleSalesCTIMissCallAPI_Negative() {
        Test.setMock(HttpCalloutMock.class, new TeleSalesCTIMissCallAPIMock());  
        TeleSalesCTIMissCallAPI.CTIMissedCalldWrapper strResp = TeleSalesCTIMissCallAPI.doPost();
    }
    
    @isTest public static void testTeleSalesAgentExtensionSearch_Positive() {
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.Email = 'test@test.com';
        l.MobilePhone = '971502083945';
        l.Presales_Agent__c = UserInfo.getUserId();
        l.ownerID = UserInfo.getUserId();
        insert l;
        Test.setMock(HttpCalloutMock.class, new TeleSalesAgentExtensionSearchMock());  
        TeleSalesAgentExtensionSearch.CTIInboundWrapper strResp = TeleSalesAgentExtensionSearch.doGet();
    }
    
    @isTest public static void testTeleSalesAgentExtensionSearch_Negative() {
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Account acc = new Account(Name='test acc');
        insert acc;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = acc.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.Other_Applicants_Email__c = 'test1233337new0@gmail.com';
        objOpportunity.Other_Applicants_Name__c =' Test New';
        insert objOpportunity;
        TeleSalesUtil.createTeleSalesAPILogs('','','','','','');
        TeleSalesUtil.createTask(objOpportunity.Id,'');
        TeleSalesUtil.createTaskOnAccount(acc.Id,'');
        Test.setMock(HttpCalloutMock.class, new TeleSalesAgentExtensionSearchMock());  
        TeleSalesAgentExtensionSearch.CTIInboundWrapper strResp = TeleSalesAgentExtensionSearch.doGet();
    }
}