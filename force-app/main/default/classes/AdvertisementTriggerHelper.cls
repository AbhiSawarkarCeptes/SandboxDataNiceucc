/*********************************************************************
 * Class Name  :   AdvertisementTriggerHelper
 * Description :   Helper Class For AdvertisementTrigger
 * Created Date:   24/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 24/07/2023
 *********************************************************************/
public class AdvertisementTriggerHelper {
    public static void showErrorAmtCheck(List<PropStrength__Advertisement__c> advRecList) {
        Set<Id> marketingChannelIds = new Set<Id>();
        for(PropStrength__Advertisement__c adv : advRecList) {
            if(adv.Marketing_Channel__c != null) {
                marketingChannelIds.add(adv.Marketing_Channel__c);
            }
        }
        
        if(!marketingChannelIds.isEmpty()) {
            Map<Id, Marketing_Channel__c> marketingChannelMap = new Map<Id, Marketing_Channel__c>([SELECT Id, Budget_Allotted__c, Start_Date__c, End_Date__c, (SELECT Id, PropStrength__Budgeted_Cost__c FROM Advertisements__r) FROM Marketing_Channel__c WHERE Id IN :marketingChannelIds]);
            if(!marketingChannelMap.isEmpty()) {
                Map<Id, Marketing_Channel__c> updMarketChannelMap = new Map<Id, Marketing_Channel__c>();
                for(PropStrength__Advertisement__c adv : advRecList) {
                    if(adv.Marketing_Channel__c != null && marketingChannelMap.containsKey(adv.Marketing_Channel__c)) {
                        Decimal totalBudgetInvested = adv.PropStrength__Budgeted_Cost__c;
                        List<PropStrength__Advertisement__c> alreadyPresentAdvt = marketingChannelMap.get(adv.Marketing_Channel__c).Advertisements__r;
                        if(!alreadyPresentAdvt.isEmpty()) {
                            for(PropStrength__Advertisement__c ad : alreadyPresentAdvt) {
                                totalBudgetInvested += ad.PropStrength__Budgeted_Cost__c;
                            }
                        }
                        if(adv.PropStrength__Start_Date__c != null && adv.PropStrength__End_Date__c != null && adv.PropStrength__Start_Date__c > adv.PropStrength__End_Date__c) {
                            adv.addError('Start Date can\'t be greather than End Date');
                        }
                        if(adv.PropStrength__Start_Date__c != null && adv.PropStrength__End_Date__c != null && adv.PropStrength__End_Date__c < adv.PropStrength__Start_Date__c) {
                            adv.addError('End Date can\'t be less than Start Date');
                        }
                        if(adv.PropStrength__Start_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c != null && adv.PropStrength__Start_Date__c < marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c) {
                            adv.addError('Start Date can\'t be less than ' + marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c.format());
                        }
                        if(adv.PropStrength__End_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c != null && adv.PropStrength__End_Date__c > marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c) {
                            adv.addError('End Date can\'t be greater than ' + marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c.format());
                        }
                        if(adv.PropStrength__Start_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c != null && adv.PropStrength__Start_Date__c > marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c) {
                            adv.addError('Start Date can\'t be greater than ' + marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c.format());
                        }
                        if(adv.PropStrength__End_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c != null && adv.PropStrength__End_Date__c < marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c) {
                            adv.addError('End Date can\'t be less than ' + marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c.format());
                        }
                        if(totalBudgetInvested > marketingChannelMap.get(adv.Marketing_Channel__c).Budget_Allotted__c) {
                            adv.addError('Budget Cost Value is exceeding the Budget Alloted Value');
                        }
                        // else if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && !updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                        //     updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        // } else if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                        //     totalBudgetInvested += updMarketChannelMap.get(marketingChannelMap.get(adv.Marketing_Channel__c).Id).Budget_Utilization_Till_Date__c;
                        //     updMarketChannelMap.remove(marketingChannelMap.get(adv.Marketing_Channel__c).Id);
                        //     updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        // }
                    }
                }
                if(!updMarketChannelMap.isEmpty()) {
                    update updMarketChannelMap.values();
                }
            }
        }
    }

    public static void showErrorAmtCheckOnUpd(List<PropStrength__Advertisement__c> advRecList, Map<Id, PropStrength__Advertisement__c> advRecMap) {
        Set<Id> marketingChannelIds = new Set<Id>();
        for(PropStrength__Advertisement__c adv : advRecList) {
            if(adv.Marketing_Channel__c != null) {
                marketingChannelIds.add(adv.Marketing_Channel__c);
            }
        }
        
        if(!marketingChannelIds.isEmpty()) {
            Map<Id, Marketing_Channel__c> marketingChannelMap = new Map<Id, Marketing_Channel__c>([SELECT Id, Budget_Allotted__c, Start_Date__c, End_Date__c, (SELECT Id, PropStrength__Budgeted_Cost__c FROM Advertisements__r) FROM Marketing_Channel__c WHERE Id IN :marketingChannelIds]);
            if(!marketingChannelMap.isEmpty()) {
                Map<Id, Marketing_Channel__c> updMarketChannelMap = new Map<Id, Marketing_Channel__c>();
                for(PropStrength__Advertisement__c adv : advRecList) {
                    if(adv.Marketing_Channel__c != null && marketingChannelMap.containsKey(adv.Marketing_Channel__c)) {
                        Decimal totalBudgetInvested = adv.PropStrength__Budgeted_Cost__c != null ? adv.PropStrength__Budgeted_Cost__c : 0.00;
                        List<PropStrength__Advertisement__c> alreadyPresentAdvt = marketingChannelMap.get(adv.Marketing_Channel__c).Advertisements__r;
                        if(!alreadyPresentAdvt.isEmpty()) {
                            for(PropStrength__Advertisement__c ad : alreadyPresentAdvt) {
                                if(!advRecMap.containsKey(ad.Id)) {
                                    totalBudgetInvested += ad.PropStrength__Budgeted_Cost__c;
                                }                                
                            }
                        }
                        if(adv.PropStrength__Start_Date__c != null && adv.PropStrength__End_Date__c != null && adv.PropStrength__Start_Date__c > adv.PropStrength__End_Date__c) {
                            adv.addError('Start Date can\'t be greather than End Date');
                        }
                        if(adv.PropStrength__Start_Date__c != null && adv.PropStrength__End_Date__c != null && adv.PropStrength__End_Date__c < adv.PropStrength__Start_Date__c) {
                            adv.addError('End Date can\'t be less than Start Date');
                        }
                        if(adv.PropStrength__Start_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c != null && adv.PropStrength__Start_Date__c < marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c) {
                            adv.addError('Start Date can\'t be less than ' + marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c.format());
                        }
                        if(adv.PropStrength__End_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c != null && adv.PropStrength__End_Date__c > marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c) {
                            adv.addError('End Date can\'t be greater than ' + marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c.format());
                        }
                        if(adv.PropStrength__Start_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c != null && adv.PropStrength__Start_Date__c > marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c) {
                            adv.addError('Start Date can\'t be greater than ' + marketingChannelMap.get(adv.Marketing_Channel__c).End_Date__c.format());
                        }
                        if(adv.PropStrength__End_Date__c != null && marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c != null && adv.PropStrength__End_Date__c < marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c) {
                            adv.addError('End Date can\'t be less than ' + marketingChannelMap.get(adv.Marketing_Channel__c).Start_Date__c.format());
                        }
                        if(totalBudgetInvested > marketingChannelMap.get(adv.Marketing_Channel__c).Budget_Allotted__c) {
                            adv.addError('Budget Cost Value is exceeding the Budget Alloted Value');
                        }
                        // else if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && !updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                        //     updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        // } else if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                        //     totalBudgetInvested += updMarketChannelMap.get(marketingChannelMap.get(adv.Marketing_Channel__c).Id).Budget_Utilization_Till_Date__c;
                        //     updMarketChannelMap.remove(marketingChannelMap.get(adv.Marketing_Channel__c).Id);
                        //     updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        // }
                    }
                }
                if(!updMarketChannelMap.isEmpty()) {
                    update updMarketChannelMap.values();
                }
            }
        }
    }
    
    public static void totalBudgetCost(List<PropStrength__Advertisement__c> advRecList) {
        Set<Id> marketingChannelIds = new Set<Id>();
        for(PropStrength__Advertisement__c adv : advRecList) {
            if(adv.Marketing_Channel__c != null) {
                marketingChannelIds.add(adv.Marketing_Channel__c);
            }
        }
        
        if(!marketingChannelIds.isEmpty()) {
            Map<Id, Marketing_Channel__c> marketingChannelMap = new Map<Id, Marketing_Channel__c>([SELECT Id, Budget_Allotted__c, (SELECT Id, PropStrength__Budgeted_Cost__c FROM Advertisements__r) FROM Marketing_Channel__c WHERE Id IN :marketingChannelIds]);
            if(!marketingChannelMap.isEmpty()) {
                Map<Id, Marketing_Channel__c> updMarketChannelMap = new Map<Id, Marketing_Channel__c>();
                for(PropStrength__Advertisement__c adv : advRecList) {
                    if(adv.Marketing_Channel__c != null && marketingChannelMap.containsKey(adv.Marketing_Channel__c)) {
                        Decimal totalBudgetInvested = 0.00;
                        List<PropStrength__Advertisement__c> alreadyPresentAdvt = marketingChannelMap.get(adv.Marketing_Channel__c).Advertisements__r;
                        System.debug(alreadyPresentAdvt);
                        if(!alreadyPresentAdvt.isEmpty()) {
                            for(PropStrength__Advertisement__c ad : alreadyPresentAdvt) {
                                totalBudgetInvested += ad.PropStrength__Budgeted_Cost__c;
                            }
                        }
                        System.debug(totalBudgetInvested);
                        if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && !updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                            updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        } else if(marketingChannelMap.get(adv.Marketing_Channel__c).Id != null && updMarketChannelMap.containsKey(marketingChannelMap.get(adv.Marketing_Channel__c).Id)){
                            totalBudgetInvested += updMarketChannelMap.get(marketingChannelMap.get(adv.Marketing_Channel__c).Id).Budget_Utilization_Till_Date__c;
                            updMarketChannelMap.remove(marketingChannelMap.get(adv.Marketing_Channel__c).Id);
                            updMarketChannelMap.put(marketingChannelMap.get(adv.Marketing_Channel__c).Id, new Marketing_Channel__c(Id = marketingChannelMap.get(adv.Marketing_Channel__c).Id, Budget_Utilization_Till_Date__c = totalBudgetInvested));
                        }
                    }
                }
                if(!updMarketChannelMap.isEmpty()) {
                    update updMarketChannelMap.values();
                }
            }
        }
    }
    
   /* public static void updateTotalBudgetCost(List<PropStrength__Advertisement__c> advRecList, Map<Id, PropStrength__Advertisement__c> oldAdvtMap) {
        Set<Id> minusTotalBudgetId = new Set<Id>();
        List<Marketing_Channel__c> updateMCList = new List<Marketing_Channel__c>();
        
        for(PropStrength__Advertisement__c advt : advRecList) {
            if(oldAdvtMap.get(advt.Id).Marketing_Channel__c != advt.Marketing_Channel__c) {
                if(oldAdvtMap.get(advt.Id).Marketing_Channel__c != null) {
                    minusTotalBudgetId.add(oldAdvtMap.get(advt.Id).Marketing_Channel__c);
                }
                if(advt.Marketing_Channel__c != null) {
                    minusTotalBudgetId.add(advt.Marketing_Channel__c);
                }
            }
        }
        
        if(!minusTotalBudgetId.isEmpty()) {
            List<Marketing_Channel__c> marketChannelList = [SELECT Id, Budget_Utilization_Till_Date__c, (SELECT Id, PropStrength__Budgeted_Cost__c FROM Advertisements__r) FROM Marketing_Channel__c WHERE Id IN :minusTotalBudgetId];
            if(!marketChannelList.isEmpty()) {
                for(Marketing_Channel__c mc : marketChannelList) {
                    if(!mc.Advertisements__r.isEmpty()) {
                        Decimal total = 0.00;
                        for(PropStrength__Advertisement__c adv : mc.Advertisements__r) {
                            if(adv.PropStrength__Budgeted_Cost__c != null) {
                                total += adv.PropStrength__Budgeted_Cost__c;
                            }
                        }
                        updateMCList.add(new Marketing_Channel__c(Id = mc.Id, Budget_Utilization_Till_Date__c = total));
                    }
                }
            }
        }
        
        if(!updateMCList.isEmpty()) {
            update updateMCList;
        }
    }*/
    
    public static void updateCountOnMarketChannel(List<PropStrength__Advertisement__c> advRecList, Map<Id, PropStrength__Advertisement__c> oldAdvtMap) {
        Set<Id> marketingIds = new Set<Id>();
        
        for(PropStrength__Advertisement__c advt : advRecList) {
            Boolean flag = FALSE;
            if(advt.Marketing_Channel__c != null && advt.Total_Booking_Count__c != oldAdvtMap.get(advt.Id).Total_Booking_Count__c) {
                flag = TRUE;
            }
            if(advt.Marketing_Channel__c != null && advt.Total_Offer_Count__c != oldAdvtMap.get(advt.Id).Total_Offer_Count__c) {
                flag = TRUE;
            }
            if(advt.Marketing_Channel__c != null && advt.Total_Enquiry_Count__c != oldAdvtMap.get(advt.Id).Total_Enquiry_Count__c) {
                 flag = TRUE;
            }
            if(flag) {
                marketingIds.add(advt.Marketing_Channel__c);
            }
        }
        
        if(!marketingIds.isEmpty()) {
            List<Marketing_Channel__c> marketChannelList = [SELECT Id, Total_Offer_Count__c, Total_Enquiry_Count__c, Total_Booking_Count__c, (SELECT Id, Total_Enquiry_Count__c, Total_Offer_Count__c, Total_Booking_Count__c FROM Advertisements__r) FROM Marketing_Channel__c WHERE Id IN :marketingIds];
            
            if(!marketChannelList.isEmpty()) {
                List<Marketing_Channel__c> updateMarketChannel = new List<Marketing_Channel__c>();
                for(Marketing_Channel__c market : marketChannelList) {
                    Decimal enqCount = 0.00;
                    Decimal offCount = 0.00;
                    Decimal bookCount = 0.00;
                    if(!market.Advertisements__r.isEmpty()) {
                        for(PropStrength__Advertisement__c adv : market.Advertisements__r) {
                            if(adv.Total_Enquiry_Count__c != null) {
                                enqCount += adv.Total_Enquiry_Count__c;
                            }
                            if(adv.Total_Offer_Count__c != null) {
                                offCount += adv.Total_Offer_Count__c;
                            }
                            if(adv.Total_Booking_Count__c != null) {
                                bookCount += adv.Total_Booking_Count__c;
                            }
                        }
                        updateMarketChannel.add(new Marketing_Channel__c(Id = market.Id, Total_Booking_Count__c = bookCount, Total_Enquiry_Count__c = enqCount, Total_Offer_Count__c = offCount));
                    }
                    if(!updateMarketChannel.isEmpty()) {
                        update updateMarketChannel;
                    }
                }                
            }
        }
    }
    //Added by Amrit Sharma 09/08/2023
   public static void updateBudgetedCost(List<PropStrength__Advertisement__c> advRecList, Map<Id, PropStrength__Advertisement__c> oldMap){
        Set<Id> marketingId= new Set<Id>();
        Map<Object,Decimal> mapOfCost=new  Map<Object,Decimal>();
        List<Marketing_Channel__c> updateMarketChannel = new List<Marketing_Channel__c>();
        for (PropStrength__Advertisement__c adv : advRecList) {
            if (adv.Approval_Status__c == 'Approved' && adv.Approval_Status__c !=  oldMap.get(adv.Id).Approval_Status__c) {
                marketingId.add(adv.Marketing_Channel__c);
            }
        }
        if (marketingId.size() > 0) {
            List<AggregateResult> sumOfCOst=[SELECT Marketing_Channel__c,SUM(PropStrength__Actual_Cost__c) total FROM PropStrength__Advertisement__c WHERE Marketing_Channel__c IN :marketingId AND Approval_Status__c='Approved' GROUP BY Marketing_Channel__c];
            List<Marketing_Channel__c> marketChannelList = [SELECT Id,  Budget_Allotted__c,Budget_Utilization_Till_Date__c FROM Marketing_Channel__c WHERE Id IN :marketingId];
            if (sumOfCOst.size() > 0) {
                for (AggregateResult ag:sumOfCOst) {
                    if (!mapOfCost.containsKey(ag.get('Marketing_Channel__c'))) {
                        mapOfCost.put(ag.get('Marketing_Channel__c'),(Decimal)ag.get('total'));
                    }
                }
            }
            if (marketChannelList.size() > 0) {
                for (Marketing_Channel__c market : marketChannelList) {
                    market.Budget_Utilization_Till_Date__c =mapOfCost.get(market.Id);
                    updateMarketChannel.add(market);
                }
                if (!updateMarketChannel.isEmpty()) {
                    update updateMarketChannel;
                }          
            }
        }
    }
}