public  without sharing class CaseController {
    
    @AuraEnabled(cacheable=false)
    public static string createCase(String email, String phone, String Remarks,String Subject) {
        
        try{
            String userName = UserInfo.getUserId();
            
            List<User> lstUser = [SELECT ContactId, AccountId FROM User WHERE Id = :userName];
            
            List<Channel_Partner__c> partners = [SELECT Channel_Relationship_Manager__c FROM Channel_Partner__c WHERE Contact__c = :lstUser[0].ContactId];
            String OwnerId ;
            if(partners.size()>0 ){
                OwnerId =partners[0].Channel_Relationship_Manager__c;
            }else{
                List<Sobha_Connect__c> Sobhapartners = [SELECT Channel_Relationship_Manager__c FROM Sobha_Connect__c WHERE Contact__c = :lstUser[0].ContactId];
                if(Sobhapartners.size()>0) OwnerId = Sobhapartners[0].Channel_Relationship_Manager__c; 
            }
            
            //create case record
            
            Case newCase = new Case();
            
            newCase.SuppliedEmail = email;
            // newCase.ContactEmail = email;
            newCase.SuppliedPhone = phone;
            newCase.Description = Remarks;
            newCase.Subject = Subject;
            if(OwnerId!=Null){  
                newCase.OwnerId = OwnerId ;
            }
            System.debug('contact Id '+lstUser[0].ContactId);
            System.debug('AccountId Id '+lstUser[0].AccountId);
            newCase.ContactId = lstUser[0].ContactId;
            newCase.AccountId = lstUser[0].AccountId;
            newCase.Origin = 'Broker Portal';
            newCase.Priority = 'High';
            newCase.Status = 'New';
            newCase.Type = 'Query';
            
            
            //Get the record type Id for "Channel Partner"
            Id channelPartnerRecordTypeId = getRecordTypeId('Channel_Partner');
            System.debug('channelPartnerRecordTypeId : '+channelPartnerRecordTypeId);
            //Set the record type Id for the new Case
            newCase.RecordTypeId = channelPartnerRecordTypeId;
            
            insert newCase;
            sendEmail(email);
            
            return newCase.Id;
        }catch(Exception e){
            System.debug('Exception is : '+e.getMessage() + ' => ' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }
    }
    @AuraEnabled(cacheable=true)
    public static TemplateInfo fetchEmailTemplateInfo(String templateName) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        return new TemplateInfo(template.Subject, template.Body);
    }
    // Helper method to get the record type Id based on developer name
    private static Id getRecordTypeId(String developerName) {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = :developerName LIMIT 1];
        return rt.Id;
    }
    @AuraEnabled
    public static void sendEmail(String emailAddress) {
        String currentUser = UserInfo.getName(); 
        // body = body.replace('<User Name>', currentUser); 
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'CreateEnquiry' LIMIT 1];
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{emailAddress});
        email.setSubject(template.subject);
        email.setHtmlBody(template.body);
        try {
                    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});

        }
        catch(exception e) {
            system.debug('email failed');	
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getAllCasesByCurrentUser() {
        String userId = UserInfo.getUserId();
        
        return [SELECT Id, Subject,CreatedDate,Description, CaseNumber, SuppliedEmail, ClosedDate,SuppliedPhone,Status
                FROM Case
                WHERE CreatedById = :userId
                ORDER BY CreatedDate DESC];
    }
    // Custom exception class for handling access errors
    public class NoAccessException extends Exception {}
    public class TemplateInfo {
        @AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String Body { get; set; }
        
        public TemplateInfo(String subject, String body) {
            this.Subject = subject;
            this.Body = body;
        }
    }
}