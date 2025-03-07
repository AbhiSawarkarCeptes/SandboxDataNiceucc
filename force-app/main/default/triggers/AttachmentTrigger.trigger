trigger AttachmentTrigger on Attachment (after insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            AttachmentTriggerHelper.createFile(Trigger.new);
        }
    }
}