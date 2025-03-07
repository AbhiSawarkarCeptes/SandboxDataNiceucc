@isTest
public class IncentivePayoutTriggerHelper_Test {
    @TestSetup
    static void setup(){
        User u = TestDataFactorySobha.createUser(null);
        u.lastName = 'TestUser';
        insert u;
        Id incentivePaidRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Paid').getRecordTypeId();
		Incentive_Payouts__c ip1 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false, Payable_To__c = u.Id);
        ip1.RecordTypeId = incentivePaidRecTypeId;
        insert ip1;
        
        Id incentivePaidRecTypeId2 = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
		Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false, Payable_To__c = u.Id);
        ip2.RecordTypeId = incentivePaidRecTypeId2;
        ip2.Amount__c = 55623;
        ip2.Commission_Paid__c = 525;
        insert ip2;
        
		Incentive_Payouts__c ip3 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false);
        ip3.RecordTypeId = incentivePaidRecTypeId2;
        ip3.Amount__c = 55623;
        ip3.Commission_Paid__c = 525;
        insert ip3;
        
    }
    @isTest
    static void Test1(){
        User u = [Select id from user WHERE LastName = 'TestUser' LIMIT 1];
        Id incentivePaidRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Paid').getRecordTypeId();
		Incentive_Payouts__c ip1 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false, Payable_To__c = u.Id);
        ip1.RecordTypeId = incentivePaidRecTypeId;
        ip1.Amount__c = 55623;
        ip1.Commission_Paid__c = 525;
        insert ip1;

        
        Incentive_Payouts__c ip2 = new Incentive_Payouts__c(User_Role__c = 'Sales Director',All_Payment_Of_Sale_Inn__c = false);
        ip2.RecordTypeId = incentivePaidRecTypeId;
        ip2.Amount__c = 55623;
        ip2.Commission_Paid__c = 525;
        insert ip2;
        Set<Id> testSet = new Set<Id>();
        testSet.add(ip1.Id);
        testSet.add(ip2.Id);
         try{
        Test.startTest();
        IncentivePayoutTriggerHelper.sendForApprovalProcess(testSet,testSet);

      
        Test.stopTest();
               }
        catch(Exception e){
            
        }
    }

}