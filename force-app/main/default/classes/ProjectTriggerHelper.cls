public class ProjectTriggerHelper {
    public static void sendToMobile(List<PropStrength__Projects__c> newList,map<Id,PropStrength__Projects__c> oldMap) {
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Project_Trigger__c;
        set<Id> projectIds = new Set<Id>();
        if(trgFlg || test.IsRunningtest()) {
            for(PropStrength__Projects__c pr : newList) {
                if(trigger.isInsert) {
                    if(pr.Name != null || pr.Master_Project__c != null || pr.Min_Area__c != null || pr.Max_Area__c != null || pr.PropStrength__Description__c != null) {
                           projectIds.add(pr.Id);
                       }
                } else if(trigger.isUpdate) {
                    if(pr.Name != oldMap.get(pr.Id).Name ||
                      pr.Master_Project__c != oldMap.get(pr.Id).Master_Project__c ||
                      pr.Min_Area__c != oldMap.get(pr.Id).Min_Area__c ||
                      pr.Max_Area__c != oldMap.get(pr.Id).Max_Area__c ||
                      pr.PropStrength__Description__c != oldMap.get(pr.Id).PropStrength__Description__c) {
                           projectIds.add(pr.Id);
                       }
                }
            }
            system.debug('projectIds::'+projectIds);
            if(!projectIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                ProjectTriggerHelper.sendToMobileAPI(projectIds);
            }
        }
    }
    
    public static void convertRichTextToText(List<PropStrength__Projects__c> newList, map<Id,PropStrength__Projects__c> oldMap) {
        
        for(PropStrength__Projects__c pr : newList) {
         if(pr.Booking_Form_T_C__c != null) {
                pr.Booking_Form_T_C_Text__c = pr.Booking_Form_T_C__c.stripHtmlTags();
            System.debug('pr.Booking_Form_T_C_Text__c*-----'+pr.Booking_Form_T_C_Text__c);
         }
        }            
        
    }
    
    @future(callOut=true)
    Public static void sendToMobileAPI(set<Id> projectIds) {
        if(!projectIds.isEmpty()) {
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endPointURL = mobile_appmdt.Communities_endpoint__c;
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
            List<PropStrength__Projects__c> projectList = [SELECT Id,Name,PropStrength__Description__c,Min_Area__c,Max_Area__c,
                                                           Master_Project__c,
                                                           (SELECT Id,Name,Type__c,Project_PS__c,Tower_PS__c FROM Aminities__r),
                                                           (SELECT Id,Name,Attraction_Type__c,Project_PS__c,Tower_PS__c FROM Attractions__r)
                                                           FROM PropStrength__Projects__c
                                                           WHERE Id IN: projectIds];
            if(!projectList.isEmpty()) {
                try{
                    String sftoken = mobile_appmdt.sf_Token__c;
                    String Subscription_Key = mobile_appmdt.Subscription_Key__c;
                    for(PropStrength__Projects__c pr : projectList) {
                        requestBodyWrapper wrap = new requestBodyWrapper();
                        wrap.sfCommunityId = pr.Id;
                        wrap.sfMasterCommunityId = pr.Master_Project__c;
                        wrap.name = (!String.isBlank(pr.Name) ? pr.Name : '');
                        wrap.minArea = (pr.Min_Area__c != null ? pr.Min_Area__c : 0);
                        wrap.maxArea  = (pr.Max_Area__c != null ? pr.Max_Area__c : 0);
                        wrap.description = (!String.isBlank(pr.PropStrength__Description__c) ? pr.PropStrength__Description__c : '');
                        if(pr.Aminities__r.size() > 0){
                            for(Amenity__c ame : pr.Aminities__r) {
                                amenities amenitywrap = new amenities();
                                amenitywrap.sfAmenityId = ame.Id;
                                amenitywrap.Name = ame.Name;
                                amenitywrap.type = ame.Type__c;
                                wrap.amenities.add(amenitywrap);
                            }
                        }
                        if(pr.Attractions__r.size() > 0){
                            for(Attractions__c attract  : pr.Attractions__r) {
                                attractions attractwrap = new attractions();
                                attractwrap.sfAttractionId = attract.Id;
                                attractwrap.Name = attract.Name;
                                attractwrap.type = attract.Attraction_Type__c;
                                wrap.attractions.add(attractwrap);
                            }
                        }
                        wraplst.add(wrap);
                    }
                    system.debug('wraplst::'+JSON.serialize(wraplst[0]));
                    if(wraplst != null){
                        String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,'POST',JSON.serialize(wraplst[0]));
                        system.debug('response::'+response);
                        if(!String.isBlank(response)) {
                            for(PropStrength__Projects__c pr : projectList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Project__c = pr.Id;
                                appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                                appLog.API_Name__c = endPointURL;
                                appLog.Response_Body__c = response;
                                if(response.contains('Success')){
                                    appLog.Status__c = 'Success';
                                }else
                                    appLog.Status__c = 'Error';
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                } catch(Exception e) {
                    for(PropStrength__Projects__c pr : projectList) {
                        Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                        appLog.Project__c = pr.Id;
                        appLog.Status__c = 'Exception';
                        appLog.API_Name__c = endPointURL;
                        appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                        appLog.Response_Body__c = String.valueOf(e.getStackTraceString());
                        insertList.add(appLog);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                    }
                    system.debug('~~~~~Error: '+e.getStackTraceString());
                }
            }
        }
    }
    
    public class requestBodyWrapper{
        //string name;
        string name;
        string description;
        Decimal minArea;
        Decimal maxArea;
        String sfCommunityId;
        String sfMasterCommunityId;
        
        List<amenities> amenities = new List<amenities>();
        List<attractions> attractions = new List<attractions>();
    }
    
    public class amenities{
        String sfAmenityId;
        String name;
        String type;
    }
    
    public class attractions{
        String sfAttractionId;
        String name;
        String type;
    }
}