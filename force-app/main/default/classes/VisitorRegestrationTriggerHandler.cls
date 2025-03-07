public class VisitorRegestrationTriggerHandler {
    public static void createSiteVisitForm(List<Visitor_Registration__c> visitRegList, Map<Id,Visitor_Registration__c> visitRegOldMap) {
        List<Customer_Registration__c> siteVisitToInsert = new List<Customer_Registration__c>();
        List<Visitor_Registration__c> vrList = new List<Visitor_Registration__c>();
        Set<String> salesName = new Set<String>();
        Map<String, Id> userNameIdMap = new Map<String, Id>();
        Set<String> duplicateCheckSet = new Set<String>();
        Map<String, Id> duplicatEnquiryCheckMap = new Map<String, Id>();

        for(Visitor_Registration__c vr : visitRegList) {
            if(vr.Sales_Adviser__c != null) {
                salesName.add(vr.Sales_Adviser__c);
            }
            if(vr.DocumentId__c != null) {
                duplicateCheckSet.add(vr.DocumentId__c);
            }
            if(vr.Email__c != null) {
                duplicateCheckSet.add(vr.Email__c);
            }
            if(vr.Alternate_Email_Id__c != null) {
                duplicateCheckSet.add(vr.Alternate_Email_Id__c);
            }
            if(vr.Alternate_Mobile_Number__c != null) {
                duplicateCheckSet.add(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Alternate_Mobile_Number__c));
            }
            if(vr.Mobile__c != null) {
                duplicateCheckSet.add(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Mobile__c));
            }
        }
        for(PropStrength__Request__c pr : [SELECT Id, PropStrength__Primary_Contact__r.VCC1__Email_Encrypted__c, PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted_Data__c, 
                                            PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted_Data__c, PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted_Data__c, 
                                            DocumentId__c, (SELECT Id FROM Site_Visit_Forms__r) FROM PropStrength__Request__c 
                                            WHERE DocumentId__c IN :duplicateCheckSet
                                            OR PropStrength__Primary_Contact__r.VCC1__Email_Encrypted__c IN :duplicateCheckSet
                                            OR PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted_Data__c IN :duplicateCheckSet
                                            OR PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted_Data__c IN :duplicateCheckSet
                                            OR PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted_Data__c IN :duplicateCheckSet]) {
            if(pr.Site_Visit_Forms__r.size() == 0 ){
                if(pr.DocumentId__c != null) {
                    duplicatEnquiryCheckMap.put(pr.DocumentId__c, pr.Id);
                }
                if(pr.PropStrength__Primary_Contact__r.VCC1__Email_Encrypted__c != null) {
                    duplicatEnquiryCheckMap.put(pr.PropStrength__Primary_Contact__r.VCC1__Email_Encrypted__c, pr.Id);
                }
                if(pr.PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted_Data__c != null) {
                    duplicatEnquiryCheckMap.put(pr.PropStrength__Primary_Contact__r.VCC1__Mobile_Encrypted_Data__c, pr.Id);
                }
                if(pr.PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted_Data__c != null) {
                    duplicatEnquiryCheckMap.put(pr.PropStrength__Primary_Contact__r.VCC1__Calling_Number_Encrypted_Data__c, pr.Id);
                }
                if(pr.PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted_Data__c != null) {
                    duplicatEnquiryCheckMap.put(pr.PropStrength__Primary_Contact__r.VCC1__Phone_Encrypted_Data__c, pr.Id);
                }
            }
        }
        for(User u: [SELECT Id, Name FROM USER WHERE Name IN :salesName]) {
            userNameIdMap.put(u.Name, u.Id);
        }

        Id siteVisitRecordId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByName().get('Site Visit').getRecordTypeId();
        Map<Visitor_Registration__c, Customer_Registration__c> vistorSiteVisitMap = new Map<Visitor_Registration__c, Customer_Registration__c>(); 
        for(Visitor_Registration__c vr : visitRegList) {
            if(vr.Status__c != visitRegOldMap.get(vr.Id).Status__c && vr.Status__c == 'Accepted') {
                Customer_Registration__c cr = new Customer_Registration__c();
                cr.RecordTypeId = siteVisitRecordId;
                cr.Alternate_Email_Id__c =  vr.Alternate_Email_Id__c != null ? vr.Alternate_Email_Id__c : null; 
                cr.Email_Address__c =  vr.Email__c != null ? vr.Email__c : null; 
                cr.Alternate_Mobile_Number__c =  vr.Alternate_Mobile_Number__c != null ? vr.Alternate_Mobile_Number__c : null; 
                cr.Birth_Date__c =  vr.Birth_Date__c != null ? vr.Birth_Date__c : null; 
                cr.Indicative_Budget__c =  vr.Budget__c != null ? vr.Budget__c : null;  
                cr.Budget_in_cr__c =  vr.Budget__c != null ? vr.Budget__c : null;  
                cr.City__c =  vr.City__c != null ? vr.City__c : null; 
                cr.Date__c =  vr.Date__c != null ? Date.valueof(vr.Date__c) : null; 
                cr.Company_Business_Name__c =  vr.Company__c != null ? vr.Company__c : null; 
                cr.Designation__c =  vr.Designation__c != null ? vr.Designation__c : null; 
                cr.Last_Name__c =  vr.Last_Name__c != null ? vr.Last_Name__c : null; 
                cr.First_Name__c =  vr.First_Name__c != null ? vr.First_Name__c : null; 
                cr.Interested_in__c =  vr.Interested_in__c != null ? vr.Interested_in__c : null; 
                cr.Nationality__c =  vr.Nationality__c != null ? vr.Nationality__c : null; 
                cr.Mobile_Number__c =  vr.Mobile__c != null ? vr.Mobile__c : null; 
                cr.Address__c =  vr.Permanent_Address__c != null ? vr.Permanent_Address__c : null; 
                cr.Property_Type__c =  vr.Property_Type__c != null ? vr.Property_Type__c : null; 
                cr.Occupation__c =  vr.Occupation__c != null ? vr.Occupation__c : null; 
                cr.Broker_Contact__c =  vr.Broker_Contact__c != null ? vr.Broker_Contact__c : null; 
                cr.Possessiom_Timeline__c =  vr.Possession_Timeline__c != null ? vr.Possession_Timeline__c : null; 
                cr.Project1__c =  vr.Project1__c != null ? vr.Project1__c : null; 
                cr.Project_Name__c =  vr.Project_Name__c != null ? vr.Project_Name__c : null; 
                cr.Residential_Status__c =  vr.Residential_Status__c != null ? vr.Residential_Status__c : null; 
                cr.Purpose_Of_Purchase__c =  vr.Purpose_Of_Purchase__c != null ? vr.Purpose_Of_Purchase__c : null; 
                cr.Remarks__c =  vr.Remarks_if_any__c != null ? vr.Remarks_if_any__c : null; 
                cr.LeadSource__c =  vr.Source__c != null ? vr.Source__c : null; 
                cr.Source__c =  vr.Source__c != null ? vr.Source__c : null; 
                cr.DocumentId__c =  vr.DocumentId__c != null ? vr.DocumentId__c : null; 
                cr.Existing_Sobha_Owner__c =  vr.Existing_Sobha_Owner__c != null ? vr.Existing_Sobha_Owner__c : null; 
                cr.Unique_Id__c =  vr.Unique_Id__c != null ? vr.Unique_Id__c : null; 
                cr.Visiting_On_Behalf_Of__c =  vr.Visiting_On_Behalf_Of__c != null ? vr.Visiting_On_Behalf_Of__c : null; 
                cr.Status__c = 'Open'; 
                cr.Broker_Account__c =  vr.Broker_Account__c != null ? vr.Broker_Account__c : null; 
                if(vr.DocumentId__c != null && duplicatEnquiryCheckMap.containsKey(vr.DocumentId__c)) {
                    cr.Enquiry__c = duplicatEnquiryCheckMap.get(vr.DocumentId__c);
                }
                else if(vr.Mobile__c != null && VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Mobile__c) != null && duplicatEnquiryCheckMap.containsKey(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Mobile__c))) {
                    cr.Enquiry__c = duplicatEnquiryCheckMap.get(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Mobile__c));
                }
                else if(vr.Alternate_Mobile_Number__c != null && VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Alternate_Mobile_Number__c) != null && duplicatEnquiryCheckMap.containsKey(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Alternate_Mobile_Number__c))) {
                    cr.Enquiry__c = duplicatEnquiryCheckMap.get(VisitorRegestrationTriggerHandler.dividePrefixAndConvert(vr.Alternate_Mobile_Number__c));
                }
                else if(vr.Email__c != null &&  duplicatEnquiryCheckMap.containsKey(vr.Email__c)) {
                    cr.Enquiry__c = duplicatEnquiryCheckMap.get(vr.Email__c);
                }
                else if(vr.Alternate_Email_Id__c != null && duplicatEnquiryCheckMap.containsKey(vr.Alternate_Email_Id__c)) {
                    cr.Enquiry__c = duplicatEnquiryCheckMap.get(vr.Alternate_Email_Id__c);
                }
                cr.OwnerId = vr.Sales_Adviser__c != null && userNameIdMap.containsKey(vr.Sales_Adviser__c) ? userNameIdMap.get(vr.Sales_Adviser__c) : null;
                siteVisitToInsert.add(cr);
                vistorSiteVisitMap.put(vr, cr);
            }
        }
        if(!siteVisitToInsert.isEmpty()) {
            insert siteVisitToInsert;
        }
        for(Visitor_Registration__c vr : vistorSiteVisitMap.KeySet()) {
            vr.Site_Visit_Form__c = vistorSiteVisitMap.get(vr).Id;
            vrList.add(vr);
        }
        if(!vrList.isEmpty()) {
            VisitorRegestrationTriggerHandler.createFileOnSiteVisit(vrList);
        }
    }
    public static void createFileOnSiteVisit(List<Visitor_Registration__c> vrList) {
        Set<Id> contentDocId = new Set<Id>();
        Set<Id> parentId = new Set<Id>();
        Set<String> fileName = new Set<String>();
        for(Visitor_Registration__c vr: vrList) {
            parentId.add(vr.Id);
            fileName.add(vr.First_Name__c);
        }
        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId, ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN :parentId AND ContentDocument.title IN :fileName]) {
                                                    contentDocId.add(conDoc.contentdocumentId);
                                                }
        List<ContentVersion>  conVerList = [SELECT Id, ContentLocation, PathOnClient, Origin, Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocId];
        List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
        Map<String, Id> contentVersionIds = new Map<String, Id>();
        for(ContentVersion cv : conVerList) {
            contentVersionIds.put(cv.Title, cv.Id);
        }
        Map<Id, ContentVersion> contDocMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN :conVerList]);
        for(Visitor_Registration__c vr: vrList) {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contDocMap.get(contentVersionIds.get(vr.First_Name__c)).ContentDocumentId;
            contentDocumentLink.LinkedEntityId = vr.Site_Visit_Form__c; 
            contentDocumentLink.Visibility = 'AllUsers';
            contentDocumentLinksToInsert.add(contentDocumentLink);
        }
        if (!contentDocumentLinksToInsert.isEmpty()) {
            insert contentDocumentLinksToInsert;
        }
        // }                                       
    }
    public static void enquiryOnVisitor(List<Visitor_Registration__c> visitRegList, Map<Id,Visitor_Registration__c> visitRegOldMap) {
        Set<Id> vrId = new Set<Id>();
        Set<Id> siteVisitsId = new Set<Id>();
        for(Visitor_Registration__c vr : visitRegList) {
            if(vr.Site_Visit_Form__c != null && vr.Site_Visit_Form__c != visitRegOldMap.get(vr.Id).Site_Visit_Form__c) {
                vrId.add(vr.Id);
                siteVisitsId.add(vr.Site_Visit_Form__c);

            }
        }
        Map<Id, Customer_Registration__c> siteVisitMap = new Map<Id, Customer_Registration__c>([SELECT Id, Enquiry__c FROM Customer_Registration__c WHERE Enquiry__c != null AND Id IN :siteVisitsId]);
        List<Visitor_Registration__c> updateVistorReg = [SELECT Id, Site_Visit_Form__c, Enquiry__c FROM Visitor_Registration__c WHERE Id IN :vrId];
        for(Visitor_Registration__c vReg : updateVistorReg) {
            if(siteVisitMap.containsKey(vReg.Site_Visit_Form__c) && siteVisitMap.get(vReg.Site_Visit_Form__c).Enquiry__c != null) {
                vReg.Enquiry__c = siteVisitMap.get(vReg.Site_Visit_Form__c).Enquiry__c;
            }
        }
        if( !updateVistorReg.isEmpty()) {
            update updateVistorReg;
        }
    }

    
    public static String dividePrefixAndConvert(String originalNumber) {
        String rowData = '';
        String rowNumber = '';
        String preNumber = '';
        if(originalNumber.startswith('+')) {
            rowData = originalNumber.remove('+');
        } else {
            rowData = originalNumber;
        }
        if(rowData.length() > 10) {
            preNumber = rowData.left(rowData.length()-10);
            rowNumber = rowData.right(rowData.length()-preNumber.length());
        } else {
            rowNumber = rowData;
            preNumber = '';
        }
        if(originalNumber.startswith('+')) {
            preNumber = '+' + preNumber;
        }
        rowNumber = convertInBinary(rowNumber);
        if(!String.isBlank(preNumber)) {
            rowNumber = preNumber + '@@' + rowNumber;
        }
        return rowNumber;
    }
    public static String convertInBinary(String numberStr) {
        String lastCharacter = '';
        String startCharacter = '';
        String convertedString = '';
        Integer charLength = numberStr.length();
        if(charLength > 5) {
            lastCharacter = numberStr.right(5);
            startCharacter = numberStr.left(charLength - 5);
        } else {
            startCharacter = numberStr;
        }
        if(!String.isBlank(startCharacter)) {
            convertedString += numberToBinary(startCharacter);
        }
        if(!String.isBlank(lastCharacter)) {
            convertedString += '##' + numberToBinary(lastCharacter);
        }
        return convertedString;
    }
    public static String numberToBinary(String numberInString) {
        Integer finalNumber = Integer.valueof(numberInString);
        String convertedData = '';
        while(finalNumber > 0) {
            convertedData = ((Math.mod(finalNumber, 2)) == 0 ? '0' : '1') + convertedData;
            finalNumber = finalNumber/2;
        }
        convertedData = 'av$10' + convertedData + '0fd=1';
        return convertedData;
    }
}