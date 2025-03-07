public class allOfferTriggerHelper{
    public static Boolean runOne = true;
    
    public static void errorMsg(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> newOfferMap) {
        Set<Id> prIds = new Set<Id>();
        Map<Id, Id> propertyMap = new Map<Id, Id>();
        
        for (PropStrength__Offer__c offer : newOfferList) {
            if (offer.Payment_Request_1__c != null) {
                prIds.add(offer.Payment_Request_1__c);
            }
        }
        
        System.debug('prIds::' + prIds);
        
        if (!prIds.isEmpty()) {
            List<Payment_Request__c> prList = [SELECT Id, Property__c FROM Payment_Request__c WHERE Id IN :prIds];
            
            if (!prList.isEmpty()) {
                for (Payment_Request__c pr : prList) {
                    propertyMap.put(pr.Property__c, pr.Id);
                }
                
                System.debug('propertyMap::' + propertyMap);
                
                if (!propertyMap.isEmpty()) {
                    for (PropStrength__Offer__c offer : newOfferList) {
                        if (!propertyMap.containsKey(offer.PropStrength__Property__c)) {
                           // offer.addError('Please tag correct PR');
                        }
                    }
                }
            }
        }
    }

    //Added by deepak sharma to update count of offer on Advertisement object on 21 Jun 2023
    public static void updateCountOnAdvtMarket(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> newOfferMap, String eventOccur) {
        List<PropStrength__Offer__c> offerList = [SELECT Id, PropStrength__Advertisement__c, PropStrength__Request__c, PropStrength__Advertisement__r.Marketing_Channel__c, PropStrength__Advertisement__r.Total_Offer_Count__c, PropStrength__Advertisement__r.Marketing_Channel__r.Total_Offer_Count__c, PropStrength__Request__r.PropStrength__Advertisement__c, PropStrength__Request__r.PropStrength__Advertisement__r.Marketing_Channel__c, PropStrength__Request__r.PropStrength__Advertisement__r.Total_Offer_Count__c, PropStrength__Request__r.PropStrength__Advertisement__r.Marketing_Channel__r.Total_Offer_Count__c FROM PropStrength__Offer__c WHERE Id IN :newOfferMap.keySet()];
        
        if(eventOccur == 'Insert') {
            Set<Id> enqIds = new Set<Id>();
            Map<Id, PropStrength__Advertisement__c> updAdvertisement = new Map<Id, PropStrength__Advertisement__c>();
            
            for(PropStrength__Offer__c offer : newOfferList) {
                if(offer.PropStrength__Request__c != null) {
                    enqIds.add(offer.PropStrength__Request__c);
                }
            }
            
            if(!enqIds.isEmpty()) {
                Map<Id, PropStrength__Request__c> enquiryMap = new Map<Id, PropStrength__Request__c>([SELECT Id, (SELECT Id FROM PropStrength__Offers__r) FROM PropStrength__Request__c WHERE Id IN :enqIds]);
                if(!enquiryMap.isEmpty()) {
                    for(PropStrength__Offer__c offer : offerList) {
                        if(offer.PropStrength__Request__c != null && enquiryMap.containsKey(offer.PropStrength__Request__c) && offer.PropStrength__Request__r.PropStrength__Advertisement__c != null) {
                            if(!updAdvertisement.containsKey(offer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                                updAdvertisement.put(offer.PropStrength__Request__r.PropStrength__Advertisement__c, new PropStrength__Advertisement__c(Id = offer.PropStrength__Request__r.PropStrength__Advertisement__c, Total_Offer_Count__c = enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Offers__r.size()));
                            } 
                        }
                    }
                    if(!updAdvertisement.values().isEmpty()) {
                        update updAdvertisement.values();
                    } 
                }
            }           
        }
        
        if(eventOccur == 'Delete') {
            Map<Id, Decimal> updAdvt = new Map<Id, Decimal>();
            for(PropStrength__Offer__c offer : offerList) {
                if(offer.PropStrength__Request__c != null && offer.PropStrength__Request__r.PropStrength__Advertisement__c != null) {
                    Decimal advtCount = (offer.PropStrength__Request__r.PropStrength__Advertisement__r.Total_Offer_Count__c != null ? offer.PropStrength__Request__r.PropStrength__Advertisement__r.Total_Offer_Count__c - 1 : null);
                    if(updAdvt.containsKey(offer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                        advtCount = updAdvt.get(offer.PropStrength__Request__r.PropStrength__Advertisement__c) - 1;
                        updAdvt.remove(offer.PropStrength__Request__r.PropStrength__Advertisement__c);
                    } 
                    if(offer.PropStrength__Request__r.PropStrength__Advertisement__c != null) {
                        updAdvt.put(offer.PropStrength__Request__r.PropStrength__Advertisement__c, advtCount);
                    }
                } 
            }
            
            if(!updAdvt.isEmpty()) {
                Map<Id, PropStrength__Advertisement__c> advtMap = new Map<Id, PropStrength__Advertisement__c>([SELECT Id, (SELECT Id FROM PropStrength__Enquiry__r) FROM PropStrength__Advertisement__c WHERE Id IN :updAdvt.keySet()]);
                Map<Id, Decimal> totBookCnt = new Map<Id, Decimal>();

                Set<Id> enqIds = new Set<Id>();
                for(PropStrength__Advertisement__c advt : advtMap.values()) {
                    if(!advt.PropStrength__Enquiry__r.isEmpty()) {
                        for(PropStrength__Request__c en : advt.PropStrength__Enquiry__r) {
                            enqIds.add(en.Id);
                        }
                    }
                }
                if(!enqIds.isEmpty()) {
                    Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Offers__r) FROM PropStrength__Request__c WHERE Id IN :enqIds]);
                    if(!enqMap.isEmpty()) {
                        Set<Id> offIds = new Set<Id>();
                        for(PropStrength__Request__c enq : enqMap.values()) {
                                if(!enq.PropStrength__Offers__r.isEmpty()) {
                                    for(PropStrength__Offer__c offer : enq.PropStrength__Offers__r) {
                                        offIds.add(offer.Id);
                                    }
                                }
                        }
                        if(!offIds.isEmpty()) {
                            Map<Id, PropStrength__Offer__c> offMaps = new Map<Id, PropStrength__Offer__c>([SELECT Id, PropStrength__Request__c, PropStrength__Request__r.PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM PropStrength__Offer__c WHERE Id IN :offIds]);
                            if(!offMaps.isEmpty()) {
                                for(PropStrength__Offer__c ofer : offMaps.values()) {
                                    if(!newOfferMap.containsKey(ofer.Id)) {
                                        Decimal count = ofer.PropStrength__Applications_Bookings__r.size();
                                        if(ofer.PropStrength__Request__c != null && ofer.PropStrength__Request__r.PropStrength__Advertisement__c != null && totBookCnt.containsKey(ofer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                                            count += totBookCnt.get(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                            totBookCnt.remove(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                        }
                                        totBookCnt.put(ofer.PropStrength__Request__r.PropStrength__Advertisement__c, count);
                                    }
                                }
                            }
                        }
                    }
                }
                System.debug('totBookCnt**'+totBookCnt);
                System.debug('advtMap**'+advtMap);
                System.debug('updAdvt.keySet()**'+updAdvt.keySet());

                List<PropStrength__Advertisement__c> updateAdvertisement = new List<PropStrength__Advertisement__c>();
                for(Id advtId : updAdvt.keySet()) {
                    PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = advtId);
                    Boolean flag = FALSE;
                    if(advtMap.containsKey(advtId)) {
                        tempAdvt.Total_Offer_Count__c = updAdvt.get(advtId);
                        flag = TRUE;
                    }
                    if(totBookCnt.containsKey(advtId)) {
                        tempAdvt.Total_Booking_Count__c = totBookCnt.get(advtId);
                        flag = TRUE;
                    }
                    if(flag) {
                        updateAdvertisement.add(tempAdvt);
                    }
                }
                
                if(!updateAdvertisement.isEmpty()) {
                    update updateAdvertisement;
                }
            }
        }
    }

    //Added by deepak sharma to update count of offer on Advertisement object on 21 Jun 2023
    public static void updateCountOnAdvtMarketOnUp(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> enquiryIds = new Set<Id>();
        List<PropStrength__Advertisement__c> updateAdvtList = new List<PropStrength__Advertisement__c>();

        for(PropStrength__Offer__c offer : newOfferList) {
            if(oldOfferMap.get(offer.Id).PropStrength__Request__c != offer.PropStrength__Request__c) {
                if(oldOfferMap.get(offer.Id).PropStrength__Request__c != null) {
                    enquiryIds.add(oldOfferMap.get(offer.Id).PropStrength__Request__c);
                }
                if(offer.PropStrength__Request__c != null) {
                    enquiryIds.add(offer.PropStrength__Request__c);
                }
            }
        }

        System.debug('enquiryIds---'+enquiryIds);

        if(!enquiryIds.isEmpty()) {
            Map<Id, PropStrength__Request__c> enquiryMap = new Map<Id, PropStrength__Request__c>([SELECT Id, PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Offers__r) FROM PropStrength__Request__c WHERE Id IN :enquiryIds]);
            Map<Id, Decimal> totBookCnt = new Map<Id, Decimal>();
            if(!enquiryMap.isEmpty()) {
                Set<Id> offIds = new Set<Id>();
                for(PropStrength__Request__c enq : enquiryMap.values()) {
                    if(!enq.PropStrength__Offers__r.isEmpty()) {
                        for(PropStrength__Offer__c offer : enq.PropStrength__Offers__r) {
                            offIds.add(offer.Id);
                        }
                    }
                }
                if(!offIds.isEmpty()) {
                    Map<Id, PropStrength__Offer__c> offMaps = new Map<Id, PropStrength__Offer__c>([SELECT Id, PropStrength__Request__c, PropStrength__Request__r.PropStrength__Advertisement__c, (SELECT Id FROM PropStrength__Applications_Bookings__r) FROM PropStrength__Offer__c WHERE Id IN :offIds]);
                    if(!offMaps.isEmpty()) {
                        for(PropStrength__Offer__c ofer : offMaps.values()) {
                            Decimal count = ofer.PropStrength__Applications_Bookings__r.size();
                            if(ofer.PropStrength__Request__c != null && ofer.PropStrength__Request__r.PropStrength__Advertisement__c != null && totBookCnt.containsKey(ofer.PropStrength__Request__r.PropStrength__Advertisement__c)) {
                                count += totBookCnt.get(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                                totBookCnt.remove(ofer.PropStrength__Request__r.PropStrength__Advertisement__c);
                            }
                            totBookCnt.put(ofer.PropStrength__Request__r.PropStrength__Advertisement__c, count);
                        }
                    }
                }
            }

            for(PropStrength__Offer__c offer : newOfferList) {
                if(oldOfferMap.get(offer.Id).PropStrength__Request__c != offer.PropStrength__Request__c) {
                    if(oldOfferMap.get(offer.Id).PropStrength__Request__c != null && enquiryMap.get(oldOfferMap.get(offer.Id).PropStrength__Request__c).PropStrength__Advertisement__c != null) {
                        PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = enquiryMap.get(oldOfferMap.get(offer.Id).PropStrength__Request__c).PropStrength__Advertisement__c);
                        Boolean flag = FALSE;
                        if(enquiryMap.containsKey(oldOfferMap.get(offer.Id).PropStrength__Request__c)) {
                            tempAdvt.Total_Offer_Count__c=enquiryMap.get(oldOfferMap.get(offer.Id).PropStrength__Request__c).PropStrength__Offers__r.size();
                            flag = TRUE;
                        }
                        if(totBookCnt.containsKey(oldOfferMap.get(offer.Id).PropStrength__Advertisement__c)) {
                            tempAdvt.Total_Booking_Count__c = totBookCnt.get(oldOfferMap.get(offer.Id).PropStrength__Advertisement__c);
                            flag = TRUE;
                        }
                        if(flag) {
                            updateAdvtList.add(tempAdvt);
                        }
                    }
                }
                if(offer.PropStrength__Request__c != null && enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Advertisement__c != null) {
                    PropStrength__Advertisement__c tempAdvt = new PropStrength__Advertisement__c(Id = enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Advertisement__c);
                    Boolean flag = FALSE;
                    if(enquiryMap.containsKey(offer.PropStrength__Request__c)) {
                        tempAdvt.Total_Offer_Count__c=enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Offers__r.size();
                    }
                    if(totBookCnt.containsKey(enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Advertisement__c)) {
                        tempAdvt.Total_Booking_Count__c = totBookCnt.get(enquiryMap.get(offer.PropStrength__Request__c).PropStrength__Advertisement__c);
                        flag = TRUE;
                    }
                    if(flag) {
                        updateAdvtList.add(tempAdvt);
                    }
                }
            }
            System.debug('updateAdvtList---'+updateAdvtList);
            if(!updateAdvtList.isEmpty()) {
                update updateAdvtList;
            }
        }
    }

    public static boolean runOnce() {
        if(runOne) {
            runOne = false;
            return true;
        } else {
            return runOne;
        }
    }
}