public without sharing class SitevisitChartController {
    
    // String excludedProjectLabel = System.label.Excluded_Project;

    // // Split the label value by commas into a List<String>
    // List<String> excludeProjectList = new List<String>();
    
    // {
    //     if (String.isNotBlank(excludedProjectLabel)) {
    //         excludeProjectList = excludedProjectLabel.split(',');
    //     }  
    // }  

    @AuraEnabled(cacheable=true)
    public static List<Customer_Registration__c> SiteVisits(){
        // Get the ContactId of the logged-in user
        Id loggedInUserContactId = getLoggedInUserContactId();
        system.debug('loggedInUserContactId'+loggedInUserContactId);
        // Use the loggedInUserContactId in the query
        return [SELECT Name, Booking__c, Visit_Month__c 
                FROM Customer_Registration__c 
                WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId)];
    }
    @AuraEnabled(cacheable=true)
    public static TemplateInfo fetchEmailTemplateInfo(String templateName) {
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        return new TemplateInfo(template.Subject, template.Body);
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getBookingAppartmentsCount() {
        Integer count = 0;
        Integer currentYear = Date.today().year();
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = [SELECT COUNT(Id) totalBookings
                                         FROM Booking__c
                                         WHERE Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c = 'Apartments') and  CALENDAR_YEAR(Booking_Date__c) =:currentYear and  Status__c !='Cancelled' and (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND Project__r.name !=:System.label.Excluded_Project];
        if (results.size() > 0) {
            count = Integer.valueOf(results[0].get('totalBookings'));
        }
        return count;
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getBookingVillasCount() {
        Integer count = 0;
        Id loggedInUserContactId = getLoggedInUserContactId();
         Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT COUNT(Id) totalBookings
                                         FROM Booking__c
                                         WHERE Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c = 'Villas') AND  Status__c !='Cancelled' AND CALENDAR_YEAR(Booking_Date__c) =:currentYear
                                         and (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND Project__r.name !=:System.label.Excluded_Project];
        if (results.size() > 0) {
            count = Integer.valueOf(results[0].get('totalBookings'));
        }
        return count;
    }
    //get booking data for one month   chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingData() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Booking_Date__c) month FROM Booking__c where (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) and CALENDAR_YEAR(Booking_Date__c) = 2024 and Status__c !='Cancelled' AND Project__r.name !=:System.label.Excluded_Project GROUP BY CALENDAR_MONTH(Booking_Date__c) order by CALENDAR_MONTH(Booking_Date__c) ];
    }
    //get sitevisits data for one month chart
    @AuraEnabled(cacheable=true)
    public static  map<string,integer> getSitevisits1(list<Integer> years,list<Integer> months){
        map<integer,string> monthNames = new map<integer,string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
            map<string,integer> response = new map<string,integer>();
        /*List<Integer> integerList = new List<Integer>();
        List<Integer> integerMonList = new List<Integer>();
        integerMonList.add(months);
        integerList.add(years);*/
        for(integer yr : years){
            for(integer mo : months){
                response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
            }
        }
        system.debug('response for site vist chart : '+response);
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> res = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month,CALENDAR_YEAR(Date__c) year FROM Customer_Registration__c where (Channel_Partner__r.Contact__c =:loggedInUserContactId or Sobha_Connect__r.Contact__c =:loggedInUserContactId) and CALENDAR_YEAR(Date__c) =:years and CALENDAR_MONTH(Date__c) in :months GROUP BY CALENDAR_MONTH(Date__c),CALENDAR_YEAR(Date__c) order by CALENDAR_YEAR(Date__c)];
        system.debug(res);
        for(AggregateResult agg : res){
            system.debug(agg);
            system.debug(agg.get('recordCount'));
            integer mon = (integer)agg.get('month');
            system.debug(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')));
            system.debug(agg);
            if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))){
                response.put(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')),(integer)agg.get('recordCount'));
            }
        }
        system.debug(response);
        return response; 
    }
    //Aravind Code
    @AuraEnabled(cacheable=true)
    public static  List<AggregateResult> getSitevisits(Integer years,Integer months){
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> results = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month,CALENDAR_YEAR(Date__c) year FROM Customer_Registration__c where (Channel_Partner__r.Contact__c =:loggedInUserContactId or Sobha_Connect__r.Contact__c =:loggedInUserContactId) and  CALENDAR_YEAR(Date__c) =:years  GROUP BY CALENDAR_MONTH(Date__c),CALENDAR_YEAR(Date__c) order by CALENDAR_YEAR(Date__c)];
        return results;
    }
    
    
    // get sales Booking data for 1 month
    @AuraEnabled(cacheable=true)
    public static  map<string,integer> getSalesBookings(list<integer> years,list<integer> months){
        map<integer,string> monthNames = new map<integer,string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
            map<string,integer> response = new map<string,integer>();
        for(integer yr : years){
            for(integer mo : months){
                response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
            }
        }
        system.debug(response);
        Id loggedInUserContactId = getLoggedInUserContactId();
        List<AggregateResult> res = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Booking_Date__c) month,CALENDAR_YEAR(Booking_Date__c) year FROM Booking__c where 
                                     ((Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId))
                                     AND Status__c !='Cancelled' AND CALENDAR_YEAR(Booking_Date__c) in :years and CALENDAR_MONTH(Booking_Date__c) in :months AND Project__r.name !=:System.label.Excluded_Project GROUP BY CALENDAR_MONTH(Booking_Date__c),CALENDAR_YEAR(Booking_Date__c) order by CALENDAR_YEAR(Booking_Date__c)];
        system.debug(res);
        for(AggregateResult agg : res){
            system.debug('aggregation 1 : '+agg);
            system.debug('record count : '+agg.get('recordCount'));
            integer mon = (integer)agg.get('month');
            system.debug('aggregation 2 : '+monthNames.get(mon)+'-'+string.valueOf(agg.get('year')));
            system.debug('aggreagtion 3 : '+agg);
            if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))){
                response.put(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')),(integer)agg.get('recordCount'));
            }
        }
        system.debug('response end : '+response);
        return response; 
    }
    // get Bookings data for Quartely  chart 
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataQuaterly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT CALENDAR_QUARTER(CreatedDate), COUNT(Id) recordCount
                FROM Booking__c WHERE ((Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId))
                and Status__c !='Cancelled' AND CALENDAR_YEAR(Booking_Date__c) = :selectedYear AND Project__r.name !=:System.label.Excluded_Project
                GROUP BY CALENDAR_QUARTER(CreatedDate)];
    }
    // get siteVisit data for Quartely  chart 
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsQuaterly(integer selectedYear){
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT CALENDAR_QUARTER(CreatedDate), COUNT(Id) recordCount FROM Customer_Registration__c where ((Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId)) and CALENDAR_YEAR(CreatedDate) = :selectedYear GROUP BY CALENDAR_QUARTER(CreatedDate)]; 
    }
    //get booking data for Bi-Yearly  chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataHalfYearly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [ SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Booking_Date__c) month FROM Booking__c where
                (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) 
                AND  Status__c !='Cancelled' AND CALENDAR_YEAR(Booking_Date__c) = :selectedYear AND Project__r.name !=:System.label.Excluded_Project  GROUP BY CALENDAR_MONTH(Booking_Date__c)];
        
    }
    //get site visits for Bi-yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsHalfYearly(integer selectedYear){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer monthOfInterest = Date.today().month();
        List<AggregateResult> results = new   List<AggregateResult>() ;
        
        results = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month 
                    FROM Customer_Registration__c 
                    WHERE (Channel_Partner__r.Contact__c =:loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) 
                    and CALENDAR_YEAR(Date__c) =:selectedYear
                    GROUP BY CALENDAR_MONTH(Date__c) 
                    ORDER BY CALENDAR_MONTH(Date__c)];
        
      /*  if (monthOfInterest >= 1 && monthOfInterest <= 6) {
            // Months 1 to 6 (January to June) case
            return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month 
                    FROM Customer_Registration__c 
                    WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) 
                    AND CALENDAR_MONTH(Date__c) IN (1,2,3,4,5,6) and CALENDAR_YEAR(Date__c) = :selectedYear
                    GROUP BY CALENDAR_MONTH(Date__c) 
                    ORDER BY CALENDAR_MONTH(Date__c)];
            
            
        } else {
            // Months 7 to 12 (July to December) case
            return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month 
                    FROM Customer_Registration__c 
                    WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) 
                    AND CALENDAR_MONTH(Date__c) IN (7,8,9,10,11,12) and CALENDAR_YEAR(Date__c) = :selectedYear
                    GROUP BY CALENDAR_MONTH(Date__c) 
                    ORDER BY CALENDAR_MONTH(Date__c)];
            
            
        }   */   
        return results;
    }
    //get Booking chart for yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingDataYearly(integer selectedYear) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_YEAR(Booking_Date__c) month FROM Booking__c where (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND  Status__c !='Cancelled' AND CALENDAR_YEAR(Booking_Date__c) = :selectedYear AND Project__r.name !=:System.label.Excluded_Project GROUP BY CALENDAR_YEAR(Booking_Date__c) order by CALENDAR_YEAR(Booking_Date__c) ];
    }
    //get Sitevisit data for yearly chart
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsYearly(integer selectedYear){
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_YEAR(Date__c) month FROM Customer_Registration__c where (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) and CALENDAR_YEAR(Date__c) = :selectedYear GROUP BY CALENDAR_YEAR(Date__c) order by CALENDAR_YEAR(Date__c)]; 
    }
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<Events__c> getUpcomingAllEvents() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT Name, Date_Of_Event__c, City_Country__c
                FROM Events__c 
                WHERE  (recordType.name IN ('Open Houses','Business Trip','Road Shows','Video Shoot') OR Type_Of_Road_Show__c = 'Channel Partner Roadshow') and Date_Of_Event__c > :Date.today() and (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) and Event_Approved_status__c IN ('Pending With Khodr El Masri/Invoice submitted by Khodr El Masri','Approved','Invoice Under Review','Venue Cost Pending Approval - CMO','Venue Cost Approved')
                ORDER BY Date_Of_Event__c 
                LIMIT 5];
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUpcomingEvents(String recordType) {
        Id loggedInUserContactId = getLoggedInUserContactId();
        
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
            // Adjust as per your record type name
            recordTypeName = 'Video Shoots';
            queryStr = ' (RecordType.Name = \'Video Shoot\' ) AND ';
        }else if(recordType == 'All'){
            recordTypeName = 'All';
        }
        
        DateTime todaysDate = System.today();
String todaysDateStr = todaysDate.format('yyyy-MM-dd');
System.debug('todaysDateStr '+todaysDateStr);
        
        String query = 'Select Name, Date_Of_Event__c, City_Country__c FROM Events__c  WHERE '+queryStr+' Date_Of_Event__c > '+todaysDateStr+' AND (Channel_Partner__r.Contact__c =:loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND Event_Approved_status__c IN (\'Pending With Khodr El Masri/Invoice submitted by Khodr El Masri\',\'Approved\',\'Invoice Under Review\',\'Venue Cost Pending Approval - CMO\',\'Venue Cost Approved\') ORDER BY Date_Of_Event__c LIMIT 5';
       System.debug('query is : '+query);
        
       List<Events__c> events  = Database.query(query);
        
      /*  List<Events__c> events = [SELECT Name, Date_Of_Event__c, City_Country__c
                                  FROM Events__c 
                                  WHERE   Date_Of_Event__c > :Date.today() 
                                  AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId)
                                  ORDER BY Date_Of_Event__c 
                                  LIMIT 5]; */
        
        Integer recordCount = events.size();
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('events', events);
        result.put('recordCount', recordCount);
        
        return result;
    }
    //@AuraEnabled(cacheable=true)
    //public static List<Events__c> getUpcomingEvents(String recordType) {
    //Id loggedInUserContactId = getLoggedInUserContactId();
    
    //String recordTypeName = '';
    //if(recordType == 'Openhouse') {
    //  recordTypeName = 'Open Houses';
    //} else if(recordType == 'Roadshows') {
    //  recordTypeName = 'Road Shows';
    //} else if(recordType == 'BusinessTrips') {
    //  recordTypeName = 'Business Trip';
    //} else if(recordType == 'Videoshoot') {
    // Adjust as per your record type name
    //   recordTypeName = 'Video Shoots';
    // }
    
    //return [SELECT Name, Date_Of_Event__c, City_Country__c
    // FROM Events__c 
    //WHERE  (RecordType.Name = :recordTypeName OR Type_Of_Road_Show__c = 'Channel Partner Roadshow') 
    //    AND Date_Of_Event__c > :Date.today() 
    //          AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId)
    //        ORDER BY Date_Of_Event__c 
    //          LIMIT 5];
    //} 
    //get last sixmonths sitevisits count
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountLastSixMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        Integer monthOfInterest = Date.today().month();
        List<AggregateResult> results = new   List<AggregateResult>() ;
        
        if (monthOfInterest >= 1 && monthOfInterest <= 6) {
            // Months 1 to 6 (January to June) case
            results = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month 
                       FROM Customer_Registration__c 
                       WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) AND CALENDAR_YEAR(Date__c) =: currentYear
                       AND CALENDAR_MONTH(Date__c) IN (1,2,3,4,5,6) 
                       GROUP BY CALENDAR_MONTH(Date__c) 
                       ORDER BY CALENDAR_MONTH(Date__c)];
            
            
        } else {
            // Months 7 to 12 (July to December) case
            results = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month 
                       FROM Customer_Registration__c 
                       WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) AND CALENDAR_YEAR(Date__c) =: currentYear
                       AND CALENDAR_MONTH(Date__c) IN (7,8,9,10,11,12) 
                       GROUP BY CALENDAR_MONTH(Date__c) 
                       ORDER BY CALENDAR_MONTH(Date__c)];
            
            
        }
        
        
        Integer totalCount = 0;
        // Sum up the record counts from each AggregateResult
        for (AggregateResult result : results) {
            Integer count = (Integer)result.get('recordCount');
            totalCount += count != null ? count : 0;
        }
        
        return totalCount;
    }
    //get last three months sitevisits count
    
    @AuraEnabled(cacheable=true)
public static Integer getSitevisitsCountLastThreeMonths() {
    Id loggedInUserContactId = getLoggedInUserContactId();
    Integer currentYear = Date.today().year();
    Integer currentMonth = Date.today().month();
    Integer startMonth;
    Integer endMonth;

    // Determine the current quarter
    if (currentMonth >= 1 && currentMonth <= 3) {
        startMonth = 1; // January
        endMonth = 3;   // March
    } else if (currentMonth >= 4 && currentMonth <= 6) {
        startMonth = 4; // April
        endMonth = 6;   // June
    } else if (currentMonth >= 7 && currentMonth <= 9) {
        startMonth = 7; // July
        endMonth = 9;   // September
    } else if (currentMonth >= 10 && currentMonth <= 12) {
        startMonth = 10; // October
        endMonth = 12;   // December
    }

    // SOQL query to get records for the current quarter
    List<AggregateResult> results = [
        SELECT COUNT(Id) recordCount 
        FROM Customer_Registration__c 
        WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId 
            OR Sobha_Connect__r.Contact__c = :loggedInUserContactId) 
        AND CALENDAR_YEAR(Date__c) = :currentYear 
        AND CALENDAR_MONTH(Date__c) >= :startMonth 
        AND CALENDAR_MONTH(Date__c) <= :endMonth
    ];

    if (!results.isEmpty()) {
        return (Integer)results[0].get('recordCount');
    } else { 
        return 0; // Return 0 if no records found for the current quarter
    }
}

    // get the sitevisist count of current month 
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountInCurrentMonth() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        System.debug('currentYear'+currentYear);
        Integer currentMonth = Date.today().month();
        System.debug('currentMonth'+currentMonth);
        
        // Execute SOQL query to get records for the current month of the current year
        List<AggregateResult> results = [
            SELECT COUNT(Id) recordCount 
            FROM Customer_Registration__c 
            WHERE ((Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId))
                   AND CALENDAR_YEAR(Date__c) = :currentYear
            AND CALENDAR_MONTH(Date__c) = :currentMonth
        ];
        
        if (!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0; // Return 0 if no records found for the current month 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getSitevisitsCountInCurrentYear(){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT COUNT(Id) recordCount 
                                         FROM Customer_Registration__c 
                                         WHERE (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND CALENDAR_YEAR(Date__c) = :currentYear];
        if (!results.isEmpty()) {
            return (Integer)results[0].get('recordCount');
        } else { 
            return 0; // Return 0 if no records found for the current year
        }
    }
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInCurrentYear(){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                                         FROM Booking__c
                                         WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                                         CALENDAR_YEAR(CreatedDate) = :currentYear AND Project__r.name !=:System.label.Excluded_Project];
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInLastSixMonths() {
        Id loggedInUserContactId = getLoggedInUserContactId();
        Date today = Date.today();
        Integer currentMonth = today.month();
        Date sixMonthStartDate;
        Date sixMonthEndDate;
    
        // Determine the start and end dates for the last six months based on current date
        if (currentMonth >= 1 && currentMonth <= 6) {
            // First half of the year
            sixMonthStartDate = Date.newInstance(today.year(), 1, 1); // Six months ago from start of current year
            sixMonthEndDate = Date.newInstance(today.year(), 6, 30); // End of last six months
        } else {
            // Second half of the year
            sixMonthStartDate = Date.newInstance(today.year(), 7, 1); // Start of the current year
            sixMonthEndDate = today; // Current date
        }
    
        List<AggregateResult> results = [
            SELECT SUM(Total_Purchase_Price__c) totalPriceSum
            FROM Booking__c
            WHERE Status__c != 'Cancelled'
                AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId)
                AND CreatedDate >= :sixMonthStartDate
                AND CreatedDate <= :sixMonthEndDate
                AND Project__r.name !=:System.label.Excluded_Project
        ];
    
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else {
            return 0;
        }
    }
    
    @AuraEnabled(cacheable=true)
public static Decimal getBookingsTotalInLastThreeMonths() {
    Id loggedInUserContactId = getLoggedInUserContactId();
    Date today = Date.today();
    Integer currentMonth = today.month();
    Date quarterStartDate;
    Date quarterEndDate;

    // Determine the start and end dates of the current quarter
    if (currentMonth >= 1 && currentMonth <= 3) {
        quarterStartDate = Date.newInstance(today.year(), 1, 1);
        quarterEndDate = Date.newInstance(today.year(), 3, 31);
    } else if (currentMonth >= 4 && currentMonth <= 6) {
        quarterStartDate = Date.newInstance(today.year(), 4, 1);
        quarterEndDate = Date.newInstance(today.year(), 6, 30);
    } else if (currentMonth >= 7 && currentMonth <= 9) {
        quarterStartDate = Date.newInstance(today.year(), 7, 1);
        quarterEndDate = Date.newInstance(today.year(), 9, 30);
    } else {
        quarterStartDate = Date.newInstance(today.year(), 10, 1);
        quarterEndDate = Date.newInstance(today.year(), 12, 31);
    }

    List<AggregateResult> results = [
        SELECT SUM(Total_Purchase_Price__c) totalPriceSum
        FROM Booking__c
        WHERE Status__c != 'Cancelled'
            AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c = :loggedInUserContactId)
            AND CreatedDate >= :quarterStartDate
            AND CreatedDate <= :quarterEndDate
            AND Project__r.name !=:System.label.Excluded_Project
    ];

    if (!results.isEmpty()) {
        return (Decimal)results[0].get('totalPriceSum');
    } else {
        return 0;
    }
}

    
    @AuraEnabled(cacheable=true)
    public static Decimal getBookingsTotalInCurrentMonth(){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        Date startDate = Date.newInstance(currentYear, currentMonth, 1);
        Date endDate = startDate.addMonths(1).addDays(-1);
        
        
        List<AggregateResult> results = [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                                         FROM Booking__c
                                         WHERE  Status__c !='Cancelled' And((Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                                                (CreatedDate >= :startDate AND CreatedDate <= :endDate)) AND Project__r.name !=:System.label.Excluded_Project];
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
    
    
    
    
    
    // Method to get the ContactId of the logged-in user
    @AuraEnabled(cacheable=true)
    public static Id getLoggedInUserContactId() {
        List<User> userList = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (!userList.isEmpty()) {
            system.debug('userList[0].ContactId'+userList[0].ContactId);
            return userList[0].ContactId;
        } else {
            system.debug('NULLL');
            return null; // Handle the case where no user is found with the given Id
        }
    }
    
    public class TemplateInfo {
        @AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String Body { get; set; }
        
        public TemplateInfo(String subject, String body) {
            this.Subject = subject;
            this.Body = body;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getBookingDataDetails() {
        Integer currentYear = Date.today().year();
        Id loggedInUserContactId = getLoggedInUserContactId();
        system.debug('loggedInUserContactId'+loggedInUserContactId);
        return [SELECT Id,Project__r.name,Unit__r.Name,Nationality__c,Nationality_V2__c,Status__c,Opportunity__r.Name,DLD_Amount__c ,Unit__r.No_of_Bedroom__c,
                Unit__r.Super_Builtup_Area_Sq_Mtr__c,Booking_Date__c,Agreement_Value__c,SPA_Executed__c,Signed_Status__c,
                Paid_Percentage__c,Pre_registration__c,Current_Status__c,Tower_Name__c,
                Name,Sales_Managers__r.Name,Sales_Managers__r.FirstName,Sales_Managers__r.LastName, 
                Sales_Head__r.Name,Sales_Head__r.FirstName,Sales_Head__r.LastName,  
                Channel_Partner__r.Name,Signed_Date__c,DLD_Percentage__c,Unit__r.Chargeable_Area__c,SPA_Executed_Date__c,Primary_Applicant_Name__c,Channel_Partner_Contact_Person__c,
                Unit__r.Tower__r.Tower_Type__c
                FROM Booking__c where  CALENDAR_YEAR(CreatedDate) = :currentYear AND Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId 
                                       OR Sobha_Connect__r.Contact__c =:loggedInUserContactId)  AND Project__r.name !=:System.label.Excluded_Project
                order by Booking_Date__c DESC];
    }
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getBookingMonthlyData(Integer fromMonthSelect, Integer ToMonthSelect) {
        system.debug('monthSelect'+ToMonthSelect);
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Booking_Date__c) month FROM Booking__c where  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) and CALENDAR_Month(Booking_Date__c) >=: fromMonthSelect and CALENDAR_Month(Booking_Date__c) <=: ToMonthSelect and CALENDAR_YEAR(Booking_Date__c) = 2024 AND Project__r.name !=:System.label.Excluded_Project GROUP BY CALENDAR_MONTH(Booking_Date__c) order by CALENDAR_MONTH(Booking_Date__c) ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSitevisitsMonthlyData(Integer fromMonthSelect, Integer ToMonthSelect){
        Id loggedInUserContactId = getLoggedInUserContactId();
        return [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Date__c) month FROM Customer_Registration__c where (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) and CALENDAR_Month(Date__c) >=: fromMonthSelect and CALENDAR_YEAR(Date__c) = 2024 GROUP BY CALENDAR_MONTH(Date__c) order by CALENDAR_MONTH(Date__c) ]; 
    }

    @AuraEnabled
    public static string getBookingFormUrl(String recordId, String fileTitle){
        system.debug('recordId->'+recordId);
        system.debug('fileTitle->'+fileTitle);
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId
                                                    FROM ContentDocumentLink WHERE LinkedEntityId =:recordId AND ContentDocument.Title =:fileTitle order by SystemModstamp desc Limit 1];
        system.debug('contentDocList'+contentDocList);
        if(contentDocList.size() > 0){
            String FilterCriteria = 'BookingForm Downloaded: '+fileTitle;
            BrokerPortalSobhaProjectsController.createDataDownloadTracker('',FilterCriteria);
            return URL.getOrgDomainURL().toExternalForm()+'/sfc/servlet.shepherd/document/download/'+contentDocList[0].ContentDocumentId;
        }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static string getBookingFormSPAUrl(String recordId){
        String fileTitle = 'SPA%';
        List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersionId
                                                    FROM ContentDocumentLink WHERE LinkedEntityId =:recordId AND ContentDocument.Title LIKE:fileTitle order by SystemModstamp desc Limit 1];
        if(contentDocList.size() > 0){
            String FilterCriteria = 'SPA Downloaded: '+contentDocList[0].ContentDocument.Title;
            BrokerPortalSobhaProjectsController.createDataDownloadTracker('',FilterCriteria);
            return URL.getOrgDomainURL().toExternalForm()+'/sfc/servlet.shepherd/document/download/'+contentDocList[0].ContentDocumentId;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled 
    public static map<string,integer> getBookingCount(list<string> types, string frequency,list<integer> years,list<integer> months,integer selectedYear) {
        Integer count = 0;
        Id loggedInUserContactId = getLoggedInUserContactId();
        map<string,integer> response = new map<string,integer>();
        if(frequency == 'month'){
            map<integer,string> monthNames = new map<integer,string>{1=>'Jan',2=>'Feb',3=>'Mar',4=>'Apr',5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
                
                for(integer yr : years){
                    for(integer mo : months){
                        response.put(monthNames.get(mo)+'-'+String.valueof(yr),0);
                    }
                }
            system.debug(response);
            List<AggregateResult> res = [SELECT COUNT(Id) recordCount, CALENDAR_MONTH(Booking_Date__c) month,
                                         CALENDAR_YEAR(Booking_Date__c) year
                                         FROM Booking__c
                                         WHERE Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c in :types) and  Status__c !='Cancelled' and 
                                         (Channel_Partner__r.Contact__c = :loggedInUserContactId OR 
                                          Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND 
                                         CALENDAR_YEAR(Booking_Date__c) in :years and 
                                         CALENDAR_MONTH(Booking_Date__c) in :months AND Project__r.name !=:System.label.Excluded_Project
                                         GROUP BY CALENDAR_MONTH(Booking_Date__c),
                                         CALENDAR_YEAR(Booking_Date__c) order by CALENDAR_YEAR(Booking_Date__c)];
            
            system.debug(res);
            for(AggregateResult agg : res){
                system.debug(agg);
                system.debug(agg.get('recordCount'));
                integer mon = (integer)agg.get('month');
                system.debug(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')));
                system.debug(agg);
                if(response.containsKey(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')))){
                    response.put(monthNames.get(mon)+'-'+string.valueOf(agg.get('year')),(integer)agg.get('recordCount'));
                }
            }
        }else if(frequency == 'quarter'){
            response.put('Q1',0);
            response.put('Q2',0);
            response.put('Q3',0);
            response.put('Q4',0);
            List<AggregateResult> res = [ SELECT CALENDAR_QUARTER(Booking_Date__c) quarter, COUNT(Id) recordCount
                                         FROM Booking__c WHERE  Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c in :types) and  Status__c !='Cancelled' and
                                         (Channel_Partner__r.Contact__c = :loggedInUserContactId OR 
                                          Sobha_Connect__r.Contact__c =:loggedInUserContactId)  and
                                         CALENDAR_YEAR(Booking_Date__c) = :selectedYear
                                         AND Project__r.name !=:System.label.Excluded_Project
                                         GROUP BY CALENDAR_QUARTER(Booking_Date__c)];
            for(AggregateResult agg : res){
                system.debug(agg);
                system.debug(agg.get('recordCount'));
                integer qua = (integer)agg.get('quarter');
                system.debug(agg);
                if(qua == 1){
                    response.put('Q1',(integer)agg.get('recordCount'));
                }else if(qua == 2){
                    response.put('Q2',(integer)agg.get('recordCount'));
                }else if(qua == 3){
                    response.put('Q3',(integer)agg.get('recordCount'));
                }else if(qua == 4){
                    response.put('Q4',(integer)agg.get('recordCount'));
                }
            }
        }else if(frequency == 'biyear'){
            Integer monthOfInterest = Date.today().month();
            integer mon = 0;
            List<AggregateResult> res ;
            List<AggregateResult> res1 ;
            
            res = [ SELECT CALENDAR_MONTH(Booking_Date__c) quarter, COUNT(Id) recordCount
                   FROM Booking__c WHERE  Unit__c IN (
                       SELECT Id
                       FROM Unit__c
                       WHERE   Tower__r.Tower_Type__c in :types) and Status__c !='Cancelled' and 
                   CALENDAR_MONTH(Booking_Date__c) < = 6 AND
                   (Channel_Partner__r.Contact__c = :loggedInUserContactId OR 
                    Sobha_Connect__r.Contact__c =:loggedInUserContactId)  and
                   CALENDAR_YEAR(Booking_Date__c) = :selectedYear
                   AND Project__r.name !=:System.label.Excluded_Project
                   GROUP BY CALENDAR_MONTH(Booking_Date__c)];
            integer count1 = 0;
            for(AggregateResult agg : res){
                integer cou = (integer)agg.get('recordCount');
                count1 = count1 + cou;
            }
            response.put('B1',count1);
            res1 = [ SELECT CALENDAR_MONTH(Booking_Date__c) quarter, COUNT(Id) recordCount
                    FROM Booking__c WHERE  Unit__c IN (
                        SELECT Id
                        FROM Unit__c
                        WHERE   Tower__r.Tower_Type__c in :types)  AND Status__c !='Cancelled' and 
                    CALENDAR_MONTH(Booking_Date__c) > = 6 AND
                    (Channel_Partner__r.Contact__c = :loggedInUserContactId OR 
                     Sobha_Connect__r.Contact__c =:loggedInUserContactId)   and
                    CALENDAR_YEAR(Booking_Date__c) = :selectedYear
                    AND Project__r.name !=:System.label.Excluded_Project
                    GROUP BY CALENDAR_MONTH(Booking_Date__c)];
            integer count2 = 0;
            for(AggregateResult agg : res1){
                integer cou = (integer)agg.get('recordCount');
                count2 = count2 + cou;
            }
            response.put('B2',count2);
            
        }else if(frequency == 'year'){
            Integer yr = Date.today().year();
            List<AggregateResult> res = [ SELECT CALENDAR_YEAR(Booking_Date__c) quarter, COUNT(Id) recordCount
                                         FROM Booking__c WHERE  Unit__c IN (
                                             SELECT Id
                                             FROM Unit__c
                                             WHERE Tower__r.Tower_Type__c in :types) and Status__c !='Cancelled' and 
                                         (Channel_Partner__r.Contact__c = :loggedInUserContactId OR 
                                          Sobha_Connect__r.Contact__c =:loggedInUserContactId) and
                                         CALENDAR_YEAR(Booking_Date__c) = :selectedYear
                                         AND Project__r.name !=:System.label.Excluded_Project
                                         GROUP BY CALENDAR_YEAR(Booking_Date__c)];
            integer count2 = 0;
            for(AggregateResult agg : res){
                integer cou = (integer)agg.get('recordCount');
                count2 = count2 + cou;
            }
            response.put(string.valueof(yr),count2);
        }
        
        return response;
    }
    @AuraEnabled 
    public static Decimal getBookingsInSelectedMonth(list<Integer> months, List<String> TypeValue){
        Id loggedInUserContactId = getLoggedInUserContactId();
        Integer currentYear = Date.today().year();
        List<AggregateResult> results = new List<AggregateResult>();
        if(TypeValue.size() > 0 && months.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                         FROM Booking__c WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_MONTH(Booking_Date__c) in :months AND  Unit__c IN (
                             SELECT Id FROM Unit__c WHERE Tower__r.Tower_Type__c in :TypeValue) AND CALENDAR_YEAR(CreatedDate) = :currentYear AND Project__r.name !=:System.label.Excluded_Project];  
        }
        else  if(TypeValue.size() == 0 && months.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum FROM Booking__c
                         WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_MONTH(Booking_Date__c) in :months AND  
                         CALENDAR_YEAR(CreatedDate) = :currentYear AND Project__r.name !=:System.label.Excluded_Project];   
        }
        else if(TypeValue.size() > 0){
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum
                         FROM Booking__c WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         Unit__c IN (
                             SELECT Id FROM Unit__c WHERE Tower__r.Tower_Type__c in :TypeValue) AND CALENDAR_YEAR(CreatedDate) = :currentYear AND Project__r.name !=:System.label.Excluded_Project];  
        }
        else{
            results =   [SELECT SUM(Total_Purchase_Price__c) totalPriceSum FROM Booking__c
                         WHERE  Status__c !='Cancelled' AND (Channel_Partner__r.Contact__c = :loggedInUserContactId OR Sobha_Connect__r.Contact__c =:loggedInUserContactId) AND
                         CALENDAR_YEAR(CreatedDate) = :currentYear AND Project__r.name !=:System.label.Excluded_Project];   
        }
        
        if (!results.isEmpty()) {
            return (Decimal)results[0].get('totalPriceSum');
        } else { 
            return 0;
        }
    }
}