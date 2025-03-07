//Updated production code after code compare
//Nov 1 Overridden the code from Prod
public without sharing class PortalBrokerEventsController {
  private static final List<String> ALLOWED_MEDIA_TYPES = new List<String>{
    'webm',
    'mp4',
    'mov',
    'm4v'
  };
  public static String getContactInfo() {
    String userId = UserInfo.getUserId();
    User usr;
    try {
      usr = [SELECT Id, ContactId FROM User WHERE Id = :userId LIMIT 1];
    } catch (Exception ex) {
      system.debug('exception ' + ex);
      throw new AuraHandledException(ex.getMessage());
    }
    if (usr.ContactId != null) {
      return usr.ContactId;
    } else {
      return null;
    }
  }
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getEventsDetails(
    String recType,
    String fromDOEvent,
    String toDOEvent,
    String category,
    String year
  ) {
    Integer apartmentCount = 0, villasCount = 0;
    String userContId = getContactInfo();
    Map<String, Object> result = new Map<String, Object>();
    List<Events__c> EventsList = new List<Events__c>();
    Integer userRecordCount = 0;
    //List<Applicant_Details__c> listApplicationDetail;
    string filter = '';

    if (String.isNotBlank(recType)) {
      filter = filter + 'recordType.Name = \'' + recType + '\'';
    }
    if (String.isNotBlank(fromDOEvent) && String.isNotBlank(toDOEvent)) {
      filter =
        filter +
        ' AND Date_Of_Event__c >= ' +
        fromDOEvent +
        ' AND Date_Of_Event__c <= ' +
        toDOEvent +
        '';
    } else if (String.isNotBlank(category)) {
      if (category.containsIgnoreCase('Upcoming')) {
        DateTime dToday = DateTime.now();
        String dateStr = dToday.format('yyyy-MM-dd');
        filter = filter + ' AND Date_Of_Event__c > ' + dateStr + '';
      }

      if (category.containsIgnoreCase('Completed')) {
        DateTime dToday = DateTime.now();
        String dateStr = dToday.format('yyyy-MM-dd');
        filter = filter + ' AND Date_Of_Event__c < ' + dateStr + '';
      }
    } else if (String.isNotBlank(year)) {
      filter = filter + ' AND CALENDAR_YEAR(Date_Of_Event__c) =' + year + ''; // the year hard coded as it is required
    } else {
      filter = filter + ' AND CALENDAR_YEAR(Date_Of_Event__c) =2024';
    }
    if (filter.startsWith('AND')) {
      filter = filter.substring(4);
    }
    if (String.isNotBlank(filter))
      filter = ' where ' + filter;
    //string  qry='Select Id,Name,Venue_Video_Shoot__c,Collateral_Uploaded__c,Campaign_Leads__c,Campaign_Lead_7_days_before_event__c,Sales_Manager__r.Name,Sales_Manager__r.FirstName,Sales_Manager__r.LastName,Sales_Director__c,Sales_Director__r.Name,Sales_Director__r.FirstName,Sales_Director__r.LastName,Total_Purchase_Price__c,Expected_number_of_Visitors__c,city_country__c,Confirmed_No_of_Meeting__c,Country__c,Date_Of_Event__c,End_Date_Of_Event__c,Visit_numbers__c,Event_status__c,Event_Sales_Value__c,recordType.Name,CreatedById,(Select Id, unit__r.Puchase_Price__c,unit__r.Tower__r.Tower_Type__c,Status__c From Booking1__r WHERE Status__c != \'Cancelled\') from Events__c'+filter+' AND (Channel_Partner__r.Contact__c =:userContId OR Sobha_Connect__r.Contact__c =:userContId) ORDER BY CreatedDate DESC';
    string qry =
      'Select Id,Name,Venue_Video_Shoot__c,Date_of_Proposal__c,Collateral_Uploaded__c,Campaign_Leads__c,Campaign_Lead_7_days_before_event__c,Sales_Manager__r.Name,Sales_Manager__r.FirstName,Sales_Manager__r.LastName,Sales_Director__c,Sales_Director__r.Name,Sales_Director__r.FirstName,Sales_Director__r.LastName,Total_Purchase_Price__c,Expected_number_of_Visitors__c,city_country__c,Confirmed_No_of_Meeting__c,Country__c,Date_Of_Event__c,End_Date_Of_Event__c,Visit_numbers__c,Event_status__c,Event_Sales_Value__c,recordType.Name,CreatedById,(Select Id, unit__r.Puchase_Price__c,unit__r.Tower__r.Tower_Type__c,Status__c From Booking1__r WHERE Status__c != \'Cancelled\') from Events__c' +
      filter +
      ' AND Event_status__c != \'Cancelled\' AND Event_Approved_status__c IN ( \'Venue Cost Approved\',\'Approved\') AND (Channel_Partner__r.Contact__c =:userContId OR Sobha_Connect__r.Contact__c =:userContId) ORDER BY CreatedDate DESC';
    system.debug('Query is ' + qry);
    EventsList = Database.query(qry);
    system.debug('====EventList=====' + EventsList);
    //  for (Events__c event : EventsList) {
    // if (event.recordType.Name == 'Road Shows') {
    //     userRecordCount++;
    //     }
    // }
    map<string, string> eventIdToVideoLink = new Map<string, string>();
    string latestVideoUrl = 'NoURL';
    for (ContentDistribution cd : [
      SELECT Id, ContentVersion.FileType, ContentDownloadUrl, RelatedRecordId
      FROM ContentDistribution
      WHERE RelatedRecordId != NULL AND RelatedRecordId IN :EventsList
      ORDER BY createddate ASC
    ]) {
      if (
        cd.ContentVersion.FileType == 'MP4' ||
        cd.ContentVersion.FileType == 'MOV' ||
        cd.ContentVersion.FileType == 'AVI' ||
        cd.ContentVersion.FileType == 'WMV'
      ) {
        eventIdToVideoLink.put(cd.RelatedRecordId, cd.ContentDownloadUrl);
        latestVideoUrl = cd.ContentDownloadUrl;
      }
    }
    userRecordCount = EventsList.size();
    for (Events__c event : EventsList) {
      Decimal totalPurchasePrice = 0;
      // if (event.recordType.Name == 'Road Shows') {
      //     userRecordCount++;
      // }
      // Iterate over related Booking1__c records to calculate total purchase price
      for (Booking__c booking : event.Booking1__r) {
        if (booking.Status__c != 'Cancelled' && booking.unit__r != null) {
          totalPurchasePrice += booking.unit__r.Puchase_Price__c;
        }
        if (booking.unit__r.Tower__r.Tower_Type__c == 'Apartments') {
          apartmentCount++;
        } else if (booking.unit__r.Tower__r.Tower_Type__c == 'Villas') {
          villasCount++;
        }
      }
      // Add total purchase price to the event record
      event.Total_Purchase_Price__c = totalPurchasePrice;
      if (eventIdToVideoLink.containsKey(string.valueOf(event.Id))) {
        event.Remarks__c = eventIdToVideoLink.get(event.Id);
      } else {
        event.Remarks__c = '';
      }
    }
    if (EventsList != null && EventsList.size() > 0) {
      // Populate result map
      result.put('eventsList', EventsList);
      result.put('userRecordCount', userRecordCount);
      result.put('apartmentCount', apartmentCount);
      result.put('villasCount', villasCount);
      result.put('baseURL', URL.getOrgDomainURL().toExternalForm());
      result.put('latestVideoUrl', latestVideoUrl);

      return result;
    } else
      return null;
  }

  @AuraEnabled
  public static Id createEventRecord(Object eventData) {
    try {
      String userContId = getContactInfo();

      Events__c ev = new Events__c();
      ev = (Events__c) JSON.deserialize(
        JSON.serialize(eventData),
        Events__c.class
      );
      List<Channel_partner__C> cp = [
        SELECT
          id,
          Sales_Manager__c,
          Channel_Relationship_Manager__c,
          Sales_Manager__r.ManagerId,
          OwnerId,
          Name
        FROM Channel_Partner__c
        WHERE Contact__c = :userContId
        LIMIT 1
      ];
      if (!cp.isEmpty()) {
        ev.Channel_Partner__c = cp[0].Id;
        ev.Sales_Manager__c = cp[0].Sales_Manager__c;
        ev.Start_Time_of_the_Event__c = ev.Start_Time_of_the_Event__c.addHours(
          4
        );
        ev.End_Time_of_the_Event__c = ev.End_Time_of_the_Event__c.addHours(4);
        ev.Channel_Relationship_Manager__c = cp[0]
          .Channel_Relationship_Manager__c;
        // ev.Sales_Director__c=cp[0].Sales_Manager__r.ManagerId;
        ev.OwnerId = cp[0].OwnerId;
      } else {
        List<Sobha_Connect__C> sc = [
          SELECT
            id,
            Sales_Manager__c,
            Channel_Relationship_Manager__c,
            Sales_Manager__r.ManagerId,
            OwnerId,
            Name
          FROM Sobha_Connect__C
          WHERE Contact__c = :userContId
          LIMIT 1
        ];
        if (!sc.isEmpty()) {
          ev.Sobha_Connect__c = sc[0].Id;
          ev.Sales_Manager__c = sc[0].Sales_Manager__c;
          ev.Channel_Relationship_Manager__c = sc[0]
            .Channel_Relationship_Manager__c;
          // ev.Sales_Director__c=sc[0].Sales_Manager__r.ManagerId;
          ev.Start_Time_of_the_Event__c = ev.Start_Time_of_the_Event__c.addHours(
            4
          );
          ev.End_Time_of_the_Event__c = ev.End_Time_of_the_Event__c.addHours(4);
          ev.OwnerId = sc[0].OwnerId;
        }
      }

      if (ev != null) {
        ev.From_Broker_Portal__c = true;
        insert ev;
        Events__c evnt = [SELECT Id, name FROM Events__c WHERE Id = :ev.Id];
        String filterCriteria = 'Event Created:' + evnt.Name;
        BrokerPortalSobhaProjectsController.createDataDownloadTracker(
          '',
          filterCriteria
        );
        return ev.Id;
      } else
        return null;
    } catch (Exception e) {
      System.debug(
        'Exception occurred in createEventRecord: ' + e.getMessage()
      );
      Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
      logError.class__c = 'PortalBrokerEventsController';
      insert logError;
      return null;
    }
    //     // System.debug('Imperative call successful');
    //     //   System.debug('Data is'+eventData);
    //        Date myDate;
    //        Time myTime;
    //        Integer myInt;
    //     try {
    //         Events__c newEvent = new Events__c();
    //         for (String fieldName : eventData.keySet()) {
    //            String value = eventData.get(fieldName);
    //             // Set field value dynamically based on field name
    //             if(fieldName.containsIgnoreCase('date'))
    //             {
    //                  myDate=Date.valueOf(value);
    //                 System.debug('myDate is'+myDate);
    //                 newEvent.put(fieldName,myDate);
    //             }
    //             else if(fieldName.containsIgnoreCase('time'))
    //             {
    //                  List<String> timeParts = value.split(':');
    //                 Integer hours = Integer.valueOf(timeParts[0]);
    //                 Integer minutes = Integer.valueOf(timeParts[1]);
    //                 Integer seconds = Integer.valueOf(timeParts[2].substring(0, 2)); // Remove milliseconds
    //                 // Create a Time instance
    //                 myTime = Time.newInstance(hours, minutes, seconds, 0);
    //                 // If no exception is thrown, the time is valid
    //                 newEvent.put(fieldName, myTime);
    //             }
    //             else if(value.isNumeric()){
    //                 myInt=Integer.valueof(value);
    //                 newEvent.put(fieldName, myInt);
    //             }
    //             else
    //             newEvent.put(fieldName, value);
    //             // System.debug('newEvent is'+newEvent);
    //         }
    //         insert newEvent;
    //         // System.debug('the object '+newEvent);
    //         //return newEvent.Id;
    //     } catch(Exception e) {
    //        // return null;
    //        System.debug('the exception is  '+e);
    //     }
  }

  @AuraEnabled(cacheable=true)
  public static map<string, Object> getProfileDetails() {
    String userContId = getContactInfo();
    system.debug('userContId is ' + userContId);
    map<string, Object> retMap = new Map<string, Object>();
    List<Broker_Registration__c> listBrokerRegistration;
    List<User> usr = [
      SELECT Id, CompanyName, Title, SmallPhotoUrl, FullPhotoUrl
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    List<Channel_Partner__c> listBroker = [
      SELECT
        Id,
        BP_Owner_Name__c,
        Designation__c,
        Category__c,
        Authorised_signatory__c,
        Channel_Relationship_Manager__r.Email,
        Name,
        Passport_No__c,
        Mobile_No__c,
        Email_ID_1__c,
        Channel_Partner_Id__c,
        Address__c,
        RERA_Registration_No__c,
        Expiry_Date__c
      FROM Channel_Partner__c
      WHERE Contact__c = :userContId
    ];
    system.debug('listBroker is ' + listBroker);
    List<ContentDocumentLink> docLink = new List<ContentDocumentLink>();
    List<ContentDocumentLink> NOCLink = new List<ContentDocumentLink>();
    //retMap.put('Roshan','Bande');
    //Id='a3YJX0000000tpK2AQ'
    if (!listBroker.isEmpty()) {
      listBrokerRegistration = [
        SELECT
          ID,
          Name,
          Email__c,
          Account_Email__c,
          Alternate_Email__c,
          Renewal_Status__c,
          Name_as_per_trade_license__c,
          Designation__c,
          Name_as_per_passport__c,
          Status__c,
          RecordType.Name,
          Accounts_Finance_Email_ID__c,
          Broker_Expiry_Date__c
        FROM Broker_Registration__c
        WHERE
          CPID__c = :listBroker[0].Id
          AND (Status__c = 'Executed Agreement sent to broker'
          OR RecordType.Name = 'NEW')
        ORDER BY createddate DESC
        LIMIT 1
      ];
      if (!listBrokerRegistration.isEmpty())
        docLink = [
          SELECT Id, ContentDocument.Title, ContentDocument.CreatedDate
          FROM ContentDocumentLink
          WHERE
            ContentDocument.Title LIKE 'Agreement%'
            AND LinkedEntityId = :listBrokerRegistration[0].Id
          ORDER BY ContentDocument.CreatedDate DESC
          LIMIT 1
        ];
      NOCLink = [
        SELECT Id, ContentDocument.Title, ContentDocument.CreatedDate
        FROM ContentDocumentLink
        WHERE
          ContentDocument.Title LIKE 'NOC%'
          AND LinkedEntityId = :listBrokerRegistration[0].Id
        ORDER BY ContentDocument.CreatedDate DESC
        LIMIT 1
      ];
      String baseUrl =
        URL.getOrgDomainURL().toExternalForm() +
        '/sfc/servlet.shepherd/document/download/';
      retMap.put('Name', listBroker[0].BP_Owner_Name__c); // BP Owner Name
      retMap.put('Passport_No', listBroker[0].Passport_No__c);
      retMap.put('Mobile_No', listBroker[0].Mobile_No__c);
      retMap.put('Email_Id', listBroker[0].Email_ID_1__c);
      //retMap.put('AccEmail', listBrokerRegistration[0].Accounts_Finance_Email_ID__c);
      retMap.put('AccEmail', listBrokerRegistration[0].Account_Email__c);
      retMap.put('ownersEmail', listBrokerRegistration[0].Alternate_Email__c);
      retMap.put(
        'authSignatoryPassportName',
        listBrokerRegistration[0].Name_as_per_passport__c
      );
      retMap.put('Designation', listBrokerRegistration[0].Designation__c);
      retMap.put('BrokerCategory', listBroker[0].Category__c);
      retMap.put('Broker_Id', listBroker[0].Channel_Partner_Id__c);
      retMap.put('Address', listBroker[0].Address__c);
      retMap.put('Rera_no', listBroker[0].RERA_Registration_No__c);
      retMap.put('Expiry_Date', String.ValueOf(listBroker[0].Expiry_Date__c));
      retMap.put('Photo_Url', usr[0].FullPhotoUrl);
      retMap.put('CompanyName', listBroker[0].Name); //listBroker[0].Name replace it
      retMap.put('Title', listBroker[0].Designation__c);
      retMap.put('Broker_Type', 'Channel Partner');
      retMap.put(
        'TradeLicenceNum',
        listBrokerRegistration[0].Name_as_per_trade_license__c
      );
      retMap.put('Authorised_signatory', listBroker[0].Authorised_signatory__c);
      retMap.put(
        'CHRMEmail',
        listBroker[0].Channel_Relationship_Manager__r.Email
      );
      if (
        !listBrokerRegistration.isEmpty() &&
        listBrokerRegistration[0].Renewal_Status__c == 'Renewal Initiated'
      )
        retMap.put('Renewal_status', true);
      else
        retMap.put('Renewal_status', false);

      if (
        !listBrokerRegistration.isEmpty() &&
        (listBrokerRegistration[0].Broker_Expiry_Date__c > Date.today())
      )
        retMap.put('BR_status_Executed_or_New', true);
      else
        retMap.put('BR_status_Executed_or_New', false);
      if (!docLink.isEmpty())
        retMap.put('doc_Link', baseUrl + docLink[0].ContentDocumentId);
      if (!NOCLink.isEmpty())
        retMap.put('NOC_Link', baseUrl + NOCLink[0].ContentDocumentId);
      if (!listBrokerRegistration.isEmpty())
        retMap.put('brRecordId', listBrokerRegistration[0].Id);
      retMap.put('conId', userContId);
    } else if (listBroker.isEmpty()) {
      List<Sobha_Connect__c> listBrokerSc = [
        SELECT
          Id,
          BP_Owner_Name__c,
          Designation__c,
          Category__c,
          Authorised_signatory__c,
          Channel_Relationship_Manager__r.Email,
          Name,
          Registration__c,
          Mobile_No__c,
          Email_Id__c,
          Name__c,
          Address__c,
          RERA_Number__c,
          Expiry_Date__c
        FROM Sobha_Connect__c
        WHERE Contact__c = :userContId
      ];
      if (listBrokerSc.size() != 0) {
        listBrokerRegistration = [
          SELECT
            ID,
            Email__c,
            Account_Email__c,
            Alternate_Email__c,
            Name_as_per_trade_license__c,
            Name_as_per_passport__c,
            Designation__c,
            Name,
            Renewal_Status__c,
            Status__c,
            RecordType.Name,
            Accounts_Finance_Email_ID__c,
            Broker_Expiry_Date__c
          FROM Broker_Registration__c
          WHERE
            SCID__c = :listBrokerSc[0].Id
            AND (Status__c = 'Executed Agreement sent to broker'
            OR RecordType.Name = 'NEW')
          ORDER BY createddate DESC
          LIMIT 1
        ];
        if (!listBrokerRegistration.isEmpty())
          docLink = [
            SELECT Id, ContentDocument.Title, ContentDocument.CreatedDate
            FROM ContentDocumentLink
            WHERE
              ContentDocument.Title LIKE 'Agreement%'
              AND LinkedEntityId = :listBrokerRegistration[0].Id
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
          ];
        NOCLink = [
          SELECT Id, ContentDocument.Title, ContentDocument.CreatedDate
          FROM ContentDocumentLink
          WHERE
            ContentDocument.Title LIKE 'NOC%'
            AND LinkedEntityId = :listBrokerRegistration[0].Id
          ORDER BY ContentDocument.CreatedDate DESC
          LIMIT 1
        ];
        String baseUrl =
          URL.getOrgDomainURL().toExternalForm() +
          '/sfc/servlet.shepherd/document/download/';
        retMap.put('Name', listBrokerSc[0].BP_Owner_Name__c); // BP Owner Name
        retMap.put('Passport_No', listBrokerSc[0].Registration__c);
        retMap.put('Mobile_No', listBrokerSc[0].Mobile_No__c);
        retMap.put('Email_Id', listBrokerSc[0].Email_Id__c);
        // retMap.put('AccEmail', listBrokerRegistration[0].Accounts_Finance_Email_ID__c);
        retMap.put('AccEmail', listBrokerRegistration[0].Account_Email__c);
        retMap.put('ownersEmail', listBrokerRegistration[0].Alternate_Email__c);
        retMap.put(
          'authSignatoryPassportName',
          listBrokerRegistration[0].Name_as_per_passport__c
        );
        retMap.put('Designation', listBrokerRegistration[0].Designation__c);
        retMap.put('BrokerCategory', listBrokerSc[0].Category__c);
        retMap.put('Broker_Id', listBrokerSc[0].Name__c);
        retMap.put('Address', listBrokerSc[0].Address__c);
        retMap.put('Rera_no', listBrokerSc[0].RERA_Number__c);
        retMap.put(
          'Expiry_Date',
          String.ValueOf(listBrokerSc[0].Expiry_Date__c)
        );
        retMap.put('Photo_Url', usr[0].FullPhotoUrl);
        retMap.put('CompanyName', listBrokerSc[0].Name); //listBroker[0].Name replace it
        retMap.put('Title', listBrokerSc[0].Designation__c);
        retMap.put('Broker_Type', 'Sobha Connect');
        retMap.put(
          'TradeLicenceNum',
          listBrokerRegistration[0].Name_as_per_trade_license__c
        );
        retMap.put(
          'Authorised_signatory',
          listBrokerSc[0].Authorised_signatory__c
        );
        retMap.put(
          'CHRMEmail',
          listBrokerSc[0].Channel_Relationship_Manager__r.Email
        );
        if (
          !listBrokerRegistration.isEmpty() &&
          listBrokerRegistration[0].Renewal_Status__c == 'Renewal Initiated'
        )
          retMap.put('Renewal_status', true);
        else
          retMap.put('Renewal_status', false);
        if (
          !listBrokerRegistration.isEmpty() &&
          (listBrokerRegistration[0].Broker_Expiry_Date__c > Date.today())
        )
          retMap.put('BR_status_Executed_or_New', true);
        else
          retMap.put('BR_status_Executed_or_New', false);
        if (!docLink.isEmpty())
          retMap.put('doc_Link', baseUrl + docLink[0].ContentDocumentId);
        if (!NOCLink.isEmpty())
          retMap.put('NOC_Link', baseUrl + NOCLink[0].ContentDocumentId);
        if (!listBrokerRegistration.isEmpty())
          retMap.put('brRecordId', listBrokerRegistration[0].Id);
        retMap.put('conId', userContId);
      }
    }

    return retMap;
  }

  @AuraEnabled(cacheable=true)
  public static List<Project__c> getProjectsDetails() {
    List<Project__c> projectList = new List<Project__c>();
    String qry = 'SELECT Id, Name, (SELECT Id, Name FROM Clusters__r) FROM Project__c';
    projectList = Database.query(qry);
    if (projectList.size() != 0)
      return projectList;
    else
      return null;
  }

  @AuraEnabled
  public static string renewAgreement() {
    Id scId, cpId;
    string retStatement = '';
    List<Id> renewedRecords;
    List<Broker_Registration__c> listBrokerRegistration;
    String userContId = getContactInfo();
    if (userContId == null) {
      return '';
    }
    List<User> usr = [
      SELECT Id, SmallPhotoUrl, FullPhotoUrl
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    List<Channel_Partner__c> listBroker = [
      SELECT
        Id,
        Name,
        Passport_No__c,
        Mobile_No__c,
        Email_ID_1__c,
        Channel_Partner_Id__c,
        Address__c,
        RERA_Registration_No__c,
        Expiry_Date__c
      FROM Channel_Partner__c
      WHERE Contact__c = :userContId
    ];

    if (!listBroker.isEmpty()) {
      cpId = listBroker[0].Id;
      listBrokerRegistration = [
        SELECT ID, Name
        FROM Broker_Registration__c
        WHERE
          CPID__c = :cpId
          AND (Status__c = 'Executed Agreement sent to broker'
          OR RecordType.Name = 'NEW')
        ORDER BY createddate DESC
        LIMIT 1
      ];
    } else {
      List<Sobha_Connect__c> listBrokerSc = [
        SELECT
          Id,
          Name,
          Registration__c,
          Mobile_No__c,
          Email_Id__c,
          Name__c,
          Address__c,
          RERA_Number__c,
          Expiry_Date__c
        FROM Sobha_Connect__c
        WHERE Contact__c = :userContId
      ];
      if (!listBrokerSc.isEmpty()) {
        scId = listBrokerSc[0].Id;
        listBrokerRegistration = [
          SELECT ID, Name
          FROM Broker_Registration__c
          WHERE
            SCID__c = :scId
            AND (Status__c = 'Executed Agreement sent to broker'
            OR RecordType.Name = 'NEW')
          ORDER BY createddate DESC
          LIMIT 1
        ];
      } else {
        return '';
      }
    }
    system.debug('Broekr record ' + listBrokerRegistration);
    if (!listBrokerRegistration.isEmpty()) {
      try {
        renewedRecords = BrokerRegistrationRenewalController.createRenewalRecordFromPortal(
          listBrokerRegistration
        );
        if (!renewedRecords.isEmpty()) {
          retStatement = 'Successfully created renewal';
        } else
          retStatement = '';
      } catch (exception e) {
        system.debug('Exception triggered' + e);
      }
    }
    return retStatement;
  }

  @AuraEnabled(cacheable=true)
  public static List<ContactWithImage> getRelatedContacts() {
    List<ContactWithImage> relatedCons = new List<ContactWithImage>();
    String userContId = getContactInfo();
    system.debug('getRelated contacts method ');
    List<Contact> contacts = [
      SELECT AccountId
      FROM Contact
      WHERE Id = :userContId
      LIMIT 1
    ];
    if (!contacts.isEmpty()) {
      Id accountId = contacts[0].AccountId;
      List<Contact> relatedContacts = [
        SELECT
          Id,
          Name,
          Email,
          Phone,
          (SELECT Id, SmallPhotoUrl, FullPhotoUrl FROM Users)
        FROM Contact
        WHERE AccountId = :accountId
      ];
      for (contact con : relatedContacts) {
        for (User u : con.Users) {
          relatedCons.add(new ContactWithImage(con.Name, u.SmallPhotoUrl));
        }
      }
      system.debug('list is ' + relatedCons);
    }
    return relatedCons;
  }

  public class ContactWithImage {
    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String imageUrl { get; set; }

    public ContactWithImage(String name, String imageUrl) {
      this.name = name;
      this.imageUrl = imageUrl;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<docWrapper> getBRFileHistory(Boolean showBalanceFiles) {
    String userContId = getContactInfo();
    List<BR_Document_History__c> docListSet = new List<BR_Document_History__c>();
    List<docWrapper> brDocumentList = new List<docWrapper>();
    Map<String, docWrapper> uniqueDocumentsMap = new Map<String, docWrapper>();
    Map<String, Id> uniqueDocumentsMap2 = new Map<String, Id>();
    List<Broker_Registration__c> listBrokerRegistration;
    List<Channel_Partner__c> listBroker = [
      SELECT
        Id,
        Name,
        Passport_No__c,
        Mobile_No__c,
        Email_ID_1__c,
        Channel_Partner_Id__c,
        Address__c,
        RERA_Registration_No__c,
        Expiry_Date__c
      FROM Channel_Partner__c
      WHERE Contact__c = :userContId
    ];
    system.debug('listBroker is ' + listBroker);

    if (!listBroker.isEmpty()) {
      listBrokerRegistration = [
        SELECT
          Id,
          Name,
          recordType.name,
          (
            SELECT
              Id,
              ContentDocumentId,
              ContentDocument.FileType,
              ContentDocument.Title,
              ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLinks
            ORDER BY ContentDocument.CreatedDate DESC
          )
        FROM Broker_Registration__c
        WHERE
          CPID__c = :listBroker[0].Id
          AND (Status__c = 'Executed Agreement sent to broker'
          OR RecordType.Name = 'NEW')
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      List<BR_Document_History__c> brDocHistList = new List<BR_Document_History__c>();

      if (showBalanceFiles == true) {
        brDocHistList = [
          SELECT
            Id,
            File_Name__c,
            Start_Date__c,
            Expiry_date__c,
            Broker_Registration__c,
            file_type__c,
            (
              SELECT
                Id,
                ContentDocumentId,
                ContentDocument.FileType,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersionId
              FROM ContentDocumentLinks
              ORDER BY ContentDocument.CreatedDate DESC
              LIMIT 1
            )
          FROM BR_Document_History__c
          WHERE
            Broker_Registration__c = :listBrokerRegistration[0].Id
            AND File_Type__c = 'Secondary Document'
        ];
        for (BR_Document_History__c brDoc : brDocHistList) {
          for (ContentDocumentLink link : brDoc.ContentDocumentLinks) {
            System.debug(
              'link.ContentDocument.Title : ' + link.ContentDocument.Title
            );
            String key = link.ContentDocument.Title;
            if (
              !(uniqueDocumentsMap2.containsKey(key) &&
              uniqueDocumentsMap2.get(key) == brDoc.Id)
            ) {
              docWrapper docwrap = new docWrapper(
                link.ContentDocumentId,
                link.ContentDocument.LatestPublishedVersionId,
                brDoc.Expiry_date__c != null
                  ? brDoc.Expiry_date__c.toString()
                  : '',
                brDoc.file_type__c,
                link.ContentDocument.Title,
                true,
                brDoc.Id,
                link.ContentDocument.FileType
              );
              brDocumentList.add(docwrap);
              uniqueDocumentsMap2.put(key, brDoc.Id);
            }
            System.debug('brDocumentList : ' + brDocumentList);
          }
        }
      } else {
        brDocHistList = [
          SELECT
            Id,
            File_Name__c,
            Start_Date__c,
            Expiry_date__c,
            Broker_Registration__c,
            file_type__c,
            (
              SELECT
                Id,
                ContentDocumentId,
                ContentDocument.Title,
                ContentDocument.FileType,
                ContentDocument.LatestPublishedVersionId
              FROM ContentDocumentLinks
              ORDER BY ContentDocument.CreatedDate DESC
            )
          FROM BR_Document_History__c
          WHERE
            Broker_Registration__c = :listBrokerRegistration[0].Id
            AND File_Type__c != 'Secondary Document'
        ];

        for (Broker_Registration__c reg : listBrokerRegistration) {
          for (ContentDocumentLink link : reg.ContentDocumentLinks) {
            String key = link.ContentDocument.Title;
            System.debug('key value is : ' + key);
            if (
              link.ContentDocument.Title.startsWith('Agreement') ||
              link.ContentDocument.Title.startsWith('NOC')
            ) {
              if (!(uniqueDocumentsMap.get(key) != null)) {
                System.debug(
                  'inside condition is :  ' + link.ContentDocument.Title
                );
                docWrapper docwrap = new docWrapper(
                  link.ContentDocumentId,
                  link.ContentDocument.LatestPublishedVersionId,
                  '',
                  '',
                  link.ContentDocument.Title,
                  false,
                  '',
                  link.ContentDocument.FileType
                );
                brDocumentList.add(docwrap);
                uniqueDocumentsMap.put(key, docwrap);
              }
            }
            System.debug('brDocumentList 444: ' + brDocumentList);
          }
          for (BR_Document_History__c brDoc : brDocHistList) {
            for (ContentDocumentLink link : brDoc.ContentDocumentLinks) {
              System.debug(
                'link.ContentDocument.Title : ' + link.ContentDocument.Title
              );
              String key = brDoc.file_type__c;
              if (!(uniqueDocumentsMap2.get(key) != null)) {
                docWrapper docwrap = new docWrapper(
                  link.ContentDocumentId,
                  link.ContentDocument.LatestPublishedVersionId,
                  brDoc.Expiry_date__c != null
                    ? brDoc.Expiry_date__c.toString()
                    : '',
                  brDoc.file_type__c,
                  link.ContentDocument.Title,
                  true,
                  brDoc.Id,
                  link.ContentDocument.FileType
                );
                brDocumentList.add(docwrap);
                uniqueDocumentsMap2.put(key, brDoc.Id);
              }
              System.debug('brDocumentList : ' + brDocumentList);
            }
          }
        }
      }

      System.debug('brDocumentList 35: ' + brDocumentList);
      return brDocumentList;
    } else if (listBroker.isEmpty()) {
      List<Sobha_Connect__c> listBrokerSc = [
        SELECT
          Id,
          Name,
          Registration__c,
          Mobile_No__c,
          Email_Id__c,
          Name__c,
          Address__c,
          RERA_Number__c,
          Expiry_Date__c
        FROM Sobha_Connect__c
        WHERE Contact__c = :userContId
      ];
      if (!listBrokerSc.isEmpty()) {
        listBrokerRegistration = [
          SELECT
            Id,
            Name,
            (
              SELECT
                Id,
                ContentDocumentId,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.FileType
              FROM ContentDocumentLinks
              ORDER BY ContentDocument.CreatedDate DESC
            )
          FROM Broker_Registration__c
          WHERE
            SCID__c = :listBrokerSc[0].Id
            AND (Status__c = 'Executed Agreement sent to broker'
            OR RecordType.Name = 'NEW')
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];

        // List<BR_Document_History__c> brDocHistList= [SELECT Id,File_Name__c, Start_Date__c, Expiry_date__c, Broker_Registration__c,file_type__c,
        //                                              (SELECT Id, ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId
        //                                               FROM ContentDocumentLinks
        //                                               ORDER BY ContentDocument.CreatedDate DESC)
        //                                              FROM BR_Document_History__c
        //                                              WHERE Broker_Registration__c=: listBrokerRegistration[0].Id];
        List<BR_Document_History__c> brDocHistList = new List<BR_Document_History__c>();

        if (showBalanceFiles == true) {
          brDocHistList = [
            SELECT
              Id,
              File_Name__c,
              Start_Date__c,
              Expiry_date__c,
              Broker_Registration__c,
              file_type__c,
              (
                SELECT
                  Id,
                  ContentDocumentId,
                  ContentDocument.Title,
                  ContentDocument.LatestPublishedVersionId,
                  ContentDocument.FileType
                FROM ContentDocumentLinks
                ORDER BY ContentDocument.CreatedDate DESC
                LIMIT 1
              )
            FROM BR_Document_History__c
            WHERE
              Broker_Registration__c = :listBrokerRegistration[0].Id
              AND File_Type__c = 'Secondary Document'
          ];
          for (BR_Document_History__c brDoc : brDocHistList) {
            for (ContentDocumentLink link : brDoc.ContentDocumentLinks) {
              System.debug(
                'link.ContentDocument.Title : ' + link.ContentDocument.Title
              );
              String key = link.ContentDocument.Title;
              if (
                !(uniqueDocumentsMap2.containsKey(key) &&
                uniqueDocumentsMap2.get(key) == brDoc.Id)
              ) {
                docWrapper docwrap = new docWrapper(
                  link.ContentDocumentId,
                  link.ContentDocument.LatestPublishedVersionId,
                  brDoc.Expiry_date__c != null
                    ? brDoc.Expiry_date__c.toString()
                    : '',
                  brDoc.file_type__c,
                  link.ContentDocument.Title,
                  true,
                  brDoc.Id,
                  link.ContentDocument.FileType
                );
                brDocumentList.add(docwrap);
                uniqueDocumentsMap2.put(key, brDoc.Id);
              }
              System.debug('brDocumentList : ' + brDocumentList);
            }
          }
        } else {
          brDocHistList = [
            SELECT
              Id,
              File_Name__c,
              Start_Date__c,
              Expiry_date__c,
              Broker_Registration__c,
              file_type__c,
              (
                SELECT
                  Id,
                  ContentDocumentId,
                  ContentDocument.Title,
                  ContentDocument.FileType,
                  ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLinks
                ORDER BY ContentDocument.CreatedDate DESC
              )
            FROM BR_Document_History__c
            WHERE
              Broker_Registration__c = :listBrokerRegistration[0].Id
              AND File_Type__c != 'Secondary Document'
          ];

          for (Broker_Registration__c reg : listBrokerRegistration) {
            for (ContentDocumentLink link : reg.ContentDocumentLinks) {
              String key = link.ContentDocument.Title;
              System.debug('key value is : ' + key);
              if (
                link.ContentDocument.Title.startsWith('Agreement') ||
                link.ContentDocument.Title.startsWith('NOC')
              ) {
                if (!(uniqueDocumentsMap.get(key) != null)) {
                  System.debug(
                    'inside condition is :  ' + link.ContentDocument.Title
                  );
                  docWrapper docwrap = new docWrapper(
                    link.ContentDocumentId,
                    link.ContentDocument.LatestPublishedVersionId,
                    '',
                    '',
                    link.ContentDocument.Title,
                    false,
                    '',
                    link.ContentDocument.FileType
                  );
                  brDocumentList.add(docwrap);
                  uniqueDocumentsMap.put(key, docwrap);
                }
              }
              System.debug('brDocumentList 444: ' + brDocumentList);
            }
            for (BR_Document_History__c brDoc : brDocHistList) {
              for (ContentDocumentLink link : brDoc.ContentDocumentLinks) {
                System.debug(
                  'link.ContentDocument.Title : ' + link.ContentDocument.Title
                );
                String key = brDoc.file_type__c;
                if (!(uniqueDocumentsMap2.get(key) != null)) {
                  docWrapper docwrap = new docWrapper(
                    link.ContentDocumentId,
                    link.ContentDocument.LatestPublishedVersionId,
                    brDoc.Expiry_date__c != null
                      ? brDoc.Expiry_date__c.toString()
                      : '',
                    brDoc.file_type__c,
                    link.ContentDocument.Title,
                    true,
                    brDoc.Id,
                    link.ContentDocument.FileType
                  );
                  brDocumentList.add(docwrap);
                  uniqueDocumentsMap2.put(key, brDoc.Id);
                }
                System.debug('brDocumentList : ' + brDocumentList);
              }
            }
          }
        }

        System.debug('brDocumentList 35: ' + brDocumentList);
        return brDocumentList;
      }
    }
    return null;
  }

  /*@AuraEnabled(cacheable=true)
public static List<BRDocument> getBRFileHistory()
{   String userContId=getContactInfo();
List<BR_Document_History__c> docListSet= new List<BR_Document_History__c>();
List<BRDocument> brDocumentList = new List<BRDocument>();
Map<String, BRDocument> uniqueDocumentsMap = new Map<String, BRDocument>();
List<Broker_Registration__c> listBrokerRegistration;
List<Channel_Partner__c> listBroker=[Select Id,Name,Passport_No__c,Mobile_No__c,Email_ID_1__c, Channel_Partner_Id__c,Address__c,RERA_Registration_No__c,Expiry_Date__c from Channel_Partner__c WHERE Contact__c=:userContId];
system.debug('listBroker is '+ listBroker);

if(!listBroker.isEmpty())
{
listBrokerRegistration = [SELECT Id, Name, 
(SELECT Id, ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId 
FROM ContentDocumentLinks
ORDER BY ContentDocument.CreatedDate DESC) 
From Broker_Registration__c 
WHERE CPID__c=:listBroker[0].Id 
AND 
Parent_Record__c=NULL ORDER BY CreatedDate ASC LIMIT 1];

List<BR_Document_History__c> brDocHistList= [SELECT Id,File_Name__c, Start_Date__c, Expiry_date__c, Broker_Registration__c,file_type__c,
(SELECT Id, ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId 
FROM ContentDocumentLinks
ORDER BY ContentDocument.CreatedDate DESC)
FROM BR_Document_History__c 
WHERE Broker_Registration__c=: listBrokerRegistration[0].Id];


//   for (BR_Document_History__c brDoc : brDocHistList) {
for (Broker_Registration__c reg : listBrokerRegistration) {
for (ContentDocumentLink link : reg.ContentDocumentLinks) {

String key = link.ContentDocument.Title;
if (!uniqueDocumentsMap.containsKey(key)) { 
BRDocument newDocument = new BRDocument(reg, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId);
brDocumentList.add(newDocument);                                
uniqueDocumentsMap.put(key, newDocument);
}
}

}
//  } 

for(BR_Document_History__c brDoc : brDocHistList){
for(ContentDocumentLink link : brDoc.ContentDocumentLinks){
String key = link.ContentDocument.Title;
if (!uniqueDocumentsMap.containsKey(key)) {
BRDocument newDocument = new BRDocument(brDoc, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId);
brDocumentList.add(newDocument);   
uniqueDocumentsMap.put(key, newDocument);
}
}
}
return brDocumentList ;
}
else if(listBroker.isEmpty())
{
List<Sobha_Connect__c> listBrokerSc=[Select Id,Name,Registration__c,Mobile_No__c,Email_Id__c,Name__c,Address__c,RERA_Number__c,Expiry_Date__c from Sobha_Connect__c WHERE Contact__c=:userContId];
if(!listBrokerSc.isEmpty())
{
listBrokerRegistration = [SELECT Id, Name, 
(SELECT Id, ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId 
FROM 
ContentDocumentLinks ORDER BY ContentDocument.CreatedDate DESC) 
From Broker_Registration__c 
WHERE SCID__c=:listBrokerSc[0].Id 
AND 
Parent_Record__c=NULL ORDER BY CreatedDate ASC LIMIT 1];

List<BR_Document_History__c> brDocHistList= [SELECT Id,File_Name__c, Start_Date__c, Expiry_date__c, Broker_Registration__c,file_type__c,
(SELECT Id, ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId 
FROM ContentDocumentLinks
ORDER BY ContentDocument.CreatedDate DESC)
FROM BR_Document_History__c 
WHERE Broker_Registration__c=: listBrokerRegistration[0].Id];


/*  for (BR_Document_History__c brDoc : brDocHistList) {
for (Broker_Registration__c reg : listBrokerRegistration) {
for (ContentDocumentLink link : reg.ContentDocumentLinks) {
if (link.ContentDocument.Title == brDoc.File_Name__c) {
String key = link.ContentDocument.Title;
if (!uniqueDocumentsMap.containsKey(key)) {
BRDocument newDocument = new BRDocument(brDoc, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId);
brDocumentList.add(newDocument);                                
uniqueDocumentsMap.put(key, newDocument);
}
}
}
}
} 
for(BR_Document_History__c brDoc : brDocHistList){
for(ContentDocumentLink link : brDoc.ContentDocumentLinks){
String key = link.ContentDocument.Title;
if (!uniqueDocumentsMap.containsKey(key)) {
BRDocument newDocument = new BRDocument(brDoc, link.ContentDocumentId, link.ContentDocument.LatestPublishedVersionId);
brDocumentList.add(newDocument);   
uniqueDocumentsMap.put(key, newDocument);
}
}
}

return brDocumentList ;
}
}
return null;



}*/

  /*public class BRDocument {
@AuraEnabled
public Id fileId {get; set;}

@AuraEnabled
public Id latestVersionId {get; set;}

@AuraEnabled
public String baseUrl {get; set;}

@AuraEnabled
public BR_Document_History__c record {get; set;}

@AuraEnabled
public Broker_Registration__c record1 {get; set;}

public BRDocument(BR_Document_History__c record, Id fileId,Id latestVersionId) {
this.fileId = fileId;
this.record = record;
this.latestVersionId=latestVersionId;
this.baseUrl = URL.getOrgDomainURL().toExternalForm();
}

public BRDocument(Broker_Registration__c record, Id fileId,Id latestVersionId){
this.fileId = fileId;
this.record1 = record1;
this.latestVersionId=latestVersionId;
this.baseUrl = URL.getOrgDomainURL().toExternalForm();
}
} */
  @AuraEnabled
  public static void deleteFile(Id fileId) {
    // Your file deletion logic here
    ContentDocumentLink[] links = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE ContentDocumentId = :fileId
    ];
    if (!links.isEmpty()) {
      ContentDocument cd = [
        SELECT Id
        FROM ContentDocument
        WHERE Id = :links[0].ContentDocumentId
      ];
      delete cd;
    }
  }
  public class docWrapper {
    @AuraEnabled
    public Id fileId { get; set; }

    @AuraEnabled
    public Id latestVersionId { get; set; }

    @AuraEnabled
    public String baseUrl { get; set; }

    @AuraEnabled
    public String expiryDate { get; set; }

    @AuraEnabled
    public String fileType { get; set; }

    @AuraEnabled
    public String fileName { get; set; }

    @AuraEnabled
    public boolean ObjectName { get; set; }

    @AuraEnabled
    public String recordId { get; set; }

    @AuraEnabled
    public String fileExtention { get; set; }

    public docWrapper(
      Id fileId,
      Id latestVersionId,
      String expiryDate,
      String fileType,
      String fileName,
      boolean ObjectName,
      String recordId,
      String fileExtention
    ) {
      this.fileId = fileId;
      this.latestVersionId = latestVersionId;
      this.baseUrl = URL.getOrgDomainURL().toExternalForm();
      this.expiryDate = expiryDate;
      this.fileType = fileType;
      this.fileName = fileName;
      this.ObjectName = ObjectName;
      this.recordId = recordId;
      this.fileExtention = fileExtention;
    }
  }

  @AuraEnabled
  public static String getBodyFile(String contVersionId) {
    String filterCriteria = 'Downloaded Files in Profile:';
    ContentVersion contentVersion = [
      SELECT Id, VersionData, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contVersionId
      LIMIT 1
    ];
    //Find the linked record from ContentDocumentLink
    List<ContentDocumentLink> contentDocumentLinks = [
      SELECT LinkedEntityId
      FROM ContentDocumentLink
      WHERE
        ContentDocumentId = :contentVersion.ContentDocumentId
        AND LinkedEntityId IN (SELECT Id FROM BR_Document_History__c)
      LIMIT 1
    ];
    if (!contentDocumentLinks.isEmpty()) {
      Id linkedEntityId = contentDocumentLinks[0].LinkedEntityId;
      // Query the BR_Document_History__c record to get the file type
      BR_Document_History__c linkedEntityRecord = [
        SELECT File_Type__c
        FROM BR_Document_History__c
        WHERE Id = :linkedEntityId
        LIMIT 1
      ];
      filterCriteria =
        filterCriteria +
        linkedEntityRecord.File_Type__c +
        ':' +
        contentVersion.Title;
    } else {
      filterCriteria = filterCriteria + contentVersion.Title;
    }
    BrokerPortalSobhaProjectsController.createDataDownloadTracker(
      '',
      filterCriteria
    );
    return EncodingUtil.base64Encode(contentVersion.VersionData);
  }

  @AuraEnabled
  public static String uploadFiles(
    String base64,
    String filename,
    String recordId,
    String filetype
  ) {
    System.debug('inside upload files');
    Document_validator__c validatorRec = createDocumentValidatorRecord(
      recordId
    );
    ContentVersion cv = createContentVersion(base64, filename);
    ContentDocumentLink cdl = createContentLink(cv.Id, validatorRec.Id);
    if (cv == null || cdl == null) {
      return null;
    } else {
      submitForApproval(
        validatorRec.Id,
        'document_validation_approval_process'
      );
      String filterCriteria =
        'Uploaded File in Profile:' +
        validatorRec.File_Type__c +
        ':' +
        cv.Title;
      BrokerPortalSobhaProjectsController.createDataDownloadTracker(
        '',
        filterCriteria
      );
    }
    System.debug('cdl Id : ' + cdl.Id);
    return cdl.Id;
  }
  /*
   * @method createContentVersion() [private]
   * @desc Creates a content version from a given file's base64 and name
   *
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   *
   * @return {ContentVersion} - returns the newly created ContentVersion, or null
   *   if there was an error inserting the record
   */
  @testvisible
  private static ContentVersion createContentVersion(
    String base64,
    String filename
  ) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch (DMLException e) {
      System.debug(e);
      return null;
    }
  }

  /*
   * @method createContentLink() [private]
   * @desc Creates a content link for a given ContentVersion and record
   *
   * @param {String} contentVersionId - Id of the ContentVersion of the file
   * @param {String} recordId - Id of the record you want to attach this file to
   *
   * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink,
   *   or null if there was an error inserting the record
   */
  @testvisible
  private static ContentDocumentLink createContentLink(
    String contentVersionId,
    String recordId
  ) {
    if (contentVersionId == null || recordId == null) {
      return null;
    }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersionId
    ]
    .ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    // ShareType is either 'V', 'C', or 'I'
    // V = Viewer, C = Collaborator, I = Inferred
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch (DMLException e) {
      System.debug(e);
      return null;
    }
  }

  @AuraEnabled
  public static void updateBRHistoryRecord(
    List<FileExpiryInfo> fileExpiryList
  ) {
    List<BR_Document_History__c> brdList = new List<BR_Document_History__c>();
    for (FileExpiryInfo feRec : fileExpiryList) {
      BR_Document_History__c brd = new BR_Document_History__c();
      brd.Id = feRec.Id;
      if (feRec.expiryDate != null)
        brd.Expiry_date__c = feRec.expiryDate;
      if (feRec.isFileUploaded != null)
        brd.New_File_Uploaded__c = feRec.isFileUploaded;
      brdList.add(brd);
    }
    update brdList;
  }

  public class FileExpiryInfo {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public Date expiryDate { get; set; }
    @AuraEnabled
    public Boolean isFileUploaded { get; set; }
  }

  @AuraEnabled(cacheable=true)
  public static List<ContentDocumentLink> getCollataralFiles(
    String linkedRecord
  ) {
    Id recId = Id.ValueOf(linkedRecord);
    List<ContentDocumentLink> cdlList = [
      SELECT
        Id,
        ContentDocument.FileType,
        ContentDocument.Title,
        ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :recId
    ];
    system.debug('list is ' + cdlList);
    return cdlList;
  }

  @AuraEnabled(cacheable=true)
  public static List<ContentDocumentLink> getVideoFiles(String linkedRecord) {
    Id recId = Id.ValueOf(linkedRecord);
    List<ContentDocumentLink> cdlList = [
      SELECT
        Id,
        ContentDocument.FileType,
        ContentDocument.Title,
        ContentDocumentID
      FROM ContentDocumentLink
      WHERE ContentDocument.FileType = 'MP4' AND LinkedEntityId = :recId
      ORDER BY ContentDocument.CreatedDate DESC
      LIMIT 1
    ];
    system.debug('list is ' + cdlList);
    return cdlList;
  }

  @AuraEnabled
  public static String uploadMultipleFiles(String recordId, String filedata) {
    try {
      if (String.isNotBlank(FileData)) {
        Events__c evnt = [SELECT Id, Name FROM Events__c WHERE Id = :recordId];
        String filterCriteria = 'Uploaded Collaterals:' + evnt.Name + ':';
        List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(
          filedata,
          List<FileDataWP>.class
        );
        System.debug(files);

        List<ContentVersion> cvList = new List<ContentVersion>();
        for (FileDataWP file : files) {
          ContentVersion conVer = new ContentVersion();
          conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
          conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
          conVer.Title = file.fileName;
          conVer.PathOnClient = file.fileName;
          cvList.add(conVer);
        }
        insert cvList;
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        for (ContentVersion cv : [
          SELECT ContentDocumentId, Title
          FROM ContentVersion
          WHERE Id = :cvList
        ]) {
          ContentDocumentLink conDocLink = new ContentDocumentLink();
          conDocLink.LinkedEntityId = recordId;
          conDocLink.ContentDocumentId = cv.ContentDocumentId;
          conDocLink.Visibility = 'AllUsers';
          conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
          cdList.add(conDocLink);
          filterCriteria = filterCriteria + '|' + cv.Title;
        }
        insert cdList;
        BrokerPortalSobhaProjectsController.createDataDownloadTracker(
          '',
          filterCriteria
        );
      } else {
        return 'record Id is Blank';
      }
      return 'success';
    } catch (Exception ex) {
      System.debug(
        'Error::::' + ex.getMessage() + ' -> ' + ex.getStackTraceString()
      );
      throw new AuraHandledException(ex.getMessage());
    }
  }

  @AuraEnabled
  public static String uploadMultipleBalanceFiles(
    String brRecordId,
    String filedata
  ) {
    try {
      if (String.isNotBlank(FileData)) {
        String filterCriteria = 'Uploaded Balance Files:';
        List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(
          filedata,
          List<FileDataWP>.class
        );
        System.debug(files);

        List<ContentVersion> cvList = new List<ContentVersion>();
        List<BR_Document_History__c> brhList = new List<BR_Document_History__c>();
        for (FileDataWP file : files) {
          ContentVersion conVer = new ContentVersion();
          conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
          conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
          conVer.Title = file.fileName;
          conVer.PathOnClient = file.fileName;
          cvList.add(conVer);
        }
        insert cvList;

        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        List<ContentVersion> cvlist2 = [
          SELECT ContentDocumentId, Title
          FROM ContentVersion
          WHERE Id = :cvList
        ];
        for (ContentVersion cv : cvlist2) {
          BR_Document_History__c brDoc = new BR_Document_History__c();
          brDoc.File_Type__c = 'Secondary Document';
          brDoc.File_Name__c = cv.Title;
          brDoc.New_File_Uploaded__c = true;
          brDoc.Broker_Registration__c = brRecordId;
          brhList.add(brDoc);
          filterCriteria = filterCriteria + '|' + cv.Title;
        }
        insert brhList;
        for (Integer i = 0; i < cvlist2.size(); i++) {
          ContentDocumentLink conDocLink = new ContentDocumentLink();
          conDocLink.LinkedEntityId = brhList[i].Id;
          conDocLink.ContentDocumentId = cvlist2[i].ContentDocumentId;
          conDocLink.Visibility = 'AllUsers';
          conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
          cdList.add(conDocLink);
        }
        insert cdList;
        BrokerPortalSobhaProjectsController.createDataDownloadTracker(
          '',
          filterCriteria
        );
      } else {
        return 'record Id is Blank';
      }

      return 'success';
    } catch (Exception ex) {
      System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
      throw new AuraHandledException(ex.getMessage());
    }
  }
  // @AuraEnabled
  // public static String uploadMultipleBalanceFiles(String brRecordId, String filedata) {
  //     List<BR_Document_History__c> brh = new List<BR_Document_History__c>();
  //     List<FileExpiryInfo> feiList=new List<FileExpiryInfo>();
  //     if (!String.isBlank(brRecordId)) {
  //         brh = [SELECT Id FROM BR_Document_History__c WHERE File_Type__c = 'Secondary Document' AND Broker_Registration__c = :brRecordId LIMIT 1];
  //         if (!brh.isEmpty()) {
  //             FileExpiryInfo fei= new FileExpiryInfo();
  //             fei.Id=brh[0].Id;
  //             fei.isFileUploaded=true;
  //             feiList.add(fei);
  //             try {
  //                 uploadMultipleFilesInIndividualRecord(brh[0].Id, filedata);
  //                 updateBRHistoryRecord(feiList);
  //                 return 'success';
  //             } catch (Exception e) {
  //                 // Handle the exception or log it if needed
  //                 return 'error: ' + e.getMessage();
  //             }
  //         } else {
  //             try {
  //                 BR_Document_History__c brh1 = new BR_Document_History__c();
  //                 brh1.Broker_Registration__c = Id.valueOf(brRecordId);
  //                 brh1.File_Type__c = 'Secondary Document';
  //                 insert brh1;
  //                 uploadMultipleFilesInIndividualRecord(brh1.Id, filedata);
  //                 FileExpiryInfo fei= new FileExpiryInfo();
  //                 fei.Id=brh1.Id;
  //                 fei.isFileUploaded=true;
  //                 feiList.add(fei);
  //                 updateBRHistoryRecord(feiList);
  //                 return 'success';
  //             } catch (Exception e) {
  //                 // Handle the exception or log it if needed
  //                 return 'error: ' + e.getMessage();
  //             }
  //         }
  //     } else {
  //         return '';
  //     }
  // }

  public class FileDataWP {
    public String fileName;
    public String fileContent;
  }

  @AuraEnabled
  public static Id updateEventsRecord(Object updateData) {
    System.debug('updateData:::' + updateData);
    Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
      JSON.serialize(updateData)
    );
    Object recid = dataMap.remove('Id');

    // Map to hold API names and their corresponding UI labels
    Map<String, String> fieldLabelMap = new Map<String, String>{
      'Campaign_Lead_7_days_before_event__c' => 'Campaign Leads 7 Days Before Event',
      'Campaign_Leads__c' => 'Campaign Leads 15 Days Before Event',
      'Expected_number_of_Visitors__c' => 'Walk-Ins',
      'Confirmed_No_of_Meeting__c' => 'Confirmed Meetings'
    };
    Map<String, Object> labelMap = new Map<String, Object>();
    for (String fieldName : dataMap.keySet()) {
      if (fieldLabelMap.containsKey(fieldName)) {
        labelMap.put(fieldLabelMap.get(fieldName), dataMap.get(fieldName));
      }
    }

    String filterCriteria = JSON.serialize(labelMap);
    Events__c ev = new Events__c();
    ev = (Events__c) JSON.deserialize(
      JSON.serialize(updateData),
      Events__c.class
    );
    update ev;
    if (ev.Collateral_Uploaded__c == true) {
      submitForApproval(ev.Id, 'Collateral_Approval_V8');
    } else {
      filterCriteria = 'Edited Event Line Items:' + filterCriteria;
      BrokerPortalSobhaProjectsController.createDataDownloadTracker(
        '',
        filterCriteria
      );
    }
    return ev.Id;
  }

  // public static void submitApproval(Id recId) {
  //   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
  //   req1.setComments('Submitting request for approval ');
  //   req1.setObjectId(recId);
  //   req1.setProcessDefinitionNameOrId('Collateral_Approval');
  //   Approval.ProcessResult processResults = null;
  //   try {
  //     processResults = Approval.process(req1, true);
  //   } catch (System.DmlException e) {
  //     System.debug('Exception Is ' + e.getMessage());
  //   }
  // }

  @AuraEnabled
  public static void sendEmailToCHRM(
    List<String> emailAddList,
    String templateApiName,
    Id recId
  ) {
    // DocumentUploadEvent__e evt = new DocumentUploadEvent__e();
    // evt.Email_Address__c = 'roshan.bande@ceptes.com';
    // evt.Record_ID__c = 'a4WJX0000001fYz';
    // EventBus.publish(evt);
    // system.debug('Event published');
    //sendEmails(emailAddList, templateApiName, recId);
  }

  @AuraEnabled(cacheable=true)
  public static List<ContentDocumentLink> getAttachedDocuments(Id recordId) {
    List<String> allowedFileTypes = ALLOWED_MEDIA_TYPES;
    List<ContentDocumentLink> attachedDocuments = [
      SELECT
        ContentDocumentId,
        ContentDocument.Title,
        ContentDocument.Description
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :recordId
        AND ContentDocument.FileExtension IN :allowedFileTypes
      WITH SECURITY_ENFORCED
      ORDER BY SystemModstamp
    ];
    return attachedDocuments;
  }
  @AuraEnabled
  public static String setProfilePicture(
    String fileName,
    String fileType,
    String base64Data
  ) {
    User userdata = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
      WITH USER_MODE
    ];

    // input validation before setting profile Photo
    if (
      fileName != null &&
      fileType != null &&
      (fileType.contains('jpeg') || fileType.contains('png')) &&
      base64Data != null
    ) {
      base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
      //set photo

      if (!Test.isRunningTest()) {
        ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(
          null,
          UserInfo.getUserId(),
          new ConnectApi.BinaryInput(
            EncodingUtil.base64Decode(base64Data),
            fileType,
            fileName
          )
        );

        return photo.smallPhotoUrl;
      } else {
        return null;
      }
    } else {
      throw new AuraHandledException('Profile picture not valid');
    }
  }

  @AuraEnabled
  public static void deleteUserPhoto() {
    User userdata = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
      WITH USER_MODE
    ];
    //Network communityId = [SELECT Id FROM Network where name ='Sobha Broker Portal' WITH SECURITY_ENFORCED limit 1];
    if (!Test.isRunningTest()) {
      ConnectApi.UserProfiles.deletePhoto(
        Id.valueOf(System.Label.SobhaBrokerPortalNetworkId),
        userdata.Id
      );
    }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean isEligibleForAction() {
    String userContId = getContactInfo();
    List<Broker_Registration__c> listBrokerRegistration;
    Boolean isEligible = false;
    List<Channel_Partner__c> listBroker = [
      SELECT
        Id,
        Expiry_Date__c,
        Channel_Relationship_Manager__r.Email,
        Name,
        Passport_No__c,
        Mobile_No__c,
        Email_ID_1__c,
        Channel_Partner_Id__c,
        Address__c,
        RERA_Registration_No__c
      FROM Channel_Partner__c
      WHERE Contact__c = :userContId
    ];
    if (!listBroker.isEmpty()) {
      //listBrokerRegistration = [SELECT ID, Name,Renewal_Status__c,Broker_Expiry_Date__c FROM Broker_Registration__c WHERE CPID__c =:listBroker[0].Id AND (Status__c='Executed Agreement sent to broker' OR RecordType.Name='NEW') order by createddate desc Limit 1];
      if (listBroker[0].Expiry_Date__c >= Date.today()) {
        isEligible = true;
      }
    }
    return isEligible;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, String> getPolicyFiles() {
    // List of filenames within the static resource
    List<String> staticResourceNames = new List<String>{
      'Policy_1', // The static resource names (file names)
      'Policy_2'
    };

    // Map to hold filenames and their Base64 encoded content
    Map<String, String> fileNameToBase64Content = new Map<String, String>();

    // Loop through each static resource name
    for (String staticResourceName : staticResourceNames) {
      // Load the static resource content using the StaticResource class
      StaticResource resource = [
        SELECT Body
        FROM StaticResource
        WHERE Name = :staticResourceName
        LIMIT 1
      ];

      // Encode the binary content into Base64
      String base64EncodedContent = EncodingUtil.base64Encode(resource.Body);

      // Add the Base64 encoded content to the map
      staticResourceName = staticResourceName == 'Policy_1'
        ? 'Exclusivity Policy'
        : staticResourceName;
      staticResourceName = staticResourceName == 'Policy_2'
        ? 'Kickback Policy'
        : staticResourceName;

      fileNameToBase64Content.put(staticResourceName, base64EncodedContent);
    }

    // Return the map with filenames and their Base64 encoded content
    return fileNameToBase64Content;
  }

  @AuraEnabled(cacheable=true)
  public static string getBaseURL() {
    return URL.getOrgDomainURL().toExternalForm();
  }

  @AuraEnabled(cacheable=true)
  public static List<User> getSalesTeam(String searchKey, String objectName) {
    string searchAcc = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
    string query =
      'SELECT Id, Name ,FirstName,LastName,Profile.Name FROM ' +
      objectName +
      ' WHERE Profile.Name=\'Sales\' AND Name LIKE ' +
      searchAcc +
      ' LIMIT 5';
    List<User> usrs = Database.query(query);
    return usrs;
  }

  public static Document_validator__c createDocumentValidatorRecord(
    Id brRecordId
  ) {
    Id BrDocHistoryId = brRecordId;
    List<BR_Document_History__c> brDocHistoryList = new List<BR_Document_History__c>();
    if (BrDocHistoryId != null) {
      brDocHistoryList = [
        SELECT
          Id,
          File_Name__c,
          File_Type__c,
          Broker_Registration__c,
          Broker_Registration__r.CPID__c
        FROM BR_Document_History__c
        WHERE ID = :BrDocHistoryId
        LIMIT 1
      ];
    }
    Document_validator__c dvRecord = new Document_validator__c();
    dvRecord.BR_doc_history_id__c = BrDocHistoryId;
    if (!brDocHistoryList.isEmpty()) {
      dvRecord.File_Name__c = brDocHistoryList[0].File_Name__c;
      dvRecord.File_Type__c = brDocHistoryList[0].File_Type__c;
      dvRecord.Broker_Registration__c = brDocHistoryList[0]
        .Broker_Registration__c;
      dvRecord.Channel_Partner__c = brDocHistoryList[0]
        .Broker_Registration__r.CPID__c;
    }

    insert dvRecord;
    return dvRecord;
  }

  public static void submitForApproval(Id recId, string processName) {
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setComments('Submitting request for approval ');
    req1.setObjectId(recId);
    req1.setProcessDefinitionNameOrId(processName);
    Approval.ProcessResult processResults = null;
    try {
      processResults = Approval.process(req1, true);
    } catch (System.DmlException e) {
      System.debug('Exception Is ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static void updateBrokerEmails(
    String accountEmail,
    String alternateEmail
  ) {
    String userContId = getContactInfo();
    List<Channel_Partner__c> listBroker = [
      SELECT Id
      FROM Channel_Partner__c
      WHERE Contact__c = :userContId
    ];
    system.debug('listBroker is ' + listBroker);
    List<Broker_Registration__c> listBrokerRegistration;

    listBrokerRegistration = [
      SELECT ID
      FROM Broker_Registration__c
      WHERE
        CPID__c = :listBroker[0].Id
        AND (Status__c = 'Executed Agreement sent to broker'
        OR RecordType.Name = 'NEW')
      ORDER BY createddate DESC
      LIMIT 1
    ];

    // Query the Broker_Registration__c record by Id
    Broker_Registration__c brokerRecord = [
      SELECT Id
      FROM Broker_Registration__c
      WHERE Id = :listBrokerRegistration[0].Id
      LIMIT 1
    ];

    // Set the new field values
    brokerRecord.Account_Email__c = accountEmail;
    brokerRecord.Alternate_Email__c = alternateEmail;

    // Update the record
    update brokerRecord;
  }
}