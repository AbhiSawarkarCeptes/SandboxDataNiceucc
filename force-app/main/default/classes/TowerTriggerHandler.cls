public class TowerTriggerHandler {
    
    @future(callOut=true)
    Public static void sendToMobileAPI(string newTowerString, string oldTowerString){
        String errorMessage = '';
        Integer statusCode;
        string methodType = 'POST';
        string response = '';
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endPoint = mobile_appmdt.End_Point__c;
        
        string endPointURL = endPoint+'/srprosalesforce/v1/salesforce/towers';
        list<Tower__c> newList = (list<Tower__c>)JSON.deserialize(newTowerString, list<Tower__c>.Class);
        requestBodyWrapper wrap;
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        try{
            for(Tower__c tw :newList){
                wrap = new requestBodyWrapper();
                if(oldTowerString != null){
                    Map<Id,Tower__c> oldMap = (Map<Id,Tower__c>)JSON.deserialize(oldTowerString, Map<Id,Tower__c>.Class);
                    
                    if(tw.Name != oldMap.get(tw.Id).Name){
                        if(tw.Name != null){ 
                            wrap.name = tw.Name;
                        }
                    }else{
                        wrap.name = oldMap.get(tw.Id).Name;
                    }
                    
                    if(tw.Completion_Percentage__c != oldMap.get(tw.Id).Completion_Percentage__c){
                        if(tw.Completion_Percentage__c != null){
                            wrap.completionPercentage = tw.Completion_Percentage__c;
                        }else{
                            wrap.completionPercentage = 0;
                        }
                    }else{
                        wrap.completionPercentage = oldMap.get(tw.Id).Completion_Percentage__c;
                    }
                    if(tw.Under_Construction__c != oldMap.get(tw.Id).Under_Construction__c){
                        if(tw.Under_Construction__c != null){
                            wrap.isUnderConstruction = tw.Under_Construction__c;
                        }else{
                            wrap.isUnderConstruction = false;
                        }
                    }else{
                        wrap.isUnderConstruction = oldMap.get(tw.Id).Under_Construction__c;
                    }
                    if(tw.Id != oldMap.get(tw.Id).Id){
                        if(tw.Id != null){
                            wrap.sfTowerId = tw.Id;
                        }
                    }else{
                        wrap.sfTowerId = oldMap.get(tw.Id).Id;
                    }
                    
                    wrap.isManagedBy = tw.Managed_by_SCM__c;
                        
                    if(tw.Project__c != oldMap.get(tw.Id).Project__c){
                        if(tw.Project__c != null){
                            wrap.sfMasterCommunityId = tw.Project__c;
                        }
                    }else{
                        wrap.sfMasterCommunityId = oldMap.get(tw.Id).Project__c;
                    }
                    
                    if(tw.Cluster__c != oldMap.get(tw.Id).Cluster__c){
                        if(tw.Cluster__c != null){
                            wrap.sfCommunityId = tw.Cluster__c;
                        }
                    }else{
                        wrap.sfCommunityId = oldMap.get(tw.Id).Cluster__c;
                    }
                    
                    List<Amenity__c> amelst = [select id,name,Type__c from Amenity__c   where Tower__c =:tw.Id];
                    
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
                    
                    List<Attractions__c> attractlst = [select id,name,Attraction_Type__c from Attractions__c   where Tower__c =:tw.Id];
                    
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
                    if(tw.Name != null){ 
                        wrap.name = tw.Name;
                    }
                    if(tw.Completion_Percentage__c != null){
                        wrap.completionPercentage = tw.Completion_Percentage__c;
                    }else{
                        wrap.completionPercentage = 0;
                    }
                    if(tw.Under_Construction__c != null){
                        wrap.isUnderConstruction = tw.Under_Construction__c;
                    }else{
                        wrap.isUnderConstruction = false;
                    }
                    if(tw.Id != null){
                        wrap.sfTowerId = tw.Id;
                    }
                    if(tw.Project__c != null){
                        wrap.sfMasterCommunityId = tw.Project__c;
                    }
                    if(tw.Cluster__c != null){
                        wrap.sfCommunityId = tw.Cluster__c;
                    }
                }
                
                wraplst.add(wrap);
            }
            
            if(wraplst != null){
                response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
            }
            
        }catch(Exception e){
            errorMessage = e.getMessage();
            statusCode = 400;
        }
        
        Mobile_ApiUtility.createMobileAPILogs('TowerTriggerHandler','TowerTriggerHandler',JSON.serialize(wraplst),response,errorMessage,statusCode);
        
    }
    class requestBodyWrapper{
        string name;
        Decimal completionPercentage;
        boolean isUnderConstruction;
        string sfMasterCommunityId;
        string sfCommunityId;
        string sfTowerId;
        Boolean isManagedBy;
        
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