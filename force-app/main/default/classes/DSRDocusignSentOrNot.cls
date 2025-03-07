/*********************************************************************
 * Class Name  :   DSRDocusignSentOrNot
 * Description :   Helper Class of Flow Send DSR For Docusign (Flow)
 * Created Date:   12/02/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 12/02/2024
 *********************************************************************/
public class DSRDocusignSentOrNot {
	@InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> trIds) {
        Id mySourceId = trIds[0];
        List<String> envelopExist = new List<String>(); 
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c  from dfsle__EnvelopeStatus__c where Transaction_Request__c =:mySourceId]) {
            If(dstatus.Envelope_Type__c =='DSR') {  
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