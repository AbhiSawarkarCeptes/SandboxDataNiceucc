public with sharing class BookingFormDocusignHandler1 
{
    	@InvocableMethod
    	public static List<String> sendEnvelopeMethod1(List<Id> bookingIds)
        {
        Id mySourceId = bookingIds[0];
        List<String> envelopExist = new List<String>();
        //envelopExist.add('False');
        for (dfsle__EnvelopeStatus__c dstatus : [Select Id, dfsle__Status__c,Envelope_Type__c  from dfsle__EnvelopeStatus__c where Booking__c =:mySourceId])
        {
          If(dstatus.Envelope_Type__c =='Booking Form')
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