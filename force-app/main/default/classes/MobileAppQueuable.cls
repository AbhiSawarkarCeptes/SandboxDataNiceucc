global class MobileAppQueuable implements Queueable, Database.AllowsCallouts{
	global List<String> idList;
    global String notificationStatus;
    global String type;
    global String email;
    global MobileAppQueuable(List<String> idList,String email,String notificationStatus,String type){
        this.idList = idList;
        this.notificationStatus = notificationStatus;
        this.type = type;
        this.email = email;
    }
    
    global void execute(QueueableContext context) {
        String sObjName = Id.valueOf(idList[0]).getSObjectType().getDescribe().getName();
        if(sObjName == 'Booking__c'){
            List<Booking__c> bpList = [select id,Primary_Applicant_Email__c,Primary_Applicant_Name__c,Name, Unit__r.Name, Cluster__c, Tower__c from Booking__c where id =: idList];
            Mobile_ApiUtility.TemplateData templateDataRec = new Mobile_ApiUtility.TemplateData();
            templateDataRec.unit_no = bpList[0].Unit__r.Name;
            templateDataRec.community_name = bpList[0].Cluster__c;
            templateDataRec.booking_id = bpList[0].Id; 
            templateDataRec.booking_Name = bpList[0].Name; 

            templateDataRec.tower_villa = bpList[0].Tower__c;
            /*if(notificationStatus == 'Inserted'){
               Mobile_ApiUtility.sendnotifications('unit_booking_confirmation',bpList[0].Primary_Applicant_Email__c,templateDataRec,'message'); 
            }else if(notificationStatus == 'SPA Sent through Docusign'){
               Mobile_ApiUtility.sendnotifications('SPA_readiness_customer_signature',bpList[0].Primary_Applicant_Email__c,templateDataRec,'alert');
            }else if (notificationStatus == 'SPA Executed'){
                Mobile_ApiUtility.sendnotifications('completion_SPA_approval',bpList[0].Primary_Applicant_Email__c,templateDataRec,'alert');
            }*/
            Mobile_ApiUtility.sendnotifications(notificationStatus,email,templateDataRec,type);
        }
    }
    
}