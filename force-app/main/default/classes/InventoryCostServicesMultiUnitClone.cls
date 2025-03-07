public with sharing class InventoryCostServicesMultiUnitClone {

    public static List<PropStrength__Payment_Plan__c> getPlanList(Id projId) {
        List<PropStrength__Payment_Plan__c> planList = [SELECT Id, Name, PropStrength__Active__c, Is_Access_Restricted__c  FROM PropStrength__Payment_Plan__c WHERE PropStrength__Project__c =: projId LIMIT 1000]; 
        List<PropStrength__Payment_Plan__c> newPlanList = new List<PropStrength__Payment_Plan__c>();
        User u = getLoggedInUserDetails();
        for(PropStrength__Payment_Plan__c p : planList) {
                if(p.Is_Access_Restricted__c) {
                    if(u.Special_Payment_Plan_Visible__c)
                        newPlanList.add(p);
                } else {
                    newPlanList.add(p);
                }           
        }
        return newPlanList;
    }
    public static List<PropStrength__Income_Charges__c> getIncomeChargeList(Id projId) {
        List<PropStrength__Income_Charges__c> chargeList = [SELECT Id,Name, PropStrength__Category__c, PropStrength__Project__c, PropStrength__Amount__c ,PropStrength__Type__c, 
                                                        Display_on_Quotation__c, PropStrength__Rate_Per_Unit_Area__c, Charge__c, PropStrength__Income_Charge_Code__c,
                                                        PropStrength__Tax_Type__c, PropStrength__Service_Tax__c 
                                                        FROM PropStrength__Income_Charges__c
                                                        WHERE PropStrength__Project__c  =: projId AND Display_on_Quotation__c = true]; 
        return chargeList;
    }
    public static PropStrength__Request__c getEnquiry(Id enquiryId) {
        return  [SELECT Id, PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.Name FROM PropStrength__Request__c WHERE Id = :enquiryId LIMIT 1]; 
    }

    public static List<PropStrength__Payment_Plan_Line_Items__c> getPPL(Id pPlan) {
       return [SELECT Id, PropStrength__Milestone__c, PropStrength__Milestone__r.PropStrength__Milestone_Name__c,PropStrength__Order__c, 
                                                                PropStrength__Amount_Percent__c, PropStrength__Due_After_Days__c, PropStrength__Amount__c 
                                                                FROM PropStrength__Payment_Plan_Line_Items__c 
                                                                WHERE PropStrength__Payment_Plan__c = :pPlan
                                                                ORDER BY PropStrength__Order__c];
    }
    
    public static User getLoggedInUserDetails() {
            List<User> uList = [Select Id, Name, Special_Payment_Plan_Visible__c from User where Id = :UserInfo.getUserId()];
            return uList[0];
    }
}