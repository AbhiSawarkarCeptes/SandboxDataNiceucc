public class MallStandController {
    
    @AuraEnabled
    public static string updateLocation(string invoiceFieldJSON){
        Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(invoiceFieldJSON); 
        list<Mall_Stand_Roaster__c> locations = [select Id 
                                                 from Mall_Stand_Roaster__c
                                                 where 
                                                 Promoter_Name__c =: UserInfo.getUserId() and 
                                                 Start_Date__c =: system.today() and
                                                 End_Date__c  =: system.today()];
        if(locations.size()>0){
            return 'Location already captured.';
        }
        else{
            Mall_Stand_Roaster__c location = new Mall_Stand_Roaster__c();
            location.Promoter_Name__c = UserInfo.getUserId();
            location.Start_Date__c = system.today();
            location.End_Date__c = system.today();
            location.Mall_Name__c = String.valueOf(fieldMap.get('Mall_Name__c'));
            insert location;
            return 'success';
        }
    }
    
    @AuraEnabled
    public static boolean validateIfLocationUpdated(){
        list<Mall_Stand_Roaster__c> locations = [select Id 
                                                 from Mall_Stand_Roaster__c
                                                 where 
                                                 Promoter_Name__c =: UserInfo.getUserId() and 
                                                 Start_Date__c =: system.today() and
                                                 End_Date__c  =: system.today()];
        if(locations.size()>0){
            return true;
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled(cacheable= true)  
    public static Id fetchSalesManagerId(String salesMgrName){             
        List<User> usrId = [select id from user where name = :salesMgrName];
        system.debug('debugguserid' + usrId[0].id);
        return usrId[0].id;
        
    }  
}