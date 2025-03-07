public with sharing class EmailDetailController {
    private final PropStrength__Email__c emailRec;
    public ParamWrapper returnedParams {get;set;}
    public Boolean srModuleChk {get;set;}
    public Boolean isDraft {get;set;}
    public transient String body {get;set;}
    public List<Attachment> attachmentList {get;set;}
    private Boolean brokerModuleChk;
    
    private Set<id> attachmentIdSet;
    private String serializedIds;
    private PropStrength__Email__c orignalEmailObj;
    
    public EmailDetailController(ApexPages.StandardController stdController) {
        srModuleChk = False;
        brokerModuleChk = False;
        attachmentList = new List<Attachment>();
        emailRec = (PropStrength__Email__c)stdController.getRecord();
        returnedParams = checkParentObjType();

        System.debug('emailRec*****');
        System.debug(emailRec);
    
        if(emailRec.id != null) {
            orignalEmailObj = [Select PropStrength__Status__c ,PropStrength__Service_Request__c ,PropStrength__Message_Date__c,PropStrength__EmailMessage__c ,PropStrength__BCC_Address__c ,PropStrength__Subject__c,PropStrength__CC_Address__c,PropStrength__From_Address__c ,PropStrength__To_Address__c,Name,Id
                                    from PropStrength__Email__c where id=:emailRec.id];
            
            body = EmailUtilClass.getEmailBody(orignalEmailObj,'detailPage');
            System.debug('*****body****'+body);
            srModuleChk = (returnedParams.objectName != 'bookRequest');
            System.debug('*****body*emil***'+orignalEmailObj.PropStrength__Status__c );
            if(emailRec.PropStrength__Status__c == 'Draft')
                isDraft = true;
            else    
                isDraft = false;
            String strCheck = orignalEmailObj.Name+'.html';
            attachmentList = [ Select parentId,id,Name,BodyLength from Attachment where parentId =: orignalEmailObj.id AND Name!=:strCheck ];
        }
    }
    
    public void updateStatus() {
        if(emailRec.PropStrength__Status__c == 'New') {
            emailRec.PropStrength__Status__c = 'Read';
            update emailRec;
        }    
    }
    
    public ParamWrapper checkParentObjType() {
        ParamWrapper paramToReturn;
        if( emailRec.PropStrength__Service_Request__c != null )
            paramToReturn = new ParamWrapper('bookRequest',emailRec.PropStrength__Service_Request__c);
        
        
        else if( emailRec.PropStrength__Contact__c != null )
            paramToReturn = new ParamWrapper('contact',emailRec.PropStrength__Contact__c);
        else
            paramToReturn = new ParamWrapper('','');
            
        List<PropStrength__Email__c> emailRecord = new List<PropStrength__Email__c>();
        if(emailRec.id != null)
            emailRecord = [Select Id,PropStrength__Status__c ,PropStrength__Service_Request__c,PropStrength__EmailMessage__c,PropStrength__Contact__c from PropStrength__Email__c where id=:emailRec.id];
        
        if(!emailRecord.isEmpty() && emailRecord[0].PropStrength__Contact__c != null ) {
            if( EmailUtilClass.objectPrefix( emailRecord[0].PropStrength__Contact__c ) == 'Contact' ) {
                Contact conRec = [Select RecordType.Name from Contact Where id=:emailRecord[0].PropStrength__Contact__c ];
                
            }
        }
        
        return paramToReturn; 
    }
    
    public pageReference reply() {
        return new pageReference('/apex/ComposeEmail?action=reply&objName='+returnedParams.objectName+'&objId='+returnedParams.objectId+'&emailId='+emailRec.id).setRedirect(True);
    }
    public pageReference draft() {
        return new pageReference('/apex/ComposeEmail?action=draft&objName='+returnedParams.objectName+'&objId='+returnedParams.objectId+'&emailId='+emailRec.id+'&isDraft='+isDraft).setRedirect(True);
    }
    public pageReference replyToAll() {
        return new pageReference('/apex/ComposeEmail?action=replyToAll&objName='+returnedParams.objectName+'&objId='+returnedParams.objectId+'&emailId='+emailRec.id).setRedirect(True);
    }
    public pageReference forward() {
        attachmentIdSet = EmailUtilClass.getAttachmentNames ( orignalEmailObj , 'forward' );
        System.debug('attachment at forwarding time'+attachmentIdSet);
        serializedIds = JSON.serialize(attachmentIdSet);
        System.debug('attachment at forwarding time1'+serializedIds);
        return new pageReference('/apex/ComposeEmail?action=forward&objName='+returnedParams.objectName+'&objId='+returnedParams.objectId+'&emailId='+emailRec.id+'&attachmentIds='+serializedIds).setRedirect(True);
    }
    
    public class ParamWrapper {
        public String objectName{get;set;}
        public String objectId{get;set;}
        
        ParamWrapper(String objectName , String objectId) {
            this.objectName = objectName;
            this.objectId = objectId;
        }
    }
}