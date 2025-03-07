public class SiniyaPartnerController {
    @AuraEnabled
    public static Account AccountClone(Id recordId){
        system.debug('recordId'+recordId);
        Account OriginalAccount = [SELECT Name, RecordTypeId, Name_Change_Details_of_the_Broker__c, Name_as_per_trade_license__c,PropStrength__Broker_Type__c,
                                   Broker_Type__pc,Broker_Sub_Type__c,Broker_Category__c,PropStrength__Broker_Code__c,Broker_Created_Date__c,PropStrength__Broker_Approval_Status__c,
                                   Company_Registered_In__c,Registration_Link_Expiry_Date_Time__c,Registration_Number__c,Registration_Date__c,VAT_Registration_Status__c,
                                   RERA_Number__pc,RERA_Number__c,Creation_Date__c,Al_Siniya_Partner__c,
                                   Comments__c,Name_as_per_passport__c,Designation__pc,Designation1__c,Designation__c,Nationality__pc,PropStrength__Nationality__pc,Nationality__c,
                                   Country_Code__c,Phone,CLE__Phone_Encrypted__pc,VCC1__Phone_Encrypted__pc,Phone__c,Fax,Fax_correspondence__c,Fax_Permanent__c,Fax_Local__c,
                                   Office_No__c,Mobile_No__c,Alternate_Mobile_No__c,Email__c,Account_Owner_Email__c,Email_ID_2__c,BillingAddress,Villa_Building_name__c,
                                   Office_Apartment_number__c,City__pc,City__c,City_Permanent__c,City_Local__c,Street_name__c,Country_CP__c,Zip_Postal_Code_CP__c,
                                   CHRM_s_Email__c,Channel_Relationship_Manager__pc,Channel_Relationship_Manager__c,Channel_Relationship_Head__pc,
                                   Channel_Relationship_Head__c,Sales_Manager_User__c,Sales_Manager__pc,Sales_Manager__c,Sales_Director__c,OwnerId,
                                   Email_ID_1__c
                                   FROM Account WHERE Id =: recordId];
        system.debug('recordId'+OriginalAccount);
        Account clonedAccount = originalAccount.clone(false, true);
        clonedAccount.Al_Siniya_Partner__c = true;
        clonedAccount.PropStrength__Broker_Approval_Status__c = 'Broker Registration Done';
        clonedAccount.Registration_Date__c = system.today();
        clonedAccount.Broker_Created_Date__c = system.today();
        insert clonedAccount;
        system.debug('recordId'+clonedAccount);
        Set<Id> brokerDocumentSet =  new Set<Id>();
        List<BR_Document_History__c> brDocumentList = new List<BR_Document_History__c>();
        For(BR_Document_History__c br : [SELECT ID,File_Name__c,File_Type__c FROM BR_Document_History__c where Broker_Account__c =: recordId]){
            BR_Document_History__c brClone = new BR_Document_History__c(Broker_Account__c = clonedAccount.Id, File_Name__c = br.File_Name__c,File_Type__c = br.File_Type__c );
            Insert brClone;
            transferFiles(br.Id,brClone.Id);
        }
        transferFilesNotesAttachment(recordId,clonedAccount.Id);
        Account accPar = new Account(Id = recordId, Siniya_Created__c= true);
        UPDATE accPar;
        return clonedAccount;
    }
    
    public static void transferFiles(Id sourceRecordId, Id destinationRecordId) {
        List<ContentDocumentLink> sourceFiles = [
            SELECT Id, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :sourceRecordId
        ];
        
        if (sourceFiles.isEmpty()) {
            return;
        }
        
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink fileLink : sourceFiles) {
            newLinks.add(new ContentDocumentLink(
                ContentDocumentId = fileLink.ContentDocumentId,
                LinkedEntityId = destinationRecordId,
                ShareType = 'V', // V = Viewer, I = Collaborator, C = Set by Author
                Visibility = 'AllUsers'
            ));
        }
        
        insert newLinks;        
    }
    
    
    public static void transferFilesNotesAttachment(Id sourceRecordId, Id destinationRecordId) {
        List<ContentDocumentLink> sourceFiles = [
            SELECT Id, ContentDocumentId ,ContentDocument.Title
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :sourceRecordId
        ];
        
        if (sourceFiles.isEmpty()) {
            return;
        }
        
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink fileLink : sourceFiles) {
            if(!fileLink.ContentDocument.Title.StartsWith('Agreement') && !fileLink.ContentDocument.Title.StartsWith('NOC') && !fileLink.ContentDocument.Title.StartsWith('CertificateOfCompletion')){
            newLinks.add(new ContentDocumentLink(
                ContentDocumentId = fileLink.ContentDocumentId,
                LinkedEntityId = destinationRecordId,
                ShareType = 'V', // V = Viewer, I = Collaborator, C = Set by Author
                Visibility = 'AllUsers'
            ));
        }
        }
        insert newLinks;        
    }
    
}