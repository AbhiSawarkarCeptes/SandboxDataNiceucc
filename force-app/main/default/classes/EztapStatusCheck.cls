global class EztapStatusCheck implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global string status = '';
    global string remarks = '';
    global string msgCode = '';
    global string prId = '';
    global string txnId = '';
    global string rawResponse = '';
    
    public EztapStatusCheck(string txnId){
        this.txnId = txnId;
    }
    
    global List<Payment_Request_POP_Transactions__c> start(Database.BatchableContext BC) {
        List <Payment_Request_POP_Transactions__c> txnList = new List <Payment_Request_POP_Transactions__c> ();
        txnList = [Select Id,Status__c,Payment_Request__c,P2PRequestId__c 
                   from Payment_Request_POP_Transactions__c 
                   where Id =: txnId];
        this.prId = txnList[0].Payment_Request__c;
        return txnList;
    }
    
    global void execute(Database.BatchableContext BC, List<Payment_Request_POP_Transactions__c> txnList) {
        Payment_Request_POP_Transactions__c t = txnList[0];
        if(t.Status__c != 'AUTHORIZED' && t.Status__c != 'FAILED'){
            string response = EzetapIntegrationStatusCallout.sendRequest(String.valueOf(t.P2PRequestId__c));
            this.rawResponse = response;
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(responseMap.containsKey('status')){
                this.status = (responseMap.get('status')!=null)?String.valueOf(responseMap.get('status')):'';
            }
            if(responseMap.containsKey('errorMessage')){
                this.remarks = (responseMap.get('errorMessage')!=null)?String.valueOf(responseMap.get('errorMessage')):'';
            }
            if(responseMap.containsKey('messageCode')){
                string messageCode = (responseMap.get('messageCode')!=null)?String.valueOf(responseMap.get('messageCode')):'';
                this.msgCode = messageCode;
                if(messageCode.contains('CANCELED')){
                    this.status = 'CANCELED';
                    InitiateEztapController.deleteScheduledJobs(t.P2PRequestId__c);
                }
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        Payment_Request_POP_Transactions__c t = new Payment_Request_POP_Transactions__c(Id=txnId);
        Map<String, Object> responseMap = new Map<String, Object>();
        if(status != '')
            t.Status__c = status;
        if(remarks != '')
            t.errorMessage__c = remarks;
        if(msgCode != '')
            t.Message_Code__c = msgCode;
        if(rawResponse != ''){
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(rawResponse);
            if(rawResponse!=null)
                t.Raw_Response__c = String.valueOf(rawResponse);
            if(responseMap.containsKey('amount'))
                t.amount__c = (responseMap.get('amount')!=null)?String.valueOf(responseMap.get('amount')):'';
            if(responseMap.containsKey('cardLastFourDigit'))
                t.cardLastFourDigit__c = (responseMap.get('cardLastFourDigit')!=null)?String.valueOf(responseMap.get('cardLastFourDigit')):'';
            if(responseMap.containsKey('customerName'))
                t.customerName__c = (responseMap.get('customerName')!=null)?String.valueOf(responseMap.get('customerName')):'';
            if(responseMap.containsKey('mid'))
                t.mid__c = (responseMap.get('mid')!=null)?String.valueOf(responseMap.get('mid')):'';
            if(responseMap.containsKey('orderNumber'))
                t.orderNumber__c = (responseMap.get('orderNumber')!=null)?String.valueOf(responseMap.get('orderNumber')):'';
            if(responseMap.containsKey('rrNumber'))
                t.rrNumber__c = (responseMap.get('rrNumber')!=null)?String.valueOf(responseMap.get('rrNumber')):'';
            if(responseMap.containsKey('sessionKey'))
                t.sessionKey__c = (responseMap.get('sessionKey')!=null)?String.valueOf(responseMap.get('sessionKey')):'';
            if(responseMap.containsKey('txnId'))
                t.txnId__c = (responseMap.get('txnId')!=null)?String.valueOf(responseMap.get('txnId')):'';
            if(responseMap.containsKey('username'))
                t.username__c = (responseMap.get('username')!=null)?String.valueOf(responseMap.get('username')):'';
            if(responseMap.containsKey('formattedPan'))
                t.formattedPan__c = (responseMap.get('formattedPan')!=null)?String.valueOf(responseMap.get('formattedPan')):'';
            if(responseMap.containsKey('cardType'))
                t.cardType__c = (responseMap.get('cardType')!=null)?String.valueOf(responseMap.get('cardType')):'';
            if(responseMap.containsKey('paymentCardType'))
                t.paymentCardType__c = (responseMap.get('paymentCardType')!=null)?String.valueOf(responseMap.get('paymentCardType')):'';
            if(responseMap.containsKey('pgInvoiceNumber'))
                t.pgInvoiceNumber__c = (responseMap.get('pgInvoiceNumber')!=null)?String.valueOf(responseMap.get('pgInvoiceNumber')):'';
            if(responseMap.containsKey('tid'))
                t.tid__c = (responseMap.get('tid')!=null)?String.valueOf(responseMap.get('tid')):'';
            if(responseMap.containsKey('receiptUrl'))
                t.receiptUrl__c = (responseMap.get('receiptUrl')!=null)?String.valueOf(responseMap.get('receiptUrl')):'';
            if(responseMap.containsKey('acquirerCode'))
                t.acquirerCode__c = (responseMap.get('acquirerCode')!=null)?String.valueOf(responseMap.get('acquirerCode')):'';
            if(responseMap.containsKey('reverseReferenceNumber'))
                t.reverseReferenceNumber__c = (responseMap.get('reverseReferenceNumber')!=null)?String.valueOf(responseMap.get('reverseReferenceNumber')):'';
            if(responseMap.containsKey('invoiceNumber'))
                t.invoiceNumber__c = (responseMap.get('invoiceNumber')!=null)?String.valueOf(responseMap.get('invoiceNumber')):'';
        }
        update t;
        Payment_Request__c pr = new Payment_Request__c(Id=prId);
        if(status != ''){
            pr.Last_POP_Transaction_Status__c = status;
            if(status == 'AUTHORIZED'){
                pr.Status__c = 'Approved';
                if(responseMap.containsKey('authCode'))
                    pr.Instrument_Number__c = (responseMap.get('authCode')!=null)?String.valueOf(responseMap.get('authCode')):'';
                if(responseMap.containsKey('chargeSlipDate')){
                    string shipDate = (responseMap.get('chargeSlipDate')!=null)?String.valueOf(responseMap.get('chargeSlipDate')):'';
                    if(shipDate!=''){
                        shipDate = shipDate.split('T')[0];
                        pr.Instrument_Date__c = Date.valueOf(shipDate);
                    }
                }
            }
            update pr;
        }
    }
}