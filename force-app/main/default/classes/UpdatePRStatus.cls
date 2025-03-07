public class UpdatePRStatus {
    
    @InvocableMethod
    public static void updatestatusValue(List<Payment_Request__c> prList ) {
        Set<Id> offerIds = new Set<Id>();
        List<Payment_Request__c> updateprRecList = new List<Payment_Request__c>();
        for(Payment_Request__c prRec : prList){
            if(prRec.Offer__c != null){
                offerIds.add(prRec.Offer__c);
            }
            else{
                prRec.Status__c = 'Rejected by System';
                updateprRecList.add(prRec);
            }            
        }
        Map<Id,PropStrength__Offer__c> mapOfofferRec = new Map<Id,PropStrength__Offer__c>([SELECT Id FROM PropStrength__Offer__c WHERE Id IN :offerIds AND 
                                                (PropStrength__Status__c != 'Closed Won' AND PropStrength__Status__c != 'New Sale Submission' 
                                                 AND PropStrength__Status__c != 'Pre-Closed Won')]);
        for(Payment_Request__c prRec : prList){
            if(mapOfofferRec.containskey(prRec.Offer__c)){
                prRec.Status__c = 'Rejected by System';
                updateprRecList.add(prRec);
            }           
        }
        if(updateprRecList.size() > 0){
            update updateprRecList;
        }
    }
}