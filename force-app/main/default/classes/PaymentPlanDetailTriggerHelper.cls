public class PaymentPlanDetailTriggerHelper {
    private static Boolean isRun = true;
    Public static Boolean isRun2 = true;
    
    public static void PPDConstructionLink(List<PropStrength__Payment_Plan_Details__c> newList, Map<Id, PropStrength__Payment_Plan_Details__c> oldMap) {
        set<Id> ppdIds = new set<Id>();
        for(PropStrength__Payment_Plan_Details__c ppd : newList) {
            if(ppd.PropStrength__Payment_Due_Date__c == Date.today() &&
               ppd.PropStrength__Payment_Due_Date__c != null &&
               ppd.CLP_Milestone_Raised__c == true &&
               ppd.CLP_Milestone_Raised__c != oldMap.get(ppd.Id).CLP_Milestone_Raised__c &&
               ppd.PropStrength__Milestone__c != null &&
               ppd.PropStrength__Application_Booking__c != null &&
               ppd.PropStrength__Is_Milestone_Completed__c == false &&
               ppd.PropStrength__Approval_Status__c != 'Approved') {
                   ppdIds.add(ppd.Id);
               }
        }
        system.debug('ppdIds::'+ppdIds);
        if(!ppdIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                Database.executeBatch(new PPDConstructionBatch(ppdIds),1);
            }
        }
    }
    
    public static void updateBudgetedDate(List<PropStrength__Payment_Plan_Details__c> newList) {
        Set<Id> mileStId = new Set<Id>();
        for(PropStrength__Payment_Plan_Details__c ppd : newList) {
            if(ppd.PropStrength__Milestone__c != null) {
                mileStId.add(ppd.PropStrength__Milestone__c);
            }
        }
        
        if(!mileStId.isEmpty()) {
            List<PropStrength__Milestone__c> mileStList = [SELECT Id, PropStrength__Status__c, Milestone_Completion_Approved_On__c, PropStrength__Milestone_Type__c, (SELECT Id, PropStrength__Payment_Due_Date__c FROM PropStrength__Payment_Plan_Details__r) FROM PropStrength__Milestone__c WHERE Id IN :mileStId];
            List<PropStrength__Payment_Plan_Details__c> updPpdList = new List<PropStrength__Payment_Plan_Details__c>();
            
            for(PropStrength__Milestone__c mileSt : mileStList) {
                if(mileSt.PropStrength__Status__c == 'Completed' && mileSt.Milestone_Completion_Approved_On__c != null && mileSt.PropStrength__Milestone_Type__c == 'Construction Linked' && mileSt.PropStrength__Payment_Plan_Details__r.isEmpty() == FALSE) {
                    for(PropStrength__Payment_Plan_Details__c ppd : mileSt.PropStrength__Payment_Plan_Details__r) {
                        updPpdList.add(new PropStrength__Payment_Plan_Details__c(Id=ppd.Id, PropStrength__Payment_Due_Date__c=mileSt.Milestone_Completion_Approved_On__c));
                    }
                }
            }
            
            if(!updPpdList.isEmpty()) {
              //  update updPpdList;
            }
        }
    }
    
    //Added by Deepak Sharma to update rate of interest in updation of budgeted date on 23-Aug-23
    public static void updateRateOfInterest(List<PropStrength__Payment_Plan_Details__c> newList, Map<Id, PropStrength__Payment_Plan_Details__c> oldMap) {
        Boolean flag = false;
        for(PropStrength__Payment_Plan_Details__c ppd : newList) {
            if(ppd.PropStrength__Final_Payment_Date__c != null && ppd.PropStrength__Final_Payment_Date__c != oldMap.get(ppd.Id).PropStrength__Final_Payment_Date__c) {
                flag = true;
                break;
            }
        }
        if(flag) {
            List<Interest_Slab__c> interestSlabRecs = [SELECT Id,Interest__c,Start_Date__c,End_Date__c FROM Interest_Slab__c];
            for(PropStrength__Payment_Plan_Details__c ppd : newList) {
                if(ppd.PropStrength__Final_Payment_Date__c != null && ppd.PropStrength__Final_Payment_Date__c != oldMap.get(ppd.Id).PropStrength__Final_Payment_Date__c) {
                    for(Interest_Slab__c slab : interestSlabRecs) {
                        if(ppd.PropStrength__Final_Payment_Date__c > slab.Start_Date__c && ppd.PropStrength__Final_Payment_Date__c < slab.End_Date__c) {
                            ppd.PropStrength__Rate_of_Interest__c = slab.Interest__c !=null ? slab.Interest__c : 0;
                        }
                    }
                }
            }
        }
    }    
    // Added by Gourav Gour 12/4/2024
    public static void updatetaxReversal(List<PropStrength__Payment_Plan_Details__c> newList, Map<Id, PropStrength__Payment_Plan_Details__c> oldMap) {
        for(PropStrength__Payment_Plan_Details__c ppd : newList) {
            if(ppd.PropStrength__Is_reversed__c && !oldMap.get(ppd.Id).PropStrength__Is_reversed__c) {
                ppd.PropStrength__Tax_Reversal__c = true;
            }
        }
    }    
    
    
    public static boolean runOnce(){
        if(isRun){
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
    
    
}