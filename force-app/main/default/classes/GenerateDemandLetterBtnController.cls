public with sharing class GenerateDemandLetterBtnController {
    @AuraEnabled
    public static PropStrength__Received_Payment__c getRecordInfo(Id recordId) {
        try {
            PropStrength__Received_Payment__c payRec = [SELECT Id, RecordType.Name FROM PropStrength__Received_Payment__c WHERE Id = :recordId limit 1];
            return payRec;
        } catch (Exception e) {    throw new AuraHandledException(e.getMessage());   }
    }
}