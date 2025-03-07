@isTest
public class ApprovalEmailForBrokerRegControllerTest {
    @isTest
    static void testController() {
        // Create a test Broker_Registration__c record
        Broker_Registration__c testBroker = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'Pending with CHRM OPS'
        );
        insert testbroker;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(testBroker.Id);
        Approval.ProcessResult result = Approval.process(req);

        // Set the currentId in the controller
        ApprovalEmailForBrokerRegController.currentId = testBroker.Id;

        // Create a page reference and set it to the Visualforce page
        // PageReference pageRef = Page.Your_Visualforce_Page_Name;
        // Test.setCurrentPage(pageRef);

        // Create an instance of the controller
        ApprovalEmailForBrokerRegController controller = new ApprovalEmailForBrokerRegController();

        // Call the getrelatedTo method
        Broker_Registration__c resultBroker = ApprovalEmailForBrokerRegController.getrelatedTo();
        List<String> datString = new List<String>();
        datString = ApprovalEmailForBrokerRegController.getLatestApprovalComments(testbroker.id);
    }
}