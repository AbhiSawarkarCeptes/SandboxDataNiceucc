public class UnitRequestHoldLWCController {
    @AuraEnabled
    public static List<PropStrength__Projects__c> searchProjectRecord(String searchKeyWrd){
        List<PropStrength__Projects__c> projList = new List<PropStrength__Projects__c>();
        List<PropStrength__Projects__c> returnList = new List<PropStrength__Projects__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            projList = [SELECT Id, Name, 
                        (SELECT Id, PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c  FROM PropStrength__Property__r 
                        WHERE  PropStrength__Allotted__c =false 
                        AND PropStrength__Property_Alloted_Through_Offer__c =false 
                        AND PropStrength__Property_on_hold_for_Reallocation__c = false) 
                        FROM PropStrength__Projects__c 
                        WHERE Name LIKE :searchKeyWrd];
        } else {
            projList = [SELECT Id, Name, 
                        (SELECT Id, PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c FROM PropStrength__Property__r 
                        WHERE  PropStrength__Allotted__c = false 
                        AND PropStrength__Property_Alloted_Through_Offer__c =false 
                        AND PropStrength__Property_on_hold_for_Reallocation__c = false) 
                        FROM PropStrength__Projects__c];
        }
        for(PropStrength__Projects__c proj : projList) {
            if(!proj.PropStrength__Property__r.isEmpty()) {
                returnList.add(proj);
            }
        }

        return returnList;
    }
    @AuraEnabled
    public static List<PropStrength__Property__c> searchUnit(String searchKeyWrd, String projId){
        List<PropStrength__Property__c> projList = new List<PropStrength__Property__c>();
        List<PropStrength__Property__c> propReturn = new List<PropStrength__Property__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            projList = [SELECT Id, Name, PropStrength__House_Unit_No__c, PropStrength__Project_Name__c, PropStrength__Property_Name__c, PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c,
                        (SELECT Id, Status__c FROM Payment_Requests__r WHERE NOT(Status__c  LIKE '%Rejected%' OR Status__c LIKE '%Resubmitted%')) 
                        FROM PropStrength__Property__c 
                        WHERE PropStrength__House_Unit_No__c LIKE :searchKeyWrd 
                        AND PropStrength__Project_Name__c = :projId 
                        AND PropStrength__Allotted__c =false 
                        AND PropStrength__Property_Alloted_Through_Offer__c =false 
                        AND PropStrength__Property_on_hold_for_Reallocation__c = false 
                        AND PropStrength__House_Unit_No__c != null 
                        AND Not_for_Sale__c = FALSE
                        AND PropStrength__Unit_Status__c = 'Available'];
        } else {
            projList = [SELECT Id, Name, PropStrength__House_Unit_No__c, PropStrength__Project_Name__c, PropStrength__Property_Name__c, PropStrength__Allotted__c, PropStrength__Property_on_hold_for_Reallocation__c,
                        (SELECT Id, Status__c FROM Payment_Requests__r WHERE NOT(Status__c  LIKE '%Rejected%' OR Status__c LIKE '%Resubmitted%'))  
                        FROM PropStrength__Property__c 
                        WHERE PropStrength__Project_Name__c = :projId 
                        AND PropStrength__Allotted__c =false 
                        AND PropStrength__Property_Alloted_Through_Offer__c =false 
                        AND PropStrength__Property_on_hold_for_Reallocation__c = false 
                        AND PropStrength__House_Unit_No__c != null 
                        AND Not_for_Sale__c = FALSE
                        AND PropStrength__Unit_Status__c = 'Available'];
        }
        for(PropStrength__Property__c p : projList) {
            if(p.Payment_Requests__r.size() == 0) {
                propReturn.add(p);
            }
        }
        return propReturn;
    }
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
            ContentVersion cv = createContentVersion(base64, filename);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }
            return cdl.Id;
    }
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        insert cv;
        return cv;
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        SYstem.debug(contentVersionId+'-**--'+recordId);
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        System.debug('cdl*---'+cdl);
        insert cdl;
        return cdl;
    }
    @InvocableMethod
    public static void updatePropertyOnHoldValue(List<PropStrength__Property__c> prList ) {
        List<PropStrength__Property__c> propertyList = new List<PropStrength__Property__c>();
        List<PropStrength__Property__c> propertyListToUpdate = new List<PropStrength__Property__c>();
        propertyList = [SELECT Id, Name,PropStrength__Property_on_hold_for_Reallocation__c, Hold_Requester__c, Hold_Requester__r.Email, 
                        (SELECT Id, status__c FROM Payment_Requests__r ) FROM PropStrength__Property__c WHERE Id =: prList[0].Id AND PropStrength__Property_on_hold_for_Reallocation__c = true AND Hold_Requester__c != null];
        for(PropStrength__Property__c rec : propertyList) {
            if(rec.Payment_Requests__r.size() == 0 && rec.PropStrength__Property_on_hold_for_Reallocation__c) {
                rec.PropStrength__Property_on_hold_for_Reallocation__c = false;
                rec.Hold_Classification__c = null;
                rec.Allocated_SM__c = null;
                propertyListToUpdate.add(rec);
                UnitRequestHoldLWCController.sendMailToHoldRequester(rec.Id);
            } 
            else if(rec.Payment_Requests__r.size() > 0) {
                boolean flag = true;
                for(Payment_Request__c prRec : rec.Payment_Requests__r) {
                    if(prRec.status__c.contains('Rejected')) {
                        flag = false;
                    }
                }
                if(rec.PropStrength__Property_on_hold_for_Reallocation__c && !flag) {
                    rec.PropStrength__Property_on_hold_for_Reallocation__c = false;
                    rec.Hold_Classification__c = null;
                    rec.Allocated_SM__c = null;
                    propertyListToUpdate.add(rec);
                    UnitRequestHoldLWCController.sendMailToHoldRequester(rec.Id);
                }
            }
        }
        if(!propertyListToUpdate.isEmpty()) {
            update propertyListToUpdate;
        }
         
    }

    //Added by Nishank Manwani on 09/02/2024 to send mail to Hold Requester
    @Future(callout=true)
    public static void sendMailToHoldRequester(String recId) {
        if(recId != null) {
            List<PropStrength__Property__c> record = [SELECT Id, Name,PropStrength__Property_on_hold_for_Reallocation__c, Hold_Requester__c, Hold_Requester__r.Email 
                                                                FROM PropStrength__Property__c WHERE Id =: recId];
            
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'Send_Mail_To_Hold_Requester'];
            String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
            Map<Id, PropStrength__Application_Booking__c> bookingListUpdate = new Map<Id,PropStrength__Application_Booking__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{record[0].Hold_Requester__r.Email});
            email.setWhatId(record[0].id);
            email.setTargetObjectId(record[0].Hold_Requester__c);
            email.setTreatTargetObjectAsRecipient(False);
            email.setSaveAsActivity(true); 
            email.setTemplateId(tempId);
            emailList.add(email); 
            
            System.debug(emailList);
            try{
                if(emailList != null && emailList.size()>0 ) {
                    System.debug(emailList);
                    Messaging.sendEmail(emailList);
                }
            }catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }


    @AuraEnabled
    public static String createUnitHoldRecord(String name, String reqHrs, String unitId) {
        try {
            Unit_Hold__c unitHoldRec = new Unit_Hold__c();
            unitHoldRec.Customer_Full_Name__c = name;
            unitHoldRec.Request_Time__c = reqHrs;
            unitHoldRec.Unit_No__c = Id.valueOf(unitId);
            unitHoldRec.Unit_Hold_Requested__c = true;
            unitHoldRec.Status__c = 'Inactive';
            unitHoldRec.OwnerId = UserInfo.getUserId();
            User userRec = [SELECT Id, UserRole.Name, 
                                ManagerId, Manager.UserRole.Name, 
                                Manager.ManagerId, Manager.Manager.UserRole.Name,
                                Manager.Manager.ManagerId, Manager.Manager.Manager.UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
            // Code Added By Gourav on 19-02-2024
            if(userRec.userrole.name != null && userRec.userrole.name.containsIgnoreCase('Sales Manager')){
                    unitHoldRec.Sales_Manager__c = userRec.id;
                    unitHoldRec.Sales_Director__c = userRec.managerId;
                    unitHoldRec.Sales_VP__c = userRec.manager.managerId;
                    unitHoldRec.SVP__c = userRec.manager.manager.managerId;
                }
            else if(userRec.userrole.name != null && userRec.userrole.name.containsIgnoreCase('Sales Head')){
                unitHoldRec.Sales_Director__c = userRec.Id;
                unitHoldRec.Sales_VP__c = userRec.managerId;
                unitHoldRec.SVP__c = userRec.manager.managerId;
            } 
            else if(userRec.Manager.Id != null && userRec.Manager.UserRole.Name != null && userRec.Manager.UserRole.Name.containsIgnoreCase('Sales Manager')) {
                unitHoldRec.Sales_Manager__c = userRec.Manager.Id;
                unitHoldRec.Sales_Director__c = userRec.Manager.managerId;
                unitHoldRec.Sales_VP__c = userRec.Manager.manager.managerid;
            }
            // Code Commented By Gourav on 19-02-2024.
          /*  if(userRec.UserRole != null && userRec.UserRole.Name.contains('Sales Manager')) {
                unitHoldRec.Sales_Manager__c = userRec.Id;
            }
            else if(userRec.Manager.Id != null && userRec.Manager.UserRole.Name.contains('Sales Manager')) {
                unitHoldRec.Sales_Manager__c = userRec.Manager.Id;
            }
            else if(userRec.Manager.Manager.Id != null && userRec.Manager.Manager.UserRole.Name.contains('Sales Manager')) {
                unitHoldRec.Sales_Manager__c = userRec.Manager.Manager.Id;
            }

            if(userRec.UserRole != null && userRec.UserRole.Name.contains('Vice President')) {
                unitHoldRec.Sales_VP__c = userRec.Id;
            }
            else if(userRec.Manager.Id != null && userRec.Manager.UserRole.Name.contains('Vice President')) {
                unitHoldRec.Sales_VP__c = userRec.Manager.Id;
            }
            else if(userRec.Manager.Manager.Id != null && userRec.Manager.Manager.UserRole.Name.contains('Vice President')) {
                unitHoldRec.Sales_VP__c = userRec.Manager.Manager.Id;
            }

            if(userRec.UserRole != null && userRec.UserRole.Name.contains('Sales Director')) {
                unitHoldRec.Sales_Director__c = userRec.Id;
            }
            else if(userRec.Manager.Id != null && userRec.Manager.UserRole.Name.contains('Sales Director')) {
                unitHoldRec.Sales_Director__c = userRec.Manager.Id;
            }
            else if(userRec.Manager.Manager.Id != null && userRec.Manager.Manager.UserRole.Name.contains('Sales Director')) {
                unitHoldRec.Sales_Director__c = userRec.Manager.Manager.Id;
            }*/
            insert unitHoldRec;
            return unitHoldRec.Id;
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}