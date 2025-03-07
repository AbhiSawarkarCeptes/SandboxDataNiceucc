public class WaiverReceiptController {
    public PropStrength__Transaction_Requests__c tr {get;set;}
    public String projectLOGOId {get;set;}
    
    public WaiverReceiptController() {
        String recId = ApexPages.currentPage().getParameters().get('id'); 
        if(recId != null && recId != '') {
            tr = [SELECT Id, Name, PropStrength__Payment_Id__r.PropStrength__Amount_Due_Type__c, PropStrength__Amount_Type__c, PropStrength__Application_Booking__r.PropStrength__Project__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Name, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Property_Name__c, LastModifiedDate, PropStrength__Credit_Waiver_Amount__c FROM PropStrength__Transaction_Requests__c WHERE Id = :recId];
            for(Attachment att : [SELECT Id,Name FROM Attachment WHERE parentId =: tr.PropStrength__Application_Booking__r.PropStrength__Project__c]) {
                if(att.Name.contains('LOGO')){
                    projectLOGOId = att.Id;
                }
            }
        } else {
            tr = new PropStrength__Transaction_Requests__c();
            projectLOGOId = '';
        }
    }
}