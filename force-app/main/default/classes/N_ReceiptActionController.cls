public class N_ReceiptActionController{    
    String rId;
    public Receipt__c rcpt {get; set;}
    List<Receipt_Details__c> lstRctDetails;
    public String selectedRadioOption {get;set;}

    public N_ReceiptActionController(){   
        lstRctDetails = new List<Receipt_Details__c>();
        rcpt = new Receipt__c();     
        if (Apexpages.Currentpage().getParameters().get('id') != null && Apexpages.Currentpage().getParameters().get('id') != '')
            rId = Apexpages.Currentpage().getParameters().get('id');
    
        if(String.isNotBlank(rId) && rId != null){
            rcpt = [SELECT Id, Name, Project__c, Project_Unit__c, Credit_Account__c, Debit_Account__c, Booking__c, Mode__c, Tax_Debit_Account__c,
                    Business_Unit_Code__c, Business_Unit__c, Amount_Rs__c, Description__c, Is_Reversed_Receipt__c, Tax_Rate__c, Corporate_Collection_Control_Report__c,
                    Receipt_Number__c, Payment_Towards__c, Receipt_Status__c, Credit_Note_Amount__c, Tax_Amount__c, Total_Money_Apportioned__c, Cancellation_Reason__c,
                    Registration_Collection_Control_Report__c, Booking__r.Quotation__c FROM Receipt__c WHERE Id = :rId];
            lstRctDetails = [Select Id, Name, Receipts__c, Status__c from Receipt_Details__c where Receipts__c =: rId];        
        }
    }
    
    public PageReference cancel(){
        return new PageReference('/'+rId);
    }
    
    public PageReference save(){
        if(selectedRadioOption != null && selectedRadioOption == 'reverseCreditNote'){
            if(rcpt.Is_Reversed_Receipt__c != null && rcpt.Is_Reversed_Receipt__c){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'This receipt is already reversed'));
             return null;           
            }
        }
        if(selectedRadioOption != null && selectedRadioOption == 'voidReceipt'){
            if(rcpt.Total_Money_Apportioned__c != null && rcpt.Total_Money_Apportioned__c > 0){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'You cannot make this receipt void. Please unapportion this receipt first'));
             return null;
            }
            else if( 'Cheque'.equals(rcpt.Mode__c) && String.isBlank( rcpt.Cancellation_Reason__c) ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'Please enter Cancellation Reason from the receipt record before voiding the receipt.'));
                return null;
            }
        }
        if(selectedRadioOption != null && selectedRadioOption == 'reverseCreditNote')
            reverseCreditNote();
        else if(selectedRadioOption != null && selectedRadioOption == 'unapportionReceipt')    
            unapportionReceipt();
        else if(selectedRadioOption != null && selectedRadioOption == 'voidReceipt')
            voidReceipt();  
        return new PageReference('/'+ rcpt.Id); 
    }

///// Credit Note is reversed by creating debit note and updating RD status to 'Cancelled'   
///// Receipt cannot be reversed 
///// Reversed Credit Note can be adjusted by this Debit note only
    public PageReference reverseCreditNote(){                                 
            if(!lstRctDetails.isEmpty() && lstRctDetails.size() > 0) {
                for(Receipt_Details__c rd : lstRctDetails) {
                    rd.Status__c = 'Cancelled';
                }
                update lstRctDetails; 
            }            
            
            Demand__c d = new Demand__c();
            d.Remarks__c = 'Debit Note for Credit Note Rejection: '+ rcpt.Receipt_Number__c;
            d.Milestone_Name__c = 'Debit Note for Credit Note Rejection: '+ rcpt.Receipt_Number__c;       
            d.Debit_Demanded__c = rcpt.Credit_Note_Amount__c;
            d.Debit_CGST__c = rcpt.Tax_Amount__c;
            d.Tax_Rate__c = rcpt.Tax_Rate__c;
            d.Invoice_Date__c = System.Today();
            d.GL_Date__c = System.Today();
            d.Due_Date__c = System.Today();
            d.Project__c = rcpt.Project__c;
            d.Booking__c = rcpt.Booking__c;
            d.Unit__c = rcpt.Project_Unit__c;
            d.Total_Amount_Account__c = rcpt.Debit_Account__c;
            d.Total_Amount_with_Tax_Account__c = rcpt.Credit_Account__c;           
            d.Total_Tax_Account__c = rcpt.Tax_Debit_Account__c;
            d.Receipt__c = rcpt.Id;
            d.Quotation__c = rcpt.Booking__r.Quotation__c ;
            d.Business_Unit__c = rcpt.Business_Unit__c;
            d.Business_Unit_Code__c = rcpt.Business_Unit_Code__c; 
            d.Corporate_Collection_Control_Report__c = rcpt.Corporate_Collection_Control_Report__c; 
            d.Registration_Collection_Control_Report__c = rcpt.Registration_Collection_Control_Report__c;
            d.Payment_Towards__c = rcpt.Payment_Towards__c ;
            d.Debit_Type__c = 'Credit Note Reversal';
            insert d;
           
            rcpt.Description__c = 'Reversed from Actions';
            rcpt.Is_Reversed_Receipt__c = true;            
            update rcpt;  
            return null;      
    }

////while unapportioning, we are not creating DN and this receipt can be adjusted against any demand    
    public PageReference unapportionReceipt(){              
            if(!lstRctDetails.isEmpty() && lstRctDetails.size() > 0) {
                for(Receipt_Details__c rd : lstRctDetails) {
                    rd.Status__c = 'Cancelled';
                }
                update lstRctDetails;
            }
            return null;                           
    }

////// Receipt is cancelled. We can cancel receipt only if Total Money Apportioned = 0 
    public PageReference voidReceipt(){                         
            rcpt.Receipt_Status__c = 'Cancelled'; 
            update rcpt; 
            return null;                          
    }
}