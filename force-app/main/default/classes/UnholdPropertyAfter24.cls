public class UnholdPropertyAfter24 implements Database.Batchable<sObject>,Database.stateful {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime twentyFourHoursAgo = System.now().addMinutes(-10);//addHours(-24);
        
        return Database.getQueryLocator([SELECT Id,Offer__r.PropStrength__Property__c,Property__c
                                         FROM Payment_Request__c 
                                         WHERE X1st_Level_Approved__c =: true AND
                                         X1st_Level_Approved_Date__c <=: twentyFourHoursAgo]);
    }
    
    public void execute(Database.BatchableContext BC, List<Payment_Request__c> scope) {
        set<Id> propertyId = new Set<Id>();
        List<PropStrength__Property__c> updateList = new List<PropStrength__Property__c>();
        for(Payment_Request__c pr: scope) {
            if(pr.Property__c != null) {
                pr.Status__c = 'Rejected by System';
                propertyId.add(pr.Property__c);
            } else if(pr.Offer__r.PropStrength__Property__c != null) {
                propertyId.add(pr.Offer__r.PropStrength__Property__c);
                pr.Status__c = 'Rejected by System';
            } 
        }
        update scope;
        system.debug('propertyId::'+propertyId);
        if(!propertyId.isEmpty()) {
            List<PropStrength__Property__c> propertyList = [SELECT Id,PropStrength__Property_on_hold_for_Reallocation__c,Hold_Classification__c
                                                            FROM PropStrength__Property__c WHERE Id IN: propertyId];
            system.debug('propertyList::'+propertyList);
            if(!propertyList.isEmpty()) {
                for(PropStrength__Property__c pr: propertyList) {
                    PropStrength__Property__c onePR = new PropStrength__Property__c();
                    onePR.id = pr.Id;
                    onePR.PropStrength__Property_on_hold_for_Reallocation__c = false;
                    onePR.Hold_Classification__c = '';
                    updateList.add(onePR);
                }
                system.debug('updateList::'+updateList);
                if(!updateList.isEmpty()) {
                    update updateList;
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}