public without sharing class BrokerPortalNotificationController {
    
    public static void createNotification(list<NotificationWrapper> wrapList){
        try{
            list<Notification__c> notificationListToInsert = new list<Notification__c>();
            for(NotificationWrapper wrap : wrapList){
                Notification__c n = new Notification__c();
                n.Object_Type__c = wrap.objectType;
                n.Title__c = wrap.title;
                n.Description__c = wrap.description;
                n.CP_SC_ID__c = wrap.brokerId;
                notificationListToInsert.add(n);
            }
            if(notificationListToInsert.size()>0){
                insert notificationListToInsert;
            }
        }
        catch(Exception e){
            system.debug('createNotification exception msg: '+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<NotificationData> getNotifications(){
        String userContId=DynamicObjectDataForPortalLWCController.getContactInfo();
        list<Contact> c = [select Id,Last_Notification_Seen__c from Contact where Id =: userContId];
        list<NotificationData> notifications = new list<NotificationData>();
        list<Notification__c> notificationsList = [select Id,Name,CreatedDate,CP_SC_ID__c,Description__c,Object_Type__c,Title__c from Notification__c order by createddate desc];
        for(Notification__c n : notificationsList){
            NotificationData data;
            if(c.size()>0 && (c[0].Last_Notification_Seen__c==null || (c[0].Last_Notification_Seen__c!=null && n.CreatedDate > c[0].Last_Notification_Seen__c))){
                 data = new NotificationData(n.Object_Type__c,n.Title__c,n.Description__c,n.CreatedDate.format(),false);
            }
            else{
                 data = new NotificationData(n.Object_Type__c,n.Title__c,n.Description__c,n.CreatedDate.format(),true);
            }
            notifications.add(data);
        }
        return notifications;
    }
    
    @AuraEnabled
    public static Offers getOffers(){
        Offers o = new Offers();
        o.channelPartnerOffers = [select Id,Offer_Name__c,Offer_Description__c,Offer_Image__c,CreatedDate from Channel_Partner_Offers__c
                                  where IsActive__c = true 
                                  order by createddate desc];
        o.customerOffers = [select Id,Offer_Name__c,Offer_Description__c,Offer_Image__c,CreatedDate from Customer_Offers__c WHERE IsActive__c = true
                            order by createddate desc];
        return o;
    }

    @AuraEnabled
    public static void updateLastSeen(){
        try{
            String userContId=DynamicObjectDataForPortalLWCController.getContactInfo();
            Contact c = new Contact(Id=userContId,Last_Notification_Seen__c=system.now());
            update c;
        }
        catch(Exception e){}
    }
    
    public class NotificationWrapper{
        public string objectType;
        public string title;
        public string description;
        public string brokerId;
        public NotificationWrapper(string objectType, string title, string description, string brokerId){
            this.objectType=objectType;
            this.title=title;
            this.description=description;
            this.brokerId=brokerId;
        }
    }
    
    public class NotificationData{
        @AuraEnabled public string status;
        @AuraEnabled public string header;
        @AuraEnabled public string description;
        @AuraEnabled public string dateStr;
        @AuraEnabled public boolean isOpened;
        public NotificationData(string status, string header, string description, string dateStr, boolean isOpened){
            this.status=status;
            this.header=header;
            this.description=description;
            this.dateStr=dateStr;
            this.isOpened=isOpened;
        }
    }
    
    public class Offers {
        @AuraEnabled public list<Customer_Offers__c> customerOffers;
        @AuraEnabled public list<Channel_Partner_Offers__c> channelPartnerOffers;
        
        public Offers(){
            this.customerOffers = new list<Customer_Offers__c>();
            this.channelPartnerOffers = new list<Channel_Partner_Offers__c>();
        }
    }
}