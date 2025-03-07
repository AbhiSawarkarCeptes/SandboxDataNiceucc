public with sharing class DocumentUploadLWCCopyController {
    
    @AuraEnabled 
    public static String updateKYCCheckList(String selOff,String resSta,String appTy) {
        KYC_Documents__c kyc = new KYC_Documents__c();
        if(!String.isBlank(selOff)) {
            kyc.Offer__c = selOff;
        }
        if(!String.isBlank(resSta)) {
            kyc.Residential_Status__c = resSta;
        }
        if(!String.isBlank(appTy)) {
            kyc.Applicant_Type__c = appTy;
        }
        Database.saveResult[] srFiles = Database.insert(new List<KYC_Documents__c>{kyc});
        for (Database.SaveResult saveResult : srFiles) {
            return kyc.Id;
        }
        return 'Fail';
    } 
    
    @AuraEnabled
    public static String uploadFiles(List<Map<String, Object>> files,String kycRecordId){
        KYC_Documents__c kycRec = [SELECT Id, Residential_Status__c FROM KYC_Documents__c WHERE Id = :kycRecordId];
        if(kycRec.Residential_Status__c == 'Resident') {
            Boolean flag = false;
            for (Map<String, Object> file : files) {
                String fileJson = JSON.serialize(file);
                relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                if(relatedDocument.Title.contains('Emirates')) {
                    flag = true;
                    break;
                }
            }

            if(!flag) {
                delete new KYC_Documents__c(Id=kycRecordId);
                return 'Please Upload EMIRATES ID Document';
            }

        } else if(kycRec.Residential_Status__c == 'Non-Resident') {
            Boolean flag = false;
            for (Map<String, Object> file : files) {
                String fileJson = JSON.serialize(file);
                relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
                if(relatedDocument.Title.contains('National')) {
                    flag = true;
                    break;
                }
            }

            if(!flag) {
                delete new KYC_Documents__c(Id=kycRecordId);
                return 'Please Upload NATIONAL ID (NON-RESIDENTS) Document';
            }
        }

        Boolean isSuccess = false;
        List<Attachment> relatedDocuments = new List<Attachment>();
        Id offerId = [SELECT Id, Offer__c FROM KYC_Documents__c WHERE Id = :kycRecordId].Offer__c;
        KYC_Documents__c kyc = new KYC_Documents__c(Id=kycRecordId);
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            Attachment cv = new Attachment();
            cv.parentId = kycRecordId;
            cv.Name = relatedDocument.Title;
            cv.Body = relatedDocument.VersionData;
            relatedDocuments.add(cv);

            if(relatedDocument.Title.contains('Passport')) {
                kyc.Passport__c = true;
            }
            if(relatedDocument.Title.contains('Emirates')) {
                kyc.Emirates_ID__c = true;
            }
            if(relatedDocument.Title.contains('National')) {
                kyc.National_ID_Non_Residents__c = true;
            }
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
            update kyc;
            
            PropStrength__Offer__c offer = new PropStrength__Offer__c(Id = offerId, KYC_Uploaded__c = true);
            update offer;
        }
        return String.valueOf(isSuccess);
    }
    
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
}