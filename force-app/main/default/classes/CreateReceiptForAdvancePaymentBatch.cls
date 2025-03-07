global class CreateReceiptForAdvancePaymentBatch implements Database.Batchable <sObject>, Database.Stateful {
global list<string> finishreceiptIdList =  new List<string>();
    
    global List < Advance_Payment_Rebate__c > start(Database.BatchableContext BC) {
        List < Advance_Payment_Rebate__c > uList = new List < Advance_Payment_Rebate__c > ();
        if(!test.isRunningTest()){
            uList = [select id,Approved_Time__c,Booking__c,Booking__r.Unit__r.Name,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__c,Booking__r.Unit__c,Description__c,
        Booking__r.Total_On_Account_Money_With_Registration__c,Receipt_Generated__c,Discount_Amount__c,Booking__r.Opportunity__c,  CreatedDate, CreatedBy.Name from Advance_Payment_Rebate__c where Approval_Status__c ='Approved' and Approved_Time__c >= yesterday and Receipt_Generated__c = false];
        }
        else{
             uList = [select id,Approved_Time__c,Booking__c,Booking__r.Unit__r.Name,Booking__r.Primary_Applicant_Name__c,Booking__r.Project__c,Booking__r.Unit__c,Description__c,
        Booking__r.Total_On_Account_Money_With_Registration__c,Receipt_Generated__c,Discount_Amount__c,Booking__r.Opportunity__c,  CreatedDate, CreatedBy.Name from Advance_Payment_Rebate__c where Approval_Status__c ='Approved'];
        }
        return uList;
    }

    global void execute(Database.BatchableContext BC, List < Advance_Payment_Rebate__c > scope) {
        List<Receipt__c> receiptToInsert = new List<Receipt__c>();
        Account_Master__c amCredit = [select Id, Name from Account_Master__c where Name = 'Trade Receivable' LIMIT 1];
        Account_Master__c amDebit = [select Id, Name from Account_Master__c where Name = 'Discount/rebate credit note' LIMIT 1];
       	Set<String> insertedReceipts = new Set<String>();
        List<Advance_Payment_Rebate__c> aprList = new List<Advance_Payment_Rebate__c>(); 
        
        for(Advance_Payment_Rebate__c apr : scope) {
            receiptToInsert.add(createReceipt(apr,amCredit.id,amDebit.id));
            apr.Receipt_Generated__c = true;
            aprList.add(apr);
        }
        if(receiptToInsert.size() > 0){
            Database.SaveResult[] rList = Database.insert(receiptToInsert,false);           
			for (Database.SaveResult record: rList) {
  				insertedReceipts.add(record.id); 
			}
			insertedReceipts.remove(null);
        }
        finishreceiptIdList.addAll(insertedReceipts);
        update aprList;
        System.debug('I finishreceiptIdList'+finishreceiptIdList);
    }

    global void finish(Database.BatchableContext BC) {
         if(finishreceiptIdList != null && finishreceiptIdList.size() > 0){
             System.debug('I am in finishreceiptIdList'+finishreceiptIdList);
            ID jobID = System.enqueueJob(new EmailOnReceiptAdvancePaymentQueueable(finishreceiptIdList)); 
        } 
    }
    
    private Receipt__c createReceipt(Advance_Payment_Rebate__c rebate,String amCredit,String amDebit){
       
        Receipt__c r = new Receipt__c();
        r.Debit_Account__c = amDebit;
        r.Credit_Account__c = amCredit;
        r.Booking__c  = rebate.Booking__c;
        r.GL_Date__c =  date.newinstance(rebate.Approved_Time__c.year(), rebate.Approved_Time__c.month(), rebate.Approved_Time__c.day()); 
        r.Receipt_Date__c = system.today();
        r.Cheque_DD_Date__c = system.today();
        r.Payment_Towards__c = 'Corporate Account';
        r.Banking__c = 'Payment Successful';
        r.Receipt_Status__c = 'Cleared';
        r.Credit_Card_Charges__c = 0;
        r.Total_Amount__c = rebate.Discount_Amount__c;
        r.Amount_Rs__c = rebate.Discount_Amount__c;
        r.Mode__c = 'Credit Note';
        r.RemarksText__c = rebate.Description__c+' '+rebate.Discount_Amount__c;
        r.Project__c = rebate.Booking__r.Project__c;
        r.Project_Unit__c =  rebate.Booking__r.Unit__c;
        r.Opportunity__c = rebate.Booking__r.Opportunity__c;
        r.Advance_Payment_Rebate__c = rebate.id;
        return r;
}


}