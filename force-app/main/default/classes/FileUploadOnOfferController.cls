public class FileUploadOnOfferController {

    @AuraEnabled
    public static void updateOfferFields(String offerId, String uplodDocName){
        PropStrength__Offer__c offerRec = new 	PropStrength__Offer__c();
        offerRec.Id = offerId;
        if(uplodDocName == 'Passport'){
            offerRec.Passport_Uploaded__c = true;
        }
        if(uplodDocName == 'Emirates'){
            offerRec.Emirates_ID_Uploaded__c = true;
        }
        if(uplodDocName == 'Visa'){
            offerRec.Visa_Uploaded__c = true;
        }
        update offerRec;
    }
}