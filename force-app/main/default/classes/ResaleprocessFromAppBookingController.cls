public class ResaleprocessFromAppBookingController {
    @AuraEnabled
    public static string checkBookingIsAvailable(String recId) {
        try {
            if(recId != null && recId != '' && recId != 'undefined') {
                PropStrength__Application_Booking__c book = [SELECT Id, PropStrength__Status__c, (SELECT Id, PropStrength__Status__c FROM PropStrength__Transaction_Request__r WHERE RecordType.Name = 'Transfer Of Property') FROM PropStrength__Application_Booking__c WHERE Id = :recId];
                if(book.PropStrength__Status__c == 'Audit Approved') {
                    if(!book.PropStrength__Transaction_Request__r.isEmpty()) {
                        Boolean flag = true;
                        for(PropStrength__Transaction_Requests__c tr : book.PropStrength__Transaction_Request__r) {
                            if(tr.PropStrength__Status__c != 'Audit Approved') {
                                flag = false;
                                break;
                            }
                        }
                        if(flag) {
                            return 'Yes';
                        } else {
                            return 'The Resale process has already initiated and it\'s in under process.';
                        }
                    } else {
                        return 'Yes';
                    }
                } else {
                    return 'This Booking is not Audit Approved yet.';
                }
            } else {
                return 'Record Id Is Missing.';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PropStrength__Application_Booking__c retrieveSellerInfo(String recId){
        try {
            if(recId != null && recId != '' && recId != 'undefined') {
                return [SELECT Id, (SELECT Id, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Mobile__c, PropStrength__Applicant_Address__c, PropStrength__Applicant_Acc__r.Passport_No__c, PropStrength__Applicant_Acc__r.PropStrength__Nationality__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Type__c = '1st Applicant' LIMIT 1) FROM PropStrength__Application_Booking__c WHERE Id = :recId];
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getPicklistValuesResaleType() {
        List<String> picklistValues = new List<String>();
        
        try {
            Schema.DescribeFieldResult fieldDescription = Schema.getGlobalDescribe().get('PropStrength__Transaction_Requests__c').getDescribe().fields.getMap().get('PropStrength__Customer_Transfer_Type__c').getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldDescription.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                if(entry.getValue() != 'Title Transfer' && entry.getValue() != 'No Title Transfer') {
                    picklistValues.add(entry.getValue());
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        return picklistValues;
    }
}