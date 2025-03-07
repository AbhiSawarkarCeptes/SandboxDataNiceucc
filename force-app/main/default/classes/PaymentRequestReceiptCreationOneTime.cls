global class PaymentRequestReceiptCreationOneTime implements Database.Batchable<sObject>, Database.Stateful{
    global list<string> receiptIdList =  new List<string>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Status__c,Date_of_Initiation__c,Original_Amount__c,Currency__c,Booking__c,Amount__c,Amount_Towards__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Booking__c != null and Status__c =\'Approved\' and Receipt_Created__c = false';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Payment_Request__c> prList) {
        System.debug('i am prList'+prList);
        Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
        Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
        SysteM.Debug('I am mainchashid:'+maincashid.Id);
        SysteM.Debug('I am tradeid:'+tradeId.Id);
        string curr = '';
        string originalAmt = '';
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
            }else if(pr.Mode__c == 'International Wire Transfer'){
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
                    if(pr.Towards_Other_Charges_Amount__c != null && pr.Towards_Other_Charges_Amount__c > 0){
                        Receipt__c receipt1 = new Receipt__c();
                        receipt1.Booking__c = pr.Booking__c;
                        receipt1.Project__c = pr.Booking__r.Project__c;
                        receipt1.Receipt_Date__c = paymentRequestDate;
                        receipt1.Registration_Collection_Control_Report__c = 0;
                        receipt1.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                        receipt1.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                        if(pr.Mode__c == 'International Wire Transfer'){
                            receipt1.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                        }
                        receipt1.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                        receipt1.Total_Amount__c = pr.Towards_Other_Charges_Amount__c;
                        receipt1.Amount_Rs__c = pr.Towards_Other_Charges_Amount__c;
                        receipt1.Currency__c = curr;
                        receipt1.Mode__c = mode;
                        receipt1.Opportunity__c =pr.Booking__r.Opportunity__c;
                        receipt1.Project_Unit__c = pr.Unit__c;
                        receipt1.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                        receipt1.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'?pr.Account_Master__c:null;
                        //receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                        receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? approvalDate : null;
                        receipt1.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                            pr.Booking__r.Unit__r.Name+' against Other Charges '+pr.Towards_Other_Charges_Amount__c; 
                        receipt1.Other_Charges_Type__c = pr.Others__c;
                        receipt1.Credit_Card_Charges__c = pr.Towards_Other_Charges_Amount__c;
                        receipt1.Payment_Request__c = pr.id;
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                        insert receipt1;
                        system.debug('I am gldate'+receipt1.GL_Date__c);
                        receiptIdList.add(receipt1.Id);
                    }
                    if(pr.Towards_Pre_Registration_Amount__c != null && pr.Towards_Pre_Registration_Amount__c > 0){
                        Receipt__c receipt2 = new Receipt__c();
                        receipt2.Booking__c = pr.Booking__c;
                        receipt2.Project__c = pr.Booking__r.Project__c;
                        receipt2.Receipt_Date__c = paymentRequestDate;
                        receipt2.Registration_Collection_Control_Report__c = 0;
                        receipt2.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                        receipt2.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                        if(pr.Mode__c == 'International Wire Transfer'){
                            receipt2.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                        }
                        receipt2.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                        receipt2.Total_Amount__c = pr.Towards_Pre_Registration_Amount__c;
                        receipt2.Amount_Rs__c = pr.Towards_Pre_Registration_Amount__c;
                        receipt2.Currency__c = curr;
                        receipt2.Mode__c = mode;
                        receipt2.Opportunity__c =pr.Booking__r.Opportunity__c;
                        receipt2.Project_Unit__c = pr.Unit__c;
                        receipt2.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                        receipt2.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'?pr.Account_Master__c:null;
                        //receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                        receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? approvalDate : null;
                        receipt2.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                            pr.Booking__r.Unit__r.Name+' against Pre Registration '+pr.Towards_Pre_Registration_Amount__c; 
                        receipt2.Registration_Collection_Control_Report__c = pr.Towards_Pre_Registration_Amount__c;
                        receipt2.Payment_Request__c = pr.id;
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt2.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt2.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                        insert receipt2;
                        system.debug('I am gldate'+receipt2.GL_Date__c);
                        receiptIdList.add(receipt2.Id);
                    }
                    if(pr.Towards_Unit_Price_Amount__c != null && pr.Towards_Unit_Price_Amount__c > 0){
                        Receipt__c receipt3 = new Receipt__c();
                        receipt3.Booking__c = pr.Booking__c;
                        receipt3.Project__c = pr.Booking__r.Project__c;
                        receipt3.Receipt_Date__c = paymentRequestDate;
                        receipt3.Registration_Collection_Control_Report__c = 0;
                        receipt3.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                        receipt3.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                        if(pr.Mode__c == 'International Wire Transfer'){
                            receipt3.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                        }
                        receipt3.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                        receipt3.Total_Amount__c = pr.Towards_Unit_Price_Amount__c;
                        receipt3.Amount_Rs__c = pr.Towards_Unit_Price_Amount__c;
                        receipt3.Currency__c = curr;
                        receipt3.Mode__c = mode;
                        receipt3.Opportunity__c =pr.Booking__r.Opportunity__c;
                        receipt3.Project_Unit__c = pr.Unit__c;
                        receipt3.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                        receipt3.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'?pr.Account_Master__c:null;
                        //receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                        receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? approvalDate : null;
                        receipt3.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                            pr.Booking__r.Unit__r.Name+' against Unit Price '+pr.Towards_Unit_Price_Amount__c; 
                        //receipt3.Registration_Collection_Control_Report__c = pr.Towards_Unit_Price_Amount__c;
                        //receipt3.Credit_Card_Charges__c = pr.Towards_Unit_Price_Amount__c;
                        receipt3.Payment_Request__c = pr.id;
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                        insert receipt3;
                        system.debug('I am gldate'+receipt3.GL_Date__c);
                        receiptIdList.add(receipt3.Id);
                    }
                }
            }
            if(receiptIdList != null && receiptIdList.size()>0){
                pr.Receipt_Created__c = true;
                update pr;
            }
        } 
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('i am in finish receptlist'+receiptIdList);
        List<Receipt__c> receipts = [SELECT name,id,Project_Unit__r.Name,Total_Amount__c,Receipt_No__c,
                                     Currency__c,Booking__r.Tower__c,Booking__r.Name,Booking__r.Primary_Applicant_Name__c,
                                     Payment_Request__r.Owner.email,Payment_Request__r.Name__c,
                                     Payment_Request__r.Email__c,GL_Date__c,Project__c,Payment_Request__c,
                                     Booking__r.Primary_Applicant_Email__c,Booking__r.Sales_Head__c,
                                     Booking__r.Secondary_Sales_Manager_VP__c,Booking__r.Sales_Head__r.Manager.Email,
                                     Booking__r.Secondary_Sales_Head__r.Manager.Email,
                                     Booking__r.Secondary_Sales_Manager_VP__r.email,Booking__r.Sales_Head__r.email,
                                     Booking__r.Sales_Managers__r.email,Booking__r.Secondary_Sales_Manager__r.email,
                                     Booking__r.Secondary_Sales_Head__r.email
                                     FROM Receipt__c 
                                     WHERE Id IN : receiptIdList];
        System.debug('i am in finish'+receipts);
        PaymentRequestReceiptEmail.sendAttachedReceiptbatch(receipts); 
    }
}