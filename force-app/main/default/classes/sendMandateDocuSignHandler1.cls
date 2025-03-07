public with sharing class sendMandateDocuSignHandler1 
{
	@InvocableMethod
    	public static List<String> sendEnvelopeMethod1(List<Id> bookingIds)
        {
        Id mySourceId = bookingIds[0];
        List<String> envelopExist = new List<String>();
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c  from dfsle__EnvelopeStatus__c where Channel_Partner__c =:mySourceId])
        {
          If(dstatus.Envelope_Type__c =='Mandate Letter')
          {  
              If(dstatus.dfsle__Status__c == 'Sent' || dstatus.dfsle__Status__c=='Delivered') 
              {
                  envelopExist.clear();
                  envelopExist.add('True');
                  break;
              }
          }
        }
        	return envelopExist;
    	}
}