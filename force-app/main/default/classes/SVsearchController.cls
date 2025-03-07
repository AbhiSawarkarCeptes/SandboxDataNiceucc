public class SVsearchController {
    public List<SelectOption> lstProjectList {get;set;}
    public List<SelectOption> enqSourceList {get;set;}
    public String MobilePhone{get;set;}
    public string Email {get;set;}
    public string enqSource {get;set;}
    public string strError {get;set;}
    public string strProjectId {get;set;}
    public SVsearchController() {
        lstProjectList = new List <SelectOption>();
        enqSourceList = new List <SelectOption>();
        strError = '';
        
        List <PropStrength__Projects__c> lstProj = [select Id, name from PropStrength__Projects__c]; //
        System.debug('lstProj ::' + lstProj);
        lstProjectList.add(new SelectOption('--None--', '--None--'));
        enqSourceList.add(new SelectOption('--None--', '--None--'));
        if (lstProj != null && lstProj.size() > 0) {
            for (PropStrength__Projects__c EachProj: lstProj) {
                lstProjectList.add(new SelectOption(EachProj.id, EachProj.name));
            }
        }

        String objectApiName = 'PropStrength__Request__c'; 
        String fieldApiName = 'PropStrength__Request_Source__c'; 

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldApiName).getDescribe();

        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            String picklistValue = picklistEntry.getValue();
            String picklistLabel = picklistEntry.getLabel();
            enqSourceList.add(new SelectOption(picklistValue, picklistLabel));
        }
    }
    
    public pagereference searchAllLead() {
        System.debug('strProjectId**'+strProjectId);
        if(strProjectId == null || strProjectId == '' || strProjectId == '--None--') {
            strError = 'Please Select A Project';
        } else if(MobilePhone == null || MobilePhone == '') {
            strError = 'Please Enter Mobile Number';
        } else if(Email == null || Email == '') {
            strError = 'Please Enter Email Address';
        } else if(enqSource == null || enqSource == '') {
            strError = 'Please Enter Enquiry Source';
        } else {
            List<PropStrength__Request__c> enq = [SELECT Id, PropStrength__Primary_Contact__c FROM PropStrength__Request__c WHERE PropStrength__Project__c = :strProjectId AND PropStrength__Primary_Contact__r.Email = :Email AND PropStrength__Primary_Contact__r.MobilePhone = :MobilePhone ANd PropStrength__Request_Source__c = :enqSource];
            if(!enq.isEmpty()) {
                Pagereference objReference = new Pagereference('/apex/CRForm_V1?EnquiryId=' + enq[0].id + '&projectId=' + strProjectId+ '&contId=' + enq[0].PropStrength__Primary_Contact__c);
                objReference.setRedirect(true);
                return objReference;
            } else {
                Pagereference objReference1 = new Pagereference('/apex/CRForm_V1?projectId=' + strProjectId+ '&Email=' + Email+ '&mobilePhone=' + MobilePhone + '&enqSource=' + enqSource);
                objReference1.setRedirect(true);
                return objReference1;
            }
        }
        return null;
    }        
}