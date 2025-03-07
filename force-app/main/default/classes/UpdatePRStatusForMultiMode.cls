public class UpdatePRStatusForMultiMode {
    @InvocableMethod
    public static void updatestatusValue(List<Payment_Request__c> prList ) {
        Set<Id> offerIds = new Set<Id>();
        List<Payment_Request__c> updateprRecList = new List<Payment_Request__c>();
        for(Payment_Request__c prRec : prList){
            if(prRec.Payment_Request__c == null){
                prRec.Status__c = 'Rejected by System';
                updateprRecList.add(prRec);
            }                    
        }        
        if(updateprRecList.size() > 0){
            update updateprRecList;
        }
    }
}