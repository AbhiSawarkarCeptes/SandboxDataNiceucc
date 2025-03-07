@isTest
public class BLDocumentHistoryRetriever_PS_Test {
	 @testSetup
    public static void setUp() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Email_ID_1__c ='test@gmail.com';
        insert acc;
        
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.AccountId = acc.ID;
        cont.Email = 'test@test.com';
        insert cont;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        
        Test.startTest();
        PropStrength__Payment_Plan__c ppd = TestDataFactorySobha.createPaymentPlan(null);
        ppd.PropStrength__Project__c = proj.Id;
        insert ppd;
        
        PropStrength__Request__c enq  = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        tower.PropStrength__Project_Name__c = proj.Id; 
        insert tower;
        
        PropStrength__Property_Type__c pType =  TestDataFactorySobha.createPropertyType(null);
        pType.PropStrength__Project__c = proj.Id;
        insert pType;
        
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        prop.PropStrength__Tower__c = tower.Id;
        prop.PropStrength__Property_Type__c = pType.Id;
        prop.PropStrength__Project_Name__c = proj.Id;
        insert prop;
        
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        offer.PropStrength__Request__c = enq.Id;
        offer.PropStrength__Payment_Plan__c = ppd.Id;
        offer.PropStrength__Project__c = proj.Id; 
        offer.PropStrength__Property__c = prop.Id; 
        offer.PropStrength__Property_Type__c = pType.Id;
        offer.PropStrength__Primary_Contact__c = cont.Id;
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__Brokerage_Payment_Plan__c sche = new PropStrength__Brokerage_Payment_Plan__c(PropStrength__Brokerage_Type__c = 'Margin', PropStrength__Due_on_Total_Sales_Consideration__c = 10, PropStrength__of_Brokerage__c = 4, Approval_Status__c='Approved', PropStrength__Project__c = proj.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Release_Schedule_Name__c = 'Test', PropStrength__Brokerage_Schedule_Code__c = '12345');
        insert sche;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Brokerage_Release_Schedule__c = sche.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Primary_Customer__c = cont.Id, PropStrength__Property__c = prop.Id, Oqood_Fees_Received__c=FALSE, Noqoodi_Wallet_Ref_No_Approved__c = FALSE, PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today(), PropStrength__Booking_Through__c = 'Broker', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,PropStrength__Brokerage_BSP__c=1200,PropStrength__Brokerage_On_Other_Charges__c=1400);
        insert book;
        Test.stopTest();
    }
	@isTest
    public static void testMethod1() {
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = appBookRec.Id;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();        
        insert acc;
        
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        Ledger_Document_History__c ldh = new Ledger_Document_History__c(Broker_Ledger__c=br.Id, Document_Number__c='111', Document_Type__c ='Cheque Number' );
        insert ldh;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Invoice.pdf',
            PathOnClient = 'Invoice.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        Test.startTest();
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> conList = new list<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ldh.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        conList.add(cdl);
        Insert conList;
        BLDocumentHistoryRetriever_PS.getLedgerDocumentFileDetails(String.valueOf(br.Id));
    }
}