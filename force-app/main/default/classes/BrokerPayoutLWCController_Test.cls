@isTest
public class BrokerPayoutLWCController_Test {
    @testSetup
    static void setup() {
        // Create necessary data for testing
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'PropStrength__Broker_Ledger__c' AND DeveloperName = 'Brokerage_Due' LIMIT 1];
        User usr = TestDataFactorySobha.createUser(NULL);

        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;


          PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
        insert prop;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
       PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(MOU_Executed__c = true,DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
        PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = cont.Id, Title_Deed_Transfer_Executed__c=TRUE,
        MOU_Transaction_Exception__c = true,Title_Deed_Process_Exception__c = true,CRM_Executive__c=usr.id);
        insert book;

        
        PropStrength__Broker_Payment_Milestone__c milestone = new PropStrength__Broker_Payment_Milestone__c(
            
            PropStrength__Booking_ID__c = book.Id,
            PropStrength__Brokerage_Paid__c = 500
        );
        insert milestone;

        PropStrength__Broker_Ledger__c ledger = new PropStrength__Broker_Ledger__c(
            PropStrength__Broker_Account__c = acc.Id,
            PropStrength__Broker_Payment_Milestone__c = milestone.Id,
            RecordTypeId = rt.Id,
            PropStrength__Approval_Status__c = 'Approved'
        );
        insert ledger;
    }
    
    @isTest
    static void testAccountName() {
        Test.startTest();
        List<BrokerPayoutLWCController.AccountWrapper> result = BrokerPayoutLWCController.accountName('Test');
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Results should not be empty');
        //System.assertEquals('Test Broker Account', result[0].recName, 'Account name should match');
    }
     @isTest
    static void testGetAccountDetails() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Account result = BrokerPayoutLWCController.getAccountDetails(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Account should not be null');
        //System.assertEquals('Test Broker Account', result.Name, 'Account name should match');
    }

    @isTest
    static void testSaveTheLedgers() {
        PropStrength__Broker_Ledger__c ledger = [SELECT Id FROM PropStrength__Broker_Ledger__c LIMIT 1];
        
        List<Map<String, Object>> draftValues = new List<Map<String, Object>>();
        Map<String, Object> draftValue = new Map<String, Object>{
            'id' => ledger.Id,
            'PropStrength__Paid_Amount__c' => '100',
            'PropStrength__Date__c' => Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
            'PropStrength__Broker_Payment_Mode__c' => 'Test Mode',
            'PropStrength__Check_No__c' => '12345'
        };
        draftValues.add(draftValue);
        
        Test.startTest();
        String result = BrokerPayoutLWCController.saveTheLedgers(JSON.serialize(draftValues));
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Result should be Success');
    }

    @isTest
    static void testSearchPLValues() {
        Test.startTest();
        List<String> result = BrokerPayoutLWCController.searchPLValues();
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Picklist values should not be empty');
    }
}