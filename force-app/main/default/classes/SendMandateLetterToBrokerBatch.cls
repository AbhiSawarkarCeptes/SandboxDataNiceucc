public class SendMandateLetterToBrokerBatch implements Database.Batchable<sObject>,Schedulable, Database.stateful {
    public string towerValue;
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select id ,dfsle__Status__c,Channel_Partner__r.Sent_To_Broker__c,Channel_Partner__c,Channel_Partner__r.name,Channel_Partner__r.Email_ID_1__c, Booking__c from dfsle__EnvelopeStatus__c  where dfsle__Status__c = \'Completed\' and  Channel_Partner__c != null and Booking__c = null and Channel_Partner__r.Sent_To_Broker__c = false';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<dfsle__EnvelopeStatus__c> docuSignList){
        
        Map<String,String> docuSignMap = new Map<String,String>();
        Map<String,String> channelPartnerFileMap = new Map<String,String>();
        Map<String,String> fileDocIdMap = new Map<String,String>();
        Map<String,Blob> fileDataMap = new Map<String,Blob>();
        
        List <String> lststringCCaddress = new List<String>(); 
        List<String> channelPartnerList = new list<String>();
        List<Channel_Partner__c> sentToBrokerList = new list<Channel_Partner__c>();
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        
        for(dfsle__EnvelopeStatus__c env :docuSignList ){
            channelPartnerList.add(env.Channel_Partner__c);
            if(!docuSignMap.containskey(env.Channel_Partner__c))docuSignMap.put(env.Channel_Partner__c,env.dfsle__Status__c);
        }
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntity.Name,ContentDocument.Title,ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId =:docuSignMap.keyset()  and ContentDocument.Title like '%Mandate%' order by ContentDocument.CreatedDate desc  ]){
            if(!channelPartnerFileMap.containskey(cdl.LinkedEntityId))channelPartnerFileMap.put(cdl.LinkedEntityId,cdl.ContentDocument.Title);           
            if(!fileDocIdMap.containskey(cdl.LinkedEntityId))fileDocIdMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
        }
        for(ContentVersion myFile : [SELECT id, VersionData,ContentDocumentId from ContentVersion where ContentDocumentId  in :fileDocIdMap.values()]){
            if(!fileDataMap.containskey(myFile.ContentDocumentId))fileDataMap.put(myFile.ContentDocumentId,myFile.VersionData);
        }
        
        for(dfsle__EnvelopeStatus__c env :docuSignList ){
            List <String> lststringtoaddress = new List<String>();
            String body =  'Dear '+env.Channel_Partner__r.name+' ,<br/><br/>'+
                'Please find attached the Approved Mandate Letter for your records.<br></br> '+ 
                'Happy Selling! <br></br>'+                                            
                'Thanks \n'+
                'Sobha Realty';
            
            lststringtoaddress.add(env.Channel_Partner__r.Email_ID_1__c);
            //lststringtoaddress.add(booking.Sales_Head__r.email);
            // lststringCCaddress.add('salesops@sobharealty.com');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName(channelPartnerFileMap.get(env.Channel_Partner__c));
            attach.setBody(fileDataMap.get(fileDocIdMap.get(env.Channel_Partner__c)));
            String sub = 'Mandate Letter - Sobha Realty - '+ env.Channel_Partner__r.name; 
            email.setSubject(sub);
            email.setToAddresses(lststringtoaddress);
            //email.setCcAddresses(lststringCCaddress);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
            mailsList.add(email);
        }
        system.debug('mailsList'+ mailsList);
        Messaging.sendEmail(mailsList); 
        
         for(Channel_Partner__c env :[select id,Sent_To_Broker__c from Channel_Partner__c where id in :channelPartnerList] ){
             env.Sent_To_Broker__c = true;
             sentToBrokerList.add(env);
         }
        if(sentToBrokerList != null && sentToBrokerList.size() > 0){update sentToBrokerList;}
        
        
    }
    public void finish(Database.BatchableContext BC) {}

    public void execute( SchedulableContext sc ) {
        database.executebatch(this);
    }

    public static void scheduleThisEveryday(string cronExp)  {    
        SendMandateLetterToBrokerBatch oppBatch = new SendMandateLetterToBrokerBatch();
        system.schedule('SendMandateLetterToBrokerJob', cronExp, oppBatch);
    }
}