//Test Class: PSM_Booking_Title_Deed_Batch_Test
/* String inputQuery = 'SELECT Id, Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c WHERE Legacy_Booking_Id__c!=NULL LIMIT 5';
private Set<Id> recordIds=  new Set<Id>{  'a423N000000Aex2QAC' };
* */
global class PSM_Booking_Title_Deed_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    public static String CLASS_NAME = 'PSM_Booking_Title_Deed_Batch';
    private List<Id> recordIds;
    private String inputQuery; 
    
  
    // Constructor to accept record IDs
    public PSM_Booking_Title_Deed_Batch(List<Id> recordIds) {
        this.recordIds = recordIds;
    }
      public PSM_Booking_Title_Deed_Batch(String inputQuery){
        this.inputQuery = inputQuery;
    }
    public PSM_Booking_Title_Deed_Batch(){
         this.recordIds = NULL;
         this.inputQuery = '';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        
        if (recordIds != null && !recordIds.isEmpty()) {
            // Use provided record IDs
            query = 'SELECT Id, Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c WHERE Legacy_Booking_Id__c!=NULL AND Legacy_Booking_Id__c IN :recordIds';
        }  else if(String.IsNotBlank(inputQuery))
        {
             return Database.getQueryLocator(inputQuery);
        }else {
            // Default behavior if no query, no IDs  are provided
            query = 'SELECT Id, Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c WHERE Legacy_Booking_Id__c!=NULL';
        }
        
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> psBookings) {
        
        system.debug('HELLO' + psBookings);
        
        Map<String, PropStrength__Application_Booking__c> applBookingIdMap = 
            new Map<String, PropStrength__Application_Booking__c>();
        Set<Id> applBookingIdSet = new  Set<Id>();
        List<Booking__c> bookings = new   List<Booking__c>();
        List<PropStrength__Application_Booking__c> updateApplBookings = 
            new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Transaction_Requests__c> insertTransReqs = 
            new List<PropStrength__Transaction_Requests__c>();
        
        for(PropStrength__Application_Booking__c psBooking : psBookings)
        {
            applBookingIdSet.add(psBooking.Legacy_Booking_Id__c);
            applBookingIdMap.put(psBooking.Legacy_Booking_Id__c, psBooking);
        }
        
        bookings = [SELECT Id, Name,Pre_Registration_Remarks__c,Title_Transfer_Date__c,
                    Date_of_Pre_Registration_Initiation__c,Date_of_Pre_registration_Completion__c,
                    DLD_Amount_Paid_In__c,Pre_registration__c,Is_Pre_registration_Fees_Paid__c,
                    Title_Deed_Status__c,Title_Transfer_Completed__c,Title_Transfer_Status__c
                    FROM Booking__c WHERE Id IN :applBookingIdSet];
        
        for(Booking__c booking : bookings){
            
            bypassTitleDeedExceptions(applBookingIdMap.get(booking.Id));
            insertTransReqs.addAll(createTransRequest(booking, applBookingIdMap.get(booking.Id).Id));
            updateApplBookings.add(updateApplBooking(booking,applBookingIdMap.get(booking.Id)));
            
        }
        
        
        if(updateApplBookings.size() > 0) {
            System.debug('INSIDE UPDATE AB');
            Database.SaveResult[] srList = Database.update(updateApplBookings, true);
            trackDML(CLASS_NAME, srList);
        }
        if(insertTransReqs.size() > 0) {
            System.debug('INSIDE INSERT TR');
            for(PropStrength__Transaction_Requests__c req: insertTransReqs) {
                System.debug(req.PropStrength__Application_Booking_Id__c);
            }
            Database.SaveResult[] srList = Database.insert(insertTransReqs, true);
            trackDML(CLASS_NAME, srList);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        System.debug('Batch process completed successfully.');
    }
    
    public static List<PropStrength__Transaction_Requests__c> createTransRequest(Booking__c booking, String applBookingId){
        List<PropStrength__Transaction_Requests__c> transReqs = new List<PropStrength__Transaction_Requests__c>();
        try{
            // Query the RecordType IDs for the desired Developer Names
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for (RecordType rt : [
                SELECT Id, DeveloperName 
                FROM RecordType 
                WHERE SObjectType = 'PropStrength__Transaction_Requests__c' 
                AND DeveloperName IN ('Title_Deed_Process', 'Pre_Registration_Process')
            ]) {
                recordTypeMap.put(rt.DeveloperName, rt.Id);
            }
            
            // Create Title Deed Transaction Request
            PropStrength__Transaction_Requests__c tileDeedTransReq = new PropStrength__Transaction_Requests__c();
            tileDeedTransReq.RecordTypeId = recordTypeMap.get('Title_Deed_Process');
            tileDeedTransReq.PropStrength__Application_Booking__c = applBookingId;
            tileDeedTransReq.PropStrength__Application_Booking_Id__c = applBookingId;
            tileDeedTransReq.PropStrength__Status__c = booking.Title_Transfer_Completed__c;
            tileDeedTransReq.Date_of_Title_Transfer_Completion__c = booking.Title_Transfer_Date__c;
            transReqs.add(tileDeedTransReq);
           
        }Catch(Exception e){
            System.debug('Batch Error:::'+e.getMessage());
        }
        
        return transReqs;
    }
    
    public static PropStrength__Application_Booking__c updateApplBooking(Booking__c booking, PropStrength__Application_Booking__c applBooking){
        
        applBooking.Title_Deed_Transfer_Executed__c = booking.Title_Transfer_Status__c;
        applBooking.Title_Deed_Status__c = booking.Title_Transfer_Completed__c;
        applBooking.Title_Deed_Sent_Date__c = booking.Title_Transfer_Date__c;
        
        return applBooking;
    }
    
     public static void bypassTitleDeedExceptions(PropStrength__Application_Booking__c applBooking){
        
        applBooking.Title_Deed_Process_Exception__c = TRUE;
        update applBooking;
         
         String recordTypeName = 'Title Deed Process';
        List<PropStrength__Transaction_Requests__c> transactionList = [SELECT Id from PropStrength__Transaction_Requests__c 
                                                        WHERE 
                                                        PropStrength__Application_Booking__c = :applBooking.Id
                                                        AND recordType.Name = :recordTypeName];
        if(transactionList.size() > 0) {
             delete transactionList;
         }
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