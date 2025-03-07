public class UpdateHoldStatusOnPropertyFromPR {
    @InvocableMethod
    public static void updatePropertyOnHoldValue(List<PropStrength__Property__c> prList ) {
        List<PropStrength__Property__c> propertyListToUpdate = new List<PropStrength__Property__c>();        
        for(PropStrength__Property__c rec : prList) {            
            if(rec.PropStrength__Property_on_hold_for_Reallocation__c) {
                rec.PropStrength__Property_on_hold_for_Reallocation__c = false;                   
                rec.Allocated_SM__c = null;
                propertyListToUpdate.add(rec);
            }
            
        }
        if(!propertyListToUpdate.isEmpty()) {
            update propertyListToUpdate;
        }
        
    }
}