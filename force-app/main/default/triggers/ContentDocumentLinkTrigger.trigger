trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,before Insert) {
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        for(ContentDocumentLink cdl : trigger.new){
            if(cdl.LinkedEntityId!=null && (
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Booking__c' || 
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'BR_Document_History__c' || 
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Broker_Registration__c' ||
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Announcements__c'||
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Document_validator__c'
            ))
            {  
                cdl.Visibility = 'AllUsers' ;
                cdl.ShareType = 'V';
            }
        } 
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        //ContentDocumentLinkTriggerHelper.createContentDistribution(Trigger.new);
        brokerRegistrationTrghandler.updateStatusAfterDocUpload(Trigger.new);
        try{
            map<string,string> contentDocIdToRelatedRecordId = new map<string,string>();
            map<string,string> contentDocIdToContentVersionId = new map<string,string>();
            for(ContentDocumentLink cdl : trigger.new){
                if(cdl.ContentDocumentId!=null && cdl.LinkedEntityId!=null){
                    Id sObjectId =  cdl.LinkedEntityId;
                    String sObjName = sObjectId.getSObjectType().getDescribe().getName();
                    if(sObjName == 'Sobha_Event__c' || sObjName == 'Cluster__c' || sObjName == 'Events__c' || sObjName == 'BR_Document_History__c'|| sObjName == 'Announcements__c' || sObjName =='Portal_Images__c'|| sObjName == 'Document_validator__c')
                        contentDocIdToRelatedRecordId.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
                }
            }
            if(contentDocIdToRelatedRecordId.size()>0){
                for(ContentVersion cv : [SELECT Id,ContentDocumentId from ContentVersion where ContentDocumentId IN: contentDocIdToRelatedRecordId.keySet()]){
                    contentDocIdToContentVersionId.put(cv.ContentDocumentId,cv.Id);
                }
                if(contentDocIdToContentVersionId.size()>0){
                    list<ContentDistribution> contentDistributionListToInsert = new list<ContentDistribution>();
                    for(string contentDocId : contentDocIdToContentVersionId.keySet()){
                        ContentDistribution cd = new ContentDistribution(Name='PublicShare');
                        cd.RelatedRecordId=contentDocIdToRelatedRecordId.get(contentDocId);
                        cd.ContentVersionId=contentDocIdToContentVersionId.get(contentDocId);
                        contentDistributionListToInsert.add(cd);
                    }
                    if(contentDistributionListToInsert.size()>0){
                        try{
                            insert contentDistributionListToInsert;
                        }
                        catch(Exception e){
                        }
                    }
                }
            }
        }
        catch(Exception e){
        }
    }
}