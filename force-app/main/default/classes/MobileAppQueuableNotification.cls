global class MobileAppQueuableNotification implements Queueable, Database.AllowsCallouts {
    global set<Id> bookingIdSet;
    global String notificationStatus;
    global String type;
    
    global MobileAppQueuableNotification(set<Id> bookingIdSet,String notificationStatus,String type) {
        this.bookingIdSet = bookingIdSet;
        this.notificationStatus = notificationStatus;
        this.type = type;
    }
    
    global void execute(QueueableContext context) {
        if(!String.isBlank(notificationStatus)) {
            List<PropStrength__Application_Booking__c> bpList = [SELECT id,PropStrength__Applicant_Email__c,PropStrength__Primary_Applicant_Name__c,Name,
                                                                 PropStrength__Project__c, PropStrength__Property__r.PropStrength__Tower__c,PropStrength__Project__r.Name,
                                                                 PropStrength__Property__r.Name,PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c
                                                                 FROM PropStrength__Application_Booking__c 
                                                                 WHERE Id IN: bookingIdSet];
            if(!bpList.isEmpty()) {
                MobileIntegrationCallOutsAPI_PS.TemplateData templateDataRec = new MobileIntegrationCallOutsAPI_PS.TemplateData();
                templateDataRec.unit_no = bpList[0].PropStrength__Property__r.Name;
                templateDataRec.community_name = bpList[0].PropStrength__Project__r.Name;
                templateDataRec.booking_Name = bpList[0].Name;
                //templateDataRec.booking_Name = bpList[0].Name;
                templateDataRec.tower_villa = bpList[0].PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c;
                MobileIntegrationCallOutsAPI_PS.sendnotifications(String.valueOf(bpList[0].id),notificationStatus,bpList[0].PropStrength__Applicant_Email__c,templateDataRec,type);
            }
        }
    }
}