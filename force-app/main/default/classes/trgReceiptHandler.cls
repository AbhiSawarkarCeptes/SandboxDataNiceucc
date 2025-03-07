public without sharing  class trgReceiptHandler {
    private static List<String> auditApproverEmails;
    private static Id NoReplyEmailId;
    private static string auditorDashboardUrl;
    private static string accountsDashboardUrl;
    
    static {
        auditApproverEmails = new List<String>();
        for (User usr : [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Audit_Approver')]) {
            auditApproverEmails.add(usr.Email);
            //auditApproverEmails.add('shaik.rehaman@ceptes.com');
        }
        if(Test.isRunningTest()){
            NoReplyEmailId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1][0].Id;
        }else{
            NoReplyEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName=:system.Label.No_reply_display_name][0].Id;
        }
        auditorDashboardUrl=URL.getOrgDomainURL().toExternalForm()+'/lightning/n/Receipts_for_Approval';
        accountsDashboardUrl=URL.getOrgDomainURL().toExternalForm()+'/lightning/n/Rejected_Receipts';
    }
    
    public static void sendEmailNotificationToAuditOnReceiptSubmission(List<Receipt__c> newlistReceipts, Map<Id,Receipt__c> oldMapContent, System.TriggerOperation contxt){
        
        for(Receipt__c rec:newlistReceipts)
        {
            if(rec.Payment_Request__c==null)
            {
                continue;
            }
            if(rec.Receipt_Status__c=='Cleared' && (contxt == System.TriggerOperation.AFTER_INSERT || (contxt == System.TriggerOperation.AFTER_UPDATE && oldMapContent.get(rec.Id).Receipt_Status__c!='Cleared') ) )
            {
                //sendEmail(auditApproverEmails);
                sendEmail(rec.Id, rec.Payment_Request__c, rec.Audit_Approver_s_Comments__c,'Under_approval_intimation_email_to_Audit_1709013586276');
                system.debug('We are in sendEmailNotificationToAuditOnReceiptSubmission');
            }
            if(contxt == System.TriggerOperation.AFTER_UPDATE && rec.Receipt_Status__c=='Cleared' && (rec.Audit_Approval_Status__c=='Under Approval' && oldMapContent.get(rec.Id).Audit_Approval_Status__c!='Under Approval' ))
            {
                //sendEmail(auditApproverEmails);
                sendEmail(rec.Id, rec.Payment_Request__c, rec.Audit_Approver_s_Comments__c,'Under_approval_intimation_email_to_Audit_1709013586276');
            }
            
        }
    }

    public static void setPrFinalApprover(List<Receipt__c> newlistReceipts, Map<Id,Receipt__c> oldMapContent){
        if(newlistReceipts == NULL || oldMapContent == NULL) return;
        Map<Id,String> prIdToReceiptClearer = new Map<Id,String>();
        for(Receipt__c rec:newlistReceipts){
            if(rec.Mode__c == 'Credit Note' || rec.Mode__c == 'Website' || String.isBlank(rec.Payment_Request__c)) continue;

            if(rec.Receipt_Status__c=='Cleared' && oldMapContent.get(rec.Id).Receipt_Status__c!='Cleared'){
                prIdToReceiptClearer.put(rec.Payment_Request__c,UserInfo.getUserId());
            }
        }
        updatePRs(prIdToReceiptClearer);
    }

    @future
    private static void updatePRsFuture(Map<Id,String> prIdToReceiptClearer){
        updatePRs(prIdToReceiptClearer);
    }
    private static void updatePRs(Map<Id,String> prIdToReceiptClearer){
        if(isAsyncContext()){
            List<Payment_Request__c> prsToBeUpdated = new List<Payment_Request__c>();
            for(Id prId : prIdToReceiptClearer.keySet()){
                prsToBeUpdated.add(new Payment_Request__c(Id = prId,Final_Approver__c = prIdToReceiptClearer.get(prId)));
            }
            Database.update(prsToBeUpdated,false);
        }else{
            updatePRsFuture(prIdToReceiptClearer);
        }
    }

    public static void setAuditStatus(List<Receipt__c> newlistReceipts, Map<Id,Receipt__c> oldMapContent){
        
        if(newlistReceipts == NULL || oldMapContent == NULL) return;
        
        for(Receipt__c rec:newlistReceipts){
            if(rec.Receipt_Status__c=='Cleared' && oldMapContent.get(rec.Id).Receipt_Status__c!='Cleared'){
                if(!rec.Mode__c.equalsIgnoreCase('Website') && !rec.Mode__c.equalsIgnoreCase('Credit Note')){
                    rec.Audit_Approval_Status__c='Under Approval'; 
                }else if(rec.Mode__c.equalsIgnoreCase('Website') || rec.Mode__c.equalsIgnoreCase('Credit Note')){
                    rec.Audit_Approval_Status__c='Not Applicable'; 
                }
            }
            
        }
    }
    
    public static void sendEmailNotificationOnApproveAndRejectionByAuditor(List<Receipt__c> newlistReceipts, Map<Id,Receipt__c> oldMapContent){
        if(newlistReceipts == NULL || oldMapContent == NULL) return;
        
        for(Receipt__c rec:newlistReceipts)
        {
            if(rec.Payment_Request__c == null)
            {
                continue;
            }
            if(rec.Audit_Approval_Status__c=='Rejected' && oldMapContent.get(rec.Id).Audit_Approval_Status__c!='Rejected' )
            {
                sendEmail(rec.Id,rec.Payment_Request__c, rec.Audit_Approver_s_Comments__c, 'Rejection_intimation_email_to_Accounts_1708958942639');
                //system.debug('Email sent to Payment Request Approver');
                System.debug('recId: ' + rec.Id + ', paymentRequest: ' + rec.Payment_Request__c + ', auditApproverComments: ' + rec.Audit_Approver_s_Comments__c + ', emailTemplateId: Rejection_intimation_email_to_Accounts_1708958942639');

            }else if(rec.Audit_Approval_Status__c=='Approved' && oldMapContent.get(rec.Id).Audit_Approval_Status__c!='Approved'){
                sendEmail(rec.Id,rec.Payment_Request__c, rec.Audit_Approver_s_Comments__c, 'Under_approval_intimation_email_to_Audit_1709013586276');
                System.debug('recId: ' + rec.Id + ', paymentRequest: ' + rec.Payment_Request__c + ', auditApproverComments: ' + rec.Audit_Approver_s_Comments__c + ', emailTemplateId: Under_approval_intimation_email_to_Audit_1709013586276');

            }
            
        }
    }
    
    //common method use for both approve & reject
    @future
   public static void sendEmail(Id receiptId ,Id pRId, String comments, String templateDevName) {
        System.debug('pRId '+pRId);
        System.debug('comments '+comments);
        System.debug('receiptId '+receiptId);
       
       
    List<Payment_Request__c> pr = [SELECT Id, Final_Approver__c FROM Payment_Request__c WHERE Id = :pRId LIMIT 1];
    if(pr.isEmpty() || String.isBlank(pr[0].Final_Approver__c)) return;

    List<User> usr = [SELECT Id, Email,Profile.Name FROM User WHERE Id = :pr[0].Final_Approver__c];
    if(usr.isEmpty()) return;
if(templateDevName.containsIgnoreCase('account') && !usr[0].Profile.Name.containsIgnoreCase('finance')) return;
    
    System.debug('usr email - '+usr[0].Email);
    System.debug('auditApproverEmails - '+auditApproverEmails);
    // Retrieve the Classic Email Template Id based on the template name
    Id emailTemplateId = getEmailTemplateId(templateDevName);
    System.debug('emailTemplateId'+emailTemplateId);
    // Retrieve the email template fields
    EmailTemplate emailTemplate = [SELECT Subject, HtmlValue FROM EmailTemplate WHERE Id = :emailTemplateId LIMIT 1];

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = templateDevName.containsIgnoreCase('Audit') ? auditApproverEmails : new List<String>{usr[0].Email} ; 

    mail.setToAddresses(toAddresses);
    mail.setOrgWideEmailAddressId(NoReplyEmailId);
    mail.setTemplateId(emailTemplateId);
    mail.setWhatId(receiptId);
    mail.setTreatTargetObjectAsRecipient(false);
    /*& Create a new contact*/
	Contact newContact = new Contact();
	newContact.FirstName = 'FName'+Math.abs(Crypto.getRandomInteger());
	newContact.LastName = 'LName'+Math.abs(Crypto.getRandomInteger());
	newContact.Email = 'dummy'+Math.abs(Crypto.getRandomInteger())+'@example.com';

    mail.setSaveAsActivity(false);

    System.Savepoint sp = Database.setSavePoint();
    Database.insert(newContact,AccessLevel.SYSTEM_MODE);
    mail.setTargetObjectId(newContact.Id);
    try {
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        Database.delete(newContact,AccessLevel.SYSTEM_MODE);//deleting the contact
    } catch (Exception ex) {
        Database.rollback(sp);
        System.debug('Email could not be sent because of ' + ex);
    }
}
    
// Helper method to get the Id of a Classic Email Template based on the template name
private static Id getEmailTemplateId(String templateName) {
    EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName AND IsActive = true LIMIT 1];
    return emailTemplate.Id;
}
   
    
public static void updateAgingField(List<Receipt__c> newlistReceipts, Map<Id,Receipt__c> oldMapContent) {
   if(newlistReceipts == NULL || oldMapContent == NULL) return;
    
    for (Receipt__c receipt : newlistReceipts) {
        Receipt__c oldReceipt = oldMapContent.get(receipt.Id);
        
        // Check if Audit Approval Status__c has changed
        if (receipt.Audit_Approval_Status__c != oldReceipt.Audit_Approval_Status__c) {
            receipt.Audit_History__c = String.isNotBlank(receipt.Audit_History__c) ? receipt.Audit_History__c : '';
            // Append audit history
            receipt.Audit_History__c += UserInfo.getName() + ' changed status from ' + oldReceipt.Audit_Approval_Status__c + ' to ' + receipt.Audit_Approval_Status__c + ' on ' + Datetime.now() + '\n';
        }}}

    static Boolean isAsyncContext(){
        return System.isFuture() || System.isScheduled() || System.isQueueable() || System.isBatch();
    }
}