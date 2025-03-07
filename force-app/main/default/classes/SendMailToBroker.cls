/*********************************************************************
 * Class Name  :   SendMailToBroker
 * Description :   Helper Class of Flow Send Mail To Broker (Flow)
 * Created Date:   07/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
    Created By       :   Nishank Manwani
    Last Modified By :   Nishank Manwani 07/02/2024
 *********************************************************************/
public class SendMailToBroker {
    @InvocableMethod
    public static void sendEmail(List<Id> accId) {
        Id mySourceId = accId[0];
        Account acc = new Account(Id = mySourceId, PropStrength__Broker_Approval_Status__c = 'Executed Agreement Sent to Broker');
        update acc;

        DocusignRecipientStatusSobhaTrigHelper.sendEmailNotificationBroker(mySourceId);
    } 
}