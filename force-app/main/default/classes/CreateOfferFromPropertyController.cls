public class CreateOfferFromPropertyController {
    @AuraEnabled
    public static List<PropStrength__Payment_Plan__c> searchPPlans(String searchKeyWrd, String recId){
        if(searchKeyWrd != '') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            return [SELECT Id, Name FROM PropStrength__Payment_Plan__c WHERE Name LIKE :searchKeyWrd AND PropStrength__Active__c = TRUE AND PropStrength__Available_For_Change_In_PPlan__c = FALSE AND PropStrength__Project__c = :recId];
        } else {
            return [SELECT Id, Name FROM PropStrength__Payment_Plan__c WHERE PropStrength__Active__c = TRUE AND PropStrength__Available_For_Change_In_PPlan__c = FALSE AND PropStrength__Project__c = :recId];
        }
    }

    @AuraEnabled
    public static string updateOffer(String ppIdRecord, String recId){
        try {
            if(recId != 'undefined' && recId != '' && recId != null) {
                if(ppIdRecord != 'undefined' && ppIdRecord != '' && ppIdRecord != null) {
                    PropStrength__Offer__c offer = new PropStrength__Offer__c(Id=recId, PropStrength__Payment_Plan__c = ppIdRecord);
                    update offer;
                    return 'Success';
                } else {
                    return 'Payment Plan is not selected';
                }
            } else {
                return 'Offer record is not created';
            }
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}