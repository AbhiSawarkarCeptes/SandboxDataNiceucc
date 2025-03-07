public class N_CancelBookingSOController{
    
    public String bookId;
    public Booking__c book;
    public boolean isError {get;set;}
    
    public N_CancelBookingSOController(){       
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != ''){
            bookId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(String.isNotBlank(bookId)){           
            book = [SELECT Status__c, Cancellation_In_Progress__c FROM Booking__c WHERE Id = :bookId]; 
            if(book.Status__c != 'Cancelled' && book.Status__c != 'Cancellation In Progress'){
                isError = false;    
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Selected booking is already cancelled or cancellation is in process.'));
                isError = true;    
            }                  
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to process your request. Invalid booking id'));
            isError = true;                
        }
       system.debug('error::: ' + isError); 
    } 
    
    public PageReference updateBookingStatus(){
        /* Trigger fires when boking status changes from Cancellation to Progress to Cancelled */
        List<Booking__c> cancelledBookingList = new List<Booking__c>();
        book = [SELECT Name,Status__c,Unit__c,Opportunity__c,Cancellation_In_Progress__c,Reason_For_Cancellation_D__c FROM Booking__c WHERE Id = :bookId]; 
        if (book.Reason_For_Cancellation_D__c == null || book.Reason_For_Cancellation_D__c == '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Please update Reason for Cancellation on Booking before cancelling the Booking.'));
            //isError = true;
            return null;
        }   
        book.Cancellation_In_Progress__c = true;
        book.Status__c = 'Cancellation In Progress';
        book.IS_SO__c = true;
        update book;
        
        book.Status__c = 'Cancelled';
        book.Cancellation_Date__c = System.now();
        update book;
        cancelledBookingList.add(book);
        trgBookinghandler.bookingCancellation(cancelledBookingList);
        trgBookinghandler.updatePaymentRequestStatus(new Set<String>{book.Name});
        BookingTriggerHandlerCtr.sendEmailOnBookingCancellation(cancelledBookingList);
        PageReference pr = new PageReference('/'+book.Id);
        return pr;
    }
    
    public PageReference cancel(){
        PageReference pr = new PageReference('/'+bookId);
        return pr;
    }
}