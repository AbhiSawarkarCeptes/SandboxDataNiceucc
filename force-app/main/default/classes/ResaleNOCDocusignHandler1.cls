public class ResaleNOCDocusignHandler1 {
	@InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> resaleIds){
        Id mySourceId = resaleIds[0];
        List<String> nocExist = new List<String>();
        Resale_Process__c resale = [Select Id, Name, CRM_Document_Controller__c, CRM_Document_Controller__r.Name, CRM_Document_Controller__r.email, Booking__c, Booking__r.Unit__r.Name, Booking__r.Tower__c , Booking__r.Cluster__c, Unit__c, Unit__r.Name from  Resale_Process__c Where Id =:mySourceId order by createddate desc Limit 1];
        String docName = 'NOC for resale '+resale.Unit__r.Name+'%';
            for(ContentDocumentLink cdl :[SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE 
                                            LinkedEntityId =:mySourceId and ContentDocument.title like :docName Order by ContentDocument.createdDate desc Limit 1])
            {
            nocExist.add(cdl.ContentDocumentId);
        }
        return nocExist;
    }
}