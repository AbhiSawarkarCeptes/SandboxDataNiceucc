public class GenerateMandateVfController {
    
    private ApexPages.StandardController controller;
    Public GenerateMandateVfController(ApexPages.StandardController controller){
        this.controller = controller;
    }
    Public PageReference addPDFtoFiles(){
        id recId = ApexPages.currentPage().getParameters().get('id');
        system.debug('recId '+recId); 
        
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId =:recId 
                                             and ContentDocument.title like '%Mandate Letter%'];
        if(docList.size()==0){
            PageReference PDf =  Page.GenerateMandateVf;//Replace attachmentPDf with the page you have rendered as PDF
            PDf.getParameters().put('Id',recId);
            PDf.setRedirect(true);
            Attachment attach = new Attachment();
            Blob b ;
            if(!test.isRunningTest()){
                b = PDf.getContent();
            }
            else{
                b = blob.valueOf('Test');
            }
            
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'Mandate_letter.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'Mandate Letter'; // Display name of the files
            conVer.VersionData = b; // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            
            
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record 
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
        }
        
        
        PageReference PDf2 =  Page.GenerateMandateVf;
        PDf2.getParameters().put('Id',recId);
        PDf2.setRedirect(true);
        return PDf2;
    }
}