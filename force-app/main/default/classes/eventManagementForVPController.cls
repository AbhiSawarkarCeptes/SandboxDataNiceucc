public  class eventManagementForVPController {
    @AuraEnabled(cacheable=true)
    public static List<Events__c> eventWithinCurrentMonth(){
      //  try {
            return [SELECT Id,Name,City_Country__c,Country__c,date_of_event__c,end_date_of_event__c,createdby.name ,createdbyId,RecordType.Name  FROM Events__c WHERE date_of_event__c >=Last_N_Days:15 AND end_date_of_event__c <=Next_N_Days:15 order by date_of_event__c asc];
       //      return null;
     //   } catch (Exception e) {
     //       throw new AuraHandledException(e.getMessage());
    //    } */
        
    }
}