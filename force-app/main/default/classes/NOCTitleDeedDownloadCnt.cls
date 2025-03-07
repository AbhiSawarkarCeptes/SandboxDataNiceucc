public class NOCTitleDeedDownloadCnt {
    public String recId {get;set;}
    public String framesrc {get;set;}
    public PropStrength__Transaction_Requests__c tranReq ;
    public Boolean fromLightning {get;set;}
    
    public NOCTitleDeedDownloadCnt() {
        recId = ApexPages.currentPage().getParameters().get('id');
        framesrc = '/apex/NOCTitleDeedHTML?id='+recId;
        if(ApexPages.currentPage().getParameters().containsKey('frmLgtng') && ApexPages.currentPage().getParameters().get('frmLgtng') == 'true') {
            fromLightning = true;
        }
        tranReq = [Select id, PropStrength__Customer_Transfer_Type__c, PropStrength__Status__c, Transfer_Charges_Raised_to_Customer__c from PropStrength__Transaction_Requests__c where ID =:recId];
    }
    
	public PageReference saveAtt() {
        if(recId != null && recId != '' && framesrc != null) {
            SavePdfAndHtmlToAttachement.doSaveReceipt(recId, 'NOCTitleDeed');
            
            if(tranReq.PropStrength__Status__c == 'SPA/DSPA Sent to New Customer'){
                tranReq.PropStrength__Status__c = 'NOC Generated';
                update tranReq;
            }
            if(!fromLightning) {
                return new pageReference('/'+recId);
            }
        }
        return null;
    }
}