public class AuditRefundDBController {
    @AuraEnabled
    public static List<TransactionRequestWrapper> transactionRequestRecord(String projectId,String towerId,List<String> refundStatus) {
        List<PropStrength__Transaction_Requests__c> trList = new List<PropStrength__Transaction_Requests__c>();
        System.debug(projectId+'---*--'+towerId+'*---*--'+refundStatus);
        
        if (towerId != 'All') {
            trList = [SELECT Id, Name, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.House_Unit_No__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__r.Name, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Application_Booking__r.Name,
                    PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c, PropStrength__Application_Booking__r.PropStrength__Booking_Date__c, 
                    Refund_Initiated_By__c, Refund_Payment_Mode__c, Type_of_Termination__c, Termination_Refund_Status__c, 
                    PropStrength__Application_Booking__r.PropStrength__Total_Agreement_Amount__c, PropStrength__Application_Booking__r.PropStrength__Total_Payment_Received__c, 
                    PropStrength__Application_Booking__r.Total_Recurring_Interest_Till_Date__c, PropStrength__Final_Refund_Amount__c 
                    FROM PropStrength__Transaction_Requests__c 
                    WHERE RecordType.Name = 'Refund' AND PropStrength__Refund_Type__c = 'Termination Refund' AND PropStrength__Status__c != 'Rejected' 
                    AND PropStrength__Status__c != 'Request Completed' 
                    AND Termination_Refund_Status__c IN :refundStatus
                    AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =:projectId 
                    AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__c =: towerId];
        } else {
            trList = [SELECT Id, Name, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.House_Unit_No__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__c, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__r.Name, 
                    PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, PropStrength__Application_Booking__r.Name,
                    PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c, PropStrength__Application_Booking__r.PropStrength__Booking_Date__c, 
                    Refund_Initiated_By__c, Refund_Payment_Mode__c, Type_of_Termination__c, Termination_Refund_Status__c, 
                    PropStrength__Application_Booking__r.PropStrength__Total_Agreement_Amount__c, PropStrength__Application_Booking__r.PropStrength__Total_Payment_Received__c, 
                    PropStrength__Application_Booking__r.Total_Recurring_Interest_Till_Date__c, PropStrength__Final_Refund_Amount__c 
                    FROM PropStrength__Transaction_Requests__c 
                    WHERE RecordType.Name = 'Refund' AND PropStrength__Refund_Type__c = 'Termination Refund' AND PropStrength__Status__c != 'Rejected' 
                    AND PropStrength__Status__c != 'Request Completed' 
                    AND Termination_Refund_Status__c IN :refundStatus
                    AND PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c =:projectId];
        }

        return createTransactionRequestWrapper(trList);
    }
    
    @AuraEnabled 
    public static void submittedToAccount(String[] trIdList, String refundStatus) {
        List<PropStrength__Transaction_Requests__c> transactionReqListUpdate = new List<PropStrength__Transaction_Requests__c>();

        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();

        if(refundStatus == 'Resubmit to Account Executive') {
            List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue'];
        
            for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue')]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }

            if(gmList[0].group.Email != null){
                sendTo.add(gmList[0].group.Email);
            }

            emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_To_Account_Executive_Queue'];

        } else if(refundStatus == 'Resubmit to Account Manager review') {
            List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Account_Manager_Refund_queue'];
            
            for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Account_Manager_Refund_queue')]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }

            if(gmList.size() > 0 && gmList[0].group != null && gmList[0].group.Email != null){
                sendTo.add(gmList[0].group.Email);
            }

            emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_To_Account_Manager_Queue'];
        } else if(refundStatus == 'Resubmit to Respective department team member') {
            List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Respective_department_Queue'];
            
            for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Respective_department_Queue')]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }

            if(gmList[0].group.Email != null){
                sendTo.add(gmList[0].group.Email);
            }

            emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_To_Respective_Team_Queue'];
        }

        String tempId = (!emailTemplate.isEmpty() && emailTemplate.size() > 0 ? emailTemplate[0].Id : null);
        
        for (PropStrength__Transaction_Requests__c tr : [SELECT Id, CreatedById, Refund_Payment_Mode__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIdList]) {
            transactionReqListUpdate.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Termination_Refund_Status__c = refundStatus));

            if(refundStatus != 'Audit Review Completed') {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setWhatId(tr.Id);
                email.setTargetObjectId(tr.CreatedById);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                mails.add(email); 
            }

            if(refundStatus == 'Audit Review Completed' && tr.Refund_Payment_Mode__c == 'OTC'){
                AuditRefundDBController.sendMailToCashierQueue(tr.Id);
                AuditRefundDBController.sendMailToRespectiveQueue(tr.Id);
            } else if(refundStatus == 'Audit Review Completed' && tr.Refund_Payment_Mode__c == 'Cheque'){
                AuditRefundDBController.sendMailToAccExeQueue(tr.Id);
            }
        }

        if(!transactionReqListUpdate.isEmpty()) {
            update transactionReqListUpdate;

            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } Catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
            }
        }
    }

    @Future(Callout=true)
    public static void sendMailToCashierQueue(Id trId) {
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();

        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Cashier_Email'];
            
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Cashier_Email')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        if(gmList[0].group.Email != null){
            sendTo.add(gmList[0].group.Email);
        }

        emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                        FROM EmailTemplate 
                                        WHERE DeveloperName =: 'Notification_To_Cashier_Queue'];

        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');

        PropStrength__Transaction_Requests__c tr = [SELECT Id, CreatedById FROM PropStrength__Transaction_Requests__c WHERE Id = :trId];

        List<ContentVersion> attachmentList = new List<ContentVersion>();
        List<Attachment> attList = new List<Attachment>();

        List<ContentDocumentLink> contDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :trId];
        if(!contDocLinks.isEmpty()) {
            Set<Id> contDocIds = new Set<Id>();
            for(ContentDocumentLink cd : contDocLinks) {
                if(cd.ContentDocumentId != null) {
                    contDocIds.add(cd.ContentDocumentId);
                }
            }
            
            List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contDocIds];
            if(!contentVersions.isEmpty()) {
                for(ContentVersion cv : contentVersions) {
                    attachmentList.add(cv);
                }
            }
        }

        if(attachmentList.isEmpty()) {
            attList = [SELECT Id, Body, Name FROM Attachment WHERE ParentId = :trId];
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(sendTo);
        email.setWhatId(trId);
        email.setTargetObjectId(tr.CreatedById);
        email.setTreatTargetObjectAsRecipient(False);
        email.setSaveAsActivity(true); 
        email.setTemplateId(tempId);

        if(!attachmentList.isEmpty()) {
            for(ContentVersion att : attachmentList) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(att.Title + '.' + att.FileExtension);
                efa.setBody(att.VersionData);	
                efalst.add(efa);
            }
        } else if(!attList.isEmpty()) {
            for(Attachment att : attList) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);	
                efalst.add(efa);
            }
        }

        if(!efalst.isEmpty()) {
            email.setFileAttachments(efalst);
        }

        mails.add(email); 

        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } Catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
        }
    }

    @Future(Callout=true)
    public static void sendMailToRespectiveQueue(Id trId) {
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();

        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Respective_department_Queue'];
            
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Respective_department_Queue')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        if(gmList[0].group.Email != null){
            sendTo.add(gmList[0].group.Email);
        }

        emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                        FROM EmailTemplate 
                                        WHERE DeveloperName =: 'Notification_To_Respective_Queue'];

        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');

        PropStrength__Transaction_Requests__c tr = [SELECT Id, CreatedById FROM PropStrength__Transaction_Requests__c WHERE Id = :trId];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(sendTo);
        email.setWhatId(trId);
        email.setTargetObjectId(tr.CreatedById);
        email.setTreatTargetObjectAsRecipient(False);
        email.setSaveAsActivity(true); 
        email.setTemplateId(tempId);

        mails.add(email); 

        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } Catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
        }
    }

    @Future(Callout=true)
    public static void sendMailToAccExeQueue(Id trId) {
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();

        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue'];
            
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        if(gmList[0].group.Email != null){
            sendTo.add(gmList[0].group.Email);
        }

        emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                        FROM EmailTemplate 
                                        WHERE DeveloperName =: 'Notification_To_Respective_Queue'];

        String tempId = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');

        PropStrength__Transaction_Requests__c tr = [SELECT Id, CreatedById FROM PropStrength__Transaction_Requests__c WHERE Id = :trId];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(sendTo);
        email.setWhatId(trId);
        email.setTargetObjectId(tr.CreatedById);
        email.setTreatTargetObjectAsRecipient(False);
        email.setSaveAsActivity(true); 
        email.setTemplateId(tempId);

        mails.add(email); 

        try {
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        } Catch(Exception e){
            System.debug('--------------Exception in Sending emails--------------------'+ e.getMessage());
            System.debug('--------------Exception in Sending emails Line Number::'+ e.getLineNumber());
        }
    }

    @TestVisible
    private static List<TransactionRequestWrapper> createTransactionRequestWrapper(List<PropStrength__Transaction_Requests__c> trList) {
        List<TransactionRequestWrapper> transactionRequestWrapperList = new List<TransactionRequestWrapper>();

        for(PropStrength__Transaction_Requests__c transactionRequest : trList){
            TransactionRequestWrapper wrap = new TransactionRequestWrapper();
            wrap.trName = transactionRequest.Name;
            wrap.transactionRequestId = '/'+transactionRequest.Id;
            wrap.unitId = '/'+transactionRequest.PropStrength__Application_Booking__r.PropStrength__Property__c;
            wrap.unitName = transactionRequest.PropStrength__Application_Booking__r.House_Unit_No__c != null ? transactionRequest.PropStrength__Application_Booking__r.House_Unit_No__c : '';
            wrap.bookingId = transactionRequest.PropStrength__Application_Booking__c != null ? '/'+transactionRequest.PropStrength__Application_Booking__c : '';
            wrap.bookingName = transactionRequest.PropStrength__Application_Booking__r.Name;
            wrap.customerName = transactionRequest.PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c != null ? transactionRequest.PropStrength__Application_Booking__r.PropStrength__Primary_Applicant_Name__c : '';
            wrap.bookingDate = transactionRequest.PropStrength__Application_Booking__r.PropStrength__Booking_Date__c != null ? transactionRequest.PropStrength__Application_Booking__r.PropStrength__Booking_Date__c.format() : '';
            wrap.refundInitiatedBy = transactionRequest.Refund_Initiated_By__c != null ? transactionRequest.Refund_Initiated_By__c : '';
            wrap.refundAmount = transactionRequest.PropStrength__Final_Refund_Amount__c != null ? transactionRequest.PropStrength__Final_Refund_Amount__c : 0;
            wrap.paymentMode = transactionRequest.Refund_Payment_Mode__c != null ? transactionRequest.Refund_Payment_Mode__c : '';
            wrap.typeOfTermination = transactionRequest.Type_of_Termination__c != null ? transactionRequest.Type_of_Termination__c : '';
            wrap.terminationRefundStatus = transactionRequest.Termination_Refund_Status__c != null ? transactionRequest.Termination_Refund_Status__c : '';
            wrap.totalAgreementAmount = transactionRequest.PropStrength__Application_Booking__r.PropStrength__Total_Agreement_Amount__c != null ? transactionRequest.PropStrength__Application_Booking__r.PropStrength__Total_Agreement_Amount__c : 0;
            wrap.totalAmountPaid = transactionRequest.PropStrength__Application_Booking__r.PropStrength__Total_Payment_Received__c != null ? transactionRequest.PropStrength__Application_Booking__r.PropStrength__Total_Payment_Received__c : 0;
            wrap.totalLpIncurred = transactionRequest.PropStrength__Application_Booking__r.Total_Recurring_Interest_Till_Date__c != null ? transactionRequest.PropStrength__Application_Booking__r.Total_Recurring_Interest_Till_Date__c : 0;
            transactionRequestWrapperList.add(wrap);
        }
        return transactionRequestWrapperList;
    }

    public class TransactionRequestWrapper {
        @AuraEnabled public string trName;
        @AuraEnabled public string transactionRequestId;
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string customerName;
        @AuraEnabled public string bookingDate;
        @AuraEnabled public string refundInitiatedBy;
        @AuraEnabled public Decimal refundAmount;
        @AuraEnabled public string paymentMode;
        @AuraEnabled public string typeOfTermination;
        @AuraEnabled public string terminationRefundStatus;
        @AuraEnabled public Decimal totalAgreementAmount;
        @AuraEnabled public Decimal totalAmountPaid;
        @AuraEnabled public Decimal totalLpIncurred;
    }
}