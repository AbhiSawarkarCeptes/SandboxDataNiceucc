public without sharing class TriggerFinanceReportRecordHandler {
    
    public static boolean afterUpdateTriggerFRRFirstRun = true;
    public static boolean afterInsertTriggerFRRFirstRun = true;
    
    public static boolean afterUpdateTriggerDemandFirstRun = true;
    public static boolean afterInsertTriggerDemandFirstRun = true;
    
    public static boolean afterTriggerReceiptFirstRun = true;
    
    public static void UpdateFRR(List<Id> rdIdSet) {
        List<Finance_Report_Records__c> frrList = new List<Finance_Report_Records__c>();
        Shoba_Default_Settings__mdt sobhametadata = [SELECT Credit_Note_Account_Type__c,Debit_Note_Account_Type__c,
                                                     QualifiedApiName
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        List<String> creditAccountValues = sobhametadata.Credit_Note_Account_Type__c.split(',');
        List<String> debitAccountValues = sobhametadata.Debit_Note_Account_Type__c.split(',');
        
        frrList = [SELECT Id, Name,Document_Category_New__c,Booking_No__c,Receipt_Status__c,Is_Recent_Finance_Report_Record__c,
                   Debit_Amount_AED__c,Credit_Amount_AED_Unitwise__c,Total_Amount__c,
                   Registration_Collection_Control_Report__c,Debit_Account_Name__c,Demand_Status__c
                   FROM Finance_Report_Records__c 
                   WHERE id in :rdIdSet];
        
        system.debug('I am frrlist->'+frrList);
        Map<String,List<Finance_Report_Records__c>> frrMap = new Map<String,List<Finance_Report_Records__c>>();        
        Set<String> bookingNumberSet = new Set<String>();
        
        //Fetch unique list of booking ids
        for(Finance_Report_Records__c fr : frrList){
            bookingNumberSet.add(fr.Booking_No__c);
            /**if(fr.Document_Category_New__c == 'Credit Note' || fr.Document_Category_New__c == 'Receipt'){
if(fr.Receipt_Status__c == 'Cleared' && !creditAccountValues.contains(fr.Debit_Account_Name__c)){
bookingNumberSet.add(fr.Booking_No__c);
}
}else if(fr.Document_Category_New__c == 'Debit Note' || fr.Document_Category_New__c == 'Invoice'){
if(fr.Demand_Status__c == 'Reversed' && !debitAccountValues.contains(fr.Debit_Account_Name__c)){
bookingNumberSet.add(fr.Booking_No__c);
}
}*/
        }
        
        system.debug('I am bookinglist->'+bookingNumberSet);
        
        //fetch all related frrs according to booking ids
        List<Finance_Report_Records__c> getAllfrrs = [Select Id, Name,Document_Category_New__c,Booking_No__c,Receipt_Status__c,
                                                      Is_Recent_Finance_Report_Record__c,
                                                      Debit_Amount_AED__c,Credit_Amount_AED_Unitwise__c,Total_Amount__c,
                                                      Registration_Collection_Control_Report__c,Demand_Status__c,Debit_Account_Name__c
                                                      FROM Finance_Report_Records__c 
                                                      WHERE Booking_No__c IN :bookingNumberSet
                                                      ORDER BY CreatedDate desc
                                                      LIMIT 50000];
        System.debug('I am  getallfrrs-->'+ getAllfrrs);
        
        //Assign all frrs to a map
        for(Finance_Report_Records__c fr : getAllfrrs){
            if(frrMap.containsKey(fr.Booking_No__c)){
                frrMap.get(fr.Booking_No__c).add(fr);
            }else {
                frrMap.put(fr.Booking_No__c, new List<Finance_Report_Records__c> {fr});
            }
        }
        
        Map<Id,Finance_Report_Records__c> updatedvaluesMap = new Map<Id,Finance_Report_Records__c>();
        Decimal TotalAmount = 0;
        Decimal netAmount = 0;
        Decimal receiptAmount=0;
        Boolean flag = false;
        
        //calculate total amount and update recently modified record
        for(String booking : frrMap.keyset()){
            TotalAmount=0;
            netAmount=0;
            receiptAmount=0;
            flag=false;
            List<Finance_Report_Records__c> onebookingfrr = new List<Finance_Report_Records__c>();
            onebookingfrr=frrMap.get(booking);
            
            System.debug('i am onebookingfrr-->'+onebookingfrr);
            for(Finance_Report_Records__c fetchedfr : onebookingfrr){
                if(fetchedfr.Document_Category_New__c == 'Credit Note' || fetchedfr.Document_Category_New__c == 'Receipt'){
                    if(fetchedfr.Receipt_Status__c == 'Cleared'&& !creditAccountValues.contains(fetchedfr.Debit_Account_Name__c)){
                        netAmount =fetchedfr.Credit_Amount_AED_Unitwise__c-fetchedfr.Registration_Collection_Control_Report__c;
                        TotalAmount = TotalAmount+netAmount;
                    }
                }else if(fetchedfr.Document_Category_New__c == 'Debit Note' || fetchedfr.Document_Category_New__c == 'Invoice'){
                    if(fetchedfr.Demand_Status__c == 'Reversed'&& !debitAccountValues.contains(fetchedfr.Debit_Account_Name__c)){
                        netAmount =fetchedfr.Debit_Amount_AED__c-fetchedfr.Registration_Collection_Control_Report__c;
                        TotalAmount = TotalAmount-netAmount;
                        System.debug('i am totalamount-->'+TotalAmount);
                    }
                }
                System.debug('i am totalamount->'+TotalAmount);
            }
            
            for(Finance_Report_Records__c fr:onebookingfrr){                   
                if(fr.Document_Category_New__c == 'Credit Note' || fr.Document_Category_New__c == 'Receipt' || fr.Document_Category_New__c == 'Debit Note' || fr.Document_Category_New__c == 'Invoice'){
                    if((fr.Receipt_Status__c == 'Cleared' && !creditAccountValues.contains(fr.Debit_Account_Name__c)) || (fr.Demand_Status__c == 'Reversed' && !debitAccountValues.contains(fr.Debit_Account_Name__c))){
                        if(flag == false){
                            fr.Is_Recent_Finance_Report_Record__c = true;
                            fr.Total_Amount__c = TotalAmount;
                            flag = true;
                        }else{
                            fr.Total_Amount__c = TotalAmount;
                            fr.Is_Recent_Finance_Report_Record__c = false;
                        }
                    }else{
                        fr.Total_Amount__c = TotalAmount;
                        fr.Is_Recent_Finance_Report_Record__c = false;
                    }
                }else{
                    fr.Total_Amount__c = TotalAmount;
                    fr.Is_Recent_Finance_Report_Record__c = false;
                }
                updatedvaluesMap.put(fr.Id,fr);
            }
        }   
        
        Database.update(updatedvaluesMap.values(), FALSE);
        System.debug('frrQuery i am in end'+updatedvaluesMap);
    }
    
    public static void UpdateBooking(List<Id> receiptIdSet) {
        Shoba_Default_Settings__mdt sobhametadata = [SELECT Credit_Note_Account_Type__c,Debit_Note_Account_Type__c,
                                                     QualifiedApiName
                                                     FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        List<String> creditAccountValues = sobhametadata.Credit_Note_Account_Type__c.split(',');
        List<Receipt__c> triggeredreceiptsList = new List<Receipt__c>();
        Set<String> bookingIdSet = new Set<String>();
        triggeredreceiptsList = [SELECT Id,Booking__c,Debit_Account__c 
                                 FROM Receipt__c 
                                 WHERE Id IN : receiptIdSet];
        
        for(Receipt__c triggeredreceipt : triggeredreceiptsList){
            bookingIdSet.add(triggeredreceipt.Booking__c);
        }
        
        List<Receipt__c> receiptsList = [SELECT Id,Booking__c,GL_Date__c,Receipt_Date__c,Receipt_Status__c,Amount_Rs__c,
                                         Registration_Collection_Control_Report__c,Debit_Account__r.Name,Debit_Account__c 
                                         FROM Receipt__c
                                         WHERE Booking__c IN : bookingIDSet
                                         ORDER BY CreatedDate asc];
        List<Booking__c> bookingList = [SELECT Id,X10_Collected_Date__c,X10_Collected_Date_as_Per_Receipt_Date__c,
                                        X20_Collected_Date__c,X20_Collected_Date_as_Per_Receipt_Date__c,Agreement_Value__c
                                        FROM Booking__c
                                        WHERE ID IN : bookingIdSet];
        Map<Id,List<Receipt__c>> bookingReceiptMap = new Map<Id,List<Receipt__c>>();
        Map<Id,Booking__c> bookingMap = new Map<Id,Booking__c>();
        Map<Id,Booking__c> updatebookingMap = new Map<Id,Booking__c>();
        
        for(Receipt__c receiptdata: receiptsList){
            if(bookingReceiptMap.containsKey(receiptdata.Booking__c)){
                bookingReceiptMap.get(receiptdata.Booking__c).add(receiptdata);
            }else {
                bookingReceiptMap.put(receiptdata.Booking__c, new List<Receipt__c> {receiptdata});
            }
        }
        
        for(Booking__c bookingdata : bookingList){
            bookingMap.put(bookingdata.Id,bookingData);
        }
        
        for(Id currentBooking : bookingReceiptMap.keyset()){
            List<Receipt__c> receiptsdataList = new List<Receipt__c>();
            receiptsdataList=bookingReceiptMap.get(currentBooking);
            Decimal receiptAmountSummation = 0;
            Decimal receiptAmount = 0;
            Decimal PaidPercentage = 0;
            
            Booking__c updateBooking = bookingMap.get(currentBooking);
            Date GLDate10 = null;
            Date ReceiptDate10 = null;
            Date GLDate20 = null;
            Date ReceiptDate20 = null;
            for(Receipt__c currentReceipt : receiptsdataList){
                
                if(currentReceipt.Receipt_Status__c == 'Cleared'&& currentReceipt.Debit_Account__c != null && currentReceipt.Debit_Account__r.Name != null && !creditAccountValues.contains(currentReceipt.Debit_Account__r.Name)){
                    if(currentReceipt.Registration_Collection_Control_Report__c == null){
                        currentReceipt.Registration_Collection_Control_Report__c = 0;
                    }
                    receiptAmount = currentReceipt.Amount_Rs__c-currentReceipt.Registration_Collection_Control_Report__c;
                    receiptAmountSummation = receiptAmountSummation + receiptAmount;	
                   
                    if(bookingMap.containsKey(currentBooking)){
                        Booking__c Booking = bookingMap.get(currentBooking);
                        
                        try{
                         	paidPercentage = (receiptAmountSummation / booking.Agreement_Value__c)*100;
                            System.debug('i am paidpercentage->'+paidpercentage);
                            String s = paidPercentage+'';
                            String myTruncatedNumber = s.subString(0,s.indexOf('.')+3);
                            paidPercentage = Decimal.valueOf(myTruncatedNumber);
                            System.debug('i am paidpercentage after rounding off->'+paidpercentage);
                           

                           
                        }catch (Exception e){System.debug('i am exception-->'+e);}
                        
                        if(paidPercentage >=10 && paidPercentage <= 19.99){
                            if(GLDate10 == null && ReceiptDate10 == null){
                                GLDate10 = currentReceipt.GL_Date__c;
                                ReceiptDate10 = currentReceipt.Receipt_Date__c;
                            }                                 
                        }
                        if(paidPercentage >=20){
                            if(GLDate20 == null && ReceiptDate20 == null){
                                GLDate20 = currentReceipt.GL_Date__c;
                                ReceiptDate20 = currentReceipt.Receipt_Date__c;
                            }
                        }                       
                    }
                }
            }
            if(GLDate10 == null && ReceiptDate10 == null && (GLDate20 != null || ReceiptDate20 != null)){
                updateBooking.X10_Collected_Date__c = GLDate20;
            	updateBooking.X10_Collected_Date_as_Per_Receipt_Date__c = ReceiptDate20;
            	updateBooking.X20_Collected_Date__c = GLDate20;
            	UpdateBooking.X20_Collected_Date_as_Per_Receipt_Date__c = ReceiptDate20;
            	updatebookingMap.put(updateBooking.Id,updateBooking);
            }else{
            	updateBooking.X10_Collected_Date__c = GLDate10;
            	updateBooking.X10_Collected_Date_as_Per_Receipt_Date__c = ReceiptDate10;
            	updateBooking.X20_Collected_Date__c = GLDate20;
            	updateBooking.X20_Collected_Date_as_Per_Receipt_Date__c = ReceiptDate20;
            	updatebookingMap.put(updateBooking.Id,updateBooking);
            }
        }   
          Database.update(updatebookingMap.values(),FALSE);
          System.debug('updatebookingmap --->'+updatebookingMap);
    }
}