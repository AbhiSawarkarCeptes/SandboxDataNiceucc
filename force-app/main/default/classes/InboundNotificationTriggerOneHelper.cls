public class InboundNotificationTriggerOneHelper {
    //Create an Enquiry when call start inbound is created
    public static void createEnquiry(List<VCC1__Inbound_Notification__c> newInboundNotificationList) {
        Set<String> callCenterNumber = new Set<String>();
        Map<String, String> callCenterNameToAdvIdMap = new Map<String, String>();
        Map<String, String> callCenterNameToProjectIdMap = new Map<String, String>();
        List<PropStrength__Request__c> requestList = new List<PropStrength__Request__c>();
        for(VCC1__Inbound_Notification__c notifyINBRecord : newInboundNotificationList) {
            if(notifyINBRecord.VCC1__Call_Type__c == 'Inbound' && 
                notifyINBRecord.VCC1__Type__c == 'Call Start' && 
                !String.isBlank(notifyINBRecord.VCC1__Calling_Number_Encrypted__c) && 
                !String.isBlank(notifyINBRecord.VCC1__Record_Id__c) && 
                !String.isBlank(notifyINBRecord.VCC1__Dialed_Number__c) && 
                !String.isBlank(notifyINBRecord.VCC1__Call_Id__c)) {
                callCenterNumber.add(notifyINBRecord.VCC1__Dialed_Number__c);
            }
        }
        if(!callCenterNumber.isEmpty()) {
            for(VCC1__Number_Advertisement__c numberAdv : [SELECT Id, VCC1__Advertisement__c, 
                                                            VCC1__Call_Center_Number__c, 
                                                            VCC1__Call_Center_Number__r.Name, 
                                                            VCC1__Advertisement__r.Project__c 
                                                            FROM VCC1__Number_Advertisement__c 
                                                            WHERE VCC1__Call_Center_Number__r.Name IN: callCenterNumber AND 
                                                                VCC1__Advertisement__c != null 
                                                                ORDER BY CreatedDate DESC LIMIT 49999]) {
                callCenterNameToAdvIdMap.put(numberAdv.VCC1__Call_Center_Number__r.Name, numberAdv.VCC1__Advertisement__c);
                callCenterNameToProjectIdMap.put(numberAdv.VCC1__Call_Center_Number__r.Name, (numberAdv.VCC1__Advertisement__r.Project__c != null) ? numberAdv.VCC1__Advertisement__r.Project__c : null);
            }
        }
        for(VCC1__Inbound_Notification__c notifyRecord : newInboundNotificationList) {
            if(notifyRecord.VCC1__Call_Type__c == 'Inbound' && 
                notifyRecord.VCC1__Type__c == 'Call Start' && 
                !String.isBlank(notifyRecord.VCC1__Calling_Number_Encrypted__c) && 
                !String.isBlank(notifyRecord.VCC1__Record_Id__c) && 
                !String.isBlank(notifyRecord.VCC1__Dialed_Number__c) && 
                !String.isBlank(notifyRecord.VCC1__Call_Id__c)) {
                DateTime gmtDateTime = System.now();
                TimeZone currentTimeZone = UserInfo.getTimeZone();
                String currentDateTimeString = gmtDateTime.format('dd-MM-yyyy hh:mm:ss') + ' (' + currentTimeZone.toString() + ')';
                PropStrength__Request__c reqRec = new PropStrength__Request__c(); 
                reqRec.PropStrength__Primary_Contact__c = notifyRecord.VCC1__Record_Id__c;
                reqRec.PropStrength__Last_Name__c = 'New Enquiry: ' + currentDateTimeString;
                reqRec.PropStrength__Request_Status__c = 'Open';
                reqRec.OwnerId = notifyRecord.VCC1__Agent_User__c != null ? notifyRecord.VCC1__Agent_User__c : notifyRecord.OwnerId;
                reqRec.Presales_Agent__c = notifyRecord.VCC1__Agent_User__c != null ? notifyRecord.VCC1__Agent_User__c : notifyRecord.OwnerId;
                reqRec.Advertisement__c = (callCenterNameToAdvIdMap.containskey(notifyRecord.VCC1__Dialed_Number__c) ? callCenterNameToAdvIdMap.get(notifyRecord.VCC1__Dialed_Number__c) : null);
                reqRec.PropStrength__Project__c = (callCenterNameToProjectIdMap.containskey(notifyRecord.VCC1__Dialed_Number__c) ? callCenterNameToProjectIdMap.get(notifyRecord.VCC1__Dialed_Number__c) : null);
                reqRec.Call_Id__c = notifyRecord.VCC1__Call_Id__c;
                reqRec.PropStrength__Enquiry_Type__c = 'Direct';
                reqRec.PropStrength__Request_Source__c = 'Phone Enquiry';
                requestList.add(reqRec);
            }
        }
        if(!requestList.isEmpty()) {
            Database.SaveResult[] saveEnqResult = Database.insert(requestList, false);
            for(Database.SaveResult srEnq : saveEnqResult) {
                if(srEnq.isSuccess()) {
                    System.debug('===> Enq Id: ' + srEnq.getId());
                } else {
                    for(Database.Error errEnq : srEnq.getErrors()) {
                        System.debug('===> Exception: ' + errEnq.getMessage());
                    }
                }
            }
        }
    }
}