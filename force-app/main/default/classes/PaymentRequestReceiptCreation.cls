global class PaymentRequestReceiptCreation implements Database.Batchable<sObject>, Database.Stateful{
    global list<string> receiptIdList =  new List<string>();
    global list<string> finishreceiptIdList =  new List<string>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name,Status__c,Remarks__c,Date_of_Initiation__c,Original_Amount__c,Currency__c,Booking__c,Booking__r.unit__c,Booking__r.quotation__c,Amount__c,Amount_Towards__c,';
        query += 'Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Total_Interest_Till_Date__c,Booking__r.VAT_On_Interest_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,Mortgage_Value__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Booking__c != null and Status__c =\'Approved\' and ((Mode__c!= \'International Wire Transfer\' and Mode__c!= \'CDM Cash\' and mode__c != \'Domestic Wire Transfer\' and Approved_Date_and_Time__c >= LAST_N_DAYS:5 ) or (mode__c = \'International Wire Transfer\' or mode__c=\'Domestic Wire Transfer\' or mode__c=\'CDM Cash\'))and Receipt_Created__c = false and Approved_Date_and_Time__c != null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Payment_Request__c> prList) {
        try{
            System.debug('i am prList - '+prList);
            Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
            Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
            Account_Master__c interestMaster = [Select Id, Name From Account_Master__c Where Name = 'Interest Charges' LIMIT 1];
            string curr = '';
            string originalAmt = '';
            Map<Id,Payment_Request__c> mapIdToPr = new Map<Id,Payment_Request__c>();
            List<Receipt__c> receiptToInsert = new List<Receipt__c>();
            List<Demand__c> demandToInsert = new List<Demand__c>();
            for(Payment_Request__c pr : prList){
                Date paymentRequestDate = date.newinstance(pr.CreatedDate.year(),pr.CreatedDate.month(),pr.CreatedDate.day());
                Date approvalDate;
                if(pr.Approved_Date_and_Time__c != null){
                    approvalDate = date.newInstance(pr.Approved_Date_and_Time__c.year(), pr.Approved_Date_and_Time__c.month(), pr.Approved_Date_and_Time__c.day());
                }
                String instrumentno;
                String mode = '';
                curr = '';
                originalAmt = '';
                if(pr.Original_Amount__c != null && pr.Original_Amount__c != ''){
                    originalAmt = pr.Original_Amount__c;
                }
                if(pr.Mode__c == 'CDM Cheque'){
                    mode = 'CDM-cheque';
                    curr = pr.Currency__c;
                }else if(pr.Mode__c == 'CDM Cash'){
                    mode = 'CDM-cash';
                    curr = pr.Currency__c;
                }else if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'
                ){//SOB-403
                    mode = 'Wire Transfer';
                    curr = 'AED';
                }else if(pr.Mode__c == 'Credit Card'){
                    mode = 'Credit Card';
                    curr = pr.Currency__c;
                }else if(pr.Mode__c == 'OTC Deposits'){
                    mode = 'Cash';  
                    curr = pr.Currency__c;
                }else if(pr.Mode__c == 'Cheque'){
                    mode = 'Cheque';  
                    curr = pr.Currency__c;
                }else if(pr.Mode__c == 'Website'){
                    mode = 'Website'; 
                    curr = pr.Currency__c;
                }
                List<Receipt__c> receiptList = new List<Receipt__c>();
                receiptList.addAll(pr.Receipts__r);
                System.debug('i am reciptlist'+receiptList);
                if(receiptList == null && receiptList.isEmpty() ||receiptList.size() < 1 ){
                    if(pr.Amount__c != null && pr.Amount__c>0 ){
                        receiptIdList.clear();
                        if(pr.Towards_Other_Charges_Amount__c != null && pr.Towards_Other_Charges_Amount__c > 0){
                            Receipt__c receipt1 = new Receipt__c();
                            receipt1.Booking__c = pr.Booking__c;
                            receipt1.Project__c = pr.Booking__r.Project__c;
                            receipt1.Receipt_Date__c = paymentRequestDate;
                            receipt1.Registration_Collection_Control_Report__c = 0;
                            if(pr.Others__c == 'Title Deed Charges' || pr.Others__c == 'Plot title Deed' || pr.Others__c == 'Mortgage Fees' || pr.Others__c == 'Title Deed Fees (Plots)' || pr.Others__c == 'Title Deed Fees (Units)' || pr.Others__c == 'Title Deed Fees (Villas)' || pr.Others__c == 'Pre-registration to Pre-Title deed' || pr.Others__c == 'Pre-registration to pre-title deed (completed projects)'){
                                receipt1.Registration_Collection_Control_Report__c = pr.Towards_Other_Charges_Amount__c;
                            }
                            receipt1.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                            receipt1.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                            if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'){//SOB-403
                                receipt1.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                            }
                            receipt1.Receipt_Status__c = pr.Mode__c == 'OTC Deposits' || pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer'  || pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                            receipt1.Total_Amount__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Amount_Rs__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Currency__c = curr;
                            receipt1.Mode__c = mode;
                            receipt1.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt1.Project_Unit__c = pr.Unit__c;
                            receipt1.Credit_Account__c = pr.Mode__c == 'OTC Deposits' || pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'? tradeId.id:null;
                            receipt1.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? pr.Account_Master__c:null;
                            receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits' ? approvalDate != null ? approvalDate : null : pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash' ? pr.Account_Received_Date__c : null;
                            receipt1.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+ pr.Booking__r.Unit__r.Name+' against Other Charges '+pr.Towards_Other_Charges_Amount__c; 
                            receipt1.Other_Charges_Type__c = pr.Others__c;
                            receipt1.Credit_Card_Charges__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED') && originalAmt.contains(' ')){
                                receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt1);
                        }
                        if(pr.Towards_Pre_Registration_Amount__c != null && pr.Towards_Pre_Registration_Amount__c > 0){
                            Receipt__c receipt2 = new Receipt__c();
                            receipt2.Booking__c = pr.Booking__c;
                            receipt2.Project__c = pr.Booking__r.Project__c;
                            receipt2.Receipt_Date__c = paymentRequestDate;
                            receipt2.Registration_Collection_Control_Report__c = 0;
                            receipt2.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                            receipt2.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                            if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'){
                                receipt2.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                            }
                            receipt2.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash' ?'Cleared':'UnProcessed';
                            receipt2.Total_Amount__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Amount_Rs__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Currency__c = curr;
                            receipt2.Mode__c = mode;
                            receipt2.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt2.Project_Unit__c = pr.Unit__c;
                            receipt2.Credit_Account__c = pr.Mode__c == 'OTC Deposits'|| pr.Mode__c == 'International Wire Transfer'|| pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'? tradeId.id:null;
                            receipt2.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'?pr.Account_Master__c:null;
                            receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null ? approvalDate : null : pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'? pr.Account_Received_Date__c : null;
                            receipt2.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+ pr.Booking__r.Unit__r.Name+' against Pre Registration '+pr.Towards_Pre_Registration_Amount__c; 
                            receipt2.Registration_Collection_Control_Report__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED') && originalAmt.contains(' ')){
                                receipt2.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt2.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt2);
                            System.debug('I am gldate'+receipt2.GL_Date__c);
                        }
                        if(pr.Towards_Unit_Price_Amount__c != null && pr.Towards_Unit_Price_Amount__c > 0){
                            Receipt__c receipt3 = new Receipt__c();
                            receipt3.Booking__c = pr.Booking__c;
                            receipt3.Project__c = pr.Booking__r.Project__c;
                            receipt3.Receipt_Date__c = paymentRequestDate;
                            receipt3.Registration_Collection_Control_Report__c = 0;
                            receipt3.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                            receipt3.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                            if(pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'){//SOB-403
                                receipt3.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                            }
                            receipt3.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'  ||pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 added cdm cash condition
                            receipt3.Total_Amount__c = pr.Towards_Unit_Price_Amount__c;
                            receipt3.Amount_Rs__c = pr.Towards_Unit_Price_Amount__c;
                            receipt3.Currency__c = curr;
                            receipt3.Mode__c = mode;
                            receipt3.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt3.Project_Unit__c = pr.Unit__c;
                            receipt3.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? tradeId.id:null;
                            receipt3.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'?pr.Account_Master__c:null;//SOB-403 added cdm cash condition
                            receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? pr.Account_Received_Date__c : null;//SOB-403 added cdm cash condition
                            receipt3.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+ pr.Booking__r.Unit__r.Name+' against Unit Price '+pr.Towards_Unit_Price_Amount__c; 
                            receipt3.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED') && originalAmt.contains(' ')){
                                receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt3);
                            
                            System.debug('I am gldate'+receipt3.GL_Date__c);
                            
                        }
                        mapIdToPr.put(pr.id, pr);
                    }
                }
            } 
            List<Database.SaveResult> results = Database.insert(receiptToInsert, false);
            Set<Id> receiptIdsWithSucess = new Set<Id>();
            integer i = 0;
            String sError = '';
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()){
                Receipt__c r = receiptToInsert[i];
                String msg = '';
                for (Database.Error err: result.getErrors()) {
                        msg = 'Receipt Insert Failed :' + err.getMessage();
                }
                payment_request__c pr = mapIdToPr.get(r.Payment_Request__c);
                pr.Receipt_Created__c = false;
                pr.Receipt_Creation_Error_Log__c = msg;
                mapIdToPr.put(r.Payment_Request__c,pr);    
                sError += msg + ' for payment request - '+pr.id;
                    
                }else{
                    receiptIdsWithSucess.add(result.getId());
                }
                i++;
            }
            if(sError != ''){
                SendEmailForReceiptError.sendEmailMessage(sError);
            }
            for(Receipt__c r :[SELECT ID,Payment_Request__c FROM Receipt__c WHERE ID IN : receiptIdsWithSucess]){
                payment_request__c pr = mapIdToPr.get(r.Payment_Request__c);
                pr.Receipt_Created__c = true;
                pr.Receipt_creation_error_log__c = null;
                mapIdToPr.put(r.Payment_Request__c,pr);
                finishreceiptIdList.add(r.id);
            } 
            update mapIdToPr.values();
        }catch(Exception ex){
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'PaymentRequestReceiptCreation';
            insert logError;
            System.debug('Hi I am in catch block');
            String sMessage = '';
            sMessage += 'ERROR: ' + 'An exception has occurred while creating receipt -- '+ ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString();
            SendEmailForReceiptError.sendEmailMessage(sMessage);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(finishreceiptIdList != null && finishreceiptIdList.size() > 0){
            ID jobID = System.enqueueJob(new PaymentRequestReceiptQueueable(finishreceiptIdList)); 
        }
    }
}