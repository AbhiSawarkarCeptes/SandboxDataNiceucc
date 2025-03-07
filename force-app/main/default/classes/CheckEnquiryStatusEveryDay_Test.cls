@isTest
public class CheckEnquiryStatusEveryDay_Test {
@isTest 
    static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Request_Status__c = 'Open'; 
        enq.Check_Enquiry_Status_Daily__c = System.Today();
        insert enq;
        CheckEnquiryStatusEveryDay st = new CheckEnquiryStatusEveryDay();
        Database.executeBatch(st); 
        String sch = '0 0 2 * * ?';
        system.schedule('Test', sch, st);
    }
}