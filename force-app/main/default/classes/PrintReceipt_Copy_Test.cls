@isTest
public class PrintReceipt_Copy_Test {
    @isTest 
    public static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        Account acc = new Account();
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.Name = 'Test';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Digital Platform';
        insert enq;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;

         PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Broker_Contact__c = cont.Id, PropStrength__Offer_Through__c = 'Broker', Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__Application_Booking__c book = new PropStrength__Application_Booking__c(PropStrength__Offer__c=offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id);
        insert book;
        
        PropStrength__Received_Payment__c pay = new PropStrength__Received_Payment__c(PropStrength__Payment_Date__c = System.Today()+31, Rebate_Calculated__c = FALSE, PropStrength__Receipt_Reversed__c = FALSE, PropStrength__Amount_Due_Type__c = 'Reversal payment due', PropStrength__Application_Booking__c = book.Id, RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId(), PropStrength__Amount__c = 1000);
        insert pay;
        
       
        Test.startTest();      
        PageReference pRef= Page.PrintReceiptSobhaDubai;
        Test.setcurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', pay.Id);
        ApexPages.currentPage().getParameters().put('letterhead', 'testLetterhead');

        PrintReceipt_Copy obj = new PrintReceipt_Copy();
        Obj.ownerName = 'John Doe';
        Obj.ownerPhone = '123-456-7890';
        Obj.ownerEmail = 'john.doe@example.com';
        Obj.ownerSalutation = 'Mr.';
        Obj.legalAddress = '123 Legal St';
        Obj.legalCity = 'Legal City';
        Obj.legalPinCode = '123456';
        Obj.legalEntityName = 'Legal Entity Name';
        Obj.Signatory = 'Authorized Signatory';
        Obj.totalAmt = 2000;
        Obj.tamt = 'Two Thousand';
        Obj.CustomerMailingAddress = '456 Mailing St';
        Obj.CustomerMobilePhone = '987-654-3210';
        Obj.UnitName = 'Unit 101';
        Obj.ChequeDate = Date.today().format();
        Obj.ReceiptDate = Date.today().format();
        Obj.CurrencyString = 'USD';
        Test.stopTest(); 
    }
    
    @isTest
    static void testCreateErr() {
        Test.startTest();
        PrintReceipt_Copy printReceipt = new PrintReceipt_Copy();
        printReceipt.createErr();
        Test.stopTest();

    }
    
    
}