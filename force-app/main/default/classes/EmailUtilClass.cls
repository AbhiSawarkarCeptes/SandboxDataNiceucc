public class EmailUtilClass {
   
    public static String objectPrefix( String ids ) {
        String prefix;
        Map<String,String> objectTypeMap = new Map<String,String>();
        for( String str : new Set<String>{'Contact','PropStrength__Service_Request__c','PropStrength__Offer__c'} ) {
            prefix = Schema.getGlobalDescribe().get(str).getDescribe().getKeyPrefix();   
            objectTypeMap.put(prefix ,str);
        }
       
        String subStr = ids.substring(0,3);
        if( objectTypeMap.containsKey(subStr) )
            prefix = objectTypeMap.get(subStr);
        return prefix;
    }
   
    public static List<SelectOption> getFromAddress(String objName) {
        List<SelectOption> emailListToReturn = new List<SelectOption>();
       system.debug('email uiyt_____'+objName);
        if( objName == 'contact' || objName == 'bookRequest') { 
        system.debug('email uiyt11_____'+objName);
            
            List<OrgWideEmailAddress> oweList = [Select Address,DisplayName from OrgWideEmailAddress ORDER BY Address ASC];
            String OfferEnqEmailAdd = '';
            if(oweList != null && oweList.size() > 0){               
                for(OrgWideEmailAddress owdvar :  oweList){                    
                        emailListToReturn.add(new SelectOption(owdvar.Address,owdvar.Address));                          
                }
            }
            
        }else {
            system.debug('email uiyt11_____'+objName);
          
            emailListToReturn.add( new SelectOption(Userinfo.getUserEmail(),Userinfo.getName()+' ('+Userinfo.getUserEmail()+')') ); 
        }
        return emailListToReturn;
    }
    public static String displaytoAddress(String action,String objectName , PropStrength__Email__c orignalEmailObj,sObject objectRecord ) {
       
        String toAddressToReturn='';
        if( objectName == 'bookRequest' ){
            PropStrength__Service_Request__c request = (PropStrength__Service_Request__c)objectRecord;
            //if( request.Partner_Name__c != null && request.Partner_Name__r.PropStrength__Email_Id__c != null )
               // toAddressToReturn = request.Partner_Name__r.PropStrength__Email_Id__c;
             if(request.PropStrength__Contact__c!=null)
                toAddressToReturn = request.PropStrength__Contact__r.Email;
             else if(request.PropStrength__Customer__c!=null)
                toAddressToReturn = request.PropStrength__Customer__r.PropStrength__Applicant_Acc__r.Email;
            else if(request.PropStrength__Email_Address__c!= null)
                 toAddressToReturn = request.PropStrength__Email_Address__c;
        }
        
         
           
        if(action != 'new') {
             if(orignalEmailObj.PropStrength__From_Address__c != null)
                    toAddressToReturn = orignalEmailObj.PropStrength__From_Address__c;
        }else if( objectName == 'appDetail' ) {
            PropStrength__Applicant_Detail__c appDetRec = (PropStrength__Applicant_Detail__c)objectRecord;
            if(appDetRec.PropStrength__Applicant_Email__c!= null && appDetRec.PropStrength__Applicant_Email__c!= '' )
                toAddressToReturn = appDetRec.PropStrength__Applicant_Email__c;
        }
       
        if(objectName == 'contact' || objectName == 'Contacts') {
            Contact contactRec = (Contact)objectRecord;
            if(contactRec.Email != null && contactRec.Email != '' )
                toAddressToReturn = contactRec.Email;
        }
       
        return toAddressToReturn;
    }
   
    public static String additionalToAddress(String objectName,String action,PropStrength__Email__c orignalEmailObj,sObject objectRecord,String selectedFromAddress ) {
        String addToAddress = '';
        if(action == 'replyToAll') {
            List<String> addToTempAddress = new List<String>();
            if( orignalEmailObj.PropStrength__To_Address__c!=null && orignalEmailObj.PropStrength__To_Address__c!='' ) {
                orignalEmailObj.PropStrength__To_Address__c.trim();
                addToTempAddress = orignalEmailObj.PropStrength__To_Address__c.split(',');
            }   
               
            if(!addToTempAddress.isEmpty()) {
                for( String add : addToTempAddress ) {
                    
                        String tempToAddress = '';
                        if( objectName == 'bookRequest' ){
                            PropStrength__Service_Request__c request = (PropStrength__Service_Request__c)objectRecord;
                            if(request.PropStrength__Assigned_To__c!=null)
                                tempToAddress = request.PropStrength__Assigned_To__r.Email;
                        }   
                       
                        else if( objectName == 'contact' ) {
                            Contact contactRec = (Contact)objectRecord;
                            if(contactRec.Email != null && contactRec.Email != '' )
                                tempToAddress = contactRec.Email;
                        }   
                            if( tempToAddress != add && add != selectedFromAddress )
                                addToAddress+=add+',';
                    
                }
            }
        }
        if( addToAddress != null && addToAddress != '' && addToAddress.containsWhitespace() )
            addToAddress = addToAddress.deleteWhitespace();
        if( addToAddress != null && addToAddress != '' && addToAddress.endsWith(',') )
                  addToAddress = addToAddress.subString(0, (addToAddress.length()-1) );
        return addToAddress;
    }
   
    public static String displayCCAddress(String action,PropStrength__Email__c orignalEmailObj) {
        String ccAddressToReturn = '';
        if(action == 'replyToAll') {
            if( orignalEmailObj.PropStrength__CC_Address__c!=null && orignalEmailObj.PropStrength__CC_Address__c!='' )
                ccAddressToReturn = orignalEmailObj.PropStrength__CC_Address__c;
        }
        if( ccAddressToReturn != null && ccAddressToReturn != '' && ccAddressToReturn.containsWhitespace() )
            ccAddressToReturn = ccAddressToReturn.deleteWhitespace();
        return ccAddressToReturn;
    }
    
    public static String displayBCCAddress(String objName,String selectedFromAddress) {
        String bccToReturn='';
       
        if( bccToReturn != null && bccToReturn != '' && bccToReturn.containsWhitespace() )
            bccToReturn = bccToReturn.deleteWhitespace();
        return bccToReturn;
    }
  
   
    public static String displySubject(sObject objectRecord, String action , PropStrength__Email__c orignalEmailObj, String objectName){
        String Subject='';
        if(orignalEmailObj!=null){
            Subject = orignalEmailObj.PropStrength__subject__c;
            if(Subject.contains('Re:')) {
                Subject = Subject.remove('Re:');
            }
            if(Subject.contains('Sandbox:')){
                Subject = Subject.remove('Sandbox:');
            }
        }
        System.debug(Subject+'*****Subject*****'+orignalEmailObj.PropStrength__subject__c); 
        return Subject;
    }
    
    public static String displaySubject(sObject objectRecord, String action , PropStrength__Email__c orignalEmailObj, String objectName) {
        String subjectToreturn='';
        String actionStr='';
        String Code = '';
        String projectName ='';
       
        if(action == 'Reply' || action == 'ReplyToAll')
            actionStr = 'RE:';
        else if(action == 'Forward')
            actionStr = 'FW:';
           
        String tempSubject = '';
        if( orignalEmailObj != null && orignalEmailObj.PropStrength__subject__c != null ) {
            tempSubject = orignalEmailObj.PropStrength__subject__c;
            if( orignalEmailObj.PropStrength__subject__c.contains('RE:') )
                tempSubject = orignalEmailObj.PropStrength__subject__c.removeStart('RE:');
            else if( orignalEmailObj.PropStrength__subject__c.contains('FW:') )
                tempSubject = orignalEmailObj.PropStrength__subject__c.removeStart('FW:');
            else if( orignalEmailObj.PropStrength__subject__c.contains('Sandbox:') )
                tempSubject = orignalEmailObj.PropStrength__subject__c.removeStart('Sandbox:');
        }
        system.debug('*******tempSubject********'+tempSubject);
        if( objectName == 'bookRequest' ) {
            PropStrength__Service_Request__c serReq = (PropStrength__Service_Request__c)objectRecord;
            /*if( serReq != null ) {
                if( serReq.RecordType.Name != 'Partner SR' && serReq.PropStrength__Customer_Code__c != null )
                    Code = ' Cust_Code: '+serReq.PropStrength__Customer_Code__c;
               
                if( serReq.PropStrength__Project__c!=null )
                    projectName = serReq.PropStrength__Project__c;
            }*/
           
            if( orignalEmailObj.PropStrength__Status__c != 'Sent' ) {
                subjectToreturn = actionStr+projectName+Code;
            }else {
                if( tempSubject != null )   
                    subjectToreturn = actionStr+tempSubject;
            }       
        }else {
            if(orignalEmailObj.PropStrength__subject__c != null )
                subjectToreturn = actionStr+tempSubject;
        }  
            return subjectToreturn;
    }
   
    public static String getEmailBody(PropStrength__Email__c orignalEmailObj , String action ) {
        String oldMsgDetails='';
        if(action != 'new') {
            if(action != 'detailPage' && orignalEmailObj != null ) {
                oldMsgDetails = '<br/><br/>--------------- Original Message ---------------<br/>'; 
                oldMsgDetails += orignalEmailObj.PropStrength__From_Address__c == null ? '' : ('<b> From: </b> ' + orignalEmailObj.PropStrength__From_Address__c + '<br/>');
                oldMsgDetails += orignalEmailObj.PropStrength__To_Address__c == null ? '' : ('<b> To: </b> ' + orignalEmailObj.PropStrength__To_Address__c + '<br/>');
                oldMsgDetails += orignalEmailObj.PropStrength__CC_Address__c == null ? '' : ('<b> CC: </b> ' + orignalEmailObj.PropStrength__CC_Address__c + '<br/>');
                oldMsgDetails += orignalEmailObj.PropStrength__Message_Date__c == null ? '' : ('<b> Time: </b> ' + (orignalEmailObj.PropStrength__Message_Date__c).format('dd/MM/yyyy h:mm a') + '<br/>');
                oldMsgDetails += orignalEmailObj.PropStrength__Subject__c == null ? '' : ('<b> Subject: </b> ' + orignalEmailObj.PropStrength__Subject__c + '<br/><br/>');
            }
            String emailName = '';
            if( orignalEmailObj != null && orignalEmailObj.Name != null && orignalEmailObj.Name != '' )
                emailName = orignalEmailObj.Name+'.html';
            List<Attachment> attachList = [Select Body from Attachment where ParentId = :orignalEmailObj.id AND Name =:emailName];
            system.debug('*******attachListhhh*******'+attachList);
            if(attachList != null && attachList.size() > 0) {
                String str = '';
                System.debug('***attachlist body***'+attachList[0].Body);
                if(attachList[0].Body != null)
                    str = blobToString(attachList[0].Body,'utf-8');
                    System.debug('***getemailbodyString***'+str);
                return oldMsgDetails+str;
            }
        }
        return '';
    }
   
    public static String blobToString(Blob input,String inCharset) {
        if( input != null ) {
            String hex = EncodingUtil.convertToHex(input);
            System.assertEquals(0, hex.length() & 1);
            final Integer bytesCount = hex.length() >> 1;
            String[] bytes = new String[bytesCount];
           
            for(Integer i = 0; i < bytesCount; ++i) {
                bytes[i] = hex.mid(i << 1, 2);
            }  
          //  return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
           
            if(bytes != null && bytes.size()>0 )
                return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
            else
                return '';   
        }else return '';
    }
   
    public static String composedEmailBody(PropStrength__Email__c composedEmail) {
        String emailName = '';
        system.debug('****CDSDS**composedEmailBody*******'+composedEmail);
        if( composedEmail != null && composedEmail.Name != null && composedEmail.Name != '' )
            emailName= composedEmail.Name+'.html';
        List<Attachment> attachList = [Select Body from Attachment where ParentId = :composedEmail.id AND Name =:emailName];
        if(attachList != null && attachList.size() > 0) {
             String str = blobToString(attachList[0].Body,'utf-8');
            return str;
            //return attachList[0].Body.toString();
        }  
        return '';
    }
   
   
    public static String getTemplateName(String objectName,String selectedFromAddress) {
        String templateToReturn='';
       //Need to define a template here
       /* if( objectName != 'bookRequest' && objectName != 'Contacts') {
            system.debug('*******emailInboxMap********'+emailInboxMap() );
            if( emailInboxMap().containsKey(selectedFromAddress) )
                templateToReturn = emailInboxMap().get(selectedFromAddress).Email_Templete_Name__c;
        }*/
        return templateToReturn;
    }
   
    public static List<SelectOption> getAllTemplates(String objectName) {
        String folderNameStr = '';
        List<String> userInboxList;
        List<SelectOption> options = new List<SelectOption>();
        Map<String,String> templateIdMap = new Map<String,String>();
        if( objectName == 'bookRequest' || objectName == 'contact')
       system.debug('imn loopppp------'+objectName);
        
            options.add(new SelectOption('','---------- Select ----------'));
       system.debug('imn loopppp------'+options);
        if(objectName == 'bookRequest' || objectName == 'contact' ) {
                for (EmailTemplate t : [Select id,Name From EmailTemplate order by Name limit 100]){//where Folder.Name = :'SR_Template_Folder' 
                    options.add(new SelectOption(t.Id,t.Name)); 
                              system.debug('imn loopppp------'+t);system.debug('imn loopppp------'+options);
              }
        }else {   
            /*if( userInboxList!= null && !userInboxList.isEmpty() ) {
                for( String inboxName : userInboxList ) {
                    //if( inboxSettingMap.containsKey(inboxName) ) {
                        String tempName = '';  //Need to add template name
                        //inboxSettingMap.get(inboxName).Email_Templete_Name__c;
                        String tempId = '';
                        if(templateIdMap != null && templateIdMap.containsKey(tempName))
                            tempId = templateIdMap.get(tempName);
                        options.add(new SelectOption(tempId,tempName));
                    //}
                }
            }*/
        }
        return options;
    }
   
    public static PropStrength__Email__c upsertEmail( PropStrength__Email__c composedEmail, String objectName,String objectId, String OrignalEmailBody, String selectedFromAddress, String ccAddress, String bccAddress, String selectedTemplate, String subject,String toAddress,String addToAddress,String action,Map<String,String> objIdsMap ) {
        composedEmail.PropStrength__From_Name__c = Userinfo.getName();
           
        composedEmail.PropStrength__From_Address__c = selectedFromAddress;
        composedEmail.PropStrength__Message_Date__c = System.now();
        composedEmail.PropStrength__Subject__c = subject;
        composedEmail.PropStrength__To_Address__c = toAddress;
        
       
        if(ccAddress != null) {
            ccAddress = ccAddress.replaceAll(',' , ' , ');
            composedEmail.PropStrength__CC_Address__c = ccAddress;
        }
        if(bccAddress != null) {
            bccAddress = bccAddress.replaceAll(',' , ' , ');
            composedEmail.PropStrength__BCC_Address__c = bccAddress;
        }
      
        if( addToAddress != null && addToAddress != '' ) {
            addToAddress = addToAddress.replaceAll(',' , ' , ');
            composedEmail.PropStrength__To_Address__c = composedEmail.PropStrength__To_Address__c+' , '+addToAddress;
        }
        composedEmail.PropStrength__TemplateId__c = selectedTemplate;
        if( (action == 'reply' || action == 'replytoall')&&( objectName != 'bookRequest' && objectName != 'contact') ) {
            if( objIdsMap.size() > 0 ) {
                for( String str : objIdsMap.keySet() ) {
                    if( str == 'bookRequest' ) {
                        composedEmail.PropStrength__Service_Request__c = objIdsMap.get('bookRequest');
                    }
                   
                    if( str == 'contact' ) {
                        composedEmail.PropStrength__Assign_To__c = objIdsMap.get('contact');
                    }
                }
            }
        } else {
            if(objectName == 'bookRequest')
                composedEmail.PropStrength__Service_Request__c = objectId;
            
            else if(objectName == 'contact' || objectName == 'contacts')
                composedEmail.PropStrength__Assign_To__c = objectId;
        } 
       
        System.debug('********composedEmail*********' +composedEmail);
        return composedEmail;
    }
   
    public static Attachment upsertBodyAttachment(Attachment bodyAttachmentObj , String composedEmailBody, String composedEmailId, String composedEmailName) {
        system.debug('******composedEmailNamechkin*******'+composedEmailName);
        system.debug('******composedEmailBody*******'+composedEmailBody);
        if(bodyAttachmentObj.id == null) {
            bodyAttachmentObj.parentId = composedEmailId;
            bodyAttachmentObj.Name = composedEmailName+'.html';
            bodyAttachmentObj.ContentType = '.html';
        }
        bodyAttachmentObj.Body = Blob.valueOf(composedEmailBody);
        return bodyAttachmentObj;
    }  
       
    public static Set<id> getAttachmentNames ( PropStrength__Email__c orignalEmailObj,String action ) {
        Set<id> attachmentIdToReturn;
        if(action == 'forward') {
            String emailName = orignalEmailObj.Name+'.html';
            attachmentIdToReturn = new Map<id,Attachment>( [Select id ,Name From Attachment where ParentId = :orignalEmailObj.id AND Name!= :emailName] ).keySet();
        }
        /*
        system.debug('********composedEmailchk**********'+composedEmail);
        if( composedEmail.Name != null && composedEmail.Name != '' && composedEmail.id != null ) {
            String emailName = composedEmail.Name+'.html';
            for( Attachment attach : [Select parentId,id,Name,BodyLength from Attachment where ParentId = :composedEmail.id AND Name!= :emailName]) {
                attachmentToReturn.add(attach);
            }
        }
        */
        system.debug('********attachmentToReturn**********'+attachmentIdToReturn );
        if(attachmentIdToReturn!=null && !attachmentIdToReturn.isEmpty() )
            return attachmentIdToReturn ;
        else   
            return new Set<id>();
    }
    
    
    public static String substitute(String emailBody, String contactId, String objectId) {    
       system.debug('-------------------in method----------------'+objectId);
        List<string> objectsName = new List<string>();      
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();  
        Map<String, String> fieldsValues = new Map<String,String>{};
        objectsName = new List<String>{'Case', 'Account', 'Contact'}; 
        Set<string> Idset = new Set<string>();
        Idset.add(contactId); Idset.add(objectId); Idset.add(UserInfo.getUserId());    
        
        for(String objName : objectsName) { 
            system.debug('objName--------'+objName);  
            Schema.SObjectType obj = gd.get(objName);
            System.debug('-----find obj value -----'+obj);
            String objFields = '';
            Map<String, Schema.SObjectField> M  = obj.getDescribe().fields.getMap();            
            system.debug('M.keyset()==========='+M.keySet());
            for(Schema.SObjectField field : M.values()){              
                String fieldname = field.getDescribe().getName();
                if(String.valueOf(field.getDescribe().getType())!='Address')
                    objFields += fieldname + ',';              
            }               
            System.debug('objFields:-----------' + objFields);   
            objFields = objFields.substring(0, objFields.lastIndexOf(',')); //trim last comma;
            System.debug('objFields: ' + objFields);  
            List<Sobject> relObj;           
            String qryString = 'SELECT ' + objFields + ' FROM ' + objName + ' WHERE id in : Idset limit 1 ' ; //(Id = '+'\''+contactId+'\' OR id= '+ '\''+ email.Service_request__c +'\')';           
            
            relObj = Database.query(qryString);    
            system.debug('relObj------'+relObj); 
            
            for(String s : M.keySet()) {
                system.debug('in for------------');
                try {                      
                    if (relObj!= null && relObj.size() > 0 && relObj[0].get(s) != null){
                        fieldsValues.put('{!' + objName + '.' + m.get(s).getDescribe().getName() + '}', String.valueOf(relObj[0].get(s)));
                        
                    } else {
                        fieldsValues.put('{!' + objName + '.' + m.get(s).getDescribe().getName() + '}', '');                         
                    }
                } catch(System.Exception e) {                      
                }
            }                
        } 
        system.debug('fieldsValues.keySet()-----'+fieldsValues.keySet());
        for(String s : fieldsValues.keySet()) {   
            if(emailBody != null && emailBody.contains(s)) {            
                emailBody = emailBody.replace(s, fieldsValues.get(s));
            }
            //else
                //emailBody = '';
        }      
       
        return emailBody;
        
    }
    

    
   
    public static Messaging.SingleEmailMessage createEmail(List<String> toMail,List<String> addToMail ,List<String> ccEmailIdList,
                        List<String> bccEmailIdList, String strSubject, String strMsgBody,List<Attachment> attachmentsBody,PropStrength__Email__c orignalEmailObject,String objectId,String objName,String action,String selectedFromAddress,String offerLetterChk) {
       system.debug('ID IN CREATRE METHOD******'+objectId);
       system.debug('NAME IN CREATRE METHOD******'+objName);
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<String> toAddressesToSend = new List<String>();
        toAddressesToSend.addAll(toMail);
        if( !addToMail.isEmpty() )
            toAddressesToSend.addAll(addToMail);
        semail.setToAddresses(toAddressesToSend);
       
        if(ccEmailIdList != null && ccEmailIdList.size()>0)
                semail.setCcAddresses(ccEmailIdList);
       
        if(bccEmailIdList != null && bccEmailIdList.size()>0) {
            semail.setBccAddresses(bccEmailIdList);
            //semail.setBccSender(false);
        }        
       
        semail.setSaveAsActivity(false);
        if(strSubject == null || strSubject == '') {
            strSubject = 'no subject';
        }
        semail.setSubject(strSubject);
        semail.setHTMLBody(strMsgBody);
        system.debug('----semail-----objName '+objName);
        if(objName != 'Contact' && objName != 'Contacts' && objName != 'contBroker'){
        system.debug('ID *****'+objectId);
            semail.setWhatID(objectId);
            system.debug('----semail-----test______'+semail);
            }
        System.debug('&&&&selectedFromAddress&&&&&&'+selectedFromAddress);
        if(selectedFromAddress != userinfo.getUserEmail()){  
                 List<OrgWideEmailAddress> owd = [Select id from OrgWideEmailAddress Where Address =: selectedFromAddress Limit 1];  // Limit 1 swati 
                 if(!owd.isEmpty())
                     seMail.setOrgWideEmailAddressId(owd[0].id); 
                     System.debug('&&&&&&&&&&');
        }
       
        semail.setReplyTo(selectedFromAddress);
       
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa;
        if( !attachmentsBody.isEmpty() ) {
            for(Attachment attach : attachmentsBody) {
                efa = new Messaging.Emailfileattachment();
                efa.setFileName(attach.Name);
                efa.setBody(attach.body);
                fileAttachments.add(efa);          
            }
        }
        if(action == 'New') {
            
             if(objname == 'bookRequest' || objname == 'contact' ) {
                semail.setReferences('<MyForceApp.' +objectId+  '@customdomain.my.salesforce.com>');
            }  
        }else if(orignalEmailObject.PropStrength__Message_ID__c!= null)
            semail.setInReplyTo(orignalEmailObject.PropStrength__Message_ID__c);
           
        if(fileAttachments.size() > 0)
            semail.setFileAttachments(fileAttachments);
        return semail;                  
    }
}