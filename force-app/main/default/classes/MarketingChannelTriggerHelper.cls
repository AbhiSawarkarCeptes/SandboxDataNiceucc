/*********************************************************************
 * Class Name  :   MarketingChannelTriggerHelper
 * Description :   Helper Class of MarketingChannelTrigger
 * Created Date:   24/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 24/07/2023
 *********************************************************************/
public class MarketingChannelTriggerHelper {
    public static void showErrorAmtCheck(List<Marketing_Channel__c> marChanList) {
        Set<Id> marketingPlansIds = new Set<Id>();
        for(Marketing_Channel__c mc : marChanList) {
            if(mc.Marketing_Plan__c != null) {
                marketingPlansIds.add(mc.Marketing_Plan__c);
            }
        }
        
        if(!marketingPlansIds.isEmpty()) {
            Map<Id, Marketing_Plan__c> marketingPlanMap = new Map<Id, Marketing_Plan__c>([SELECT Id, Marketing_Plan_Cost__c, Start_Date__c, End_Date__c, (SELECT Id, Budget_Allotted__c FROM Marketing_Channels__r) FROM Marketing_Plan__c WHERE Id IN :marketingPlansIds]);
            if(!marketingPlanMap.isEmpty()) {
                for(Marketing_Channel__c mc : marChanList) {
                    if(mc.Marketing_Plan__c != null && marketingPlanMap.containsKey(mc.Marketing_Plan__c)) {
                        Decimal totalBudgetInvested = mc.Budget_Allotted__c;
                        List<Marketing_Channel__c> alreadyPresentMC = marketingPlanMap.get(mc.Marketing_Plan__c).Marketing_Channels__r;
                        if(!alreadyPresentMC.isEmpty()) {
                            for(Marketing_Channel__c m : alreadyPresentMC) {
                                totalBudgetInvested += m.Budget_Allotted__c;
                            }
                        }
                        if(mc.Start_Date__c != null && mc.End_Date__c != null && mc.Start_Date__c > mc.End_Date__c) {
                            mc.addError('Start Date can\'t be greather than End Date');
                        }
                        if(mc.Start_Date__c != null && mc.End_Date__c != null && mc.End_Date__c < mc.Start_Date__c) {
                            mc.addError('End Date can\'t be less than Start Date');
                        }
                        if(mc.Start_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c != null && mc.Start_Date__c < marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c) {
                            mc.addError('Start Date can\'t be less than ' + marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c.format());
                        }
                        if(mc.End_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c != null && mc.End_Date__c > marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c) {
                            mc.addError('End Date can\'t be greater than ' + marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c.format());
                        }
                        if(mc.Start_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c != null && mc.Start_Date__c > marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c) {
                            mc.addError('Start Date can\'t be greater than ' + marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c.format());
                        }   
                        if(mc.End_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c != null && mc.End_Date__c < marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c) {
                            mc.addError('End Date can\'t be less than ' + marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c.format());
                        }
                        if(totalBudgetInvested > marketingPlanMap.get(mc.Marketing_Plan__c).Marketing_Plan_Cost__c) {
                            mc.addError('Budget Alloted Value is exceeding the Marketing Plan Cost Value');
                        }
                    }
                }
            }
        }
    }

    public static void showErrorAmtCheckOnUpd(List<Marketing_Channel__c> marChanList, Map<Id, Marketing_Channel__c> marChannelMap) {
        Set<Id> marketingPlansIds = new Set<Id>();
        for(Marketing_Channel__c mc : marChanList) {
            if(mc.Marketing_Plan__c != null) {
                marketingPlansIds.add(mc.Marketing_Plan__c);
            }
        }
        
        if(!marketingPlansIds.isEmpty()) {
            Map<Id, Marketing_Plan__c> marketingPlanMap = new Map<Id, Marketing_Plan__c>([SELECT Id, Marketing_Plan_Cost__c, Start_Date__c, End_Date__c, (SELECT Id, Budget_Allotted__c FROM Marketing_Channels__r) FROM Marketing_Plan__c WHERE Id IN :marketingPlansIds]);
            if(!marketingPlanMap.isEmpty()) {
                for(Marketing_Channel__c mc : marChanList) {
                    if(mc.Marketing_Plan__c != null && marketingPlanMap.containsKey(mc.Marketing_Plan__c)) {
                        Decimal totalBudgetInvested = mc.Budget_Allotted__c != null ? mc.Budget_Allotted__c : 0.00;
                        List<Marketing_Channel__c> alreadyPresentMC = marketingPlanMap.get(mc.Marketing_Plan__c).Marketing_Channels__r;
                        if(!alreadyPresentMC.isEmpty()) {
                            for(Marketing_Channel__c m : alreadyPresentMC) {
                                if(!marChannelMap.containsKey(m.Id)) {
                                    totalBudgetInvested += m.Budget_Allotted__c;
                                }
                            }
                        }
                        if(mc.Start_Date__c != null && mc.End_Date__c != null && mc.Start_Date__c > mc.End_Date__c) {
                            mc.addError('Start Date can\'t be greather than End Date');
                        }
                        if(mc.Start_Date__c != null && mc.End_Date__c != null && mc.End_Date__c < mc.Start_Date__c) {
                            mc.addError('End Date can\'t be less than Start Date');
                        }
                        if(mc.Start_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c != null && mc.Start_Date__c < marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c) {
                            mc.addError('Start Date can\'t be less than ' + marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c.format());
                        }
                        if(mc.End_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c != null && mc.End_Date__c > marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c) {
                            mc.addError('End Date can\'t be greater than ' + marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c.format());
                        }
                        if(mc.Start_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c != null && mc.Start_Date__c > marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c) {
                            mc.addError('Start Date can\'t be greater than ' + marketingPlanMap.get(mc.Marketing_Plan__c).End_Date__c.format());
                        }   
                        if(mc.End_Date__c != null && marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c != null && mc.End_Date__c < marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c) {
                            mc.addError('End Date can\'t be less than ' + marketingPlanMap.get(mc.Marketing_Plan__c).Start_Date__c.format());
                        }
                        if(totalBudgetInvested > marketingPlanMap.get(mc.Marketing_Plan__c).Marketing_Plan_Cost__c) {
                            mc.addError('Budget Alloted Value is exceeding the Marketing Plan Cost Value');
                        }
                    }
                }
            }
        }
    }
}