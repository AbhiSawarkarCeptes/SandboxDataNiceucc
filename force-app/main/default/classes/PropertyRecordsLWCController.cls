public with sharing class PropertyRecordsLWCController {
    
    @AuraEnabled
    public static List<PropStrength__Projects__c> searchProjectRecord(String searchKeyWrd, String recId){
        List<PropStrength__Projects__c> projList = new List<PropStrength__Projects__c>();
        List<PropStrength__Projects__c> returnList = new List<PropStrength__Projects__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            projList = [SELECT Id, Name, (SELECT Id FROM PropStrength__Property__r) FROM PropStrength__Projects__c WHERE Name LIKE :searchKeyWrd];
        } else {
            projList = [SELECT Id, Name, (SELECT Id FROM PropStrength__Property__r) FROM PropStrength__Projects__c];
        }
        for(PropStrength__Projects__c proj : projList) {
            if(!proj.PropStrength__Property__r.isEmpty()) {
                returnList.add(proj);
            }
        }
        return returnList;
    }
    @AuraEnabled
    public static List<PropStrength__Tower__c> searchTowersRecord(String searchKeyWrd, String recId){
        List<PropStrength__Tower__c> towerList = new List<PropStrength__Tower__c>();
        List<PropStrength__Tower__c> returnList = new List<PropStrength__Tower__c>();
        
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            towerList = [SELECT Id,Name,  PropStrength__Tower_Name__c, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE PropStrength__Tower_Name__c LIKE :searchKeyWrd AND PropStrength__Project_Name__c =:recId];
            
        } else {
            towerList = [SELECT Id,Name, PropStrength__Tower_Name__c, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE PropStrength__Project_Name__c =:recId];
        }
        return towerList;
    }
    @AuraEnabled
    public static List<PropStrength__Floor__c> searchFloorRecord(String searchKeyWrd, String recId){
        List<PropStrength__Floor__c> floorList = new List<PropStrength__Floor__c>();
        List<PropStrength__Floor__c> returnList = new List<PropStrength__Floor__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            floorList = [SELECT Id,Name,PropStrength__Floor_Name__c,  PropStrength__Tower__c, PropStrength__Tower__r.PropStrength__Project_Name__c, (SELECT ID FROM PropStrength__Property__r) FROM PropStrength__Floor__c WHERE PropStrength__Floor_Name__c LIKE :searchKeyWrd AND PropStrength__Tower__c = :recId];
        } else {
            floorList =  [SELECT Id,Name,PropStrength__Floor_Name__c, PropStrength__Tower__c, PropStrength__Tower__r.PropStrength__Project_Name__c, (SELECT ID FROM PropStrength__Property__r) FROM PropStrength__Floor__c WHERE PropStrength__Tower__c != null AND PropStrength__Tower__c = :recId];
        }
        return floorList;
    }
    
    @AuraEnabled
    public static List<PropStrength__Property__c> getPropertyList(String projId, String towerId, String floorId) {
        User u = [SELECT ID, UserRole.Name  FROM USER WHERE Id = : userInfo.getUserId()];
        boolean flagUserSM = false;
        if(u != null && u.UserRole != null && u.UserRole.Name.contains('Sales Manager')) {
            flagUserSM = true;
        }
        List<PropStrength__Property__c> propertyList = new List<PropStrength__Property__c>();
        if(projId != '' && towerId != '' && floorId == '') {
            propertyList = [SELECT Id, PropStrength__Property_Name__c, PropStrength__Project_Name__c, PropStrength__Property_Type__c, PropStrength__Project_Name__r.Name,  
                            PropStrength__Property_Type_Name__c, PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Floor__r.PropStrength__Floor_Name__c, 
                            PropStrength__Super_Area__c, PropStrength__Rate_per_unit_area__c , PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c, 
                            PropStrength__Property_Alloted_Through_Offer__c,
                            (SELECT ID, OwnerId FROM Unit_Hold__r WHERE Status__c = 'Active' AND Unit_Hold_Approval_Status__c = 'Approved')
                            FROM PropStrength__Property__c 
                            WHERE PropStrength__Project_Name__c =:projId 
                            AND PropStrength__Tower__c =: towerId AND PropStrength__Allotted__c =false 
                            AND PropStrength__Property_Alloted_Through_Offer__c =false 
                            AND PropStrength__Property_on_hold_for_Reallocation__c = false 
                            AND Not_for_Sale__c = FALSE
                            AND PropStrength__Unit_Status__c = 'Available'
                            AND (Hold_Requester__c = :UserInfo.getUserId() OR Hold_Requester__c = null)
                           ];
        }
        else if(projId != '' && towerId != '' && floorId != '') {
            propertyList = [SELECT Id, PropStrength__Property_Name__c, PropStrength__Project_Name__c,PropStrength__Project_Name__r.Name,PropStrength__Property_Type__c,  
                            PropStrength__Property_Type_Name__c, PropStrength__Tower__r.PropStrength__Tower_Name__c, PropStrength__Floor__r.PropStrength__Floor_Name__c, 
                            PropStrength__Super_Area__c, PropStrength__Rate_per_unit_area__c,  PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c, 
                            PropStrength__Property_Alloted_Through_Offer__c,
                            (SELECT ID, OwnerId FROM Unit_Hold__r WHERE Status__c = 'Active' AND Unit_Hold_Approval_Status__c = 'Approved')
                            FROM PropStrength__Property__c 
                            WHERE PropStrength__Project_Name__c =:projId 
                            AND PropStrength__Tower__c =: towerId 
                            AND PropStrength__Floor__c = :floorId AND PropStrength__Allotted__c =false 
                            AND PropStrength__Property_Alloted_Through_Offer__c =false 
                            AND PropStrength__Property_on_hold_for_Reallocation__c = false 
                            AND Not_for_Sale__c = FALSE
                            AND PropStrength__Unit_Status__c = 'Available'
                            AND (Hold_Requester__c = :UserInfo.getUserId() OR Hold_Requester__c = null)
                           ];
        }
        if(flagUserSM) {
            List<PropStrength__Property__c> propertyForSM = new List<PropStrength__Property__c>();
            for(PropStrength__Property__c prop : propertyList) {
                if(!prop.PropStrength__Property_on_hold_for_Reallocation__c || !prop.PropStrength__Allotted__c ) {
                    propertyForSM.add(prop);
                }
                else if(prop.Unit_Hold__r.size() > 0) {
                    for(Unit_Hold__c rec : prop.Unit_Hold__r) {
                        if(rec.OwnerId == u.Id) {
                            propertyForSM.add(prop);
                            break;
                        }
                    }
                }
            }
            return propertyForSM;
        }
        else{
            return propertyList;
        }
    }
    
   @AuraEnabled
    public static boolean validateHoldProperty(List<String> propId) {
        for(Unit_Hold__c holdRec : [SELECT id,owner.userRoleId,ownerId,owner.userRole.Name  from Unit_Hold__c where Status__c = 'Active' 
                                    AND Unit_No__r.PropStrength__Property_on_hold_for_Reallocation__c = true AND Unit_No__c IN : propId ]){
                                        if( !((holdRec.ownerId == userInfo.getUserId() && holdRec.owner.userRoleId != null && (holdRec.owner.userRole.Name.contains('sales director') || holdRec.owner.userRole.Name.contains('sales manager') ) ) || ( holdRec.owner.userRoleId != null && holdRec.owner.userRole.Name.contains('sales operations')) ) )  {
                                            return true;
                                        }
                                        else
                                           return false; 
        }
        System.debug('propId**---'+propId);
        return null;
    }
    
}