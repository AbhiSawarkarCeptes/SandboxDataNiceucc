public class QuoteTriggerHandler {
    public static void sendForApprover(List<Quote__c> quoteList) {
        for(Quote__c rec : quoteList) {
            if(rec.Total_Discount__c != null && rec.Total_Discount__c > 0) {
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(rec.id);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setProcessDefinitionNameOrId('Multi_Unit_Quote_Approval');
                req1.setSkipEntryCriteria(false);  
                List<Id> idList = new List<Id>();
                idList.add(UserInfo.getUserId());
                req1.setNextApproverIds(idList);
                If(!Test.isRunningTest()){
                    Approval.ProcessResult result = Approval.process(req1);
                }
            }
        }
    }
}