public  class RequestUnitHoldController {
    @AuraEnabled
    public static void saveAttachements(String recordId, List<Id> contentDocIds){
       System.debug('Save Attachement Method is called');
       
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentDocument> cdList = new List<ContentDocument>();
        for(Id docId : contentDocIds){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.linkedEntityId = recordId;
            cdl.contentDocumentID = docId;
            cdlList.add(cdl);
        }
        insert cdlList;
    }    
    @AuraEnabled
    public static String validateUnitAvailablity(String unitId){
        try {
             List<Payment_Request__c> prList = [SELECT ID FROM Payment_Request__c
                                            WHERE ((Mode__c != 'Website')
                                            OR (Mode__c ='Website' AND Payment_Request_Wrapper__r.Payment_Link_Expiry__c >: System.now()))
                                            AND unit__c =: unitId
                                            AND (Not (Status__c Like '%Rejected%'))
                                            AND Status__c != 'PR was Approved- Booking is cancelled'
                                            ];
            
            if(prList.size() > 0) {
                return 'This request cannot be submitted as PR has been already submitted for this unit';
            }
            
            List<Unit__c> unitList = [SELECT Id, name,Unit_Status__c, Allocated_SM__c from Unit__c WHERE Id = :unitId];
            if(unitList.size() > 0) {
                Unit__c thisUnit = unitList[0];
                if(thisUnit.Allocated_SM__c != null || thisUnit.Unit_Status__c == 'Hold') {
                    return 'Cannot process Unit Hold request, as Unit is not Available';
                }
            }

            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}