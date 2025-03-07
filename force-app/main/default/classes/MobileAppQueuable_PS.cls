global class MobileAppQueuable_PS implements Queueable, Database.AllowsCallouts{
    global List<String> idList;
    global String notificationStatus;
    global String type;
    //global String email;
    
    /*global MobileAppQueuable(List<String> idList,String email,String notificationStatus,String type){
        this.idList = idList;
        this.notificationStatus = notificationStatus;
        this.type = type;
        this.email = email;
    } */
    
    global MobileAppQueuable_PS(List<String> idList,String notificationStatus,String type) {
        this.idList = idList;
        this.notificationStatus = notificationStatus;
        this.type = type;
    }
    
    global void execute(QueueableContext context) {
        if(!String.isBlank(notificationStatus)) {
            String sObjName = Id.valueOf(idList[0]).getSObjectType().getDescribe().getName();
            if(sObjName == 'PropStrength__Received_Payment__c') {
                List<PropStrength__Received_Payment__c> bpList = [SELECT id,PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c
                                                                  FROM PropStrength__Received_Payment__c 
                                                                  WHERE id =: idList AND PropStrength__Application_Booking__c != null];
                if(!bpList.isEmpty()) {
                    NotificationAPIForPayment.Payload templateDataRec = new NotificationAPIForPayment.Payload();
                    templateDataRec.payloadBooking = bpList[0].PropStrength__Application_Booking__c;
                    NotificationAPIForPayment.sendnotificationsPayment(notificationStatus,bpList[0].PropStrength__Application_Booking__r.PropStrength__Applicant_Email__c,templateDataRec,type);
                }
            } else if(sObjName == 'Payment_Request__c') {
                List<Payment_Request__c> bpList = [SELECT id,Application_Booking__c,Application_Booking__r.PropStrength__Applicant_Email__c
                                                   FROM Payment_Request__c 
                                                   WHERE id =: idList AND Application_Booking__c != null];
                if(!bpList.isEmpty()) {
                    NotificationAPIForPayment.Payload templateDataRec = new NotificationAPIForPayment.Payload();
                    templateDataRec.payloadBooking = bpList[0].Application_Booking__c;
                    NotificationAPIForPayment.sendnotificationsPayment(notificationStatus,bpList[0].Application_Booking__r.PropStrength__Applicant_Email__c,templateDataRec,type);
                }
            }
        }
    }
}