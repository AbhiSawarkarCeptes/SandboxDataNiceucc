/*********************************************************************
 * Class Name  :   BookingFormDocusignHandler1Clone
 * Description :   Helper Class of Flow Send Booking Form for Docusign Clone (Flow)
 * Created Date:   12/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 12/01/2024
 *********************************************************************/
public with sharing class BookingFormDocusignHandler1Clone {
    @InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> appBookingIds) {
        Id mySourceId = appBookingIds[0];
        List<String> envelopExist = new List<String>();
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c FROM dfsle__EnvelopeStatus__c where Application_Booking__c =:mySourceId]) {
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