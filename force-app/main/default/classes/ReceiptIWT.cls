global class ReceiptIWT {
    @InvocableMethod
    public static void generateReceipt(List<ID> ids) {
        try{
        
        List<unit_hold_request__c> nsaList= [SELECT Id,Approval_Status__c,Payment_Request__r.Payment_Request__r.Original_Amount__c,
                                             Payment_Request__r.Date_of_Initiation__c,Payment_Request__r.Payment_Request__r.Date_of_Initiation__c,
                                             Payment_Request__r.Payment_Request__r.Currency__c,
                                             Payment_Request__r.Payment_Request__c,Payment_Request__r.Currency__c,Payment_Request__r.Original_Amount__c,
                                             Booking__c,DP_Amount_2__c,DLD_Amount_2__c,Booking__r.Unit__r.Name,Booking__r.Project__c,
                                             Payment_Request__r.Payment_Transaction_Tracking_Id__c,
                                             Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c,
                                             Payment_Request__r.Account_Received_Date__c,Payment_Request__r.Payment_Request__r.Account_Received_Date__c,
                                             Payment_Request__r.Approved_Date_and_Time__c,Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c,
                                             Payment_Request__r.Account_Master__c,Payment_Request__r.Payment_Request__r.Account_Master__c,
                                             Payment_Request__r.Instrument_Date__c,Payment_Request__r.Payment_Request__r.Instrument_Date__c,
                                             Payment_Request__r.Instrument_Number__c,Payment_Request__r.Payment_Request__r.Instrument_Number__c,
                                             Payment_Request__r.Reference_Number__c,Payment_Request__r.Payment_Request__r.Reference_Number__c,
                                             Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Request__r.Payment_Transaction_Number__c,
                                             Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c,
                                             Payment_Request__r.CreatedDate,Payment_Request__r.payment_Request__r.CreatedDate,
                                             Payment_Request__r.Unit__c,Payment_Request__r.Payment_Request__r.Unit__c,DLD_Amount__c,
                                             Payment_Request__r.Cheque_Date__c,Payment_Request__r.Payment_Request__r.Cheque_Date__c,
                                             Payment_Request__r.Cheque_No__c,Payment_Request__r.Payment_Request__r.Cheque_No__c,
                                             Payment_Request__c,Payment_Request__r.Mode__c,Payment_Request__r.Payment_Request__r.Mode__c,DP_Amount__c,Mode__c,
                                             (select id from Receipts__r)
                                             FROM unit_hold_request__c
                                             WHERE Id in :ids];
        
        List<Receipt__c> receiptIdList = new List<Receipt__c>();
        List<Receipt__c> receiptToInsert = new List<Receipt__c>();
        Map<Id,unit_hold_request__c> mapIdToNsa = new Map<Id,unit_hold_request__c>();
        
        for(unit_hold_request__c nsa : nsaList){
            Integer count = 0;
            if(nsa.DP_Amount__c != null && nsa.DP_Amount__c>0 ){count++;}
            if(nsa.DLD_Amount__c != null && nsa.DLD_Amount__c > 0){count++;}
            if(nsa.DP_Amount_2__c != null && nsa.DP_Amount_2__c>0 ){count++;}
            if(nsa.DLD_Amount_2__c != null && nsa.DLD_Amount_2__c > 0){count++;}
            
            List<Receipt__c> receiptList = new List<Receipt__c>();
            receiptList.addAll(nsa.Receipts__r);
            system.debug('I am receiptlist'+receiptList.size());
            system.debug('I am count'+count);
            if(receiptList.size() < count && (nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
            || (nsa.Payment_Request__r.Payment_Request__c != null && (nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'||
            nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')))){//SOB-403 Aayushi added CDM cash condition
                Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
                Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
                SysteM.Debug('I am mainchashid:'+maincashid.Id);
                SysteM.Debug('I am tradeid:'+tradeId.Id);
                string curr = '';
                string originalAmt = '';
                string curr1 = '';
                string originalAmt1 = '';
                Date approvalDate1;
                Date paymentRequestDate1;
                String mode1 = '';
                
                Date paymentRequestDate = date.newinstance(nsa.Payment_Request__r.CreatedDate.year(),nsa.Payment_Request__r.CreatedDate.month(),nsa.Payment_Request__r.CreatedDate.day());            
                Date approvalDate;
                if(nsa.Payment_Request__r.Approved_Date_and_Time__c != null){
                    approvalDate = date.newInstance(nsa.Payment_Request__r.Approved_Date_and_Time__c.year(), nsa.Payment_Request__r.Approved_Date_and_Time__c.month(), nsa.Payment_Request__r.Approved_Date_and_Time__c.day());
                }  
                curr = '';
                originalAmt = '';
                
                if(nsa.Payment_Request__r.Original_Amount__c != null && nsa.Payment_Request__r.Original_Amount__c != ''){
                    originalAmt = nsa.Payment_Request__r.Original_Amount__c;
                }
                String mode = '';
                
              if(nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
              || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                    mode = 'Wire Transfer';
                    curr = 'AED';
                }
                
                if(nsa.Payment_Request__r.Payment_Request__c!=null){
                    paymentRequestDate1 = date.newinstance(nsa.Payment_Request__r.payment_Request__r.CreatedDate.year(),nsa.Payment_Request__r.payment_Request__r.CreatedDate.month(),nsa.Payment_Request__r.payment_Request__r.CreatedDate.day());
                    
                    if(nsa.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c != null){
                        approvalDate1 = date.newInstance(nsa.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.year(), nsa.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.month(), nsa.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.day());
                    }
                    
                    if(nsa.Payment_Request__r.Payment_Request__r.Original_Amount__c != null && nsa.Payment_Request__r.Payment_Request__r.Original_Amount__c != ''){
                        originalAmt1 = nsa.Payment_Request__r.Payment_Request__r.Original_Amount__c;
                    }
                    
                   if(nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'
                   || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                        mode1 = 'Wire Transfer';
                        curr1 = 'AED';
                    }
                }
                if((nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash' 
                 || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')//SOB-403 Aayushi added CDM cash condition
                 && nsa.Payment_Request__r.Payment_Request__c == null){
                    if(nsa.DP_Amount__c != null && nsa.DP_Amount__c>0 ){
                        Receipt__c receipt = new Receipt__c();
                        receipt.Booking__c = nsa.Booking__c;
                        receipt.Project__c = nsa.Booking__r.Project__c;
                        receipt.Receipt_Date__c =  nsa.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                        receipt.Registration_Collection_Control_Report__c = 0;
                        receipt.Cheque_DD__c = nsa.Payment_Request__r.Mode__c == 'Website'?nsa.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(nsa.Payment_Request__r.Cheque_No__c)?String.isBlank(nsa.Payment_Request__r.Instrument_Number__c)?String.isBlank(nsa.Payment_Request__r.Reference_Number__c)?String.isBlank(nsa.Payment_Request__r.Payment_Transaction_Number__c)?'':nsa.Payment_Request__r.Payment_Transaction_Number__c:nsa.Payment_Request__r.Reference_Number__c:nsa.Payment_Request__r.Instrument_Number__c:nsa.Payment_Request__r.Cheque_No__c;
                        receipt.Cheque_DD_Date__c = nsa.Payment_Request__r.Cheque_Date__c== null ?nsa.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : nsa.Payment_Request__r.Instrument_Date__c : nsa.Payment_Request__r.Cheque_Date__c;
                        if(nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
                        || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                            receipt.Cheque_DD_Date__c = nsa.Payment_Request__r.Date_of_Initiation__c;
                        }
                        receipt.Receipt_Status__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer'  
                        || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 Aayushi added CDM cash condition
                        receipt.Total_Amount__c = nsa.DP_Amount__c;
                        receipt.Amount_Rs__c = nsa.DP_Amount__c;
                        receipt.Mode__c = mode;
                        receipt.Currency__c = curr;
                        receipt.Opportunity__c =nsa.Booking__r.Opportunity__c;
                        receipt.New_Sale_Approval__c =nsa.Id;
                        receipt.Project_Unit__c = nsa.Payment_Request__r.Unit__c;
                        receipt.Credit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash' || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 Aayushi added CDM cash condition
                        receipt.Debit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash' || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?nsa.Payment_Request__r.Account_Master__c:null;//SOB-403 Aayushi added CDM cash condition
                        receipt.GL_Date__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'|| nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? nsa.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 Aayushi added CDM cash condition
                        receipt.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                            nsa.Booking__r.Unit__r.Name+' against DP Charges '+nsa.DP_Amount__c; 
                        receipt.Payment_Request__c = nsa.Payment_Request__c;
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                        receiptToInsert.add(receipt);
                        
                        //system.debug('I am gldate'+receipt.GL_Date__c);
                        //receiptIdList.add(receipt);
                    }
                    if(nsa.DLD_Amount__c != null && nsa.DLD_Amount__c > 0){
                        Receipt__c receipt1 = new Receipt__c();
                        receipt1.Booking__c = nsa.Booking__c;
                        receipt1.Project__c = nsa.Booking__r.Project__c;
                        receipt1.Receipt_Date__c =  nsa.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                        receipt1.Registration_Collection_Control_Report__c = nsa.DLD_Amount__c;
                        receipt1.Cheque_DD__c = nsa.Payment_Request__r.Mode__c == 'Website'?nsa.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(nsa.Payment_Request__r.Cheque_No__c)?String.isBlank(nsa.Payment_Request__r.Instrument_Number__c)?String.isBlank(nsa.Payment_Request__r.Reference_Number__c)?String.isBlank(nsa.Payment_Request__r.Payment_Transaction_Number__c)?'':nsa.Payment_Request__r.Payment_Transaction_Number__c:nsa.Payment_Request__r.Reference_Number__c:nsa.Payment_Request__r.Instrument_Number__c:nsa.Payment_Request__r.Cheque_No__c;
                        receipt1.Cheque_DD_Date__c = nsa.Payment_Request__r.Cheque_Date__c== null ?nsa.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : nsa.Payment_Request__r.Instrument_Date__c : nsa.Payment_Request__r.Cheque_Date__c;
                        if(nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
                        || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                            receipt1.Cheque_DD_Date__c = nsa.Payment_Request__r.Date_of_Initiation__c;
                        }
                        receipt1.Receipt_Status__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer'  
                        || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 Aayushi added CDM cash condition
                        receipt1.Total_Amount__c = nsa.DLD_Amount__c;
                        receipt1.Amount_Rs__c = nsa.DLD_Amount__c;
                        receipt1.Mode__c = mode;
                        receipt1.Currency__c = curr;
                        receipt1.Opportunity__c =nsa.Booking__r.Opportunity__c;
                        receipt1.New_Sale_Approval__c =nsa.Id;
                        receipt1.Project_Unit__c = nsa.Payment_Request__r.Unit__c;
                        receipt1.Credit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash' || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 Aayushi added CDM cash condition
                        receipt1.Debit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash' || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?nsa.Payment_Request__r.Account_Master__c:null;//SOB-403 Aayushi added CDM cash condition
                        receipt1.GL_Date__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'|| nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? nsa.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 Aayushi added CDM cash condition
                        receipt1.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                            nsa.Booking__r.Unit__r.Name+' against DLD Charges '+nsa.DLD_Amount__c; 
                        receipt1.Payment_Request__c = nsa.Payment_Request__c;
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                        receiptToInsert.add(receipt1);
                        
                        //system.debug('I am gldate'+receipt1.GL_Date__c);
                        //receiptIdList.add(receipt1);
                    }
                    
                }else {
                    //SOB-403 Aayushi added CDM cash condition
                    if(nsa.Payment_Request__r.Payment_Request__c != null && (nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
                    || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')){
                        if(nsa.DP_Amount_2__c != null && nsa.DP_Amount_2__c>0 ){
                            Receipt__c receipt3 = new Receipt__c();
                            receipt3.Booking__c = nsa.Booking__c;
                            receipt3.Project__c = nsa.Booking__r.Project__c;
                            receipt3.Receipt_Date__c = paymentRequestDate;
                            receipt3.Registration_Collection_Control_Report__c = 0;
                            receipt3.Cheque_DD__c = nsa.Payment_Request__r.Mode__c == 'Website'?nsa.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(nsa.Payment_Request__r.Cheque_No__c)?String.isBlank(nsa.Payment_Request__r.Instrument_Number__c)?String.isBlank(nsa.Payment_Request__r.Reference_Number__c)?String.isBlank(nsa.Payment_Request__r.Payment_Transaction_Number__c)?'':nsa.Payment_Request__r.Payment_Transaction_Number__c:nsa.Payment_Request__r.Reference_Number__c:nsa.Payment_Request__r.Instrument_Number__c:nsa.Payment_Request__r.Cheque_No__c;
                            receipt3.Cheque_DD_Date__c = nsa.Payment_Request__r.Cheque_Date__c== null ?nsa.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : nsa.Payment_Request__r.Instrument_Date__c : nsa.Payment_Request__r.Cheque_Date__c;
                            if(nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                                receipt3.Cheque_DD_Date__c = nsa.Payment_Request__r.Date_of_Initiation__c;
                            }
                            //SOB-403 Aayushi added CDM cash condition
                            receipt3.Receipt_Status__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' 
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                            receipt3.Total_Amount__c = nsa.DP_Amount_2__c;
                            receipt3.Amount_Rs__c = nsa.DP_Amount_2__c;
                            receipt3.Mode__c = mode;
                            receipt3.Currency__c = curr;
                            receipt3.Opportunity__c =nsa.Booking__r.Opportunity__c;
                            receipt3.New_Sale_Approval__c =nsa.Id;
                            receipt3.Project_Unit__c = nsa.Payment_Request__r.Unit__c;
                            receipt3.Credit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'|| nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 Aayushi added CDM cash condition
                            receipt3.Debit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'|| nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?nsa.Payment_Request__r.Account_Master__c:null;//SOB-403 Aayushi added CDM cash condition
                            receipt3.GL_Date__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'|| nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? nsa.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 Aayushi added CDM cash condition
                            receipt3.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                nsa.Booking__r.Unit__r.Name+' against DP Charges '+nsa.DP_Amount_2__c;  
                            receipt3.Payment_Request__c = nsa.Payment_Request__c;
                            if(originalAmt != '' && !originalAmt.contains('AED')){
                                receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt3); system.debug('I am gldate2'+receipt3.GL_Date__c);
                            //receiptIdList.add(receipt3);
                        }
                        if(nsa.DLD_Amount_2__c != null && nsa.DLD_Amount_2__c > 0){
                            Receipt__c receipt4 = new Receipt__c();
                            receipt4.Booking__c = nsa.Booking__c;
                            receipt4.Project__c = nsa.Booking__r.Project__c;
                            receipt4.Receipt_Date__c = paymentRequestDate;
                            receipt4.Registration_Collection_Control_Report__c = nsa.DLD_Amount_2__c;
                            receipt4.Cheque_DD__c = nsa.Payment_Request__r.Mode__c == 'Website'?nsa.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(nsa.Payment_Request__r.Cheque_No__c)?String.isBlank(nsa.Payment_Request__r.Instrument_Number__c)?String.isBlank(nsa.Payment_Request__r.Reference_Number__c)?String.isBlank(nsa.Payment_Request__r.Payment_Transaction_Number__c)?'':nsa.Payment_Request__r.Payment_Transaction_Number__c:nsa.Payment_Request__r.Reference_Number__c:nsa.Payment_Request__r.Instrument_Number__c:nsa.Payment_Request__r.Cheque_No__c;
                            receipt4.Cheque_DD_Date__c = nsa.Payment_Request__r.Cheque_Date__c== null ?nsa.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : nsa.Payment_Request__r.Instrument_Date__c : nsa.Payment_Request__r.Cheque_Date__c;
                            if(nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 Aayushi added CDM cash condition
                                receipt4.Cheque_DD_Date__c = nsa.Payment_Request__r.Date_of_Initiation__c;
                            }
                            receipt4.Receipt_Status__c =nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' //SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'  || nsa.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                            receipt4.Total_Amount__c = nsa.DLD_Amount_2__c;
                            receipt4.Amount_Rs__c = nsa.DLD_Amount_2__c;
                            receipt4.Opportunity__c =nsa.Booking__r.Opportunity__c;
                            receipt4.Mode__c = mode;
                            receipt4.Currency__c = curr;
                            receipt4.New_Sale_Approval__c =nsa.Id;
                            receipt4.Project_Unit__c = nsa.Payment_Request__r.Unit__c;
                            receipt4.Credit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;
                            receipt4.Debit_Account__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?nsa.Payment_Request__r.Account_Master__c:null;
                            receipt4.GL_Date__c = nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? nsa.Payment_Request__r.Account_Received_Date__c : null;
                            receipt4.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                nsa.Booking__r.Unit__r.Name+' against DLD Charges '+nsa.DLD_Amount_2__c; 
                            receipt4.Payment_Request__c = nsa.Payment_Request__c;
                            if(originalAmt != '' && !originalAmt.contains('AED')){
                                receipt4.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt4.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt4);
                            //receiptIdList.add(receipt4);
                        }
                    }
                    //SOB-403 Aayushi added CDM cash condition
                    
                    if( nsa.Payment_Request__r.Payment_Request__c != null && (nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'
                     || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')){
                        if(nsa.DP_Amount__c != null && nsa.DP_Amount__c>0 ){
                            Receipt__c receipt5 = new Receipt__c();
                            receipt5.Booking__c = nsa.Booking__c;
                            receipt5.Project__c = nsa.Booking__r.Project__c;
                            receipt5.Receipt_Date__c =  nsa.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                            receipt5.Registration_Collection_Control_Report__c = 0;
                            receipt5.Cheque_DD__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Website' ? 
                                nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c:
                            String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Cheque_No__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Instrument_Number__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Reference_Number__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c)?
                                '':nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Reference_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Instrument_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Cheque_No__c;
                            
                            
                            receipt5.Cheque_DD_Date__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Cheque_Date__c== null ?
                                nsa.Payment_Request__r.Payment_Request__r.Instrument_Date__c== null ?
                                paymentRequestDate1 : nsa.Payment_Request__r.Payment_Request__r.Instrument_Date__c : 
                            nsa.Payment_Request__r.Payment_Request__r.Cheque_Date__c;
                            
                            if(nsa.Payment_Request__r.Payment_Request__c !=null &&( nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')){
                                receipt5.Cheque_DD_Date__c = nsa.Payment_Request__r.Payment_Request__r.Date_of_Initiation__c;
                            }
                            
                            receipt5.Receipt_Status__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Payment_Request__r.Mode__c =='International Wire Transfer'//SOB-403 Aayushi added CDM cash condition
                                || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'  || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash' ?
                                'Cleared':'UnProcessed';
                            
                            
                            receipt5.Total_Amount__c = nsa.DP_Amount__c;
                            receipt5.Amount_Rs__c = nsa.DP_Amount__c;
                            receipt5.Mode__c = nsa.Payment_Request__r.Payment_Request__c !=null ? mode1 : mode;
                            receipt5.Currency__c = nsa.Payment_Request__r.Payment_Request__c !=null ? curr1 : curr;
                            receipt5.Opportunity__c =nsa.Booking__r.Opportunity__c;
                            receipt5.New_Sale_Approval__c =nsa.Id;
                            receipt5.Project_Unit__c = nsa.Payment_Request__r.Payment_Request__c !=null ? nsa.Payment_Request__r.Payment_Request__r.Unit__c : nsa.Payment_Request__r.Unit__c;
                            receipt5.Credit_Account__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                                || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
                                ? tradeId.id:null;
                            
                            
                            receipt5.Debit_Account__c = nsa.Payment_Request__r.Payment_Request__c !=null ?
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:
                            nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?
                                nsa.Payment_Request__r.Payment_Request__r.Account_Master__c:null:
                            
                            nsa.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:
                            nsa.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?
                                nsa.Payment_Request__r.Account_Master__c:null;
                            receipt5.GL_Date__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate1!=null? approvalDate1 : null
                                    :nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                                    || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? 
                                        nsa.Payment_Request__r.Payment_Request__r.Account_Received_Date__c : null;
                            
                            
                            receipt5.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                nsa.Booking__r.Unit__r.Name+' against DP Charges '+nsa.DP_Amount__c; 
                            receipt5.Payment_Request__c = nsa.Payment_Request__r.Payment_Request__c !=null ? nsa.Payment_Request__r.Payment_Request__c :nsa.Payment_Request__c ;
                            
                            if(nsa.Payment_Request__r.Payment_Request__c !=null){
                                if(originalAmt1 != '' && !originalAmt1.contains('AED')){
                                    receipt5.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                    receipt5.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt1.split(' ')[1]);
                                }
                            }
                            receiptToInsert.add(receipt5);
                            
                            system.debug('I am gldate'+receipt5.GL_Date__c);
                            //receiptIdList.add(receipt5);
                        }
                        if(nsa.DLD_Amount__c != null && nsa.DLD_Amount__c > 0){
                            Receipt__c receipt6 = new Receipt__c();
                            receipt6.Booking__c = nsa.Booking__c;
                            receipt6.Project__c = nsa.Booking__r.Project__c;
                            receipt6.Receipt_Date__c = nsa.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                            receipt6.Registration_Collection_Control_Report__c = nsa.DLD_Amount__c;
                            receipt6.Cheque_DD__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Website' ? 
                                nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c:
                            String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Cheque_No__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Instrument_Number__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Reference_Number__c)?
                                String.isBlank(nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c)?
                                '':nsa.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Reference_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Instrument_Number__c:
                            nsa.Payment_Request__r.Payment_Request__r.Cheque_No__c;
                            
                            
                            receipt6.Cheque_DD_Date__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Cheque_Date__c== null ?
                                nsa.Payment_Request__r.Payment_Request__r.Instrument_Date__c== null ?
                                paymentRequestDate1 : nsa.Payment_Request__r.Payment_Request__r.Instrument_Date__c : 
                            nsa.Payment_Request__r.Payment_Request__r.Cheque_Date__c;
                            
                            
                            if(nsa.Payment_Request__r.Payment_Request__c !=null && (nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'//SOB-403 Aayushi added CDM cash condition
                            || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer')){
                                receipt6.Cheque_DD_Date__c = nsa.Payment_Request__r.Payment_Request__r.Date_of_Initiation__c;
                            }
                            
                            receipt6.Receipt_Status__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||nsa.Payment_Request__r.Payment_Request__r.Mode__c =='International Wire Transfer'
                                || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'  || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash' ?
                                'Cleared':'UnProcessed';
                            
                            
                            receipt6.Total_Amount__c = nsa.DLD_Amount__c;
                            receipt6.Amount_Rs__c = nsa.DLD_Amount__c;
                            receipt6.Opportunity__c =nsa.Booking__r.Opportunity__c;
                            receipt6.Mode__c = nsa.Payment_Request__r.Payment_Request__c !=null ?mode1 : mode;
                            receipt6.Currency__c = nsa.Payment_Request__r.Payment_Request__c !=null ? curr1 : curr;
                            receipt6.New_Sale_Approval__c =nsa.Id;
                            receipt6.Project_Unit__c = nsa.Payment_Request__r.Payment_Request__c !=null ? nsa.Payment_Request__r.Payment_Request__r.Unit__c : nsa.Payment_Request__r.Unit__c;
                            receipt6.Credit_Account__c =  
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'
                                || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
                                ? tradeId.id:null ; 
                            
                            receipt6.Debit_Account__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:
                            nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'
                            || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?
                                nsa.Payment_Request__r.Payment_Request__r.Account_Master__c:null;
                            
                            
                            
                            receipt6.GL_Date__c = 
                                nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate1!=null? approvalDate1 : null
                                    :nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'
                                    || nsa.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? 
                                        nsa.Payment_Request__r.Payment_Request__r.Account_Received_Date__c : null;
                            
                            
                            receipt6.RemarksText__c ='Received from '+nsa.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                nsa.Booking__r.Unit__r.Name+' against DLD Charges '+nsa.DLD_Amount__c;  
                            receipt6.Payment_Request__c = nsa.Payment_Request__r.Payment_Request__c !=null ? nsa.Payment_Request__r.Payment_Request__c :nsa.Payment_Request__c ;
                            
                            if(nsa.Payment_Request__r.Payment_Request__c !=null){
                                if(originalAmt1 != '' && !originalAmt1.contains('AED')){
                                    receipt6.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                    receipt6.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt1.split(' ')[1]);
                                }
                            }
                            receiptToInsert.add(receipt6); system.debug('I am gldate1'+receipt6.GL_Date__c);
                            
                           
                        }
                    }
                }  
            }
            system.debug('I am receiptid list final'+receiptIdList);
            /*if(receiptIdList != null && receiptIdList.size()>0){
                nsa.Receipt_Created__c = true;                           
                update nsa;
            }*/
            mapIdToNsa.put(nsa.id , nsa);
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
                unit_hold_request__c pr = mapIdToNsa.get(r.New_Sale_Approval__c);
                pr.Receipt_Created__c = false;
                pr.Receipt_creation_error_log__c = msg;
                mapIdToNsa.put(r.New_Sale_Approval__c,pr);    
                sError += msg + ' for new sale approval - '+pr.id;
                  
                }else{
                    receiptIdsWithSucess.add(result.getId());
                }
                i++;
            }
            if(sError != ''){
                SendEmailForReceiptError.sendEmailMessage(sError);
           
            }
            for(Receipt__c r :[SELECT ID,New_Sale_Approval__c FROM Receipt__c WHERE ID IN : receiptIdsWithSucess]){
                unit_hold_request__c pr = mapIdToNsa.get(r.New_Sale_Approval__c);
                pr.Receipt_Created__c = true;
                pr.Receipt_Creation_Error_Log__c = null;
                mapIdToNsa.put(r.New_Sale_Approval__c,pr);
                receiptIdList.add(r);
            } 
            update mapIdToNsa.values();
        system.debug('I am receiptid list final'+receiptIdList);
        if(receiptIdList != null && receiptIdList.size()>0){
            List<Id> receipts = new List<Id>();
            for(Receipt__c receipt : receiptIdList){
               /*PageReference page = new PageReference('/apex/PrintReceiptSobhaDubai?id='+receipt.Id+'&letterhead=0');
                Blob pdf;
                String name = '';
                String descr = 'Receipt';
                try{              
                    pdf = page.getContentAsPDF();
                }catch(Exception e){
                    pdf = Blob.valueOf(e.getMessage());
                    descr = e.getMessage();
                }
                
                Attachment att = new Attachment();
                att.Body = pdf;
                att.Name = receipt.name+'.pdf';
                att.IsPrivate = false;
                att.ParentId = receipt.New_Sale_Approval__c;
                att.Description = descr;
                insert att;*/
                receipts.add(receipt.id);
            }
            if(receipts != null && receipts.size()>0){
                createAttachments(receipts);
            }
            //sendAttachedReceiptbatch(receiptIdList);
        }
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
    
     @future(callout=true)
    public static void createAttachments(List<id> IdsList){
        List<Receipt__c> receiptList= [SELECT name,id,Project_Unit__r.Name,Total_Amount__c,Receipt_No__c,New_Sale_Approval__c,
                                     Currency__c,Booking__r.Tower__c,Booking__r.Name,Booking__r.Primary_Applicant_Name__c,
                                     New_Sale_Approval__r.Owner.email,New_Sale_Approval__r.Payment_Request__r.Name__c,
                                     New_Sale_Approval__r.Payment_Request__r.Email__c,GL_Date__c,Project__c,Payment_Request__c,
                                     Booking__r.Primary_Applicant_Email__c,Booking__r.Sales_Head__c,
                                     Booking__r.Secondary_Sales_Manager_VP__c,Booking__r.Sales_Head__r.Manager.Email,
                                     Booking__r.Secondary_Sales_Head__r.Manager.Email,
                                     Booking__r.Secondary_Sales_Manager_VP__r.email,Booking__r.Sales_Head__r.email,
                                     Booking__r.Sales_Managers__r.email,Booking__r.Secondary_Sales_Manager__r.email,
                                     Booking__r.Secondary_Sales_Head__r.email
                                     ,booking__r.owner.email
                                     FROM Receipt__c 
                                     WHERE Id IN : IdsList];
        
        if(receiptList != null && receiptList.size()>0){
            
            for(Receipt__c receipt : receiptList){
                PageReference page = new PageReference('/apex/PrintReceiptSobhaDubai?id='+receipt.Id+'&letterhead=0');
                Blob pdf;
                String name = '';
                String descr = 'Receipt';
                try{              
                    pdf = page.getContentAsPDF();
                }catch(Exception e){
                    pdf = Blob.valueOf(e.getMessage());
                    descr = e.getMessage();
                }
                
                Attachment att = new Attachment();
                att.Body = pdf;
                att.Name = receipt.name+'.pdf';
                att.IsPrivate = false;
                att.ParentId = receipt.New_Sale_Approval__c;
                att.Description = descr;
                insert att;
            }
            sendAttachedReceiptbatch(receiptList);
        }
        
    }
    
    public static PageReference sendAttachedReceiptbatch(List<Receipt__c> receiptList)
    { 
        List<Messaging.SingleEmailMessage> emailsList = new  List<Messaging.SingleEmailMessage>();
        for(Receipt__c receipt : receiptList){
            
            System.debug('I am recordidyamini-->'+receipt.Id);
            String fileName;
            
            User usr = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId()]; 
            if((receipt.New_Sale_Approval__r.Owner.email != null && receipt.New_Sale_Approval__r.Owner.email  != '') || Test.isRunningTest()){   
                
                PageReference pref = new PageReference('/apex/PrintReceiptSobhaDubai');
                pref.getParameters().put('id', receipt.Id);
                Blob b;
                if(!Test.isRunningTest()){
                    b = pref.getContent();   
                } else {
                    b = Blob.valueOf('Test123');
                }                           
                
                fileName = receipt.Name;
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
                attach.setBody(b);
                attach.setFileName(fileName+'.pdf');  
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                email.setSubject('Receipt for ' +receipt.Booking__r.Name+' '+receipt.Project_Unit__r.Name+' '+ receipt.Booking__r.Primary_Applicant_Name__c);
                List <String> lststringtoaddress = new List<String>();
                List <String> lstStringccaddress = new List <String>();
                
                String body =  'Dear ' + receipt.New_Sale_Approval__r.Payment_Request__r.Name__c+ ',<br/><br/>' +                        
                    
                    'Greetings, <br/><br/>'+
                    'Thank you for your payment towards your property'+' ' +receipt.Booking__r.Tower__c+' '+receipt.Project_Unit__r.Name +
                    '.Please find attached receipt of amount'+' '+receipt.Currency__c+' '+receipt.Total_Amount__c +'.<br/><br/>'+                
                    'Best Regards,<br/>'+
                    usr.Name;
                if(receipt.New_Sale_Approval__r.Payment_Request__r.Email__c !=null && receipt.New_Sale_Approval__r.Payment_Request__r.Email__c != ''){
                            System.debug('lststringtoaddress -->'+ lststringtoaddress);          
                }
                
                if(receipt.Booking__r.Primary_Applicant_Email__c != null && receipt.Booking__r.Primary_Applicant_Email__c != ''){
                    lstStringtoaddress.add(receipt.Booking__r.Primary_Applicant_Email__c);
                }
                SYSTEM.DEBUG('I AM EMAIL'+receipt.Booking__r.sales_Head__r.email);
                if(receipt.Booking__r.Sales_Head__c != null){
                    lstStringccaddress.add(receipt.Booking__r.Sales_Head__r.email);
                    lstStringccaddress.add(receipt.Booking__r.Sales_Head__r.Manager.Email);
                    SYSTEM.DEBUG('I AM EMAIL'+receipt.Booking__r.sales_Head__r.email);
                }
                if(receipt.Booking__r.Secondary_Sales_Head__c!=null){
                    lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Head__r.Manager.Email);
                }
                if(receipt.Booking__r.Sales_Managers__c!=null){
                    lstStringccaddress.add(receipt.Booking__r.Sales_Managers__r.email);
                }
                if(receipt.Booking__r.Secondary_Sales_Manager__c!=null){
                    lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Manager__r.email);
                }
                if(receipt.Booking__r.Secondary_Sales_Head__c!=null){
                    lstStringccaddress.add(receipt.Booking__r.Secondary_Sales_Head__r.email);
                }
                
                lstStringccaddress.add(System.label.SobhaSalesOp);               
                
                email.setToAddresses(lststringtoaddress);
                email.setccAddresses(lstStringccaddress);
                
                email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   
                emailsList.add(email);
            } 
        }
        Messaging.sendEmail(emailsList);
        
        
        
        return null;                           
    }
    
}