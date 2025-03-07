/*********************************************************************
* Class Name  :   DSPADocusignSentOrNot
* Description :   Helper Class of Flow Send DSPA For Docusign (Flow)
* Created Date:   13/02/2024
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 13/02/2024
*********************************************************************/
public class DSPADocusignSentOrNot {
    @InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> trIds) {
        Id mySourceId = trIds[0];
        List<String> envelopExist = new List<String>(); 
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c  from dfsle__EnvelopeStatus__c where Transaction_Request__c =:mySourceId]) {
            If(dstatus.Envelope_Type__c =='DSPA') {  
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