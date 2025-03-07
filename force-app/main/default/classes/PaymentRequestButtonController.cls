public without sharing class PaymentRequestButtonController {
	@AuraEnabled
    public static string confirmAmount(Double amount, string referenceNo, string accountReceivedDate, string prId){
        string res = '';
        Boolean PR_Deallocation_Feature = Feature_Flag__mdt.getAll().containsKey('PR_Deallocation') && Feature_Flag__mdt.getInstance('PR_Deallocation').Active__c;//Fix for amount deductions in DWT and CDM-Cash
        
        Payment_Request__c pr = new Payment_Request__c(Id=prId);
        
        if(PR_Deallocation_Feature){
            List<Payment_Request__c> prs = [SELECT id,Amount__c,Original_Amount__c FROM Payment_Request__c WHERE Id = :prId];
            if(!prs.isEmpty()) pr = prs[0];
        }

        try{
            if(PR_Deallocation_Feature && pr.Amount__c != amount){//If confirmed amount has changed, remove allocations
                pr.Towards_Unit_Price_Amount__c = null;
                pr.Towards_Pre_Registration_Amount__c = null;
                pr.Towards_Other_Charges_Amount__c = null;
                pr.Others__c = null;
                pr.Amount_Allocated__c = false;
            }

            pr.Amount__c = amount;
            pr.Reference_Number__c = referenceNo;
            pr.Account_Received_Date__c = Date.valueOf(accountReceivedDate);
            pr.Amount_Confirmed_By_Accounts__c = true;
            pr.Final_Approver__c = UserInfo.getUserId();
            pr.Status__c = 'Amount Confirmed by Accounts';
            
        	update pr;
            res = 'SUCCESS';
        }
        catch(Exception e){
            res = e.getMessage();
        }
        return res;
    }
    
    @AuraEnabled
    public static string resubmitToSM(string prId, string remarks){
        string res = '';
        Payment_Request__c pr = new Payment_Request__c(Id=prId);
        pr.Status__c = 'Resubmitted to SM/SD';
        pr.Remarks__c = remarks;
        try{
        	update pr;
            res = 'SUCCESS';
        }
        catch(Exception e){
            res = e.getMessage();
        }
        return res;
    }
    
    @AuraEnabled
    public static string updatePaymentRequest(string prId, string instrumentNumber, string instrumentDate, string referenceNumber){
        string res = '';
        Payment_Request__c pr = new Payment_Request__c(Id=prId);
        if(instrumentNumber!=null && instrumentNumber!='')
        	pr.Instrument_Number__c = instrumentNumber;
        if(instrumentDate!=null && instrumentDate!='')
        	pr.Instrument_Date__c = Date.valueOf(instrumentDate);
        if(referenceNumber!=null && referenceNumber!='')
        	pr.Reference_Number__c = referenceNumber;
        try{
        	update pr;
            res = 'SUCCESS';
        }
        catch(Exception e){
            res = e.getMessage();
        }
        return res;
    }
}