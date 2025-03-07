trigger Booking on Booking__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        try {
            // Add any necessary validation or processing logic here
            // For example, ensure required fields are populated
            for(Booking__c booking : Trigger.new) {
                if(booking.Account__c == null || booking.Quotation__c == null) {
                    booking.addError('Account and Quotation fields are required');
                }
            }
        } catch(Exception e) {
            // Handle any exceptions
            System.debug('Error in Booking trigger: ' + e.getMessage());
        }
    }
}
