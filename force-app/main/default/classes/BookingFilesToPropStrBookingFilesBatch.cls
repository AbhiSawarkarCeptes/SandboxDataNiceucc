public class BookingFilesToPropStrBookingFilesBatch implements Database.Batchable<sObject> 
{
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug('BookingFilesToPropStrBookingFilesBatch - Start Menthod');
        String query='SELECT Id from Booking__c';
        //String query='SELECT Id from Booking__c where Name in (\'B-3116\',\'B-14824\',\'B-13321\',\'B-15855\',\'B-24246\')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Booking__c> legBookingList) 
    {
        System.debug('BookingFilesToPropStrBookingFilesBatch - Execute Menthod');
        Map<Id, Booking__c> legBookingMap = new Map<Id, Booking__c>(legBookingList);
        Set<Id> legacyIds= new Set<Id>();
        
        Map<Id, List<Id>> mapContentDocLink = new Map<Id, List<Id>>();
        List<ContentDocumentLink> newContentDocLinkList = new List<ContentDocumentLink>();
        if(!legBookingMap.isEmpty())
        {
            System.debug('Legacy Bookings Found');
            legacyIds=legBookingMap.keySet();
			for(ContentDocumentLink cdl : [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :legacyIds order by SystemModstamp])
            {
             System.debug('Content Documents Found');
              if(mapContentDocLink.containsKey(cdl.LinkedEntityId)) {
                List<Id> conDocIds = mapContentDocLink.get(cdl.LinkedEntityId);
                conDocIds.add(cdl.ContentDocumentId);
                mapContentDocLink.put(cdl.LinkedEntityId, conDocIds);
                } else {
                    mapContentDocLink.put(cdl.LinkedEntityId, new List<Id> {cdl.ContentDocumentId});
                }  
            }
        }
        If(!mapContentDocLink.isEmpty())
        {
            for(PropStrength__Application_Booking__c prStAppBook : [SELECT Id,Legacy_Booking_Id__c FROM PropStrength__Application_Booking__c WHERE Legacy_Booking_Id__c IN :legacyIds])
            {
             System.debug('PropStrength Bookings Found');
             for(Id id : mapContentDocLink.get(prStAppBook.Legacy_Booking_Id__c))
             {
                 ContentDocumentLink link = new ContentDocumentLink();
                 link.ContentDocumentId =id;
                 link.LinkedEntityId = prStAppBook.Id;
                 link.ShareType = 'V'; 
                 newContentDocLinkList.add(link); 
             } 
            }
        }
        If(!newContentDocLinkList.isEmpty())
        {
            Insert newContentDocLinkList;
        }
    }
    public void finish(Database.BatchableContext BC) 
    {
        System.debug('BookingFilesToPropStrBookingFilesBatch - Finish Menthod');  
    }
}