public class CustomLookupAppBookController {
    @AuraEnabled
    public static List<User> searchUsers(String searchKeyWrd){
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            return [SELECT Id, Name FROM User WHERE Name LIKE :searchKeyWrd];
        } else {
            return [SELECT Id, Name FROM User];
        }
    }

    @AuraEnabled
    public static void updateHomeOrientation(String homeOrientation, Id recId){
        if(recId != null) {
                PropStrength__Application_Booking__c bookUpdate = new PropStrength__Application_Booking__c(Id=recId, Home_Orientation_Executive_Name__c = String.valueOf(homeOrientation));
                update bookUpdate;
        }
    }

    @AuraEnabled
    public static void updateHandoverCrm(String handoverCrm, Id recId){
        if(recId != null) {
                PropStrength__Application_Booking__c bookUpdate = new PropStrength__Application_Booking__c(Id=recId, Handover_CRM_Executive__c = String.valueOf(handoverCrm));
                update bookUpdate;
        }
    }
}