@isTest
public class BrokerAccountFormExternalController_Test {
	@testsetup
    static void createData() {
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
        acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
        insert acc;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
    }
    @isTest
    static void testGetRecord() {
        Id recId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        Map<String, Object> response = BrokerAccountFormExternalController.getRecord(recId);
        List<Map<String, String>> responseFields = BrokerAccountFormExternalController.picklistValues('Account', 'Nationality__c');
        try{
           Map<String, Object> response2 = BrokerAccountFormExternalController.getRecord(null);
       		}catch(Exception e){
        }
        Test.stopTest();
   	}
    @isTest
    static void testUpdate() {
        Account rec = [SELECT Id, Name_as_per_trade_license__c,Mobile_No__c, Email_ID_1__c, Phone, Name_as_per_passport__c, Nationality__c, Designation1__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, BillingCity, Country__c, BillingPostalCode, Broker_Sub_Type__c, 
                Phone__c, Fax, Mobile__c, Email__c, RERA_Number__c,Witness_Name__c, Witness_Email__c, Registration_Link_Expiry_Date_Time__c, Broker_Created_Date__c, PropStrength__Broker_Approval_Status__c,
                Renewal_Status__c, Registration_Number__c,BillingStreet, BillingCountry, Email_ID_2__c, State_Province__c, BillingState, City_Local__c, Country_CP__c, Zip_Postal_Code_CP__c, 
                Broker_Category__c, Status__c , Name, PropStrength__Broker_Code__c,
                recordtype.Name FROM Account LIMIT 1]; 
        Test.startTest();
        rec.Name_as_per_trade_license__c = 'Trade';
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
        acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
        acc.Al_Siniya_Partner__c = true;
        acc.PropStrength__Broker_Code__c = rec.PropStrength__Broker_Code__c;
        insert acc;
       	Account result = BrokerAccountFormExternalController.updateRecord(rec);
        try{
           Map<String, Object> response2 = BrokerAccountFormExternalController.getRecord(result.Id);
       		}catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    static void testUpdate2() {
        Account rec = [SELECT Id, Name_as_per_trade_license__c,Mobile_No__c, Email_ID_1__c, Phone, Name_as_per_passport__c, Nationality__c, Designation1__c, Office_Apartment_number__c, 
                Villa_Building_name__c, Street_name__c, District_Area__c, BillingCity, Country__c, BillingPostalCode, Broker_Sub_Type__c, 
                Phone__c, Fax, Mobile__c, Email__c, RERA_Number__c,Witness_Name__c, Witness_Email__c, Registration_Link_Expiry_Date_Time__c, Broker_Created_Date__c, PropStrength__Broker_Approval_Status__c,
                Renewal_Status__c, Registration_Number__c,BillingStreet, BillingCountry, Email_ID_2__c, State_Province__c, BillingState, City_Local__c, Country_CP__c, Zip_Postal_Code_CP__c, 
                Broker_Category__c, Status__c , Name, PropStrength__Broker_Code__c,
                recordtype.Name FROM Account LIMIT 1]; 
        Test.startTest();
        rec.Name_as_per_trade_license__c = 'Trade';
       	Account result = BrokerAccountFormExternalController.updateRecord(rec);
        try{
           Map<String, Object> response2 = BrokerAccountFormExternalController.getRecord(result.Id);
       		}catch(Exception e){
        }
        Test.stopTest();
    }
    @isTest
    static void createGetDeleteDocumnet() {
        Account rec = [SELECT Id, PropStrength__Broker_Code__c FROM Account LIMIT 1];
        Test.startTest();
        try{
            Account acc = TestDataFactorySobha.createAccount(null);
            acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
            acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
            acc.Al_Siniya_Partner__c = true;
            acc.PropStrength__Broker_Code__c = rec.PropStrength__Broker_Code__c;
            insert acc;
       		String docId = BrokerAccountFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',rec.Id);
            String deleteMssg = BrokerAccountFormExternalController.deleteDocuments(new List<Id>{Id.valueOf(docId)});
            Id documentId = BrokerAccountFormExternalController.getDocID(String.valueOf(rec.Id));
            String doc2Id = BrokerAccountFormExternalController.createAttachment('', 'TestFile', 'Test Datat',rec.Id);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    static void createGetDeleteDocumnet2() {
        Id recId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        try{
       		String docId = BrokerAccountFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',recId);
            String deleteMssg = BrokerAccountFormExternalController.deleteDocuments(new List<Id>{Id.valueOf(docId)});
            Id documentId = BrokerAccountFormExternalController.getDocID(String.valueOf(recId));
            String doc2Id = BrokerAccountFormExternalController.createAttachment('', 'TestFile', 'Test Datat',recId);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    static void createGetDeleteDocument() {
        Account rec = [SELECT Id, PropStrength__Broker_Code__c FROM Account LIMIT 1];
        Test.startTest();
        try{
            Account acc = TestDataFactorySobha.createAccount(null);
            acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
            acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
            acc.Al_Siniya_Partner__c = true;
            acc.PropStrength__Broker_Code__c = rec.PropStrength__Broker_Code__c;
            insert acc;
            BR_Document_History__c brd= new BR_Document_History__c();
            brd.Expiry_date__c=Date.Today().addDays(-2);
            brd.File_Name__c='TestFile.pdf';
            brd.File_Type__c='Test';
            brd.Broker_Account__c = rec.Id;
            insert brd;
            BR_Document_History__c brd2= new BR_Document_History__c();
            brd2.Expiry_date__c=Date.Today().addDays(-3);
            brd2.File_Name__c='TestFile2.pdf';
            brd2.File_Type__c='Test2';
            brd2.Broker_Account__c = acc.Id;
            insert brd2;
            String docId2 = BrokerAccountFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',rec.Id);
            Id documentId2 = BrokerAccountFormExternalController.getDocID(String.valueOf(rec.Id));
            String deleteMssg2 = BrokerAccountFormExternalController.deleteDocuments(new List<String>{String.valueOf(documentId2)});
            String doc2Id2 = BrokerAccountFormExternalController.createAttachment('', 'TestFile', 'Test Datat',rec.Id);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    @isTest
    static void createGetDeleteDocument2() {
        Id recId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        try{
            BR_Document_History__c brd= new BR_Document_History__c();
            brd.Expiry_date__c=Date.Today().addDays(-2);
            brd.File_Name__c='TestFile.pdf';
            brd.File_Type__c='Test';
            brd.Broker_Account__c = recId;
            insert brd;
            String docId2 = BrokerAccountFormExternalController.createAttachment('Test', 'TestFile', 'Test Datat',recId);
            Id documentId2 = BrokerAccountFormExternalController.getDocID(String.valueOf(recId));
            String deleteMssg2 = BrokerAccountFormExternalController.deleteDocuments(new List<String>{String.valueOf(documentId2)});
            String doc2Id2 = BrokerAccountFormExternalController.createAttachment('', 'TestFile', 'Test Datat',recId);
        }catch(Exception e){
        }
        Test.stopTest();
    }
}