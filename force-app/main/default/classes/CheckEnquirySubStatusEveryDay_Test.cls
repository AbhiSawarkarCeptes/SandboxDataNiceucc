@isTest
public class CheckEnquirySubStatusEveryDay_Test {
	@isTest 
    static void testMethod1() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        insert cont;
        PropStrength__Request__c enq = TestDataFactorySobha.createEnquiry(null);
        enq.PropStrength__Request_Status__c = 'Qualified'; 
        enq.Enquiry_Sub_Status__c = 'Follow-up';
        insert enq;
        CheckEnquirySubStatusEveryDay st = new CheckEnquirySubStatusEveryDay();
        Database.executeBatch(st); 
        String sch = '0 0 2 * * ?';
        system.schedule('Test', sch, st);
    }
}