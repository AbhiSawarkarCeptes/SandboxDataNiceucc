public class CreateOfferFromPRController {    
    @AuraEnabled
    public  static String createOfferRecord(String ppId, String recId, String fromClassic) {
        try{
            System.debug(ppId);
            System.debug(recId);
            Payment_Request__c pr = [SELECT Id, Enquiry__c, Payment_Request__c, Property__c, Property__r.PropStrength__Property_Type__c FROM Payment_Request__c WHERE Id = :recId];
            PropStrength__Property__c propRec = [SELECT Id, PropStrength__Project_Name__c, PropStrength__Project_Name__r.Expiry_Days__c FROM PropStrength__Property__c WHERE Id = :pr.Property__c];
            PropStrength__Request__c enqRec = [SELECT Id, PropStrength__Broker_Contact__c, PropStrength__Broker_Account__c, PropStrength__Request_Source__c, PropStrength__Enquiry_Type__c, PropStrength__Project__c, PropStrength__Project__r.Expiry_Days__c, PropStrength__Primary_Contact__c FROM PropStrength__Request__c WHERE Id = :pr.Enquiry__c];
            
            PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Broker_Contact__c = (enqRec.PropStrength__Broker_Contact__c != null ? enqRec.PropStrength__Broker_Contact__c : null), PropStrength__Broker_Account__c = (enqRec.PropStrength__Broker_Account__c != null? enqRec.PropStrength__Broker_Account__c : null), PropStrength__Offer_Source__c = enqRec.PropStrength__Request_Source__c, PropStrength__Property_Type__c = pr.Property__r.PropStrength__Property_Type__c, PropStrength__Property__c = pr.Property__c, PropStrength__Request__c = enqRec.Id, PropStrength__Payment_Plan__c = ppId, PropStrength__Offer_Through__c = enqRec.PropStrength__Enquiry_Type__c, PropStrength__Status__c = 'New', PropStrength__Offer_Close_Date__c = System.Today().addDays(Integer.valueOf(propRec.PropStrength__Project_Name__r.Expiry_Days__c)), PropStrength__Project__c = propRec.PropStrength__Project_Name__c, PropStrength__Primary_Contact__c = enqRec.PropStrength__Primary_Contact__c, Payment_Request_1__c = recId);
            
            List<Payment_Request__c> pr2Rec = new List<Payment_Request__c>();
            if(pr.Payment_Request__c != null) {
                pr2Rec = [SELECT Id FROM Payment_Request__c WHERE Id = :pr.Payment_Request__c AND Status__c = 'Approved'];
                if(!pr2Rec.isEmpty()) {
                    offer.Payment_Request_2__c = pr2Rec[0].Id;
                }
            }
            
            insert offer;
            
            List<Payment_Request__c> prUpdateList = new List<Payment_Request__c>();
            prUpdateList.add(new Payment_Request__c(Id=recId, Offer__c = offer.Id));
            if(pr.Payment_Request__c != null) {
                prUpdateList.add(new Payment_Request__c(Id=pr.Payment_Request__c, Offer__c = offer.Id));
            }
            update prUpdateList;
            
            if(fromClassic == 'true') {
                return '/'+offer.Id;
            }
            return '/lightning/r/PropStrength__Offer__c/' + offer.Id + '/view';
        } catch(Exception e) {
            if(fromClassic == 'true') {
                return e.getMessage()+'fromClassic';
            }
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string checkOfferIsCreatedOrNot(String recId, String fromClassic){
        try {
            Payment_Request__c pr = [SELECT Id, Offer__c FROM Payment_Request__c WHERE Id = :recId];
            if(pr.Offer__c != null) {
                if(fromClassic == 'true') {
                    return 'created fromClassic';
                }
                return 'created';
            } else {
                return 'not created';
            }
        } catch (Exception e) {
            if(fromClassic == 'true') {
                return e.getMessage()+'fromClassic';
            }
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<PropStrength__Payment_Plan__c> searchPPlans(String searchKeyWrd, String recId){
        searchKeyWrd = '%'+searchKeyWrd+'%';
        Payment_Request__c pr = [SELECT Id, Property__c FROM Payment_Request__c WHERE Id = :recId];
        PropStrength__Property__c propRec = [SELECT Id, PropStrength__Project_Name__c FROM PropStrength__Property__c WHERE Id = :pr.Property__c];
        return [SELECT Id, Name FROM PropStrength__Payment_Plan__c WHERE Name LIKE :searchKeyWrd AND PropStrength__Active__c = TRUE AND PropStrength__Available_For_Change_In_PPlan__c = FALSE AND PropStrength__Project__c = :propRec.PropStrength__Project_Name__c];
    }
}