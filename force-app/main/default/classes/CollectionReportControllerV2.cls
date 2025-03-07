public with sharing class CollectionReportControllerV2 implements Database.Batchable<SObject>,Schedulable{
    static final Integer DEFAULT_SCOPE = 1; 
    Integer scope;

    @TestVisible private static Boolean recursiveRun = false;
    static String errorLogs;

    //CONTROLLER
    public CollectionReportControllerV2(){
        this.scope = DEFAULT_SCOPE;
    }
    
    public CollectionReportControllerV2(Integer scope){
        this.scope = scope == NULL || scope < 1 || scope > 2000 ? DEFAULT_SCOPE : scope ;
    }

    //SCHEDULABLE
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this,this.scope);
    }

    //BATCHABLE
    public Database.QueryLocator start(Database.BatchableContext dbCon){
        return Database.getqueryLocator('SELECT id,Name FROM Booking__c ORDER BY LastModifiedDate DESC');
    }
    public void execute(Database.BatchableContext dbCon,List<Booking__c> bookings){
        Set<String> bookingNames = new Set<String>();
        for(Booking__c booking : bookings){bookingNames.add(booking.Name);}
        if(!bookingNames.isEmpty()) CollectionReportControllerV2.dateCalculation(new List<String>(bookingNames));
    }
    public void finish(Database.BatchableContext dbCon){}

    //PROCESSes
    public static void dateCalculation(List<String> bookingsList){
        if(recursiveRun) return;
        recursiveRun = true;
        
        if(bookingsList == NULL || bookingsList.isEmpty()) return;
        
        try{
            Database.SaveResult[] dbSRs = dateCalculationInternal(bookingsList);
            if(dbSRs == null){
                logError('\n dbSRs == null');
            }else{
                for(Database.SaveResult dbSR : dbSRs){
                    if(!dbSR.isSuccess()){
                        logError('\n'+dbSR.getId()+' - '+dbSR.getErrors());
                    }
                }
            }
        }catch(Exception ex){
            logError('\n Exception Occurred - '+ex.getTypeName()+'\n Cause - '+ex.getMessage()+'\n @ '+ex.getStackTraceString()+'\n Exception instance - '+ex);
        }

        if(String.isNotBlank(errorLogs)){
            Error_Log__c el = new Error_Log__c(Name = 'CollectionReportControllerV2 '+DateTime.now());
            el.Message__c = 'Error with Bookings - \n'+String.join(bookingsList,'\n')+errorLogs;
            insert el;
        }
    }

    public static Database.SaveResult[] dateCalculationInternal(List<String> bookingsList){

        List<Booking__c> bookingDataList = new List<Booking__c>();
        List<Collection_Report__c> createCRList = new List<Collection_Report__c>();
        
        Map<String,Booking__c> bookingMap = new Map<String,Booking__c>();
        Map<string,Collection_Report__c> crMap = new Map<string,Collection_Report__c>();
        Map<id,Collection_Report__c> updatecrMap = new Map<id,Collection_Report__c>();
        
        List<Collection_Report__c> cRList = new List<Collection_Report__c>();
        Map<string,List<Finance_Report_Records__c>> bookingfrrMap = new Map<string,List<Finance_Report_Records__c>>();
        List<String> statusList = new List<String>{'UnProcessed','Processed-Sent for Banking','Physical Verification Rejected','Cleared','Cancelled'};
        List<String> DCList = new List<String>{'Receipt','Credit Note'};
        List<String> DList = new List<String>{'Debit Note'};

        bookingDataList = [SELECT Id,Agreement_Value__c,Unit__r.Name,Primary_Applicant_Name__c,Name FROM Booking__c 
                            WHERE Name IN : bookingsList];
        
        Map<String,List<Finance_Report_Records__c>> bookingWithFinanceListMap = new Map<String,List<Finance_Report_Records__c>>();

        for(Finance_Report_Records__c frrRec : [SELECT Id,Booking_No__c,Receipt_Status__c,Credit_Amount_AED_Corp__c,Credit_Amount_AED_Reg__c, Credit_Amount_AED_Unitwise__c,Debit_Account_Name__c,Receipt_Mode__c,GL_Date__c,Receipt_Date__c,
                    Document_Category_New__c,Registration_Collection_Control_Report__c,Description__c,Debit_Amount_AED__c,Customer_Name__c,Receipt_Rejection_Description__c
                    FROM Finance_Report_Records__c WHERE Booking_No__c IN : bookingsList and (NOT Customer_Name__c  like '%test%') and
                    (Document_Category_New__c IN : DList OR (Document_Category_New__c IN : DCList and Receipt_Status__c IN :statusList) )
                    ORDER BY Date_For_Collection_Report__c asc]){
            if(!bookingWithFinanceListMap.containsKey(frrRec.Booking_No__c)){
                bookingWithFinanceListMap.put(frrRec.Booking_No__c, new List<Finance_Report_Records__c>());
            }
            bookingWithFinanceListMap.get(frrRec.Booking_No__c).add(frrRec);
        }
        
        Shoba_Default_Settings__mdt sobhametadata = [SELECT Collection_Report_Account_Names__c,
                                                        QualifiedApiName
                                                        FROM Shoba_Default_Settings__mdt
                                                        WHERE QualifiedApiName = 'Org_Defaults'
                                                        LIMIT 1];
        
        List<String> creditAccountValues = sobhametadata.Collection_Report_Account_Names__c.split(',');
        
        for(Booking__c bookingdata : bookingDataList){
            bookingMap.put(bookingdata.name,bookingData);
        }
        
        cRList = [SELECT Id,X10_As_Per_GL_Date__c,X10_As_Per_Receipt_Date__c,X20_As_Per_GL_Date__c,X20_As_Per_Receipt_Date__c,
                    booking__c,Total_Paid_Amount__c FROM Collection_Report__c WHERE Booking__c IN : bookingsList];
        
        for(Collection_Report__c crrec : cRList){ crMap.put(crrec.booking__c,crrec); }
        
        if(bookingWithFinanceListMap.size() > 0){
            for(String bookingNo : bookingWithFinanceListMap.keySet()){
                for(Finance_Report_Records__c fr : bookingWithFinanceListMap.get(bookingNo)){
                    if((fr.Receipt_Status__c == 'UnProcessed' && fr.Receipt_Mode__c == 'Credit Note') || fr.Receipt_Status__c != 'UnProcessed'){   
                        if((fr.Document_Category_New__c != 'Credit Note' && fr.Document_Category_New__c != 'Debit Note') || ((fr.Document_Category_New__c == 'Credit Note' || fr.Document_Category_New__c == 'Debit Note') && !creditAccountValues.contains(fr.Debit_Account_Name__c))){
                            if(fr.Document_Category_New__c != 'Debit Note' || (fr.Document_Category_New__c == 'Debit Note' && ((fr.Description__c == null || fr.Description__c == '') || (fr.Description__c != null && !(fr.Description__c.containsIgnoreCase('Debit note for DLD charges')))))){
                                if(fr.Document_Category_New__c != 'Credit Note' || (fr.Document_Category_New__c == 'Credit Note' &&  ((fr.Receipt_Rejection_Description__c == null || fr.Receipt_Rejection_Description__c == '')|| (fr.Receipt_Rejection_Description__c != null && !(fr.Receipt_Rejection_Description__c.containsIgnoreCase('Credit Note for Demand Rejection')))))){
                                    if(bookingfrrMap.containsKey(fr.Booking_No__c) && bookingfrrMap.get(fr.Booking_No__c) != null){
                                        bookingfrrMap.get(fr.Booking_No__c).add(fr);
                                    }
                                    else{
                                        bookingfrrMap.put(fr.Booking_No__c, new List<Finance_Report_Records__c> {fr});
                                    }
                                }
                            }
                        }
                    }
                }
                if(!bookingfrrMap.containsKey(bookingNo)){
                    Collection_Report__c updatecrToBlank = crMap.containsKey(bookingNo)?crMap.get(bookingNo):null;
                    if(updatecrToBlank != null){
                        updatecrToBlank.X10_As_Per_GL_Date__c = null;
                        updatecrToBlank.X20_As_Per_GL_Date__c = null;
                        updatecrToBlank.X10_As_Per_Receipt_Date__c = null;
                        updatecrToBlank.X20_As_Per_Receipt_Date__c = null;
                        updatecrToBlank.Total_Paid_Amount__c = 0;
                        updatecrToBlank.Total_DLD_Amount_Paid__c = 0;
                        updatecrMap.put(updatecrToBlank.Id,updatecrToBlank);
                    }
                }
            }
        }
        
        //Frr with GL date ordered by ASC        
        for(string currentBooking : bookingfrrMap.keyset()){
            try{
                List<Finance_Report_Records__c> frrdataList = new List<Finance_Report_Records__c>();
                frrdataList=bookingfrrMap.get(currentBooking);
                Decimal receiptAmountSummation = 0;
                Decimal receiptAmount = 0;
                Decimal PaidPercentage = 0;
                Decimal totalDLDAmountPaid = 0;
                String bookingName='';
                String unitName='';
                String customerName='';
                Decimal agreementValue = 0;
                Decimal dldPaidValue = 0;
                Decimal dldPercentageValue = 0;
                Decimal dld4PercentValue = 0;
                
                Collection_Report__c updatecr = crMap.containsKey(currentBooking)?crMap.get(currentBooking):null;
                Date GLDate10 = null;
                Date ReceiptDate10 = null;
                Date GLDate20 = null;
                Date ReceiptDate20 = null;
                
                Date final10GLDate = null;
                Date final10ReceiptDate = null;
                Date final20GLDate = null;
                Date final20ReceiptDate = null;
                Date DLDDateForBooking = null;
                Booking__c Booking = new Booking__c();
                
                if(bookingMap.containsKey(currentBooking)){
                    Booking = bookingMap.get(currentBooking);
                    bookingName = booking.name;
                    unitName = booking.Unit__r.Name;
                    customerName= booking.Primary_Applicant_Name__c;
                    agreementValue= booking.Agreement_Value__c;
                    dld4PercentValue = booking.Agreement_Value__C * 0.04;
                }

                for(Finance_Report_Records__c frr : frrdataList){
                    if(frr.Document_Category_New__c != 'Debit Note'){
                        if(frr.Credit_Amount_AED_Unitwise__c != null && frr.Credit_Amount_AED_Unitwise__c > 0){
                            if(frr.Receipt_Status__c != 'Cancelled'){
                                receiptAmountSummation = receiptAmountSummation + frr.Credit_Amount_AED_Unitwise__c;
                                if(frr.Registration_Collection_Control_Report__c != null && frr.Registration_Collection_Control_Report__c >0){  
                                    receiptAmountSummation = receiptAmountSummation - frr.Registration_Collection_Control_Report__c;
                                    totalDLDAmountPaid = totalDLDAmountPaid + frr.Registration_Collection_Control_Report__c;
                                    dldPaidValue = dldPaidValue + frr.Registration_Collection_Control_Report__c;
                                    DLDDateForBooking = frr.GL_Date__c;
                                }
                            }
                            else if(frr.Receipt_Status__c == 'Cancelled'){ receiptAmountSummation = receiptAmountSummation + 0; }
                            
                        }
                    }else {
                        if(frr.Debit_Amount_AED__c != null && frr.Debit_Amount_AED__c > 0){
                            Decimal debitAmount = frr.Debit_Amount_AED__c;
                            if(frr.Registration_Collection_Control_Report__c != null && frr.Registration_Collection_Control_Report__c >0){
                                debitAmount = debitAmount - frr.Registration_Collection_Control_Report__c;
                                totalDLDAmountPaid = totalDLDAmountPaid - frr.Registration_Collection_Control_Report__c;
                            }
                            receiptAmountSummation = receiptAmountSummation - debitAmount; 
                        }
                    }
                    if(agreementValue > 0 && receiptAmountSummation != 0){
                        paidPercentage = (receiptAmountSummation / booking.Agreement_Value__c)*100;
                        paidPercentage = (paidPercentage != NULL && paidPercentage > 0) ? Math.round(paidPercentage * 100.0)/100.0 : 0.0;
                        //round off logic -> 1234.567 => 123456.7 => 123457 => 1234.57

                        if(paidPercentage >=9.9 && paidPercentage < 19.9){
                            ReceiptDate10 = ReceiptDate10 == null ? frr.Receipt_Date__c : ReceiptDate10;
                            GLDate10 = GLDate10 == null ? frr.GL_Date__c : GLDate10;
                        }
                        else if(paidPercentage >=19.9){
                            ReceiptDate20 = ReceiptDate20 == null ? frr.Receipt_Date__c : ReceiptDate20;
                            GLDate20 = GLDate20 == null ? frr.GL_Date__c : GLDate20;
                            ReceiptDate10 = ReceiptDate10 == null ? frr.Receipt_Date__c : ReceiptDate10;
                            GLDate10 = GLDate10 == null ? frr.GL_Date__c : GLDate10;       
                        }         
                    }
                    if(agreementValue > 0 && dldPaidValue > 0){
                        dldPercentageValue = (dldPaidValue / booking.Agreement_Value__C) * 100 ; 
                        String textDld = dldPercentageValue+'';
                        String truncatedNumber = textDld.subString(0,textDld.indexOf('.')+3);
                        if(textDld != null && textDld.contains('.')){
                            dldPercentageValue = Decimal.valueOf(truncatedNumber);
                        }else{
                            dldPercentageValue = Decimal.valueOf(textDld);
                        }
                    }
                }
                
                if(receiptAmountSummation == 0){
                    ReceiptDate10 = null; GLDate10 = null; ReceiptDate20 = null; GLDate20 = null;
                }
                final10GLDate = GLDate10;
                final20GLDate = GLDate20;
                final10ReceiptDate = ReceiptDate10 != null ? ReceiptDate10 : GLDate10;
                final20ReceiptDate = ReceiptDate20 != null ? ReceiptDate20 : GLDate20;
                                
                if(updatecr != null){
                    updatecr.X10_As_Per_GL_Date__c = final10GLDate;
                    updatecr.X20_As_Per_GL_Date__c = final20GLDate;
                    updatecr.X10_As_Per_Receipt_Date__c = final10ReceiptDate;
                    updatecr.X20_As_Per_Receipt_Date__c = final20ReceiptDate;
                    updatecr.Total_Paid_Amount__c = receiptAmountSummation;
                    updatecr.Total_DLD_Amount_Paid__c = totalDLDAmountPaid;
                    updatecr.DLD_Received__c = dldPercentageValue;
                    updatecr.Latest_GL_Date_for_DLD_Paid__c = DLDDateForBooking;
                    updatecrMap.put(updatecr.Id,updatecr);
                }else{
                    Collection_Report__c crRecord = new Collection_Report__c();
                    crRecord.booking__c = bookingName;
                    crRecord.Unit__c = UnitName;
                    crRecord.Customer_Name__c = customerName;
                    crRecord.Total_Amount__c = AgreementValue;
                    crRecord.X10_As_Per_GL_Date__c = final10GLDate;
                    crRecord.X20_As_Per_GL_Date__c = final20GLDate;
                    crRecord.X10_As_Per_Receipt_Date__c = final10ReceiptDate;
                    crRecord.X20_As_Per_Receipt_Date__c = final20ReceiptDate;
                    crRecord.Total_Paid_Amount__c = receiptAmountSummation;
                    crRecord.Total_DLD_Amount_Paid__c = totalDLDAmountPaid;
                    crRecord.DLD_Received__c = dldPercentageValue;
                        crRecord.Latest_GL_Date_for_DLD_Paid__c = DLDDateForBooking;
                    createCRList.add(crRecord);
                }
            }catch(Exception ex){
                logError('\nException Occurred for Booking - '+currentBooking+'\n Exception Type - '+ex.getTypeName()+'\n Cause - '+ex.getMessage()+'\n @ '+ex.getStackTraceString()+'\n Exception instance - '+ex);
            }
        }

        Database.SaveResult[] resultLstPM;
        if(updatecrMap.values() != null && !updatecrMap.values().isEmpty()){
            resultLstPM = Database.update(updatecrMap.values(),false);
        }

        if(createCRList != null && !createCRList.isEmpty()){
            resultLstPM = Database.insert(createCRList,false);
        }
        if(resultLstPM == NULL && (createCRList == null || createCRList.isEmpty()) && (updatecrMap.values() == null || updatecrMap.values().isEmpty())){
            resultLstPM = new List<Database.SaveResult>();
        }
        return resultLstPM;
    }

    //HELPERs
    @TestVisible static void logError(String errorLog){
        if(String.isBlank(errorLog)) return;
        errorLogs = errorLogs == NULL ? errorLog : errorLogs+'\n'+errorLog;
    }
}