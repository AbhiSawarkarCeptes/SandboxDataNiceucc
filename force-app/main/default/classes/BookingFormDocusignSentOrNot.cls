/*********************************************************************
* Class Name  :   public with sharing class BookingFormDocusignSentOrNot {
* Description :   Helper Class of Flow Send Booking Form For Docusign (Flow)
* Created Date:   16/02/2024
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 16/02/2024
*********************************************************************/
public class BookingFormDocusignSentOrNot {
    @InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> trIds) {
        Id mySourceId = trIds[0];
        System.debug('test----');
        List<String> envelopExist = new List<String>(); 
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c  from dfsle__EnvelopeStatus__c where Application_Booking__c =:mySourceId]) {
            If(dstatus.Envelope_Type__c =='Booking Form') {  
                If(dstatus.dfsle__Status__c == 'Sent' || dstatus.dfsle__Status__c=='Delivered') {
                    envelopExist.clear();
                    envelopExist.add('True');
                    break;
                }
            }
        }
        return envelopExist;
    }
}