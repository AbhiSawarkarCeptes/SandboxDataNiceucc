public without sharing class BRSiteVisitChartController {
    @AuraEnabled(cacheable=true)
    public static List<Customer_Registration__c> SiteVisits() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        system.debug('loggedInUserContactId' + loggedInUserContactId);
        return [SELECT Name, Booking__c, Visit_Month__c 
                FROM Customer_Registration__c 
                WHERE Broker_Contact__c =: loggedInUserContactId AND 
                    RecordType.Name = 'Site Visit'];
    }
    @AuraEnabled(cacheable=true)
    public static TemplateInfo fetchEmailTemplateInfo(String templateName) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName =: templateName LIMIT 1];
        return new TemplateInfo(template.Subject, template.Body);
    }
    //Total Appartment Booking
    @AuraEnabled(cacheable=true)
    public static Integer getBookingAppartmentsCount() {
        Integer count = 0;
        Id loggedInUserContactId = getLoggedInUserContactId();
        /*List<AggregateResult> results = [SELECT COUNT(Id) totalBookings
                                         FROM Booking__c
                                         WHERE Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c = 'Apartments') and  Status__c !='Cancelled' and (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId)];
        if(results.size() > 0) {
            count = Integer.valueOf(results[0].get('totalBookings'));
        }*/
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT COUNT(Id) totalBookings 
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Property__r.RecordType.Name = 'Apartment' AND 
                                                PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                PropStrength__Active__c = true AND 
                                                PropStrength__Booking_Cancelled__c = false AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        if(results.size() > 0) {
            count = Integer.valueOf(results[0].get('totalBookings'));
        }
        return count;
    }
    //Total Villa Booking
    @AuraEnabled(cacheable=true)
    public static Integer getBookingVillasCount() {
        Integer count = 0;
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT COUNT(Id) totalBookings
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Property__r.RecordType.Name = 'Villas' AND 
                                                PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                PropStrength__Active__c = true AND 
                                                PropStrength__Booking_Cancelled__c = false AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        if(results.size() > 0) {
            count = Integer.valueOf(results[0].get('totalBookings'));
        }
        return count;
    }
    //get booking data for one month chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingData() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month 
                FROM PropStrength__Application_Booking__c 
                WHERE (PropStrength__Broker_Contact__c =: loggedInUserContactId) AND 
                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                    PropStrength__Booking_Through__c = 'Broker' AND 
                    PropStrength__Booking_Date__c != null AND 
                    PropStrength__Active__c = true AND 
                    PropStrength__Booking_Cancelled__c = false AND 
                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)];
    }
    //get sitevisits data for one month chart
    @AuraEnabled(cacheable=true)
    public static Map<string,integer> getSitevisits1(list<Integer> years,list<Integer> months) {
        Map<integer, string> monthNames = new Map<integer, string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
        Map<string, integer> response = new map<String, integer>();
        for(integer yr : years) {
            for(integer mo : months) {
                response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
            }
        }
        System.debug('===> response 75 ' + response);
        Id loggedInUserContactId = getLoggedInUserContactId();
        for(AggregateResult agg : [SELECT COUNT(Id) recordCount, 
                                        CALENDAR_MONTH(CreatedDate) month, 
                                        CALENDAR_YEAR(CreatedDate) year 
                                        FROM Customer_Registration__c 
                                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                                            RecordType.Name = 'Site Visit' 
                                            GROUP BY CALENDAR_MONTH(CreatedDate), CALENDAR_YEAR(CreatedDate) 
                                            ORDER BY CALENDAR_YEAR(CreatedDate)]) {
            System.debug('===> agg month ' + (integer)agg.get('month'));
            System.debug('===> agg Year ' + (integer)agg.get('year'));
            Integer mon = (integer)agg.get('month');
            if(response.containsKey(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')))) {
                response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
            }
        }
        System.debug('===> response 93 ' + response);
        return response; 
    }
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisits(Integer years, Integer months) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = [SELECT COUNT(Id) recordCount, 
                                            CALENDAR_MONTH(CreatedDate) month, 
                                            CALENDAR_YEAR(CreatedDate) year 
                                            FROM Customer_Registration__c 
                                            WHERE Broker_Contact__c =: loggedInUserContactId AND 
                                                RecordType.Name = 'Site Visit' AND 
                                                CALENDAR_YEAR(CreatedDate) =: years 
                                                GROUP BY CALENDAR_MONTH(CreatedDate), CALENDAR_YEAR(CreatedDate) 
                                                ORDER BY CALENDAR_YEAR(CreatedDate)];
        return results;
        /*List<AggregateResult> results = [SELECT COUNT(Id) recordCount, 
                                            CALENDAR_MONTH(Date_of_Site_Visit__c) month, 
                                            CALENDAR_YEAR(Date_of_Site_Visit__c) year 
                                            FROM PropStrength__Request__c 
                                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Enquiry_Type__c = 'Partner' AND 
                                                PropStrength__Request_Status__c = 'Site Visit Done' AND 
                                                Date_of_Site_Visit__c != null 
                                                GROUP BY CALENDAR_MONTH(Date_of_Site_Visit__c), CALENDAR_YEAR(Date_of_Site_Visit__c) 
                                                ORDER BY CALENDAR_YEAR(Date_of_Site_Visit__c)];*/
        
    }
    // get sales Booking data for 1 month
    @AuraEnabled(cacheable=true)
    public static Map<string,integer> getSalesBookings(List<Integer> years, List<Integer> months) {
        Map<integer,string> monthNames = new Map<integer,string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
        Map<string,integer> response = new Map<string,integer>();
        for(integer yr : years) {
            for(integer mo : months) {
                response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
            }
        }
        system.debug('===> response ' + response);
        Id loggedInUserContactId = getLoggedInUserContactId();
        for(AggregateResult agg : [SELECT COUNT(Id) recordCount, 
                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) month, 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) year 
                                        FROM PropStrength__Application_Booking__c 
                                        WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                            CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                            CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                            PropStrength__Booking_Date__c != null AND 
                                            PropStrength__Active__c = true AND 
                                            PropStrength__Booking_Cancelled__c = false AND 
                                            PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                            PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                            GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                            ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
            system.debug('===> agg.get(month) ' + agg.get('month'));
            system.debug('===> agg.get(year) ' + agg.get('year'));
            system.debug('===> agg.get(recordCount) ' + agg.get('recordCount'));
            integer mon = (integer)agg.get('month');
            if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
            }
        }
        system.debug('===> response ' + response);
        system.debug('response ' + response.size());
        return response; 
    }
    // get Bookings data for Quartely  chart 
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataQuaterly(Integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c), COUNT(Id) recordCount 
                FROM PropStrength__Application_Booking__c 
                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                    PropStrength__Booking_Through__c = 'Broker' AND 
                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                    PropStrength__Booking_Date__c != null AND 
                    PropStrength__Active__c = true AND 
                    PropStrength__Booking_Cancelled__c = false AND 
                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                    GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)];
    }
    //get booking data for Bi-Yearly  chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataHalfYearly(integer selectedYear) {
        System.debug('===> selectedYear ' + selectedYear);
        Id loggedInUserContactId = getLoggedInUserContactId();
        System.debug('===> loggedInUserContactId ' + loggedInUserContactId);
        return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month, 
                CALENDAR_YEAR(PropStrength__Booking_Date__c) year 
                FROM PropStrength__Application_Booking__c 
                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                    PropStrength__Booking_Through__c = 'Broker' AND 
                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                    PropStrength__Booking_Date__c != null AND 
                    PropStrength__Active__c = true AND 
                    PropStrength__Booking_Cancelled__c = false AND 
                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c)  
                    ORDER BY CALENDAR_MONTH(PropStrength__Booking_Date__c)];
    }
  //get Booking chart for yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataYearly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_YEAR(PropStrength__Booking_Date__c) month 
                    FROM PropStrength__Application_Booking__c 
                    WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                        PropStrength__Booking_Through__c = 'Broker' AND 
                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                        PropStrength__Booking_Date__c != null AND 
                        PropStrength__Active__c = true AND 
                        PropStrength__Booking_Cancelled__c = false AND 
                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                        GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                        ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c) ];
    }
    // get siteVisit data for Quartely  chart 
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsQuaterly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT CALENDAR_QUARTER(CreatedDate), COUNT(Id) recordCount 
                FROM Customer_Registration__c 
                WHERE Broker_Contact__c =: loggedInUserContactId AND 
                    RecordType.Name = 'Site Visit' AND 
                    CALENDAR_YEAR(CreatedDate) =: selectedYear 
                    GROUP BY CALENDAR_QUARTER(CreatedDate)];
    }
    //get site visits for Bi-yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsHalfYearly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer monthOfInterest = Date.today().month();
        List<AggregateResult> results = new List<AggregateResult>() ;
        results = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(CreatedDate) month, 
                    CALENDAR_YEAR(CreatedDate) year 
                    FROM Customer_Registration__c 
                    WHERE Broker_Contact__c =: loggedInUserContactId AND 
                    RecordType.Name = 'Site Visit' AND 
                    CALENDAR_YEAR(CreatedDate) =: selectedYear 
                    GROUP BY CALENDAR_MONTH(CreatedDate), CALENDAR_YEAR(CreatedDate) 
                    ORDER BY CALENDAR_MONTH(CreatedDate)];
        return results;
    }
    //get Sitevisit data for yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsYearly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_YEAR(CreatedDate) month 
                    FROM Customer_Registration__c 
                    WHERE Broker_Contact__c =: loggedInUserContactId AND 
                        RecordType.Name = 'Site Visit' AND 
                        CALENDAR_YEAR(CreatedDate) =: selectedYear 
                        GROUP BY CALENDAR_YEAR(CreatedDate) 
                        ORDER BY CALENDAR_YEAR(CreatedDate)]; 
    }
    @AuraEnabled(cacheable=true)
    public static List<Events__c> getUpcomingAllEvents() {
        List<User> usr = new List<User>();
        Id loggedInUserContactAccountId;
        usr = [SELECT Id, Contact.AccountId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            loggedInUserContactAccountId = usr[0].Contact.AccountId;
        }
        if(loggedInUserContactAccountId != null) {
            return [SELECT Name, Date_Of_Event__c, City_Country__c
                    FROM Events__c 
                    WHERE RecordType.name IN ('Open Houses','Business Trip','Road Shows','Video Shoot') AND 
                        Date_Of_Event__c >: Date.today() AND 
                        Broker_Account__c =: loggedInUserContactAccountId AND 
                        Event_Approved_status__c IN ('Pending for Hotel Finalization','Approved','Invoice Under Review','Venue Cost Pending Approval - CMO','Venue Cost Approved') 
                        ORDER BY Date_Of_Event__c LIMIT 5];
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUpcomingEvents(String recordType) {
        List<User> usr = new List<User>();
        Id loggedInUserContactAccountId;
        usr = [SELECT Id, Contact.AccountId 
                FROM User 
                WHERE Id =: UserInfo.getUserId() AND 
                    ContactId != null AND 
                    Contact.AccountId != null 
                    ORDER BY CreatedDate DESC LIMIT 1];
        if(!usr.isEmpty()) {
            loggedInUserContactAccountId = usr[0].Contact.AccountId;
        }
        String recordTypeName = '';
        String queryStr = '';
        if(recordType == 'Open Houses') {
            recordTypeName = 'Open Houses';
            queryStr = ' (RecordType.Name = \'Open Houses\' ) AND ';
        } else if(recordType == 'Road Shows') {
            recordTypeName = 'Road Shows';
            queryStr = ' (RecordType.Name = \'Road Shows\' ) AND ';
        } else if(recordType == 'Business Trip') {
            recordTypeName = 'Business Trip';
            queryStr = ' (RecordType.Name = \'Business Trip\' ) AND ';
        } else if(recordType == 'Videoshoot') {
            recordTypeName = 'Video Shoots';
            queryStr = ' (RecordType.Name = \'Video Shoot\' ) AND ';
        } else if(recordType == 'All') {
            recordTypeName = 'All';
        }
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        System.debug('todaysDateStr '+todaysDateStr);
        String queryString = 'SELECT Name, Date_Of_Event__c, City_Country__c FROM Events__c WHERE ' + queryStr + ' Date_Of_Event__c != null AND Date_Of_Event__c > ' + 
                                todaysDateStr + ' AND (Broker_Account__c = \'' + loggedInUserContactAccountId + '\') AND Event_Approved_status__c IN (\'Pending for Hotel Finalization\',\'Approved\',\'Invoice Under Review\',\'Venue Cost Pending Approval - CMO\',\'Venue Cost Approved\') ORDER BY Date_Of_Event__c LIMIT 5';
        System.debug('===> queryString: ' + queryString);
        List<Events__c> events  = Database.query(queryString);
        Integer recordCount = events.size();
        Map<String, Object> result = new Map<String, Object>();
        result.put('events', events);
        result.put('recordCount', recordCount);
        return result;
    }
    // get the sitevisist count of current month 
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountInCurrentMonth() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        // Execute SOQL query to get records for the current month of the current year
        List<AggregateResult> results = [SELECT COUNT(Id) recordCount 
                                            FROM Customer_Registration__c 
                                            WHERE Broker_Contact__c =: loggedInUserContactId AND 
                                                RecordType.Name = 'Site Visit' AND 
                                                CALENDAR_YEAR(CreatedDate) =: currentYear AND 
                                                CALENDAR_MONTH(CreatedDate) =: currentMonth];
        if(!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0;
            // Return 0 if no records found for the current month 
        }
    }
    //get Current Quater sitevisits count
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountLastThreeMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = new List<AggregateResult>();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        if(currentMonth >= 1 && currentMonth <= 3) {
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (1,2,3) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        } else if(currentMonth >= 4 && currentMonth <= 6) {
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (4,5,6) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        } else if(currentMonth >= 7 && currentMonth <= 9) {
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (7,8,9) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        } else if(currentMonth >= 10 && currentMonth <= 12) {
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (10,11,12) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        }
        if(!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0;
            // Return 0 if no records found for the current year
        }
    }
    //get Current Bi yearly sitevisits count
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountLastSixMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        Integer monthOfInterest = Date.today().month();
        List<AggregateResult> results = new List<AggregateResult>() ;
        if(monthOfInterest >= 1 && monthOfInterest <= 6) {
            // Months 1 to 6 (January to June) case
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (1,2,3,4,5,6) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        } else {
            // Months 7 to 12 (July to December) case
            results = [SELECT COUNT(Id) recordCount 
                        FROM Customer_Registration__c 
                        WHERE Broker_Contact__c =: loggedInUserContactId AND 
                            RecordType.Name = 'Site Visit' AND 
                            CALENDAR_MONTH(CreatedDate) IN (7,8,9,10,11,12) AND 
                            CALENDAR_YEAR(CreatedDate) =: currentYear];
        }
        /*Integer totalCount = 0;
        // Sum up the record counts from each AggregateResult
        for(AggregateResult result : results) {
            Integer count = (Integer)result.get('recordCount');
            totalCount += count != null ? count : 0;
        }
        return totalCount;*/
        if (!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0;
            //Return 0 if no records found for the current year
        }
    }
    //get Current yearly sitevisits count
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountInCurrentYear() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT COUNT(Id) recordCount 
                                            FROM Customer_Registration__c 
                                            WHERE Broker_Contact__c =: loggedInUserContactId AND 
                                                RecordType.Name = 'Site Visit' AND 
                                                CALENDAR_YEAR(CreatedDate) =: currentYear];
        if (!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0;
            //Return 0 if no records found for the current year
        }
    }
    // get current month Total Considerasion Booking
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInCurrentMonth() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        Date startDate = Date.newInstance(currentYear, currentMonth, 1);
        Date endDate = startDate.addMonths(1).addDays(-1);
        List<AggregateResult> results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                PropStrength__Active__c = true AND 
                                                PropStrength__Booking_Cancelled__c = false AND 
                                                (PropStrength__Booking_Date__c >= :startDate AND 
                                                PropStrength__Booking_Date__c <= :endDate) AND 
                                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    // get current Quater Total Considerasion Booking
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInLastThreeMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = new List<AggregateResult>();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        if(currentMonth >= 1 && currentMonth <= 3) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (1,2,3) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        } else if(currentMonth >= 4 && currentMonth <= 6) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (4,5,6) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        } else if(currentMonth >= 7 && currentMonth <= 9) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (7,8,9) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        } else if(currentMonth >= 10 && currentMonth <= 12) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (10,11,12) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        }
        if(!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    // get current bi year Total Considerasion Booking
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInLastSixMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = new List<AggregateResult>();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        if(currentMonth >= 1 && currentMonth <= 6) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (1,2,3,4,5,6) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        } else if(currentMonth >= 7 && currentMonth <= 12) {
            results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                            FROM PropStrength__Application_Booking__c 
                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN (7,8,9,10,11,12) AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        }
        if(!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    // get current year Total Considerasion Booking
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInCurrentYear() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                PropStrength__Active__c = true AND 
                                                PropStrength__Booking_Cancelled__c = false AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: currentYear AND 
                                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    // Method to get the ContactId of the logged-in user
    @AuraEnabled(cacheable=true)
    public static Id getLoggedInUserContactId() {
        List<User> userList = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() AND ContactId != null ORDER BY CreatedDate DESC LIMIT 1];
        if(!userList.isEmpty()) {
            return userList[0].ContactId;
        } else {
            return null;
        }
    }
    public class TemplateInfo {
        @AuraEnabled
        public String Subject {get; set;}
        @AuraEnabled
        public String Body {get; set;}
        public TemplateInfo(String subject, String body) {
            this.Subject = subject;
            this.Body = body;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<PropStrength__Application_Booking__c> getBookingDataDetails() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT Id, PropStrength__Property__r.PropStrength__Property_Name__c, 
                    PropStrength__Total_Sales_Consideration__c, PropStrength__Property__r.DLD_Unit_No__c, 
                    PropStrength__Property__r.Super_Area_Sq_Mtr__c, PropStrength__Booking_Date__c, 
                    SPA_Executed__c, Signed_Status__c, PropStrength__Status__c, 
                    PropStrength__Total_Paid_Percent__c,Booking_Form_Signed_by_Customer__c,
                    PropStrength__Property__r.DLD_Admin_Fees__c, Name, 
                    Oqood_Fees_Received_Date__c, PropStrength__Property__c, 
                    PropStrength__Property__r.PropStrength__Unit_Type__c, 
                    PropStrength__Primary_Customer__c, 
                    PropStrength__Primary_Applicant_Name__c, 
                    PropStrength__Primary_Customer__r.PropStrength__Nationality__c, 
                    PropStrength__Broker_Contact__r.Name, 
                    Sales_Manager__r.Name, Sales_Manager__r.FirstName, Sales_Manager__r.LastName, 
                    Sales_Head__r.Name, Sales_Head__r.FirstName, Sales_Head__r.LastName 
                    FROM PropStrength__Application_Booking__c 
                    WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                        PropStrength__Booking_Through__c = 'Broker' AND 
                        PropStrength__Booking_Date__c != null AND 
                        PropStrength__Active__c = true AND 
                        PropStrength__Booking_Cancelled__c = false AND 
                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                        ORDER BY PropStrength__Booking_Date__c DESC];
        /*return [SELECT Id,Unit__r.Name,Nationality__c,Status__c,Opportunity__r.Name,DLD_Amount__c ,Unit__r.No_of_Bedroom__c,
                Unit__r.Super_Builtup_Area_Sq_Mtr__c,Booking_Date__c,Agreement_Value__c,SPA_Executed__c,Signed_Status__c,
                Paid_Percentage__c,Pre_registration__c,Current_Status__c,Tower_Name__c,
                Total_DLD_Amt_Paid__c,Name,
                Channel_Partner__r.Name
                FROM PropStrength__Application_Booking__c 
                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                    PropStrength__Booking_Through__c = 'Broker' AND 
                    Status__c != 'Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId 
                                       OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND 
                (unit__r.Unit_Status__c IN ('Blocked','Cancelled') or Current_Status__c IN ('Audit Accepted','Signed by Client')) 
                order by Booking_Date__c DESC];*/
    }
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingMonthlyData(Integer fromMonthSelect, Integer ToMonthSelect) {
        system.debug('monthSelect'+ToMonthSelect);
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, 
                CALENDAR_MONTH(PropStrength__Booking_Date__c) month 
                FROM PropStrength__Application_Booking__c 
                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                    PropStrength__Booking_Through__c = 'Broker' AND 
                    PropStrength__Booking_Date__c != null AND 
                    PropStrength__Active__c = true AND 
                    PropStrength__Booking_Cancelled__c = false AND 
                    CALENDAR_Month(PropStrength__Booking_Date__c) >=: fromMonthSelect AND 
                    CALENDAR_Month(PropStrength__Booking_Date__c) <=: ToMonthSelect AND 
                    CALENDAR_YEAR(PropStrength__Booking_Date__c) = 2024 AND 
                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c) 
                    ORDER BY CALENDAR_MONTH(PropStrength__Booking_Date__c)];
    }
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsMonthlyData(Integer fromMonthSelect, Integer ToMonthSelect) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, 
                    CALENDAR_MONTH(CreatedDate) month 
                    FROM Customer_Registration__c 
                    WHERE Broker_Contact__c =: loggedInUserContactId AND 
                    RecordType.Name = 'Site Visit' AND 
                    CALENDAR_Month(CreatedDate) >=: fromMonthSelect AND 
                    CALENDAR_YEAR(CreatedDate) = 2024 
                    GROUP BY CALENDAR_MONTH(CreatedDate) 
                    ORDER BY CALENDAR_MONTH(CreatedDate)];
    }
    @AuraEnabled
    public static String getBookingFormUrl(String recordId, String fileTitle) {
        String file_Title = '%Booking Form%';
        List<ContentDistribution> contentDocList = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                                        ContentDownloadUrl 
                                                        FROM ContentDistribution 
                                                        WHERE RelatedRecordId != null AND 
                                                            RelatedRecordId =: recordId AND 
                                                            ContentVersion.Title LIKE: file_Title 
                                                            ORDER BY CreatedDate DESC LIMIT 1];
        if(contentDocList.size() > 0) {
            //return URL.getOrgDomainURL().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocList[0].ContentDocumentId;
            return contentDocList[0].ContentDownloadUrl;
        } else {
            return '';
        }
    }
    @AuraEnabled
    public static String getBookingFormSPAUrl(String recordId) {
        String fileTitle = 'SPA%';
        List<PropStrength__Transaction_Requests__c> transactionList = new List<PropStrength__Transaction_Requests__c>();
        List<ContentDistribution> contentDocList = new List<ContentDistribution>();
        if(!String.isBlank(recordId)) {
            transactionList = [SELECT Id FROM PropStrength__Transaction_Requests__c 
                                WHERE PropStrength__Application_Booking__c =: recordId AND 
                                    PropStrength__Status__c = 'SPA Executed' AND 
                                    RecordType.Name = 'SPA Process' 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        }
        System.debug('===> transactionList ' + transactionList);
        if(!transactionList.isEmpty()) {
            contentDocList = [SELECT Id, ContentDocumentId, ContentVersion.Title, 
                                ContentDownloadUrl 
                                FROM ContentDistribution 
                                WHERE RelatedRecordId != null AND 
                                    RelatedRecordId =: transactionList[0].Id AND 
                                    ContentVersion.Title LIKE: fileTitle 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        }
        System.debug('===> contentDocList ' + contentDocList);
        if(contentDocList.size() > 0) {
            //return URL.getOrgDomainURL().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocList[0].ContentDocumentId;
            return contentDocList[0].ContentDownloadUrl;
        } else {
            return '';
        }
    }
    @AuraEnabled 
    public static Map<string,integer> getBookingCount(List<String> types, String frequency, List<integer> years, List<integer> months, integer selectedYear) {
        System.debug('===> types ' + types);
        System.debug('===> frequency ' + frequency);
        System.debug('===> years ' + years);
        System.debug('===> months ' + months);
        System.debug('===> selectedYear ' + selectedYear);
        Integer count = 0;
        Id loggedInUserContactId = getLoggedInUserContactId();
        Map<string,integer> response = new Map<string,integer>();
        if(frequency == 'month') {
            Map<integer,string> monthNames = new Map<integer,string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
            for(integer yr : years) {
                for(integer mo : months) {
                    response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
                }
            }
            System.debug('===> response ' + response);
            if(types != null && !types.isEmpty()) {
                if(types.contains('Villas') && types.contains('Apartment') && types.contains('Others')) {
                    for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        Integer mon = (integer)agg.get('month');
                        System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                        if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                            response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                        }
                    }
                } else if((types.contains('Villas') || types.contains('Apartment')) && !types.contains('Others')) {
                    for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        Integer mon = (integer)agg.get('month');
                        System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                        if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                            response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && types.contains('Apartment') && !types.contains('Villas')) {
                    for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        Integer mon = (integer)agg.get('month');
                        System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                        if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                            response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        Integer mon = (integer)agg.get('month');
                        System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                        if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                            response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && !types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        Integer mon = (integer)agg.get('month');
                        System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                        if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                            response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                        }
                    }
                }
                /*for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                            CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months 
                                                GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                    Integer mon = (integer)agg.get('month');
                    System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                    if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                        response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                    }
                }*/
            } else {
                for(AggregateResult agg : [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(PropStrength__Booking_Date__c) month,
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) year
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c), CALENDAR_YEAR(PropStrength__Booking_Date__c) 
                                                    ORDER BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                    Integer mon = (integer)agg.get('month');
                    System.debug('===> agg ' + monthNames.get(mon) + '-' + string.valueOf(agg.get('year')));
                    if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))) {
                        response.put(monthNames.get(mon) + '-' + string.valueOf(agg.get('year')), (integer)agg.get('recordCount'));
                    }
                }
            }
        } else if(frequency == 'quarter') {
            response.put('Q1',0);
            response.put('Q2',0);
            response.put('Q3',0);
            response.put('Q4',0);
            if(types != null && !types.isEmpty()) {

                if(types.contains('Villas') && types.contains('Apartment') && types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                        integer qua = (integer)agg.get('quarter');
                        if(qua == 1) {
                            response.put('Q1',(integer)agg.get('recordCount'));
                        } else if(qua == 2) {
                            response.put('Q2',(integer)agg.get('recordCount'));
                        } else if(qua == 3) {
                            response.put('Q3',(integer)agg.get('recordCount'));
                        } else if(qua == 4) {
                            response.put('Q4',(integer)agg.get('recordCount'));
                        }
                    }
                } else if((types.contains('Villas') || types.contains('Apartment')) && !types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                        integer qua = (integer)agg.get('quarter');
                        if(qua == 1) {
                            response.put('Q1',(integer)agg.get('recordCount'));
                        } else if(qua == 2) {
                            response.put('Q2',(integer)agg.get('recordCount'));
                        } else if(qua == 3) {
                            response.put('Q3',(integer)agg.get('recordCount'));
                        } else if(qua == 4) {
                            response.put('Q4',(integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && types.contains('Apartment') && !types.contains('Villas')) {
                    for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                        integer qua = (integer)agg.get('quarter');
                        if(qua == 1) {
                            response.put('Q1',(integer)agg.get('recordCount'));
                        } else if(qua == 2) {
                            response.put('Q2',(integer)agg.get('recordCount'));
                        } else if(qua == 3) {
                            response.put('Q3',(integer)agg.get('recordCount'));
                        } else if(qua == 4) {
                            response.put('Q4',(integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                        integer qua = (integer)agg.get('quarter');
                        if(qua == 1) {
                            response.put('Q1',(integer)agg.get('recordCount'));
                        } else if(qua == 2) {
                            response.put('Q2',(integer)agg.get('recordCount'));
                        } else if(qua == 3) {
                            response.put('Q3',(integer)agg.get('recordCount'));
                        } else if(qua == 4) {
                            response.put('Q4',(integer)agg.get('recordCount'));
                        }
                    }
                } else if(types.contains('Others') && !types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                        integer qua = (integer)agg.get('quarter');
                        if(qua == 1) {
                            response.put('Q1',(integer)agg.get('recordCount'));
                        } else if(qua == 2) {
                            response.put('Q2',(integer)agg.get('recordCount'));
                        } else if(qua == 3) {
                            response.put('Q3',(integer)agg.get('recordCount'));
                        } else if(qua == 4) {
                            response.put('Q4',(integer)agg.get('recordCount'));
                        }
                    }
                }

                /*for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear 
                                                    GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                    integer qua = (integer)agg.get('quarter');
                    if(qua == 1) {
                        response.put('Jan-Mar',(integer)agg.get('recordCount'));
                    } else if(qua == 2) {
                        response.put('Apr-Jun',(integer)agg.get('recordCount'));
                    } else if(qua == 3) {
                        response.put('Jul-Sep',(integer)agg.get('recordCount'));
                    } else if(qua == 4) {
                        response.put('Oct-Dec',(integer)agg.get('recordCount'));
                    }
                }*/
            } else {
                for(AggregateResult agg : [SELECT CALENDAR_QUARTER(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount 
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_QUARTER(PropStrength__Booking_Date__c)]) {
                    integer qua = (integer)agg.get('quarter');
                    if(qua == 1) {
                        response.put('Q1',(integer)agg.get('recordCount'));
                    } else if(qua == 2) {
                        response.put('Q2',(integer)agg.get('recordCount'));
                    } else if(qua == 3) {
                        response.put('Q3',(integer)agg.get('recordCount'));
                    } else if(qua == 4) {
                        response.put('Q4',(integer)agg.get('recordCount'));
                    }
                }
            }
        } else if(frequency == 'biyear') {
            Integer monthOfInterest = Date.today().month();
            integer mon = 0;
            integer count1 = 0;
            if(types != null && !types.isEmpty()) {
                if(types.contains('Villas') && types.contains('Apartment') && types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count1 = count1 + cou;
                    }
                } else if((types.contains('Villas') || types.contains('Apartment')) && !types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count1 = count1 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Apartment') && !types.contains('Villas')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count1 = count1 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count1 = count1 + cou;
                    }
                } else if(types.contains('Others') && !types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count1 = count1 + cou;
                    }
                }
                /*for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count1 = count1 + cou;
                }*/
            } else {
                for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) <= 6 AND
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) = :selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count1 = count1 + cou;
                }
            }
            response.put('B1',count1);
            integer count2 = 0;
            if(types != null && !types.isEmpty()) {
                if(types.contains('Villas') && types.contains('Apartment') && types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if((types.contains('Villas') || types.contains('Apartment')) && !types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Apartment') && !types.contains('Villas')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && !types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                    FROM PropStrength__Application_Booking__c 
                                                    WHERE PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                                        PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                                        PropStrength__Booking_Date__c != null AND 
                                                        PropStrength__Active__c = true AND 
                                                        PropStrength__Booking_Cancelled__c = false AND 
                                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                        GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                }
                /*for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count2 = count2 + cou;
                }*/
            } else {
                for(AggregateResult agg : [SELECT CALENDAR_MONTH(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_MONTH(PropStrength__Booking_Date__c) > 6 AND
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_MONTH(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count2 = count2 + cou;
                }
            }
            response.put('B2',count2);
        } else if(frequency == 'year') {
            integer count2 = 0;
            if(types != null && !types.isEmpty()) {
                if(types.contains('Villas') && types.contains('Apartment') && types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if((types.contains('Villas') || types.contains('Apartment')) && !types.contains('Others')) {
                    for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Apartment') && !types.contains('Villas')) {
                    for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                } else if(types.contains('Others') && !types.contains('Villas') && !types.contains('Apartment')) {
                    for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                                FROM PropStrength__Application_Booking__c 
                                                WHERE PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                                    PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                                    PropStrength__Booking_Date__c != null AND 
                                                    PropStrength__Active__c = true AND 
                                                    PropStrength__Booking_Cancelled__c = false AND 
                                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                    GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                        integer cou = (integer)agg.get('recordCount');
                        count2 = count2 + cou;
                    }
                }
                /*for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Property__r.RecordType.Name IN: types AND 
                                                PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear 
                                                GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count2 = count2 + cou;
                }*/
            } else {
                for(AggregateResult agg : [SELECT CALENDAR_YEAR(PropStrength__Booking_Date__c) quarter, COUNT(Id) recordCount
                                            FROM PropStrength__Application_Booking__c 
                                            WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                                PropStrength__Booking_Through__c = 'Broker' AND 
                                                PropStrength__Booking_Date__c != null AND 
                                                PropStrength__Active__c = true AND 
                                                PropStrength__Booking_Cancelled__c = false AND 
                                                CALENDAR_YEAR(PropStrength__Booking_Date__c) =: selectedYear AND 
                                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false 
                                                GROUP BY CALENDAR_YEAR(PropStrength__Booking_Date__c)]) {
                    integer cou = (integer)agg.get('recordCount');
                    count2 = count2 + cou;
                }
            }
            response.put(string.valueof(selectedYear),count2);
        }
        return response;
    }
    @AuraEnabled
    public static Decimal getBookingsInSelectedMonth(List<integer> years, List<Integer> months, List<String> TypeValue) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = new List<AggregateResult>();
        if(TypeValue.size() > 0 && months.size() > 0) {
            if(TypeValue.contains(' ') && TypeValue.contains('Apartment') && TypeValue.contains('Others')) {
                results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                             FROM PropStrength__Application_Booking__c 
                             WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if((TypeValue.contains('Villas') || TypeValue.contains('Apartment')) && !TypeValue.contains('Others')) {
                results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                             FROM PropStrength__Application_Booking__c 
                             WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Property__r.RecordType.Name IN: TypeValue AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && !TypeValue.contains('Apartment') && !TypeValue.contains('Villas')) {
                results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                             FROM PropStrength__Application_Booking__c 
                             WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && TypeValue.contains('Apartment') && !TypeValue.contains('Villas')) {
                results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                             FROM PropStrength__Application_Booking__c 
                             WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && TypeValue.contains('Villas') && !TypeValue.contains('Apartment')) {
                results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                             FROM PropStrength__Application_Booking__c 
                             WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                PropStrength__Booking_Through__c = 'Broker' AND 
                                PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                PropStrength__Booking_Date__c != null AND 
                                PropStrength__Active__c = true AND 
                                PropStrength__Booking_Cancelled__c = false AND 
                                CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            }
        } else if(TypeValue.size() == 0 && months.size() > 0) {
            results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        CALENDAR_MONTH(PropStrength__Booking_Date__c) IN: months AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        } else if(TypeValue.size() > 0) {
            if(TypeValue.contains('Villas') && TypeValue.contains('Apartment') && TypeValue.contains('Others')) {
                results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if((TypeValue.contains('Villas') || TypeValue.contains('Apartment')) && !TypeValue.contains('Others')) {
                results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Property__r.RecordType.Name IN: TypeValue AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && !TypeValue.contains('Apartment') && !TypeValue.contains('Villas')) {
                results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Property__r.RecordType.Name NOT IN ('Apartment','Villas') AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && TypeValue.contains('Apartment') && !TypeValue.contains('Villas')) {
                results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Property__r.RecordType.Name != 'Villas' AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            } else if(TypeValue.contains('Others') && TypeValue.contains('Villas') && !TypeValue.contains('Apartment')) {
                results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                     FROM PropStrength__Application_Booking__c 
                                     WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                        PropStrength__Booking_Through__c = 'Broker' AND 
                                        PropStrength__Property__r.RecordType.Name != 'Apartment' AND 
                                        PropStrength__Booking_Date__c != null AND 
                                        PropStrength__Active__c = true AND 
                                        PropStrength__Booking_Cancelled__c = false AND 
                                        CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                        PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                        PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
            }
            //Unit__c IN (SELECT Id FROM Unit__c WHERE Tower__r.Tower_Type__c in :TypeValue)
        } else {
            results = results = [SELECT SUM(PropStrength__Total_Sales_Consideration__c) totalPriceSum
                                 FROM PropStrength__Application_Booking__c 
                                 WHERE PropStrength__Broker_Contact__c =: loggedInUserContactId AND 
                                    PropStrength__Booking_Through__c = 'Broker' AND 
                                    PropStrength__Booking_Date__c != null AND 
                                    PropStrength__Active__c = true AND 
                                    PropStrength__Booking_Cancelled__c = false AND 
                                    CALENDAR_YEAR(PropStrength__Booking_Date__c) IN: years AND 
                                    PropStrength__Project__r.Hide_From_3rd_Party__c = false AND 
                                    PropStrength__Project__r.Master_Project__r.Hide_From_3rd_Party__c = false];
        }
        if(!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
}