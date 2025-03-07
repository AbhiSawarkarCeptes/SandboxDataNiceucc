global class SREmailServices implements Messaging.InboundEmailHandler {
    public map<string,id> oweidmap;
    Public List<PropStrength__Projects__c> projLst;
    public Boolean createReq = False;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String fromAddress = email.fromAddress;
        Set<string> appCodeMatcher = new Set<string>();
        Set<string> codeInBodySet = new Set<string>();
        String replySbuject = '';
        
        if(email.subject != null && email.subject != ''){
            replySbuject = email.subject; 
        }  
        
        if(replySbuject.contains('Re:')) {
            replySbuject = replySbuject.remove('Re:');
        }
        
        String str = String.valueOf(email.plainTextBody);  
        system.debug('========str1======'+str);
        
        if(str != null && str.contains('\n')){
            str = str.replace('\n',''); 
        }
        system.debug('========str2======'+str);
        
        String toaddr = '';
        String ccaddr = '';
                    
        if(email.toAddresses!= null && email.toAddresses.size() > 0){
            for(string toaddress : email.toAddresses){
                toaddr += toaddress +',';
            }
            toaddr = toaddr.removeEnd(',');
        }
        
        if(email.ccAddresses != null && email.ccAddresses.size() > 0){
            for(string ccaddress : email.ccAddresses){
                ccaddr += ccaddress +',';
            }
            ccaddr = ccaddr.removeEnd(',');
        } 
        
        PropStrength__Service_Request__c srObj= new PropStrength__Service_Request__c();
        String ids;
        List<PropStrength__Service_Request__c> exitSrLst= new list<PropStrength__Service_Request__c>();
          
        List<Contact> Clist = New List<contact>();
        if(fromAddress != null && fromAddress !='') {
            srObj.PropStrength__Contact_Email__c = fromAddress;
            Clist = [Select id,Email,MobilePhone,AccountId, (SELECT Id FROM PropStrength__Applications_Bookings__r WHERE PropStrength__Active__c = TRUE ORDER By CreatedDate DESC) from Contact WHERE Email=: fromAddress];
        }
           
        PropStrength__Application_Booking__c app = new PropStrength__Application_Booking__c();
             
        if(fromAddress != null && fromAddress !='' && Clist.isEmpty()) {
            Contact cont = new Contact(Email=fromAddress, LastName=fromAddress.substring(0,fromAddress.indexOf('@')));
            insert cont;
            
            srObj.Contact__c = cont.Id;
        }
          
        if(Clist.isEmpty() == False && Clist[0].PropStrength__Applications_Bookings__r.size() == 1){
            app = Clist[0].PropStrength__Applications_Bookings__r[0];
            srObj.Contact__c = Clist[0].Id;
            srObj.PropStrength__Contact_Mobile__c =  Clist[0].MobilePhone !=null ? Clist[0].MobilePhone : ''; 
        }
        
        System.debug('srobj.PropStrength__Subject__c-----'+srobj.PropStrength__Subject__c);
        System.debug(toaddr);
        srObj.PropStrength__Status__c  = 'Not Started';                
        srObj.PropStrength__MessageId__c=  email.messageId != null ? email.messageId : '';                                           
        srobj.PropStrength__Subject__c = replySbuject != null ? replySbuject :'';  
        srObj.PropStrength__Description__c = replySbuject;           
        srObj.PropStrength__Origin__c = 'Email';
        srObj.PropStrength__Priority__c = 'Medium';
        srObj.PropStrength__Request_Origin__c= 'Email';
        srObj.PropStrength__Email_Address__c= email.fromAddress; 
        srObj.To_Email_Address__c = toaddr != null ? toaddr : ''; 
        if(!Clist.isEmpty()) {
        srObj.Contact__c = Clist[0].Id;
        }
        
        if(app != null && app.Id != null){
            srObj.PropStrength__Application_Booking__c = app.Id;
        }
        
        List<Account> AList = new List<Account>(); 
        if(!Clist.isEmpty())
              AList=[Select Id From Account WHERE Id =:CliSt[0].AccountId];
        
        if(!Alist.isEmpty())
            srObj.PropStrength__Account__c =  Alist[0].Id !=null ? Alist[0].Id : '';
            
        String strTest = string.valueOf(email.Subject);
        String g = '';
        List <String> arrTest = new List<string>() ;
        arrTest = strTest.split(':');
        for(string s : arrTest){
            g = s.trim();   
        }
        g.trim();
        system.debug('0####0'+g);
        
        String correctSub = '';
        if(replySbuject.contains(':')) {
            List<String> strlst = replySbuject.split(':');
            if(strlst.size()>1)
                correctSub = strlst[1].trim();
        } else {
            correctSub = replySbuject;
        }
        System.debug('+++correctSub'+correctSub);
        
        exitSrLst =[Select Id,name,PropStrength__Subject__c, PropStrength__Status__c, SR_Closed_Date__c From PropStrength__Service_Request__c where PropStrength__Email_Address__c= :fromAddress OR To_Email_Address__c =: toaddr ];
        ids = '';
        
        for(PropStrength__Service_Request__c obj:exitSrLst) { 
            correctSub = correctSub.trim();
            if(obj.PropStrength__Subject__c !='' && obj.PropStrength__Subject__c != null && obj.PropStrength__Subject__c.contains(correctSub)){
                if(obj.PropStrength__Status__c=='Closed' && obj.SR_Closed_Date__c.date().daysBetween(System.Today()) < 7) {
                    ids= obj.id;
                }
            }
        }
        if(ids=='')
            insert srObj;
             
        PropStrength__Email__c emailobj = new PropStrength__Email__c();
        List<PropStrength__Service_Request__c> servRequestObj =new List<PropStrength__Service_Request__c>([SELECT id,PropStrength__Customer__c,PropStrength__Contact__c,PropStrength__Re_Opened_Case__c,PropStrength__Status__c,PropStrength__Assigned_To__c, SR_Closed_Date__c from PropStrength__Service_Request__c 
                                                            WHERE id =: srObj.Id OR id =:ids]); 
        
        if(servRequestObj.size() > 0) {
            emailobj.PropStrength__To_Address__c = toaddr != null ? toaddr : '';
            emailobj.PropStrength__cc_Address__c = ccaddr != null ? ccaddr : '';
            emailobj.PropStrength__From_Address__c = email.fromAddress != null ? email.fromAddress : '';
            emailobj.PropStrength__From_Name__c = email.fromname != null ? email.fromname : '';
            emailobj.PropStrength__Email_Reference__c = email.references != null ? String.ValueOf(email.references) : null;
            if((email.binaryAttachments != null && email.binaryAttachments.size() > 0) || (email.textAttachments != null && email.textAttachments.size() > 0)) {
                emailobj.PropStrength__Has_Attachment__c= true;
            }
            emailobj.PropStrength__Incoming__c = true; 
            emailobj.PropStrength__Message_Date__c = system.now();
            emailobj.PropStrength__Subject__c = replySbuject != null ? replySbuject : '';        
            emailobj.PropStrength__Status__c = 'New'; 
            emailobj.PropStrength__Service_Request__c = servRequestObj[0].id;
            emailobj.PropStrength__Message_ID__c = email.messageId != null ? email.messageId : '';
            emailobj.PropStrength__In_Reply_To__c = email.inReplyTo != null ? email.inReplyTo : '';
            system.debug('******messageId *********' +email.messageId);
            
            if(servRequestObj[0].PropStrength__Contact__c!= null)
                emailobj.PropStrength__Contact__c = servRequestObj[0].PropStrength__Contact__c; 
            
            insert emailobj;
            
            if(servRequestObj.size()>0 && servRequestObj[0].PropStrength__Status__c=='Closed' && servRequestObj[0].SR_Closed_Date__c.date().daysBetween(System.Today()) < 7){
                servRequestObj[0].PropStrength__Status__c = 'Reopened';
                servRequestObj[0].PropStrength__Re_Opened_Case__c =true;
                update servRequestObj[0];
            }
        }
        
        emailobj= [select Id,Name, CreatedDate from PropStrength__Email__c where id = :emailobj.id];
        
        List<Attachment> attList = new List<Attachment>();
        
        if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){
            for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                
                Attachment attachment = new Attachment();
                attachment.ParentId = emailobj.Id;
                attachment.Name = email.binaryAttachments[i].filename;
                attachment.Body = email.binaryAttachments[i].body;
                attList.add(attachment);
            }
        }
        
        String tempbody = '';
        if(email.htmlBody != null) {
            tempbody = email.htmlBody;
        } else if (email.plainTextBody != null) {
            tempbody = email.plainTextBody;
        }
        
        system.debug('tempbody--------'+tempbody);
        system.debug('email.htmlBody--------'+email.htmlBody);
        system.debug('email.plainTextBody--------'+email.plainTextBody);
        
        String emailBody = tempbody;
        if( tempbody!= null && tempbody.contains('<img') ) 
            emailBody = tempbody.replaceAll('<img(.*?)>', '');
        
        Attachment attach = new Attachment(Name = emailobj.Name + '.html', Body = Blob.valueOf(emailBody), ContentType = '.html', ParentId = emailobj.id);  
        insert attach;
        
        if(email.textAttachments != null && email.textAttachments.size() > 0) {
            for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                system.debug('attachment.Body--------'+attachment.Body);
                attachment.ParentId = emailobj.Id;
                attList.add(attachment);
            }  
        } 
        system.debug('attachmenttest:'+attList);
        
        if(!attList.isEmpty()) {
            List<Database.SaveResult> insertAttList = Database.insert(attList, false);
            system.debug('insertAttList:' + insertAttList);
        }
       
       return result;
    }
    
    
    public Messaging.SingleEmailMessage sendEmail(List<String> toMail, String strSubject, String strMsgBody ,String selectedemailid) {
        oweidmap = new map<string,id> ();
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        
        for(OrgWideEmailAddress owe : [SELECT Address,DisplayName,Id FROM OrgWideEmailAddress]) {
            oweidmap.put(owe.Address,owe.id);
        }
        
        if(selectedemailid != userinfo.getUserEmail()) {
            seMail.setOrgWideEmailAddressId(oweidmap.get(selectedemailid));    
        }
        
        if(strSubject == null || strSubject == '') {
            strSubject = 'no subject';
        }
        System.debug('***********semail***********'+semail);
        
        semail.setToAddresses(toMail);
        semail.setSubject(strSubject);
        semail.setHTMLBody(strMsgBody);    
        
        Messaging.SendEmailResult[] sendResult;                  
        return semail;
    }
}