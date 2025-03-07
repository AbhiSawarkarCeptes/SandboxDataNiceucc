@isTest
public class BrokerRegistrationAutoApproveByVPTest {

    @isTest
    static void testApproveRecordByAshish() {
        // Create test data - Create a Broker_Registration__c record
        Broker_Registration__c testBrokerRegistration = new Broker_Registration__c(
            First_Name__c = 'Existing',
            Last_Name__c = 'Broker',
            Email__c = 'existing@example.com',
            Mobile__c = '1234567890',
            Name_as_per_trade_license__c = 'Test Trade License',
            Registration_Number__c = '123456',
            Broker_Category__c = 'Broker - RERA',
            Status__c = 'NOC Is in Process'
        );
        testBrokerRegistration.OwnerId = userinfo.getUserId();
        insert testBrokerRegistration;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(testBrokerRegistration.Id);
        Approval.ProcessResult result = Approval.process(req);

        Test.startTest();

        // Call the method to be tested
        List<String> recordIds = new List<String>{testBrokerRegistration.Id};
        try{
        BrokerRegistrationAutoApproveByVP.approveRecordByAshish(recordIds);
        }catch(exception e){
            
        }

        Test.stopTest();
    }
}