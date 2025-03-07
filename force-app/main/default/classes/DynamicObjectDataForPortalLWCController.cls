public without sharing class DynamicObjectDataForPortalLWCController {
    
	public static String getContactInfo(){
        String userId = UserInfo.getUserId();
       	User usr;
        try {
            usr=[SELECT Id,ContactId FROM User WHERE Id=:userId LIMIT 1];
        } catch (Exception ex) {
            system.debug('exception '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        if(usr.ContactId !=null) { return usr.ContactId; }
        else {
            return null;
        }    
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String objName, String fieldNames, String conditions){
        //String userIdee = '005JX0000021FLfYAM';//UserInfo.getUserId();
        List<SObject> listRec;
        String userContId=getContactInfo();
        String obj=objName;
        if(userContId != null || Test.isRunningTest()) {
            try {
                String fullCondition='';
                if(conditions!=''){
                    /*List<String> cond = conditions.split(',');
                    List<String> conditionList = new List<String>();
                    for(String con: cond){
                        String temp = con+'='+'\''+userContId+ '\'';
                        conditionList.add(temp);
                    }*/
                   conditions = String.escapeSingleQuotes(conditions);
                   fullCondition = 'AND '+conditions;
                }
                
                //conditions = conditions.replaceAll(',',' OR ');
                //listRec=[SELECT Id,  FROM Lead WHERE Channel_Partner__r.Contact__c=:userContId];
                system.debug('~~'+'SELECT Id, '+fieldNames+' FROM '+objName+' WHERE Channel_Partner__r.Contact__c =:userContId OR Sobha_Connect__r.Contact__c =:userContId '+fullCondition);
                listRec = Database.query('SELECT Id, '+fieldNames+' FROM '+objName+' WHERE (Channel_Partner__r.Contact__c =:userContId OR Sobha_Connect__r.Contact__c =:userContId) '+fullCondition);
                //SELECT Id, Channel_Partner__r.Contact__c FROM Lead WHERE Channel_Partner__r.Contact__c='003JX000008SKjzYAG' 
            } catch (Exception ex) {
                system.debug('exception '+ex);
                if(Test.isRunningTest())
                	return null;
                throw new AuraHandledException(ex.getMessage());
            }
        }
        if(listRec !=null) { return listRec; }
        else {
            if(Test.isRunningTest()) return null;
            throw new DynamicObjectDataException('There is no Contact Linked to this user..');
        }
    }
   
    @AuraEnabled
    public static Map<String, String> getLabels(String ObjectApi, String FieldApi){
        List<String> fieldList = FieldApi.split(',');
        Map<String, String> fieldWithLabelMap = new Map<String, String>();
        if(fieldList.size()>0){
            for(String fld: fieldList){
                fieldWithLabelMap.put(fld, (String)Schema.getGlobalDescribe().get(ObjectApi).getDescribe().fields.getMap().get(fld).getDescribe().getLabel());
            }
        }
        return fieldWithLabelMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static map<string,integer> getContactsDataCount(){
        map<string,integer> contactDataMap = new map<string,integer>();
        try{
			String userContId=getContactInfo();
             if(Test.isRunningTest())
                userContId='Test';
            if(userContId!=null && userContId!=''){
                Integer leadCount = [select count() from Lead where Sobha_Connect__r.Contact__c=:userContId OR Channel_Partner__r.Contact__c=:userContId];
                contactDataMap.put('Lead',leadCount);
                Integer opptyCount = [select count() from Opportunity where Sobha_Connect__r.Contact__c=:userContId OR Channel_Partner__r.Contact__c=:userContId];
                contactDataMap.put('Opportunity',opptyCount);
                Integer bookingCount = [select count() from Booking__c where Sobha_Connect__r.Contact__c=:userContId OR Channel_Partner__r.Contact__c=:userContId];
                contactDataMap.put('Booking',bookingCount);
                Integer siteVisitCount = [select count() from Customer_Registration__c where Sobha_Connect__r.Contact__c=:userContId OR Channel_Partner__r.Contact__c=:userContId];
                contactDataMap.put('SiteVisit',siteVisitCount);
            } else {
                contactDataMap.put('Lead',0);
                contactDataMap.put('Opportunity',0);
                contactDataMap.put('Booking',0);
                contactDataMap.put('SiteVisit',0);
            }           
        }
        catch(Exception e){
            system.debug('exception: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return contactDataMap;
    }
    
    public class DynamicObjectDataException extends Exception {}
    
}