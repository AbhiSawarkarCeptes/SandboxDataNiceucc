global class MilestoneAgeingBatch implements Database.Batchable<sObject>,Schedulable{

    global void execute(SchedulableContext sc) {
        MilestoneAgeingBatch b = new MilestoneAgeingBatch();
        database.executebatch(b,1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Quotation__c,Total_On_Account_Money__c,Total_On_Account_Money_With_Registration__c,unit__c,Project__c FROM Booking__c WHERE Status__c != null AND Status__c != \'\' ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Booking__c> bookingList) {
         try{
             if(bookingList != null && bookingList.size() > 0){
             	MilestoneAgeingController.calculateAging(bookingList);
             }
         }catch(Exception e){
            System.debug('Exception '+e.getMessage());
         }
     }
    global void finish(Database.BatchableContext BC) {}

}