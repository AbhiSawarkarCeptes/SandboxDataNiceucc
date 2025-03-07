global class LpWaiverReceiptBatch implements Database.Batchable<sObject>, Database.Stateful{

    global list<string> waiverIdList =  new List<string>();
    global list<Receipt__c> receiptList = new List<Receipt__c>();
    global list<LP_Waiver__c> waiverList = new List<LP_Waiver__c>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
		
        String status = 'Approved by MDO/CMO';
        String query = 'SELECT Id,Booking__c,Booking__r.Unit__r.Name,Booking__r.Primary_Applicant_Name__c,'+
            			'Booking__r.Project__c,Booking__r.Unit__c,Booking__r.Total_On_Account_Money_With_Registration__c,'+
                        'Amount_Towards_Late_Penalty__c,Booking__r.Opportunity__c,LP_Amount_To_Be_Waived__c, CreatedDate,'+ 
            			'CreatedBy.Name,Approved_Amount__c from LP_Waiver__c where Status__c =\'Approved by MDO/CMO\' and Receipt__c = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<LP_Waiver__c> lpWaiver) {
        Account_Master__c amCredit = [select Id, Name from Account_Master__c where Name = 'Trade Receivable' LIMIT 1];
        Account_Master__c amDebit = [select Id, Name from Account_Master__c where Name = 'Discount/rebate credit note' LIMIT 1];
        
        for(LP_Waiver__c lp : lpWaiver){
        Receipt__c r = new Receipt__c();
        r.Debit_Account__c = amDebit.Id;
        r.Credit_Account__c = amCredit.Id;
        r.Booking__c  = lp.Booking__c;
        r.GL_Date__c = system.today();
        r.Receipt_Date__c = system.today();
        r.Cheque_DD_Date__c = system.today();
        r.Payment_Towards__c = 'Corporate Account';
        r.Banking__c = 'Payment Successful';
        r.Receipt_Status__c = 'Cleared';
        r.Credit_Note_Amount__c = (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Total_Amount__c = (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Amount_Rs__c = (lp.Approved_Amount__c != null && lp.Approved_Amount__c > 0) ? lp.Approved_Amount__c : lp.LP_Amount_To_Be_Waived__c;
        r.Mode__c = 'Credit Note';
        r.RemarksText__c = '';
        r.Project__c = lp.Booking__r.Project__c;
        r.Project_Unit__c = lp.Booking__r.Unit__c;
        r.Opportunity__c = lp.Booking__r.Opportunity__c;
        r.LP_Waiver__c = lp.id;
        insert r;
        lp.Receipt__c = r.id;
        update lp;
         waiverIdList.add(lp.id);
        }
    }
    
     global void finish(Database.BatchableContext BC) {
         if(waiverIdList != null && waiverIdList.size() > 0){
            ID jobID = System.enqueueJob(new LpWaiverReceiptQueueable(waiverIdList)); 
        }
     }
}