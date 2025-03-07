@isTest
public class UpdatePricingMilestoneBatchTest {
	@isTest
    private static void createData(){
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Trade Receivable';
        amList.add(am1);
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Discount/rebate credit note';
        amList.add(am2);
        insert amList;        
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = DemandAutoGenerationBatchTest.createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
        Payment_Milestones__c pm = DemandAutoGenerationBatchTest.createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.Current_Status__c = 'Audit Accepted';
        b.status__c = 'Processed';
        b.Stage_of_Booking__c = 'Booked';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;  
        b.PCC_Status__c = 'Pending for Audit Approval';
        insert b; 
        
        quote.Booking__c = b.Id;
        update quote;      
        Test.startTest();
        UpdatePricingMilestoneBatch obj = new UpdatePricingMilestoneBatch(new Set<String>{String.valueOf(unitId)});
        	Database.executeBatch(obj);
   		Test.stopTest();
    }
}