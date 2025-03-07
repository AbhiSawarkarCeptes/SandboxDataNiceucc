public class SBTRTriggerHandler {
    public static Boolean hasFiredParentTrigger = false;
    
    public static void beforeUpdate(List<SBTR__c> newList, Map<Id,SBTR__c> oldMap) {
        Set<Id> collectionReportIds = new Set<Id>();
        for(SBTR__c sbtr : newList){
            if(sbtr.Declared_Date__c != null && (sbtr.Collection_10__c == 'No' || sbtr.Collection_10__c == null)){
                sbtr.Collection_10__c = 'Yes';
            }
            if(sbtr.Collection_Report__c != null && sbtr.Collection_Report__c != oldMap.get(sbtr.Id).Collection_Report__c){
                collectionReportIds.add(sbtr.Collection_Report__c);
            }
        }
        if(collectionReportIds.size()>0){
            populateDeclaredDateRelatedFields(newList,collectionReportIds);
        }
    }
    
    public static void beforeInsert(List<SBTR__c> newList) {
        Set<Id> collectionReportIds = new Set<Id>();
        for(SBTR__c sbtr : newList){
            if(sbtr.Declared_Date__c != null && (sbtr.Collection_10__c == 'No' || sbtr.Collection_10__c == null)){
                sbtr.Collection_10__c = 'Yes';
            }
            if(sbtr.Collection_Report__c != null){
                collectionReportIds.add(sbtr.Collection_Report__c);
            }
        }
        if(collectionReportIds.size()>0){
            populateDeclaredDateRelatedFields(newList,collectionReportIds);
        }
    }
    
    public static void afterUpdate(List<SBTR__c> newList) {
        SBTR__c LeadObject = new SBTR__c();
        Map<String, Schema.SObjectField> M = Schema.SObjectType.SBTR__c.fields.getMap();
        List<SBTR_Audit__c> listToInsert = new  List<SBTR_Audit__c>();
        listToInsert.addAll(getChangedFields(newList[0].Id ,M.VALUES())) ; 
        insert listToInsert;
    }

    public static void populateDeclaredDateRelatedFields(List<SBTR__c> newList, Set<Id> collectionReportIds){
        Map<Id,Boolean> collectionReportToCollected = new Map<Id,Boolean>();
        Map<Id,Collection_Report__c> crIdToRecord = new Map<Id,Collection_Report__c>();
        for(Collection_Report__c cr : [select Id,Total_Paid_Amount__c,Total_Amount__c,X10_As_Per_GL_Date__c from Collection_Report__c where Id IN : collectionReportIds]){
            if(cr.Total_Paid_Amount__c != null && cr.Total_Amount__c != null){
                Decimal percentageOfTotal = (cr.Total_Paid_Amount__c / cr.Total_Amount__c)*100;
                if(percentageOfTotal >= 9.7){
                    collectionReportToCollected.put(cr.Id,true);
                    crIdToRecord.put(cr.Id,cr);
                }
                else{
                    collectionReportToCollected.put(cr.Id,false);
                }
            }
        }
        for(SBTR__c sbtr : newList){
            if(sbtr.Collection_Report__c != null && collectionReportToCollected.conTainsKey(sbtr.Collection_Report__c)){
                if(collectionReportToCollected.get(sbtr.Collection_Report__c) == true){
                    if(sbtr.Declared_Date__c == null)
                        sbtr.Declared_Date__c = crIdToRecord.get(sbtr.Collection_Report__c).X10_As_Per_GL_Date__c;
                    sbtr.Payment_Date__c = crIdToRecord.get(sbtr.Collection_Report__c).X10_As_Per_GL_Date__c;
                    sbtr.Paid_Percentage_Gone_Down__c = null;
                    sbtr.Collection_10__c = 'Yes';
                }
            }
        }
    }

    public static List<SBTR_Audit__c> getChangedFields(ID recordId, Schema.sObjectField[] fieldList) {
        Schema.sObjectField[] changedFields = new list<Schema.sObjectField> ();
        SObject o1 = Trigger.oldMap.get(recordId);
        SObject o2 = Trigger.newMap.get(recordId);
        List<SBTR_Audit__c> auditLogList = new List<SBTR_Audit__c>();
        for (Schema.sObjectField field : fieldList) {
            Object v1 = o1.get(field);
            Object v2 = o2.get(field);
            if (didFieldChange(v1, v2) &&  string.valueof(field.getDescribe().getType()) != 'Formula' && field.getDescribe().getName() != 'LastModifiedDate' && field.getDescribe().getName() != 'LastModifiedById' && field.getDescribe().getName() != 'SystemModstamp') {
                SBTR_Audit__c auditLog = new SBTR_Audit__c();
                auditLog.Field_Name__c =field.getDescribe().getName();
                auditLog.New_Value__c = string.valueof(o2.get(field.getDescribe().getName()));
                auditLog.Old_Value__c = string.valueof(o1.get(field.getDescribe().getName()));
                auditLog.SBTR__c = recordId;
                auditLog.User__c = UserInfo.getUserId();
                auditLogList.add(auditLog);
            }
        }
        return auditLogList;
    }
    
    private static Boolean didFieldChange(Object v1, Object v2) {
        if (v1 == null && v2 == null) {
            return false;
        }
        if (v1 != v2) {
            return true;
        }
        return false;
    }
}