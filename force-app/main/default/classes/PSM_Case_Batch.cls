//Test Class - PSM_Case_Batch_Test
/* String inputQuery = SELECT Id, OwnerId, AccountId, Subject, CreatedDate, IsClosedOnCreate, PropStrength__Application_Booking__c, RecordTypeId, CaseNumber, ContactId, Status, Type, Priority, Origin, Description, ClosedDate, SuppliedName, SuppliedEmail, SuppliedPhone, Comments, ContactEmail, ContactPhone FROM Case;
private Set<Id> recordIds=  new Set<Id>{  'a423N000000Aex2QAC' };
* */
global class PSM_Case_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    public static String CLASS_NAME = 'PSM_Case_Batch';
    private List<Id> recordIds; // To hold the provided record IDs
    private String queryParam;
    
     // Constructor to accept record IDs
    public PSM_Case_Batch() {
    }

    // Constructor to accept record IDs
    public PSM_Case_Batch(List<Id> ids) {
        this.recordIds = ids;
    }
    
    // Constructor to accept query as param
    public PSM_Case_Batch(String qParam) {
        this.queryParam = qParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query;

        // If record IDs are provided, query only those records
        if (recordIds != null && !recordIds.isEmpty()) {
            query = 'SELECT Id, Booking__c, Booking__r.Name, OwnerId, AccountId, Subject, CreatedDate, IsClosedOnCreate, PropStrength__Application_Booking__c, RecordTypeId, RecordType.Name, CaseNumber, ContactId, Status, Type, Priority, Origin, Description, ClosedDate, SuppliedName, SuppliedEmail, SuppliedPhone, Comments, ContactEmail, ContactPhone,Re_Opened_Timestamp__c,Department__c,Category__c,Sub_Category__c,Relationship_Manager__c,Escalation_Date_Time__c FROM Case WHERE Id IN :recordIds';
        } else if (String.isNotEmpty(queryParam)) {
            query = queryParam;
        } else {
            // Query all records if no IDs are provided
            query = 'SELECT Id, Booking__c, Booking__r.Name, OwnerId, AccountId, Subject, CreatedDate, IsClosedOnCreate, PropStrength__Application_Booking__c, RecordTypeId, RecordType.Name, CaseNumber, ContactId, Status, Type, Priority, Origin, Description, ClosedDate, SuppliedName, SuppliedEmail, SuppliedPhone, Comments, ContactEmail, ContactPhone,Re_Opened_Timestamp__c,Department__c,Category__c,Sub_Category__c,Relationship_Manager__c,Escalation_Date_Time__c FROM Case';
        }

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        
        Map<String,Id> srRecordTypeNameToId = new Map<String,Id>();
        for(RecordType rt : [Select Id,Name from RecordType where SobjectType = 'PropStrength__Service_Request__c']){
            srRecordTypeNameToId.put(rt.Name,rt.Id);
        }
        
        set<String> bookingSet = new set<String>();
        for(Case ca : caseList){
            if(ca.Booking__c != null){
                bookingSet.add(ca.Booking__r.Name);
            }
        }
        Map<String,String> legacyBookingToAppBooking = new Map<String,String>();
        for(PropStrength__Application_Booking__c ab : [select Id,Lagecy_Booking__c from PropStrength__Application_Booking__c where Lagecy_Booking__c IN: bookingSet]){
            legacyBookingToAppBooking.put(ab.Lagecy_Booking__c,ab.Id);
        }
        
        Map<String,String> caseToSR = new Map<String,String>();
        caseToSR.put('Channel Partner','Channel Partner');
        caseToSR.put('Collection','Collection');
        caseToSR.put('CRM','CRM');
        //caseToSR.put('Customer Care','');
        caseToSR.put('Siniya Customer Care','Siniya Customer Care');
        caseToSR.put('Sobha Community Management','Sobha Community Management');
        
        List<PropStrength__Service_Request__c> srList = new   List<PropStrength__Service_Request__c>();
        Map<Id,String> casenumberAndCaseIdMap = new Map<Id,String>();
        Map<String,Id> caseNumberAndPsIdMap =  new Map<String,Id>();
        List<PropStrength__Email__c> strengthEmaillst = new List<PropStrength__Email__c>();
        for(Case ca : caseList){
            casenumberAndCaseIdMap.put(ca.Id,ca.CaseNumber);
            PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
            sr.OwnerId = ca.OwnerId;
            sr.PropStrength__Account__c = ca.AccountId;
            sr.PropStrength__Subject__c = ca.Subject;
            sr.IsClosed__c = ca.IsClosedOnCreate;
            if(ca.PropStrength__Application_Booking__c != null){
                sr.PropStrength__Application_Booking__c = ca.PropStrength__Application_Booking__c;
            }
            else if(ca.Booking__c != null && legacyBookingToAppBooking.containsKey(ca.Booking__r.Name)){
                sr.PropStrength__Application_Booking__c = legacyBookingToAppBooking.get(ca.Booking__r.Name);
            }
            if(caseToSR.containsKey(ca.RecordType.Name) && srRecordTypeNameToId.containsKey(caseToSR.get(ca.RecordType.Name))){
                sr.RecordTypeId = srRecordTypeNameToId.get(caseToSR.get(ca.RecordType.Name));
            }
            //sr.Name = ca.CaseNumber; Autonumber
            sr.PropStrength__Contact__c = ca.ContactId;
            sr.Re_Opened_Timestamp__c = ca.Re_Opened_Timestamp__c;// No field named Re_Opened_Timestamp__c on Case
            sr.PropStrength__Status__c = ca.Status;
            sr.PropStrength__SR_Type__c = ca.Type;
            sr.PropStrength__Priority__c  = ca.Priority;
            sr.SR_Department__c = ca.Department__c;//No field named Department__c on Case
            sr.PropStrength__Origin__c = ca.Origin;
            sr.SR_Category__c = ca.Category__c;//No field named Category__c on Case
            sr.SR_Sub_Category__c = ca.Sub_Category__c;//No field named Sub_Category__c on Case
            sr.Relationship_Manager__c = ca.Relationship_Manager__c;//No field named Relationship_Manager__c on Case  
            sr.PropStrength__Description__c = ca.Description;
            sr.SR_Closed_Date__c = ca.ClosedDate;
            sr.Escalation_Date_Time__c = ca.Escalation_Date_Time__c;//No field named Escalation_Date_Time__c on Case
            sr.PropStrength__Supplied_Name__c = ca.SuppliedName;
            sr.PropStrength__Supplied_Email__c = ca.SuppliedEmail;
            sr.PropStrength__Supplied_Phone__c = ca.SuppliedPhone;
            sr.PropStrength__Comments__c = ca.Comments;
            sr.PropStrength__Contact_Email__c = ca.ContactEmail;
            sr.PropStrength__Contact_Phone__c = ca.ContactPhone;
            sr.Case_ID__c = ca.Id;
            srList.add(sr);
            
        }
        
        if(srList.size() > 0) {
            Database.SaveResult[] srListData = Database.Insert(srList, false);
            trackDML(CLASS_NAME, srListData);
        }
        
        For( PropStrength__Service_Request__c ps : srList){
            caseNumberAndPsIdMap.put(ps.Name, ps.Id);
        }
        For(EmailMessage em : [select Id, ParentId, Status, MessageDate, FromAddress, FromName, ToAddress, CcAddress, BccAddress, Subject,
                               HtmlBody, TextBody from EmailMessage WHERE ParentId IN : casenumberAndCaseIdMap.keySet()])
        {
            PropStrength__Email__c email = new PropStrength__Email__c(PropStrength__Service_Request__c = caseNumberAndPsIdMap.get(casenumberAndCaseIdMap.get(em.ParentId)),
                                                                      PropStrength__Status__c = em.Status,PropStrength__Message_Date__c = em.MessageDate ,
                                                                      PropStrength__From_Address__c = em.FromAddress,PropStrength__From_Name__c = em.FromName,PropStrength__To_Address__c = em.ToAddress,
                                                                      PropStrength__CC_Address__c = em.CcAddress,PropStrength__BCC_Address__c = em.BccAddress,PropStrength__Subject__c = em.Subject,
                                                                      PropStrength__HTML_Body__c = em.HtmlBody, PropStrength__Plain_Text_Body__c = em.TextBody);
            strengthEmaillst.add(email);
        }
        if(strengthEmaillst.size() > 0) {
            Database.SaveResult[] emailListData = Database.Insert(strengthEmaillst, false);
            trackDML(CLASS_NAME, emailListData);
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