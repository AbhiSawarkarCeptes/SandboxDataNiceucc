@isTest
public class DocuSignEnvelopeStatusTriggerHelper_Test {
    
    @testSetup
    static void setup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        insert enq;
        PropStrength__Projects__c proj = TestDataFactorySobha.createProject(null);
        insert proj;
        PropStrength__Property_Type__c propType = TestDataFactorySobha.createPropertyType(null);
        insert propType;
        PropStrength__Tower__c tower = TestDataFactorySobha.createTower(null);
        insert tower;
        PropStrength__Property__c prop = TestDataFactorySobha.createProperty(null);
        insert prop;
        PropStrength__Payment_Plan__c pp = TestDataFactorySobha.createPaymentPlan(null);
        insert pp;
        PropStrength__Offer__c offer = TestDataFactorySobha.createOffer(null);
        insert offer;
        Incentive_Slab__c incSlab = TestDataFactorySobha.createIncentiveSlab(null);
        insert incSlab;
        PropStrength__PrePayment_Received__c ppRec = TestDataFactorySobha.createPrePaymentReceive(null);
        insert ppRec;
        PropStrength__Brokerage_Scheme__c brkScheme = TestDataFactorySobha.createBrokerageScheme(null);
        insert brkScheme;
        PropStrength__Additional_Brokerage_Slab__c brkSlab = TestDataFactorySobha.createAddBrokerSlab(null);
        insert brkSlab;
        Test.StartTest();
        PropStrength__Application_Booking__c appBook = TestDataFactorySobha.createApplicationBooking(null);
        insert appBook;
        PropStrength__Milestone_Group__c mileStGroup = TestDataFactorySobha.createMilestoneGroup(null);
        insert mileStGroup;
        PropStrength__Milestone__c milestone = TestDataFactorySobha.createMilestone(null);
        insert milestone;
        PropStrength__Payment_Plan_Details__c ppd = TestDataFactorySobha.createPaymentPlanDetail(null);
        insert ppd;
        PropStrength__Received_Payment__c pay = TestDataFactorySobha.createPayment(null);
        insert pay;
        PropStrength__Transaction_Requests__c transReq = TestDataFactorySobha.createTransactionRequest(null);
        insert transReq;
        dfsle__EnvelopeStatus__c envelopeStatus = TestDataFactorySobha.createDocusignEnvelopeStatus(null);
        insert envelopeStatus;
    }
    
	@isTest
    static void testUpdateCheckboxOnBooking(){
		
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        
        DateTime completedDate = System.now();
        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            Application_Booking__c = appBookRec.Id,
            Envelope_Type__c = 'MOU',
            dfsle__Completed__c = completedDate
        );
        insert envelopeStatus;
        
        envelopeStatus.dfsle__Completed__c = System.now();
		update envelopeStatus;
        
        Map<Id, dfsle__EnvelopeStatus__c> oldEsMap = new Map<Id, dfsle__EnvelopeStatus__c>();
        oldEsMap.put(envelopeStatus.Id, new dfsle__EnvelopeStatus__c(dfsle__Completed__c = completedDate.addDays(-1)));

        Test.startTest();
        DocuSignEnvelopeStatusTriggerHelper.updateCheckboxOnBooking(new List<dfsle__EnvelopeStatus__c>{envelopeStatus}, oldEsMap);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCheckboxOnBooking2(){
        // Test case 2: Envelope Type 'MOU'
        PropStrength__Transaction_Requests__c transactionRequest = [SELECT Id FROM PropStrength__Transaction_Requests__c WHERE Id != null LIMIT 1];
        DateTime completedDate = System.now();
        dfsle__EnvelopeStatus__c envelopeStatusMOU = new dfsle__EnvelopeStatus__c(
            Envelope_Type__c = 'MOU',
            Transaction_Request__c = transactionRequest.Id,
            dfsle__Completed__c = completedDate
        );
        insert envelopeStatusMOU;

        Map<Id, dfsle__EnvelopeStatus__c> oldEsMapMOU = new Map<Id, dfsle__EnvelopeStatus__c>();
        oldEsMapMOU.put(envelopeStatusMOU.Id, new dfsle__EnvelopeStatus__c(
            dfsle__Completed__c = completedDate.addDays(-1)
        ));

        Test.startTest();
        DocuSignEnvelopeStatusTriggerHelper.updateCheckboxOnBooking(new List<dfsle__EnvelopeStatus__c>{envelopeStatusMOU}, oldEsMapMOU);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCheckboxOnBooking3(){
        // Test case 3: Envelope Type 'DSPA'
        DateTime completedDate = System.now();
        PropStrength__Transaction_Requests__c transactionRequest = [SELECT Id FROM PropStrength__Transaction_Requests__c WHERE Id != null LIMIT 1];
        dfsle__EnvelopeStatus__c envelopeStatusDSPA = new dfsle__EnvelopeStatus__c(
            Envelope_Type__c = 'DSPA',
            Transaction_Request__c = transactionRequest.Id,
            dfsle__Completed__c = completedDate
        );
        insert envelopeStatusDSPA;

        Map<Id, dfsle__EnvelopeStatus__c> oldEsMapDSPA = new Map<Id, dfsle__EnvelopeStatus__c>();
        oldEsMapDSPA.put(envelopeStatusDSPA.Id, new dfsle__EnvelopeStatus__c(
            dfsle__Completed__c = completedDate.addDays(-1)
        ));

        Test.startTest();
        DocuSignEnvelopeStatusTriggerHelper.updateCheckboxOnBooking(new List<dfsle__EnvelopeStatus__c>{envelopeStatusDSPA}, oldEsMapDSPA);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateTRStatus(){
        PropStrength__Transaction_Requests__c transactionRequest = [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        
        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            Transaction_Request__c = transactionRequest.Id,
            dfsle__Status__c = 'voided'
        );
        insert envelopeStatus;
        envelopeStatus.dfsle__Status__c = 'sent';

        Map<Id, dfsle__EnvelopeStatus__c> oldEvMap = new Map<Id, dfsle__EnvelopeStatus__c>();
        oldEvMap.put(envelopeStatus.Id, envelopeStatus);

        Test.startTest();
        DocuSignEnvelopeStatusTriggerHelper.updateTRStatus(new List<dfsle__EnvelopeStatus__c>{envelopeStatus}, oldEvMap);
        Test.stopTest();
	}
    
    @isTest
    static void testUpdateTRStatus2(){
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
        
        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            Broker_Ledger__c = br.Id,
            dfsle__Status__c = 'voided'
        );
        insert envelopeStatus;
        envelopeStatus.dfsle__Status__c = 'Completed';
		update envelopeStatus;
	}
    
    @isTest
    static void testUpdateTRStatus3(){
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        
        PropStrength__Broker_Payment_Milestone__c bpm = new PropStrength__Broker_Payment_Milestone__c();            
        bpm.PropStrength__Brokerage_Due_Rs__c = 100; 
        bpm.PropStrength__Brokerage_Type__c = 'Additional Brokerage'; 
        bpm.PropStrength__Booking_ID__c = appBookRec.Id;
        bpm.Differentiate_Brokerage__c = true;
        insert bpm;
        
        Account acc = new Account(Name = 'Test');
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        insert acc;
        PropStrength__Broker_Ledger__c br = new PropStrength__Broker_Ledger__c();
        br.PropStrength__Broker_Account__c = acc.Id;
        br.recordTypeId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Paid').getRecordTypeId();
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Broker_Payment_Milestone__c = bpm.id;
        br.PropStrength__Paid_Amount__c = 100;
        br.PropStrength__Brokerage_Due_Rs__c = 1000;
        insert br;
        
        dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c(
            Broker_Account__c = acc.Id,
            Envelope_Type__c = 'Broker Agreement',
            dfsle__Status__c = 'voided'
        );
        insert envelopeStatus;
        envelopeStatus.dfsle__Status__c = 'Completed';
        envelopeStatus.dfsle__Completed__c = System.now();
		update envelopeStatus;
	}
}