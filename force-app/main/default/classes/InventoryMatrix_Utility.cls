public without sharing class InventoryMatrix_Utility {

    Public static list<payment_request__c> getPrs(id unitId){
        return [select id,ownerId from payment_request__c where status__c = 'Approved' and Unit__c = :unitId order by createdDate Desc limit 1];
    }
    
    public static string getUnitAllocatedSM(id unitId){
        list<Unit__c> unit = [select Id, Allocated_SM__c from Unit__c where Id=: unitId];
        if(unit.size()>0 && unit[0].Allocated_SM__c != null){
            return String.valueOf(unit[0].Allocated_SM__c);
        }
        else{
            return '';
        }
    }
        
}