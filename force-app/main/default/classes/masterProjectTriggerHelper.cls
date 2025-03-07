public class masterProjectTriggerHelper {
    public static void sendToMobileMasterProject(List<Master_Project__c> newList,map<Id,Master_Project__c> oldMap) {
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.Master_Project_Trigger__c;
        set<Id> projectIds = new Set<Id>();
        if(trgFlg || test.isRunningTest()) {
            for(Master_Project__c pr : newList) {
                if(trigger.isInsert) {
                    if(pr.Name != null || pr.Street__c != null || pr.City__c != null || pr.State_Province__c != null || pr.Zip_Postal_Code__c != null || pr.Country__c != null || pr.Max_Budget__c != null || pr.Min_Budget__c != null || pr.longitude__c != null || pr.latitude__c != null ||
                       pr.Status__c != null || pr.Type_of_Project__c != null) {
                        projectIds.add(pr.Id);
                    }
                } else if(trigger.isUpdate) {
                    if(pr.Name != oldMap.get(pr.Id).Name ||
                       pr.Street__c != oldMap.get(pr.Id).Street__c ||
                       pr.City__c != oldMap.get(pr.Id).City__c ||
                       pr.State_Province__c != oldMap.get(pr.Id).State_Province__c ||
                       pr.Zip_Postal_Code__c != oldMap.get(pr.Id).Zip_Postal_Code__c ||
                       pr.Country__c != oldMap.get(pr.Id).Country__c ||
                       pr.Max_Budget__c != oldMap.get(pr.Id).Max_Budget__c ||
                       pr.Min_Budget__c != oldMap.get(pr.Id).Min_Budget__c ||
                       pr.longitude__c != oldMap.get(pr.Id).longitude__c ||
                       pr.latitude__c != oldMap.get(pr.Id).latitude__c ||
                       pr.Status__c != oldMap.get(pr.Id).Status__c ||
                       pr.Type_of_Project__c != oldMap.get(pr.Id).Type_of_Project__c) {
                        projectIds.add(pr.Id);
                    }
                }
            }
            if(!projectIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                masterProjectTriggerHelper.sendToMobileAPIMasterProject(projectIds);
            }
        }
    }
    
    
    @future(callOut=true)
    Public static void sendToMobileAPIMasterProject(set<Id> projectIds) {
        if(!projectIds.isEmpty()) {
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endPointURL = mobile_appmdt.Master_Communities_Endpoint__c;
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<requestMasterBodyWrapper> wraplst = new List<requestMasterBodyWrapper>();
            List<Master_Project__c> projectList = [SELECT Id,Name,Street__c,City__c,State_Province__c,Zip_Postal_Code__c,Country__c,
                                                   Max_Budget__c,Min_Budget__c,longitude__c,latitude__c,Status__c,Type_of_Project__c,
                                                   (SELECT Id,Name,Type__c,Project_PS__c,Tower_PS__c FROM Aminities__r),
                                                   (SELECT Id,Name,Attraction_Type__c,Project_PS__c,Tower_PS__c FROM Attractions__r)
                                                   FROM Master_Project__c
                                                   WHERE Id IN: projectIds];
            if(!projectList.isEmpty()) {
                try{
                    String sftoken = mobile_appmdt.sf_Token__c;
                    String Subscription_Key = mobile_appmdt.Subscription_Key__c;
                    System.debug('endPointURL : '+endPointURL);
                    //endPointURL = endpoint+'/srprosalesforce/v1/salesforce/master-communities';
                    for(Master_Project__c pr : projectList) {
                        requestMasterBodyWrapper wrap = new requestMasterBodyWrapper();
                        wrap.sfMasterCommunityId = pr.Id;
                        wrap.name = (!String.isBlank(pr.Name) ? pr.Name : '');
                        wrap.address = (!String.isBlank(pr.Street__c) ? pr.Street__c : '') + ' ' + 
                            (!String.isBlank(pr.City__c) ? pr.City__c : '') + ' ' + 
                            (!String.isBlank(pr.State_Province__c) ? pr.State_Province__c : '') + ' ' + 
                            (!String.isBlank(pr.Zip_Postal_Code__c) ? pr.Zip_Postal_Code__c : '') + ' ' + 
                            (!String.isBlank(pr.Country__c) ? pr.Country__c : '');
                        wrap.maxBudget = (pr.Max_Budget__c != null ? pr.Max_Budget__c : 0);
                        wrap.minBudget  = (pr.Min_Budget__c != null ? pr.Min_Budget__c : 0);
                        wrap.longitude = (!String.isBlank(pr.longitude__c) ? pr.longitude__c : '');
                        wrap.latitude = (!String.isBlank(pr.latitude__c) ? pr.latitude__c : '');
                        wrap.stage = (!String.isBlank(pr.Status__c) ? pr.Status__c : '');
                        wrap.projectType = (!String.isBlank(pr.Type_of_Project__c) ? pr.Type_of_Project__c : '');
                        if(pr.Aminities__r.size() > 0){
                            system.debug('Amenity__c::'+pr.Aminities__r);
                            for(Amenity__c ame : pr.Aminities__r) {
                                amenities amenitywrap = new amenities();
                                amenitywrap.sfAmenityId = ame.Id;
                                amenitywrap.Name = ame.Name;
                                amenitywrap.type = (ame.Type__c != null) ? ame.Type__c : '';
                                wrap.amenities.add(amenitywrap);
                            }
                        }
                        if(pr.Attractions__r.size() > 0){
                            system.debug('Attractions__c::'+pr.Attractions__r);
                            for(Attractions__c attract  : pr.Attractions__r) {
                                attractions attractwrap = new attractions();
                                attractwrap.sfAttractionId = attract.Id;
                                attractwrap.Name = attract.Name;
                                attractwrap.type = (attract.Attraction_Type__c != null ? attract.Attraction_Type__c : '');
                                wrap.attractions.add(attractwrap);
                            }
                        }
                        wraplst.add(wrap);
                    }
                    if(wraplst != null){
                        system.debug('wraplst::'+JSON.serialize(wraplst[0]));
                        String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,'POST',JSON.serialize(wraplst[0]));
                        system.debug('response::'+response);
                        if(!String.isBlank(response)) {
                            for(Master_Project__c pr : projectList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Master_Project__c = pr.Id;
                                appLog.Status__c = response;
                                appLog.API_Name__c = endPointURL;
                                appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                                appLog.Response_Body__c = response;
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                } catch(Exception e) {
                    for(Master_Project__c pr : projectList) {
                        Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                        appLog.Master_Project__c = pr.Id;
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
    
    public class requestMasterBodyWrapper{
        //string name;
        string name;
        string address;
        Decimal maxBudget;
        Decimal minBudget;
        String longitude;
        String latitude;
        String stage;
        String projectType;
        String sfMasterCommunityId; 
        // amenities amenities;
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