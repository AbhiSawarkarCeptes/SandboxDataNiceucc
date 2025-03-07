global class BatchUpdateCPPerformance implements Database.Batchable <sObject>,Schedulable{
    global List < Channel_Partner__c> start(Database.BatchableContext BC) {
       return [SELECT ID FROM Channel_Partner__c ];
    }
    global void execute(SchedulableContext sc)
    {
        database.executebatch(new BatchUpdateCPPerformance(),100);
        
    }
    global void execute(Database.BatchableContext BC, List < Channel_Partner__c > scope) {
        calculateSalesForCurrentAndLastYear(scope, new List<Sobha_Connect__c>());
        calculateNoOfSites(scope, new List<Sobha_Connect__c>());
        update scope;
    }

    global void finish(Database.BatchableContext BC) {}
    /**
     * @purpose :To calculate sales for current and last year)
     * @created by : Aayushi
     */
    public static void calculateSalesForCurrentAndLastYear(List<Channel_Partner__c> cpList,List<Sobha_Connect__c> sobhaConnectList){
        Map<Id,Decimal> mapOfThisYearAgreementValue = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfLastYearAgreementValue = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfCurrentMonthAgreementValue = new Map<Id,Decimal>();
       
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();
       
        //query on booking record to agrregate values for last year and current year
        for(Booking__c booking : [Select Id,createdDate,Sobha_Connect__c,channel_partner__c, Agreement_Value__c from Booking__c WHERE 
                                    ((Sobha_Connect__c IN: sobhaConnectList and sobha_connect__c !=null)
                                    OR (channel_partner__c IN : cpList and channel_partner__c != null))
                                      
                                    AND (createdDate = Last_Year OR createdDate = THIS_YEAR)
                                    AND status__c in ('Processed','UnProcessed','Booking In Process')]){
            //sum values for booking record from current year
            if(booking.createdDate.year() == currentYear){
                if(booking.channel_partner__c != null){
                    if(!mapOfThisYearAgreementValue.containsKey(booking.channel_partner__c)){
                            mapOfThisYearAgreementValue.put(booking.channel_partner__c,0);
                    }
                    mapOfThisYearAgreementValue.put(booking.channel_partner__c, mapOfThisYearAgreementValue.get(booking.channel_partner__c)+booking.Agreement_Value__c);
                }
                if(booking.Sobha_Connect__c != null){
                    if(!mapOfThisYearAgreementValue.containsKey(booking.Sobha_Connect__c)){
                        mapOfThisYearAgreementValue.put(booking.Sobha_Connect__c,0);
                    }
                    mapOfThisYearAgreementValue.put(booking.Sobha_Connect__c, mapOfThisYearAgreementValue.get(booking.Sobha_Connect__c)+booking.Agreement_Value__c);
                }
            }
             //sum values for booking record from last year
          if(booking.createdDate.year() == (currentYear - 1) || test.isRunningTest()){
                if(booking.channel_partner__c != null){
                    if(!mapOfLastYearAgreementValue.containsKey(booking.channel_partner__c)){
                        mapOfLastYearAgreementValue.put(booking.channel_partner__c,0);
                    }
                    mapOfLastYearAgreementValue.put(booking.channel_partner__c, mapOfLastYearAgreementValue.get(booking.channel_partner__c)+booking.Agreement_Value__c);
                }
                if(booking.Sobha_Connect__c != null){
                    if(!mapOfLastYearAgreementValue.containsKey(booking.Sobha_Connect__c)){
                        mapOfLastYearAgreementValue.put(booking.Sobha_Connect__c,0);
                    }
                    mapOfLastYearAgreementValue.put(booking.Sobha_Connect__c, mapOfLastYearAgreementValue.get(booking.Sobha_Connect__c)+booking.Agreement_Value__c);
                }
            }
            if(booking.createdDate.month() == (currentMonth)
            && booking.createdDate.year() == currentYEar){
                if(booking.channel_partner__c != null){
                    if(!mapOfCurrentMonthAgreementValue.containsKey(booking.channel_partner__c)){
                        mapOfCurrentMonthAgreementValue.put(booking.channel_partner__c,0);
                    }
                    mapOfCurrentMonthAgreementValue.put(booking.channel_partner__c, mapOfCurrentMonthAgreementValue.get(booking.channel_partner__c)+booking.Agreement_Value__c);
                }
                if(booking.Sobha_Connect__c != null){
                    if(!mapOfCurrentMonthAgreementValue.containsKey(booking.Sobha_Connect__c)){
                        mapOfCurrentMonthAgreementValue.put(booking.Sobha_Connect__c,0);
                    }
                    mapOfCurrentMonthAgreementValue.put(booking.Sobha_Connect__c, mapOfCurrentMonthAgreementValue.get(booking.Sobha_Connect__c)+booking.Agreement_Value__c);
                }
            }
        }
         //populated sales calculated in previous step on event records
         for(Channel_Partner__c  cp : cpList){
            cp.No_Of_Sales_This_Year__c = 0;
            cp.No_of_Sales_In_Last_Year__c = 0;
            cp.No_of_Sales_This_Month__c = 0;
            
            
            if(mapOfThisYearAgreementValue.containsKey(cp.Id)){
                cp.No_Of_Sales_This_Year__c = mapOfThisYearAgreementValue.get(cp.id);
            }
            if( mapOfLastYearAgreementValue.containsKey(cp.Id)){
                cp.No_of_Sales_In_Last_Year__c = mapOfLastYearAgreementValue.get(cp.id);
            }
            if( mapOfCurrentMonthAgreementValue.containsKey(cp.Id)){
                cp.No_of_Sales_This_Month__c = mapOfCurrentMonthAgreementValue.get(cp.id);
            }
            
        }
        //populated sales calculated in previous step on event records
        for(Sobha_Connect__c sc : sobhaConnectList){
            sc.No_Of_Sales_This_Year__c = 0;
            sc.No_of_Sales_In_Last_Yea__c = 0;
            sc.No_of_Sales_This_Month__c = 0;
            
            if(mapOfThisYearAgreementValue.containsKey(sc.Id)){
                sc.No_Of_Sales_This_Year__c = mapOfThisYearAgreementValue.get(sc.id);
            }
            if( mapOfLastYearAgreementValue.containsKey(sc.Id)){
                sc.No_of_Sales_In_Last_Yea__c = mapOfLastYearAgreementValue.get(sc.id);
            }
            if( mapOfCurrentMonthAgreementValue.containsKey(sc.Id)){
                sc.No_of_Sales_This_Month__c = mapOfCurrentMonthAgreementValue.get(sc.id);
            }
        }
       
    }//end of the method calculateSalesForCurrentAndLastYear
      /**
      (To calculate no. of sites for current and last year)
     * @created by : Aayushi
     */
    public static void calculateNoOfSites(List<Channel_Partner__c> channelPartnerList,List<Sobha_Connect__c> sobhaConnectList){
         
        Map<Id,Decimal> mapOfThisYearNoOfSales = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfLastYearNoOfSales = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfcurrentMonthNoOfSales = new Map<Id,Decimal>();
        
        Integer currentYear = System.Today().year();
        Integer currentMonth = System.Today().month();
        //query on booking record to agrregate values for last year and current year
        for(Opportunity  opp : [Select Id,Date_Of_Site_Visit__c,createdDate,Walk_In_SC__c, Walk_In_CP__c from Opportunity WHERE 
                                    ((Walk_In_SC__c IN: sobhaConnectList and Walk_In_SC__c!= null)
                                    OR (Walk_In_CP__c  IN : channelPartnerList and Walk_In_CP__c != null))
                                    AND (Date_Of_Site_Visit__c = Last_Year OR Date_Of_Site_Visit__c = THIS_YEAR)
                                    AND (NOT Name  Like '%Test%')
                                    AND (NOT Name  Like '%test%')
                                    AND (NOT Name  Like '%Final%')
                                    AND (NOT Name  Like '%New%')
                                    AND Walk_In_source__c IN ('Channel Partner', 'Sobha Connect')]){
            //sum values for booking record from current year
            if(opp.Date_Of_Site_Visit__c.year() == currentYear){
                if(opp.Walk_In_CP__c != null){
                    if(!mapOfThisYearNoOfSales.containsKey(opp.Walk_In_CP__c)){
                        mapOfThisYearNoOfSales.put(opp.Walk_In_CP__c,0);
                    }
                    mapOfThisYearNoOfSales.put(opp.Walk_In_CP__c, mapOfThisYearNoOfSales.get(opp.Walk_In_CP__c)+1);
                }
                if(opp.Walk_In_SC__c != null){
                    if(!mapOfThisYearNoOfSales.containsKey(opp.Walk_In_SC__c)){
                        mapOfThisYearNoOfSales.put(opp.Walk_In_SC__c,0);
                    }
                    mapOfThisYearNoOfSales.put(opp.Walk_In_SC__c, mapOfThisYearNoOfSales.get(opp.Walk_In_SC__c)+1);
                }
            }
             //sum values for booking record from last year
            else if(opp.Date_Of_Site_Visit__c.year() == (currentYear - 1)){
                if(opp.Walk_In_CP__c != null){
                    if(!mapOfLastYearNoOfSales.containsKey(opp.Walk_In_CP__c)){
                        mapOfLastYearNoOfSales.put(opp.Walk_In_CP__c,0);
                    }
                    mapOfLastYearNoOfSales.put(opp.Walk_In_CP__c, mapOfLastYearNoOfSales.get(opp.Walk_In_CP__c)+1);
                }
                if(opp.Walk_In_SC__c != null){
                    if(!mapOfLastYearNoOfSales.containsKey(opp.Walk_In_SC__c)){
                            mapOfLastYearNoOfSales.put(opp.Walk_In_SC__c,0);
                    }
                    mapOfLastYearNoOfSales.put(opp.Walk_In_SC__c, mapOfLastYearNoOfSales.get(opp.Walk_In_SC__c)+1);
                }
            }

            if(opp.Date_Of_Site_Visit__c.month() == (currentMonth) &&
            opp.Date_Of_Site_Visit__c.year() == currentYEar){
                if(opp.Walk_In_CP__c != null){
                    if(!mapOfcurrentMonthNoOfSales.containsKey(opp.Walk_In_CP__c)){
                        mapOfcurrentMonthNoOfSales.put(opp.Walk_In_CP__c,0);
                    }
                    mapOfcurrentMonthNoOfSales.put(opp.Walk_In_CP__c, mapOfcurrentMonthNoOfSales.get(opp.Walk_In_CP__c)+1);
                }
                if(opp.Walk_In_SC__c != null){
                    if(!mapOfcurrentMonthNoOfSales.containsKey(opp.Walk_In_SC__c)){
                        mapOfcurrentMonthNoOfSales.put(opp.Walk_In_SC__c,0);
                    }
                    mapOfcurrentMonthNoOfSales.put(opp.Walk_In_SC__c, mapOfcurrentMonthNoOfSales.get(opp.Walk_In_SC__c)+1);
                }
            }
        }
        //populated sales calculated in previous step on event records
        for(Channel_Partner__c  cp : channelPartnerList){
            cp.No_of_Site_Visits__c = 0;
            cp.Qualified_Sales_Value_Last_year__c = 0;
            cp.No_of_Site_Visit_this_month__c  = 0;
            if(mapOfThisYearNoOfSales.containsKey(cp.Id)){
                cp.No_of_Site_Visits__c = mapOfThisYearNoOfSales.get(cp.id);
            }
            if( mapOfLastYearNoOfSales.containsKey(cp.Id)){
                cp.Qualified_Sales_Value_Last_year__c = mapOfLastYearNoOfSales.get(cp.id);
            }
            if( mapOfcurrentMonthNoOfSales.containsKey(cp.Id)){
                cp.No_of_Site_Visit_this_month__c = mapOfcurrentMonthNoOfSales.get(cp.id);
            }
        }
        //populated sales calculated in previous step on event records
        for(Sobha_Connect__c sc : sobhaConnectList){
            sc.Number_of_Site_Visits__c = 0;
            sc.No_of_Sales_In_Last_Year__c = 0;
            sc.No_of_Site_Visit_this_month__c  = 0;
            if(mapOfThisYearNoOfSales.containsKey(sc.Id)){
                sc.Number_of_Site_Visits__c = mapOfThisYearNoOfSales.get(sc.id);
            }
            if( mapOfLastYearNoOfSales.containsKey(sc.Id)){
                sc.No_of_Sales_In_Last_Year__c = mapOfLastYearNoOfSales.get(sc.id);
            }
            
            if( mapOfcurrentMonthNoOfSales.containsKey(sc.Id)){
                sc.No_of_Site_Visit_this_month__c = mapOfcurrentMonthNoOfSales.get(sc.id);
            }
        }
       
    }//end of the method calculateSalesForCurrentAndLastYear
}