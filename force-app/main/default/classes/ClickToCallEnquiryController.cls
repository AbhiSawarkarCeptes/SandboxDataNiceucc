public without sharing class ClickToCallEnquiryController {
    @AuraEnabled(cacheable=true)
    public static String originalPhoneNumber(String enqId) {
        String originalNumber = '';
        List<PropStrength__Request__c> enqList = new List<PropStrength__Request__c>();
        if(!String.isBlank(enqId)) {
            enqList = [SELECT Id, PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted__c 
                        FROM PropStrength__Request__c 
                        WHERE Id= : enqId AND 
                            PropStrength__Primary_Contact__c != null 
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!enqList.isEmpty() && !String.isBlank(enqList[0].PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted__c)) {
            originalNumber = enqList[0].PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted__c;
        }
        return originalNumber;
    }
    @AuraEnabled(cacheable=true)
    public static String originalMobileNumber(String enqId) {
        String originalNumber = '';
        List<PropStrength__Request__c> enqList = new List<PropStrength__Request__c>();
        if(!String.isBlank(enqId)) {
            enqList = [SELECT Id, PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted__c 
                        FROM PropStrength__Request__c 
                        WHERE Id= : enqId AND 
                            PropStrength__Primary_Contact__c != null 
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!enqList.isEmpty() && !String.isBlank(enqList[0].PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted__c)) {
            originalNumber = enqList[0].PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted__c;
        }
        return originalNumber;
    }
    @AuraEnabled(cacheable=true)
    public static String originalCallingNumber(String enqId) {
        String originalNumber = '';
        List<PropStrength__Request__c> enqList = new List<PropStrength__Request__c>();
        if(!String.isBlank(enqId)) {
            enqList = [SELECT Id, PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted__c 
                        FROM PropStrength__Request__c 
                        WHERE Id= : enqId AND 
                            PropStrength__Primary_Contact__c != null 
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!enqList.isEmpty() && !String.isBlank(enqList[0].PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted__c)) {
            originalNumber = enqList[0].PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted__c;
        }
        return originalNumber;
    }
}