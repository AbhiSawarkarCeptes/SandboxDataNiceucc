public with sharing class HOUndertakingBtnController {
    public String frameSrc                                          {get;set;}
    public String recId;

    public HOUndertakingBtnController() {
        frameSrc = '';
        recId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(recId)){
            framesrc = '/apex/HomeOrientationUndertakingDocumentHTML?id='+recId;
        }
    }

    public pageReference saveDocFile(){
        if(recId != null && recId != ''){
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'HomeOrientationUndertakingDocument');
            if(recId != null && recId != ''){
                return new pageReference('/'+recId);
            }
        }    
        return null;
    }

    public PageReference backToRecPage() {
        if(recId != null && recId != '') {
            return new pageReference('/'+recId);
        } else {
            return null;            
        }   
    }
}