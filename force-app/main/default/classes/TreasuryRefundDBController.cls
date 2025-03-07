public class TreasuryRefundDBController {
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
    public static PropStrength__Transaction_Requests__c refAmtAndPayMode(Id trId) {
        return [SELECT Id, PropStrength__Final_Refund_Amount__c, Refund_Payment_Mode__c FROM PropStrength__Transaction_Requests__c WHERE Id = :trId];
    }
    
    @AuraEnabled 
    public static void submittedToAccount(String[] trIdList, String refundStatus) {
        List<PropStrength__Transaction_Requests__c> transactionReqListUpdate = new List<PropStrength__Transaction_Requests__c>();

        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Notification_Treasury_Approve_Resubmit'];

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();

        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue'];
        
        for(User u : [SELECT Id, Email FROM User WHERE Id IN ( SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Account_Executive_Refund_queue')]) {
            if(u.Email != null) {
                sendTo.add(u.Email);
            }
        }

        if(gmList.size() > 0 && gmList[0].group != null && gmList[0].group.Email != null){
            sendTo.add(gmList[0].group.Email);
        }

        String tempId = (!emailTemplate.isEmpty() && emailTemplate.size() > 0 ? emailTemplate[0].Id : null);

        for (PropStrength__Transaction_Requests__c tr : [SELECT Id, CreatedById FROM PropStrength__Transaction_Requests__c WHERE Id IN :trIdList]) {
            if(!refundStatus.contains('##'))
                transactionReqListUpdate.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Termination_Refund_Status__c = refundStatus));
            else
                transactionReqListUpdate.add(new PropStrength__Transaction_Requests__c(Id=tr.Id, Termination_Refund_Status__c = 'Approved by Treasury', PropStrength__Final_Refund_Amount__c = Decimal.valueOf(refundStatus.split('##')[0]), Refund_Payment_Mode__c = refundStatus.split('##')[1]));

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            email.setWhatId(tr.Id);
            email.setTargetObjectId(tr.CreatedById);
            email.setTreatTargetObjectAsRecipient(False);
            email.setSaveAsActivity(true); 
            email.setTemplateId(tempId);
            mails.add(email); 
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