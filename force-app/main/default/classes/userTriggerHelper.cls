public class userTriggerHelper {
   /* public static void sendToMobile(List<User> newList,map<Id,User> oldMap) {
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.User_trigger__c;
        set<Id> userIds = new Set<Id>();
        if(trgFlg) {
            for(User pr : newList) {
                if(trigger.isInsert) {
                    if((pr.LastName != null ||
                        pr.FirstName != null ||
                        pr.Email != null ||
                        pr.MobilePhone != null) && 
                       pr.IsActive) {
                           userIds.add(pr.Id);
                    }
                } else if(trigger.isUpdate) {
                    if((pr.LastName != oldMap.get(pr.Id).LastName ||
                        pr.FirstName != oldMap.get(pr.Id).FirstName ||
                        pr.Email != oldMap.get(pr.Id).Email ||
                        pr.MobilePhone != oldMap.get(pr.Id).MobilePhone) &&
                       pr.IsActive) {
                           userIds.add(pr.Id);
                       }
                }
            }
            system.debug('userIds::'+userIds);
            if(!userIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                userTriggerHelper.sendToMobileAPIUser(userIds);
            }
        }
    }
*/
    public static void updateDeactivatedDate(List<User> newList,map<Id,User> oldMap) {
        for(User rec : newList) {
            if(rec.IsActive && !oldMap.get(rec.Id).IsActive) {
                rec.Deactivated_Date__c = null;
            }
            else if(!rec.IsActive && oldMap.get(rec.Id).IsActive) {
                rec.Deactivated_Date__c = System.now();
            }
        }
    }
    
    @future(callOut=true)
    Public static void sendToMobileAPIUser(set<Id> userIds) {
        List<User> userList = [SELECT Id,FirstName,LastName,Email,MobilePhone,Password__c
                               FROM User
                               WHERE Id IN: userIds AND
                               IsActive =: true];
        system.debug('userList::'+userList);
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        if(!userList.isEmpty()) {
            try {
                Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
                String endPointURL = mobile_appmdt.End_Point__c;
                String sftoken = mobile_appmdt.sf_Token__c;
                String Subscription_Key = mobile_appmdt.Subscription_Key__c;
                for(User u : userList) {
                    requestBodyWrapper wrap = new requestBodyWrapper();
                    wrap.firstName = (!String.isBlank(u.FirstName) ? u.FirstName : '');
                    wrap.lastName = (!String.isBlank(u.LastName) ? u.LastName : '');
                    wrap.email = (!String.isBlank(u.Email) ? u.Email : '');
                    wrap.mobile = (!String.isBlank(u.MobilePhone) ? u.MobilePhone : '');
                    wrap.password = 'G345345';//Password__c
                    wrap.source = 'salesForce';
                    wrap.dialCode = '971';
                    wraplst.add(wrap);
                }
                if(wraplst != null){
                    String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,'POST',JSON.serialize(wraplst[0]));
                    system.debug('response '+response);
                }
            } catch(Exception e){
                system.debug('~~~~~Error: '+e.getStackTraceString());
            }
        }
    }
    
    public class requestBodyWrapper{
        String firstName;
        String lastName;
        String email;
        String dialCode;
        String mobile;
        String source;
        String password;
    }
}