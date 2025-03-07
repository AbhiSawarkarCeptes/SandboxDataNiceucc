public  class RecordVisitVfController {
    Id currentRecord;
    public RecordVisitVfController(ApexPages.StandardController controller) {
        currentRecord = controller.getId();
    }
    public void onLoad(){
        String objectApiName = currentRecord.getSObjectType().getDescribe().getName();
        try{
            Record_Visit__c rv = new Record_Visit__c();
            rv.visit_time__c = System.now();
            rv.Record_Opened_by__c = userinfo.getuserId();
            if(!objectApiName.contains('__c')){
                objectApiName += '__c';
            }
            rv.put(objectApiName,currentRecord);
            insert rv;
        }catch(exception e){

        }
       
    }
}