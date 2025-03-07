trigger TrgDocumentValidator on Document_validator__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        TrgDocumentValidatorHelper.updateCDLLinkedEntityId(Trigger.newMap,Trigger.oldMap);
    }

}