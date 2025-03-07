public without sharing class CreatePaymentPlanFromOfferController {
    @AuraEnabled(cacheable=true)
    public static string checkValidation(String offerId){
        List<PropStrength__Offer__c> offList = [SELECT Id, PropStrength__Project__c,  PropStrength__Status__c, PropStrength__Property__c, Deviation_on_Payment_Plan_Approved__c  
                    FROM PropStrength__Offer__c WHERE Id = :offerId];
        System.debug('----->'+ offerId);
        if(!offList.isEmpty()) {
            if(offList[0].PropStrength__Project__c == null) {
                return 'Please Select Project and Property before creating a Payment Plan';
            }
            else if(offList[0].PropStrength__Property__c  == null) {
                return 'Please Select Property before creating a Payment Plan';
            }
            else if(offList[0].PropStrength__Status__c == 'Closed Won') {
                return 'New Payment Plan cannot be created for Closed Won Offer';
            }
            else if(!offList[0].Deviation_on_Payment_Plan_Approved__c){
                return 'Deviation on payment plan is not approved';
            }
            else {
                return 'URL';
            }
        }
        return offerId;
    }
}