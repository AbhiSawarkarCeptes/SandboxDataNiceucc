//only for booking object
public without sharing class DocumentVerificationController {
 
 @AuraEnabled
        public static List<FileDetails> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId,contentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :recordId
            AND (ContentDocument.Title LIKE '%Applicant%' or contentdocument.title ='Signed Booking Form')];
           List<Booking__c> bookingObj = [SELECT ID, booking_form_verified__c FROM Booking__c WHERE ID =: recordId];
            List<Applicant_Details__c> applicationDetails = [SELECT Type_Of_Applicant__c,Applicant_Number__c,Subtype_Of_Applicant__c,
            Visa_Copy__c,Passport_Copy__c,ID,National_Id_Verified__c,Non_Residency_Letter_Verified__c,Other_Documents_Verified__c,
            Passport_Copy_of_Authorized_Verified__c,Passport_Verified__c,Power_Of_Attorney_Verified__c,
            Registration_License_Verified__c,Visa_Copy_Verified__c,Certificate_of_Good_Standing_Verified__c,
            Certificate_Of_Incorporation_Verified__c,Emirates_Id_Verified__c,Memoradum_Articles_Verified__c,
            Emirates_ID_of_Authorized_Verified__c,Letter_of_undertaking_Verified__c,
            Visa_copy_of_Authorized_Verified__c,Trade_License_Verified__c ,Passport_Copy_Of_Attorney_Verified__c
            FROM Applicant_Details__c WHERE booking__c =: recordId];
            Map<String,Applicant_Details__c>   mapApplicationDetails = new Map<String,Applicant_Details__c>();
            for(Applicant_Details__c ad : applicationDetails){
                mapApplicationDetails.put(ad.Applicant_Number__c, ad);
            }
            Map<ID,boolean > fileIDs = new Map<ID,boolean>();
            for(String applicantType : mapApplicationDetails.keySet()){
                for (ContentDocumentLink docLink : files) {
                    if(!docLink.contentDocument.Title.contains('Expired') && docLink.contentDocument.Title.contains(applicantType)){
                        String fileName = docLink.contentDocument.Title;
                         if(fileName.contains('Passport Copy of Authorized Signatory') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Passport_Copy_of_Authorized_Verified__c );
                        } 
                        else if(fileName.contains('Passport Copy of Authorized Attorney') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Passport_Copy_Of_Attorney_Verified__c);
                        }
                       else if(fileName.contains('Passport Copy')){
                        fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Passport_Verified__c);
                        }
                         else if(fileName.contains('Power of Attorney') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Power_Of_Attorney_Verified__c);
                        }
                        else if(fileName.contains('Visa Copy of Authorized Signatory')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Visa_copy_of_Authorized_Verified__c);
                            
                        }
                        else if(fileName.contains('Visa Copy')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Visa_Copy_Verified__c);
                        }
                        else if(fileName.contains('Others')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Other_Documents_Verified__c);
                        }
                        else if(fileName.contains('Emirates Id') ){
                            fileIDs.put(docLink.ContentDocumentId, mapApplicationDetails.get(applicantType).Emirates_Id_Verified__c );
                        }
                        else if(fileName.contains('Non-residency Letter') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Non_Residency_Letter_Verified__c);
                        }
                        else if(fileName.contains('National Id') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).National_Id_Verified__c);
                        }
                        else if(fileName.contains('Registration License') ){
                           
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Registration_License_Verified__c);
                        }
                        
                        else if(fileName.contains('Memorandum') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Memoradum_Articles_Verified__c );
                        }
                        else if(fileName.contains('Certificate of Incorporation') ){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Certificate_Of_Incorporation_Verified__c );
                        }
                        else if(fileName.contains('Certificate of Good Standing and Certificate of Incumbency')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Certificate_of_Good_Standing_Verified__c);
                        }
                        else if(fileName.contains('Letter of undertaking')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Letter_of_undertaking_Verified__c);
                            
                        }else if(fileName.contains('Emirates ID of Authorized Signatory')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Emirates_ID_of_Authorized_Verified__c);
                        }    
                        else if(fileName.contains('Trade License')){
                            fileIDs.put(docLink.ContentDocumentId,mapApplicationDetails.get(applicantType).Trade_License_Verified__c);
                        }
                    }
                    if(!docLink.contentDocument.Title.contains('Expired')&& docLink.contentDocument.Title.contains('Signed Booking Form')) {
                        fileIDs.put(docLink.ContentDocumentId,bookingObj[0].booking_form_verified__c);
                    }
                }
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs.keySet()];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            List<FileDetails> wrapperList = new List<FileDetails>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
                FileDetails fd = new FileDetails();
                fd.docId = docLink.contentDocumentId;
                fd.doctitle = doclink.title;
                fd.verified = fileIDs.get(doclink.contentDocumentId);
                wrapperList.add(fd);
            }
            return wrapperList;
        }
        public class FileDetails{
            @AuraEnabled
            public String docId;
            @AuraEnabled
            public String doctitle;
            @AuraEnabled
            public boolean verified;


        }
        @AuraEnabled
        public static void verifyDocuments(List<String> verifiedFiles , String bookingId){
            try {
                 // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId,
            ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :bookingId
            AND (ContentDocument.Title LIKE '%Applicant%' or contentdocument.title ='Signed Booking Form')];
            List<ContentDocument> contentDocToUpdate = new List<ContentDocument>();
            for(ContentDocumentLink cdl : files){
                if(!verifiedFiles.contains(cdl.ContentDocument.title)){
                    contentDocToUpdate.add(new ContentDocument(id = cdl.contentDocumentId, title = cdl.ContentDocument.title + 'Expired'));
                }
            }
            update contentDocToUpdate;
            List<Applicant_Details__c> applicationDetails = [SELECT ID,Applicant_Number__c FROM Applicant_Details__c WHERE booking__c =: bookingId];
            Map<String,Applicant_Details__c> mapApplicationDetails = new Map<String,Applicant_Details__c>();
            for(Applicant_Details__c ad : applicationDetails){
                mapApplicationDetails.put(ad.Applicant_Number__c, ad);
            }
            Map<Id,Applicant_Details__c> mapOfApplicantDetailsToUpdate = new Map<Id,Applicant_Details__c>();
            if(verifiedFiles.size() == 0 || (verifiedFiles.size() == 1 && verifiedFiles[0] =='Signed Booking Form' )){
                update new booking__c(id= bookingId , booking_form_verified__c = true);
                for(Applicant_Details__c applicationDetailToUpdate : applicationDetails){
                   applicationDetailToUpdate.Passport_Verified__c = false;
                   applicationDetailToUpdate.Power_Of_Attorney_Verified__c = false;
                   applicationDetailToUpdate.Visa_Copy_Verified__c = false;
                   applicationDetailToUpdate.Other_Documents_Verified__c = false;
                   applicationDetailToUpdate.Emirates_Id_Verified__c = false;
                    applicationDetailToUpdate.Non_Residency_Letter_Verified__c = false;
                   applicationDetailToUpdate.National_Id_Verified__c = false;
                    applicationDetailToUpdate.Registration_License_Verified__c = false;
                     applicationDetailToUpdate.Passport_Copy_of_Authorized_Verified__c= false;
                    applicationDetailToUpdate.Memoradum_Articles_Verified__c = false;
                    
                     applicationDetailToUpdate.Certificate_Of_Incorporation_Verified__c = false;
                   applicationDetailToUpdate.Certificate_of_Good_Standing_Verified__c = false;
                   applicationDetailToUpdate.Passport_Uploaded__c = false;
                   applicationDetailToUpdate.Power_Of_Attorney_Uploaded__c = false;
                   applicationDetailToUpdate.Visa_Copy_Uploaded__c = false;
                   applicationDetailToUpdate.Other_Documents_Uploaded__c = false;
                   applicationDetailToUpdate.Emirates_Id_Uploaded__c = false;
                    applicationDetailToUpdate.Non_Residency_Letter_Uploaded__c = false;
                   applicationDetailToUpdate.National_Id_Uploaded__c = false;
                    applicationDetailToUpdate.Registration_License_Uploaded__c = false;
                     applicationDetailToUpdate.Passport_Copy_of_Authorized_Uploaded__c= false;
                    applicationDetailToUpdate.Memoradum_Articles_Uploaded__c= false;
                    
                     applicationDetailToUpdate.Certificate_Of_Incorporation_Uploaded__c = false;
                   applicationDetailToUpdate.Certificate_of_Good_Standing_Uploaded__c = false;
                   applicationDetailToUpdate.Letter_of_undertaking_Verified__c = false;
                   applicationDetailToUpdate.Emirates_ID_of_Authorized_Verified__c = false;
                   applicationDetailToUpdate.Visa_copy_of_Authorized_Verified__c = false;
                   applicationDetailToUpdate.Trade_License_Verified__c = false;
                   applicationDetailToUpdate.Passport_Copy_Of_Attorney_Verified__c = false;
                   applicationDetailToUpdate.Letter_of_undertaking_Uploaded__c = false;
                   applicationDetailToUpdate.Emirates_ID_of_Authorized_Uploaded__c = false;
                   applicationDetailToUpdate.Visa_copy_of_Authorized_Uploaded__c = false;
                   applicationDetailToUpdate.Trade_License_Uploaded__c = false;
                   applicationDetailToUpdate.Passport_Copy_Of_Attorney_Uploaded__c = false;
                   mapofApplicantDetailsToUpdate.put(applicationDetailToUpdate.id,applicationDetailToUpdate);

                }
            }
            boolean bookingDocVerified = false;
            for(String fileName :verifiedFiles){
                if(fileName == 'Signed Booking Form'){
                    bookingDocVerified  = true;
                    
                }
                Applicant_Details__c applicationDetailToUpdate = new Applicant_Details__c();
                if(fileName.contains('Primary Applicant')){
                    applicationDetailToUpdate = mapApplicationDetails.get('Primary Applicant');
                   
                }else if(fileName.contains('Second Applicant')){
                    applicationDetailToUpdate = mapApplicationDetails.get('Second Applicant');
                }else  if(fileName.contains('Third Applicant')){
                    applicationDetailToUpdate = mapApplicationDetails.get('Third Applicant');
                }else if(fileName.contains('Fourth Applicant')){
                    applicationDetailToUpdate = mapApplicationDetails.get('Fourth Applicant');
                }else  if(fileName.contains('Fifth Applicant')){
                    applicationDetailToUpdate = mapApplicationDetails.get('Fifth Applicant');
                }
                if(applicationDetailToUpdate.id != null){
                    if(mapOfApplicantDetailsToUpdate.get(applicationDetailToUpdate.Id) != null){
                        applicationDetailToUpdate = mapOfApplicantDetailsToUpdate.get(applicationDetailToUpdate.id);
                    }else{
                        applicationDetailToUpdate.Passport_Verified__c = false;
                        applicationDetailToUpdate.Power_Of_Attorney_Verified__c = false;
                        applicationDetailToUpdate.Visa_Copy_Verified__c = false;
                        applicationDetailToUpdate.Other_Documents_Verified__c = false;
                        applicationDetailToUpdate.Emirates_Id_Verified__c = false;
                         applicationDetailToUpdate.Non_Residency_Letter_Verified__c = false;
                        applicationDetailToUpdate.National_Id_Verified__c = false;
                         applicationDetailToUpdate.Registration_License_Verified__c = false;
                          applicationDetailToUpdate.Passport_Copy_of_Authorized_Verified__c= false;
                         applicationDetailToUpdate.Memoradum_Articles_Verified__c = false;
                         
                          applicationDetailToUpdate.Certificate_Of_Incorporation_Verified__c = false;
                        applicationDetailToUpdate.Certificate_of_Good_Standing_Verified__c = false;
                        applicationDetailToUpdate.Passport_Uploaded__c = false;
                        applicationDetailToUpdate.Power_Of_Attorney_Uploaded__c = false;
                        applicationDetailToUpdate.Visa_Copy_Uploaded__c = false;
                        applicationDetailToUpdate.Other_Documents_Uploaded__c = false;
                        applicationDetailToUpdate.Emirates_Id_Uploaded__c = false;
                         applicationDetailToUpdate.Non_Residency_Letter_Uploaded__c = false;
                        applicationDetailToUpdate.National_Id_Uploaded__c = false;
                         applicationDetailToUpdate.Registration_License_Uploaded__c = false;
                          applicationDetailToUpdate.Passport_Copy_of_Authorized_Uploaded__c= false;
                         applicationDetailToUpdate.Memoradum_Articles_Uploaded__c= false;
                         
                          applicationDetailToUpdate.Certificate_Of_Incorporation_Uploaded__c = false;
                        applicationDetailToUpdate.Certificate_of_Good_Standing_Uploaded__c = false;
                        applicationDetailToUpdate.Letter_of_undertaking_Verified__c = false;
                        applicationDetailToUpdate.Emirates_ID_of_Authorized_Verified__c = false;
                        applicationDetailToUpdate.Visa_copy_of_Authorized_Verified__c = false;
                        applicationDetailToUpdate.Trade_License_Verified__c = false;
                        applicationDetailToUpdate.Passport_Copy_Of_Attorney_Verified__c = false;
                        applicationDetailToUpdate.Letter_of_undertaking_Uploaded__c = false;
                        applicationDetailToUpdate.Emirates_ID_of_Authorized_Uploaded__c = false;
                        applicationDetailToUpdate.Visa_copy_of_Authorized_Uploaded__c = false;
                        applicationDetailToUpdate.Trade_License_Uploaded__c = false;
                        applicationDetailToUpdate.Passport_Copy_Of_Attorney_Uploaded__c = false;
                    }
                    if(fileName.contains('Passport Copy') && !fileName.contains('Passport Copy of Authorized Signatory')
                    &&  !fileName.contains('Passport Copy of Authorized Attorney')){
                        applicationDetailToUpdate.Passport_Verified__c = true;
                        applicationDetailToUpdate.Passport_Uploaded__c = true;
                        
                    }
                     if(fileName.contains('Power of Attorney')){
                        applicationDetailToUpdate.Power_Of_Attorney_Verified__c = true;
                        applicationDetailToUpdate.Power_Of_Attorney_Uploaded__c = true;
                    }
                     if(fileName.contains('Visa Copy') && !fileName.contains('Visa copy of Authorized Signatory')){
                        applicationDetailToUpdate.Visa_Copy_Verified__c = true;
                        applicationDetailToUpdate.Visa_Copy_Uploaded__c = true;
                    }
                    if(fileName.contains('Others')){
                        applicationDetailToUpdate.Other_Documents_Verified__c = true;
                        applicationDetailToUpdate.Other_Documents_Uploaded__c = true;
                    }
                     if(fileName.contains('Emirates Id')){
                        applicationDetailToUpdate.Emirates_Id_Verified__c = true;
                        applicationDetailToUpdate.Emirates_Id_Uploaded__c = true;
                    }
                     if(fileName.contains('Non-residency Letter')){
                        applicationDetailToUpdate.Non_Residency_Letter_Verified__c = true;
                        applicationDetailToUpdate.Non_Residency_Letter_Uploaded__c = true;
                    }
                     if(fileName.contains('National Id')){
                        applicationDetailToUpdate.National_Id_Verified__c = true;
                        applicationDetailToUpdate.National_Id_Uploaded__c = true;
                    }
                     if(fileName.contains('Registration License')){
                       
                        applicationDetailToUpdate.Registration_License_Verified__c = true;
                        applicationDetailToUpdate.Registration_License_Uploaded__c = true;
                    }
                    if(fileName.contains('Passport Copy of Authorized Signatory')){
                        applicationDetailToUpdate.Passport_Copy_of_Authorized_Verified__c= true;
                        applicationDetailToUpdate.Passport_Copy_of_Authorized_Uploaded__c= true;
                    }
                    if(fileName.contains('Passport Copy of Authorized Attorney')){
                        applicationDetailToUpdate.Passport_Copy_Of_Attorney_Uploaded__c= true;
                        applicationDetailToUpdate.Passport_Copy_Of_Attorney_Verified__c= true;
                    }
                    if(fileName.contains('Memorandum')){
                        applicationDetailToUpdate.Memoradum_Articles_Verified__c = true;
                        applicationDetailToUpdate.Memoradum_Articles_Uploaded__c = true;
                    }
                    if(fileName.contains('Certificate of Incorporation')){
                        applicationDetailToUpdate.Certificate_Of_Incorporation_Verified__c = true;
                        applicationDetailToUpdate.Certificate_Of_Incorporation_Uploaded__c = true;
                    }
                    if(fileName.contains('Certificate of Good Standing and Certificate of Incumbency')){
                        applicationDetailToUpdate.Certificate_of_Good_Standing_Verified__c = true;
                        applicationDetailToUpdate.Certificate_of_Good_Standing_Uploaded__c = true;
                    }
                    if(fileName.contains('Letter of undertaking')){
                        applicationDetailToUpdate.Letter_of_undertaking_uploaded__c = true;
                        applicationDetailToUpdate.Letter_of_undertaking_Verified__c = true;
                    }
                    if(fileName.contains('Emirates ID of Authorized Signatory')){
                        applicationDetailToUpdate.Emirates_ID_of_Authorized_Uploaded__c = true;
                        applicationDetailToUpdate.Emirates_ID_of_Authorized_Verified__c = true;
                    }
                    if(fileName.contains('Visa Copy of Authorized Signatory')){
                        applicationDetailToUpdate.Visa_copy_of_Authorized_Uploaded__c = true;
                        applicationDetailToUpdate.Visa_copy_of_Authorized_Verified__c = true;
                    }
                    
                    if(fileName.contains('Trade License')){
                        applicationDetailToUpdate.Trade_License_Uploaded__c = true;
                        applicationDetailToUpdate.Trade_License_Verified__c = true;
                    }
                   
                    mapofApplicantDetailsToUpdate.put(applicationDetailToUpdate.id,applicationDetailToUpdate);
                }
               
            }
            update new booking__c(id= bookingId , 	Booking_Form_Verified__c = bookingDocVerified,booking_form_uploaded__c= bookingDocVerified);
            update mapOfApplicantDetailsToUpdate.values();
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
}