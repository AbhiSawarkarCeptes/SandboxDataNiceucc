public with sharing class ComposeEmailController {
    public List<SelectOption> fromAddressList {get;set;}
    public List<SelectOption> ccAddressList {get;set;}
    public List<SelectOption> bccAddressList {get;set;}
    public String selectedFromAddress {get;set;}
    public String selectedTemplate {get;set;}
    public String toAddress {get;set;}
    public String addToAddress {get;set;}
    public String bccAddress {get;set;}
    public String ccAddress {get;set;}
    public String subject {get;set;}
    public transient String composedEmailBody {get;set;}
    public Boolean srModuleChk {get;set;}
    public transient string attachName {get;set;}
    public transient blob attachBody {get;set;}
    public List<AttachWrapper> attachmentWrapList {get;set;}
    public String objectName {get;set;}
    public PropStrength__Email__c orignalEmailObj{get;set;}
    public String offerLetterChk {get;set;}
    public String recordName {get;set;}
    public String objectId {get;set;}
    //public PropStrength__Service_Request__c servObj{get;set;}
    public PropStrength__Broker__c partnerObj{get;set;}
    public String selectedCCAddress {get;set;}
    public String selectedBCCAddress {get;set;}
    public String selectedEmailTemplate {get;set;}
    public List<SelectOption> availableTemplates {get;set;}
   
    //** Private instance variables
    private Map<String,String> paramMap = ApexPages.CurrentPage().getParameters();
    public List<SelectOption> emailListToReturn = new List<SelectOption>();
    private sObject objectRecord;
    private String action='';
    private String orignalEmailId='';
    private String serializedId ='';
    private PropStrength__Email__c composedEmail;
    private String composedEmailName='';
    private Attachment bodyAttachment;
    private Set<id> attachmentIds;
    private List<Attachment> attachmentList;
    private String hiddenBccAddress='';
    private String taskId='';
    private String isDraft='';
    private Map<String,String> objIdsMap;
   
    public ComposeEmailController() {
        objIdsMap = new Map<String,String>();
        composedEmail = new PropStrength__Email__c();
        bodyAttachment = new Attachment();
        recordName = '';
        composedEmailBody = '';
        selectedEmailTemplate = '--None--';
        offerLetterChk = 'False';
        isDraft = 'False';
        attachmentIds = new Set<id>();
        ccAddressList = new List<SelectOption>();
        bccAddressList = new List<SelectOption>();
        availableTemplates = new List<SelectOption>();
        ccAddressList.add(new SelectOption('--None--', '--None--'));
        bccAddressList.add(new SelectOption('--None--', '--None--'));
        selectedCCAddress = '--None--';
        selectedBCCAddress = '--None--';

        String lastSignature = callSignature();
        composedEmailBody += lastSignature;
        
        String ccAdd = System.Label.Email_Address_For_CC_ComposeEmail;
        List<String> ccAddList = ccAdd.split(',');
        if(!ccAddList.isEmpty()) {
            for(String add : ccAddList) {
                String temp = add.trim();
                ccAddressList.add(new SelectOption(temp, temp));
            }
        }
        
        String bccAdd = System.Label.Email_Address_For_BCC_ComposeEmail;
        List<String> bccAddList = bccAdd.split(',');
        if(!bccAddList.isEmpty()) {
            for(String address : bccAddList) {
                String tempAdd = address.trim();
                bccAddressList.add(new SelectOption(tempAdd, tempAdd));
            }
        }

        List<EmailTemplate> emailTemplatesList = [select id, Markup, Name from emailtemplate where IsActive = true and TemplateType = 'visualforce'];

        availableTemplates.add(new SelectOption('--None--', '--None--'));
        for(EmailTemplate et : emailTemplatesList) {
            if(et.Markup != null && et.Markup.containsIgnoreCase('relatedToType="PropStrength__Service_Request__c"')) {
                availableTemplates.add(new SelectOption(et.Id, et.Name));
            }
        }
        
        createData();
        if(isDraft=='False')
            dataOnLoad();
        else
            draftedDataOnLoad();
    }
   
    private void fetchParamValues( String serializedIds ) {
        if( paramMap.containsKey('action') )
            action = paramMap.get('action');
        if( paramMap.containsKey('emailId') )
            orignalEmailId = paramMap.get('emailId');
        if( paramMap.containsKey('objName') )
            objectName = paramMap.get('objName');
        if( paramMap.containsKey('objId') )
            objectId = paramMap.get('objId');
        if( paramMap.containsKey('attachmentIds') )
            serializedId = paramMap.get('attachmentIds');
            System.debug('****serializedId in line 66 ***'+serializedId);
        if( paramMap.containsKey('offerLetterChk') )
            offerLetterChk = paramMap.get('offerLetterChk');
        if(paramMap.containsKey('isDraft'))
            isDraft = paramMap.get('isDraft');
        if(paramMap.containsKey('taskId'))
            taskId = paramMap.get('taskId');
       
    }
    
    public void createData() {
        String serializedIds;
        System.debug('****serializedIds in line 92 ***'+serializedIds);
        fetchParamValues(serializedIds);
        System.debug('****serializedIds in line 94 ***'+serializedIds);
        if( objectName != 'Contact' ) { //  objectName != 'bookRequest' &&
            List<PropStrength__Email__c> emailRec = new List<PropStrength__Email__c>();
           
            if(orignalEmailId != null && orignalEmailId != '') {
                emailRec = [Select PropStrength__Service_Request__c,PropStrength__Assign_To__c from PropStrength__Email__c where id=:orignalEmailId];   
               
                if( action == 'reply' || action == 'replytoall' ) {
                    if( emailRec[0].PropStrength__Assign_To__c != null ) {
                        objIdsMap.put('contact',emailRec[0].PropStrength__Assign_To__c);
                    }
                   
                    if( emailRec != null && !emailRec.isEmpty() ) {
                        if( emailRec[0].PropStrength__Service_Request__c != null ) {
                            objectName = 'bookRequest';
                            objectId = emailRec[0].PropStrength__Service_Request__c;
                        }else if( emailRec[0].PropStrength__Assign_To__c != null ) {
                            objectName = 'contact';
                            objectId = emailRec[0].PropStrength__Assign_To__c;
                        }else {
                            objectName = '';
                            objectId = '';
                        }
                    }
                }
            }
        }
       
        System.debug('**serializedId**'+serializedId);
        if(serializedId != null && serializedId != '') {
            for( Id i : (List<id>)JSON.deserialize(serializedId, List<Id>.class)) {
                attachmentIds.add(i);
            }
        }
       // srModuleChk = ( objectName != 'bookRequest' );
        srModuleChk = true;
        if(action != 'new' && orignalEmailId != null && orignalEmailId != '') {
            List<PropStrength__Email__c> tempOrignalEmailObj = [Select PropStrength__Status__c,PropStrength__TemplateId__c,PropStrength__Message_ID__c,PropStrength__BCC_Address__c,PropStrength__Service_Request__c,PropStrength__Subject__c,PropStrength__Message_Date__c
                                             ,PropStrength__CC_Address__c,PropStrength__From_Address__c,PropStrength__To_Address__c,Name,Id from PropStrength__Email__c Where id=:orignalEmailId];
           
            if( tempOrignalEmailObj != null && tempOrignalEmailObj.size() > 0 )
                orignalEmailObj = tempOrignalEmailObj[0];
            else
                orignalEmailObj = new PropStrength__Email__c();
        }else
            orignalEmailObj = new PropStrength__Email__c();
        
            sObjectRecordLogic(objectName,objectId);
    }
   
    private void sObjectRecordLogic(String objectName , String objectId) {
        
      if(objectName == 'bookRequest') {
            objectRecord = new PropStrength__Service_Request__c();
            if( objectId != null && objectId != '' )
                objectRecord =[Select id,Name,PropStrength__Project__c, PropStrength__Customer_Code__c,PropStrength__Contact__r.Email,
                                PropStrength__Contact__c, PropStrength__Customer__c,PropStrength__Customer__r.PropStrength__Applicant_Acc__r.Email,
                                PropStrength__Email_Address__c,PropStrength__Assigned_To__c,PropStrength__Assigned_To__r.Email  
                                from PropStrength__Service_Request__c Where id=:objectId];
       
            PropStrength__Service_Request__c req = (PropStrength__Service_Request__c)objectRecord;
            if( req.Name != null && req.Name != '' )
                recordName = req.Name;
        }else if(objectName == 'appDetail') {
            objectRecord = new PropStrength__Applicant_Detail__c();
            if( objectId != null && objectId != '' )
                objectRecord = [Select id,Name,PropStrength__Applicant_Email__c From PropStrength__Applicant_Detail__c Where id=:objectId];
        }
       
        if( objectName == 'contact' || objectName == 'Contacts' ) {
            objectRecord = new Contact();
            List<Contact> conRec;
            if( objectId != null && objectId != '' ){
                conRec = [Select Name, Email , Description from Contact Where id =:objectId limit 1];
                recordName = conRec[0].Name;
            }
            if(conRec != null && conRec.size()>0 )
                objectRecord = conRec[0];
        }
    }
   
    public void draftedDataOnLoad() {
        if( objectName != 'Contacts' ){
            //fromAddressList = EmailUtilClass.getFromAddress(objectName);
            //fromAddressList = emailListToReturn;
            fromAddressList = EmailUtilClass.getFromAddress(objectName);
            System.debug('*******fromAddressList*******'+fromAddressList);
            
                                
            
        }   
        selectedFromAddress = orignalEmailObj.PropStrength__From_Address__c;
        System.debug('*******fromAddressList*******'+fromAddressList);

        
        if( objectName != 'bookRequest' && objectName != 'contact' )
            hiddenBccAddress = EmailUtilClass.displayBCCAddress(objectName,selectedFromAddress);
       
        if( orignalEmailObj != null ) {
            toAddress = orignalEmailObj.PropStrength__To_Address__c;
            ccAddress = orignalEmailObj.PropStrength__CC_Address__c;
            bccAddress = orignalEmailObj.PropStrength__BCC_Address__c;
            subject = EmailUtilClass.displySubject( objectRecord, action , orignalEmailObj,  objectName);
            selectedTemplate = orignalEmailObj.PropStrength__TemplateId__c;
           
            for( Attachment attach : [Select Name,id,Body from Attachment Where parentid=:orignalEmailObj.id] ) {
                if(attach.Name!=orignalEmailObj.Name+'.html')
                    attachmentIds.add(attach.id);
                else{
                    bodyAttachment = attach;
                    composedEmailBody = EmailUtilClass.blobToString(attach.Body,'utf-8');
                    system.debug('composedEmailBody::'+composedEmailBody);
                }     
            }
            composedEmail = orignalEmailObj;
        }
        
        updateAttachmentList();
    }

    public String callSignature() {
        User u = [SELECT Id, Name, UserRole.Name, Email,Telephone__c, MobilePhone FROM User WHERE Id = :UserInfo.getUserId()];
        
        return '<br/><br/><br/><br/> <b>'+u.Name+'</b> <br/> '+u.UserRole.Name+' | <br/><br/> T: <u> '+(u.Telephone__c == null?'':u.Telephone__c)	+'</u><br/>M: <u>'+u.MobilePhone+'</u><br/> E: <u>'+u.Email+'</u><br/>  <a href="https://www.sobharealty.com/"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZ0z&oid=00D3N0000000e7H" style="width:50%;"></img></a>  <br/><br/>    <a href="https://www.facebook.com/SobhaRealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZAf&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;<a href="https://www.instagram.com/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZH7&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;<a href="https://www.linkedin.com/company/sobharealty/" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZFV&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;<a href="https://twitter.com/SobhaRealty" style="width:1%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZ2b&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ" style="width:2.5%; height:1%;"><img src="https://sobharealty--devcs.sandbox.file.force.com/servlet/servlet.ImageServer?id=015Vc000000PZCH&oid=00D3N0000000e7H" width="1.8%"></img></a>&nbsp;<a href="https://www.sobharealty.com/" style="color:black;">www.sobharealty.com</a>';
    }
   
    public void dataOnLoad() {
            List<String> ProjectNotnullEmail = new List<String>();
            
            if(objectName != 'Contacts' ) { 
           // fromAddressList = emailListToReturn;
                fromAddressList = EmailUtilClass.getFromAddress(objectName);
            System.debug('*******fromAddressList****cv***'+fromAddressList);
            
        }else {
            selectedFromAddress = EmailUtilClass.getFromAddress(objectName)[0].getValue();
            System.debug('*******selectedFromAddress***'+selectedFromAddress);
        }
       
        if(objectName  != 'BookRequest' && objectName != 'Contact' )
             //subject = orignalEmailObj.PropStrength__Subject__c;
            subject = EmailUtilClass.displySubject( objectRecord,  action , orignalEmailObj, objectName);
            System.debug('*******subject235***'+subject);
         
        if( action != 'forward' )
        toAddress = EmailUtilClass.displayToAddress(action,objectName,orignalEmailObj,objectRecord);
        addToAddress = EmailUtilClass.additionalToAddress(objectName,action,orignalEmailObj,objectRecord,selectedFromAddress);
        ccAddress = EmailUtilClass.displayCCAddress(action,orignalEmailObj); 
        subject =EmailUtilClass.displySubject( objectRecord, action , orignalEmailObj, objectName);
        System.debug('******subject242*****'+subject);
       
        if( objectName != 'bookRequest' && objectName != 'Contact' )
            hiddenBccAddress = EmailUtilClass.displayBCCAddress(objectName,selectedFromAddress);
        else
            bccAddress = EmailUtilClass.displayBCCAddress(objectName,selectedFromAddress);
       
        // to set selectedFromAddress
        if( objectName != 'bookRequest' && objectName != 'Contact' ) {
            List<String> userInboxList = new List<String>();
            selectedFromAddress = fromAddressList[0].getValue();
           System.debug('***[0]****fromAddressList*******'+fromAddressList);
           
           
           
           
            onChangeFromAddress();
        }else{
             User u = [Select id FROm User where id=:UserInfo.getUserId()];
             composedEmailBody += EmailUtilClass.getEmailBody(orignalEmailObj,action);   
            System.debug('composedEmailBody at line number 276'+composedEmailBody);
        }
        updateAttachmentList();
    }
    
   
    public void updateAttachmentList() {
        attachmentWrapList = new List<AttachWrapper>();
        if( !attachmentIds.isEmpty() ) {
            for( Attachment attach : [Select parentId,id,Name,BodyLength from Attachment where id IN :attachmentIds] ) {
                attachmentWrapList.add( new AttachWrapper( attach,AttachmentWrapList.size() ) );
            }
        }
    }
    
    public void onChangeCCAddress() {
        System.debug(selectedCCAddress);
        if(selectedCCAddress != '--None--' && (ccAddress == null || ccAddress == '')) {
            ccAddress += selectedCCAddress;
        } else if (selectedCCAddress != '--None--' && ccAddress.contains(selectedCCAddress) == false) {
            ccAddress += ',' + selectedCCAddress;
        } else if(selectedCCAddress != '--None--' && ccAddress.contains(selectedCCAddress)){
            Integer index = ccAddress.indexOf(selectedCCAddress);
            ccAddress = ccAddress.remove(selectedCCAddress);
            if(ccAddress != null && ccAddress != '' && (index-1) > 0 && (index+1) < ccAddress.length() && ccAddress.substring(index-1,index+1) == ',,') {
                ccAddress = ccAddress.substring(0,index) + ccAddress.substring(index+1);
            }
            if(ccAddress != null && ccAddress != '' && ccAddress.lastIndexOf(',') >= ccAddress.length()-1) {
                ccAddress = ccAddress.substring(0,ccAddress.length()-1);
            }
            if(ccAddress != null && ccAddress != '' && ccAddress.indexOf(',') == 0) {
                ccAddress = ccAddress.substring(1);
            }
        }
        selectedCCAddress = '--None--';
    }
    
    public void onChangeBCCAddress() {
        System.debug(selectedBCCAddress);
        if(selectedBCCAddress != '--None--' && (bccAddress == null || bccAddress == '')) {
            bccAddress += selectedBCCAddress;
        } else if (selectedBCCAddress != '--None--' && bccAddress.contains(selectedBCCAddress) == false) {
            bccAddress += ',' + selectedBCCAddress;
        } else if(selectedBCCAddress != '--None--' && bccAddress.contains(selectedBCCAddress)){
            Integer index = bccAddress.indexOf(selectedBCCAddress);
            bccAddress = bccAddress.remove(selectedBCCAddress);
            if(bccAddress != null && bccAddress != '' && (index-1) > 0 && (index+1) < bccAddress.length() && bccAddress.substring(index-1,index+1) == ',,') {
                bccAddress = bccAddress.substring(0,index) + bccAddress.substring(index+1);
            }
            if(bccAddress != null && bccAddress != '' && bccAddress.lastIndexOf(',') >= bccAddress.length()-1) {
                bccAddress = bccAddress.substring(0,bccAddress.length()-1);
            }
            if(bccAddress != null && bccAddress != '' && bccAddress.indexOf(',') == 0) {
                bccAddress = bccAddress.substring(1);
            }
        }
        selectedBCCAddress = '--None--';
    }
    
    public void onChangeFromAddress() {
   
        String templatename = EmailUtilClass.getTemplateName(objectName,selectedFromAddress);
        if(templatename != null && templatename!='' ) {
            User u = [Select id FROm User where id=:UserInfo.getUserId()];
            composedEmailBody += EmailUtilClass.getEmailBody( orignalEmailObj,action);
            List<EMailTemplate> template = setTemplates(templatename);
           
            if(!template.isEmpty() && template[0].HtmlValue != null) {
                selectedTemplate = template[0].Id;
               
                String formattedTemplateBody = EmailUtilClass.substitute(template[0].HtmlValue,selectedFromAddress,objectId);
                system.debug('*********formattedTemplateBody********'+formattedTemplateBody);
                composedEmailBody = formattedTemplateBody+EmailUtilClass.getEmailBody(orignalEmailObj,action);
            }else {   
                selectedTemplate = ''; 
            }  
            
            if(objectName != 'bookRequest' && objectName != 'Contact')
                hiddenBccAddress = EmailUtilClass.displayBCCAddress(objectName,selectedFromAddress);
            else
                bccAddress = EmailUtilClass.displayBCCAddress(objectName,selectedFromAddress);
        }else{ 
            User u = [Select id FROm User where id=:UserInfo.getUserId()];
            composedEmailBody += EmailUtilClass.getEmailBody(orignalEmailObj,action);
            selectedTemplate = '';
        }
        system.debug('=====subject ===='+subject ); 
    }
   
    public List<EMailTemplate> setTemplates(String templateName) {
        system.debug('*******templateName********'+templateName);
        List<EMailTemplate> templateToReturn = [Select Subject,id,HtmlValue from EMailTemplate Where Name =:templateName];
        return templateToReturn;
    }
   
    public EMailTemplate setTemplatesBody(String templateId) {
        EMailTemplate templateToReturn = [Select Subject,id,HtmlValue from EMailTemplate Where id =:templateId];
        return templateToReturn;
    }
   
    public void onChangeTemplates() {
        composedEmailBody = '';
        system.debug('----selectedTemplate ----'+selectedTemplate );
        if(selectedTemplate != null && selectedTemplate != '') {
            String templateBody = '';
            if( setTemplatesBody(selectedTemplate) != null ) {
                EMailTemplate returnedTemplate = setTemplatesBody(selectedTemplate);
                if( returnedTemplate.HtmlValue != null )
                    templateBody = returnedTemplate.HtmlValue;
               
               
               /* if( returnedTemplate.Subject!=null  && (objectName == 'bookRequest'  || objectName == 'Contacts' ) )
                    subject = returnedTemplate.Subject;
                else if(objectName == 'bookRequest' ||  objectName == 'Contacts' )
                    subject ='';*/
                  
            }
           
            system.debug('templateBody*****************'+templateBody);
            User u = [Select id FROm User where id=:UserInfo.getUserId()];
            if(templateBody != null) {
                String formattedTemplateBody =  EmailUtilClass.substitute(templateBody,selectedFromAddress,objectId);
                string str = EmailUtilClass.getEmailBody(orignalEmailObj,action);
                composedEmailBody += formattedTemplateBody; 
                if( objectName == 'bookRequest' || objectName == 'contact' )
                    composedEmailBody = composedEmailBody+str;                                                                                                                                                                                                                                                                                                                                                                                   system.debug('====str ==='+str );
                                                                                                                                                                                                                                                                                                                                                                                                        system.debug('====composedEmailBody ==='+composedEmailBody );
            }
        }else {
            User u = [Select id FROm User where id=:UserInfo.getUserId()];
            composedEmailBody = EmailUtilClass.getEmailBody(orignalEmailObj,action);
            if( action != 'new' && (objectName == 'bookRequest' || objectName == 'contact' ) )
                subject = orignalEmailObj.PropStrength__Subject__c;
                System.debug('******subject355***'+subject);
            /*else {
                if(objectName == 'bookRequest' || objectName == 'contacts')
                    subject = '';   
            }  */ 
        }   
    }   
   
    public List<SelectOption> getTemplateList () {
        return EmailUtilClass.getAllTemplates(objectName);
    }
   
    public Pagereference deleteAttachment() {
        Integer column = Integer.valueOf(System.currentPageReference().getParameters().get('colValue'));
       
        if(column != null) {
            Attachment attachToDel = attachmentWrapList.get(column).attachment;
            attachmentWrapList.remove(column);
            if( attachToDel.parentId != orignalEmailObj.id ) {
                Attachment attach = new Attachment(id = attachToDel.id);
                delete attach;
            }
            if(attachmentIds.contains(attachToDel.id))
                attachmentIds.remove(attachToDel.id);
        }
        updateAttachmentList();
        return null;
    }
   
    public Pagereference upload() {
        try {
            PropStrength__Email__c composedEmailDrafted;
            List<PropStrength__Email__c> tempEmailList = new List<PropStrength__Email__c>();
            system.debug('******composedEmailName******'+composedEmailName );
            if( composedEmailName != null && composedEmailName != '' )
                tempEmailList = [Select id ,Name from PropStrength__Email__c Where Name=:composedEmailName And PropStrength__Status__c='Draft'];
          
            if( tempEmailList != null && tempEmailList.size()>0 )
                composedEmailDrafted = tempEmailList[0];
            else
                composedEmailDrafted = composedEmail;
               
            system.debug('******composedEmailDrafted******'+composedEmailDrafted );   
            composedEmail = EmailUtilClass.upsertEmail( composedEmailDrafted , objectName, objectId, composedEmailBody, selectedFromAddress, ccAddress, bccAddress, selectedTemplate, subject,toAddress,addToAddress, action, objIdsMap );
            composedEmail.PropStrength__Status__c = 'Draft';
           
            if(action != 'new') {
                if(orignalEmailObj.id != null) {
                    composedEmail.PropStrength__In_Reply_To__c = orignalEmailObj.PropStrength__Message_ID__c;
                    composedEmail.PropStrength__Email_Reference__c = orignalEmailObj.PropStrength__Message_ID__c;
                    composedEmail.PropStrength__Message_Id__c = orignalEmailObj.PropStrength__Message_ID__c;
                }
            }
            upsert composedEmail;
            Set<id> attachIdSet = new Set<id>();
           
            Attachment attachObj;
            if(attachName != null && attachName != '' && attachBody != null) {
                attachObj = new Attachment();
                attachObj.parentid = composedEmail.id;
                attachObj.Name = attachName;
                attachObj.Body = attachBody;
                insert attachObj;
                attachmentIds.add(attachObj.id);
            }
            List<PropStrength__Email__c> tempEmail = [Select Name,id from PropStrength__Email__c where id=:composedEmail.id];
            if( tempEmail != null && tempEmail.size() > 0 )
                composedEmailName = tempEmail[0].Name;
            bodyAttachment = EmailUtilClass.upsertBodyAttachment( bodyAttachment,composedEmailBody,composedEmail.id,composedEmailName );
            upsert bodyAttachment;
        }catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file. Please try again'));
            return null; 
        }
        updateAttachmentList();
        return null;
    }
   
    public pageReference saveToDraft() {
        Savepoint sp = Database.setSavepoint();
        try {
            composedEmail = EmailUtilClass.upsertEmail( composedEmail, objectName, objectId, composedEmailBody, selectedFromAddress, ccAddress, bccAddress, selectedTemplate, subject,toAddress,addToAddress, action, objIdsMap );
            composedEmail.PropStrength__Status__c = 'Draft';
           
            if(action != 'new') {
                if(orignalEmailObj.id != null) {
                    composedEmail.PropStrength__Email_Reference__c = orignalEmailObj.PropStrength__Message_ID__c ;
                    composedEmail.PropStrength__Message_Id__c = orignalEmailObj.PropStrength__Message_ID__c ;
                    //composedEmail.Reply_To_Email__c = orignalEmailObj.id;
                }
            }
            upsert composedEmail;
           
            String composedName = [Select Name from PropStrength__Email__c where id = :composedEmail.id].Name;
            bodyAttachment = EmailUtilClass.upsertBodyAttachment( bodyAttachment,composedEmailBody,composedEmail.id,composedName );
            upsert bodyAttachment;
            
            if( !attachmentIds.isEmpty() ) {
                List<Attachment> attachmentsBody = [Select id, body,parentId, Name From Attachment Where id IN: attachmentIds]; 
                System.debug('*****attachmentsBody at line 453*****'+attachmentsBody);          
                if(action == 'forward' && isDraft!='True')
                    existingAttachmentsOnLoad(attachmentsBody);
            }
            if( objectId != null && objectId != '' )
                return new pageReference('/'+objectId).setRedirect(true);
            else if ( composedEmail.id != null )
                return new pageReference('/'+composedEmail.id).setRedirect(true);
            else  
                return new PageReference('/'+'a1S/o').setRedirect(true);
        }catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is some problem with drafting. Please try again. Please donot refresh url.'));
            return null; 
        }
    }
   
    public pagereference doCancel() {
        pageReference page = new pageReference('/'+objectId);       
        page.setRedirect(true);
        return page;
    }
   
    public pageReference sendSRMail() {
        Savepoint sp = Database.setSavepoint();
        List<String> toAddressList = new List<String>();
        List<String> addToAddressList = new List<String>();
        List<String> ccAddressList = new List<String>();
        List<String> bccAddressList = new List<String>();
       
        if(toAddress != null && toAddress.trim() != '')
            toAddressList = toAddress.split(',') ;  
        if(addToAddress != null && addToAddress.trim() != '')
            addToAddressList = addToAddress.split(',') ;  
           
        if(bccAddress != null && bccAddress != '')
            bccAddressList = bccAddress.split(',');  
       
        if(hiddenBccAddress != null && hiddenBccAddress != '')
            bccAddressList.add(hiddenBccAddress);
       
        if(ccAddress != null && ccAddress != '')
            ccAddressList = ccAddress.split(',') ;  
           
        List<Attachment> attachmentsBody = [Select id, body,parentId, Name From Attachment Where id IN: attachmentIds];
       
        Messaging.SingleEmailMessage mail = EmailUtilClass.createEmail(toAddressList,addToAddressList,ccAddressList ,
            bccAddressList ,subject, composedEmailBody,attachmentsBody,orignalEmailObj,objectId,objectName,action,selectedFromAddress,offerLetterChk);
        PropStrength__Email__c composedEmailDrafted = new PropStrength__Email__c();
        List<PropStrength__Email__c> tempEmailList = new List<PropStrength__Email__c>();
        system.debug('******composedEmailName******'+composedEmailName );
        if( composedEmailName != null && composedEmailName != '' )
            tempEmailList = [Select id,Name,PropStrength__Message_ID__c from PropStrength__Email__c Where Name=:composedEmailName And PropStrength__Status__c='Draft'];
      
        if( tempEmailList != null && tempEmailList.size()>0 )
            composedEmailDrafted = tempEmailList[0];
        else
            composedEmailDrafted = composedEmail;
        system.debug('******composedEmailDrafted******'+composedEmailDrafted );
        PropStrength__Email__c emailToUpsert = EmailUtilClass.upsertEmail( composedEmailDrafted, objectName, objectId, composedEmailBody, selectedFromAddress, ccAddress, bccAddress, selectedTemplate, subject,toAddress,addToAddress, action, objIdsMap );
        emailToUpsert.PropStrength__Status__c = 'Sent';
        if(attachmentWrapList.size()>0 || offerLetterChk=='True')
            emailToUpsert.PropStrength__Has_Attachment__c = True; 
        if(action != 'new') {
            if(orignalEmailObj.id != null) {
                emailToUpsert.PropStrength__In_Reply_To__c = orignalEmailObj.PropStrength__Message_ID__c;
                if(isDraft!='True')
                    emailToUpsert.PropStrength__Reply_To_Email__c = orignalEmailObj.id;
                emailToUpsert.PropStrength__Email_Reference__c = orignalEmailObj.PropStrength__Message_ID__c ;
                emailToUpsert.PropStrength__Message_Id__c = emailToUpsert.PropStrength__Message_ID__c ;
            }
        }
       
        upsert emailToUpsert;

        if(action == 'reply') {
            PropStrength__Email__c sr = [SELECT Id, PropStrength__Service_Request__c, PropStrength__Service_Request__r.PropStrength__Status__c FROM PropStrength__Email__c WHERE Id = :emailToUpsert.Id];
            if(sr.PropStrength__Service_Request__r.PropStrength__Status__c == 'New' || sr.PropStrength__Service_Request__r.PropStrength__Status__c == 'Not Started') {
                PropStrength__Service_Request__c srRec = new PropStrength__Service_Request__c(Id = sr.PropStrength__Service_Request__c, PropStrength__Status__c = 'In Progress');
                update srRec;
            }
        }
        if( emailToUpsert.id != null ) {
            List<PropStrength__Email__c> tempEmail = [Select Name,id,PropStrength__Message_ID__c from PropStrength__Email__c where id=:emailToUpsert.id];
            if( tempEmail != null && tempEmail.size() > 0 )
                composedEmailName = tempEmail[0].Name;
        }   
        bodyAttachment = EmailUtilClass.upsertBodyAttachment( bodyAttachment,composedEmailBody,composedEmail.id,composedEmailName);
        if( bodyAttachment != null) {
            try {
                upsert bodyAttachment;
            }catch(Exception e){
                Database.RollBack(sp);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Email sending failed. Please try again.'));       
                return null;
            }
        }
       
        
        if( !attachmentIds.isEmpty() && isDraft!='True' ) {
            if(action == 'forward')
                existingAttachmentsOnLoad(attachmentsBody);
                System.debug('*********attachmentsBody*****'+attachmentsBody);
        }
       
        
        system.debug('*****mail*****'+mail);
        if(mail != null) {
            try {
                Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
            }catch(Exception e){
                emailToUpsert.id=null;
                bodyAttachment.id= null;
                Database.RollBack(sp);
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Email sending failed : '+e.getMessage());
                ApexPages.addMessage(msg);
                return null;
            }
        }else{
            return null;
        }
        if(objectId != null && objectId != '') {
            pageReference page = new PageReference('/'+objectId);
            page.setRedirect(true);
            return page;
        }else
        return new PageReference('/'+'a1S/o').setRedirect(true);
    }

    

    public void onChangeEmailTemplate() {
        System.debug(selectedEmailTemplate);
        
        if(selectedEmailTemplate != '--None--') {
            EmailTemplate emTemp = [SELECT Id, Markup FROM EmailTemplate WHERE Id = :selectedEmailTemplate];
            composedEmailBody = emTemp.Markup;
            System.debug('composedEmailBody before****');
            System.debug(composedEmailBody);
            if(composedEmailBody.contains('<a href="https://www.instagram.com/sobharealty')) {
                if(composedEmailBody.contains('<messaging:htmlEmailBody>')) {
                    composedEmailBody = composedEmailBody.substring(composedEmailBody.indexOf('<messaging:htmlEmailBody>')+25, composedEmailBody.indexOf('<a href="https://www.instagram.com/sobharealty'));
                } else if(composedEmailBody.contains('<messaging:htmlEmailBody >')) {
                    composedEmailBody = composedEmailBody.substring(composedEmailBody.indexOf('<messaging:htmlEmailBody >')+26, composedEmailBody.indexOf('<a href="https://www.instagram.com/sobharealty'));
                }
            } else {
                if(composedEmailBody.contains('<messaging:htmlEmailBody>')) {
                    composedEmailBody = composedEmailBody.substring(composedEmailBody.indexOf('<messaging:htmlEmailBody>')+25, composedEmailBody.indexOf('</messaging:htmlEmailBody>'));
                } else if(composedEmailBody.contains('<messaging:htmlEmailBody >')) {
                    composedEmailBody = composedEmailBody.substring(composedEmailBody.indexOf('<messaging:htmlEmailBody >')+26, composedEmailBody.indexOf('</messaging:htmlEmailBody>'));
                }
            }

            String tempComposedEmailBody = composedEmailBody;
            List<String> wordToQuery = new List<String>();

            List<String> words = composedEmailBody.split('\\s+');
            for (String word : words) {
                if (word.containsIgnoreCase('{!relatedTo.')) {
                    wordToQuery.add(word.substring(word.indexOf('{!relatedTo.')+12, word.indexOf('}')));
                }
            }

            System.debug('wordToQuery****');
            System.debug(wordToQuery);

            if(!wordToQuery.isEmpty()) {
                String queryStr = 'SELECT Id, ';
                queryStr += String.join(wordToQuery, ',')+' FROM PropStrength__Service_Request__c WHERE Id = \''+objectId+'\'';
                
                System.debug('queryStr****');
                System.debug(queryStr);

                List<PropStrength__Service_Request__c> queryResults = Database.query(queryStr);
                
                for (String word : words) {
                    if (word.containsIgnoreCase('{!relatedTo.')) {
                        String temp = word.substring(word.indexOf('{!relatedTo.')+12, word.indexOf('}'));
                        String oldValue = word.substring(word.indexOf('{!relatedTo.'), word.indexOf('}')+1);
                        String newValue = String.valueOf(queryResults[0].get(temp));
                        tempComposedEmailBody = tempComposedEmailBody.replace(oldValue, newValue);
                    }
                }

                System.debug('tempComposedEmailBody****');
                System.debug(tempComposedEmailBody);
            }

            composedEmailBody = tempComposedEmailBody;

            String lastSignature = callSignature();
            composedEmailBody += lastSignature;
        } else if(selectedEmailTemplate == '--None--') {
            composedEmailBody = '';
            String lastSignature = callSignature();
            composedEmailBody += lastSignature;
        }

        System.debug('composedEmailBody****');
        System.debug(composedEmailBody);
    }
   
   
    
  @TestVisible private void existingAttachmentsOnLoad(List<Attachment> attachmentsBody) {
       
        Set<Attachment> orignalEmailAttachment = new Set<Attachment>();
        List<Attachment> attListToInsert = new List<Attachment>();
        if( !attachmentsBody.isEmpty() ) {
            for( Attachment attach : attachmentsBody) {
                if( attach.parentId == orignalEmailId )
                    orignalEmailAttachment.add(attach);
            }  
        }
       
        if( !orignalEmailAttachment.isEmpty() ) {
            Attachment attachedObj;
            for( Attachment attach : orignalEmailAttachment ) {
                attachedObj = new Attachment();
                attachedObj.Name = attach.Name;
                attachedObj.Body = attach.Body;
                attachedObj.parentId = composedEmail.id;
                attListToInsert.add(attachedObj);
            }
        }
        if( !attListToInsert.isEmpty() ) {
            try {
                insert attListToInsert;
            }catch( Exception e ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is some error in sending file.Please try again. Donot refresh the url'));
            }
        }   
    }
   
    public class AttachWrapper {
        public Attachment attachment {get;set;}
        public Integer column {get;set;}
       
        public attachWrapper(Attachment attach, Integer col){
            attachment = attach;
            column = col; 
        }            
    }
}