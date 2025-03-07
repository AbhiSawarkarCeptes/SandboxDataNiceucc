global class ReceiptEmailBatchOneTime implements Database.Batchable<sObject>, Database.Stateful{
    global list<string> receiptIdList =  new List<string>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Approval_Status__c,Payment_Request__r.Date_of_Initiation__c,Payment_Request__r.Currency__c,Payment_Request__r.Original_Amount__c,Booking__c,DP_Amount_2__c,DLD_Amount_2__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Request__r.Payment_Transaction_Tracking_Id__c,Payment_Request__r.Account_Received_Date__c,Payment_Request__r.Approved_Date_and_Time__c,Payment_Request__r.Account_Master__c,Payment_Request__r.Instrument_Date__c,Payment_Request__r.Instrument_Number__c,Payment_Request__r.Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Request__r.Payment_Transaction_Number__c,Payment_Request__r.CreatedDate,Payment_Request__r.Unit__c,DLD_Amount__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__c,Payment_Request__r.Mode__c,DP_Amount__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c WHERE Booking__c != null and Approval_Status__c =\'Approved\' and Receipt_Created__c = false';
        return Database.getQueryLocator(query);
    }
	
    global void execute(Database.BatchableContext BC, List<unit_hold_request__c> newSaleList) {
        System.debug('i am newsaleList'+newSaleList);
        Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
        Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
       SysteM.Debug('I am mainchashid:'+maincashid.Id);
        SysteM.Debug('I am tradeid:'+tradeId.Id);
        string curr = '';
        string originalAmt = '';
        for(unit_hold_request__c newSale : newSaleList){
             Date paymentRequestDate = date.newinstance(newSale.Payment_Request__r.CreatedDate.year(),newSale.Payment_Request__r.CreatedDate.month(),newSale.Payment_Request__r.CreatedDate.day());
            Date approvalDate;
            if(newSale.Payment_Request__r.Approved_Date_and_Time__c != null){
             	approvalDate = date.newInstance(newSale.Payment_Request__r.Approved_Date_and_Time__c.year(), newSale.Payment_Request__r.Approved_Date_and_Time__c.month(), newSale.Payment_Request__r.Approved_Date_and_Time__c.day());
            } 
            String instrumentno;
            curr = '';
            originalAmt = '';
            if(newSale.Payment_Request__r.Original_Amount__c != null && newSale.Payment_Request__r.Original_Amount__c != ''){
                originalAmt = newSale.Payment_Request__r.Original_Amount__c;
            }
            //Double totalAmount = newSale.DP_Amount__c + newSale.DLD_Amount__c;
            String mode = '';
            if(newSale.Payment_Request__r.Mode__c == 'CDM Cheque'){
                mode = 'CDM-cheque';
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'CDM Cash'){
                mode = 'CDM-cash';
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'){
                 mode = 'Wire Transfer';
                curr = 'AED';
            }else if(newSale.Payment_Request__r.Mode__c == 'Credit Card'){
                 mode = 'Credit Card';
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'OTC Deposits'){
                 mode = 'Cash';       
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'Cheque'){
                 mode = 'Cheque';   
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'Website'){
                 mode = 'Website';  
                curr = newSale.Payment_Request__r.Currency__c;
            }
            List<Receipt__c> receiptList = new List<Receipt__c>();
            receiptList.addAll(newSale.Receipts__r);
            System.debug('i am reciptlist'+receiptList);
            if(receiptList == null && receiptList.isEmpty() ||receiptList.size() < 1 ){
                if(newSale.DP_Amount__c != null && newSale.DP_Amount__c>0 ){
                    Receipt__c receipt = new Receipt__c();
                	receipt.Booking__c = newSale.Booking__c;
                    receipt.Project__c = newsale.Booking__r.Project__c;
                	receipt.Receipt_Date__c = paymentRequestDate;
                	receipt.Registration_Collection_Control_Report__c = 0;
                	receipt.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                	receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'){
                        receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                	receipt.Total_Amount__c = newSale.DP_Amount__c;
                    receipt.Amount_Rs__c = newSale.DP_Amount__c;
                	receipt.Mode__c = mode;
                    receipt.Currency__c = curr;
                    receipt.Opportunity__c =newSale.Booking__r.Opportunity__c;
                	receipt.New_Sale_Approval__c =newSale.Id;
                    receipt.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                    receipt.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        					 newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount__c; 
                    receipt.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                	insert receipt;
                   
                    system.debug('I am gldate'+receipt.GL_Date__c);
                    receiptIdList.add(receipt.Id);
                }
                if(newSale.DLD_Amount__c != null && newSale.DLD_Amount__c > 0){
                    Receipt__c receipt1 = new Receipt__c();
                	receipt1.Booking__c = newSale.Booking__c;
                    receipt1.Project__c = newsale.Booking__r.Project__c;
                	receipt1.Receipt_Date__c = paymentRequestDate;
                	receipt1.Registration_Collection_Control_Report__c = newSale.DLD_Amount__c;
                	receipt1.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                	receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                	if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'){
                        receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt1.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c =='International Wire Transfer'?'Cleared':'UnProcessed';
                	receipt1.Total_Amount__c = newSale.DLD_Amount__c;
                    receipt1.Amount_Rs__c = newSale.DLD_Amount__c;
                    receipt1.Opportunity__c =newSale.Booking__r.Opportunity__c;
                	receipt1.Mode__c = mode;
                    receipt1.Currency__c = curr;
                	receipt1.New_Sale_Approval__c =newSale.Id;
                    receipt1.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt1.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                    receipt1.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt1.GL_Date__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt1.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
					newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount__c;  
                    receipt1.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                	insert receipt1; system.debug('I am gldate1'+receipt1.GL_Date__c);
                    
                    receiptIdList.add(receipt1.Id);
                }
                if(newSale.DP_Amount_2__c != null && newSale.DP_Amount_2__c>0 ){
                    Receipt__c receipt3 = new Receipt__c();
                	receipt3.Booking__c = newSale.Booking__c;
                    receipt3.Project__c = newsale.Booking__r.Project__c;
                	receipt3.Receipt_Date__c = paymentRequestDate;
                	receipt3.Registration_Collection_Control_Report__c = 0;
                	receipt3.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                	receipt3.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                	if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'){
                        receipt3.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt3.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                	receipt3.Total_Amount__c = newSale.DP_Amount_2__c;
                    receipt3.Amount_Rs__c = newSale.DP_Amount_2__c;
                	receipt3.Mode__c = mode;
                    receipt3.Currency__c = curr;
                    receipt3.Opportunity__c =newSale.Booking__r.Opportunity__c;
                	receipt3.New_Sale_Approval__c =newSale.Id;
                    receipt3.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt3.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                    receipt3.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt3.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt3.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        					 newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount__c;  
                     receipt3.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                	insert receipt3; system.debug('I am gldate2'+receipt3.GL_Date__c);
                    receiptIdList.add(receipt3.Id);
                }
                if(newSale.DLD_Amount_2__c != null && newSale.DLD_Amount_2__c > 0){
                    Receipt__c receipt4 = new Receipt__c();
                	receipt4.Booking__c = newSale.Booking__c;
                    receipt4.Project__c = newsale.Booking__r.Project__c;
                	receipt4.Receipt_Date__c = paymentRequestDate;
                	receipt4.Registration_Collection_Control_Report__c = newSale.DLD_Amount_2__c;
                	receipt4.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                	receipt4.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                	if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'){
                        receipt4.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt4.Receipt_Status__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?'Cleared':'UnProcessed';
                	receipt4.Total_Amount__c = newSale.DLD_Amount_2__c;
                    receipt4.Amount_Rs__c = newSale.DLD_Amount_2__c;
                    receipt4.Opportunity__c =newSale.Booking__r.Opportunity__c;
                	receipt4.Mode__c = mode;
                    receipt4.Currency__c = curr;
                	receipt4.New_Sale_Approval__c =newSale.Id;
                    receipt4.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt4.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? tradeId.id:null;
                    receipt4.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt4.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt4.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        					 newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount__c; 
                     receipt4.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt4.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt4.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                	insert receipt4;
                    receiptIdList.add(receipt4.Id);
                }
                if(receiptIdList != null && receiptIdList.size()>0){
                    newSale.Receipt_Created__c = true;
                    update newSale;
                }
            }
        }   
    }
     global void finish(Database.BatchableContext BC) {
         System.debug('i am in finish receptlist'+receiptIdList);
         List<Receipt__c> receipts = [SELECT name,id,Project_Unit__r.Name,Total_Amount__c,Receipt_No__c,New_Sale_Approval__c,
                             Currency__c,Booking__r.Tower__c,Booking__r.Name,Booking__r.Primary_Applicant_Name__c,
                             New_Sale_Approval__r.Owner.email,New_Sale_Approval__r.Payment_Request__r.Name__c,
                             New_Sale_Approval__r.Payment_Request__r.Email__c,GL_Date__c,Project__c,Payment_Request__c,
                             Booking__r.Primary_Applicant_Email__c,Booking__r.Sales_Head__c,
                             Booking__r.Secondary_Sales_Manager_VP__c,Booking__r.Sales_Head__r.Manager.Email,
                             Booking__r.Secondary_Sales_Head__r.Manager.Email,
                       		 Booking__r.Secondary_Sales_Manager_VP__r.email,Booking__r.Sales_Head__r.email,
                             Booking__r.Sales_Managers__r.email,Booking__r.Secondary_Sales_Manager__r.email,
                             Booking__r.Secondary_Sales_Head__r.email
                             FROM Receipt__c 
                             WHERE Id IN : receiptIdList];
         System.debug('i am in finish'+receipts);
         ReceiptEmailController.sendAttachedReceiptbatch(receipts);
         /*for(Receipt__c r : receipts){
             System.debug('i am in finish receptglcheck'+r);
             ReceiptEmailController.sendAttachedReceipt1(r);
         }*/
    }
}