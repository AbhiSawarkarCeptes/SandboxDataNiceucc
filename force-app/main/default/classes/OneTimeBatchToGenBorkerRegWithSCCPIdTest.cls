@isTest
public class OneTimeBatchToGenBorkerRegWithSCCPIdTest {
    
    @testSetup
    static void setup() {
        List<Sobha_Connect__c> scList = new List<Sobha_Connect__c>();
        for (Integer i=0;i<10;i++) {
            scList.add(new Sobha_Connect__c(Name__c='TestSC- '+i, Address__c='Test,Test,Test,Test,Test', City__c='Dubai', Country__c='UNITED ARAB EMIRATES', Nationality__c='Indian', Registration__c='REGSC23'+i, Agent_Category__c='Broker - RERA', Email_Id__c='testsz'+i+'@tesee.dd', Mobile_No__c='123566434'+i));
        }
        insert scList;
        
        List<Channel_Partner__c> cpList = new List<Channel_Partner__c>();
        for (Integer i=0;i<10;i++) {
            cpList.add(new Channel_Partner__c(Name='TestSC- '+i, Address__c='Test,Test,Test,Test,Test', City__c='Dubai', Country__c='UNITED ARAB EMIRATES', Passport_No__c='REGCP22'+i, Category__c='Broker - RERA', Email_ID_1__c='testsz'+i+'@tesee.dd', Mobile_No__c='123566434'+i));
        }
        insert cpList;
    }
    
    @isTest 
    static void testMethodSC() {
        Test.startTest();
            OneTimeBatchToGenerateBorkerRegWithSCId scb = new OneTimeBatchToGenerateBorkerRegWithSCId();
            Id batchId = Database.executeBatch(scb);
        Test.stopTest();
    }
    
    @isTest 
    static void testMethodCP() {
        Test.startTest();
            OneTimeBatchToGenerateBorkerRegWithCPId pcb = new OneTimeBatchToGenerateBorkerRegWithCPId();
            Id batchId = Database.executeBatch(pcb);
        Test.stopTest();
    }

}