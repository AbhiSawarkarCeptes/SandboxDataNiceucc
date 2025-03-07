public with sharing class SPADocVfController {
    public String msg {get;set;}
    public String framesrc {get; set;}
    public String transIds = null; 
    public Boolean showButton {get;set;}



    public SPADocVfController() {
        transIds = ApexPages.currentPage().getParameters().get('Id');
        msg = '';
        transMethod();
    }

    public void transMethod() {
        list<PropStrength__Transaction_Requests__c> transactionRequestList = new List<PropStrength__Transaction_Requests__c>();
        if(!String.isBlank(transIds)) {
            transactionRequestList = [SELECT Id,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,PropStrength__Application_Booking__r.POA_Email_Address__c,
                                      PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c
                                      FROM PropStrength__Transaction_Requests__c 
                                      WHERE Id =: transIds 
                                      AND RecordType.Name =: 'SPA Process' 
                                      AND PropStrength__Application_Booking__r.SPA_Executed__c =: false
                                      AND PropStrength__Application_Booking__r.SPA_Execution_Date__c =: null
                                      AND SPA_Created__c = false];
            if(transactionRequestList.isEmpty()) {
                msg = 'SPA Already Generated.';
            } else {
                if(transIds != null && transIds != '') {
                    showButton = true;
                    framesrc = '/apex/loop__looplus?eid='+transIds+'&header=false&sidebar=false';
                    System.debug('=====>'+ framesrc);
                } 
            }
        }
    }
    public pagereference docancel(){
        return new pageReference('/'+transIds);
    }
}