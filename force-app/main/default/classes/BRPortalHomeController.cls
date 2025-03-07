public without sharing class BRPortalHomeController {
    @AuraEnabled
    public static HomePageWrapper getHomePageContents() {
        List<User> usrList = new List<User>();
        List<Contact> contactList = new List<Contact>();
        List<Channel_Partner_Offers__c> channelOfferList = new List<Channel_Partner_Offers__c>();
        List<Customer_Offers__c> customerOfferList = new List<Customer_Offers__c>();
        List<PropStrength__Projects__c> latestProjectList = new List<PropStrength__Projects__c>();
        List<Announcements__c> announcementList = new List<Announcements__c>();
        List<String> eventsList = new List<String>();
        List<String> imageGallery = new List<String>();
        List<String> videoGallery = new List<String>();
        HomePageWrapper wrap = new HomePageWrapper();
        wrap.channelPartnerOffer = new List<Channel_Partner_Offers__c>();
        wrap.customerOffer = new List<Customer_Offers__c>();
        wrap.announcements = new List<Announcements__c>();
        wrap.latestProjects = new List<PropStrength__Projects__c>();
        String userId = UserInfo.getUserId();
        Integer availableProperyCount = 0;
        try {
            if(!String.isBlank(userId)) {
                usrList = [SELECT Id, ContactId FROM User 
                            WHERE Id =: userId AND 
                            ContactId != null 
                            ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(!usrList.isEmpty()) {
                contactList = [SELECT Id, Name, Birthdate 
                                FROM Contact 
                                WHERE Id =: usrList[0].ContactId 
                                ORDER BY CreatedDate DESC LIMIT 1];
            }
            if(!contactList.isEmpty() && 
                contactList[0].Birthdate != null) {
                Integer dayNumber = contactList[0].Birthdate.day();
                Integer monthNumber = contactList[0].Birthdate.month();
                Integer day_Number = System.today().day();
                Integer month_Number = System.today().month();
                wrap.displayBirthdayCard = (dayNumber == day_Number && monthNumber == month_Number) ? true : false;
                /*{
                    wrap.displayBirthdayCard = true;
                } else {
                    wrap.displayBirthdayCard = ;
                }*/
            } else {
                wrap.displayBirthdayCard = false;
            }
            channelOfferList = [SELECT Id, Offer_Description__c, Offer_Name__c 
                                FROM Channel_Partner_Offers__c 
                                WHERE IsActive__c = true 
                                ORDER BY CreatedDate DESC LIMIT 49999];
            customerOfferList = [SELECT Id, Offer_Description__c, Offer_Name__c 
                                    FROM Customer_Offers__c 
                                    WHERE IsActive__c = true 
                                    ORDER BY CreatedDate DESC LIMIT 49999];
            announcementList = [SELECT Id, Announcement_Title__c, Announcement_Description__c 
                                    FROM Announcements__c 
                                    WHERE IsActive__c = true 
                                    ORDER BY CreatedDate DESC LIMIT 49999];
            latestProjectList = [SELECT Id, Name, PropStrength__Image_Path__c, 
                                    Project_Image__c, 
                                    Project_Location__c, PropStrength__Description__c, 
                                    (SELECT Id FROM PropStrength__Property__r 
                                    WHERE PropStrength__Unit_Status__c = 'Available' AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Allotted__c = false ) 
                                    FROM PropStrength__Projects__c 
                                        WHERE PropStrength__Active__c = true AND 
                                        Hide_From_3rd_Party__c = false AND 
                                        Master_Project__r.Hide_From_3rd_Party__c = false 
                                        ORDER BY CreatedDate DESC LIMIT 1];
            if(!channelOfferList.isEmpty()) {
                wrap.channelPartnerOffer = channelOfferList;
            }
            if(!customerOfferList.isEmpty()) {
                wrap.customerOffer = customerOfferList;
            }
            if(!announcementList.isEmpty()) {
                wrap.announcements = announcementList;
            }
            if(!latestProjectList.isEmpty()) {
                wrap.latestProjects = latestProjectList;
                if(!latestProjectList[0].PropStrength__Property__r.isEmpty()) {
                    availableProperyCount = latestProjectList[0].PropStrength__Property__r.size();
                }
            }
            wrap.unitCount = availableProperyCount;
            if(!contactList.isEmpty()) {
                wrap.userName = contactList[0].Name;
            }
            //wrap.userName = UserInfo.getName();
            for(Sobha_Event__c se : [SELECT Id, Name 
                                        FROM Sobha_Event__c 
                                        WHERE IsActive__c = true 
                                            ORDER BY CreatedDate DESC LIMIT 999]) {
                eventsList.add(se.Name);
            }
            wrap.eventsList = eventsList;
            System.debug('===> eventsList ' + eventsList);
            //for test class
            /*if(Test.isRunningTest()) {
                for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, ContentDownloadUrl, 
                                                RelatedRecord.Name 
                                                FROM ContentDistribution LIMIT 49999]) {
                    if(cd.ContentVersion.FileType == 'JPEG' || cd.ContentVersion.FileType == 'JPG' || cd.ContentVersion.FileType == 'GIF' || cd.ContentVersion.FileType == 'PNG' || cd.ContentVersion.FileType == 'SVG') {
                        imageGallery.add(cd.ContentDownloadUrl);
                    }
                    if(cd.ContentVersion.FileType == 'MP4' || cd.ContentVersion.FileType == 'MOV' || cd.ContentVersion.FileType == 'AVI' || cd.ContentVersion.FileType == 'WMV') {
                        videoGallery.add(cd.ContentDownloadUrl);
                    }
                } 
            } else */
            if(!eventsList.isEmpty()) {
                for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, ContentDownloadUrl, 
                                                RelatedRecord.Name 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecord.Name =: eventsList[0] 
                                                    ORDER BY Createddate DESC]) {
                    if(cd.ContentVersion.FileType == 'JPEG' || cd.ContentVersion.FileType == 'JPG' || cd.ContentVersion.FileType == 'GIF' || cd.ContentVersion.FileType =='PNG' || cd.ContentVersion.FileType == 'SVG') {
                        imageGallery.add(cd.ContentDownloadUrl);
                    }
                    if(cd.ContentVersion.FileType == 'MP4' || cd.ContentVersion.FileType == 'MOV' || cd.ContentVersion.FileType == 'AVI' || cd.ContentVersion.FileType == 'WMV') {
                        videoGallery.add(cd.ContentDownloadUrl);
                    }
                }
            }
            wrap.imageGallery = imageGallery;
            wrap.videoGallery = videoGallery;
        } catch(Exception ex) {  throw new AuraHandledException(ex.getMessage());
        }
        return wrap;
    }
    @AuraEnabled
    public static HomePageWrapper getGallery(String eventName) {
        HomePageWrapper wrap = new HomePageWrapper();
        List<String> imageGallery = new List<String>();
        List<String> videoGallery = new List<String>();
        /*if(Test.isRunningTest()) {
            for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, 
                                                ContentDownloadUrl, RelatedRecord.Name 
                                                FROM ContentDistribution 
                                                ORDER BY CreatedDate DESC LIMIT 49999]) {
                if(cd.ContentVersion.FileType == 'JPEG' || cd.ContentVersion.FileType == 'JPG' || cd.ContentVersion.FileType == 'GIF' || cd.ContentVersion.FileType == 'PNG' || cd.ContentVersion.FileType == 'SVG') {
                    imageGallery.add(cd.ContentDownloadUrl);
                }
                if(cd.ContentVersion.FileType == 'MP4' || cd.ContentVersion.FileType == 'MOV' || cd.ContentVersion.FileType == 'AVI' || cd.ContentVersion.FileType == 'WMV') {
                    videoGallery.add(cd.ContentDownloadUrl);
                }
            }
        } else 
        */
        if(!String.isBlank(eventName)) {
            for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, 
                                            ContentDownloadUrl, RelatedRecord.Name 
                                            FROM ContentDistribution 
                                            WHERE RelatedRecord.Name =: eventName 
                                            ORDER BY createddate DESC]) {
                if(cd.ContentVersion.FileType == 'JPEG' || cd.ContentVersion.FileType == 'JPG' || cd.ContentVersion.FileType == 'GIF' || cd.ContentVersion.FileType == 'PNG' || cd.ContentVersion.FileType == 'SVG') {
                    imageGallery.add(cd.ContentDownloadUrl);
                }
                if(cd.ContentVersion.FileType == 'MP4' || cd.ContentVersion.FileType == 'MOV' || cd.ContentVersion.FileType == 'AVI' || cd.ContentVersion.FileType == 'WMV') {
                    videoGallery.add(cd.ContentDownloadUrl);
                }
            }
        }
        System.debug('===> imageGallery ' + imageGallery.size());
        wrap.imageGallery = imageGallery;
        wrap.videoGallery = videoGallery;
        return wrap;
    }
    public class HomePageWrapper {
        @AuraEnabled
        public List<Channel_Partner_Offers__c> channelPartnerOffer;
        @AuraEnabled
        public List<Customer_Offers__c> customerOffer;
        @AuraEnabled
        public List<Announcements__c> announcements;
        @AuraEnabled
        public List<PropStrength__Projects__c> latestProjects;
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public Integer unitCount;
        @AuraEnabled
        public Boolean displayBirthdayCard;
        @AuraEnabled
        public List<String> imageGallery;
        @AuraEnabled
        public List<String> videoGallery;
        @AuraEnabled
        public List<String> eventsList;
    }
}