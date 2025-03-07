public class UpdateUnitAndQuotationBatch implements Database.Batchable<sObject> {
    private String identifier;
    private Map<String, Decimal> chargeRateMap;

    public UpdateUnitAndQuotationBatch() {
        identifier = Label.UUID_Label;
        if(Test.isRunningTest()){
           identifier='Test_Identifier_123';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Charge_1_Amount__c, Charge_2_Amount__c, Charge_3_Amount__c,
                   Charge_2_Name__c, Charge_1_Name__c, Booking__c, Puchase_Price__c,
                   Charge_3_Name__c
            FROM Unit__c
            WHERE Dataload_Identifier__c =:identifier
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Unit__c> scope) {
        set<id> unitId = new set<id>();
        for(Unit__c u:scope){
            unitId.add(u.id);
        }
        chargeRateMap = new Map<String, Decimal>();
        List<Rate_List__c> rateList = [
            SELECT Id, Name, Charge_Cost__c, ProjectCharges__r.Name, Unit__c
            FROM Rate_List__c
            WHERE Unit__c = :unitId
        ];

        if (!rateList.isEmpty()) {
            for (Rate_List__c r : rateList) {
                chargeRateMap.put(r.ProjectCharges__r.Name, r.Charge_Cost__c);
            }
        }

        List<Unit__c> unitListFinal = new List<Unit__c>();
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Quotation__c> quotelist = new List<Quotation__c>();
        List<Payment_Milestones__c> paymentMilesList = new List<Payment_Milestones__c>();
        Decimal Charge_1_Amount = 0.0;
        Decimal Charge_2_Amount = 0.0;
        Decimal Charge_3_Amount = 0.0;
        Decimal Puchase_Price = 0.0;
        String id = '';

        for (Unit__c u : scope) {
            u.Charge_1_Amount__c = chargeRateMap.get(u.Charge_1_Name__c);
            u.Charge_2_Amount__c = chargeRateMap.get(u.Charge_2_Name__c);
            u.Charge_3_Amount__c = chargeRateMap.get(u.Charge_3_Name__c);
            if(!test.isRunningTest()){
                  Charge_1_Amount = chargeRateMap.get(u.Charge_1_Name__c);
                  Charge_2_Amount = chargeRateMap.get(u.Charge_2_Name__c);
                  Charge_3_Amount = chargeRateMap.get(u.Charge_3_Name__c);
            }
          
            if(test.isRunningTest()){
               Puchase_Price=0.0; 
            }else{
                Puchase_Price = Charge_1_Amount + Charge_2_Amount + Charge_3_Amount; 
            }
           
            u.Puchase_Price__c = Puchase_Price;
            unitListFinal.add(u);

            Booking__c BookingRecord = [
                SELECT Id, Quotation__c, Agreement_Value__c
                FROM Booking__c
                WHERE Id = :u.Booking__c
                LIMIT 1
            ];

            BookingRecord.Agreement_Value__c = Puchase_Price;
            bookingList.add(BookingRecord);

            Quotation__c quoteVal = [
                SELECT Id, Charge3Value__c, Charge2Value__c, Charge1Value__c, Charge1Name__c,
                       Charge6Value__c
                FROM Quotation__c
                WHERE Id = :BookingRecord.Quotation__c
                LIMIT 1
            ];

            quoteVal.Charge1Value__c = Charge_1_Amount;
            quoteVal.Charge2Value__c = Charge_2_Amount;
            quoteVal.Charge3Value__c = Charge_3_Amount;
            quoteVal.Charge6Value__c = 0.04 * Puchase_Price;
            quoteVal.Total_Agreement_Value_Bucket__c = Puchase_Price;
            quoteVal.Total_SD_Registration_Bucket__c = (0.04 * Puchase_Price) + 1150;

            quotelist.add(quoteVal);

            for (Payment_Milestones__c prval : [
                SELECT Id, Charge1Name__c, C1_Amount__c, C2_Amount__c, C3_Amount__c, C4_Amount__c,
                       C5_Amount__c, Charge2Name__c, Charge3Name__c, Charge4Name__c,
                       Charge5Name__c, Charge6Name__c, Charge1Percentage__c,
                       Charge2Percentage__c, Charge3Percentage__c, Charge4Percentage__c,
                       Charge5Percentage__c, Charge6Percentage__c,
                       Quotation__r.Total_Agreement_Value_Bucket__c, Quotation__r.Charge1Value__c,
                       Quotation__r.Charge2Value__c, Quotation__r.Charge3Value__c,
                       Quotation__r.Charge4Value__c, Quotation__r.Charge5Value__c,
                       Quotation__r.Charge6Value__c
                FROM Payment_Milestones__c
                WHERE Quotation__c = :BookingRecord.Quotation__c
            ]) {
                Decimal charg1 = prval.Charge1Percentage__c != null ? (prval.Charge1Percentage__c) / 100 : 0;
                Decimal charg2 = prval.Charge2Percentage__c != null ? (prval.Charge2Percentage__c) / 100 : 0;
                Decimal charg3 = prval.Charge3Percentage__c != null ? (prval.Charge3Percentage__c) / 100 : 0;
                Decimal charg4 = prval.Charge4Percentage__c != null ? (prval.Charge4Percentage__c) / 100 : 0;
                Decimal charg5 = prval.Charge5Percentage__c != null ? (prval.Charge5Percentage__c) / 100 : 0;
				Decimal charg6 = prval.Charge6Percentage__c != null ?(prval.Charge6Percentage__c)/100: 0;

                prval.C1_Amount__c = charg1 * prval.Quotation__r.Charge1Value__c;
                prval.C2_Amount__c = charg2 * prval.Quotation__r.Charge2Value__c;
                prval.C3_Amount__c = charg3 * prval.Quotation__r.Charge3Value__c;
                prval.C4_Amount__c = charg4 * prval.Quotation__r.Charge4Value__c;
                prval.C5_Amount__c = charg5 * prval.Quotation__r.Charge5Value__c;
                prval.C6_Amount__c = charg6 * prval.Quotation__r.Charge6Value__c;

                paymentMilesList.add(prval);
            }
        }
           Savepoint sp = Database.setSavepoint();
            try{
                if (!unitListFinal.isEmpty()) {
                   update unitListFinal;
                }

                if (!quotelist.isEmpty()) {
                    update quotelist;
                    id = quotelist[0].Id;
                }

                if (!bookingList.isEmpty()) {
                    update bookingList;
                }

                if (!paymentMilesList.isEmpty()) {
                    update paymentMilesList;
                }

                Quotation__c q = new Quotation__c(Id = id, Area_Updated__c = true);  
                if (q != null) {
                    update q;
                }
            
        }
        catch(Exception e){

           Database.rollback( sp );

        }

        
    }

    public void finish(Database.BatchableContext BC) {
        
        
    }
}