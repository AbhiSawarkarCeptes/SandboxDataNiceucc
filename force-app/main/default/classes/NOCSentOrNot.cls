/*********************************************************************
 * Class Name  :   NOCSentOrNot
 * Description :   Helper Class of Flow Send NOC For Docusign (Flow)
 * Created Date:   04/04/2024
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Gourav Gour
   Last Modified By :   Gourav Gour 04/04/2024
 *********************************************************************/
public class NOCSentOrNot {
	@InvocableMethod
    public static List<String> sendEnvelopeMethod1(List<Id> trIds) {
        Id mySourceId = trIds[0];
        List<String> envelopExist = new List<String>(); 
        for (dfsle__EnvelopeStatus__c dstatus : [SELECT Id, dfsle__Status__c,Envelope_Type__c  FROM dfsle__EnvelopeStatus__c WHERE Transaction_Request__c =:mySourceId]) {
            If(dstatus.Envelope_Type__c =='NOC TR') {  
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