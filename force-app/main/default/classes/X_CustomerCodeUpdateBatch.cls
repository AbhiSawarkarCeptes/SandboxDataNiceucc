global class X_CustomerCodeUpdateBatch implements Database.Batchable <sObject>, Database.Stateful{

    global List<String> failedBookingIdsList = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'SELECT Id,Name,opportunity__r.AccountId,Unit__r.Xpedeon_Unit_Code__c,Unit__r.Unit_No__c,opportunity__r.Account.Code__c,unit__r.Name FROM Booking__c WHERE SF_Xp_Composite_Code__c = null and Opportunity__c != null and Unit__c != null';
        String query = 'SELECT Id,Name,opportunity__r.AccountId,Unit__r.Xpedeon_Unit_Code__c,Unit__r.Unit_No__c,opportunity__r.Account.Code__c,unit__r.Name FROM Booking__c WHERE Opportunity__c != null and Unit__c != null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List <Booking__c> bookingsList) {
        List<Booking__c> updateBookingsList = new List<Booking__c>();
        if(bookingsList != null && bookingsList.size() > 0){
            for(Booking__c booking : bookingsList){
                if(booking.opportunity__r.AccountId != null && booking.opportunity__r.Account.Code__c != null && booking.unit__r.Name != null){
                    String UnitCode = (String.IsNotBlank(booking.Unit__r.Xpedeon_Unit_Code__c)) ? String.ValueOf(booking.Unit__r.Xpedeon_Unit_Code__c) : booking.Unit__r.Unit_No__c;
                    booking.SF_Xp_Composite_Code__c = booking.Name + '-' + booking.opportunity__r.Account.Code__c + '-' + UnitCode;
                    updateBookingsList.add(booking);
                }
            }
            if(updateBookingsList != null && !updateBookingsList.isEmpty()){
                Database.SaveResult[] resultBookingUpdate = Database.update(updateBookingsList,false);
                
                for (Database.SaveResult result : resultBookingUpdate) if(!result.isSuccess()) failedBookingIdsList.add(result.getid());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!failedBookingIdsList.isEmpty())insert new Error_Log__c(Name = 'X_CustomerCodeUpdateBatch',Message__c = 'failedBookingIdsList - \n\n'+failedBookingIdsList);
    }
}