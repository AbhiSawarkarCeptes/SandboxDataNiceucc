public class ProjectTriggerHandler {
    @future(callOut=true)
    Public static void sendToMobileAPI(string newTowerString, string oldTowerString){
        String errorMessage = '';
        Integer statusCode;
        string methodType = 'POST';
        string response = '';
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        try{ 
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endpoint = mobile_appmdt.End_Point__c;
            String sftoken = mobile_appmdt.sf_Token__c;
            String Subscription_Key = mobile_appmdt.Subscription_Key__c;
            System.debug('endpoint : '+endpoint);
            String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/master-communities';
            requestBodyWrapper wrap = new requestBodyWrapper();
            list<Project__c> newList = (list<Project__c>)JSON.deserialize(newTowerString, list<Project__c>.Class);
            //Map<Id,Project__c> oldMap = (Map<Id,Project__c>)JSON.deserialize(oldTowerString, Map<Id,Project__c>.Class);
            System.debug('new list : '+newList);
            //System.debug('old list : '+oldMap);
            system.debug('Size: '+newList.size());
            for(Project__c pr :newList){
                if(oldTowerString != null){
                    wrap = new requestBodyWrapper();
                    Map<Id,Project__c> oldMap = (Map<Id,Project__c>)JSON.deserialize(oldTowerString, Map<Id,Project__c>.Class);
                    System.debug('oldMap : '+oldMap);
                    if(pr.Name != oldMap.get(pr.Id).Name){
                        if(pr.Name != null){
                            wrap.name = pr.Name;
                        }else{
                            wrap.name = '';
                        }
                    }else{
                        wrap.Name = oldMap.get(pr.Id).Name;
                    }
                    
                    if(pr.Address__c != oldMap.get(pr.Id).Address__c){
                        if(pr.Address__c != null){
                            wrap.address = pr.Address__c;
                        }else{
                            wrap.address = '';
                        }
                    }else{
                        wrap.address = oldMap.get(pr.Id).Address__c;
                    }
                    if(pr.Max_Budget__c != oldMap.get(pr.Id).Max_Budget__c){
                        if(pr.Max_Budget__c != null){
                            wrap.maxBudget = pr.Max_Budget__c;
                        }else{
                            wrap.maxBudget = 0;
                        }
                    }else{
                        wrap.maxBudget = oldMap.get(pr.Id).Max_Budget__c;
                    }
                    if(pr.Min_Budget__c != oldMap.get(pr.Id).Min_Budget__c){
                        if(pr.Min_Budget__c != null){
                            wrap.minBudget = pr.Min_Budget__c;
                        } else {
                            wrap.minBudget = 0;
                        }
                    }else{
                        wrap.minBudget = oldMap.get(pr.Id).Min_Budget__c;
                    }
                    
                    if(pr.longitude__c != oldMap.get(pr.Id).longitude__c){
                        if(pr.longitude__c != null){
                            wrap.longitude = pr.longitude__c;
                        }else{
                            wrap.longitude = '';
                        }
                    }else{
                        if(oldMap.get(pr.Id).longitude__c != null){
                            wrap.longitude = oldMap.get(pr.Id).longitude__c;
                        }else{
                            wrap.longitude = '';
                        }
                        
                    }
                    
                    if(pr.latitude__c != oldMap.get(pr.Id).latitude__c){
                        if(pr.latitude__c != null){
                            wrap.latitude = pr.latitude__c;
                        }else{
                            wrap.latitude = '';
                        }
                    }else{
                        if(oldMap.get(pr.Id).latitude__c !=null){
                            wrap.latitude = oldMap.get(pr.Id).latitude__c;
                        }else{
                            wrap.latitude = '';
                        }
                        
                    }
                    
                    if(pr.Project_Stage__c != oldMap.get(pr.Id).Project_Stage__c){
                        if(pr.Project_Stage__c != null){
                            wrap.stage = pr.Project_Stage__c;
                        }else{
                            wrap.stage = '';
                        }
                    }else{
                        wrap.stage = oldMap.get(pr.Id).Project_Stage__c;
                    }
                    
                    if(pr.Project_Property_Type__c != oldMap.get(pr.Id).Project_Property_Type__c){
                        if(pr.Project_Property_Type__c != null){
                            wrap.projectType = pr.Project_Property_Type__c;
                        }else{
                            wrap.projectType = '';
                        }
                    }else{
                        wrap.projectType = oldMap.get(pr.Id).Project_Property_Type__c;
                    }
                    
                    if(pr.Id != oldMap.get(pr.Id).Id){
                        if(pr.Id != null){
                            wrap.sfMasterCommunityId = pr.Id;
                        }
                    }else{
                        wrap.sfMasterCommunityId = oldMap.get(pr.Id).Id;
                    }
                    
                    List<Amenity__c> amelst = [select id,name,Type__c,Project__c from Amenity__c   where Project__c =:pr.Id];
                    
                    if(amelst.size() > 0){
                        
                        for(Amenity__c ame : amelst){
                            amenities amenitywrap = new amenities();
                            amenitywrap.sfAmenityId = ame.Id;
                            amenitywrap.Name = ame.Name;
                            amenitywrap.type = ame.Type__c;
                            // wrap.amenities = new wrap.amenities();
                            wrap.amenities.add(amenitywrap);
                        }
                    } else {
                        System.debug('No Amenities');
                    }
                    
                    List<Attractions__c> attractlst = [select id,name,Attraction_Type__c,Project__c from Attractions__c   where Project__c =:pr.Id];
                    
                    if(attractlst.size() > 0){
                        
                        for(Attractions__c attract : attractlst){
                            attractions attractwrap = new attractions();
                            attractwrap.sfAttractionId = attract.Id;
                            attractwrap.Name = attract.Name;
                            attractwrap.type = attract.Attraction_Type__c;
                            // wrap.amenities = new wrap.amenities();
                            wrap.attractions.add(attractwrap);
                        }
                    } else {
                        System.debug('No Attractions');
                    }
                    
                }
                else{
                    if(pr.Name != null){
                        wrap.name = pr.Name;
                    }else{
                        wrap.name = '';
                    }
                    if(pr.Address__c != null){
                        wrap.address = pr.Address__c;
                    }else{
                        wrap.address = '';
                    }
                    if(pr.Max_Budget__c != null){
                        wrap.maxBudget = pr.Max_Budget__c;
                    }else{
                        wrap.maxBudget = 0;
                    }
                    if(pr.Min_Budget__c != null){
                        wrap.minBudget = pr.Min_Budget__c;
                    } else {
                        wrap.minBudget = 0;
                    }
                    if(pr.longitude__c != null){
                        wrap.longitude = pr.longitude__c;
                    }else{
                        wrap.longitude = '';
                    }
                    if(pr.latitude__c != null){
                        wrap.latitude = pr.latitude__c;
                    }else{
                        wrap.latitude = '';
                    }
                    if(pr.Project_Stage__c != null){
                        wrap.stage = pr.Project_Stage__c;
                    }else{
                        wrap.stage = '';
                    }
                    if(pr.Project_Property_Type__c != null){
                        wrap.projectType = pr.Project_Property_Type__c;
                    }else{
                        wrap.projectType = '';
                    }
                    if(pr.Id != null){
                        wrap.sfMasterCommunityId = pr.Id;
                    }
                }
                wraplst.add(wrap);
            }
            
            if(wraplst != null){
                response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
                system.debug('response '+response);
            }
        }catch(Exception e){
            errorMessage = e.getMessage();
            statusCode = 400;
            system.debug('~~~~~Error: '+e.getStackTraceString());
        }
        Mobile_ApiUtility.createMobileAPILogs('ProjectTriggerHandler','ProjectTriggerHandler',JSON.serialize(wraplst),response,errorMessage,statusCode);
        
    }
    
    class requestBodyWrapper{
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
    
    class amenities{
        String sfAmenityId;
        String name;
        String type;
    }
    
    class attractions{
        String sfAttractionId;
        String name;
        String type;
    }
}