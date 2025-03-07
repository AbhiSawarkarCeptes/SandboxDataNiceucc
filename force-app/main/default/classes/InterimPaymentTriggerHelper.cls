public class InterimPaymentTriggerHelper {
    
    public static void createInterimPaymentRecord(List<PropStrength__Interim_Payment__c> newList) {
        List<Interim_Payments__c> listOfInterimRec = new List<Interim_Payments__c>();
        for(PropStrength__Interim_Payment__c interimRec : newList){
            Interim_Payments__c interimPay = new Interim_Payments__c();
            interimPay.recordTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
            interimPay.Application_Booking_Interim__c = interimRec.PropStrength__Application_Booking__c;            
            interimPay.Amount_Type__c = interimRec.PropStrength__Amount_Type__c;
            interimPay.Payment_Mode_Interim__c = interimRec.PropStrength__Amount_Type__c;
            interimPay.Amount_Interim__c = interimRec.PropStrength__Amount__c;
            interimPay.Payment_Date_Interim__c = interimRec.PropStrength__Payment_Date__c;           
            listOfInterimRec.add(interimPay);        
        }
        if(listOfInterimRec.size() > 0)
            insert listOfInterimRec;
    }
}