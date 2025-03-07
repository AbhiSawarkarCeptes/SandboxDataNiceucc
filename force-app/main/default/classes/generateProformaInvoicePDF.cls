public class generateProformaInvoicePDF
{

    public Proforma_Invoice__c currentRecord{get; set;}
    
    public generateProformaInvoicePDF(ApexPages.StandardController controller){
        // Proforma_Invoice__c pv = (Proforma_Invoice__c)controller.getRecord();  
        currentRecord = [SELECT Id, Name FROM Proforma_Invoice__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        System.debug('Proforma Invoice'+currentRecord.id);
    }
          
    public void savePdf(){ 
        
        if(ApexPages.currentPage().getParameters().containsKey('generatepdf')) {
            return;
        }
        String InvoiceId = currentRecord.id;
        PageReference pdf = ApexPages.currentPage();
        pdf.getParameters().put('generatepdf','true');
        Blob body;   
        try {        
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }   
        Attachment attachmentProformaInvoice = new Attachment();
        attachmentProformaInvoice.Body = body;
        attachmentProformaInvoice.Name = 'ProformaInvoice'+System.now()+'.pdf';
        attachmentProformaInvoice.IsPrivate = false;
        attachmentProformaInvoice.ParentId = currentRecord.id;
        attachmentProformaInvoice.ContentType='application/pdf';
        
        Insert attachmentProformaInvoice ; 
        //PageReference pageRef = new PageReference('/' + InvoiceId);
        // return pageRef;  
    }    

          
}