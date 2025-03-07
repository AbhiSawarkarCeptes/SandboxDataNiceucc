public class TransferAssignmentAgreementDownloadCnt {
    public String recId {get;set;}
    public String framesrc {get;set;}
    
    public TransferAssignmentAgreementDownloadCnt() {
        recId = ApexPages.currentPage().getParameters().get('id');
        framesrc = '/apex/TransferAssignmentAgreement?id='+recId;
    }
    
	public PageReference saveAtt() {
        if(recId != null && recId != '' && framesrc != null) {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'TransferAssignmentAgreement');
            return new pageReference('/'+recId);
        }
        return null;
    }
}