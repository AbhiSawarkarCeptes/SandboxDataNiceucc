global class PSM_HO_Handover_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public static String CLASS_NAME = 'PSM_HO_Handover_Batch';
    private List<Id> recordIds; // To hold the provided record IDs
    private String queryParam;
    
     // Default Constructor
    public PSM_HO_Handover_Batch() {
    }

    // Constructor to accept record IDs
    public PSM_HO_Handover_Batch(List<Id> ids) {
        this.recordIds = ids;
    }
    
    // Constructor to accept query as param
    public PSM_HO_Handover_Batch(String qParam) {
        this.queryParam = qParam;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'select Id,Name,RecordTypeId,RecordType.Name,CRM_Excutive__c,Proposed_Scheduled_Date__c,Booking__c,Scheduled_Date__c,Status__c,Remarks__c,QT_Keepout_Date__c,Third_party_snagging__c from Time_Slot_For_Handover__c WHERE Booking__c != NULL';
        //return Database.getQueryLocator(query);
        //
        String query;

        // If record IDs are provided, query only those records
        if (recordIds != null && !recordIds.isEmpty()) {
            query = 'select Id,Name,RecordTypeId,RecordType.Name,CRM_Excutive__c,Proposed_Scheduled_Date__c,Booking__c,Scheduled_Date__c,Status__c,Remarks__c,QT_Keepout_Date__c,Third_party_snagging__c,Timings__c from Time_Slot_For_Handover__c WHERE Booking__c IN :recordIds';
        } else if (String.isNotEmpty(queryParam)) {
            query = queryParam;
        } else {
            // Query all records if no IDs are provided
            query = 'select Id,Name,RecordTypeId,RecordType.Name,CRM_Excutive__c,Proposed_Scheduled_Date__c,Booking__c,Scheduled_Date__c,Status__c,Remarks__c,QT_Keepout_Date__c,Third_party_snagging__c,Timings__c from Time_Slot_For_Handover__c WHERE Booking__c != NULL';
        }
        system.debug('Hi' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Time_Slot_For_Handover__c> scope) {
        Map<Id,Time_Slot_For_Handover__c> timeSlotAndHandoverMap =  new Map<Id,Time_Slot_For_Handover__c>();
        Map<Id,Time_Slot_For_Handover__c> timeSlotAndOrientationMap =  new Map<Id,Time_Slot_For_Handover__c>();
        List<PropStrength__Application_Booking__c> appBookingList = new   List<PropStrength__Application_Booking__c>();
        for(Time_Slot_For_Handover__c tslot : scope){
            if(tslot.RecordType.Name == 'HandOver' ){
                timeSlotAndHandoverMap.put(tslot.Booking__c, tslot); 
            }
            else if(tslot.RecordType.Name == 'Home Orientation' ){
                timeSlotAndOrientationMap.put(tslot.Booking__c, tslot);   
            }
            SYSTEM.DEBUG('hello' + timeSlotAndOrientationMap);
        }
        For(PropStrength__Application_Booking__c apBooking : [SELECT ID,Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c
                                                              WHERE Legacy_Booking_Id__c IN : timeSlotAndHandoverMap.keySet() OR  Legacy_Booking_Id__c IN : timeSlotAndOrientationMap.keySet()]){
               apBooking.Home_Orientation_Executive_Name_V1__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).CRM_Excutive__c;
			   apBooking.Proposed_Home_Orientation_Scheduled_Date__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).Proposed_Scheduled_Date__c;
			   apBooking.Home_Orientation_Scheduled_Date__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).Scheduled_Date__c;
               apBooking.Home_Orientation_Slot_Status__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).Status__c;
               apBooking.Home_Orientation_Remark__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).Remarks__c;
               apBooking.Home_Orientation_QT_Keepout_Date__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).QT_Keepout_Date__c;
               apBooking.Home_Orientation_Time__c = timeSlotAndOrientationMap.get(apBooking.Legacy_Booking_Id__c).Timings__c;
                                                                                                                                    
               apBooking.Snag_Status__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).Third_party_snagging__c;
               apBooking.QT_Keep_out_Date__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).QT_Keepout_Date__c;
               apBooking.Handover_CRM_Executive_v1__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).CRM_Excutive__c;
               apBooking.Slot_Scheduled_Date__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).Scheduled_Date__c;
               apBooking.Slot_Status__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).Status__c;
               apBooking.Slot_Remarks__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).Remarks__c;
               apBooking.Timings__c = timeSlotAndHandoverMap.get(apBooking.Legacy_Booking_Id__c).Timings__c;
            appBookingList.add(apBooking); 
        }
        if(appBookingList.size() > 0) {
            Database.SaveResult[] BookingListData = Database.Update(appBookingList, TRUE);
            trackDML(CLASS_NAME, BookingListData);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    
    public static void trackDML(String className, Database.SaveResult[] srList) {
        List<Error_log__c> allErrorList = new List<Error_log__c>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted record. Record ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors 
                String errorsCombined = '';               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Object fields that affected this error: ' + err.getFields());
                    errorsCombined += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                }
                
                Error_Log__c trackRec = new Error_Log__c(Class__c = className, Message__c = errorsCombined );
                allErrorList.add(trackRec);
            }
        }
        if(allErrorList.size() > 0) {
            Database.insert(allErrorList, false);
        }
    }
}