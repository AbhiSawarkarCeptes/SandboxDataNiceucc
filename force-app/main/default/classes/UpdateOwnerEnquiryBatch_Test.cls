@isTest
public class UpdateOwnerEnquiryBatch_Test {
    @isTest
    static void testUpdateOwnerEnquiryBatch() {
        // Create test data - PropStrength__Assignment_Group_Name__c
        List<PropStrength__Assignment_Group_Name__c> grpList = new List<PropStrength__Assignment_Group_Name__c>();
        grpList.add(new PropStrength__Assignment_Group_Name__c(Name = 'Arabic', PropStrength__Active__c = true,PropStrength__Type__c = 'Enquiry'));
        insert grpList;

        // Create test data - PropStrength__Group_Member__c
        List<PropStrength__Group_Member__c> groupMembers = new List<PropStrength__Group_Member__c>();
        groupMembers.add(new PropStrength__Group_Member__c(PropStrength__User__c = UserInfo.getUserId(), PropStrength__Order__c = 1, PropStrength__Active__c = 'TRUE', PropStrength__Assignment_Group__c = grpList[0].Id));
        insert groupMembers;

        // Create test data - PropStrength__Request__c
        List<PropStrength__Request__c> requests = new List<PropStrength__Request__c>();
        requests.add(new PropStrength__Request__c(PropStrength__Request_Status__c = 'Open',Assignment_Group__c =grpList[0].Id , Prefered_LAnguage__c = 'Arabic',Enquiry_Owner_Batch_Update__c = SYstem.today()));
        insert requests;
        
        requests[0].Enquiry_Owner_Batch_Update__c = System.now().addMinutes(-25);
        update requests;

        Test.startTest();
        // Instantiate and execute the batch class
        UpdateOwnerEnquiryBatch batchClass = new UpdateOwnerEnquiryBatch();
        Database.executeBatch(batchClass);
        Test.stopTest();
    }
}