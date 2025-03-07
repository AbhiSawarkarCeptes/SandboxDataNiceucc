/* Bypass Framework Enabled */
trigger trgFile on ContentVersion (after insert) {

Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
	
    Set<Id> contentDocumentIdSet = new Set<Id>();
    Set<Id> bookingIdSet = new Set<Id>();
    List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
    List<Booking__c> bookingList = new List<Booking__c>();

// To update Is_Booking_Form_Attached__c on Booking
    if(Trigger.IsInsert) {
        if(Trigger.isAfter) {     
            for(ContentVersion a: trigger.new){
                contentDocumentIdSet.add(a.ContentDocumentId);	
            }   
        }
        
        if(contentDocumentIdSet != null && !contentDocumentIdSet.isEmpty() && contentDocumentIdSet.size() > 0)
        	cdl = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.title FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIdSet];                   
        
        if(!cdl.isEmpty() && cdl != null && cdl.size() > 0){
            for(ContentDocumentLink cd: cdl){
                if(cd.LinkedEntityId != null){
                    String parentName = cd.LinkedEntityId.getSObjectType().getDescribe().getName();
                    system.debug('object name::: ' + parentName);
                    if(parentName.equalsIgnoreCase('Booking__c') && cd.ContentDocument.title.containsIgnoreCase('Booking Form')){
                        bookingIdSet.add(cd.LinkedEntityId);    
                    }                       
                }                
            }
            
            if(bookingIdSet != null && !bookingIdSet.isEmpty() && bookingIdSet.size() > 0) {
                bookingList = [SELECT Id, Is_Booking_Form_Attached__c FROM Booking__c WHERE ID IN :bookingIdSet]; 
                system.debug('Booking list::: ' + bookingList.size());
            }
            
            if(!bookingList.isEmpty() && bookingList.size() > 0){
                for(Booking__c b : bookingList){
                    b.Is_Booking_Form_Attached__c = true;
                    system.debug('booking checkbox is made true:::'+ b.Id);
                }
            }
            
            if(!bookingList.isEmpty() && bookingList.size() > 0)
                update bookingList;
        }
    }
}