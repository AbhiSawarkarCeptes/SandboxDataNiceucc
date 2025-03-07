public class ReceiptApprovalBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public Map<EmailKey, EmailInfo> recordsByEmail; // Map to hold records grouped by recipient email and CC emails
    
    public ReceiptApprovalBatch() {
        recordsByEmail = new Map<EmailKey, EmailInfo>(); // Initialize the map
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query the Receipt__c records that are under approval or rejected for more than 2 days
      //  Datetime thresholdDateTime = Datetime.now().addDays(-2); // Change the threshold as needed
        return Database.getQueryLocator([
            SELECT Id, Name, Audit_Approval_Status__c, CreatedDate, Account_Aging__c, Audit_Aging__c,Booking__r.name, Opportunity__r.Name, Project_Unit__r.Name
            FROM Receipt__c
            WHERE (Audit_Approval_Status__c = 'Under Approval' AND Audit_Aging__c >= 1) OR (Audit_Approval_Status__c = 'Rejected' AND Account_Aging__c >= 1)
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Receipt__c> scope) {
      
        // Map to store the metadata records by team and age
        Map<String, Map<Decimal, Audit_Escalation_Metrice__mdt>> teamAgeMetricsMap = new Map<String, Map<Decimal, Audit_Escalation_Metrice__mdt>>();
        
        // Query the Audit_Escalation_Metrice__mdt records and organize them by team and age
        for (Audit_Escalation_Metrice__mdt metric : [SELECT Age__c, ccEmailAddress__c, Team__c, ToEmailAddress__c FROM Audit_Escalation_Metrice__mdt]) {
            if (!teamAgeMetricsMap.containsKey(metric.Team__c)) {
                teamAgeMetricsMap.put(metric.Team__c, new Map<Decimal, Audit_Escalation_Metrice__mdt>());
            }
            teamAgeMetricsMap.get(metric.Team__c).put(Integer.ValueOf(metric.Age__c), metric);
        }
        System.debug('-----Team and Custom'+teamAgeMetricsMap);
        
        for (Receipt__c receipt : scope) {
            String team = determineTeam(receipt.Audit_Approval_Status__c);
            EmailInfo emailInfo = determineRecipient(receipt, team, teamAgeMetricsMap);
            System.debug('-------'+emailInfo);
            
            if (emailInfo != null && emailInfo.approvalStatus != null && (emailInfo.toEmail != '' || !emailInfo.ccEmails.isEmpty())) {
                
                EmailKey emailKey = new EmailKey(emailInfo.toEmail, emailInfo.ccEmails);
                if (!recordsByEmail.containsKey(emailKey)) {
                    recordsByEmail.put(emailKey, new EmailInfo());
                }
                recordsByEmail.get(emailKey).receipts.add(receipt);
                recordsByEmail.get(emailKey).approvalStatus = emailInfo.approvalStatus;
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        // Send emails containing information about all records to each recipient and cc recipient
        List<Messaging.SingleEmailMessage> listEmailToSend = new List<Messaging.SingleEmailMessage>();
		System.debug('--------'+recordsByEmail);
        for (EmailKey emailKey : recordsByEmail.keySet()) {
            createEmailsList(recordsByEmail.get(emailKey), emailKey, listEmailToSend);
        }
        if (!listEmailToSend.isEmpty()) {
            // Send the emails
            Messaging.SendEmailResult[] result = Messaging.sendEmail(listEmailToSend);
            for(Integer i=0; i<result.size(); i++){
                if (result[i].isSuccess()) {
                    System.debug('Email sent successfully: ' + listEmailToSend[i]);
                } else {
                    System.debug('Failed to send email to ' + listEmailToSend[i] + ': ' + result[i].getErrors());
                }
            }
        }
    }
    
    private String determineTeam(String status) {
        if (status == 'Under Approval') {
            return 'Audit';
        } else if (status == 'Rejected') {
            return 'Account';
        }
        return '';
    }
    
    private EmailInfo determineRecipient(Receipt__c receipt, String team, Map<String, Map<Decimal, Audit_Escalation_Metrice__mdt>> teamAgeMetricsMap) {
       System.debug('-----Team and Custom'+teamAgeMetricsMap);
        System.debug('-----Team value'+team);
        Integer auditAging = Integer.ValueOf(receipt.Audit_Aging__c);
        Integer accountAging = Integer.ValueOf(receipt.Account_Aging__c);
        System.debug('-------Reciept'+receipt);
        if (teamAgeMetricsMap != null && teamAgeMetricsMap.containsKey(team)) {
            Map<Decimal, Audit_Escalation_Metrice__mdt> metricsMap = teamAgeMetricsMap.get(team);
            if (metricsMap != null) {
                if (metricsMap.containsKey(auditAging)) {
                    EmailInfo emailInfo = new EmailInfo();
                    emailInfo.toEmail = metricsMap.get(auditAging).ToEmailAddress__c;
                    emailInfo.ccEmails = new List<String>{metricsMap.get(auditAging).ccEmailAddress__c};
                    emailInfo.approvalStatus = 'Under Approval';
                    return emailInfo;
                } else if (metricsMap.containsKey(accountAging)) {
                    EmailInfo emailInfo = new EmailInfo();
                    emailInfo.toEmail = metricsMap.get(accountAging).ToEmailAddress__c;
                    emailInfo.ccEmails = new List<String>{metricsMap.get(accountAging).ccEmailAddress__c};
                    emailInfo.approvalStatus = 'Rejected';
                    return emailInfo;
                }
            }
        }
        
        // Default recipient if no condition is met
        return null;
    }
    
    private void createEmailsList(EmailInfo emailInfo, EmailKey emailKey, List<Messaging.SingleEmailMessage> listEmailToSend) {
        if (emailKey.toEmail != '' && !emailInfo.receipts.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{emailKey.toEmail});
            email.setCcAddresses(emailKey.ccEmails);
            email.setSubject('Receipt Approval Status Report');
            
            String emailBody = constructEmailBody(emailInfo.receipts, emailInfo.approvalStatus);
             System.debug('Debug1'+emailInfo.approvalStatus);
            //email.setPlainTextBody(emailBody + '\nRegards,\nYour Salesforce Admin');
             email.setHtmlBody(emailBody); // Set email body as HTML
            listEmailToSend.add(email);
        }
    }
    
   /* private String constructEmailBody(List<Receipt__c> receipts, String approvalStatus) {
        String emailBody = '';
        System.debug('Debug1'+emailBody);
        if (approvalStatus == 'Under Approval') {
            emailBody += 'Dear Audit Team member,\n';
            emailBody += 'The below mentioned receipt is pending in audit queue for approval beyond the TAT. Kindly action the request on priority:\n\n';
        	System.debug('Debug2'+emailBody);
        } else if (approvalStatus == 'Rejected') {
            emailBody += 'Dear Accounts team member,\n';
            emailBody += 'The below mentioned receipt has been rejected by audit review. Kindly action the request at the earliest and clear the audit comment:\n\n';
       	System.debug('Debug3'+emailBody);
        }
        
        emailBody += '<table border="1" style="border-collapse: collapse"><caption>Receipt Data</caption><tr>';
        System.debug('Debug4'+emailBody);
        Map<String, String>  columns = getColumns(approvalStatus);
        for (String columnName : columns.KeySet()) {
            emailBody += '<th>' + columnName + '</th>';
        }
        emailBody += '</tr>';
        System.debug('Debug5'+emailBody);
        for (Receipt__c receipt : receipts) {
            emailBody += '<tr>';
            for (String columnName : columns.KeySet()) {
                String columnValue = String.valueOf(receipt.get(columns.get(columnName)));
                emailBody += '<td>' + (columnValue != null ? columnValue : '') + '</td>';
            }
            // Add link to the receipt record
        emailBody += '<td><a href="' + getReceiptLink(receipt.Id) + '">View Receipt</a></td>';
        emailBody += '</tr>';
        }
        System.debug('Debug6'+emailBody);
        emailBody += '</table>\n\n';
        emailBody += 'Note: This is an automated mail generated from system. Kindly do not reply to this email. In case of any clarifications or concerns, please contact IT helpdesk.\n';
        emailBody += '\nRegards,\nYour Salesforce Admin';
        System.debug('Debug7'+emailBody);
        return emailBody;
    }*/
    private String constructEmailBody(List<Receipt__c> receipts, String approvalStatus) {
    String emailBody = '';
    if (approvalStatus == 'Under Approval') {
            emailBody += 'Dear Audit Team member,\n<br>';
            emailBody += 'The below mentioned receipt is pending in audit queue for approval beyond the TAT. Kindly action the request on priority:\n\n';
        	System.debug('Debug2'+emailBody);
        } else if (approvalStatus == 'Rejected') {
            emailBody += 'Dear Accounts team member,\n<br>';
            emailBody += 'The below mentioned receipt has been rejected by audit review. Kindly action the request at the earliest and clear the audit comment:\n\n';
       	System.debug('Debug3'+emailBody);
        }

    emailBody += '<table border="1" style="border-collapse: collapse"><caption>Receipt Data</caption><tr>';
    Map<String, String>  columns = getColumns(approvalStatus);
    for (String columnName : columns.keySet()) {
        emailBody += '<th>' + columnName + '</th>';
    }
    emailBody += '<th>Receipt Link</th>'; // Add column header for Receipt Link
    emailBody += '</tr>';
    
    for (Receipt__c receipt : receipts) {
        emailBody += '<tr>';
        for (String columnName : columns.keySet()) {
            string columnAPIName = columns.get(columnName);
            String columnValue;
            if(columnAPIName == 'Booking__r.name'){
                columnValue = receipt.Booking__r.name;} 
            else if(columnAPIName == 'Opportunity__r.Name'){
                columnValue = receipt.Opportunity__r.Name;}
            else if(columnAPIName == 'Project_Unit__r.Name'){
                columnValue = receipt.Project_Unit__r.Name;}
            else{
                columnValue = String.valueOf(receipt.get(columns.get(columnName)));}
           // String columnValue = receipt.columnAPIName;
            emailBody += '<td>' + (columnValue != null ? columnValue : '') + '</td>';
        }
        // Add dynamic URL for Receipt record
        emailBody += '<td><a href="' + getReceiptLink(receipt.Id) + '">View Receipt</a></td>';
        emailBody += '</tr>';
    }

    emailBody += '</table>\n\n<br>';
    emailBody += 'Note: This is an automated mail generated from the system. Kindly do not reply to this email. In case of any clarifications or concerns, please contact IT helpdesk.\n<br>';
    emailBody += '\nRegards,<br>\nYour Salesforce Admin';
    return emailBody;
}
     // Helper method to get the link to the Receipt record
		public String getReceiptLink(Id receiptId) {
    		return URL.getOrgDomainUrl().toExternalForm() + '/' + receiptId;
		}

    
    private Map<String, String> getColumns(String approvalStatus) {
    Map<String, String> columns = new Map<String, String>();
    if (approvalStatus == 'Under Approval') {
        // Define columns for Under Approval status
        columns.put('Booking id', 'Booking__r.name');
        columns.put('Opportunity Id', 'Opportunity__r.Name');
        columns.put('Unit Number', 'Project_Unit__r.Name');
        columns.put('Reciept Number', 'Name');
        columns.put('Delay Days', 'Audit_Aging__c');
         
        // Add more columns as needed
    } else if (approvalStatus == 'Rejected') {
        // Define columns for Rejected status
        columns.put('Booking id', 'Booking__r.name');
        columns.put('Opportunity Id', 'Opportunity__r.Name');
        columns.put('Unit Number', 'Project_Unit__r.Name');
        columns.put('Reciept Number', 'Name');
        columns.put('Delay Days', 'Account_Aging__c'); 
        // Add more columns as needed
    }
    return columns;
}

    
    // Inner class to hold email information
    public class EmailInfo {
        public String toEmail { get; set; }
        public List<String> ccEmails { get; set; }
        public List<Receipt__c> receipts { get; set; }
        public String approvalStatus { get; set; }
        
        public EmailInfo() {
            ccEmails = new List<String>();
            receipts = new List<Receipt__c>();
        }
    }
    
    // Inner class to create a composite key for email addresses
    public class EmailKey {
        public String toEmail { get; set; }
        public List<String> ccEmails { get; set; }
        
        public EmailKey(String toEmail, List<String> ccEmails) {
            this.toEmail = toEmail;
            this.ccEmails = ccEmails;
        }
        
        // Overriding equals and hashCode methods for Map key comparison
        public Boolean equals(Object obj) {
            if (obj instanceof EmailKey) {
                EmailKey other = (EmailKey)obj;
                return this.toEmail == other.toEmail && this.ccEmails == other.ccEmails;
            }
            return false;
        }
        
        public Integer hashCode() {
            return (toEmail != null ? toEmail.hashCode() : 0) ^ (ccEmails != null ? ccEmails.hashCode() : 0);
        }
       
    }
}