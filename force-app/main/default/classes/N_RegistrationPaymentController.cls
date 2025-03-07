public class N_RegistrationPaymentController{

    Id bookingId;
    public Booking__c b {get;set;}
    public Registration_Payment_Account__c r {get;set;}
    public Boolean bank {get;set;}

    public N_RegistrationPaymentController(){
         r = new Registration_Payment_Account__c();
         bank = true;
    
         if(ApexPages.currentPage().getParameters().get('bookId') != null && ApexPages.currentPage().getParameters().get('bookId') != '')
                bookingId = ApexPages.currentPage().getParameters().get('bookId');
                
         if(bookingId != null){         
             b = [SELECT Id, Name, Unit__c, Opportunity__c, Final_Corporate_Account_Amount__c, Amount_Transferred_to_Registration__c
                  FROM Booking__c 
                  WHERE Id = :bookingId];
         }
         
         r.Unit__c = b.Unit__c;
         r.Opportunity__c = b.Opportunity__c; 
         r.Booking__c = b.Id;
    }
    
    public PageReference getDetails(){
        if(r.Mode_of_Payment__c == 'Cheque'){
            bank = true;
        } else {
            bank = false;
        } 
        return null;   
    }
    
    public PageReference save(){
        if(r.Transfer_Date__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Transfer Date'));
            return null;               
        }
        if(r.GL_Date__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter GL Date'));
            return null;               
        }
        if(r.From_Account__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter From Account'));
            return null;               
        }       
        if(String.isBlank(r.Mode_of_Payment__c) || r.Mode_of_Payment__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Mode of Payment'));
            return null;               
        }
		if(r.Amount__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Amount'));
            return null;               
        }
		if(r.Instrument_No__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Instrument No.'));
            return null;               
        }
		if((String.isBlank(r.Drawee_Bank__c) || r.Drawee_Bank__c == null) && r.Mode_of_Payment__c == 'Cheque'){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Drawee Bank'));
            return null;               
        }
		if(String.isBlank(r.Bank_Reference_No__c) || r.Bank_Reference_No__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Bank Reference No.'));
            return null;               
        }
        if(b.Final_Corporate_Account_Amount__c == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Amount in Corporate Account is 0, so you cannot transfer amount'));
            return null;
        } 
        if(r.Amount__c > b.Final_Corporate_Account_Amount__c){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Transfer amount is more than on account money'));
            return null;
        } else {
            try{
                insert r;
            } 
            catch(Exception e){
                System.debug('Error occurred while inserting transfer amount:: ' + e);    
            }
            return new PageReference('/'+r.Id);
        }    
    }
    
    public PageReference close(){
        return new PageReference('/'+b.Id);   
    }
}