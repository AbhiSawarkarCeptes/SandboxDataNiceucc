@isTest
public class trgDemandTest {

    @isTest Public Static void method1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = NewCustomerSOAControllerTest.createQuotation(oppId, recordMap.get('PLAN'), unitId);
        
        Booking__c testBooking = new Booking__c();
        testBooking.Booking_Date__c = system.today();
        testBooking.Project__c = projectId;
        testBooking.Opportunity__c = oppId;
        testBooking.Unit__c = unitId;
        testBooking.status__c = 'Processed';
        testBooking.Quotation__c = quote.Id;
        testBooking.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        testBooking.Future_Correspondence_Contact__c = 'First Applicant';
        testBooking.Agreement_Value__c = 6000000;
        testBooking.Stage_of_Booking__c = 'Booked';
        insert testBooking;
        Date dat = system.today() + 30 ;
        Payment_Milestones__c pm = NewCustomerSOAControllerTest.createPaymentMilestone(quote.Id,dat);
        ProjectCharges__c projchrg1 = new ProjectCharges__c(); // create projectcharges
        projchrg1.name = 'Basic';
        projchrg1.Active__c = true;
        projchrg1.Project__c = projectId;
        projchrg1.Calculatedas__c = 'Rate list at Unit level';
        projchrg1.ChargeBucket__c = 'Other Charges';
        projchrg1.Taxable__c = 67.0;
        projchrg1.SGST__c = 9.0;
        projchrg1.CGST__c = 9.0;
        projchrg1.IGST__c = 0.0;
        insert projchrg1;
        Demand__c d1 = new Demand__c();
        //d1.Payment_Milestones__c = pmList[0].id;
        d1.Quotation__c = quote.id;
        d1.Booking__c = testBooking.id;
        d1.Invoice_Date__c = system.today();
        d1.Due_Date__c = system.today()+1; 
        d1.Debit_Demanded__c = 1000;
        d1.Debit_Paid__c = 20;
        d1.Charge_1_Demanded__c = 123;
        d1.Debit_Type__c = 'Cheque Bounce';
        d1.Debit_Tax_Demanded__c = 100;
        d1.Debit_Tax_Paid__c = 20;
        d1.Debit_SGST__c = 50;
        d1.Charge_1_Tax_Demanded__c =123.0;
         d1.Charge_2_Tax_Demanded__c =123.0;
        d1.Other_Charges_Type__c = 'NOC Charges';
        d1.Demand_Status__c = 'Raised';
        d1.Agreement_Value_Demanded_New__c = 123;
        d1.Service_Tax_on_Agreement_Value_Demanded__c = 345;
        d1.Debit_Demanded__c = 134;
        d1.Charge_1_Lookup__c =projchrg1.Id;
        d1.Debit_Tax_Demanded__c = 678;
        d1.Agreement_Value_Paid__c=400;
        d1.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d1.Debit_CGST__c = 50;
        
        insert d1;
         Demand__c d = new Demand__c();
        //d1.Payment_Milestones__c = pmList[0].id;
        d.Quotation__c = quote.id;
        d.Booking__c = testBooking.id;
        d.Invoice_Date__c = system.today();
        d.Due_Date__c = system.today()+1; 
        d.Debit_Demanded__c = 1000;
        d.Debit_Paid__c = 20;
        d.Charge_1_Demanded__c = 123;
        d.Debit_Type__c = 'Cheque Bounce';
        d.Debit_Tax_Demanded__c = 100;
        d.Debit_Tax_Paid__c = 20;
        d.Debit_SGST__c = 50;
        d.Charge_1_Tax_Demanded__c =123.0;
         d.Charge_2_Tax_Demanded__c =123.0;
        d.Other_Charges_Type__c = 'NOC Charges';
        d.Demand_Status__c = 'Reversed';
        d.Agreement_Value_Demanded_New__c = 123;
        d.Service_Tax_on_Agreement_Value_Demanded__c = 345;
        d.Debit_Demanded__c = 134;
        d.Charge_1_Lookup__c =projchrg1.Id;
        d.Debit_Tax_Demanded__c = 678;
        d.Agreement_Value_Paid__c=400;
        d.Service_Tax_on_Agreement_Value_Paid__c = 200;
        d.Debit_CGST__c = 50;
        
        insert d;
        
        d1.Demand_Status__c = 'Reversed';
        update d1;
    }
}