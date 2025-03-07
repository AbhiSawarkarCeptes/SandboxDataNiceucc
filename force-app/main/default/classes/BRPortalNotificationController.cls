public without sharing class BRPortalNotificationController {
    public static void createNotification(List<NotificationWrapper> wrapList) {
        try {
            List<Notification__c> notificationListToInsert = new List<Notification__c>();
            for(NotificationWrapper wrap : wrapList) {
                Notification__c n = new Notification__c();
                n.Object_Type__c = wrap.objectType;
                n.Title__c = wrap.title;
                n.Description__c = wrap.description;
                n.CP_SC_ID__c = wrap.brokerId;
                n.IsActive__c = wrap.is_Active;
                notificationListToInsert.add(n);
            }
            if(notificationListToInsert.size()>0) {
                insert notificationListToInsert;
            }
        } catch(Exception e) {
            system.debug('createNotification exception msg: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static List<NotificationData> getNotifications() {
        List<User> lstUser = new List<User>();
        String userName = UserInfo.getUserId();
        if(!String.isBlank(userName)) {
            lstUser = [SELECT Id, ContactId, Contact.Last_Notification_Seen__c 
                                FROM User 
                                WHERE Id =: userName AND 
                                    ContactId != null 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        }
        List<NotificationData> notifications = new List<NotificationData>();
        for(Notification__c n : [SELECT Id, Name, CreatedDate, CP_SC_ID__c, 
                                    Description__c, Object_Type__c, Title__c 
                                    FROM Notification__c 
                                    WHERE IsActive__c = true 
                                    ORDER BY CreatedDate DESC LIMIT 49999]) {
            NotificationData data;
            if(lstUser.size()>0 && 
                (lstUser[0].Contact.Last_Notification_Seen__c == null || 
                (lstUser[0].Contact.Last_Notification_Seen__c != null && n.CreatedDate > lstUser[0].Contact.Last_Notification_Seen__c))) {
                data = new NotificationData(n.Object_Type__c, n.Title__c, n.Description__c, n.CreatedDate.format(),false);
            } else {
                data = new NotificationData(n.Object_Type__c, n.Title__c, n.Description__c, n.CreatedDate.format(), true);
            }
            notifications.add(data);
        }
        return notifications;
    }
    @AuraEnabled
    public static List<OfferWrapper> getOffers() {
        List<Channel_Partner_Offers__c> channelList = new List<Channel_Partner_Offers__c>();
        List<Customer_Offers__c> customerList = new List<Customer_Offers__c>();
        List<OfferWrapper> offerWrapperList = new List<OfferWrapper>();
        channelList = [SELECT Id, Offer_Name__c, Offer_Description__c, 
                            Offer_Image__c, CreatedDate 
                            FROM Channel_Partner_Offers__c 
                            WHERE IsActive__c = true 
                                ORDER BY Createddate DESC LIMIT 999];
        customerList = [SELECT Id, Offer_Name__c, Offer_Description__c, Offer_Image__c, 
                            CreatedDate 
                            FROM Customer_Offers__c 
                            WHERE IsActive__c = true
                                ORDER BY Createddate DESC LIMIT 999];
        if(!channelList.isEmpty()) {
            for(Channel_Partner_Offers__c channel : channelList) {
                OfferWrapper channelWrap = new OfferWrapper();
                channelWrap.isOfferChannel = true;
                channelWrap.isOfferCustomer = false;
                channelWrap.channelRecord = channel;
                channelWrap.customerRecord = new Customer_Offers__c();
                channelWrap.offerDateTime = channel.CreatedDate;
                offerWrapperList.add(channelWrap);
            }
        }
        if(!customerList.isEmpty()) {
            for(Customer_Offers__c cust : customerList) {
                OfferWrapper customerWrap = new OfferWrapper();
                customerWrap.isOfferChannel = false;
                customerWrap.isOfferCustomer = true;
                customerWrap.channelRecord = new Channel_Partner_Offers__c();
                customerWrap.customerRecord = cust;
                customerWrap.offerDateTime = cust.CreatedDate;
                offerWrapperList.add(customerWrap);
            }
        }
        if(!offerWrapperList.isEmpty()) {
            offerWrapperList.sort();
        }
        /*<ChannelPartnerWrapper> channelWrapperList = new List<ChannelPartnerWrapper>();
        List<CustomerWrapper> customerWrapperList = new List<CustomerWrapper>();
        Offers o = new Offers();
        o.channelPartnerOffers = channelWrapperList;
        o.customerOffers = customerWrapperList;
        channelList = [SELECT Id, Offer_Name__c, Offer_Description__c, 
                            Offer_Image__c, CreatedDate 
                            FROM Channel_Partner_Offers__c 
                            WHERE IsActive__c = true 
                                ORDER BY Createddate DESC LIMIT 999];
        customerList = [SELECT Id, Offer_Name__c, Offer_Description__c, Offer_Image__c, 
                            CreatedDate 
                            FROM Customer_Offers__c 
                            WHERE IsActive__c = true
                                ORDER BY Createddate DESC LIMIT 999];
        if(!channelList.isEmpty()) {
            for(Channel_Partner_Offers__c channel : channelList) {
                ChannelPartnerWrapper ch = new ChannelPartnerWrapper();
                ch.channelRecord = channel;
                ch.channelDate = channel.CreatedDate.format();
                channelWrapperList.add(ch);
            }
        }
        if(!channelWrapperList.isEmpty()) {
            o.channelPartnerOffers = channelWrapperList;
        }
        if(!customerList.isEmpty()) {
            for(Customer_Offers__c cust : customerList) {
                CustomerWrapper custom = new CustomerWrapper();
                custom.customerRecord = cust;
                custom.customerDate = cust.CreatedDate.format();
                customerWrapperList.add(custom);
            }
        }
        if(!customerWrapperList.isEmpty()) {
            o.customerOffers = customerWrapperList;
        }
        return o;*/
        return offerWrapperList;
    }
    @AuraEnabled
    public static void updateLastSeen() {
        try {
            List<User> lstUser = new List<User>();
            String userName = UserInfo.getUserId();
            if(!String.isBlank(userName)) {
                lstUser = [SELECT Id, ContactId 
                                    FROM User 
                                    WHERE Id =: userName AND 
                                        ContactId != null 
                                        ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(!lstUser.isEmpty()) {
                Contact c = new Contact(Id=lstUser[0].ContactId, Last_Notification_Seen__c = system.now());
                update c;
            }
        }
        catch(Exception e){}
    }
    public class NotificationWrapper {
        public String objectType;
        public String title;
        public String description;
        public String brokerId;
        public Boolean is_Active;
        public NotificationWrapper(String objectType, String title, String description, String brokerId, Boolean is_Active) {
            this.objectType = objectType;
            this.title = title;
            this.description = description;
            this.brokerId = brokerId;
            this.is_Active = is_Active;
        }
    }
    public class NotificationData {
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string header;
        @AuraEnabled
        public string description;
        @AuraEnabled
        public string dateStr;
        @AuraEnabled
        public boolean isOpened;
        public NotificationData(string status, string header, string description, string dateStr, boolean isOpened) {
            this.status = status;
            this.header = header;
            this.description = description;
            this.dateStr = dateStr;
            this.isOpened = isOpened;
        }
    }
    /*public class Offers {
        @AuraEnabled
        public List<CustomerWrapper> customerOffers;
        @AuraEnabled
        public List<ChannelPartnerWrapper> channelPartnerOffers;
        public Offers() {
            this.customerOffers = new List<CustomerWrapper>();
            this.channelPartnerOffers = new List<ChannelPartnerWrapper>();
        }
    }
    public class ChannelPartnerWrapper {
        @AuraEnabled
        public Channel_Partner_Offers__c channelRecord;
        @AuraEnabled
        public String channelDate;
    }
    public class CustomerWrapper {
        @AuraEnabled
        public Customer_Offers__c customerRecord;
        @AuraEnabled
        public String customerDate;
    }*/
    public class OfferWrapper implements Comparable {
        @AuraEnabled
        public Boolean isOfferChannel;
        @AuraEnabled
        public Boolean isOfferCustomer;
        @AuraEnabled
        public Channel_Partner_Offers__c channelRecord;
        @AuraEnabled
        public Customer_Offers__c customerRecord;
        @AuraEnabled
        public DateTime offerDateTime;
        public Integer compareTo(Object instance) {
            OfferWrapper that = (OfferWrapper)instance;
            if(this.offerDateTime < that.offerDateTime) return 1;
            if(this.offerDateTime > that.offerDateTime) return -1;
            return 0;
        }
    }
}