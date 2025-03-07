public class TransferLetterButtonController {

    public string framesrc {get;set;}
    public string strId;
    public PropStrength__Transaction_Requests__c tranReq ;
    public Boolean fromLightning {get;set;}
    
    public TransferLetterButtonController(){
        fromLightning = false;
        strId = ApexPages.currentPage().getParameters().get('id');
        tranReq = [Select id, PropStrength__Customer_Transfer_Type__c, PropStrength__Status__c, Transfer_Charges_Raised_to_Customer__c from PropStrength__Transaction_Requests__c where ID =:strID];
         if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer'){
           framesrc = '/apex/TransferAndAssignmentAgreement_HTML?id='+strId;
         }else if(tranReq.PropStrength__Customer_Transfer_Type__c == 'Title Transfer'){
           framesrc = '/apex/TransferLetter_TR_HTML?id='+strId;
         }

         if(ApexPages.currentPage().getParameters().containsKey('frmLgtng') && ApexPages.currentPage().getParameters().get('frmLgtng') == 'true') {
            fromLightning = true;
         }
    }
    
    public pagereference docancel(){
        if(strId != null && strId != ''){
            return new pageReference('/'+strId);
        }else
            return null;
    }
    
    public pageReference savepdf(){
    if(strId != null && strId != ''){
       
            List<Attachment> allAttachment = new List<Attachment>();
            allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: strId];

            for(Attachment abc : allAttachment){
                if(abc.Name == 'Transfer Letter.pdf'){
                    delete abc;
                }else if(abc.Name == 'Transfer & Assignment Agreement.pdf'){
                    delete abc;
                } 
              }
            
        string aName ;
        
        if(tranReq.PropStrength__Status__c == 'Assignment: Update Applicants & Verify Applicants'){
        	if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer')
            {
                tranReq.PropStrength__Status__c = 'Transfer & Assignment Agreement Generated';
                aName= 'Transfer & Assignment Agreement';
            }else{
                tranReq.PropStrength__Status__c = 'Transfer Letter Generated';
                 aName= 'Transfer Letter';
            }
         update tranReq;
        }
             String frmsrc = '';
            if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer'){
           frmsrc = '/apex/TransferAndAssignmentAgreement?id='+strId;
         }else if(tranReq.PropStrength__Customer_Transfer_Type__c == 'Title Transfer'){
           frmsrc = '/apex/TransferLetter_TR?id='+strId;
         }
            
            PageReference p1 = new PageReference(frmsrc);   
            Attachment a1 = new Attachment();
                a1.parentid = strId;
                a1.name = aName + '.pdf';
                 if (Test.IsRunningTest())
                 {
                     a1.body =Blob.valueOf('UNIT.TEST');
                 }
                 else{
                     a1.body = p1.getContent();
                 }
           
           insert a1;
        
        
        
            if(strid != null && strid != ''){
               return new pageReference('/'+strid);
            }
        
    }        
        return null;
      }
}