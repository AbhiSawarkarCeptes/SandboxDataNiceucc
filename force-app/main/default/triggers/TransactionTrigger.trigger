/* Bypass Framework Enabled */
trigger TransactionTrigger on Magnati_Transaction_History__c (after update) {
    
    Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();  
    if( bypassSettingInstance.Bypass_Backend_Automations__c){
        return;
    }
    
    try {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<Contact> conList = new List<Contact>();
        conList = [SELECT Id FROM Contact WHERE LastName = 'Payment_Status'];
        update conList;
        if(conList.isEmpty()){
            Contact conInst = new Contact();
            conInst.LastName = 'Payment_Status';
            insert conInst;
            conList.add(conInst);
        }
        for(Magnati_Transaction_History__c transactionInst :Trigger.new){
            if(transactionInst.Status_Fetched__c == true){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] orgWideAdd = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :System.Label.Payment_Status_Email LIMIT 1 ];
                email.setOrgWideEmailAddressId(orgWideAdd.get(0).id);
                email.setToAddresses(new String[] { transactionInst.Email__c });
                EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :System.Label.Payment_Template];
                email.setTemplateId(template.Id);
                email.setTargetObjectId(conList[0].Id);
                email.setWhatId(transactionInst.Id);
                email.setTreatTargetObjectAsRecipient(false);
                emailList.add(email);
            }
        }
        Messaging.sendEmail(emailList);
    } catch (Exception ex) {
        Error_Log__c log = new Error_Log__c();
        log.Class__c = 'TransactionTrigger';
        log.Name = 'Error in send payment status mail';
        log.Message__c = ex.getMessage();
        insert log;
    }
}