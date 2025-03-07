public class ReceiptUtil {
    
    
    /***** BOF Create Missed out Receipt ***/
    public static void createReceiptBookingLevel(List<String> prNameList) { 
        try{
            
            List<Payment_Request__c> prList = new List<Payment_Request__c>();
            prList=[SELECT Id,Status__c,Date_of_Initiation__c,Original_Amount__c,Currency__c,Booking__c,Amount__c,Amount_Towards__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Name IN: prNameList and  Booking__c != null and Status__c = 'Approved'];
            System.debug('i am prList'+prList);
            Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
            Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
            //Account_Master__c interestMaster = [Select Id, Name From Account_Master__c Where Name = 'Interest Charges' LIMIT 1];
            
            SysteM.Debug('I am mainchashid:'+maincashid.Id);
            SysteM.Debug('I am tradeid:'+tradeId.Id);
            //SysteM.Debug('I am tradeid Interest:'+interestMaster.Id);
            string curr = '';
            string originalAmt = '';
            Map<Id,Payment_Request__c> mapIdToPr = new Map<Id,Payment_Request__c>();
            List<Receipt__c> receiptToInsert = new List<Receipt__c>();
            //Aayushi : SOB-353 Demand to be created for "Towards Other Charges Amount" in Booking level PR.
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
                        //receiptIdList.clear();
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
                            if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'
                               ||pr.Mode__c == 'CDM Cash'){//SOB-403
                                   receipt1.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                               }
                            receipt1.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'
                                ||pr.Mode__c == 'Domestic Wire Transfer'  ||pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403
                            receipt1.Total_Amount__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Amount_Rs__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Currency__c = curr;
                            receipt1.Mode__c = mode;
                            receipt1.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt1.Project_Unit__c = pr.Unit__c;
                            receipt1.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? tradeId.id:null;//SOB-403 added cdm cash condition
                            receipt1.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'?pr.Account_Master__c:null;//SOB-403 added cdm cash condition
                            //receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                            receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? pr.Account_Received_Date__c : null;//SOB-403 added cdm cash condition
                            receipt1.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                pr.Booking__r.Unit__r.Name+' against Other Charges '+pr.Towards_Other_Charges_Amount__c; 
                            receipt1.Other_Charges_Type__c = pr.Others__c;
                            receipt1.Credit_Card_Charges__c = pr.Towards_Other_Charges_Amount__c;
                            receipt1.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED')){
                                receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt1);
                            /* if(pr.Demands__r == null || pr.Demands__r.size() == 0){
//Aayushi : SOB-353 Demand record creation
Demand__C demand = new Demand__C();
demand.Booking__c = pr.booking__c;
demand.Payment_Towards__c = 'Corporate Account';
demand.GL_Date__c = System.today();
demand.Invoice_Date__c = System.today();
demand.Debit_Demanded__c = pr.Towards_Other_Charges_Amount__c*Decimal.valueOf(System.label.PR_Debit_Note_Percent);
demand.Milestone_Name__c = 'Debit Note for '+pr.Name;
demand.Debit_Type__c = 'Others';
demand.Tax_Rate__c = 'VAT 5%';
demand.Payment_Term__c = 'Immediate';
demand.Project__c = pr.booking__r.Project__c;
demand.Unit__c = pr.booking__r.Unit__c;
demand.Remarks__c = 'Other Charges '+pr.Remarks__c;
demandToInsert.add(demand);
}
*/
                        }
                        if(pr.Towards_Pre_Registration_Amount__c != null && pr.Towards_Pre_Registration_Amount__c > 0){
                            Receipt__c receipt2 = new Receipt__c();
                            receipt2.Booking__c = pr.Booking__c;
                            receipt2.Project__c = pr.Booking__r.Project__c;
                            receipt2.Receipt_Date__c = paymentRequestDate;
                            receipt2.Registration_Collection_Control_Report__c = 0;
                            receipt2.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                            receipt2.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                            if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'
                               ||pr.Mode__c == 'CDM Cash'){//SOB-403 added cdm cash condition
                                   receipt2.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                               }
                            receipt2.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash' ?'Cleared':'UnProcessed';
                            receipt2.Total_Amount__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Amount_Rs__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Currency__c = curr;
                            receipt2.Mode__c = mode;
                            receipt2.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt2.Project_Unit__c = pr.Unit__c;
                            receipt2.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'||pr.Mode__c == 'CDM Cash'? tradeId.id:null;//SOB-403 added cdm cash condition
                            receipt2.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'?pr.Account_Master__c:null;//SOB-403 added cdm cash condition
                            //receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                            receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? pr.Account_Received_Date__c : null;//SOB-403 added cdm cash condition
                            receipt2.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                pr.Booking__r.Unit__r.Name+' against Pre Registration '+pr.Towards_Pre_Registration_Amount__c; 
                            receipt2.Registration_Collection_Control_Report__c = pr.Towards_Pre_Registration_Amount__c;
                            receipt2.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED')){
                                receipt2.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt2.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt2);
                            
                            system.debug('I am gldate'+receipt2.GL_Date__c);
                            //receiptIdList.add(receipt2.Id);
                            //finishreceiptIdList.add(receipt2.Id);
                        }
                        if(pr.Towards_Unit_Price_Amount__c != null && pr.Towards_Unit_Price_Amount__c > 0){
                            
                            Receipt__c receipt3 = new Receipt__c();
                            receipt3.Booking__c = pr.Booking__c;
                            receipt3.Project__c = pr.Booking__r.Project__c;
                            receipt3.Receipt_Date__c = paymentRequestDate;
                            receipt3.Registration_Collection_Control_Report__c = 0;
                            receipt3.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                            receipt3.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                            if(pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'
                               ||pr.Mode__c == 'CDM Cash'){//SOB-403
                                   receipt3.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                               }
                            //SOB-403 added cdm cash condition
                            receipt3.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer'  ||pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 added cdm cash condition
                            receipt3.Total_Amount__c = pr.Towards_Unit_Price_Amount__c;
                            receipt3.Amount_Rs__c = pr.Towards_Unit_Price_Amount__c;
                            receipt3.Currency__c = curr;
                            receipt3.Mode__c = mode;
                            receipt3.Opportunity__c =pr.Booking__r.Opportunity__c;
                            receipt3.Project_Unit__c = pr.Unit__c;
                            receipt3.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? tradeId.id:null;
                            receipt3.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'?pr.Account_Master__c:null;//SOB-403 added cdm cash condition
                            //receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'? pr.Account_Received_Date__c : null;
                            receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer'||pr.Mode__c == 'Domestic Wire Transfer' ||pr.Mode__c == 'CDM Cash'? pr.Account_Received_Date__c : null;//SOB-403 added cdm cash condition
                            receipt3.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                                pr.Booking__r.Unit__r.Name+' against Unit Price '+pr.Towards_Unit_Price_Amount__c; 
                            //receipt3.Registration_Collection_Control_Report__c = pr.Towards_Unit_Price_Amount__c;
                            //receipt3.Credit_Card_Charges__c = pr.Towards_Unit_Price_Amount__c;
                            receipt3.Payment_Request__c = pr.id;
                            if(originalAmt != '' && !originalAmt.contains('AED')){
                                receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                                receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                            }
                            receiptToInsert.add(receipt3);
                            
                            system.debug('I am gldate'+receipt3.GL_Date__c);
                            //receiptIdList.add(receipt3.Id);
                            //finishreceiptIdList.add(receipt3.Id);
                            
                        }
                        
                        //System.debug('i am in execute receptlist'+finishreceiptIdList);
                        /*if(receiptIdList != null && receiptIdList.size()>0){
pr.Receipt_Created__c = true;
update pr;
}*/
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
                //finishreceiptIdList.add(r.id);
            } 
            update mapIdToPr.values();
            //insert demandToInsert SOB-353
            /*
//commented demand insert as its not going live as of 27th april - aayushi
if(demandToInsert != null && demandToInsert.size() > 0){
insert demandToInsert;
}*/
        } catch(Exception ex){
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'PaymentRequestReceiptCreation';
            insert logError;
            System.debug('Hi I am in catch block');
            String sMessage = '';
            sMessage += 'ERROR: ' + 'An exception has occurred while creating receipt -- '+ ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString();
            
            SendEmailForReceiptError.sendEmailMessage(sMessage);
        } 
    }    
    /***** EOF Create Missed out Receipt ***/
    
    
    /*public static void createReceiptBookingLevel(string prName){
        list<string> receiptIdList =  new List<string>();
        Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
        Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
        string curr = '';
        string originalAmt = '';
        Payment_Request__c pr = [SELECT Id,Status__c,Date_of_Initiation__c,Original_Amount__c,Currency__c,Booking__c,Amount__c,Amount_Towards__c,Towards_Other_Charges_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Unit_Price_Amount__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Transaction_Tracking_Id__c,Account_Received_Date__c,Approved_Date_and_Time__c,Account_Master__c,Instrument_Date__c,Instrument_Number__c,Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Transaction_Number__c,CreatedDate,Unit__c,Cheque_Date__c,Cheque_No__c,Mode__c,Others__c,(select id from Receipts__r) FROM Payment_Request__c WHERE Name =: prName and  Booking__c != null and Status__c = 'Approved' LIMIT 1];
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
        }else if(pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash' || pr.Mode__c == 'Domestic Wire Transfer'){
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
        if( receiptList.isEmpty() ||receiptList.size() < 1 ){
            if(pr.Amount__c != null && pr.Amount__c>0 ){
                if(pr.Towards_Other_Charges_Amount__c != null && pr.Towards_Other_Charges_Amount__c > 0){
                    Receipt__c receipt1 = new Receipt__c();
                    receipt1.Booking__c = pr.Booking__c;
                    receipt1.Project__c = pr.Booking__r.Project__c;
                    receipt1.Receipt_Date__c = paymentRequestDate;
                    receipt1.Registration_Collection_Control_Report__c = 0;
                    if(pr.Others__c == 'Title Deed Charges' || pr.Others__c == 'Plot title Deed' || pr.Others__c == 'Mortgage Fees'){
                        receipt1.Registration_Collection_Control_Report__c = pr.Towards_Other_Charges_Amount__c;
                    }
                    receipt1.Cheque_DD__c = pr.Mode__c == 'Website'?pr.Payment_Transaction_Tracking_Id__c:String.isBlank(pr.Cheque_No__c)?String.isBlank(pr.Instrument_Number__c)?String.isBlank(pr.Reference_Number__c)?String.isBlank(pr.Payment_Transaction_Number__c)?'':pr.Payment_Transaction_Number__c:pr.Reference_Number__c:pr.Instrument_Number__c:pr.Cheque_No__c;
                    receipt1.Cheque_DD_Date__c = pr.Cheque_Date__c== null ?pr.Instrument_Date__c== null ?paymentRequestDate : pr.Instrument_Date__c : pr.Cheque_Date__c;
                    if(pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'|| pr.Mode__c == 'Domestic Wire Transfer'){//SOB-403 aayushi added cdm cash conditopon
                        receipt1.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                    }
                    receipt1.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed'; //SOB-403 aayushi added cdm cash conditopon
                    receipt1.Total_Amount__c = pr.Towards_Other_Charges_Amount__c;
                    receipt1.Amount_Rs__c = pr.Towards_Other_Charges_Amount__c;
                    receipt1.Currency__c = curr;
                    receipt1.Mode__c = mode;
                    receipt1.Opportunity__c =pr.Booking__r.Opportunity__c;
                    receipt1.Project_Unit__c = pr.Unit__c;
                    receipt1.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash' ||pr.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null; //SOB-403 aayushi added cdm cash conditopon
                    receipt1.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash' || pr.Mode__c == 'Domestic Wire Transfer'?pr.Account_Master__c:null; //SOB-403 aayushi added cdm cash conditopon
                    receipt1.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'? pr.Account_Received_Date__c : null;//SOB-403 aayushi added cdm cash conditopon
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
                    if(pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash' || pr.Mode__c == 'Domestic Wire Transfer'){ //SOB-403 aayushi added cdm cash conditopon
                        receipt2.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                    }
                    receipt2.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer'  || pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed'; //SOB-403 aayushi added cdm cash conditopon
                    receipt2.Total_Amount__c = pr.Towards_Pre_Registration_Amount__c;
                    receipt2.Amount_Rs__c = pr.Towards_Pre_Registration_Amount__c;
                    receipt2.Currency__c = curr;
                    receipt2.Mode__c = mode;
                    receipt2.Opportunity__c =pr.Booking__r.Opportunity__c;
                    receipt2.Project_Unit__c = pr.Unit__c;
                    receipt2.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null; //SOB-403 aayushi added cdm cash conditopon
                    receipt2.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'?pr.Account_Master__c:null; //SOB-403 aayushi added cdm cash conditopon
                    receipt2.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'? pr.Account_Received_Date__c : null; //SOB-403 aayushi added cdm cash conditopon
                    receipt2.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                    pr.Booking__r.Unit__r.Name+' against Pre Registration '+pr.Towards_Pre_Registration_Amount__c; 
                    receipt2.Registration_Collection_Control_Report__c = pr.Towards_Pre_Registration_Amount__c;
                    receipt2.Payment_Request__c = pr.id;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt2.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt2.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    insert receipt2;
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
                    if(pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'){ 
                        receipt3.Cheque_DD_Date__c = pr.Date_of_Initiation__c;
                    }
                    receipt3.Receipt_Status__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer'  || pr.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 aayushi added cdm cash conditopon
                    receipt3.Total_Amount__c = pr.Towards_Unit_Price_Amount__c;
                    receipt3.Amount_Rs__c = pr.Towards_Unit_Price_Amount__c;
                    receipt3.Currency__c = curr;
                    receipt3.Mode__c = mode;
                    receipt3.Opportunity__c =pr.Booking__r.Opportunity__c;
                    receipt3.Project_Unit__c = pr.Unit__c;
                    receipt3.Credit_Account__c = pr.Mode__c == 'OTC Deposits'||pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 aayushi added cdm cash conditopon
                    receipt3.Debit_Account__c = pr.Mode__c == 'OTC Deposits'? mainCashId.id:pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'?pr.Account_Master__c:null;//SOB-403 aayushi added cdm cash conditopon
                    receipt3.GL_Date__c = pr.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null :pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'CDM Cash'||pr.Mode__c == 'Domestic Wire Transfer'? pr.Account_Received_Date__c : null;//SOB-403 aayushi added cdm cash conditopon
                    receipt3.RemarksText__c ='Received from '+pr.Booking__r.Primary_Applicant_Name__c +' Unit '+
                    pr.Booking__r.Unit__r.Name+' against Unit Price '+pr.Towards_Unit_Price_Amount__c; 
                    receipt3.Payment_Request__c = pr.id;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    insert receipt3;
                    receiptIdList.add(receipt3.Id);
                }
            }
        }
        
        if(receiptIdList != null && receiptIdList.size()>0){
            pr.Receipt_Created__c = true;
            update pr;
        }
        
        if(receiptIdList != null && receiptIdList.size()>0){
             ReceiptUtil.sendEmailToUser(receiptIdList);
        }
    } */
    
    /*** BOF Create Receipt in Unit Level ***/
	public static void createReceiptUnitLevel(List<String> SaleApprovalNameList){
        try{
        List<unit_hold_request__c> newSaleList = new List<unit_hold_request__c>();
        newSaleList =[SELECT Id,Payment_Request__r.Payment_Request__r.Account_Master__c,Payment_Request__r.Payment_Request__r.Account_Received_Date__c,Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c,Payment_Request__r.Payment_Request__r.Cheque_No__c,Payment_Request__r.Payment_Request__r.Unit__c,Payment_Request__r.Payment_Request__r.Date_of_Initiation__c,Payment_Request__r.Payment_Request__r.Instrument_Date__c,Payment_Request__r.Payment_Request__r.Cheque_Date__c,Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c,Payment_Request__r.Payment_Request__r.Reference_Number__c,Payment_Request__r.Payment_Request__r.Instrument_Number__c,Payment_Request__r.Payment_Request__r.Currency__c,Payment_Request__r.Payment_Request__r.Mode__c,Payment_Request__r.Payment_Request__r.Original_Amount__c,Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c,Approval_Status__c,Payment_Request__r.Date_of_Initiation__c,Payment_Request__r.Payment_Request__c,Payment_Request__r.payment_Request__r.CreatedDate,Payment_Request__r.Currency__c,Payment_Request__r.Original_Amount__c,Booking__c,DP_Amount_2__c,DLD_Amount_2__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Request__r.Payment_Transaction_Tracking_Id__c,Payment_Request__r.Account_Received_Date__c,Payment_Request__r.Approved_Date_and_Time__c,Payment_Request__r.Account_Master__c,Payment_Request__r.Instrument_Date__c,Payment_Request__r.Instrument_Number__c,Payment_Request__r.Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Request__r.Payment_Transaction_Number__c,Payment_Request__r.CreatedDate,Payment_Request__r.Unit__c,DLD_Amount__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__c,Payment_Request__r.Mode__c,DP_Amount__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c WHERE Name IN: SaleApprovalNameList and Booking__c != null and Approval_Status__c='Approved' LIMIT 1];
        System.debug('i am newsaleList'+newSaleList);
        Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
        Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
        SysteM.Debug('I am mainchashid:'+maincashid.Id);
        SysteM.Debug('I am tradeid:'+tradeId.Id);
        string curr = '';
        string originalAmt = '';
         string curr1 = '';
        string originalAmt1 = '';
        List<Receipt__c> receiptToInsert = new List<Receipt__c>();
        Map<Id,unit_hold_request__c> mapIdToNsa = new Map<Id,unit_hold_request__c>();
            
        for(unit_hold_request__c newSale : newSaleList){
            system.debug('~~~Date: '+newSale.Payment_Request__r.CreatedDate);
            Date paymentRequestDate = date.newinstance(newSale.Payment_Request__r.CreatedDate.year(),newSale.Payment_Request__r.CreatedDate.month(),newSale.Payment_Request__r.CreatedDate.day());            
            Date paymentRequestDate1;
            Date approvalDate;
            Date approvalDate1;
            if(newSale.Payment_Request__r.Approved_Date_and_Time__c != null){
                approvalDate = date.newInstance(newSale.Payment_Request__r.Approved_Date_and_Time__c.year(), newSale.Payment_Request__r.Approved_Date_and_Time__c.month(), newSale.Payment_Request__r.Approved_Date_and_Time__c.day());
            } 
             
            String instrumentno;
            curr = '';
            originalAmt = '';
            curr1 = '';
            originalAmt1 = '';
            if(newSale.Payment_Request__r.Original_Amount__c != null && newSale.Payment_Request__r.Original_Amount__c != ''){
                originalAmt = newSale.Payment_Request__r.Original_Amount__c;
            }
            
            //Double totalAmount = newSale.DP_Amount__c + newSale.DLD_Amount__c;
            String mode = '';
            String mode1 = '';
            if(newSale.Payment_Request__r.Mode__c == 'CDM Cheque'){
                mode = 'CDM-cheque';
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'CDM Cash'){ 
                mode = 'CDM-cash';
                curr = newSale.Payment_Request__r.Currency__c;
            }else if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' ){
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
            if(newSale.Payment_Request__r.Payment_Request__c!=null){
                paymentRequestDate1 = date.newinstance(newSale.Payment_Request__r.payment_Request__r.CreatedDate.year(),newSale.Payment_Request__r.payment_Request__r.CreatedDate.month(),newSale.Payment_Request__r.payment_Request__r.CreatedDate.day());
            	
                if(newSale.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c != null){
                    approvalDate1 = date.newInstance(newSale.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.year(), newSale.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.month(), newSale.Payment_Request__r.Payment_Request__r.Approved_Date_and_Time__c.day());
            	}
                
                if(newSale.Payment_Request__r.Payment_Request__r.Original_Amount__c != null && newSale.Payment_Request__r.Payment_Request__r.Original_Amount__c != ''){
                	originalAmt1 = newSale.Payment_Request__r.Payment_Request__r.Original_Amount__c;
            	}
                
                if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cheque'){
                	mode1 = 'CDM-cheque';
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'){
                	mode1 = 'CDM-cash';
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'){//Aayushi :SOB-403 added cdm cash condition
                	mode1 = 'Wire Transfer';
                	curr1 = 'AED';
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Credit Card'){
                	mode1 = 'Credit Card';
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'){
                	mode1 = 'Cash';       
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Cheque'){
                	mode1 = 'Cheque';   
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}else if(newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Website'){
                	mode1 = 'Website';  
                	curr1 = newSale.Payment_Request__r.Payment_Request__r.Currency__c;
            	}
            }
            List<Receipt__c> receiptList = new List<Receipt__c>();
            receiptList.addAll(newSale.Receipts__r);
            System.debug('i am reciptlist'+receiptList);
            if(receiptList == null && receiptList.isEmpty() || receiptList.size() < 1 ){
                //receiptIdList.clear();
                system.debug('~~~~newSale.DP_Amount__c: '+newSale.DP_Amount__c);
                if(newSale.DP_Amount__c != null && newSale.DP_Amount__c>0 ){
                    Receipt__c receipt = new Receipt__c();
                    receipt.Booking__c = newSale.Booking__c;
                    receipt.Project__c = newsale.Booking__r.Project__c;
                    receipt.Receipt_Date__c =  newSale.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                    receipt.Registration_Collection_Control_Report__c = 0;
                    receipt.Cheque_DD__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Website' ? newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c: String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Cheque_No__c)? String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Payment_Request__r.Cheque_No__c :
                                            
                                            newSale.Payment_Request__r.Mode__c == 'Website' ? newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:
                                            String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?
                                            String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?
                                            String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?
                                            String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?
                                            '':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    
                    receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Payment_Request__c !=null ?newSale.Payment_Request__r.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate1 : newSale.Payment_Request__r.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Payment_Request__r.Cheque_Date__c:
                                                
                                                newSale.Payment_Request__r.Cheque_Date__c== null ?
                                                newSale.Payment_Request__r.Instrument_Date__c== null ?
                                                paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'|| newSale.Payment_Request__r.Mode__c == 'CDM Cash') {//Aayushi :SOB-403 added cdm cash condition
                        receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    if(newSale.Payment_Request__r.Payment_Request__c !=null && (newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash')){//Aayushi :SOB-403 added cdm cash condition
                        receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Payment_Request__r.Date_of_Initiation__c;
                    }
                    
                    receipt.Receipt_Status__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='Domestic Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='CDM Cash'
                                                 ?//Aayushi :SOB-403 added cdm cash condition
                                                'Cleared':'UnProcessed':
                                                
                                                newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c =='International Wire Transfer'||newSale.Payment_Request__r.Mode__c =='Domestic Wire Transfer'
                                                ||newSale.Payment_Request__r.Mode__c =='CDM Cash'?
                                                'Cleared':'UnProcessed';
                    receipt.Total_Amount__c = newSale.DP_Amount__c;
                    receipt.Amount_Rs__c = newSale.DP_Amount__c;
                    receipt.Mode__c = newSale.Payment_Request__r.Payment_Request__c !=null ? mode1 : mode;
                    receipt.Currency__c = newSale.Payment_Request__r.Payment_Request__c !=null ? curr1 : curr;
                    receipt.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt.New_Sale_Approval__c =newSale.Id;
                    receipt.Project_Unit__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Unit__c : newSale.Payment_Request__r.Unit__c;
                    receipt.Credit_Account__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' ||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null : newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null;//Aayushi :SOB-403 added cdm cash condition

                    receipt.Debit_Account__c = newSale.Payment_Request__r.Payment_Request__c !=null ?newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Payment_Request__r.Account_Master__c:null:newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt.GL_Date__c = newSale.Payment_Request__r.Payment_Request__c !=null ?newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate1!=null? approvalDate1 : null:newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Payment_Request__r.Account_Received_Date__c : null:
                                            
                                         newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount__c; 
                    receipt.Payment_Request__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__c :newSale.Payment_Request__c ;
                    
                     if(newSale.Payment_Request__r.Payment_Request__c !=null){
                        if(originalAmt1 != '' && !originalAmt1.contains('AED')){
                        	receipt.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        	receipt.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt1.split(' ')[1]);
                    	}
                    }else{
                        
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                    }
                    system.debug('~~~R1: '+receiptToInsert);
                    receiptToInsert.add(receipt);
                    //finishreceiptIdList.add(receipt.ID);
                    
                    system.debug('I am gldate'+receipt.GL_Date__c);
                    //receiptIdList.add(receipt.Id);
                }
                if(newSale.DLD_Amount__c != null && newSale.DLD_Amount__c > 0){
                    Receipt__c receipt1 = new Receipt__c();
                    receipt1.Booking__c = newSale.Booking__c;
                    receipt1.Project__c = newsale.Booking__r.Project__c;
                    receipt1.Receipt_Date__c = newSale.Payment_Request__r.Payment_Request__c !=null ? paymentRequestDate1 : paymentRequestDate;
                    receipt1.Registration_Collection_Control_Report__c = newSale.DLD_Amount__c;
                    receipt1.Cheque_DD__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Website' ? newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Payment_Request__r.Cheque_No__c :
                                            
                                            newSale.Payment_Request__r.Mode__c == 'Website' ? newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?
                                            String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?
                                            '':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    
                    receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Cheque_Date__c== null ? newSale.Payment_Request__r.Payment_Request__r.Instrument_Date__c== null ? paymentRequestDate1 : newSale.Payment_Request__r.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Payment_Request__r.Cheque_Date__c:
                                                
                                                newSale.Payment_Request__r.Cheque_Date__c== null ?
                                                newSale.Payment_Request__r.Instrument_Date__c== null ?
                                                paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'){//Aayushi :SOB-403 added cdm cash condition
                        receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    if(newSale.Payment_Request__r.Payment_Request__c !=null && (newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash')){
                        receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Payment_Request__r.Date_of_Initiation__c;
                    }
                    
                    receipt1.Receipt_Status__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='Domestic Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c =='CDM Cash'?'Cleared':'UnProcessed':
                                                newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c =='International Wire Transfer'||newSale.Payment_Request__r.Mode__c =='Domestic Wire Transfer'||newSale.Payment_Request__r.Mode__c =='CDM Cash'?
                                                'Cleared':'UnProcessed';
                    receipt1.Total_Amount__c = newSale.DLD_Amount__c;
                    receipt1.Amount_Rs__c = newSale.DLD_Amount__c;
                    receipt1.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt1.Mode__c = newSale.Payment_Request__r.Payment_Request__c !=null ?mode1 : mode;
                    receipt1.Currency__c = newSale.Payment_Request__r.Payment_Request__c !=null ? curr1 : curr;
                    receipt1.New_Sale_Approval__c =newSale.Id;
                    receipt1.Project_Unit__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Unit__c : newSale.Payment_Request__r.Unit__c;
                    receipt1.Credit_Account__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null : 
                                                 newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                                                 newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null; //Aayushi :SOB-403 added cdm cash condition
                    receipt1.Debit_Account__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Payment_Request__r.Account_Master__c:null:
                                                
                                                newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null;

                    receipt1.GL_Date__c = newSale.Payment_Request__r.Payment_Request__c !=null ?newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate1!=null? approvalDate1 : null:newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Payment_Request__r.Account_Received_Date__c : null:
                                            
                                            newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt1.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        					 newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount__c;  
                    receipt1.Payment_Request__c = newSale.Payment_Request__r.Payment_Request__c !=null ? newSale.Payment_Request__r.Payment_Request__c :newSale.Payment_Request__c ;
                    
                    if(newSale.Payment_Request__r.Payment_Request__c !=null){
                        if(originalAmt1 != '' && !originalAmt1.contains('AED')){
                        	receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        	receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt1.split(' ')[1]);
                    	}
                    }else{
                        
                        if(originalAmt != '' && !originalAmt.contains('AED')){
                            receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                            receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                        }
                    }
                    receiptToInsert.add(receipt1);
                     system.debug('I am gldate1'+receipt1.GL_Date__c);
                    
                    //receiptIdList.add(receipt1.Id);
                    //finishreceiptIdList.add(receipt1.ID);
                }
                if(newSale.DP_Amount_2__c != null && newSale.DP_Amount_2__c>0 ){
                    Receipt__c receipt3 = new Receipt__c();
                    receipt3.Booking__c = newSale.Booking__c;
                    receipt3.Project__c = newsale.Booking__r.Project__c;
                    receipt3.Receipt_Date__c = paymentRequestDate;
                    receipt3.Registration_Collection_Control_Report__c = 0;
                    receipt3.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    receipt3.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'){ //Aayushi :SOB-403 added cdm cash condition
                        receipt3.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt3.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'
                    ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'  ||newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed'; //Aayushi :SOB-403 added cdm cash condition
                    receipt3.Total_Amount__c = newSale.DP_Amount_2__c;
                    receipt3.Amount_Rs__c = newSale.DP_Amount_2__c;
                    receipt3.Mode__c = mode;
                    receipt3.Currency__c = curr;
                    receipt3.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt3.New_Sale_Approval__c =newSale.Id;
                    receipt3.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt3.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null; //Aayushi :SOB-403 added cdm cash condition
                    receipt3.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null; //Aayushi :SOB-403 added cdm cash condition
                    receipt3.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null; //Aayushi :SOB-403 added cdm cash condition
                    receipt3.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount_2__c;  
                    receipt3.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    receiptToInsert.add(receipt3);
                     system.debug('I am gldate2'+receipt3.GL_Date__c);
                    //finishreceiptIdList.add(receipt3.ID);
                    //receiptIdList.add(receipt3.Id);
                }
                if(newSale.DLD_Amount_2__c != null && newSale.DLD_Amount_2__c > 0){
                    Receipt__c receipt4 = new Receipt__c();
                    receipt4.Booking__c = newSale.Booking__c;
                    receipt4.Project__c = newsale.Booking__r.Project__c;
                    receipt4.Receipt_Date__c = paymentRequestDate;
                    receipt4.Registration_Collection_Control_Report__c = newSale.DLD_Amount_2__c;
                    receipt4.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    receipt4.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'){ //Aayushi :SOB-403 added cdm cash condition
                        receipt4.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt4.Receipt_Status__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'
                    ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' ||newSale.Payment_Request__r.Mode__c == 'CDM Cash' ?'Cleared':'UnProcessed'; //Aayushi :SOB-403 added cdm cash condition
                    receipt4.Total_Amount__c = newSale.DLD_Amount_2__c;
                    receipt4.Amount_Rs__c = newSale.DLD_Amount_2__c;
                    receipt4.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt4.Mode__c = mode;
                    receipt4.Currency__c = curr;
                    receipt4.New_Sale_Approval__c =newSale.Id;
                    receipt4.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt4.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null; //Aayushi :SOB-403 added cdm cash condition
                    receipt4.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null; //Aayushi :SOB-403 added cdm cash condition
                    receipt4.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null; //Aayushi :SOB-403 added cdm cash condition
                    receipt4.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount_2__c; 
                    receipt4.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt4.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt4.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    receiptToInsert.add(receipt4);
                    //finishreceiptIdList.add(receipt4.ID);
                    //receiptIdList.add(receipt4.Id);
                }
                /*
                commented as thertiary mode is not enabled for now
                if(newSale.DP_Amount_3__c != null && newSale.DP_Amount_3__c  > 0){
                    Receipt__c receipt5 = new Receipt__c();
                    receipt5.Booking__c = newSale.Booking__c;
                    receipt5.Project__c = newsale.Booking__r.Project__c;
                    receipt5.Receipt_Date__c = paymentRequestDate;
                    receipt5.Registration_Collection_Control_Report__c = newSale.DP_Amount_3__c;
                    receipt5.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    receipt5.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'){
                        receipt5.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt5.Receipt_Status__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                    receipt5.Total_Amount__c = newSale.DP_Amount_3__c;
                    receipt5.Amount_Rs__c = newSale.DP_Amount_3__c;
                    receipt5.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt5.Mode__c = mode;
                    receipt5.Currency__c = curr;
                    receipt5.New_Sale_Approval__c =newSale.Id;
                    receipt5.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt5.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null;
                    receipt5.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt5.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt5.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DP_Amount_3__c; 
                    receipt5.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt5.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt5.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    receiptToInsert.add(receipt5);
                    //finishreceiptIdList.add(receipt5.ID);
                    //receiptIdList.add(receipt5.Id);
                }
                if(newSale.DLD_Amount_3__c != null && newSale.DLD_Amount_3__c > 0){
                    Receipt__c receipt6 = new Receipt__c();
                    receipt6.Booking__c = newSale.Booking__c;
                    receipt6.Project__c = newsale.Booking__r.Project__c;
                    receipt6.Receipt_Date__c = paymentRequestDate;
                    receipt6.Registration_Collection_Control_Report__c = newSale.DLD_Amount_3__c;
                    receipt6.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                    receipt6.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                    if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'){
                        receipt6.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                    }
                    receipt6.Receipt_Status__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                    receipt6.Total_Amount__c = newSale.DLD_Amount_3__c;
                    receipt6.Amount_Rs__c = newSale.DLD_Amount_3__c;
                    receipt6.Opportunity__c =newSale.Booking__r.Opportunity__c;
                    receipt6.Mode__c = mode;
                    receipt6.Currency__c = curr;
                    receipt6.New_Sale_Approval__c =newSale.Id;
                    receipt6.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                    receipt6.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? tradeId.id:null;
                    receipt6.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?newSale.Payment_Request__r.Account_Master__c:null;
                    receipt6.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                    receipt6.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                        newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount_3__c; 
                    receipt6.Payment_Request__c = newSale.Payment_Request__c;
                    if(originalAmt != '' && !originalAmt.contains('AED')){
                        receipt6.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                        receipt6.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                    }
                    receiptToInsert.add(receipt6);
                    //finishreceiptIdList.add(receipt6.ID);
                    //receiptIdList.add(receipt6.Id);
                }*/
                /*if(receiptIdList != null && receiptIdList.size()>0){
                    newSale.Receipt_Created__c = true;
                    update newSale;
                }*/
                mapIdToNsa.put(newSale.id, newSale);
            }
            
        }   
            system.debug('~~Receipt To Insert: '+receiptToInsert);
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
                    system.debug('~~Receipt Created: '+result.getId());
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
                //finishreceiptIdList.add(r.id);
            } 
            update mapIdToNsa.values();
        }catch(Exception ex){
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'PaymentRequestReceiptCreation';
            insert logError;
            System.debug('Hi I am in catch block');
            String sMessage = '';
            sMessage += 'ERROR: ' + 'An exception has occurred while creating receipt -- '+ ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString();
        	system.debug('~~~~Error: '+sMessage);
            SendEmailForReceiptError.sendEmailMessage(sMessage);
        } 
    }    
    /*** EOF Create Receipt in Unit Level ***/
    
    /*public static void createReceiptUnitLevel(string newSaleApprovalName){
        list<string> receiptIdList =  new List<string>();
        Account_Master__c mainCashId = [SELECT ID FROM Account_Master__c WHERE Name =:'MAIN CASH' LIMIT 1];
        Account_Master__c tradeId = [SELECT ID FROM Account_Master__c WHERE Name =:'TRADE RECEIVABLE' LIMIT 1];
        string curr = '';
        string originalAmt = '';
        unit_hold_request__c newSale = [SELECT Id,Approval_Status__c,Payment_Request__r.Date_of_Initiation__c,Payment_Request__r.Currency__c,Payment_Request__r.Original_Amount__c,Booking__c,DP_Amount_2__c,DLD_Amount_2__c,Booking__r.Unit__r.Name,Booking__r.Project__c,Payment_Request__r.Payment_Transaction_Tracking_Id__c,Payment_Request__r.Account_Received_Date__c,Payment_Request__r.Approved_Date_and_Time__c,Payment_Request__r.Account_Master__c,Payment_Request__r.Instrument_Date__c,Payment_Request__r.Instrument_Number__c,Payment_Request__r.Reference_Number__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__c,Payment_Request__r.Payment_Transaction_Number__c,Payment_Request__r.CreatedDate,Payment_Request__r.Unit__c,DLD_Amount__c,Payment_Request__r.Cheque_Date__c,Payment_Request__r.Cheque_No__c,Payment_Request__c,Payment_Request__r.Mode__c,DP_Amount__c,Mode__c,(select id from Receipts__r) FROM unit_hold_request__c WHERE Name =: newSaleApprovalName and Booking__c != null and Approval_Status__c='Approved' LIMIT 1];
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
        String mode = '';
        if(newSale.Payment_Request__r.Mode__c == 'CDM Cheque'){
            mode = 'CDM-cheque';
            curr = newSale.Payment_Request__r.Currency__c;
        }else if(newSale.Payment_Request__r.Mode__c == 'CDM Cash'){
            mode = 'CDM-cash';
            curr = newSale.Payment_Request__r.Currency__c;
        }else if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){
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
        if(receiptList.isEmpty() ||receiptList.size() < 1 ){
            if(newSale.DP_Amount__c != null && newSale.DP_Amount__c>0 ){
                Receipt__c receipt = new Receipt__c();
                receipt.Booking__c = newSale.Booking__c;
                receipt.Project__c = newsale.Booking__r.Project__c;
                receipt.Receipt_Date__c = paymentRequestDate;
                receipt.Registration_Collection_Control_Report__c = 0;
                receipt.Cheque_DD__c = newSale.Payment_Request__r.Mode__c == 'Website'?newSale.Payment_Request__r.Payment_Transaction_Tracking_Id__c:String.isBlank(newSale.Payment_Request__r.Cheque_No__c)?String.isBlank(newSale.Payment_Request__r.Instrument_Number__c)?String.isBlank(newSale.Payment_Request__r.Reference_Number__c)?String.isBlank(newSale.Payment_Request__r.Payment_Transaction_Number__c)?'':newSale.Payment_Request__r.Payment_Transaction_Number__c:newSale.Payment_Request__r.Reference_Number__c:newSale.Payment_Request__r.Instrument_Number__c:newSale.Payment_Request__r.Cheque_No__c;
                receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Cheque_Date__c== null ?newSale.Payment_Request__r.Instrument_Date__c== null ?paymentRequestDate : newSale.Payment_Request__r.Instrument_Date__c : newSale.Payment_Request__r.Cheque_Date__c;
                if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c== 'Domestic Wire Transfer'){//SOB-403 aayushi added cdm cash conditopon
                    receipt.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                }
                receipt.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' 
                ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'  || newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 aayushi added cdm cash conditopon
                receipt.Total_Amount__c = newSale.DP_Amount__c;
                receipt.Amount_Rs__c = newSale.DP_Amount__c;
                receipt.Mode__c = mode;
                receipt.Currency__c = curr;
                receipt.Opportunity__c =newSale.Booking__r.Opportunity__c;
                receipt.New_Sale_Approval__c =newSale.Id;
                receipt.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                receipt.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 aayushi added cdm cash conditopon
                receipt.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c== 'Domestic Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;//SOB-403 aayushi added cdm cash conditopon
                receipt.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? 
                approvalDate!=null? approvalDate : null :
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 aayushi added cdm cash conditopon
                receipt.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                    newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount__c; 
                receipt.Payment_Request__c = newSale.Payment_Request__c;
                if(originalAmt != '' && !originalAmt.contains('AED')){
                    receipt.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                    receipt.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                }
                insert receipt;
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
                if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 aayushi added cdm cash conditopon
                    receipt1.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                }
                receipt1.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c =='International Wire Transfer'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
                ||newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';
                receipt1.Total_Amount__c = newSale.DLD_Amount__c;
                receipt1.Amount_Rs__c = newSale.DLD_Amount__c;
                receipt1.Opportunity__c =newSale.Booking__r.Opportunity__c;
                receipt1.Mode__c = mode;
                receipt1.Currency__c = curr;
                receipt1.New_Sale_Approval__c =newSale.Id;
                receipt1.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                receipt1.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 aayushi added cdm cash conditopon
                receipt1.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? mainCashId.id:
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;//SOB-403 aayushi added cdm cash conditopon
                receipt1.GL_Date__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? 
                approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 aayushi added cdm cash conditopon
                receipt1.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount__c; 
                receipt1.Payment_Request__c = newSale.Payment_Request__c;
                if(originalAmt != '' && !originalAmt.contains('AED')){
                    receipt1.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                    receipt1.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                }
                insert receipt1; 
                
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
                if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 aayushi added cdm cash conditopon
                    receipt3.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                }
                receipt3.Receipt_Status__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
                ||newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 aayushi added cdm cash conditopon
                receipt3.Total_Amount__c = newSale.DP_Amount_2__c;
                receipt3.Amount_Rs__c = newSale.DP_Amount_2__c;
                receipt3.Mode__c = mode;
                receipt3.Currency__c = curr;
                receipt3.Opportunity__c =newSale.Booking__r.Opportunity__c;
                receipt3.New_Sale_Approval__c =newSale.Id;
                receipt3.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                receipt3.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;//SOB-403 aayushi added cdm cash conditopon
                receipt3.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? 
                mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;//SOB-403 aayushi added cdm cash conditopon
                receipt3.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? 
                approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c== 'Domestic Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;//SOB-403 aayushi added cdm cash conditopon
                receipt3.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                newSale.Booking__r.Unit__r.Name+' against DP Charges '+newSale.DP_Amount_2__c;  
                receipt3.Payment_Request__c = newSale.Payment_Request__c;
                if(originalAmt != '' && !originalAmt.contains('AED')){
                    receipt3.Foreign_Currency_Type__c = originalAmt.split(' ')[0];
                    receipt3.Amount_in_Foreign_Currency__c = Double.valueOf(originalAmt.split(' ')[1]);
                }
                insert receipt3;
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
                if(newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'){//SOB-403 aayushi added cdm cash conditopon
                    receipt4.Cheque_DD_Date__c = newSale.Payment_Request__r.Date_of_Initiation__c;
                }
                receipt4.Receipt_Status__c =newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' ||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'
                ||newSale.Payment_Request__r.Mode__c == 'CDM Cash'?'Cleared':'UnProcessed';//SOB-403 aayushi added cdm cash conditopon
                receipt4.Total_Amount__c = newSale.DLD_Amount_2__c;
                receipt4.Amount_Rs__c = newSale.DLD_Amount_2__c;
                receipt4.Opportunity__c =newSale.Booking__r.Opportunity__c;
                receipt4.Mode__c = mode;
                receipt4.Currency__c = curr;
                receipt4.New_Sale_Approval__c =newSale.Id;
                receipt4.Project_Unit__c = newSale.Payment_Request__r.Unit__c;
                receipt4.Credit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'||
                newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? tradeId.id:null;
                receipt4.Debit_Account__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? 
                mainCashId.id:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c== 'Domestic Wire Transfer'?newSale.Payment_Request__r.Account_Master__c:null;
                receipt4.GL_Date__c = newSale.Payment_Request__r.Mode__c == 'OTC Deposits'? approvalDate!=null? 
                approvalDate : null:newSale.Payment_Request__r.Mode__c == 'International Wire Transfer' || newSale.Payment_Request__r.Mode__c == 'CDM Cash'||newSale.Payment_Request__r.Mode__c == 'Domestic Wire Transfer'? newSale.Payment_Request__r.Account_Received_Date__c : null;
                receipt4.RemarksText__c ='Received from '+newSale.Booking__r.Primary_Applicant_Name__c +' Unit '+
                    newSale.Booking__r.Unit__r.Name+' against DLD Charges '+newSale.DLD_Amount_2__c; 
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
            
            if(receiptIdList != null && receiptIdList.size()>0){
                ReceiptUtil.sendEmailToUser(receiptIdList);
            }
        }
    } */
    
    @future(callout=true)
    public static void sendEmailToUser(list<string> receiptIdList){
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
                                         
        PaymentRequestReceiptEmail.sendAttachedReceiptbatch(receipts); 
    }
}