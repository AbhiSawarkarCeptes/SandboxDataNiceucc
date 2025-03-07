public class UpdatePricingMilestoneBatch implements Database.Batchable<sObject>,Database.stateful {

    Set<String> unitIds = new Set<String>();

    public  UpdatePricingMilestoneBatch(Set<String> unitIds){
        this.unitIds = unitIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Charge_1_Amount__c,Charge_2_Amount__c,Charge_3_Amount__c,Charge_2_Name__c,Charge_1_Name__c,Booking__c,Puchase_Price__c,Charge_3_Name__c from Unit__c';
        if(unitIds.size() > 0){
            query += ' where id IN:unitIds';
        }
        else{
            query += ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Unit__c> unitList){

        Decimal Charge_1_Amount = 0.0;
        Decimal Charge_2_Amount = 0.0;
        Decimal Charge_3_Amount = 0.0;
        Decimal Puchase_Price = 0.0;
        String id = '';
        List<Quotation__c> quotelist = new List<Quotation__c>();
        List<Unit__c> unitListFinal = new List<Unit__c>();
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Payment_Milestones__c> paymentMilesList = new List<Payment_Milestones__c>();
        Map<String,Decimal> chargeRateMap = new Map<String,Decimal>();
        Set<Id> bookingIds = new Set<Id>();
        Set<Id> quotationIds = new Set<Id>(); 
        
        for(Rate_List__c rateListRec : [select id, name,Charge_Cost__c,ProjectCharges__r.Name,unit__c from Rate_List__c where Unit__c IN:unitList]){
            chargeRateMap.put(rateListRec.ProjectCharges__r.Name,rateListRec.Charge_Cost__c);      
        }
        
        for(Unit__c u : unitList){
            u.Charge_1_Amount__c = chargeRateMap.get(u.Charge_1_Name__c) != null ? chargeRateMap.get(u.Charge_1_Name__c) : 0;
            u.Charge_2_Amount__c = chargeRateMap.get(u.Charge_2_Name__c) != null ? chargeRateMap.get(u.Charge_2_Name__c) : 0;
            u.Charge_3_Amount__c = chargeRateMap.get(u.Charge_3_Name__c) != null ? chargeRateMap.get(u.Charge_3_Name__c) : 0;
            u.Puchase_Price__c = u.Charge_1_Amount__c + u.Charge_2_Amount__c + u.Charge_3_Amount__c;
            unitListFinal.add(u);
            Charge_1_Amount = u.Charge_1_Amount__c;
            Charge_2_Amount = u.Charge_2_Amount__c;
            Charge_3_Amount = u.Charge_3_Amount__c;
            Puchase_Price = u.Charge_1_Amount__c + u.Charge_2_Amount__c + u.Charge_3_Amount__c;
            bookingIds.add(u.Booking__c);
        }
        
        if(bookingIds.size() > 0){
            for(Booking__c bookingRecord : [select id,Quotation__c,Agreement_Value__c from Booking__c where id IN :bookingIds]){
                bookingRecord.Agreement_Value__c=Puchase_Price;
                bookingList.add(bookingRecord);
                quotationIds.add(bookingRecord.Quotation__c);
            }
        }
        
        if(quotationIds.size() > 0){
            for(Quotation__c quoteVal : [select id ,Charge3Value__c,Charge2Value__c,Charge1Value__c,Charge1Name__c,Charge6Value__c from Quotation__c where id IN :quotationIds]){
                quoteVal.Charge1Value__c = Charge_1_Amount ;
                quoteVal.Charge2Value__c = Charge_2_Amount ;
                quoteVal.Charge3Value__c = Charge_3_Amount;
                quoteVal.Charge6Value__c = 0.04 * Puchase_Price;
                quoteVal.Total_Agreement_Value_Bucket__c = Puchase_Price;
                quoteVal.Total_SD_Registration_Bucket__c = (0.04 * Puchase_Price)+1150;
                quoteVal.Area_Updated__c = true;
                quotelist.add(quoteVal);
            } 
            
            for(Payment_Milestones__c prval : [select id ,Charge1Name__c ,Area_Update__c,C1_Amount__c,C2_Amount__c,C3_Amount__c,C4_Amount__c,C5_Amount__c, Charge2Name__c ,Charge3Name__c,Charge4Name__c,Charge5Name__c,Charge6Name__c, Charge1Percentage__c,Charge2Percentage__c,Charge3Percentage__c,Charge4Percentage__c,Charge5Percentage__c,Charge6Percentage__c ,Quotation__r.Charge4Value__c,Quotation__r.Charge5Value__c from Payment_Milestones__c where Quotation__c IN :quotationIds]){
                Decimal charg1 = prval.Charge1Percentage__c != null ?(prval.Charge1Percentage__c)/100 : 0;
                Decimal charg2 = prval.Charge2Percentage__c != null ?(prval.Charge2Percentage__c)/100: 0;
                Decimal charg3 = prval.Charge3Percentage__c != null ?(prval.Charge3Percentage__c)/100: 0;
                Decimal charg4 = prval.Charge4Percentage__c != null ?(prval.Charge4Percentage__c)/100: 0;
                Decimal charg5 = prval.Charge5Percentage__c != null ?(prval.Charge5Percentage__c)/100: 0;
                Decimal charg6 = prval.Charge6Percentage__c != null ?(prval.Charge6Percentage__c)/100: 0;
    
                prval.C1_Amount__c = charg1 * Charge_1_Amount;
                prval.C2_Amount__c = charg2 * Charge_2_Amount;
                prval.C3_Amount__c = charg3 * Charge_3_Amount;
                prval.C4_Amount__c = charg4 * (prval.Quotation__r.Charge4Value__c != null ? prval.Quotation__r.Charge4Value__c : 0);
                prval.C5_Amount__c = charg5 * (prval.Quotation__r.Charge5Value__c != null ? prval.Quotation__r.Charge5Value__c : 0);
                prval.C6_Amount__c = charg6 * 0.04 * Puchase_Price;
                prVal.Area_Update__c = true;
                paymentMilesList.add(prval);
            }
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(unitListFinal.size() > 0){
                update unitListFinal;
            }
            if(quotelist.size() > 0 ){
                update quotelist;
            }
            if(bookingList.size() > 0 ){
                update BookingList;
            }
            if(paymentMilesList.size() > 0 ){
                update paymentMilesList;
            }
        }
        catch(Exception e){
            Database.rollback( sp );
        }
    }
     public void finish(Database.BatchableContext BC){
        
    }
}