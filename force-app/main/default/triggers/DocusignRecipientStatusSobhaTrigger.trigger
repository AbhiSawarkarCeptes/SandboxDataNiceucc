trigger DocusignRecipientStatusSobhaTrigger on Docusign_Recipient_Status_Sobha__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            DocusignRecipientStatusSobhaTrigHelper.updateTypeField(Trigger.new, null);
        }
        if(Trigger.isUpdate) {
            DocusignRecipientStatusSobhaTrigHelper.updateTypeField(Trigger.new, Trigger.oldMap);
            DocusignRecipientStatusSobhaTrigHelper.updateHandover(Trigger.new, Trigger.oldMap);
            DocusignRecipientStatusSobhaTrigHelper.updateHomeOrientation(Trigger.new, Trigger.oldMap);
        }
     }
}