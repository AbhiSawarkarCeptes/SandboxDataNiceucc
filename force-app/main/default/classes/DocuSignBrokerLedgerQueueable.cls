public class DocuSignBrokerLedgerQueueable implements Queueable, Database.AllowsCallouts{
    
    private Id ledgerId;
    
    public DocuSignBrokerLedgerQueueable(Id ledgerId) {
        this.ledgerId = ledgerId;
    }
    
    public void execute(QueueableContext context) {        
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =:ledgerId 
                                             AND ContentDocument.title = 'Invoice.pdf'
                                             ORDER BY ContentDocument.CreatedDate desc];   
        Id myDocumentId = null;
        
        if(!docList.isEmpty()){
            myDocumentId = docList[0].ContentDocumentId;
        }      
        else{         
            PageReference PDf =  Page.Invoice;
            PDf.getParameters().put('id',ledgerId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            
            Blob b ;
            if(Test.IsRunningTest())
                b= Blob.valueOf('This is Test');    
            else
                b= PDf.getContentAsPDF(); 
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = 'Invoice.pdf';
            contentVersion.Title = 'Invoice.pdf';
            contentVersion.VersionData = b;
            insert contentVersion;
            
            myDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = myDocumentId;
            contentDocumentLink.LinkedEntityId = ledgerId;
            contentDocumentLink.ShareType = 'I';
            contentDocumentLink.Visibility = 'InternalUsers';
            insert contentDocumentLink; 
            
            List<Ledger_Document_History__c> ldhList = [SELECT Id FROM Ledger_Document_History__c WHERE Document_Type__c = 'Invoice' AND Broker_Ledger__c = :ledgerId];
            if(!ldhList.isEmpty()) {
                ContentVersion contentVersion2 = new ContentVersion();
                contentVersion2.ContentLocation = 'S'; // S = Stored in Salesforce
                contentVersion2.PathOnClient = 'Invoice.pdf';
                contentVersion2.Title = 'Invoice.pdf';
                contentVersion2.VersionData = b;
                insert contentVersion2;
                
                myDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion2.Id].ContentDocumentId;
                
                ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink();
                contentDocumentLink2.ContentDocumentId = myDocumentId;
                contentDocumentLink2.LinkedEntityId = ldhList[0].Id;
                contentDocumentLink2.ShareType = 'I';
                contentDocumentLink2.Visibility = 'InternalUsers';
                insert contentDocumentLink2; 
            } else {
                Ledger_Document_History__c ldh = new Ledger_Document_History__c(Broker_Ledger__c = ledgerId, Document_Type__c = 'Invoice');
                insert ldh;

                ContentVersion contentVersion2 = new ContentVersion();
                contentVersion2.ContentLocation = 'S'; // S = Stored in Salesforce
                contentVersion2.PathOnClient = 'Invoice.pdf';
                contentVersion2.Title = 'Invoice.pdf';
                contentVersion2.VersionData = b;
                insert contentVersion2;
                
                myDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion2.Id].ContentDocumentId;
                
                ContentDocumentLink contentDocumentLink2 = new ContentDocumentLink();
                contentDocumentLink2.ContentDocumentId = myDocumentId;
                contentDocumentLink2.LinkedEntityId = ldh.Id;
                contentDocumentLink2.ShareType = 'I';
                contentDocumentLink2.Visibility = 'InternalUsers';
                insert contentDocumentLink2;
            }

        }
        BrokerLedgerTriggerController.sendLetterForDocusign(ledgerId , myDocumentId);
    }
    
}