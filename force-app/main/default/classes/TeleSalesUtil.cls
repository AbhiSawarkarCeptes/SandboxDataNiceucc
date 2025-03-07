public without sharing class TeleSalesUtil {
    public static void createTeleSalesAPILogs(string apiName,string className,string requestBody,string responseBody,string errorMsg,string stackTrace){
        CTI_Logs__c log = new CTI_Logs__c();
        log.API_Name__c = (apiName!=null && apiName!='')?apiName:'';
        log.Class_Name__c = (className!=null && className!='')?className:'';
        log.Error_Message__c = (errorMsg!=null && errorMsg!='')?errorMsg:'';
        log.Request_Body__c = (requestBody!=null && requestBody!='')?requestBody:'';
        log.Response_Body__c = (responseBody!=null && responseBody!='')?responseBody:'';
        log.Stack_Trace__c = (stackTrace!=null && stackTrace!='')?stackTrace:'';
        insert log;
    }
    
    @AuraEnabled
    public static string createTask(string opptyId, string mobileNumber){
        try{
            Opportunity oppty = [select Id,OwnerId from Opportunity where Id=:opptyId];
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                .get('Presales and Sales').getRecordTypeId();
            Task t = new Task();
            t.RecordTypeId = recordTypeId;
            t.Task_Type__c = 'Presales Call';
            t.Subject = 'Outbound Call to ' + mobileNumber + ' on ' + System.now().format();
            t.WhatId = opptyId;
            t.ActivityDate = System.today();
            t.Communication_Type__c = 'Outbound Call';
            t.CallType = 'Outbound';
            t.OwnerId = oppty.OwnerId;
            t.Mobile_Number_Webform__c = mobileNumber;
            insert t;
            return 'success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string createTaskOnAccount(string accId, string mobileNumber){
        try{
            Account acc = [select Id,OwnerId from Account where Id=:accId];
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName()
                .get('Presales and Sales').getRecordTypeId();
            Task t = new Task();
            t.RecordTypeId = recordTypeId;
            t.Task_Type__c = 'Presales Call';
             t.Subject = 'Outbound Call to ' + mobileNumber + ' on ' + System.now().format();
            t.WhatId = accId;
            t.ActivityDate = System.today();
            t.Communication_Type__c = 'Outbound Call';
            t.CallType = 'Outbound';
            t.OwnerId = acc.OwnerId;
            t.Mobile_Number_Webform__c = mobileNumber;
            insert t;
            return 'success';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
}