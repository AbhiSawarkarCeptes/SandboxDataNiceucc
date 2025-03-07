public class N_TransferAmountController{

    Id bookingId;
    public Booking__c b {get;set;}
    public Transfer_Amount__c t {get;set;}
    public Boolean bank {get;set;}

    public N_TransferAmountController(){
         t = new Transfer_Amount__c();
         bank = true;
    
         if(ApexPages.currentPage().getParameters().get('bookId') != null && ApexPages.currentPage().getParameters().get('bookId') != '')
                bookingId = ApexPages.currentPage().getParameters().get('bookId');
                
         if(bookingId != null){         
             b = [SELECT Id, Name, Unit__c, Opportunity__c, Final_Corporate_Account_Amount__c, Final_ESCROW_Account_Amount__c 
                  FROM Booking__c 
                  WHERE Id = :bookingId];
         }
         
         t.Unit__c = b.Unit__c;
         t.Opportunity__c = b.Opportunity__c; 
         t.Booking__c = b.Id;
    }
    
    public PageReference save(){
        if(t.Transfer_Date__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Transfer Date'));
            return null;               
        }
        if(t.GL_Date__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter GL Date'));
            return null;               
        }
        if(t.From_Account__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter From Account'));
            return null;               
        }
        if(t.To_Account__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter To Account'));
            return null;               
        }
        if(String.isBlank(t.Mode_of_Payment__c) || t.Mode_of_Payment__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Mode of Payment'));
            return null;               
        }
		if(t.Amount__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Amount'));
            return null;               
        }
		if(t.Instrument_No__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Instrument No.'));
            return null;               
        }
		if((String.isBlank(t.Drawee_Bank__c) || t.Drawee_Bank__c == null) && t.Mode_of_Payment__c == 'Cheque'){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Drawee Bank'));
            return null;               
        }
		if(String.isBlank(t.Bank_Reference_No__c) || t.Bank_Reference_No__c == null){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Bank Reference No.'));
            return null;               
        }		  
        if(b.Final_Corporate_Account_Amount__c == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Amount in Corporate Account is 0, so you cannot transfer amount'));
            return null;
        } 
        if(t.Amount__c > b.Final_Corporate_Account_Amount__c){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Transfer amount is more than on account money'));
            return null;
        } else {
            try{
                insert t;
            } 
            catch(Exception e){
                System.debug('Error occurred while inserting transfer amount:: ' + e);    
            }
            return new PageReference('/'+t.Id);
        }    
    }
    
    public PageReference close(){
        return new PageReference('/'+b.Id);   
    }
}