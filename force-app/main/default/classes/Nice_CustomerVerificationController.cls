/***************************************************************************
Class      : Nice_CustomerVerificationController
Test Class : Nice_CustomerVerificationTest
Purpose    : Nice - An Apex class helps in the manual verification process when a customer calls from an unregistered number 
             by returning the verification questions and answers and logging the user-provided answers in the system.
Author     : Ashok Kumar M
*****************************************************************************/
public with sharing class Nice_CustomerVerificationController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> fetchQuestionsAndAnswers(String recordId) {
        
        String objectName = getObjectNameFromRecordId(recordId);
        String accId;
        
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Make sure the recordId is valid.');
        }
        
        if (objectName == 'Task__c') {
            
            Task__c taskRecord = [SELECT Id, Name, Account__c 
                                  FROM Task__c 
                                  WHERE Id = :recordId AND Account__c != Null WITH USER_MODE LIMIT 1 ] ?? Null;
            
            if(taskRecord == Null) {
                throw new AuraHandledException('The Task should associate with account record to proceed for customer verification.');
            }
            
            accId  = taskRecord.Account__c;
        } else if (objectName == 'Account') {
            accId  = recordId;
        }
        
        List<Customer_Verification_Configuration__mdt> metadataRecords = getRandomMetadataRecords();
        if (metadataRecords.isEmpty()) {
            throw new AuraHandledException('No questions configured for this object.');
        }
        
        Set<String> fieldSet = new Set<String>();
        for (Customer_Verification_Configuration__mdt record : metadataRecords) {
            fieldSet.add(record.Answer_Field_API_Name__c);
        }
        
        String fields = String.join(new List<String>(fieldSet), ', ');
        String query = 'SELECT ' + fields + ' FROM Account WHERE Id = :accId';
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('accId', accId);
        SObject record = Database.QueryWithBinds(query, bindParams, AccessLevel.USER_MODE);
        
        Map<String, String> questionAnswerMap = new Map<String, String>();
        for (Customer_Verification_Configuration__mdt recordMeta : metadataRecords) {
            String fieldValue = (String) record.get(recordMeta.Answer_Field_API_Name__c);
            questionAnswerMap.put(recordMeta.Question__c, fieldValue != null ? fieldValue : 'Not Available');
        }
        
        return questionAnswerMap;
        
    }
    
    @AuraEnabled
    public static void createCustomerVerificationLog(String cvLogs, String recordId, String status) {
        
        try{
            
            if (!Schema.sObjectType.Customer_Verification__c.isCreateable() || !Schema.sObjectType.Customer_Verification_Log__c.isCreateable()) {
                throw new AuraHandledException('Oops! You do not have permission to create this record. Reach out to your administrator for help.');
            }
            
            String verificationId = createCustomerVerificationRecord(recordId, status);
            
            List<Object> cvLogsList = (List<Object>) JSON.deserializeUntyped(cvLogs);
            List<Customer_Verification_Log__c> logsToInsert = new List<Customer_Verification_Log__c>();
            for (Object logItem : cvLogsList) {
                Map<String, Object> logMap = (Map<String, Object>) logItem;
                
                Customer_Verification_Log__c log = new Customer_Verification_Log__c();
                log.Customer_Verification__c = verificationId;
                log.Question_Asked__c = (String) logMap.get('question');
                log.Expected_Answer__c = (String) logMap.get('expectedAnswer');
                log.Actual_Answer__c = (String) logMap.get('actualAnswer');
                log.Is_Valid_Answer__c = (String) logMap.get('isValidAnswer');
                logsToInsert.add(log);
            }
            
            if (!logsToInsert.isEmpty()) {
                insert logsToInsert;
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    private static String createCustomerVerificationRecord(String recordId, String status) {
        
        try {
            
            String objectName = getObjectNameFromRecordId(recordId);
            
            if (objectName == null || (objectName != 'Account' && objectName != 'Task__c')) {
                throw new AuraHandledException('Invalid object type. Customer verification not supported for this Object.');
            }
            
            Customer_Verification__c customerVerification = new Customer_Verification__c();
            customerVerification.Customer_Verified_Date_Time__c = System.now();
            customerVerification.Customer_Verification_Status__c = status;
            customerVerification.Customer_Verified_By__c = UserInfo.getUserId();
            
            if (objectName == 'Task__c') {
                customerVerification.Task__c = recordId;
            } else if (objectName == 'Account') {
                Task__c tsk = getLatestTaskRecord(recordId);
                if (tsk != Null) {
                    customerVerification.Task__c = tsk.Id;
                } else {
                    customerVerification.Account__c = recordId;
                }
            }
            
            insert customerVerification;
            return customerVerification.Id;
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    public static List<Customer_Verification_Configuration__mdt> getRandomMetadataRecords() {
        
        List<Customer_Verification_Configuration__mdt> metadataRecords = [SELECT Question__c, Answer_Field_API_Name__c 
                                                                          FROM Customer_Verification_Configuration__mdt 
                                                                          WHERE Answer_Field_API_Name__c != Null
                                                                          WITH USER_MODE LIMIT 2000];
        
        Integer questionCount = Integer.valueOf(System.Label.Customer_Verification_Question_Count);
        if (metadataRecords.size() <= questionCount) {
            return metadataRecords;
        }
        
        List<Customer_Verification_Configuration__mdt> randomRecords = new List<Customer_Verification_Configuration__mdt>();
        Integer totalRecords = metadataRecords.size();
        Set<Integer> randomIndexes = new Set<Integer>();
        
        while (randomIndexes.size() < questionCount) {
            Integer randomIndex = Math.floor(Math.random() * totalRecords).intValue();
            randomIndexes.add(randomIndex);
        }
        
        for (Integer index : randomIndexes) {
            randomRecords.add(metadataRecords[index]);
        }
        
        return randomRecords;
        
    }
    
    private static Task__c getLatestTaskRecord(String recordId) {
        
        return [SELECT Id, Name FROM Task__c 
                WHERE Account__c = :recordId WITH USER_MODE ORDER 
                By CreatedDate LIMIT 1] ?? Null;
        
    }
    
    private static String getObjectNameFromRecordId(String recordId) {
        
        try {
            return Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            return null;
        }
        
    }
    
}