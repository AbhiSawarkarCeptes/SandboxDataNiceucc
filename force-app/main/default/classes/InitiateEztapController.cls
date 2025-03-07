public without sharing class InitiateEztapController {
    @AuraEnabled
    public static list<Eztap_Device__mdt> getAllEztapDevices(){
        return [select Id, MasterLabel, DeveloperName, Device_Id__c, Location__c, Username__c 
                from Eztap_Device__mdt 
                Order By MasterLabel ASC];
    }
    
    @AuraEnabled
    public static string checkExistingRequest(string prId) {
        Payment_Request__c pr = [select Id, 
                                 Name, 
                                 Amount__c,
                                 Last_POP_Transaction_Status__c
                                 from Payment_Request__c 
                                 where Id =: prId];
        
        if (pr.Last_POP_Transaction_Status__c == 'INITIATED') {
            return 'INITIATED';
        } 
        else if (pr.Last_POP_Transaction_Status__c == 'AUTHORIZED') {
            return 'AUTHORIZED';
        }
        else{
            return 'CONTINUE';
        }
    }
    
    @AuraEnabled
    public static string startEztap(string deviceId, string prId){
        
        String result = '';
        Eztap_Device__mdt device = [select Id, 
                                    MasterLabel, 
                                    DeveloperName, 
                                    Device_Id__c, Location__c, Username__c 
                                    from Eztap_Device__mdt 
                                    where Id =:deviceId];
        
        Payment_Request__c pr = [select Id, 
                                 Name, 
                                 Amount__c,
                                 Last_POP_Transaction_Status__c
                                 from Payment_Request__c 
                                 where Id =: prId];
        
        if (pr.Last_POP_Transaction_Status__c == 'INITIATED') {
            return 'Ezetap transaction has already been initiated. Please wait for the transaction to complete.';
        }
        if (pr.Last_POP_Transaction_Status__c == 'AUTHORIZED') {
            return 'Ezetap transaction has already been AUTHORIZED for this Payment Request.';
        }
        
        String response = EzetapIntegrationStartCallout.sendRequest(pr.Amount__c,String.valueOf(device.Device_Id__c),String.valueOf(pr.Name));
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        if(responseMap.containsKey('success')){
            if(responseMap.get('success') == true){
                result = 'Ezetap transaction has been successfully initiated.';
                string p2pRequestId = (responseMap.containsKey('p2pRequestId'))?string.valueOf(responseMap.get('p2pRequestId')):'';
                InitiateEztapController.createPOPTransactions(prId,p2pRequestId,response);
            }
            else{
                if(responseMap.containsKey('message')){
                    result = string.valueOf(responseMap.get('message'));
                }
                else{
                    result = 'Ezetap transaction failed.';
                }
            }
        }
        else{
            result = String.valueOf(response);
        }
        return result;
    }
    
    @AuraEnabled
    public static string eztapCancelTransaction(string prId){
        string res = '';
        List<Payment_Request_POP_Transactions__c> txns = [select Id,P2PRequestId__c 
                                                          from Payment_Request_POP_Transactions__c 
                                                          where Payment_Request__c =: prId 
                                                          order by createddate desc limit 1];
        if(txns.size() > 0 && txns[0].P2PRequestId__c != null){
            string response = EzetapIntegrationCancelCallout.sendRequest(String.valueOf(txns[0].P2PRequestId__c));
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(responseMap.containsKey('success')){
                res = (responseMap.get('success')==true)?'SUCCESS# ':'FAILURE# ';
            }
            else{
                res = 'FAILURE# ';
            }
            if(responseMap.containsKey('message')){
                res += (responseMap.get('message')!=null)?String.valueOf(responseMap.get('message')):'';
            }
            string status,remarks;
            status = res.split('#')[0];
            remarks = res.split('#')[1];
            
            Payment_Request_POP_Transactions__c t = new Payment_Request_POP_Transactions__c(Id=txns[0].Id);
            if(status == 'SUCCESS')
                t.Status__c = 'CANCELED';
            if(remarks != '')
                t.errorMessage__c = remarks;
            update t;
            
            Payment_Request__c pr = new Payment_Request__c(Id=prId);
            if(status == 'SUCCESS'){
                pr.Last_POP_Transaction_Status__c = 'CANCELED';
                update pr;
                InitiateEztapController.deleteScheduledJobs(txns[0].P2PRequestId__c);
            }
            
        }
        return res;
    }
    
    @AuraEnabled
    public static string eztapStatusCheck(string prId){
        string res = '';
        List<Payment_Request_POP_Transactions__c> txns = [select Id,P2PRequestId__c,Payment_Request__c 
                                                          from Payment_Request_POP_Transactions__c 
                                                          where Payment_Request__c =: prId 
                                                          order by createddate desc limit 1];
        if(txns.size() > 0 && txns[0].P2PRequestId__c != null){
            string response = EzetapIntegrationStatusCallout.sendRequest(String.valueOf(txns[0].P2PRequestId__c));
            system.debug('VVK Hello: '+response);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(responseMap.containsKey('status')){
                res = (responseMap.get('status')!=null)?String.valueOf(responseMap.get('status'))+'#':'INITIATED#';
            }
            else if(responseMap.containsKey('messageCode') && responseMap.get('messageCode')!=null){
                string mCode = String.valueOf(responseMap.get('messageCode'));
                res = (mCode.contains('CANCELED'))?'CANCELED#':'INITIATED#';
            }
            else{
                res = 'INITIATED#';
            }
            if(responseMap.containsKey('errorMessage')){
                res += (responseMap.get('errorMessage')!=null)?String.valueOf(responseMap.get('errorMessage'))+'#':'#';
            }
            else{
                res += '#';
            }
            if(responseMap.containsKey('messageCode')){
                res += (responseMap.get('messageCode')!=null)?String.valueOf(responseMap.get('messageCode')):'';
            }
            
            string status,remarks,msgCode;
            status = res.split('#')[0];
            remarks = res.split('#')[1];
            msgCode = res.split('#')[2];
            
            Payment_Request_POP_Transactions__c t = new Payment_Request_POP_Transactions__c(Id=txns[0].Id);
            if(status != '')
                t.Status__c = status;
            if(remarks != '')
                t.errorMessage__c = remarks;
            if(msgCode != '')
                t.Message_Code__c = msgCode;
            if(response!=null)
                t.Raw_Response__c = String.valueOf(response);
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
            if(responseMap.containsKey('messageCode')){
                string messageCode = (responseMap.get('messageCode')!=null)?String.valueOf(responseMap.get('messageCode')):'';
                if(messageCode.contains('CANCELED')){
                    t.Status__c = 'CANCELED';
                }
            }
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
                if(responseMap.containsKey('messageCode')){
                    string messageCode = (responseMap.get('messageCode')!=null)?String.valueOf(responseMap.get('messageCode')):'';
                    if(messageCode.contains('CANCELED')){
                        pr.Last_POP_Transaction_Status__c = 'CANCELED';
                        InitiateEztapController.deleteScheduledJobs(txns[0].P2PRequestId__c);
                    }
                }
                update pr;
            }
            
        }
        return res;
    }
    
    @future
    public static void createPOPTransactions(string prId, string p2pRequestId, string rawResponse){
        Payment_Request_POP_Transactions__c t = new Payment_Request_POP_Transactions__c();
        t.Payment_Request__c = prId;
        t.P2PRequestId__c = p2pRequestId;
        t.Status__c = 'INITIATED';
        t.Raw_Response__c = String.valueOf(rawResponse);
        insert t;
        
        Payment_Request__c pr = new Payment_Request__c(Id=prId,Last_POP_Transaction_Status__c='INITIATED');
        update pr;
        
        for(integer i=1;i<=5;i++){
            Datetime nextRun = System.now().addMinutes(i*2);
            //Generating cron expression for next run time
            String year = String.valueOf(nextRun.year());
            String day = String.valueOf(nextRun.day());
            String hour = String.valueOf(nextRun.hour());
            String min = String.valueOf(nextRun.minute());
            String sec = String.valueOf(nextRun.second());
            String cronExp = sec + ' ' + min + ' ' + hour + ' '+day+' '+nextRun.format('MMM').toUpperCase()+' ? '+year;
            //Scheduling at the specified time
            EztapStatusCheckSchedular trackerJob = new EztapStatusCheckSchedular(t.Id);
            System.schedule('Ezetap Tracker'+i+' for '+p2pRequestId, cronExp, trackerJob);
        }
    }
    
    public static void deleteScheduledJobs(string p2PRequestId){
        string jobName = '%'+p2PRequestId+'%';
        List<CronTrigger> cronList = [select id, CronJobDetail.Name from CronTrigger Where CronJobDetail.Name Like : jobName];
        for(CronTrigger job:cronList){
            System.abortJob(job.id);
        }
    }
    
}