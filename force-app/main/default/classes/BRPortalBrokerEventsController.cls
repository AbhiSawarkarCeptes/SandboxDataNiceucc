public without sharing class BRPortalBrokerEventsController {
    private static final List<String> ALLOWED_MEDIA_TYPES = new List<String>{'webm','mp4','mov','m4v'};
    public static String getContactInfo() {
        String userId = UserInfo.getUserId();
        User usr;
        try {
            usr = [SELECT Id, ContactId FROM User WHERE Id =: userId AND ContactId != null LIMIT 1];
        } catch (Exception ex) { throw new AuraHandledException(ex.getMessage());
        }
        if(usr != null) {
            return usr.ContactId;
        } else {
            return null;
        } 
    }   
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEventsDetails(String recType, String fromDOEvent, String toDOEvent, String category, String year) {
        List<User> usr = new List<User>();
        List<Contact> contactList = new List<Contact>();
        Integer apartmentCount = 0, villasCount = 0;
        Map<String, Object> result = new Map<String, Object>();
        List<Events__c> EventsList = new List<Events__c>();
        String filter = '';
        usr = [SELECT Id, CompanyName, Title, 
                SmallPhotoUrl, FullPhotoUrl, 
                ContactId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            contactList = [SELECT Id, Name, AccountId FROM Contact 
                            WHERE Id =: usr[0].ContactId AND 
                                AccountId != null 
                                ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(String.isNotBlank(recType)) {
            filter = filter + 'recordType.Name = \'' + recType + '\'';
        }
        if(String.isNotBlank(fromDOEvent) && String.isNotBlank(toDOEvent)) {
            filter = filter + ' AND Date_Of_Event__c >= ' + fromDOEvent + 
                    ' AND Date_Of_Event__c <= ' + toDOEvent + '';
        } else if(String.isNotBlank(category)) {
            if(category.containsIgnoreCase('Upcoming')) {
                DateTime dToday = DateTime.now();
                String dateStr = dToday.format('yyyy-MM-dd');
                filter=filter+' AND Date_Of_Event__c > '+dateStr+'';
            }
            if(category.containsIgnoreCase('Completed')) {
                DateTime dToday = DateTime.now();
                String dateStr = dToday.format('yyyy-MM-dd');
                filter=filter+' AND Date_Of_Event__c < '+dateStr+'';
            }
        } else if(String.isNotBlank(year)) {
            filter = filter + ' AND CALENDAR_YEAR(Date_Of_Event__c) = ' + year + '';
        } else {
            filter = filter+' AND CALENDAR_YEAR(Date_Of_Event__c) = ' + Date.Today().Year() + '';
        }
        filter = filter + ' AND Event_Approved_status__c IN ( \'Venue Cost Approved\',\'Approved\')';
        if(filter.startsWith('AND')) {  filter = filter.substring(4);
        }
        if(String.isNotBlank(filter))
            filter = ' WHERE ' + filter;
        /*
        String qry = 'SELECT Id, Name, Venue_Video_Shoot__c, Collateral_Uploaded__c, ' + 
                        'Campaign_Leads__c, Campaign_Lead_7_days_before_event__c, ' + 
                        'Sales_Manager__r.Name, Sales_Manager__r.FirstName, ' + 
                        'Sales_Manager__r.LastName, Sales_Director__c, ' + 
                        'Sales_Director__r.Name, Sales_Director__r.FirstName, ' + 
                        'Sales_Director__r.LastName, Total_Purchase_Price__c, ' + 
                        'Expected_number_of_Visitors__c, city_country__c, ' + 
                        'Confirmed_No_of_Meeting__c, Country__c, Date_Of_Event__c, ' + 
                        'End_Date_Of_Event__c, Visit_numbers__c, Event_status__c, ' + 
                        'Event_Sales_Value__c, recordType.Name, CreatedById, ' + 
                        '(SELECT Id, unit__r.Puchase_Price__c, unit__r.Tower__r.Tower_Type__c, ' + 
                        'Status__c FROM Booking1__r WHERE Status__c != \'Cancelled\') FROM Events__c' + 
                        filter + ' AND (Channel_Partner__r.Contact__c =: userContId OR Sobha_Connect__r.Contact__c =:userContId) ORDER BY CreatedDate DESC';
        */
        String qry = '';
        if(!contactList.isEmpty()) {
            qry = 'SELECT Id, Name, Venue_Video_Shoot__c, Collateral_Uploaded__c, ' + 
                    'Campaign_Leads__c, Campaign_Lead_7_days_before_event__c, ' + 
                    'Sales_Manager__r.Name, Sales_Manager__r.FirstName, ' + 
                    'Sales_Manager__r.LastName, Sales_Director__c, ' + 
                    'Sales_Director__r.Name, Sales_Director__r.FirstName, ' + 
                    'Sales_Director__r.LastName, Total_Purchase_Price__c, ' + 
                    'Expected_number_of_Visitors__c, city_country__c, ' + 
                    'Confirmed_No_of_Meeting__c, Country__c, Date_Of_Event__c, ' + 
                    'End_Date_Of_Event__c, Visit_numbers__c, Event_status__c, ' + 
                    'Event_Sales_Value__c, recordType.Name, CreatedById, Remarks__c, ' + 
                    '(SELECT Id, PropStrength__Total_Sales_Consideration__c, PropStrength__Property_Type__c, ' + 
                    'PropStrength__Property_Type__r.PropStrength__Type__c, ' + 
                    'PropStrength__Status__c FROM Applications_Bookings__r WHERE PropStrength__Booking_Cancelled__c = false AND ' + 
                    'PropStrength__Booking_Through__c = \'Broker\' AND PropStrength__Booking_Date__c != null AND ' + 
                    'PropStrength__Project__r.Hide_From_3rd_Party__c = false AND PropStrength__Active__c = true AND ' + 
                    'PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false AND ' + 
                    'PropStrength__Broker_Contact__c = \'' + contactList[0].Id + '\' ) ' + 
                    'FROM Events__c ' + filter;
        }
        if(!contactList.isEmpty()) {
            qry += ' AND Broker_Account__c = \'' + contactList[0].AccountId + '\'';
        }
        qry += ' ORDER BY CreatedDate DESC LIMIT 49999';
        try {
            Map<String, String> eventIdToVideoLink = new Map<String, String>();
            String latestVideoUrl = 'NoURL';
            System.debug('===> qry ' + qry);
            EventsList = Database.query(qry);
            System.debug('===> ' + EventsList);
            if(!EventsList.isEmpty()) {
                for(ContentDistribution cd : [SELECT Id, ContentVersion.FileType, ContentDownloadUrl, 
                                                RelatedRecordId 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    RelatedRecordId IN : EventsList 
                                                    ORDER BY Createddate ASC]) {
                    if(cd.ContentVersion.FileType == 'MP4' || cd.ContentVersion.FileType == 'MOV' || cd.ContentVersion.FileType == 'AVI' || cd.ContentVersion.FileType == 'WMV') {
                        eventIdToVideoLink.put(cd.RelatedRecordId,cd.ContentDownloadUrl);
                        latestVideoUrl = cd.ContentDownloadUrl;
                    }
                }
                for(Events__c evt : EventsList) {
                    Decimal totalPurchasePrice = 0;
                    for(PropStrength__Application_Booking__c booking : evt.Applications_Bookings__r) {
                        totalPurchasePrice += booking.PropStrength__Total_Sales_Consideration__c != null ? booking.PropStrength__Total_Sales_Consideration__c : 0;
                        if(booking.PropStrength__Property_Type__c != null && booking.PropStrength__Property_Type__r.PropStrength__Type__c == 'Apartment') {
                            apartmentCount++;
                        } else if(booking.PropStrength__Property_Type__c != null && booking.PropStrength__Property_Type__r.PropStrength__Type__c == 'Villas') {
                            villasCount++;
                        }
                    }
                    evt.Total_Purchase_Price__c = totalPurchasePrice;
                    if(eventIdToVideoLink.containsKey(string.valueOf(evt.Id))) {  evt.Remarks__c = eventIdToVideoLink.get(evt.Id);
                    } else {
                        evt.Remarks__c = '';
                    }
                }
            }
            if(!EventsList.isEmpty()) {
                result.put('eventsList', EventsList); result.put('userRecordCount', EventsList.size());result.put('apartmentCount', apartmentCount); result.put('villasCount', villasCount);
                result.put('baseURL', URL.getOrgDomainURL().toExternalForm());result.put('latestVideoUrl', latestVideoUrl);
                return result;
            }
        } catch(Exception e) {
            System.debug('===> Exception ' + e.getMessage());
        }
        return null;
    }
    @AuraEnabled
    public static String createEventRecord(Object eventData) {
        String userContId = getContactInfo();
        Events__c ev = new Events__c();
        ev = (Events__c)JSON.deserialize(JSON.serialize(eventData), Events__c.class);
        List<Contact> contactList = [SELECT Id, AccountId, Account.Sales_Manager_User__c, Account.Sales_Director__c, Account.Channel_Relationship_Manager__c FROM Contact WHERE Id =: userContId AND AccountId != null ORDER BY CreatedDate DESC LIMIT 1];
        if(contactList[0].Account.Channel_Relationship_Manager__c == null) { return 'Channel Relationship Manager in not maintained';
        }
        if(!contactList.isEmpty()) {
            System.debug('===> RERERERE '+ ev.RecordTypeId);
            ev.Sales_Manager__c = contactList[0].Account.Sales_Manager_User__c != null ? contactList[0].Account.Sales_Manager_User__c : null;
            ev.Sales_Director__c = contactList[0].Account.Sales_Director__c != null ? contactList[0].Account.Sales_Director__c : null;
            ev.Broker_Account__c = contactList[0].AccountId;
            if(contactList[0].Account.Channel_Relationship_Manager__c != null) {
                ev.OwnerId = contactList[0].Account.Channel_Relationship_Manager__c;
            }
            ev.Start_Time_of_the_Event__c = ev.Start_Time_of_the_Event__c.addHours(4);
            ev.End_Time_of_the_Event__c = ev.End_Time_of_the_Event__c.addHours(4);
            ev.From_Broker_Portal__c = true;
        }
        /*
        List<Channel_partner__C> cp = [SELECT id, Sales_Manager__c, Sales_Manager__r.ManagerId, 
                                        OwnerId, Name 
                                        FROM Channel_Partner__c 
                                        WHERE Contact__c =: userContId LIMIT 1];
        if(!cp.isEmpty()) {
            ev.Channel_Partner__c = cp[0].Id;
            ev.Sales_Manager__c = cp[0].Sales_Manager__c;
            ev.Start_Time_of_the_Event__c = ev.Start_Time_of_the_Event__c.addHours(4);
            ev.End_Time_of_the_Event__c = ev.End_Time_of_the_Event__c.addHours(4);
            ev.OwnerId = cp[0].OwnerId;
        } else {
            List<Sobha_Connect__C> sc = [SELECT id, Sales_Manager__c, Sales_Manager__r.ManagerId, 
                                            OwnerId, Name 
                                            FROM Sobha_Connect__C 
                                            WHERE Contact__c =: userContId LIMIT 1];
            if(!sc.isEmpty()) {
                ev.Sobha_Connect__c = sc[0].Id;
                ev.Sales_Manager__c = sc[0].Sales_Manager__c;
                ev.Start_Time_of_the_Event__c = ev.Start_Time_of_the_Event__c.addHours(4);
                ev.End_Time_of_the_Event__c = ev.End_Time_of_the_Event__c.addHours(4);
                ev.OwnerId = sc[0].OwnerId;
            }
        }*/
        if(ev != null && !Test.isRunningTest()) {
            insert ev;
            System.debug('===> ev ' + ev.Id);
            return String.valueof(ev.Id);
        } else {
            return '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getProfileDetails() {
        String related_Id = '';
        Set<String> agreementSet = new Set<String>();
        List<User> usr = new List<User>();
        List<Contact> contactList = new List<Contact>();
        Map<string, Object> retMap = new Map<String,Object>();
        //List<ContentDistribution> docLink = new List<ContentDistribution>();
        //List<ContentDistribution> NOCLink = new List<ContentDistribution>();
        String baseUrl = URL.getOrgDomainURL().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
        usr = [SELECT Id, CompanyName, Title, 
                SmallPhotoUrl, FullPhotoUrl, 
                ContactId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            contactList = [SELECT Id, Name, FirstName, LastName, Passport_No__c, 
                            MobilePhone, Email, Designation__c, Owner.FirstName, 
                            Channel_Partner_Id__c, Owner.LastName, 
                            Complete_Address__c, Registration_License_Details__c, 
                            RERA_Registration_No__c, AccountId, Account.Renewal_Record_Old__c, 
                            Account.Renewal_Record_Old__r.Broker_Approval_Status__c, 
                            Account.Renewal_Record_Id__c, Account.PropStrength__Broker_Approval_Status__c, 
                            Account.Renewal_Status__c, Account.Expiry_Date__c, 
                            Account.Show_Send_Renewal_Link_Button__c, 
                            Account.Renewal_Record_Id__r.Broker_Approval_Status__c, 
                            Account.Name, Account.Email_ID_1__c, Account.Designation1__c, 
                            Account.Name_as_per_passport__c, Account.Email_ID_2__c, 
                            Account.Account_Owner_Email__c, Account.BillingStreet, Account.BillingCountry, 
                            Account.BillingState, Account.BillingCity, Account.BillingPostalCode, 
                            Account.RERA_Number__c, Account.Registration_Number__c 
                            FROM Contact 
                            WHERE Id =: usr[0].ContactId ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!contactList.isEmpty()) {
            if(contactList[0].Account.Renewal_Record_Id__c != null) {
                related_Id = contactList[0].Account.Renewal_Record_Id__c;
                System.debug('===> related_Id New ' + related_Id);
                /*if(contactList[0].Account.Renewal_Record_Id__r.Broker_Approval_Status__c != null && 
                    contactList[0].Account.Renewal_Record_Id__r.Broker_Approval_Status__c == 'Executed Agreement Sent to Broker' && 
                    contactList[0].Account.Expiry_Date__c > (Date.today() + 30)) {
                    retMap.put('Renewal_status', true);
                } else if(contactList[0].Account.Expiry_Date__c <= (Date.today() + 30) && 
                    contactList[0].Account.Show_Send_Renewal_Link_Button__c && 
                    contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                    retMap.put('Renewal_status', true);
                } else if(!contactList[0].Account.Show_Send_Renewal_Link_Button__c) {
                    retMap.put('Renewal_status', false);
                }*/
                if(contactList[0].Account.Renewal_Record_Id__r.Broker_Approval_Status__c != null && 
                    contactList[0].Account.Renewal_Record_Id__r.Broker_Approval_Status__c == 'Executed Agreement Sent to Broker') {
                    if(contactList[0].Account.Renewal_Status__c != null && contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                        retMap.put('Renewal_status', true);
                    } else {
                        retMap.put('Renewal_status', false);
                    }
                } else {
                    retMap.put('Renewal_status', false);
                }
            } else if(contactList[0].Account.Renewal_Record_Old__c != null) {
                related_Id = contactList[0].Account.Renewal_Record_Old__c;
                System.debug('===> related_Id Old ' + related_Id);
                /*if(contactList[0].Account.Renewal_Record_Old__r.Broker_Approval_Status__c != null && 
                    contactList[0].Account.Renewal_Record_Old__r.Broker_Approval_Status__c == 'Executed Agreement Sent to Broker' && 
                    contactList[0].Account.Expiry_Date__c > (Date.today() + 30)) {
                    retMap.put('Renewal_status', true);
                } else if(contactList[0].Account.Expiry_Date__c <= (Date.today() + 30) && 
                    contactList[0].Account.Show_Send_Renewal_Link_Button__c && 
                    contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                    retMap.put('Renewal_status', true);
                } else if(!contactList[0].Account.Show_Send_Renewal_Link_Button__c) {
                    retMap.put('Renewal_status', false);
                }*/
                if(contactList[0].Account.Renewal_Record_Old__r.Broker_Approval_Status__c != null && 
                    contactList[0].Account.Renewal_Record_Old__r.Broker_Approval_Status__c == 'Executed Agreement Sent to Broker') {
                    if(contactList[0].Account.Renewal_Status__c != null && contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                        retMap.put('Renewal_status', true);
                    } else {
                        retMap.put('Renewal_status', false);
                    }
                } else {
                    retMap.put('Renewal_status', false);
                }
            } else {
                related_Id = contactList[0].AccountId;
                System.debug('===> related_Id Acc ' + related_Id);
                /*if(contactList[0].Account.PropStrength__Broker_Approval_Status__c != null && 
                    contactList[0].Account.PropStrength__Broker_Approval_Status__c == 'Executed Agreement Sent to Broker' && 
                    contactList[0].Account.Expiry_Date__c > (Date.today() + 30)) {
                    retMap.put('Renewal_status', true);
                } else if(contactList[0].Account.Expiry_Date__c <= (Date.today() + 30) && 
                    contactList[0].Account.Show_Send_Renewal_Link_Button__c && 
                    contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                    retMap.put('Renewal_status', true);
                } else if(!contactList[0].Account.Show_Send_Renewal_Link_Button__c) {
                    retMap.put('Renewal_status', false);
                }*/
                if(contactList[0].Account.PropStrength__Broker_Approval_Status__c != null && 
                    contactList[0].Account.PropStrength__Broker_Approval_Status__c == 'Executed Agreement Sent to Broker') {
                    if(contactList[0].Account.Renewal_Status__c != null && contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                        retMap.put('Renewal_status', true);
                    } else {
                        retMap.put('Renewal_status', false);
                    }
                } else {
                    retMap.put('Renewal_status', false);
                }
            }
            retMap.put('Name', contactList[0].Name);
            retMap.put('Passport_No', (contactList[0].Passport_No__c != null ? contactList[0].Passport_No__c : ''));
            retMap.put('Mobile_No', (contactList[0].MobilePhone != null ? contactList[0].MobilePhone : ''));
            retMap.put('Email_Id', (contactList[0].Account.Email_ID_1__c != null ? contactList[0].Account.Email_ID_1__c : ''));
            retMap.put('Broker_Id', (contactList[0].Channel_Partner_Id__c != null ? contactList[0].Channel_Partner_Id__c : ''));
            String accountAddress = '';
            if(contactList[0].Account.BillingStreet != null) {
                accountAddress += contactList[0].Account.BillingStreet + ',';
            }
            if(contactList[0].Account.BillingCity != null) {
                accountAddress += contactList[0].Account.BillingCity + ',';
            }
            if(contactList[0].Account.BillingState != null) {
                accountAddress += contactList[0].Account.BillingState + ',';
            }
            if(contactList[0].Account.BillingCountry != null) {
                accountAddress += contactList[0].Account.BillingCountry + ',';
            }
            if(contactList[0].Account.BillingPostalCode != null) {
                accountAddress += contactList[0].Account.BillingPostalCode;
            }
            retMap.put('Address', accountAddress);
            retMap.put('Reg_num', (contactList[0].Account.Registration_Number__c != null ? contactList[0].Account.Registration_Number__c : ''));
            retMap.put('Rera_no', (contactList[0].Account.RERA_Number__c != null ? contactList[0].Account.RERA_Number__c : ''));

            retMap.put('designation_Auth', (contactList[0].Account.Designation1__c != null ? contactList[0].Account.Designation1__c : ''));
            retMap.put('owner_Email_Id', (contactList[0].Account.Email_ID_2__c != null ? contactList[0].Account.Email_ID_2__c : ''));
            retMap.put('finance_Email_Id', (contactList[0].Account.Account_Owner_Email__c != null ? contactList[0].Account.Account_Owner_Email__c : ''));

            retMap.put('Photo_Url', (usr[0].FullPhotoUrl != null ? usr[0].FullPhotoUrl : ''));
            retMap.put('CompanyName', (contactList[0].Account.Name != null ? contactList[0].Account.Name : ''));
            retMap.put('Title', usr[0].Title);
            retMap.put('Broker_Type', 'Channel Partner');
            retMap.put('owner_Id', contactList[0].Owner.FirstName + ' ' + contactList[0].Owner.LastName);
            retMap.put('auth_Id', (contactList[0].Account.Name_as_per_passport__c != null ? contactList[0].Account.Name_as_per_passport__c : ''));
            //retMap.put('Renewal_status', (contactList[0].Account.PropStrength__Broker_Approval_Status__c != null && contactList[0].Account.PropStrength__Broker_Approval_Status__c == 'Executed Agreement Sent to Broker') ? true : false);
            /*if(contactList[0].Account.Expiry_Date__c != null && contactList[0].Account.Expiry_Date__c < Date.today() && contactList[0].Account.Renewal_Status__c == 'Renewal Completed') {
                retMap.put('RenewalModalPopup', true);
            } else if(contactList[0].Account.Expiry_Date__c == null && contactList[0].Account.Renewal_Status__c == null) {
                retMap.put('RenewalModalPopup', true);
            } else {
                retMap.put('RenewalModalPopup', false);
            }*/
            if(contactList[0].Account.Expiry_Date__c != null && contactList[0].Account.Expiry_Date__c < Date.today()) {
                if(contactList[0].Account.Renewal_Status__c != null && 
                    contactList[0].Account.Renewal_Status__c != 'Renewal Completed') {
                    retMap.put('RenewalModalPopup', false);
                } else {
                    retMap.put('RenewalModalPopup', true);
                }
            } else {
                retMap.put('RenewalModalPopup', false);
            }
            if(contactList[0].Account.Expiry_Date__c != null && (contactList[0].Account.Expiry_Date__c > Date.today())) {
                retMap.put('BR_status_Executed_or_New', false);
            } else {
                retMap.put('BR_status_Executed_or_New', true);
            }
            retMap.put('conId', contactList[0].Id);
            retMap.put('brRecordId', related_Id);
            retMap.put('Expiry_Date', contactList[0].Account.Expiry_Date__c != null ? String.ValueOf(contactList[0].Account.Expiry_Date__c) : '');
        }
        if(!String.isBlank(related_Id)) {
            for(ContentDistribution docLink : [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                                ContentDownloadUrl, ContentVersion.FileType, 
                                                RelatedRecordId 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    RelatedRecordId =: related_Id AND 
                                                    (ContentVersion.Title LIKE 'Agreement%' OR 
                                                    ContentVersion.Title LIKE 'NOC%') 
                                                    ORDER BY CreatedDate DESC LIMIT 9999]) {
                System.debug('===> docLink ' + docLink);
                if(docLink.ContentVersion.Title.startsWith('Agreement') && 
                    !agreementSet.contains('Agreement')) {
                    System.debug('===> Agreement ');
                    retMap.put('doc_Link', docLink.ContentDownloadUrl);
                    agreementSet.add('Agreement');
                } else if(docLink.ContentVersion.Title.startsWith('NOC') && 
                    !agreementSet.contains('NOC')) {
                    System.debug('===> NOC ');
                    retMap.put('NOC_Link', docLink.ContentDownloadUrl);
                    agreementSet.add('NOC');
                }
            }
        }
        /*if(!contactList.isEmpty() && contactList[0].AccountId != null && 
            contactList[0].Account.Renewal_Record_Old__c != null && 
            contactList[0].Account.Renewal_Record_Old__r.Broker_Approval_Status__c == 'Executed Agreement Sent to Broker') {
            docLink = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                        ContentVersion.FileType, ContentDownloadUrl, 
                        RelatedRecordId 
                        FROM ContentDistribution 
                        WHERE RelatedRecordId != null AND 
                            ContentVersion.Title LIKE 'Agreement%' AND 
                            RelatedRecordId = : contactList[0].Account.Renewal_Record_Old__c 
                            ORDER BY CreatedDate DESC LIMIT 1];
            NOCLink = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                            ContentVersion.FileType, ContentDownloadUrl, 
                            RelatedRecordId 
                            FROM ContentDistribution 
                            WHERE RelatedRecordId != null AND 
                                ContentVersion.Title LIKE 'NOC%' AND 
                                RelatedRecordId = : contactList[0].Account.Renewal_Record_Old__c 
                                ORDER BY CreatedDate DESC LIMIT 1];
        } else if(!contactList.isEmpty() && 
            contactList[0].AccountId != null && Account.Renewal_Record_Old__c == null) {
            docLink = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                        ContentVersion.FileType, ContentDownloadUrl, 
                        RelatedRecordId 
                        FROM ContentDistribution 
                        WHERE RelatedRecordId != null AND 
                            ContentVersion.Title LIKE 'Agreement%' AND 
                            RelatedRecordId = : contactList[0].AccountId 
                            ORDER BY CreatedDate DESC LIMIT 1];
            NOCLink = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                        ContentVersion.FileType, ContentDownloadUrl, 
                        RelatedRecordId 
                        FROM ContentDistribution 
                        WHERE RelatedRecordId != null AND 
                            ContentVersion.Title LIKE 'NOC%' AND 
                            RelatedRecordId = : contactList[0].AccountId 
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!docLink.isEmpty()) {
            retMap.put('doc_Link', docLink[0].ContentDownloadUrl);
        }
        if(!NOCLink.isEmpty()) {
            retMap.put('NOC_Link', NOCLink[0].ContentDownloadUrl);//baseUrl + 
        }*/
        return retMap;
    }
    @AuraEnabled(cacheable=true)
    public static List<PropStrength__Projects__c> getProjectsDetails() {
        List<PropStrength__Projects__c> projectList = new List<PropStrength__Projects__c>();
        projectList = [SELECT Id, Name 
                        FROM PropStrength__Projects__c 
                        WHERE PropStrength__Active__c = true 
                            ORDER BY CreatedDate DESC LIMIT 49999];
        if(!projectList.isEmpty()) {
            return projectList;
        } else {
            return null;
        }
    }
    @AuraEnabled
    public static String renewAgreement() {
        System.debug('===> Call here 274 ');
        List<Account> accounList = new List<Account>();
        List<String> chrList = new List<String>();
        List<Id> brId = new List<Id>();
        List<User> usr = new List<User>();
        usr = [SELECT Id, ContactId, Contact.AccountId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            accounList = [SELECT Id, CHRM_s_Email__c, Renewal_Record_Id__c, Renewal_Record_Id__r.CRM_Email__c FROM Account WHERE Id =: usr[0].Contact.AccountId ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!accounList.isEmpty()) {
            System.debug('===> Call here 283 ');
            /*if(accounList[0].Renewal_Record_Id__c != null && accounList[0].Renewal_Record_Id__r.CRM_Email__c != null) {
                chrList.add(accounList[0].Renewal_Record_Id__r.CRM_Email__c);
            } else if(accounList[0].CHRM_s_Email__c != null) {
                chrList.add(accounList[0].CHRM_s_Email__c);
            }*/
            if(accounList[0].Renewal_Record_Id__c == null) {
                brId = BrokerAccountRenewalController.createRenewalRecord(accounList);
            } else if(accounList[0].Renewal_Record_Id__c != null) {
                accounList[0].Renewal_Status__c = 'Renewal Initiated';
                accounList[0].Show_Send_Renewal_Link_Button__c = true;
                update accounList;
                /*if(!chrList.isEmpty()) {
                    System.debug('===> Call here 293 ');
                    sendEmails(chrList, usr[0].ContactId, usr[0].Contact.AccountId);
                }*/
                return 'Success';
            }
            
        }
        if(!brId.isEmpty()) {
            /*if(!chrList.isEmpty()) {
                System.debug('===> Call here 302 ');
                sendEmails(chrList, usr[0].ContactId, usr[0].Contact.AccountId);
            }*/
            return 'Success';
        }
        return 'Fail';
        /*Id scId, cpId;
        List<Id> renewedRecords;
        List<Broker_Registration__c> listBrokerRegistration;
        String userContId = getContactInfo();
        if(userContId == null) {
            return '';
        }
        List<User> usr = [SELECT Id, SmallPhotoUrl, FullPhotoUrl 
                            FROM User 
                            WHERE Id =: UserInfo.getUserId() AND 
                                ContactId != null];
        List<Channel_Partner__c> listBroker = [SELECT Id, Name, Passport_No__c, 
                                                Mobile_No__c, Email_ID_1__c, 
                                                Channel_Partner_Id__c, Address__c, 
                                                RERA_Registration_No__c, Expiry_Date__c 
                                                FROM Channel_Partner__c 
                                                WHERE Contact__c =: userContId];
        if(!listBroker.isEmpty()) {
            cpId = listBroker[0].Id;
            listBrokerRegistration = [SELECT ID, Name 
                                        FROM Broker_Registration__c 
                                        WHERE CPID__c =: cpId LIMIT 1];
        } else {
            List<Sobha_Connect__c> listBrokerSc = [SELECT Id, Name, Registration__c, 
                                                        Mobile_No__c, Email_Id__c, Name__c, 
                                                        Address__c, RERA_Number__c, 
                                                        Expiry_Date__c 
                                                        FROM Sobha_Connect__c 
                                                        WHERE Contact__c =: userContId];
            if(!listBrokerSc.isEmpty()) {
                scId = listBrokerSc[0].Id;
                listBrokerRegistration = [SELECT ID, Name 
                                            FROM Broker_Registration__c 
                                            WHERE SCID__c =: scId LIMIT 1];
            } else {
                return '';
            }
        }
        if(!listBrokerRegistration.isEmpty()) {
            renewedRecords = BrokerRegistrationRenewalController.createRenewalRecord(listBrokerRegistration);
        }
        if(!renewedRecords.isEmpty()) {
            return 'Successfully created renewal.';
        } else {
            return '';
        }*/
    }
    @AuraEnabled(cacheable=true)
    public static List<ContactWithImage> getRelatedContacts() {
        List<ContactWithImage> relatedCons = new List<ContactWithImage>();
        String userContId = getContactInfo();
        system.debug('getRelated contacts method ');
        List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id =: userContId AND AccountId != null LIMIT 1];
        if(!contacts.isEmpty()) {
            Id accountId = contacts[0].AccountId;
            for(Contact con : [SELECT Id, Name, Email, Phone, 
                                (SELECT Id, SmallPhotoUrl, FullPhotoUrl 
                                FROM Users) 
                                FROM Contact 
                                WHERE AccountId =: accountId AND 
                                    Account.RecordType.Name = 'Broker' AND 
                                    RecordType.Name = 'Broker' ORDER BY CreatedDate DESC LIMIT 999]) {
                System.debug('===> con ' + con);
                for(User u : con.Users) {
                    relatedCons.add(new ContactWithImage(con.Name, u.SmallPhotoUrl));
                }
            }
        }
        System.debug('===> relatedCons ' + relatedCons.size());
        return relatedCons;
    }
    public class ContactWithImage {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String imageUrl {get; set;}
        public ContactWithImage(String name, String imageUrl) {
            this.name = name;
            this.imageUrl = imageUrl;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<docWrapper> getBRFileHistory(Boolean showBalanceFiles) {
        System.debug('===> showBalanceFiles ' + showBalanceFiles);
        List<docWrapper> brDocumentList = new List<docWrapper>();
        List<User> usr = new List<User>();
        List<BR_Document_History__c> brokerDocHistryList = new List<BR_Document_History__c>();
        Set<String> fileTypeSet = new Set<String>();
        String parentalId = '';
        String accountRecordId = '';
        Map<String, BR_Document_History__c> idToBRRecordMap = new Map<String, BR_Document_History__c>();
        String relateId = '';
        Set<String> agreementSet = new Set<String>();
        usr = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Renewal_Record_Old__c, 
                Contact.Account.Renewal_Record_Id__c 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('===> usr ' + usr);
        if(!usr.isEmpty()) {
            if(usr[0].Contact.Account.Renewal_Record_Id__c != null) {
                parentalId = usr[0].Contact.Account.Renewal_Record_Id__c;
                System.debug('===> parentalId New ' + parentalId);
            } else if(usr[0].Contact.Account.Renewal_Record_Old__c != null) {
                parentalId = usr[0].Contact.Account.Renewal_Record_Old__c;
                System.debug('===> parentalId Old ' + parentalId);
            } else {
                accountRecordId = usr[0].Contact.AccountId;
                System.debug('===> accountRecordId ' + accountRecordId);
            }
        }
        
        if(!String.isBlank(parentalId)) {
            if(showBalanceFiles == true) {
                for(BR_Document_History__c brHistory : [SELECT Id, Name, Broker_Renewal__c, Expiry_date__c, 
                                                            File_Name__c, File_Type__c                                                             
                                                            FROM BR_Document_History__c 
                                                            WHERE Broker_Renewal__c =: parentalId AND 
                                                                File_Type__c = 'Secondary Document' 
                                                                ORDER BY CreatedDate DESC LIMIT 9999]) {
                    System.debug('===> Renewal Balance ');
                    idToBRRecordMap.put(brHistory.Id, brHistory);
                }
            } else {
                for(BR_Document_History__c brHistory : [SELECT Id, Name, Broker_Renewal__c, Expiry_date__c, 
                                                            File_Name__c, File_Type__c 
                                                            FROM BR_Document_History__c 
                                                            WHERE Broker_Renewal__c =: parentalId AND 
                                                                File_Type__c != 'Secondary Document' AND 
                                                                File_Type__c != null 
                                                                ORDER BY CreatedDate DESC LIMIT 9999]) {
                    if(!fileTypeSet.contains(brHistory.File_Type__c)) {
                        System.debug('===> Renewal without Balance ');
                        idToBRRecordMap.put(brHistory.Id, brHistory);
                        fileTypeSet.add(brHistory.File_Type__c);
                    }
                }
            }
        } else if(!String.isBlank(accountRecordId)) {
            if(showBalanceFiles == true) {
                for(BR_Document_History__c brHistory : [SELECT Id, Name, Broker_Account__c, Expiry_date__c, 
                                                            File_Name__c, File_Type__c                                                             
                                                            FROM BR_Document_History__c 
                                                            WHERE Broker_Account__c =: accountRecordId AND 
                                                                File_Type__c = 'Secondary Document' 
                                                                ORDER BY CreatedDate DESC LIMIT 9999]) {
                    System.debug('===> Account Balance ');
                    idToBRRecordMap.put(brHistory.Id, brHistory);
                }
            } else {
                for(BR_Document_History__c brHistory : [SELECT Id, Name, Broker_Account__c, Expiry_date__c, 
                                                            File_Name__c, File_Type__c 
                                                            FROM BR_Document_History__c 
                                                            WHERE Broker_Account__c =: accountRecordId AND 
                                                                File_Type__c != 'Secondary Document' AND 
                                                                File_Type__c != null 
                                                                ORDER BY CreatedDate DESC LIMIT 9999]) {
                    if(!fileTypeSet.contains(brHistory.File_Type__c)) {
                        System.debug('===> Account without Balance ');
                        idToBRRecordMap.put(brHistory.Id, brHistory);
                        fileTypeSet.add(brHistory.File_Type__c);
                    }
                }
            }
        }
        if(!String.isBlank(parentalId)) {
            relateId = parentalId;
        } else if(!String.isBlank(accountRecordId)) {
            relateId = accountRecordId;
        }
        System.debug('===> relateId ' + relateId);
        if(!String.isBlank(relateId) && 
            showBalanceFiles == false) {
            for(ContentDistribution docLink : [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                                ContentDownloadUrl, ContentVersion.FileType, 
                                                RelatedRecordId 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    RelatedRecordId =: relateId AND 
                                                    (ContentVersion.Title LIKE 'Agreement%' OR 
                                                    ContentVersion.Title LIKE 'NOC%') 
                                                    ORDER BY CreatedDate DESC LIMIT 9999]) {
                System.debug('===> docLink ' + docLink);
                if(docLink.ContentVersion.Title.startsWith('Agreement') && 
                    !agreementSet.contains('Agreement')) {
                    System.debug('===> Agreement ');
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                            docLink.ContentDownloadUrl, 
                                                            '',
                                                            docLink.ContentVersion.FileType, 
                                                            'Agreement', 
                                                            false,
                                                            '');
                    brDocumentList.add(docwrap);
                    agreementSet.add('Agreement');
                } else if(docLink.ContentVersion.Title.startsWith('NOC') && 
                    !agreementSet.contains('NOC')) {
                    System.debug('===> NOC ');
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                            docLink.ContentDownloadUrl, 
                                                            '',
                                                            docLink.ContentVersion.FileType, 
                                                            'NOC', 
                                                            false,
                                                            '');
                    brDocumentList.add(docwrap);
                    agreementSet.add('NOC');
                }
            }
        }
        if(!idToBRRecordMap.keyset().isEmpty()) {
            for(ContentDistribution docLink : [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                                ContentDownloadUrl, ContentVersion.FileType, 
                                                RelatedRecordId 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    RelatedRecordId IN: idToBRRecordMap.keyset() 
                                                    ORDER BY CreatedDate DESC LIMIT 9999]) {
                System.debug('===> ' + docLink);
                if(idToBRRecordMap.containskey(docLink.RelatedRecordId) && 
                    idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c != null && 
                    idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c != 'Secondary Document' && 
                    !agreementSet.contains(docLink.RelatedRecordId)) {
                    System.debug('===> Sample ' + idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c);
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                            docLink.ContentDownloadUrl, 
                                                            ((idToBRRecordMap.containskey(docLink.RelatedRecordId) && idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c != null) ? (idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c).toString() : ''), 
                                                            docLink.ContentVersion.FileType, 
                                                            idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c, 
                                                            true, 
                                                            docLink.RelatedRecordId);
                    /*if(idToBRRecordMap.containskey(docLink.RelatedRecordId) && 
                        idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c != null) {
                        Integer numberDaysDue = (System.today()).daysBetween(idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c);
                        docwrap.expiryDur = String.valueof(numberDaysDue);
                    } else {
                        docwrap.expiryDur = '0';
                    }*/
                    brDocumentList.add(docwrap);
                    agreementSet.add(docLink.RelatedRecordId);
                } else if(idToBRRecordMap.containskey(docLink.RelatedRecordId) && 
                    idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c != null && 
                    idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c == 'Secondary Document' && 
                    !agreementSet.contains(docLink.RelatedRecordId)) {
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                            docLink.ContentDownloadUrl, 
                                                            ((idToBRRecordMap.containskey(docLink.RelatedRecordId) && idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c != null) ? (idToBRRecordMap.get(docLink.RelatedRecordId).Expiry_date__c).toString() : ''), 
                                                            docLink.ContentVersion.FileType, 
                                                            docLink.ContentVersion.Title, 
                                                            false, 
                                                            docLink.RelatedRecordId);
                    //docwrap.expiryDur = '0';
                    brDocumentList.add(docwrap);
                    agreementSet.add(docLink.RelatedRecordId);
                }
                //((idToBRRecordMap.containskey(docLink.RelatedRecordId) && idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c != null) ? idToBRRecordMap.get(docLink.RelatedRecordId).File_Type__c : '')
            }
        }
        System.debug('===> brDocumentList size ' + brDocumentList.size());
        System.debug('===> brDocumentList ' + brDocumentList);
        /*List<User> usr = new List<User>();
        List<Account> accountList = new List<Account>();
        Map<String, String> docNameToExpireDate = new Map<String, String>();
        List<docWrapper> brDocumentList = new List<docWrapper>();
        Set<String> documentNameSet = new Set<String>();
        String parentalId = '';
        usr = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Renewal_Record_Old__c, 
                Contact.Account.Emirates_ID_Expiry_Date__c, Contact.Account.Passport_Expiry_Date__c, 
                Contact.Account.RERA_Expiry_Date__c, Contact.Account.Visa_Expiry_Date__c, 
                Contact.Account.Old_Emirates_ID_Expiry_Date__c, Contact.Account.Old_Passport_Expiry_Date__c, 
                Contact.Account.Old_RERA_Expiry_Date__c, Contact.Account.Old_Visa_Expiry_Date__c, 
                Contact.Account.Old_Trade_License_Expiry_Date__c, Contact.Account.Trade_License_Expiry_Date__c, 
                Contact.Account.Renewal_Record_Old__r.Emirates_ID_Expiry_Date__c, 
                Contact.Account.Renewal_Record_Old__r.Passport_Expiry_Date__c, 
                Contact.Account.Renewal_Record_Old__r.RERA_Expiry_Date__c, 
                Contact.Account.Renewal_Record_Old__r.Visa_Expiry_Date__c, 
                Contact.Account.Renewal_Record_Old__r.Trade_License_Expiry_Date__c 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            if(usr[0].Contact.Account.Renewal_Record_Old__c != null) {
                parentalId = usr[0].Contact.Account.Renewal_Record_Old__c;
                docNameToExpireDate.put('Passport', (usr[0].Contact.Account.Renewal_Record_Old__r.Passport_Expiry_Date__c != null ? usr[0].Contact.Account.Renewal_Record_Old__r.Passport_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Emirates', (usr[0].Contact.Account.Renewal_Record_Old__r.Emirates_ID_Expiry_Date__c != null ? usr[0].Contact.Account.Renewal_Record_Old__r.Emirates_ID_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('RERA', (usr[0].Contact.Account.Renewal_Record_Old__r.RERA_Expiry_Date__c != null ? usr[0].Contact.Account.Renewal_Record_Old__r.RERA_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Visa', (usr[0].Contact.Account.Renewal_Record_Old__r.Visa_Expiry_Date__c != null ? usr[0].Contact.Account.Renewal_Record_Old__r.Visa_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Trade', (usr[0].Contact.Account.Renewal_Record_Old__r.Trade_License_Expiry_Date__c != null ? usr[0].Contact.Account.Renewal_Record_Old__r.Trade_License_Expiry_Date__c.toString() : ''));
            } else {
                parentalId = usr[0].Contact.AccountId;
                docNameToExpireDate.put('Passport', (usr[0].Contact.Account.Passport_Expiry_Date__c != null ? usr[0].Contact.Account.Passport_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Emirates', (usr[0].Contact.Account.Emirates_ID_Expiry_Date__c != null ? usr[0].Contact.Account.Emirates_ID_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('RERA', (usr[0].Contact.Account.RERA_Expiry_Date__c != null ? usr[0].Contact.Account.RERA_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Visa', (usr[0].Contact.Account.Visa_Expiry_Date__c != null ? usr[0].Contact.Account.Visa_Expiry_Date__c.toString() : ''));
                docNameToExpireDate.put('Trade', (usr[0].Contact.Account.Trade_License_Expiry_Date__c != null ? usr[0].Contact.Account.Trade_License_Expiry_Date__c.toString() : ''));
            }
        }
        System.debug('===> docNameToExpireDate ' + docNameToExpireDate);
        System.debug('===> parentalId ' + parentalId);*/
        //if(!String.isBlank(parentalId)) {
            /*for(ContentDistribution docLink : [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                                ContentDownloadUrl, ContentVersion.FileType 
                                                FROM ContentDistribution 
                                                WHERE RelatedRecordId != null AND 
                                                    RelatedRecordId =: parentalId 
                                                    ORDER BY CreatedDate DESC LIMIT 9999]) {
                if(docLink.ContentVersion.Title.startsWith('Passport') && 
                    !documentNameSet.contains('Passport')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        (docNameToExpireDate.containskey('Passport') ? docNameToExpireDate.get('Passport') : ''), 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Passport');
                } else if(docLink.ContentVersion.Title.startsWith('Emirates') && 
                    !documentNameSet.contains('Emirates')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        (docNameToExpireDate.containskey('Emirates') ? docNameToExpireDate.get('Emirates') : ''), 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Emirates');
                } else if(docLink.ContentVersion.Title.startsWith('RERA') && 
                    !documentNameSet.contains('RERA')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        (docNameToExpireDate.containskey('RERA') ? docNameToExpireDate.get('RERA') : ''), 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('RERA');
                } else if(docLink.ContentVersion.Title.startsWith('Visa') && 
                    !documentNameSet.contains('Visa')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        (docNameToExpireDate.containskey('Visa') ? docNameToExpireDate.get('Visa') : ''), 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Visa');
                } else if(docLink.ContentVersion.Title.startsWith('Trade') && 
                    !documentNameSet.contains('Trade')) {
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        (docNameToExpireDate.containskey('Trade') ? docNameToExpireDate.get('Trade') : ''), 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Trade');
                } else if(docLink.ContentVersion.Title.startsWith('Agreement') && 
                    !documentNameSet.contains('Agreement')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        '', 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Agreement');
                } else if(docLink.ContentVersion.Title.startsWith('NOC') && 
                    !documentNameSet.contains('NOC')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        '', 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('NOC');
                } else if(!docLink.ContentVersion.Title.startsWith('Passport') && 
                    !docLink.ContentVersion.Title.startsWith('Emirates') && 
                    !docLink.ContentVersion.Title.startsWith('RERA') && 
                    !docLink.ContentVersion.Title.startsWith('Visa') && 
                    !docLink.ContentVersion.Title.startsWith('Trade') && 
                    !docLink.ContentVersion.Title.startsWith('Agreement') && 
                    !docLink.ContentVersion.Title.startsWith('NOC')) { 
                    docWrapper docwrap = new docWrapper(docLink.ContentDocumentId, 
                                                        docLink.ContentDownloadUrl, 
                                                        '', 
                                                        docLink.ContentVersion.FileType, 
                                                        docLink.ContentVersion.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);
                }
            }*/

            /*
            for(ContentDocumentLink link : [SELECT Id, ContentDocumentId, 
                                                ContentDocument.Title, 
                                                ContentDocument.LatestPublishedVersionId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: parentalId 
                                                    ORDER BY ContentDocument.CreatedDate DESC LIMIT 9999]) {
                System.debug('===> link.ContentDocument.Title ' + link.ContentDocument.Title);
                if(link.ContentDocument.Title.startsWith('Passport') && 
                    !documentNameSet.contains('Passport')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        (docNameToExpireDate.containskey('Passport') ? docNameToExpireDate.get('Passport') : ''), 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Passport');
                } else if(link.ContentDocument.Title.startsWith('Emirates') && 
                    !documentNameSet.contains('Emirates')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        (docNameToExpireDate.containskey('Emirates') ? docNameToExpireDate.get('Emirates') : ''), 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Emirates');
                } else if(link.ContentDocument.Title.startsWith('RERA') && 
                    !documentNameSet.contains('RERA')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        (docNameToExpireDate.containskey('RERA') ? docNameToExpireDate.get('RERA') : ''), 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('RERA');
                } else if(link.ContentDocument.Title.startsWith('Visa') && 
                    !documentNameSet.contains('Visa')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        (docNameToExpireDate.containskey('Visa') ? docNameToExpireDate.get('Visa') : ''), 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Visa');
                } else if(link.ContentDocument.Title.startsWith('Trade') && 
                    !documentNameSet.contains('Trade_License')) {
                    System.debug('===> ' + link.ContentDocument.Title);
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        (docNameToExpireDate.containskey('Trade') ? docNameToExpireDate.get('Trade') : ''), 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        parentalId);
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Trade');
                } else if(link.ContentDocument.Title.startsWith('Agreement') && 
                    !documentNameSet.contains('Agreement')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        '', 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('Agreement');
                } else if(link.ContentDocument.Title.startsWith('NOC') && 
                    !documentNameSet.contains('NOC')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        '', 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);                                
                    documentNameSet.add('NOC');
                } else if(!link.ContentDocument.Title.startsWith('Passport') && 
                    !link.ContentDocument.Title.startsWith('Emirates') && 
                    !link.ContentDocument.Title.startsWith('RERA') && 
                    !link.ContentDocument.Title.startsWith('Visa') && 
                    !link.ContentDocument.Title.startsWith('Trade License') && 
                    !link.ContentDocument.Title.startsWith('Agreement') && 
                    !link.ContentDocument.Title.startsWith('NOC')) { 
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        '', 
                                                        '', 
                                                        link.ContentDocument.Title, 
                                                        false, 
                                                        '');
                    brDocumentList.add(docwrap);
                }
            }
            */
        //}
        //System.debug('===> brDocumentList ' + brDocumentList.size());
        /*String userContId = getContactInfo();
        List<BR_Document_History__c> docListSet = new List<BR_Document_History__c>();
        List<docWrapper> brDocumentList = new List<docWrapper>();
        Map<String, docWrapper> uniqueDocumentsMap = new Map<String, docWrapper>();
        List<Broker_Registration__c> listBrokerRegistration;
        List<Channel_Partner__c> listBroker = [SELECT Id, Name, Passport_No__c, Mobile_No__c, 
                                                    Email_ID_1__c, Channel_Partner_Id__c, Address__c, 
                                                    RERA_Registration_No__c, Expiry_Date__c 
                                                    FROM Channel_Partner__c 
                                                    WHERE Contact__c =: userContId];
        system.debug('listBroker is '+ listBroker);
        if(!listBroker.isEmpty()) {
            listBrokerRegistration = [SELECT Id, Name, recordType.name,
                                        (SELECT Id, ContentDocumentId, ContentDocument.Title, 
                                        ContentDocument.LatestPublishedVersionId 
                                        FROM ContentDocumentLinks 
                                        ORDER BY ContentDocument.CreatedDate DESC) 
                                        FROM Broker_Registration__c 
                                        WHERE CPID__c =: listBroker[0].Id 
                                            ORDER BY CreatedDate DESC LIMIT 1];
            List<BR_Document_History__c> brDocHistList = [SELECT Id, File_Name__c, Start_Date__c, 
                                                            Expiry_date__c, Broker_Registration__c, 
                                                            file_type__c, 
                                                            (SELECT Id, ContentDocumentId, 
                                                            ContentDocument.Title, 
                                                            ContentDocument.LatestPublishedVersionId 
                                                            FROM ContentDocumentLinks 
                                                                ORDER BY ContentDocument.CreatedDate DESC) 
                                                            FROM BR_Document_History__c 
                                                            WHERE Broker_Registration__c =: listBrokerRegistration[0].Id];
            for(Broker_Registration__c reg : listBrokerRegistration) {
                for(ContentDocumentLink link : reg.ContentDocumentLinks) {
                    String key = link.ContentDocument.Title;
                    System.debug('key value is : '+key);
                    if(link.ContentDocument.Title.startsWith('Agreement - ') || 
                        link.ContentDocument.Title.startsWith('NOC - ')) { 
                        System.debug('inside condition is :  '+link.ContentDocument.Title);
                        docWrapper docwrap = new docWrapper(link.ContentDocumentId,link.ContentDocument.LatestPublishedVersionId,'','',link.ContentDocument.Title,false,'');
                        brDocumentList.add(docwrap);                                
                        uniqueDocumentsMap.put(key, docwrap); 
                    }
                    System.debug('brDocumentList 444: '+brDocumentList);
                }
            }
            for(BR_Document_History__c brDoc : brDocHistList) {
                for(ContentDocumentLink link : brDoc.ContentDocumentLinks) {
                    System.debug('link.ContentDocument.Title : ' + link.ContentDocument.Title);
                    String key = link.ContentDocument.Title;
                    docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                        link.ContentDocument.LatestPublishedVersionId, 
                                                        brDoc.Expiry_date__c != null ? brDoc.Expiry_date__c.toString(): '', 
                                                        brDoc.file_type__c, 
                                                        link.ContentDocument.Title, 
                                                        true, 
                                                        brDoc.Id);
                    brDocumentList.add(docwrap);   
                    System.debug('brDocumentList : '+brDocumentList);
                }
            }
            System.debug('brDocumentList 35: '+brDocumentList);
            return brDocumentList;
        } else if(listBroker.isEmpty()) {
            List<Sobha_Connect__c> listBrokerSc = [SELECT Id, Name, Registration__c, Mobile_No__c, 
                                                    Email_Id__c, Name__c, 
                                                    Address__c, RERA_Number__c, 
                                                    Expiry_Date__c 
                                                    FROM Sobha_Connect__c 
                                                    WHERE Contact__c =: userContId];
            if(!listBrokerSc.isEmpty()) {
                listBrokerRegistration = [SELECT Id, Name, 
                                            (SELECT Id, ContentDocumentId, ContentDocument.Title, 
                                            ContentDocument.LatestPublishedVersionId 
                                            FROM ContentDocumentLinks 
                                            ORDER BY ContentDocument.CreatedDate DESC) 
                                            FROM Broker_Registration__c 
                                            WHERE SCID__c =: listBrokerSc[0].Id 
                                                ORDER BY CreatedDate DESC LIMIT 1];
                List<BR_Document_History__c> brDocHistList = [SELECT Id,File_Name__c, Start_Date__c, 
                                                                Expiry_date__c, Broker_Registration__c, 
                                                                file_type__c,
                                                                (SELECT Id, ContentDocumentId, 
                                                                ContentDocument.Title, 
                                                                ContentDocument.LatestPublishedVersionId 
                                                                FROM ContentDocumentLinks
                                                                ORDER BY ContentDocument.CreatedDate DESC)
                                                                FROM BR_Document_History__c 
                                                                WHERE Broker_Registration__c =: listBrokerRegistration[0].Id];
                for(Broker_Registration__c reg : listBrokerRegistration) {
                    for(ContentDocumentLink link : reg.ContentDocumentLinks) {
                        String key = link.ContentDocument.Title;
                        if(link.ContentDocument.Title.startsWith('Agreement') || 
                            link.ContentDocument.Title.startsWith('NOC')) { 
                            docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                                link.ContentDocument.LatestPublishedVersionId,'',
                                                                '',link.ContentDocument.Title,
                                                                false,'');
                            brDocumentList.add(docwrap);                                
                            uniqueDocumentsMap.put(key, docwrap); 
                        }
                    }
                }
                for(BR_Document_History__c brDoc : brDocHistList) {
                    for(ContentDocumentLink link : brDoc.ContentDocumentLinks) {
                        String key = link.ContentDocument.Title;
                        if(!uniqueDocumentsMap.containsKey(key)) {
                            docWrapper docwrap = new docWrapper(link.ContentDocumentId, 
                                                                link.ContentDocument.LatestPublishedVersionId, 
                                                                brDoc.Expiry_date__c != null ? brDoc.Expiry_date__c.toString(): '', 
                                                                brDoc.file_type__c,link.ContentDocument.Title, 
                                                                true,
                                                                brDoc.Id);
                            brDocumentList.add(docwrap);   
                            uniqueDocumentsMap.put(key, docwrap);
                        }
                    }
                }
                return brDocumentList;
            }
        }*/
        return brDocumentList;
    }
    @AuraEnabled
    public static void deleteFile(Id fileId) {
        // Your file deletion logic here
        ContentDocumentLink[] links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =: fileId];
        if (!links.isEmpty()) {
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: links[0].ContentDocumentId];
            delete cd;
        }
    }
    public class docWrapper {
        @AuraEnabled
        public Id fileId {get; set;}
        @AuraEnabled
        public String latestVersionId {get; set;}
        @AuraEnabled
        public String baseUrl {get; set;}
        @AuraEnabled
        public String expiryDate {get; set;}
        /*@AuraEnabled
        public String expiryDur {get; set;}*/
        @AuraEnabled
        public String fileType {get; set;}
        @AuraEnabled
        public String fileName {get; set;}
        @AuraEnabled
        public boolean ObjectName {get; set;}
        @AuraEnabled
        public String recordId {get; set;}
        public docWrapper(Id fileId, String latestVersionId, String expiryDate, String fileType, String fileName, Boolean ObjectName, String recordId) {
            this.fileId = fileId;
            this.latestVersionId = latestVersionId;
            this.baseUrl = URL.getOrgDomainURL().toExternalForm();
            this.expiryDate = expiryDate;
            this.fileType = fileType;
            this.fileName = fileName;
            this.ObjectName = ObjectName;
            this.recordId = recordId;
        }
    }
    @AuraEnabled
    public static String uploadFiles(String base64, String filename, String record_Id, String filetype) {
        System.debug('===> record_Id ' + record_Id);
        System.debug('inside upload files');
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, record_Id);
        if(cv == null || cdl == null) {
            return null;
        }
        System.debug('cdl Id : '+cdl.Id);
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
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
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
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if(contentVersionId == null || recordId == null) {
            return null;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId 
                                    FROM ContentVersion 
                                    WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled
    public static String updateBRHistoryRecord(List<ExpiryInfoWrapper> fileExpiryList) {
        List<BR_Document_History__c> brUpdateList = new List<BR_Document_History__c>();
        if(!fileExpiryList.isEmpty()) {
            for(ExpiryInfoWrapper feRec : fileExpiryList) {
                if(!String.isBlank(feRec.Id) && 
                    feRec.expiryDate != null) {
                    BR_Document_History__c newBR = new BR_Document_History__c(Id=feRec.Id);
                    newBR.Expiry_date__c = feRec.expiryDate;
                    brUpdateList.add(newBR);
                }
            }
        }
        if(!brUpdateList.isEmpty()) {
            update brUpdateList;
            return 'Updated';
        }
        return '';
        /*List<Account> accountList = new List<Account>();
        List<Broker_Renewal__c> brokerRenewalList = new List<Broker_Renewal__c>();
        Map<Id, List<ExpiryInfoWrapper>> recToExpiryInfoList = new Map<Id, List<ExpiryInfoWrapper>>();
        List<Account> oldAccList = new List<Account>();
        List<Broker_Renewal__c> brList = new List<Broker_Renewal__c>();
        List<Id> sObjectSet = new List<Id>();
        if(!fileExpiryList.isEmpty()) {
            for(ExpiryInfoWrapper feRec : fileExpiryList) {
                if(recToExpiryInfoList.containskey(feRec.Id)) {
                    List<ExpiryInfoWrapper> tempList = recToExpiryInfoList.get(feRec.Id);
                    tempList.add(feRec);
                    recToExpiryInfoList.put(feRec.Id, tempList);
                } else {
                    recToExpiryInfoList.put(feRec.Id, new List<ExpiryInfoWrapper>{feRec});
                }
                sObjectSet.add(feRec.Id);
            }
        }
        if(!sObjectSet.isEmpty() && 
            sObjectSet[0] != null) {
            String objName = sObjectSet[0].getSObjectType().getDescribe().getName();
            if(objName == 'Account') {
                oldAccList = [SELECT Id, Name, Passport_Expiry_Date__c, Emirates_ID_Expiry_Date__c, 
                                RERA_Expiry_Date__c, Visa_Expiry_Date__c, Trade_License_Expiry_Date__c, 
                                Old_Trade_License_Expiry_Date__c, Old_Visa_Expiry_Date__c, 
                                Old_RERA_Expiry_Date__c, Old_Emirates_ID_Expiry_Date__c, 
                                Old_Passport_Expiry_Date__c 
                                FROM Account 
                                WHERE Id =: sObjectSet[0] 
                                    ORDER BY CreatedDate DESC LIMIT 1];
            } else if(objName == 'Broker_Renewal__c') {
                brList = [SELECT Id, Name, Broker_Account__c, 
                            Broker_Account__r.Renewal_Record_Id__c 
                            FROM Broker_Renewal__c 
                            WHERE Id =: sObjectSet[0] AND 
                                Broker_Account__c != null AND 
                                Broker_Account__r.Renewal_Record_Id__c != null 
                                ORDER BY CreatedDate DESC LIMIT 1];
                if(brList.isEmpty()) {
                    return 'Please initiate broker renewal.';
                }
            }
        }
        if(!recToExpiryInfoList.keyset().isEmpty()) {
            for(Id accId : recToExpiryInfoList.keyset()) {
                String objectName = accId.getSObjectType().getDescribe().getName();
                if(!recToExpiryInfoList.get(accId).isEmpty()) {
                    if(objectName == 'Broker_Renewal__c' && 
                        !brList.isEmpty()) {
                        Broker_Renewal__c newBR = new Broker_Renewal__c();
                        newBR.Id = brList[0].Broker_Account__r.Renewal_Record_Id__c;
                        for(ExpiryInfoWrapper fetchWrap : recToExpiryInfoList.get(accId)) {
                            if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Passport')) {
                                newBR.Passport_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Emirates')) {
                                newBR.Emirates_ID_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('RERA')) {
                                newBR.RERA_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Visa')) {
                                newBR.Visa_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Trade')) {
                                newBR.Trade_License_Expiry_Date__c = fetchWrap.expiryDate;
                            }
                        }
                        brokerRenewalList.add(newBR);
                    } else if(objectName == 'Account') {
                        Account newAccount = new Account();
                        newAccount.Id = accId;
                        for(ExpiryInfoWrapper fetchWrap : recToExpiryInfoList.get(accId)) {
                            if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Passport')) {
                                if(!oldAccList.isEmpty() && 
                                    oldAccList[0].Old_Passport_Expiry_Date__c == null && 
                                    oldAccList[0].Passport_Expiry_Date__c != null) {
                                    newAccount.Old_Passport_Expiry_Date__c = oldAccList[0].Passport_Expiry_Date__c;
                                }
                                newAccount.Passport_Expiry_Date__c = fetchWrap.expiryDate;

                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Emirates')) {
                                if(!oldAccList.isEmpty() && 
                                    oldAccList[0].Old_Emirates_ID_Expiry_Date__c == null && 
                                    oldAccList[0].Emirates_ID_Expiry_Date__c != null) {
                                    newAccount.Old_Emirates_ID_Expiry_Date__c = oldAccList[0].Emirates_ID_Expiry_Date__c;
                                }
                                newAccount.Emirates_ID_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('RERA')) {
                                if(!oldAccList.isEmpty() && 
                                    oldAccList[0].Old_RERA_Expiry_Date__c == null && 
                                    oldAccList[0].RERA_Expiry_Date__c != null) {
                                    newAccount.Old_RERA_Expiry_Date__c = oldAccList[0].RERA_Expiry_Date__c;
                                }
                                newAccount.RERA_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Visa')) {
                                if(!oldAccList.isEmpty() && 
                                    oldAccList[0].Old_Visa_Expiry_Date__c == null && 
                                    oldAccList[0].Visa_Expiry_Date__c != null) {
                                    newAccount.Old_Visa_Expiry_Date__c = oldAccList[0].Visa_Expiry_Date__c;
                                }
                                newAccount.Visa_Expiry_Date__c = fetchWrap.expiryDate;
                            } else if(fetchWrap.Id != null && fetchWrap.expiryDate != null && 
                                fetchWrap.docName != null && 
                                fetchWrap.docName.startsWith('Trade')) {
                                if(!oldAccList.isEmpty() && 
                                    oldAccList[0].Old_Trade_License_Expiry_Date__c == null && 
                                    oldAccList[0].Trade_License_Expiry_Date__c != null) {
                                    newAccount.Old_Trade_License_Expiry_Date__c = oldAccList[0].Trade_License_Expiry_Date__c;
                                }
                                newAccount.Trade_License_Expiry_Date__c = fetchWrap.expiryDate;
                            }
                        }
                        accountList.add(newAccount);
                    }
                }
            }
        }
        if(!brokerRenewalList.isEmpty()) {
            update brokerRenewalList;
            return 'Updated';
        } else if(!accountList.isEmpty()) {
            update accountList;
            return 'Updated';
        }
        return '';*/
    }
    public class ExpiryInfoWrapper {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public Date expiryDate {get; set;}
        @AuraEnabled 
        public String docName {get; set;}
    }
    public class FileExpiryInfo {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public Date expiryDate {get; set;}
        @AuraEnabled 
        public Boolean isFileUploaded {get; set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<ContentDistribution> getCollataralFiles(String linkedRecord) { 
        Id recId = Id.ValueOf(linkedRecord);
        List<ContentDistribution> cdlList = new List<ContentDistribution>();
        if(recId != null) {
            cdlList = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                        ContentVersion.FileType, 
                        ContentDownloadUrl 
                        FROM ContentDistribution 
                        WHERE RelatedRecordId != null AND 
                            RelatedRecordId =: recId 
                            ORDER BY CreatedDate DESC LIMIT 999];
        }
        /*List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocument.FileType, 
                                                ContentDocument.Title, ContentDocumentId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =: recId];*/
        system.debug('===> cdlList ' + cdlList);
        return cdlList;
    }
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getVideoFiles(String linkedRecord) { 
        Id recId = Id.ValueOf(linkedRecord);
        List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocument.FileType, 
                                                ContentDocument.Title, 
                                                ContentDocumentID 
                                                FROM ContentDocumentLink 
                                                WHERE ContentDocument.FileType = 'MP4' AND 
                                                    LinkedEntityId =: recId 
                                                    ORDER BY ContentDocument.CreatedDate DESC LIMIT 1];
        system.debug('list is '+cdlList);
        return cdlList;
    }
    @AuraEnabled
    public static String uploadMultipleFiles(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug(files);
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    conVer.Title = file.fileName;
                    conVer.PathOnClient = file.fileName;
                    cvList.add(conVer);
                }
                insert cvList;
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static String uploadMultipleBalanceFiles(String brRecordId, String filedata) {
        List<BR_Document_History__c> brh = new  List<BR_Document_History__c>();
        String objectName = '';
        String resultReturn = '';
        if(!String.isBlank(brRecordId)) {
            Id rec_Id = Id.valueof(brRecordId);
            objectName = rec_Id.getSObjectType().getDescribe().getName();
        }
        try {
            if(!String.isBlank(brRecordId) && 
                !String.isBlank(objectName)) {
                BR_Document_History__c brh1 = new BR_Document_History__c();
                if(objectName == 'Broker_Renewal__c') {
                    brh1.Broker_Renewal__c = Id.valueOf(brRecordId);
                } else if(objectName == 'Account') {
                    brh1.Broker_Account__c = Id.valueOf(brRecordId);
                }
                brh1.File_Type__c = 'Secondary Document';
                insert brh1;
                resultReturn = uploadMultipleFiles(brh1.Id, filedata);
            }
        } catch (Exception e) {
            // Handle the exception or log it if needed
            return 'error: ' + e.getMessage();
        }
        return resultReturn;
        /*if(!brh.isEmpty()) {
            FileExpiryInfo fei = new FileExpiryInfo();
            fei.Id = brh[0].Id;
            fei.isFileUploaded = true;
            feiList.add(fei);
            try {
                uploadMultipleFiles(brh[0].Id, filedata);
                //updateBRHistoryRecord(feiList);
                return 'success';
            } catch (Exception e) {
                // Handle the exception or log it if needed
                return 'error: ' + e.getMessage();
            }
        } else {
            try {
                BR_Document_History__c brh1 = new BR_Document_History__c();
                brh1.Broker_Registration__c = Id.valueOf(brRecordId);
                brh1.File_Type__c = 'Secondary Document';
                Insert brh1;
                uploadMultipleFiles(brh1.Id, filedata);
                FileExpiryInfo fei= new FileExpiryInfo();
                fei.Id = brh1.Id;
                fei.isFileUploaded=true;
                feiList.add(fei);
                //updateBRHistoryRecord(feiList);
                return 'success';
            } catch (Exception e) {
                // Handle the exception or log it if needed
                return 'error: ' + e.getMessage();
            }
        }*/ 
    }
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
    @AuraEnabled
    public static Id updateEventsRecord(Object updateData) {
        Events__c ev = new Events__c();
        ev = (Events__c)JSON.deserialize(JSON.serialize(updateData), Events__c.class);
        update ev;
        if(ev.Collateral_Uploaded__c == true) {
            submitApproval(ev.Id);
        }
        return ev.Id;
    }
    public static void submitApproval(Id recId) {
        Approval.ProcessSubmitRequest req1 = new 
        Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval ');  
        req1.setObjectId(recId);
        req1.setProcessDefinitionNameOrId('Collateral_Approval');
        Approval.ProcessResult processResults = null;
        try {
            processResults = Approval.process(req1, true);
        } catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void sendEmailToCHRM(List<String> emailAddList, String templateApiName, Id recId)
    {
        // DocumentUploadEvent__e evt = new DocumentUploadEvent__e();
        // evt.Email_Address__c = 'roshan.bande@ceptes.com';
        // evt.Record_ID__c = 'a4WJX0000001fYz';
        // EventBus.publish(evt);
        // system.debug('Event published');
        //sendEmails(emailAddList, templateApiName, recId);
    }
    @future
    public static void sendEmails(List<String> emailAddList, Id recId, Id accountId) {
        List<String> emList = new List<String>();
        //emList.add('marteen@cloudsteer.com');
        List<EmailTemplate> emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                                        FROM EmailTemplate 
                                        WHERE DeveloperName = 'Broker_Renew_Registration_Form' LIMIT 1];
        if(emailTemplate != null && !emailAddList.isEmpty() && recId != null && accountId != null) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateID(emailTemplate[0].Id);
            message.setTargetObjectId(recId);
            message.setWhatId(accountId);
            message.htmlbody = emailTemplate[0].HtmlValue != null ? emailTemplate[0].HtmlValue : '';
            message.setToAddresses(emailAddList);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
            //Messaging.sendEmail(messages);
            /*Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if(results != null && results[0].success) {
                System.debug('The email was sent successfully.');
            } else if(results != null) {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }*/
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getAttachedDocuments(Id recordId) {
        List<String> allowedFileTypes = ALLOWED_MEDIA_TYPES;
        List<ContentDocumentLink> attachedDocuments = [SELECT
                                                        ContentDocumentId,
                                                        ContentDocument.Title,
                                                        ContentDocument.Description
                                                        FROM ContentDocumentLink
                                                        WHERE LinkedEntityId = :recordId AND 
                                                            ContentDocument.FileExtension IN: allowedFileTypes 
                                                            WITH SECURITY_ENFORCED 
                                                            ORDER BY SystemModstamp];
        return attachedDocuments;
    }
    @AuraEnabled
    public static String setProfilePicture(String fileName, String fileType, String base64Data) {
        User userdata =  [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() WITH USER_MODE];
        // input validation before setting profile Photo 
        if(fileName != null && fileType != null && (fileType.contains('jpeg') || fileType.contains('png')) && base64Data != null) {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            //set photo
            if(!Test.isRunningTest()) {
                ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(null, UserInfo.getUserId(), new ConnectApi.BinaryInput(EncodingUtil.base64Decode(base64Data), fileType, fileName));
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
        User userdata = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() WITH USER_MODE];
        //Network communityId = [SELECT Id FROM Network WHERE Name = 'Sobha Broker Portal' WITH SECURITY_ENFORCED LIMIT 1];
        //ConnectApi.UserProfiles.deletePhoto(communityId.Id,userdata.Id);
        ConnectApi.UserProfiles.deletePhoto(Id.valueOf(System.Label.SobhaBrokerPortalNetworkId),userdata.Id);
    }
    @AuraEnabled
    public static String getBodyFile(String contVersionId) {
        ContentVersion contentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE Id =: contVersionId LIMIT 1];
        return EncodingUtil.base64Encode(contentVersion.VersionData);
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isEligibleForAction() {
        Boolean isEligible = false;
        List<User> usr = new List<User>();
        List<Account> accountList = new List<Account>();
        usr = [SELECT Id, Contact.AccountId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            accountList = [SELECT Id, Name, Expiry_Date__c FROM Account 
                            WHERE Id =: usr[0].Contact.AccountId 
                                ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!accountList.isEmpty()) {
            if(accountList[0].Expiry_Date__c >= Date.today()) {
                isEligible = true;
            }
        } 
        return isEligible;
    }
    @AuraEnabled(cacheable=true)
    public static List<PolicyWrapper> getPolicyFiles() {
        /*List<ContentDocument> contentDocs = [SELECT Id, Title
                                                FROM ContentDocument
                                                WHERE Title LIKE '%dummy%'];
        List<String> contentDocIds = new List<String>();
        for(ContentDocument doc : contentDocs) {
            // contentDocIds.add(String.valueOf(doc.Id));
            doc.Title = 'Mandate Letter';
        }
        return contentDocs;*/

        // List of filenames within the static resource
        /*List<String> staticResourceNames = new List<String>{
            'Policy_1','Policy_2'
        };
        // List to hold the full URLs
        Map<String,String> fileNameTofileUrls = new  Map<String,String>();
        // Get the base URL for the static resource
        String baseUrl = URL.getOrgDomainUrl().toExternalForm() + '/resource/';
        fileNameTofileUrls.put('Exclusivity Policy', baseUrl + '/sfc/servlet.shepherd/version/download/');
        fileNameTofileUrls.put('Sobha Circular', baseUrl + '/sfc/servlet.shepherd/version/download/');
        return fileNameTofileUrls;
        */
        Set<String> policyNameSet = new Set<String>();
        List<PolicyWrapper> policyWrapperList = new List<PolicyWrapper>();
        for(ContentDistribution cVersion : [SELECT Id, ContentVersion.Title, ContentVersionId FROM ContentDistribution WHERE ContentVersion.Title IN ('Policy_1','Policy_2')]) {
            System.debug('===> cVersion ' +cVersion);
            if(!policyNameSet.contains(cVersion.ContentVersion.Title) && cVersion.ContentVersion.Title == 'Policy_1') {
                PolicyWrapper pWrapper = new PolicyWrapper(); 
                pWrapper.policyName = 'Exclusivity Policy';
                pWrapper.contentVirsionId = cVersion.ContentVersionId;
                policyWrapperList.add(pWrapper);
                policyNameSet.add(cVersion.ContentVersion.Title);
            } else if(!policyNameSet.contains(cVersion.ContentVersion.Title) && cVersion.ContentVersion.Title == 'Policy_2') {
                PolicyWrapper pWrapper = new PolicyWrapper();
                pWrapper.policyName = 'Kickback Policy';
                pWrapper.contentVirsionId = cVersion.ContentVersionId;
                policyWrapperList.add(pWrapper);
                policyNameSet.add(cVersion.ContentVersion.Title);
            }
        }
        System.debug('===> policyWrapperList ' + policyWrapperList.size());
        return policyWrapperList;
    }
    public class PolicyWrapper {
        @AuraEnabled
        public String policyName {get; set;}
        @AuraEnabled
        public String contentVirsionId {get; set;}
    }
    @AuraEnabled(cacheable=true)
    public static string getBaseURL() {
        return URL.getOrgDomainURL().toExternalForm();
    }
    @AuraEnabled(cacheable=true)
    public static List<User> getSalesTeam(String searchKey, String objectName) {
        String searchAcc = '\'' + String.escapeSingleQuotes(searchKey) + '%\''; 
        String query = 'SELECT Id, Name, FirstName, LastName, Profile.Name FROM ' + objectName + 
                        ' WHERE Profile.Name = \'Sales\' AND IsActive = true AND Name LIKE ' + searchAcc + ' ORDER BY CreatedDate DESC LIMIT 5'; 
        List<User> usrs = Database.query(query); 
        return usrs;
    }
}