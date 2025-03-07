global without sharing class BatchClassToManageLeadSpillOver implements Database.Batchable <sObject> {
    global List < Lead> start(Database.BatchableContext BC) {
        List < Lead> leadList = new List < Lead > ();

        leadList = [SELECT ID,Route_To_Saturday_Queue1__c,Route_To_Sunday_Queue1__c  FROM Lead WHERE (CreatedDate = today OR CreatedDate = yesterday) AND is_serviced__c = false AND (Route_To_Sunday_Queue1__c = true OR Route_To_Saturday_Queue1__c = true)];
        return leadList;
    }

    global void execute(Database.BatchableContext BC, List < Lead > scope) {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
       
        List<Lead> leadList = scope;
        for(Lead l : leadList){
            /*if(l.Route_To_Saturday_Queue1__c == true){
                l.Route_To_Saturday_Queue1__c = false;
                l.Route_To_Sunday_Queue1__c = true;
            }
           else  if(l.Route_To_Sunday_Queue1__c == true){
                l.Route_To_Saturday_Queue1__c = false;
                l.Route_To_Sunday_Queue1__c = false;
            }*/
            l.presales_agent__c = null;
            l.setOptions(dmo);
        }
        
        Database.update(leadList);
       
    }

    global void finish(Database.BatchableContext BC) {}
   


}