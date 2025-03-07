public class PaymentRequestReallocationJob {
    
    @AuraEnabled
    public static void emitPR_ReallocationEvent(String prId){
        if(prId == NULL || String.isBlank(prId)) return;
		EventBus.publish(new PR_Reallocation__e(PR_Id__c = prId));
    }
    
    public static void initiate(Set<Id> prIds){
        if(prIds == null || prIds.isEmpty()) return;
        Savepoint sp = Database.setSavepoint(); 
        try{
            initiateProcess(prIds);
        }catch(Exception ex){
            Database.rollback(sp);
            insert new Error_Log__c(Name = 'PaymentRequestReallocationJob',Message__c = 'Context instance - \nprIds - '+prIds+'\n\nException - \n'+ex.getCause()+' : '+ex.getMessage()+'\n@ '+ex.getStackTraceString());
        }
    }
    
    public static void initiateProcess(Set<Id> prIds){
        Map<String,String> mapOfAccountAndName = getMapOfAccountAndName();
        Map<Id,Id> offerToBooking = new Map<Id,Id>();
        List<Interim_Payments__c> ips = new List<Interim_Payments__c>();
        
        List<Interim_Payments__c> iprs = new List<Interim_Payments__c>();
        List<PropStrength__Received_Payment__c> payments = new List<PropStrength__Received_Payment__c>();
        for(SObject iprObj : Database.queryWithBinds('SELECT id,(SELECT id FROM Interim__r WHERE PropStrength__Receipt_Reversed__c != TRUE) FROM Interim_Payments__c WHERE Payment_Request__c IN :prIds',new Map<String,Object>{'prIds'=>prIds},AccessLevel.SYSTEM_MODE)){
            Interim_Payments__c ipr = (Interim_Payments__c) iprObj;
            ipr.Approval_Status_Interim__c = 'Rejected';
            iprs.add(ipr);
            for(PropStrength__Received_Payment__c payment : ipr.Interim__r){
                payment.PropStrength__Receipt_Reversed__c = true;
                payments.add(payment);
            }
        }
        update payments;//on purpose kept as statement dml to let it cause a rollback on failure 
        update iprs;//on purpose kept as statement dml to let it cause a rollback on failure 
        
        Id pReceivedRT = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id icReceivedRT = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        
        for(SObject prObj : Database.queryWithBinds('SELECT id,Account_Master__c,Bank_Name__c,Mode__c,Secondary_Mode__c,CreatedDate,Cheque_No__c,Cheque_Date__c,Instrument_Date__c,Instrument_Number__c,Date_of_Initiation__c,Account_Received_Date__c,Approved_Date_and_Time__c,Others__c,Application_Booking__c,Towards_Unit_Price_Amount__c,Towards_Pre_Registration_Amount__c,Towards_Other_Charges_Amount__c FROM Payment_Request__c WHERE Id IN :prIds',new Map<String,Object>{'prIds'=>prIds},AccessLevel.SYSTEM_MODE)){
            Payment_Request__c pr = (Payment_Request__c) prObj;
            
            String status = '';
            Id debitAccountId = null;
            Id creditAccountId = null;
            String mode = pr.Mode__c;
            Date intPayInstDate = System.Today();
            String intPayInstNumber = '';
            DateTime chequeDate;
            if(mode == 'IWT(International)' || mode == 'DWT(Domestic)' || mode == 'CDM Cash (Cash Deposit in Machine)'){
                chequeDate = pr.Date_of_Initiation__c;
            }else if(mode == 'Cheque'){
                chequeDate = pr.Cheque_Date__c;
            }else if(mode == 'CDM Cheque (Cash Deposit in Machine)' || mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card'){
                chequeDate = pr.Instrument_Date__c;
            }else if(mode == 'Website'){
                chequeDate = pr.CreatedDate;
            }
            
            
            if(pr.Cheque_Date__c != null) {
                intPayInstDate = pr.Cheque_Date__c;
            } else if(pr.Instrument_Date__c != null) {
                intPayInstDate = pr.Instrument_Date__c;
            }
            
            if(pr.Cheque_No__c != null) {
                intPayInstNumber = pr.Cheque_No__c;
            } else if(pr.Instrument_Number__c != null) {
                intPayInstNumber = pr.Instrument_Number__c;
            }
            if(mode == 'IWT(International)' || mode == 'DWT(Domestic)' || mode == 'CDM Cash (Cash Deposit in Machine)' || mode == 'OTC Deposits(Cash counter)'){
                status = 'Approved';
                debitAccountId = pr.Account_Master__c ;
                if(mode == 'OTC Deposits(Cash counter)'){
                    debitAccountId = mapOfAccountAndName.get('MAIN CASH');
                }
            }else{
                if(mode == 'CDM Cheque (Cheque Deposit in Machine)'){
                    debitAccountId = pr.Account_Master__c;
                }
                status = 'UnProcessed';
            }
            
            Double dpAmount = pr.Towards_Unit_Price_Amount__c == NULL ? 0 : pr.Towards_Unit_Price_Amount__c;
            Double dldAmount = pr.Towards_Pre_Registration_Amount__c == NULL ? 0 : pr.Towards_Pre_Registration_Amount__c;
            Double ocAmount = pr.Towards_Other_Charges_Amount__c == NULL ? 0 : pr.Towards_Other_Charges_Amount__c;
            String ocType = pr.Others__c == NULL ? '' : pr.Others__c;
            
            if(dpAmount > 0) {//dp
                ips.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c,
                                                Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,                                   
                                                Instrument_Number__c = intPayInstNumber, Instrument_Date__c = intPayInstDate, 
                                                Payment_Request__c = pr.Id, Payment_Date_Interim__c = System.Today(), 
                                                Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                RecordTypeId = pReceivedRT, Amount_Interim__c = Double.valueOf(dpAmount), 
                                                Amount_Type__c = 'Installment',Approval_Status_Interim__c = status,
                                                Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE'))
                       );
            }
            
            if(dldAmount > 0 ) {//dld
                ips.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c,
                                                Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,
                                                Instrument_Number__c = intPayInstNumber, Instrument_Date__c = intPayInstDate, 
                                                Payment_Request__c = pr.Id, Payment_Date_Interim__c = System.Today(), 
                                                Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                RecordTypeId = icReceivedRT, 
                                                Amount_Interim__c = Double.valueOf(dldAmount), Amount_Type__c = 'DLD Fees',
                                                Approval_Status_Interim__c = status, 
                                                Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE'))
                       );
            }
            
            if(ocAmount > 0 ) {//ocs
                ips.add(new Interim_Payments__c(Payment_Mode_Interim__c = mode,Bank_Name_Interim__c = pr.Bank_Name__c,
                                                Receipt_Date__c = PR.CreatedDate,Cheque_Date__c = chequeDate,
                                                Instrument_Number__c = intPayInstNumber, Instrument_Date__c = intPayInstDate, 
                                                Payment_Request__c = pr.Id, Payment_Date_Interim__c = System.Today(), 
                                                Cheque_Demand_Draft_Number_Interim__c = pr.Cheque_No__c, 
                                                Application_Booking_Interim__c = pr.Application_Booking__c, 
                                                RecordTypeId = icReceivedRT, 
                                                Amount_Interim__c = Double.valueOf(ocAmount), Amount_Type__c = ocType,
                                                Approval_Status_Interim__c = status, 
                                                Debit_Account__c = debitAccountId, Credit_Account__c = mapOfAccountAndName.get('TRADE RECEIVABLE')));
            }
            
            
            if(ips.isEmpty()) return;
            
            insert ips;//on purpose kept as statement dml to let it cause a rollback on failure 
            
        }
        
    }
    
    //UTILS
    static Map<String,String> getMapOfAccountAndName(){
        Map<String,String> amNameToIdMap = new Map<String,String>();
        List<Account_Master__c > listOfAccountMaster = [SELECT Id, name from Account_Master__c where Name = 'TRADE RECEIVABLE' or Name = 'MAIN CASH'];
        for(Account_Master__c accMasterRec : listOfAccountMaster){
            amNameToIdMap.put(accMasterRec.Name , accMasterRec.Id);
        }
        return amNameToIdMap;
    }
}