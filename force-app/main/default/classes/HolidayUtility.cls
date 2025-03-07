public with sharing class HolidayUtility {
    public HolidayUtility() {

    }

    public static String calculateBusinessHours(DateTime startDateTime, DateTime endDateTime, DateTime officeHoursStart, DateTime officeHoursEnd){

        System.debug('startDateTime # '+startDateTime);
        System.debug('endDateTime # '+endDateTime);
        
        Integer totalHours = 0; 
        Decimal totalMinutesDiff = 0;
        List<Date> holidays = new List<Date>(); 
        List<Holiday__c> listHoliday = [Select Id, Date__c from Holiday__c ORDER BY Date__c ASC limit 1000];
        for(Holiday__c holi: listHoliday){
            Date myDate = date.newinstance(holi.Date__c.year(), holi.Date__c.month(), holi.Date__c.day());
            holidays.add(myDate);
            System.debug('Holiday '+myDate);
        }

        System.debug('startDateTime.date() '+startDateTime.date());
        System.debug('endDateTime.date() '+endDateTime.date());
        
        if(endDateTime.date() == startDateTime.date()){
            System.debug('process started and ended on same day: '+startDateTime + ' - '+endDateTime);
            System.debug('officeHoursStart '+officeHoursStart);
            System.debug('officeHoursEnd '+officeHoursEnd);
            if(startDateTime<officeHoursStart){                
                startDateTime = officeHoursStart; 
            }else if(startDateTime>officeHoursEnd){
                startDateTime = officeHoursEnd;
            }

            
            if(endDateTime>officeHoursEnd){
                endDateTime = officeHoursEnd;
            }else if(endDateTime<officeHoursStart){
                endDateTime = officeHoursStart;
            }

            System.debug('startDateTime Changed1 '+ startDateTime);
            System.debug('endDateTime Changed1 '+ endDateTime);

            //totalHours = endingHour-startingHour;
            totalMinutesDiff = (endDateTime.getTime() - startDateTime.getTime()) / (1000*60);
            
            System.debug('Hours ##### 1 '+ Integer.valueOf(totalMinutesDiff/60));
            System.debug('Minutes ##### 1 '+ math.mod(Integer.valueOf(totalMinutesDiff), 60));

        }else if(endDateTime.date() > startDateTime.date()){
            System.debug('process started on: '+startDateTime + ' - and ended on: '+endDateTime);

            if(startDateTime<officeHoursStart){
                startDateTime = officeHoursStart;
            }else if(startDateTime>officeHoursEnd){
                startDateTime = officeHoursEnd;
            }

            totalMinutesDiff = (officeHoursEnd.getTime() - startDateTime.getTime()) / (1000*60);
            System.debug('totalMinutesDiff 111 '+totalMinutesDiff);
            //System.debug('Hours ##### 0 '+ Integer.valueOf(totalMinutesDiff/60));
            //System.debug('Minutes ##### 0 '+ math.mod(Integer.valueOf(totalMinutesDiff), 60));  

            startDateTime = startDateTime.addDays(1);
            officeHoursEnd = officeHoursEnd.addDays(1);
            officeHoursStart = officeHoursStart.addDays(1);

            System.debug('endDateTime.date()  '+endDateTime.date() );
            System.debug('startDateTime.date()  '+startDateTime.date() );

            while(endDateTime.date() > startDateTime.date()){
                if(holidays.contains(startDateTime.date())){
                    //no change in totalHours
                    System.debug('inside holdiy '+startDateTime);
                }else{
                    totalMinutesDiff = totalMinutesDiff + ((officeHoursEnd.getTime() - officeHoursStart.getTime()) / (1000*60));
                    System.debug('not  holiday : '+startDateTime);
                }
                System.debug('totalHours '+totalHours);

                startDateTime = startDateTime.addDays(1);
                officeHoursEnd = officeHoursEnd.addDays(1);
                officeHoursStart = officeHoursStart.addDays(1);
                
            }
            if(endDateTime.date() == startDateTime.date()){
                System.debug('officeHoursEnd '+officeHoursEnd);

                if(holidays.contains(startDateTime.date())){
                    //no change in totalHours
                    System.debug('inside holdiy '+startDateTime);
                }else{
                    if(endDateTime<officeHoursStart){
                    
                    }else if(endDateTime>officeHoursEnd){
    
                        totalMinutesDiff = totalMinutesDiff + ((officeHoursEnd.getTime() - officeHoursStart.getTime()) / (1000*60));
                    }
                    else{
                        totalMinutesDiff = totalMinutesDiff + ((endDateTime.getTime() - officeHoursStart.getTime()) / (1000*60));
                    }
                }
            }
        }
        Decimal finalhours = Integer.valueOf(totalMinutesDiff/60);
        Decimal finalminutes = math.mod(Integer.valueOf(totalMinutesDiff), 60);

        System.debug('Hours ##### 4 '+ finalhours);
        System.debug('Minutes  ##### 4 '+ finalminutes); 

        String firstValueStr = String.valueOf(finalhours);
        String secondValueStr = String.valueOf(finalminutes);  

        if(secondValueStr.length()==1){ 
            secondValueStr = '0'+secondValueStr;
        }

        String finalString = firstValueStr + '.'+ secondValueStr;
        System.debug('finalString  ##### 4 '+ finalString); 

        return finalString;
    }    
}