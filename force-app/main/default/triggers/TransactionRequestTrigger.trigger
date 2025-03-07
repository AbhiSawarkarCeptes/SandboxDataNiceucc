trigger TransactionRequestTrigger on PropStrength__Transaction_Requests__c (before insert,before update,after insert,after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            TransactionRequestTriggerHelper.spaCreateValidate(Trigger.new);
            TransactionRequestTriggerHelper.TRrecordCreatePermission(Trigger.new);
            TransactionRequestTriggerHelper.updateOriginalWaiverAmount(Trigger.new, null);
            TransactionRequestTriggerHelper.customerChangeErrorMsg(Trigger.new);
            //TransactionRequestTriggerHelper.createPaymentIncomeChargeDue(Trigger.new);
            TransactionRequestTriggerHelper.showErrorForTitleDeedRecord(Trigger.new);
            //TransactionRequestTriggerHelper.showErrorForTransferOfPropertyRecord(Trigger.new);
            TransactionRequestTriggerHelper.showErrorForSPAResidentOrNonResident(Trigger.new);
            TransactionRequestTriggerHelper.showErrorOnSpaCreation(Trigger.new);
            TransactionRequestTriggerHelper.showErrorOnDspaCreation(Trigger.new);
            TransactionRequestTriggerHelper.showErrorOnMouCreation(Trigger.new);
            TransactionRequestTriggerHelper.showErrorOnPreRegistrationCreation(Trigger.new);
        }
        if(Trigger.isUpdate) {
            TransactionRequestTriggerHelper.onBeforeUpdate(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateOriginalWaiverAmount(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateDLDCertificate(trigger.new,trigger.oldMap);
            TransactionRequestTriggerHelper.updateCBSonTitleDeed(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateDsrGenDtandProcNum(Trigger.new, Trigger.oldMap);
            //TransactionRequestTriggerHelper.createPaymentIncomeChargeDueOnUpdate(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailOnRequestComplete(trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.errorOnTitleDeedCB(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateTransactionStatus(Trigger.new);
            TransactionRequestTriggerHelper.changeStatusToVoid(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateDsrReveiw(Trigger.new, Trigger.oldMap);
           // TransactionRequestTriggerHelper.updateSPADate(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateStatusOnBook(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.changeTitleDeed48(Trigger.new, Trigger.oldMap);
        }
        if((Trigger.isInsert || Trigger.isUpdate)) {
            TransactionRequestTriggerHelper.errorMSG(trigger.new,trigger.oldMap);
        }
    }
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            TransactionRequestTriggerHelper.updateAdvanceAmount(trigger.new);
            TransactionRequestTriggerHelper.createTaskForTitleDeed(Trigger.new);
            TransactionRequestTriggerHelper.submitForAPForAreaChangeRT(Trigger.new);
            TransactionRequestTriggerHelper.sendMailToAccountExecutiveQueue(Trigger.new);
            TransactionRequestTriggerHelper.updateBookingStatusAsPerTR(Trigger.new, null); // Added by Gourav Gour
            TransactionRequestTriggerHelper.updateTitleDeedNPreRegistrationStatus(Trigger.new, Trigger.newMap, 'Insert');
        }
        if(Trigger.isUpdate) { 
            TransactionRequestTriggerHelper.rejectedByAuditAction(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendEmailOnSpaExecute(Trigger.new, Trigger.oldMap); // Added by Gourav Gour
            TransactionRequestTriggerHelper.updateBookingStatusAsPerTR(Trigger.new, Trigger.oldMap); // Added by Gourav Gour
            //TransactionRequestTriggerHelper.sendMailOnAuditApprove(trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.createTaskForTitleDeedAudit(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.createTaskForTitleDeedDSRCB(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailOnHandoverDocumentShared(trigger.new, Trigger.oldMap);
            //TransactionRequestTriggerHelper.sendMailOnUndertakingDocumentsShared(trigger.new, Trigger.oldMap); //Comment by nishank manwani on 07-02-2024 because the undertaing document is now converted for booking
            TransactionRequestTriggerHelper.createIncChrgeDueForMortgage(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailOnWaiverTR(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailForChangeInPaymentPlan(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.updateTitleDeedNPreRegistrationStatus(Trigger.new, Trigger.oldMap, 'Update');
            TransactionRequestTriggerHelper.updateReminderSpaDateFldOnBooking(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailOnRejectedByAuditTeam(Trigger.new, Trigger.oldMap);
            TransactionRequestTriggerHelper.sendMailToQueueSaleOps(Trigger.new, Trigger.oldMap);
            //TransactionRequestTriggerHelper.sendMailOnCreditNoteTR(Trigger.new, Trigger.oldMap);
        }
        if(trigger.isUpdate && TransactionRequestTriggerHelper.runOnce()) {
            TransactionRequestTriggerHelper.DLDNotificationsend(trigger.new,trigger.oldMap);
            //TransactionRequestTriggerHelper.sendMOU(trigger.new,trigger.oldMap);
           // TransactionRequestTriggerHelper.sendSPA(trigger.new,trigger.oldMap);
            TransactionRequestTriggerHelper.sendDSPA(trigger.new,trigger.oldMap);
            TransactionRequestTriggerHelper.sendDLDCertificate(trigger.new,trigger.oldMap);
            TransactionRequestTriggerHelper.createPaymentRecRebateRecord(Trigger.new, Trigger.oldMap);
        }
    }
}