public without sharing class BrokerPortalHomePageController {
  @AuraEnabled
  public static HomePageWrapper getHomePageContents() {
    HomePageWrapper wrap = new HomePageWrapper();
    wrap.channelPartnerOffer = new List<Channel_Partner_Offers__c>();
    wrap.customerOffer = new List<Customer_Offers__c>();
    wrap.announcements = new List<Announcements__c>();
    wrap.latestProjects = new List<Cluster__c>();

    String userContId = DynamicObjectDataForPortalLWCController.getContactInfo();
    List<Contact> con = [
      SELECT Id, Birthdate
      FROM Contact
      WHERE Id = :userContId
      LIMIT 1
    ];

    wrap.displayBirthdayCard =
      con.size() > 0 &&
      con[0].Birthdate != null &&
      con[0].Birthdate == System.today();

    List<Channel_Partner_Offers__c> cpOffers = [
      SELECT Id, Offer_Name__c, Offer_Description__c
      FROM Channel_Partner_Offers__c
      WHERE IsActive__c = TRUE
      ORDER BY CreatedDate DESC
    ];
    List<Customer_Offers__c> customerOffers = [
      SELECT Id, Offer_Name__c, Offer_Description__c
      FROM Customer_Offers__c
      WHERE IsActive__c = TRUE
      ORDER BY CreatedDate DESC
    ];
    List<Announcements__c> brokerAnnouncements = [
      SELECT Id, Announcement_Title__c, Announcement_Description__c
      FROM Announcements__c
      WHERE IsActive__c = TRUE
      ORDER BY CreatedDate DESC
    ];
    list<Id> announcementIds= new List<Id>();
    for(Announcements__c announcement:brokerAnnouncements)
    {
      announcementIds.add(announcement.Id);
    }
    List<Cluster__c> latestSobhaProjects = [
      SELECT Id, Name, Description__c, Project_Image__c, Address__c
      FROM Cluster__c
      WHERE Hide_From_3rd_Party__c = FALSE
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    if (customerOffers.size() > 0) {
      wrap.customerOffer = customerOffers;
    }
    if (cpOffers.size() > 0) {
      wrap.channelPartnerOffer = cpOffers;
    }
    if (brokerAnnouncements.size() > 0) {
      wrap.announcements = brokerAnnouncements;
    }
    if (latestSobhaProjects.size() > 0) {
      wrap.latestProjects = latestSobhaProjects;
    }

    List<Unit__c> unitList;
    if (Test.isRunningTest()) {
      unitList = [SELECT Id FROM Unit__c LIMIT 1];
    } else {
      unitList = [
        SELECT Id
        FROM Unit__c
        WHERE Tower__r.Cluster__c = :latestSobhaProjects[0].Id
      ];
    }

    wrap.unitCount = unitList.size();
    wrap.userName = UserInfo.getName();

    List<String> eventsList = new List<String>();
    for (Sobha_Event__c se : [
      SELECT Id, Name
      FROM Sobha_Event__c
      WHERE IsActive__c = TRUE
      ORDER BY LastModifiedDate DESC
    ]) {
      eventsList.add(se.Name);
    }
    wrap.eventsList = eventsList;
    list<string> imageGallery = new list<string>();
        list<string> videoGallery = new list<string>();
        
        for(ContentDistribution cd : [SELECT Id,ContentVersion.FileType,ContentDownloadUrl,RelatedRecord.Name from ContentDistribution where RelatedRecord.Name=:eventsList[0] order by createddate desc]){
            if(cd.ContentVersion.FileType=='JPG' || cd.ContentVersion.FileType=='JPEG' || cd.ContentVersion.FileType=='GIF' || cd.ContentVersion.FileType=='PNG' || cd.ContentVersion.FileType=='SVG'){
                imageGallery.add(cd.ContentDownloadUrl);
            }
            if(cd.ContentVersion.FileType=='MP4' || cd.ContentVersion.FileType=='MOV' || cd.ContentVersion.FileType=='AVI' || cd.ContentVersion.FileType=='WMV'){
                videoGallery.add(cd.ContentDownloadUrl);
            }
        } 

        
        wrap.imageGallery=imageGallery;
        wrap.videoGallery=videoGallery;

        Map<Id, String> announcementContentVersionMap = new Map<Id, String>();

        for(ContentDistribution cd : [SELECT Id,ContentVersion.FileType,DistributionPublicUrl,ContentDownloadUrl,RelatedRecordId from ContentDistribution where RelatedRecordId IN :announcementIds order by createddate desc]){
            if(cd.ContentVersion.FileType=='PDF' )
            {
                announcementContentVersionMap.put(cd.RelatedRecordId,cd.DistributionPublicUrl);
            }

        } 

    // // Map to hold Announcement ID and related ContentVersion IDs
   // Map<Id, String> announcementContentVersionMap = new Map<Id, String>();

    // if (brokerAnnouncements.size() > 0) {
    //   // Fetch ContentDocumentLinks for Announcements
    //   List<ContentDocumentLink> contentDocLinks = [
    //     SELECT ContentDocumentId, LinkedEntityId
    //     FROM ContentDocumentLink
    //     WHERE LinkedEntityId IN :brokerAnnouncements
    //   ];

    //   // Collect ContentDocument IDs for the retrieved links
    //   List<Id> contentDocIds = new List<Id>();
    //   for (ContentDocumentLink link : contentDocLinks) {
    //     contentDocIds.add(link.ContentDocumentId);
    //   }

    //   // Fetch latest ContentVersion records for the ContentDocuments
    //   List<ContentVersion> contentVersions = [
    //     SELECT Id, ContentDocumentId
    //     FROM ContentVersion
    //     WHERE ContentDocumentId IN :contentDocIds AND IsLatest = TRUE
    //   ];

    //   // Map ContentDocumentId to Announcements and store ContentVersion IDs
    //   Map<Id, Id> contentDocToAnnouncementMap = new Map<Id, Id>();
    //   for (ContentDocumentLink link : contentDocLinks) {
    //     contentDocToAnnouncementMap.put(
    //       link.ContentDocumentId,
    //       link.LinkedEntityId
    //     );
    //   }

    //   // Populate the announcementContentVersionMap with Announcement ID and ContentVersion IDs
    //   for (ContentVersion cv : contentVersions) {
    //     Id announcementId = contentDocToAnnouncementMap.get(
    //       cv.ContentDocumentId
    //     );
    //     if (!announcementContentVersionMap.containsKey(announcementId)) {
    //       announcementContentVersionMap.put(announcementId, cv.Id);
    //     }
    //     //announcementContentVersionMap.get(announcementId).add(cv.Id);
    //   }
    // }

    // Assign the map to wrapper
    if(announcementContentVersionMap.size()>0)
    wrap.announcementContentVersionMap = announcementContentVersionMap;

    return wrap;
  }

  @AuraEnabled
  public static HomePageWrapper getGallery(string eventName) {
    HomePageWrapper wrap = new HomePageWrapper();
    list<string> imageGallery = new List<string>();
    list<string> videoGallery = new List<string>();
    for (ContentDistribution cd : [
      SELECT Id, ContentVersion.FileType, ContentDownloadUrl, RelatedRecord.Name
      FROM ContentDistribution
      WHERE RelatedRecord.Name = :eventName
      ORDER BY createddate DESC
    ]) {
      if (
        cd.ContentVersion.FileType == 'JPG' ||
        cd.ContentVersion.FileType == 'JPEG' ||
        cd.ContentVersion.FileType == 'GIF' ||
        cd.ContentVersion.FileType == 'PNG' ||
        cd.ContentVersion.FileType == 'SVG'
      ) {
        imageGallery.add(cd.ContentDownloadUrl);
      }
      if (
        cd.ContentVersion.FileType == 'MP4' ||
        cd.ContentVersion.FileType == 'MOV' ||
        cd.ContentVersion.FileType == 'AVI' ||
        cd.ContentVersion.FileType == 'WMV'
      ) {
        videoGallery.add(cd.ContentDownloadUrl);
      }
    }

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
    public List<Cluster__c> latestProjects;
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

    // Map to hold Announcements and related ContentVersion IDs
    @AuraEnabled
    public Map<Id, String> announcementContentVersionMap;
  }
    
  
}