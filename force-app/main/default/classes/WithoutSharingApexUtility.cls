public without sharing class WithoutSharingApexUtility {
    Public static void updateRecord(List<Business_Process_Step__c> objBPS){
        if(objBPS!=null && objBPS.size()>0 ){
            update objBPS;
        }
    }
}