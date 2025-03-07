public with sharing class DocumentUploadLWCController {
    
    @AuraEnabled 
    public static boolean updateBookings(List<Map<String, Object>> files,String recordId,String PreApprovalDate,String FinalOfferDate,String SignedMortgageDate,String NOCDate,String ManagersChequeDate,String PreApprovalEXDate,String FinalOfferEXDate,String SignedMortgageEXDate,String NOCEXDate,String ManagersChequeEXDate) {
        Boolean isSuccess = false;
        PropStrength__Application_Booking__c oneBook = [SELECT Id 
                                                        FROM PropStrength__Application_Booking__c 
                                                        WHERE Id =: recordId]; 
        system.debug('PreApprovalDate::'+PreApprovalDate);
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            if(relatedDocument.Title.contains('PRE-APPROVAL DOCUMENT')) {
                oneBook.Pre_Approval_letter_Uploaded__c = true;
            }
            if(!String.isBlank(PreApprovalDate)) {
                oneBook.Pre_Approval_letter_Receipt_Date__c = Date.valueOf(PreApprovalDate);
            }
            if(!String.isBlank(PreApprovalEXDate)) {
                oneBook.Pre_Approval_letter_Expiry_Date__c = Date.valueOf(PreApprovalEXDate);
            }
            if(relatedDocument.Title.contains('FINAL OFFER DOCUMENT')) {
                oneBook.Final_Offer_letter_Uploaded__c = true;
            }
            if(!String.isBlank(FinalOfferDate)) {
                oneBook.Final_Offer_letter_Receipt_Date__c = Date.valueOf(FinalOfferDate);
            }
            if(!String.isBlank(FinalOfferEXDate)) {
                oneBook.Final_Offer_letter_Expiry_Date__c = Date.valueOf(FinalOfferEXDate);
            }
            
            if(relatedDocument.Title.contains('SIGN MORTGAGE CONTRACT DOCUMENT')) {
                oneBook.Signed_Mortgage_Contract_Uploaded__c = true;
            }
            if(!String.isBlank(SignedMortgageDate)) {
                oneBook.Signed_Mortgage_Contract_Receipt_Date__c = Date.valueOf(SignedMortgageDate);
            }
            if(!String.isBlank(SignedMortgageEXDate)) {
                oneBook.Signed_Mortgage_Contract_Expiry_Date__c = Date.valueOf(SignedMortgageEXDate);
            }
            
            if(relatedDocument.Title.contains('NOC FROM BANK DOCUMENT')) {
                oneBook.NOC_from_Bank_Uploaded__c = true;
            }
            if(!String.isBlank(NOCDate)) {
                oneBook.NOC_from_Bank_Receipt_Date__c = Date.valueOf(NOCDate);
            }
            if(!String.isBlank(NOCEXDate)) {
                oneBook.NOC_from_Bank_Expiry_Date__c = Date.valueOf(NOCEXDate);
            }
        
            if(relatedDocument.Title.contains('COPY OF THE MANAGER\'S CHEQUE DOCUMENT')) {
                oneBook.Copy_of_the_Manager_s_Cheque_Uploaded__c = true;
            }
            if(!String.isBlank(ManagersChequeDate)) {
                oneBook.Copy_of_the_Managers_Cheque_Receipt_Date__c = Date.valueOf(ManagersChequeDate);
            }
            if(!String.isBlank(ManagersChequeEXDate)) {
                oneBook.Copy_of_the_Manager_s_Cheque_Expiry_Date__c = Date.valueOf(ManagersChequeEXDate);
            }
        }
        if(oneBook.Id != null) {
            onebook.Mortgage_Case__c = true;
            update oneBook; 
            isSuccess = true;
        } else {
            isSuccess = false;
        }
        return isSuccess;
    } 
    
    @AuraEnabled
    public static boolean uploadFiles(List<Map<String, Object>> files,String selectedBooking){
        Boolean isSuccess = false;
        List<Attachment> relatedDocuments = new List<Attachment>();
        for (Map<String, Object> file : files) {
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            Attachment cv = new Attachment();
            cv.parentId = selectedBooking;
            cv.Name = relatedDocument.Title;
            cv.Body = relatedDocument.VersionData;
            relatedDocuments.add(cv);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        for (Database.SaveResult saveResult : srFiles) {
            isSuccess = saveResult.isSuccess();
        }
        return isSuccess;
    }
    
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
}