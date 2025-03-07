public class TransferLetterDownloadController {
    public String recId {get;set;}
    public String framesrc {get;set;}
    
    public TransferLetterDownloadController() {
        recId = ApexPages.currentPage().getParameters().get('id');
        framesrc = '/apex/TransferLetter?id='+recId;
    }
    
	public PageReference saveAtt() {
        if(recId != null && recId != '' && framesrc != null) {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'TransferLetter');
            return new pageReference('/'+recId);
        }
        return null;
    }
}