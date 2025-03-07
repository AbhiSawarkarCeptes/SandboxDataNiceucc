global class ApprovalEmailForBrokerRegController {
    global static Id currentId {get;set;}
    public static list<string> mandatoryFileList {get;set;} 
    public static list<String> optionalFiles {get;set;}
    public static String registrationlink {get;set;}
    public static String mailSentDate {get;set;}
    public static String createdDate {get;set;}
    public static String commentstext {get;set;}
    public static Boolean showLinkActiveContent {get;set;}
    
    
    
    public static Broker_Registration__c getrelatedTo() {
        /*list<String> comments = getLatestApprovalComments(currentId);
        if(comments.size()>0){
            commentstext=comments[0];    
        }else{
            commentstext=''; 
        }*/
        String comments = getLatestApprovalCommentNew(currentId);
        if(comments!=null){
            commentstext=comments;    
        }else{
            commentstext=''; 
        }
        
        system.debug('etntecontroller');
        Broker_Registration__c brg =  [
            Select id,Name,Comments__c,Owner.Name,Days_since_Agreement_shared__c,CreatedBy.Name,CHRM_Manager__r.Name,Broker_Category__c,frmCHRMMgrName__c,Registration_Link__c,frmBrokerRegistrationName__c,Broker_Created_Date__c,CHRM_ManagerHead__r.name,Status__c,First_Name__c,Last_Name__c,
            list_of_missing_documents__c, Missing_Documents__c, recordtype.name
            FROM Broker_Registration__c where id=:currentId];
        DateTime currentDateTime = DateTime.now();
        mailSentDate =formatDateTime(currentDateTime);
        if(brg.Broker_Created_Date__c!=null){
            createdDate=formatDateTime(brg.Broker_Created_Date__c);  
        }
        showLinkActiveContent = true;
        if(brg.recordtype.name=='Renewal'){
            showLinkActiveContent = false;
        }
        
        
        
        mandatoryFileList = new list<string>();
        optionalFiles = new list<String>();
        if(brg.Registration_Link__c != null){
             registrationlink=brg.Registration_Link__c;
        }
        if(brg.Broker_Category__c != null){
        	getMandatoryFiles(brg.Broker_Category__c);    
        }
        
        return brg;
    }
    
    public static list<String> getMandatoryFiles(String brokerCat){
        system.debug(brokerCat);
        //list<string> mandatoryFileList = new list<string>();
        List<brokerCategoryMandatoryFiles__mdt> mandatoryFile = [select id,Label, MasterLabel,MandatoryFiles__c,OptionalFiles__c  from brokerCategoryMandatoryFiles__mdt where Label = :brokerCat];
        //mandatoryFileList.addAll(mandatoryFile);
        for(brokerCategoryMandatoryFiles__mdt file: mandatoryFile){
            for(string st : file.MandatoryFiles__c.split(',')){
                mandatoryFileList.add(st);
            }
            // Process Optional Files
            if(file.OptionalFiles__c!=null){
                for (String optFile : file.OptionalFiles__c.split(',')) {
                    optionalFiles.add(optFile);
                }    
            }
            
        }
        
        system.debug(mandatoryFileList);
        
        return mandatoryFileList;
        
        
        
    }
    public static List<String> getLatestApprovalComments(Id recordId) {
        List<String> latestApprovalComments = new List<String>();
        
        // Query ProcessInstance and ProcessInstanceStep records for the given recordId
        List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :recordId];
        
        if (processInstances.isEmpty()) {
            return latestApprovalComments; // No approval process for the given recordId
        }
        
        Map<Id, List<ProcessInstanceStep>> stepsMap = new Map<Id, List<ProcessInstanceStep>>();
        
        if(processInstances != null){
            List<ProcessInstanceStep> steps = [SELECT Id, StepStatus, Comments, CreatedDate,ProcessInstanceId
                                               FROM ProcessInstanceStep 
                                               WHERE ProcessInstanceId IN :processInstances
                                               ORDER BY CreatedDate DESC];
            for (ProcessInstanceStep step : steps) {
                if (!stepsMap.containsKey(step.ProcessInstanceId)) {
                    stepsMap.put(step.ProcessInstanceId, new List<ProcessInstanceStep>());
                }
                stepsMap.get(step.ProcessInstanceId).add(step);
            }
        }
        
        
        
        // Group ProcessInstanceSteps by ProcessInstanceId
        
        
        // Loop through ProcessInstance records and retrieve the latest comment from stepsMap
        for (ProcessInstance processInstance : processInstances) {
            if (stepsMap.containsKey(processInstance.Id)) {
                List<ProcessInstanceStep> instanceSteps = stepsMap.get(processInstance.Id);
                if (!instanceSteps.isEmpty()) {
                    ProcessInstanceStep latestStep = instanceSteps[0]; // The first entry is the latest one due to the sorting
                    latestApprovalComments.add(latestStep.Comments);
                }
            }
        }
        
        return latestApprovalComments;
    }
    
    public Static String formatDateTime(DateTime dt) {
        return dt.format('dd/MM/yyyy hh:mm a', 'Asia/Dubai');
    }
    
    
    
    public static String getLatestApprovalCommentNew(String registrationId) {
         List<String> latestApprovalComments = new List<String>();

    // Query ProcessInstance and ProcessInstanceStep records for the given recordId
    List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId 
                                              FROM ProcessInstance 
                                              WHERE TargetObjectId = :registrationId];
    String returnString;
    if (processInstances.isEmpty()) {
        return returnString; // No approval process for the given recordId
    }
    
    Map<Id, List<ProcessInstanceStep>> stepsMap = new Map<Id, List<ProcessInstanceStep>>();

    List<ProcessInstanceStep> steps = [SELECT Id, StepStatus, Comments, CreatedDate, ProcessInstanceId
                                       FROM ProcessInstanceStep 
                                       WHERE ProcessInstanceId IN :processInstances
                                       ORDER BY CreatedDate DESC LIMIT 1];

    // Group ProcessInstanceSteps by ProcessInstanceId
    for (ProcessInstanceStep step : steps) {
        if (!stepsMap.containsKey(step.ProcessInstanceId)) {
            stepsMap.put(step.ProcessInstanceId, new List<ProcessInstanceStep>());
        }
        stepsMap.get(step.ProcessInstanceId).add(step);
    }
    
    // Loop through ProcessInstance records and retrieve the latest comment from stepsMap
    for (ProcessInstance processInstance : processInstances) {
        if (stepsMap.containsKey(processInstance.Id)) {
            List<ProcessInstanceStep> instanceSteps = stepsMap.get(processInstance.Id);
            if (!instanceSteps.isEmpty()) {
                ProcessInstanceStep latestStep = instanceSteps[0]; // The first entry is the latest one due to the sorting
                latestApprovalComments.add(latestStep.Comments);
                returnString=latestStep.Comments;
            }
        }
    }

    return returnString;
    }
    
    
    
}