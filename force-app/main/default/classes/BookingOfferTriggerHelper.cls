public class BookingOfferTriggerHelper {
    public static void updateSbtrFields(List<Booking_Offers__c> bookOfferList, Map<Id, Booking_Offers__c> oldBookOfferMap) {
        Set<Id> BookingIds = new Set<Id>();
        Map<Id, SBTR__c> sbtrToUpdate = new Map<Id, SBTR__c>();
        for(Booking_Offers__c bo : bookOfferList) {
            if(bo.Application_Booking__c != null && 
               (oldBookOfferMap == null || 
                (oldBookOfferMap != null && 
                 (bo.Application_Booking__c != oldBookOfferMap.get(bo.Id).Application_Booking__c || bo.Offer__c != oldBookOfferMap.get(bo.Id).Offer__c)))) {
                     BookingIds.add(bo.Application_Booking__c);
                 }
        }
        if(!BookingIds.isEmpty()) {
            //, (SELECT Id, Booking_Offers__c FROM SBTRs1__r)
           List<PropStrength__Application_Booking__c> bookList = [SELECT Id, PropStrength__Offer__c, (SELECT Id, Name, Offer__c, Offer__r.Name, Application_Booking__c FROM Booking_Offers__r WHERE Offer__c != null) FROM PropStrength__Application_Booking__c WHERE Id In :BookingIds];
            for(PropStrength__Application_Booking__c book : bookList) {
                String bookOffer = '';
                for(Booking_Offers__c rec : book.Booking_Offers__r) {
                    if(bookOffer ==''){
                        bookOffer = rec.Name+' = '+ rec.Offer__r.Name;
                    } 
                    else {
                        bookOffer = bookOffer+'\n'+rec.Name+' = '+ rec.Offer__r.Name;
                    }
                }
                /*for(SBTR__C sbtr : book.SBTRs1__r) {
                    sbtrToUpdate.put(sbtr.Id, new SBTR__c(Id = sbtr.Id, Booking_Offers__c = bookOffer));
                }*/
            }
            if(!sbtrToUpdate.values().isEmpty()) {
                //update sbtrToUpdate.values();
            }
        }
    }
}