global class clusTriggerHandler {
    @future(callOut=true)
    Public static void sendToMobileAPI(string newClusterString, string oldClusterString){
        String errorMessage = '';
        String requestString = '';
        string response = '';
        Integer statusCode;
        requestBodyWrapper wrap;
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
        try{ 
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endpoint = mobile_appmdt.End_Point__c;
            String sftoken = mobile_appmdt.sf_Token__c;
            String Subscription_Key = mobile_appmdt.Subscription_Key__c;
            System.debug('endpoint : '+endpoint);
            String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/communities';
            string methodType = 'POST';
            list<Cluster__c> newList = (list<Cluster__c>)JSON.deserialize(newClusterString, list<Cluster__c>.Class);
             
            for(Cluster__c cs :newList){
                 wrap = new requestBodyWrapper();
                 if(oldClusterString != null){
                    Map<Id,Cluster__c> oldMap = (Map<Id,Cluster__c>)JSON.deserialize(oldClusterString, Map<Id,Cluster__c>.Class);
					if(cs.name != oldMap.get(cs.Id).name){
                        if(cs.name != null){
                            wrap.name = cs.name;
                        }
                    }else{
                        wrap.name = oldMap.get(cs.Id).name;
                    }
                     if(cs.Description__c != oldMap.get(cs.Id).Description__c){
                         if(cs.Description__c != null){
                             wrap.description = cs.Description__c;
                         } else {
                             wrap.description = '';
                         }
                     }else{
                         wrap.description = oldMap.get(cs.Id).Description__c;
                     }
                     
                     if(cs.Min_Area__c != oldMap.get(cs.Id).Min_Area__c){
                         if(cs.Min_Area__c != null){ 
                             wrap.minArea = cs.Min_Area__c;
                         }else{
                             wrap.minArea = 0;
                         }
                     }else{
                         wrap.minArea = oldMap.get(cs.Id).Min_Area__c;
                     }
                     if(cs.Max_Area__c != oldMap.get(cs.Id).Max_Area__c){
                         if(cs.Max_Area__c != null){ 
                             wrap.maxArea = cs.Max_Area__c;
                         }else{
                             wrap.maxArea = 0;
                         }
                     }else{
                         wrap.maxArea = oldMap.get(cs.Id).Max_Area__c;
                     }
                     
                     if(cs.Id != oldMap.get(cs.Id).Id){
                         if(cs.Id != null){
                             wrap.sfCommunityId = cs.Id;
                         }
                     }else{
                         wrap.sfCommunityId = oldMap.get(cs.Id).Id;
                     }
                     
                     if(cs.Id != oldMap.get(cs.Id).Project__c){
                         if(cs.Id != null){
                             wrap.sfMasterCommunityId = cs.Project__c;
                         }
                     }else{
                         wrap.sfMasterCommunityId = oldMap.get(cs.Id).Project__c;
                     }
                     
                     List<Amenity__c> amelst = [select id,name,Type__c from Amenity__c   where Sub_Project__c =:cs.Id];
                     
                     if(amelst.size() > 0){
                         
                         for(Amenity__c ame : amelst){
                             amenities amenitywrap = new amenities();
                             amenitywrap.sfAmenityId = ame.Id;
                             amenitywrap.Name = ame.Name;
                             amenitywrap.type = ame.Type__c;
                             wrap.amenities.add(amenitywrap);
                         }
                     } else {
                         System.debug('No Amenities');
                     }
                     
                     List<Attractions__c> attractlst = [select id,name,Attraction_Type__c from Attractions__c   where Sub_Project__c =:cs.Id];
                     
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
                     if(cs.name != null){
                         wrap.name = cs.name;
                     }
                     if(cs.Description__c != null){
                         wrap.description = cs.Description__c;
                     } else {
                         wrap.description = '';
                     }
                     if(cs.Min_Area__c != null){ 
                         wrap.minArea = cs.Min_Area__c;
                     }else{
                         wrap.minArea = 0;
                     }
                     if(cs.Max_Area__c != null){ 
                         wrap.maxArea = cs.Max_Area__c;
                     }else{
                         wrap.maxArea = 0;
                     }
                     if(cs.Id != null){
                         wrap.sfCommunityId = cs.Id;
                     }
                     if(cs.Id != null){
                         wrap.sfMasterCommunityId = cs.Project__c;
                     }
                 }
                wraplst.add(wrap);
            } 
            
            if(wraplst != null){
                response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
            }
        }   
        catch(Exception e){    
            errorMessage = e.getMessage();
          //  res.responseBody = BLOB.valueOf(JSON.serialize(prepareRequest(null,'Error','Error',400,false)));
            statusCode = 400;
        }  
         Mobile_ApiUtility.createMobileAPILogs('clusTriggerHandler','clusTriggerHandler',JSON.serialize(wraplst),response,errorMessage,statusCode);

    }
    
    
    
    global class requestBodyWrapper{
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