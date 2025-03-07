/*********************************************************************
 * Class Name  :   DocuSignEnvelopeStatusTriggerHelper
 * Description :   Helper Class of DocuSignEnvelopeStatusTrigger
 * Created Date:   12/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 12/01/2024
                        Gourav Gour 12/04/2024
 *********************************************************************/
public class DocuSignEnvelopeStatusTriggerHelper {
    //Added by Nishank Manwani on 12/01/2024 to update Booking Form Executed Checkbox when Completed Field get populated
    public static void updateCheckboxOnBooking(List<dfsle__EnvelopeStatus__c> esList, Map<Id, dfsle__EnvelopeStatus__c> oldEsMap) {
        List<PropStrength__Application_Booking__c> updatebooking = new List<PropStrength__Application_Booking__c>();
        List<Account> updateAccount = new List<Account>();
        List<Broker_Renewal__c> updateRenew = new List<Broker_Renewal__c>();
        Set<Id> trMOUIds = new Set<Id>();
        Set<Id> trSPAIds = new Set<Id>();
        Set<Id> trDSPAIds = new Set<Id>();

        for(dfsle__EnvelopeStatus__c es : esList) {
            
            if(es.Application_Booking__c!= null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                updatebooking.add(new PropStrength__Application_Booking__c(Id=es.Application_Booking__c, Booking_Form_Executed__c = true, Booking_Form_Signed_Date__c = System.Today()));
            }
            if(es.Envelope_Type__c =='MOU' && es.Transaction_Request__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                trMOUIds.add(es.Transaction_Request__c);
            }
            if(es.dfsle__Status__c != null && !es.dfsle__Status__c.containsIgnoreCase('voided') && es.Envelope_Type__c =='SPA' && es.Transaction_Request__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                trSPAIds.add(es.Transaction_Request__c);
            }
            if(es.Envelope_Type__c =='DSPA' && es.Transaction_Request__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                trDSPAIds.add(es.Transaction_Request__c);
            }
            if(es.Envelope_Type__c =='Broker Agreement' && es.Broker_Account__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Signed Agreement Received - Documents Awaiting', Agreement_Signed_by_Broker__c = true));
            }
            if(es.Envelope_Type__c =='NOC' && es.Broker_Account__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                updateAccount.add(new Account(Id=es.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Executed Agreement Sent to CHRM'));
            }
            if(es.Envelope_Type__c =='Broker Renew Agreement' && es.Broker_Renewal__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                updateRenew.add(new Broker_Renewal__c(Id=es.Broker_Renewal__c, Broker_Approval_Status__c = 'Signed Agreement Received - Documents Awaiting', Agreement_Signed_by_Broker__c = true));
            }
            if(es.Envelope_Type__c =='Broker Renew Noc' && es.Broker_Renewal__c != null && es.dfsle__Completed__c != null && es.dfsle__Completed__c != oldEsMap.get(es.Id).dfsle__Completed__c) {
                updateRenew.add(new Broker_Renewal__c(Id=es.Broker_Renewal__c, Broker_Approval_Status__c = 'Executed Agreement Sent to CHRM'));
            }
        }
        List<PropStrength__Transaction_Requests__c> trList = [SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trMOUIds OR Id In :trSPAIds OR Id In :trDSPAIds ];
        for(PropStrength__Transaction_Requests__c tr : trList) {
            if(tr.PropStrength__Application_Booking__c != null && trMOUIds.contains(tr.Id)) {
                updatebooking.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, MOU_Executed__c = true, MOU_Execution_Date__c = System.now()));
            }
            if(tr.PropStrength__Application_Booking__c != null && trSPAIds.contains(tr.Id)) {
                updatebooking.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, SPA_Executed__c = true, SPA_Execution_Date__c = System.Now()));
            }
            if(tr.PropStrength__Application_Booking__c != null && trDSPAIds.contains(tr.Id)) {
                updatebooking.add(new PropStrength__Application_Booking__c(Id=tr.PropStrength__Application_Booking__c, DSPA_Executed__c = true, DSPA_Execution_Date__c = System.Now()));
            }
        }
        if(!updatebooking.isEmpty()) { 
            update updatebooking;
        }
        if(!updateAccount.isEmpty()) { 
            update updateAccount;
        }
        if(!updateRenew.isEmpty()) { 
            update updateRenew;
        }
    }

    //Added by Nishank Manwani on 21-05-2024 to update Voided by and voided date when envelope is update as voided and create SPA Transaction request
    public static void updateTRStatus(List<dfsle__EnvelopeStatus__c> evList, Map<Id, dfsle__EnvelopeStatus__c> oldEvMap) {
        List<PropStrength__Transaction_Requests__c> updateTrList = new List<PropStrength__Transaction_Requests__c>();
        List<PropStrength__Transaction_Requests__c> insertTrList = new List<PropStrength__Transaction_Requests__c>();

        Id SPARecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('SPA Process').getRecordTypeId();

        Set<Id> trId = new Set<Id>();

        for(dfsle__EnvelopeStatus__c ev : evList) {
            if(ev.Transaction_Request__c != null && ev.dfsle__Status__c.containsIgnoreCase('voided') && ev.dfsle__Status__c != oldEvMap.get(ev.Id).dfsle__Status__c) {
                trId.add(ev.Transaction_Request__c);
            }
        }

        Map<Id, PropStrength__Transaction_Requests__c> trMap = new Map<Id, PropStrength__Transaction_Requests__c>();
        if(!trId.isEmpty()) {
            trMap = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id, PropStrength__Application_Booking__c FROM PropStrength__Transaction_Requests__c WHERE Id IN :trId]);
        }

        for(dfsle__EnvelopeStatus__c ev : evList) {
            if(!trMap.isEmpty() && ev.Transaction_Request__c != null && trMap.containsKey(ev.Transaction_Request__c) && trMap.get(ev.Transaction_Request__c).PropStrength__Application_Booking__c != null && ev.dfsle__Status__c.containsIgnoreCase('voided') && ev.dfsle__Status__c != oldEvMap.get(ev.Id).dfsle__Status__c) {
                updateTrList.add(new PropStrength__Transaction_Requests__c(Id=ev.Transaction_Request__c, PropStrength__Status__c = 'Voided', Voided_By__c = UserInfo.getUserId(), Voided_Date__c = System.Now()));
                insertTrList.add(new PropStrength__Transaction_Requests__c(RecordTypeId=SPARecordTypeId, PropStrength__Application_Booking__c = trMap.get(ev.Transaction_Request__c).PropStrength__Application_Booking__c));
            }
        }

        if(!updateTrList.isEmpty()) {
            update updateTrList;
        }
        if(!insertTrList.isEmpty()) {
            insert insertTrList;
        }
    }

    //Added by Nishank Manwani on 18-Sept-2024 to send mail to chrm after getting signature from broker
    public static void sendMailToChrmOnAccount(List<dfsle__EnvelopeStatus__c> envList, Map<Id, dfsle__EnvelopeStatus__c> oldEnvMap) {
        Set<Id> ledgerId = new Set<Id>();
        for(dfsle__EnvelopeStatus__c env : envList) {
            if(env.Broker_Ledger__c != null && env.dfsle__Status__c != null && env.dfsle__Status__c.containsIgnoreCase('Completed') && env.dfsle__Status__c != oldEnvMap.get(env.Id).dfsle__Status__c) {
                ledgerId.add(env.Broker_Ledger__c);
            }
        }

        if(!ledgerId.isEmpty()) {
            List<PropStrength__Broker_Ledger__c> ledgersRec = [SELECT Id, PropStrength__Broker_Account__c, PropStrength__Broker_Account__r.CHRM_Ops_Email__c, CreatedById FROM PropStrength__Broker_Ledger__c WHERE Id IN :ledgerId AND PropStrength__Broker_Account__c != null AND PropStrength__Broker_Account__r.CHRM_Ops_Email__c != null];
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE DeveloperName = 'Invoice_Signed' limit 1];
            for(PropStrength__Broker_Ledger__c ledRec : ledgersRec) {
                List<String> emailAddress = new List<String>();
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                String st = String.valueOf(ledRec.PropStrength__Broker_Account__r.CHRM_Ops_Email__c);
                emailAddress.add(st);
                emails.setWhatId(ledRec.Id);
                emails.setToAddresses(emailAddress);
                if(templatelist.size() > 0)
                    emails.setTemplateId(templatelist[0].Id);
                emails.setSaveAsActivity(true);
                emails.setTargetObjectId(ledRec.CreatedById);
                emails.setTreatTargetObjectAsRecipient(false);
                emaillist.add(emails);
            }
            
            
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
    //Added by Gourav Gour on 23-Sept-2024 to send mail to chrm after getting signature from broker
    public static void sendMailToChrmBrokerNotifyAccount(List<dfsle__EnvelopeStatus__c> envList, Map<Id, dfsle__EnvelopeStatus__c> oldEnvMap) {
        Set<Id> accId = new Set<Id>();
        for(dfsle__EnvelopeStatus__c env : envList) {
            if(env.Envelope_Type__c =='Broker Agreement' && env.Broker_Account__c != null && env.dfsle__Completed__c != null && env.dfsle__Completed__c != oldEnvMap.get(env.Id).dfsle__Completed__c) {
                accId.add(env.Broker_Account__c);
            }
        }

        if(!accId.isEmpty()) {
            List<Account> accountList = [SELECT Id, Channel_Relationship_Manager__c,CreatedById, Channel_Relationship_Manager__r.Email  FROM Account WHERE Id IN :accId AND Channel_Relationship_Manager__r.Email != null];
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE DeveloperName = 'Account_CHRM_Broker_Signed_Notified' limit 1];
            for(Account accRec : accountList) {
                List<String> emailAddress = new List<String>();
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                String st = String.valueOf(accRec.Channel_Relationship_Manager__r.Email);
                emailAddress.add(st);
                emails.setWhatId(accRec.Id);
                emails.setToAddresses(emailAddress);
                if(templatelist.size() > 0)
                    emails.setTemplateId(templatelist[0].Id);
                emails.setSaveAsActivity(true);
                emails.setTargetObjectId(accRec.CreatedById);
                emails.setTreatTargetObjectAsRecipient(false);
                emaillist.add(emails);
            }
            try{
                if(emaillist != null && emaillist.size()>0 ) {
                    Messaging.sendEmail(emaillist);
                }
            } catch(Exception ex){
                system.debug('===========Exception ============'+ex.getmessage());
                system.debug('===========Exception ============'+ex.getlinenumber());
            }
        }
    }
}