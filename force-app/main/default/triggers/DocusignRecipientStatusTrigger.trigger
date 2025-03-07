trigger DocusignRecipientStatusTrigger on dfsle__RecipientStatus__c (after insert, after update) {
    
    List<Docusign_Recipient_Status_Sobha__c> drsSobhaList = new List< Docusign_Recipient_Status_Sobha__c >();
    Map<Id, dfsle__RecipientStatus__c> drsMap = new Map<Id, dfsle__RecipientStatus__c>();
    Map<Id, dfsle__RecipientStatus__c> docusignStatusToDSRMap = new Map<Id, dfsle__RecipientStatus__c>();
    for(dfsle__RecipientStatus__c drs : Trigger.new) {
        drsMap.put(drs.Id, drs);
        docusignStatusToDSRMap.put(drs.dfsle__EnvelopeStatus__c,drs);
    }
	map<string,Docusign_Recipient_Status_Sobha__c> keyToDRSSobhaMap = BookingFormDocusignUtil.getDocusignRecipientStatusSobhaByKey(docusignStatusToDSRMap.keySet());
    List<Docusign_Recipient_Status_Sobha__c> drsSobhaListToUpsert = new List< Docusign_Recipient_Status_Sobha__c >();
    system.debug('VVK docusignStatusToDSRMap: '+docusignStatusToDSRMap.keySet());
    for(dfsle__RecipientStatus__c drs : Trigger.new) {
        if(!keyToDRSSobhaMap.containsKey(drs.dfsle__EnvelopeStatus__c+'#'+drs.dfsle__Sequence__c+'#'+drs.dfsle__Email__c)
        ){
            system.debug('VVK Insert Case');
            //Create new records
            Docusign_Recipient_Status_Sobha__c drsSobha = new Docusign_Recipient_Status_Sobha__c();
            drsSobha.Booking__c = drs.Booking__c;
            drsSobha.Completed__c = drs.dfsle__Completed__c;
            drsSobha.Reason__c = drs.dfsle__Reason__c;
            drsSobha.DocuSignEnvelope__c = drs.dfsle__EnvelopeStatus__c;
            drsSobha.Name = drs.Name;
            drsSobha.Email__c = drs.dfsle__Email__c;
            if(drs.Envelope_Recipient_Type__c != null && drs.Envelope_Recipient_Type__c != '')
            	drsSobha.Envelope_Recipient_Type__c = drs.Envelope_Recipient_Type__c;
            if(drs.Envelope_Type__c != null && drs.Envelope_Type__c != '')
            	drsSobha.Envelope_Type__c = drs.Envelope_Type__c;
           drsSobha.Last_Applicant__c = drs.Last_Applicant__c;
            drsSobha.LastStatusUpdate__c = drs.dfsle__LastStatusUpdate__c;
            drsSobha.RoutingOrder__c = drs.dfsle__RoutingOrder__c;
            drsSobha.Source_ID__c = drs.dfsle__SourceId__c;
            drsSobha.Sent__c = drs.dfsle__Sent__c;
            drsSobha.Sequence__c = drs.dfsle__Sequence__c;
            drsSobha.Status__c = drs.dfsle__Status__c;
            drsSobha.Type__c = drs.dfsle__Type__c;
            drsSobha.Docusign_Broker_Registration__c = drs.Docusign_Broker_Registration__c;
          
            drsSobhaListToUpsert.add(drsSobha);
        } 
        else {
            system.debug('VVK Update Case');
            //Update existing records
            Docusign_Recipient_Status_Sobha__c drsSobha = keyToDRSSobhaMap.get(drs.dfsle__EnvelopeStatus__c+'#'+drs.dfsle__Sequence__c+'#'+drs.dfsle__Email__c);
            if(drs.Booking__c != null)
            	drsSobha.Booking__c = drs.Booking__c;
            drsSobha.Completed__c = drs.dfsle__Completed__c;
            drsSobha.Reason__c = drs.dfsle__Reason__c;
            //drsSobha.DocuSignEnvelope__c = drs.dfsle__EnvelopeStatus__c;
            drsSobha.Name = drs.Name;
            drsSobha.Email__c = drs.dfsle__Email__c;
            if(drs.Envelope_Recipient_Type__c != null && drs.Envelope_Recipient_Type__c != '')
            	drsSobha.Envelope_Recipient_Type__c = drs.Envelope_Recipient_Type__c;
            if(drs.Envelope_Type__c != null && drs.Envelope_Type__c != '')
            	drsSobha.Envelope_Type__c = drs.Envelope_Type__c;
            if(drs.Last_Applicant__c)
            	drsSobha.Last_Applicant__c = drs.Last_Applicant__c;
            drsSobha.LastStatusUpdate__c = drs.dfsle__LastStatusUpdate__c;
            drsSobha.RoutingOrder__c = drs.dfsle__RoutingOrder__c;
            drsSobha.Source_ID__c = drs.dfsle__SourceId__c;
            drsSobha.Sent__c = drs.dfsle__Sent__c;
            drsSobha.Sequence__c = drs.dfsle__Sequence__c;
            drsSobha.Status__c = drs.dfsle__Status__c;
            drsSobha.Type__c = drs.dfsle__Type__c;
            if(drs.Docusign_Broker_Registration__c != null)
            drsSobha.Docusign_Broker_Registration__c = drs.Docusign_Broker_Registration__c;
            system.debug('drsSobha----'+drsSobha);
            drsSobhaListToUpsert.add(drsSobha);
        }
    }
    if(drsSobhaListToUpsert.size()>0){
        Database.upsert(drsSobhaListToUpsert,false);
    }
}