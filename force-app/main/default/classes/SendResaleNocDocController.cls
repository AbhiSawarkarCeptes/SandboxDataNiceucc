public class SendResaleNocDocController {
    
    @AuraEnabled
	public static void sendEmail(Id resaleId) {
        try {
            Resale_Process__c process = [
                SELECT Id, Resale_Type__c, Booking__c, Booking__r.Cluster__c, Unit__r.Name, NOC_sent_to_client__c,NOC_sent_date__c
                FROM Resale_Process__c
                WHERE Id = :resaleId
            ];
            
            List<ContentDocumentLink> docLinks = [
                SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId, LinkedEntity.Type
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :resaleId
                AND ContentDocument.Title LIKE 'NOC%'
                ORDER BY ContentDocument.CreatedDate DESC
                LIMIT 1
            ];
                
            if( docLinks.isEmpty() )
                throw new ResaleProcessException('Please upload NOC document before sending to the client.');
            
            ContentVersion doc = [
                SELECT VersionData, FileExtension, ContentDocumentId, ContentDocument.Title
                FROM ContentVersion 
                WHERE ContentDocumentId = :docLinks[0].ContentDocumentId
                AND IsLatest = true
            ];
                
            Blob fileData = doc.VersionData; 
            Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
            emlAtt.setFilename(doc.ContentDocument.Title + '.' + doc.FileExtension);
            emlAtt.setBody(fileData);
            
            String emailBody = 'Dear Sir/Madam <br/><br/>'+
            
                'Please find attached the NOC document for Transfer and Assignment agreement for the property purchased from Sobha LLC (“<b>Seller</b>”).'+
                +
                'Should you have any questions or concerns, please do not hesitate to write us at helpdesk@sobharealty.com.<br/>'+
                '<br/>'+
                'Warm regards,<br/>'+
                'Customer Relations - Sobha Realty</p><br/>';
            
            String emailSubject =  process.Booking__r?.Cluster__c + ' and ' + process.Unit__r.Name;
            
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            
            for(Applicant_Details__c detail : [
                SELECT Id, Name, Email_Address__c 
                FROM Applicant_Details__c
                WHERE Booking__c = :process.Booking__c
            ]) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[] { detail.Email_Address__c });
                message.setFileAttachments(new List<Messaging.EmailFileAttachment>{emlAtt});
                message.setHtmlBody(emailBody);
                message.setSubject(emailSubject);
                //message.setTemplateId(emailTemplate.Id);
                //message.setWhatId(resaleId);
                //message.setTargetObjectId(con.Id);
                //message.setSaveAsActivity(false);
                messages.add(message);
            }
            
            Messaging.sendEmail(messages);
            process.NOC_sent_to_client__c = true;
            process.NOC_sent_date__c = System.now();
            Update process;
        } catch(Exception ex) {
			throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class ResaleProcessException extends Exception {}
}