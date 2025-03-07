public class generateMadateLetterController { 
    @InvocableMethod(label = 'sendpolicyLetter')
    public static void sendpolicyLetter(List<Id> lstId){
        List<String> EmailIds = New List<String>();
        map<Id, Blob> pdfMap = new map<Id, Blob>();
        map<Id, String> emailMap = new map<Id, String>();
        Id docId = Label.Sobha_Realty_Circular_document;
        List<ContentVersion> cvList = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :docId AND IsLatest = true];
        Blob fileData;
        if(!test.isRunningTest())
        {
          fileData = cvList[0].VersionData; // <= This step converts the version data into a blob for the attachment  
        }
        else
        {
            fileData = blob.valueOf('Test Content');
        }
        system.debug('i am id:'+lstId);
        for(Channel_Partner__c ch : [Select Email_ID_1__c  from Channel_Partner__c where Id in :lstId])
        {
           PageReference ref = page.generateMadateLetter;
        	ref.getParameters().put('Id',ch.Id); 
        	ref.setRedirect(true);
        	Blob b;
            if(!test.isRunningTest())
            	{
                b=ref.getContentAsPDF();
            	}
            else
                {
                b = blob.valueOf('Test');
            	}
          pdfMap.put(ch.Id, b);
          emailMap.put(ch.Id, ch.Email_ID_1__c);
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'channeloperations@sobharealty.com'];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		for(Id ids : pdfMap.keySet())
        {
           String body =  'Dear Channel Partner' + ',<br/><br/>' +                        
                'Greetings from Sobha Realty! ' +'<br/><br/>'+
                'Please find attached Important Notices for your reference.<br/><br/>'+
                'Best Regards, <br/>'+
                '<b>Channel Operations</b> <br/>';
				//'SOBHA REALTY'; 
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
          efa1.setFileName('Exclusivity Policy - Important Notice.pdf');
          efa1.setBody(pdfMap.get(ids));
          Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
          if(!test.isRunningTest())
          {
             efa2.setFilename('Sobha Realty Circular.'+ cvList[0].FileExtension); 
          }
          else
          {
             efa2.setFilename('Sobha Realty Circular.pdf');   
          }
		  efa2.setBody(fileData);
          email.setSubject('Important Notice');
          email.setToAddresses(new List<String>{emailMap.get(ids)});
          email.setCcAddresses(new List<String>{Label.SF_Notifications});
          email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
          email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1,efa2});
          if ( owea.size() > 0 ) {
    		email.setOrgWideEmailAddressId(owea.get(0).Id);
		  }
          emailsToSend.add(email);
        }  
        if(!emailsToSend.isEmpty())
           {
             List<Messaging.SendEmailResult> allEmailResult = Messaging.sendEmail(emailsToSend);  
           }
    }
}