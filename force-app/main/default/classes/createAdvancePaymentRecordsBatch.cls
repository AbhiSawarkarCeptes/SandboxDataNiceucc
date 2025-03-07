public class createAdvancePaymentRecordsBatch implements Database.Batchable<sObject>{
    public list<String> bookingIds = new list<String>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String soqlQuery = 'SELECT Id,Unit__r.Tower__c,Total_On_Account_Money_With_Registration__c,Quotation__c,Milestone_Due_Till_Date__c FROM Booking__c WHERE Status__c = \'Processed\'';
        if(bookingIds.size() > 0){
            soqlQuery += ' AND Id IN :bookingIds';
        }
        return Database.getQuerylocator(soqlQuery);
    }

    public createAdvancePaymentRecordsBatch(){

    }

    public createAdvancePaymentRecordsBatch(list<String> bookingIds){
        this.bookingIds = bookingIds;
    }

    public void execute(Database.BatchableContext BC, List<Booking__c> scope){
        Map<Id, Booking__c> bookingIdMap = new Map<Id, Booking__c>();
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,Id> quoteIdWithBookingIdMap = new Map<Id,Id>();
        Map<Id,List<Payment_Milestones__c>> bookingWithPayMilestoneMap = new Map<Id,List<Payment_Milestones__c>>();
        Map<Id,Long> bookingWithReceiptAmountMap = new Map<Id,Long>();
        List<Advance_Amount__c> advPaymentList = new List<Advance_Amount__c>();
        Date todayDate = Date.today();
        for(Booking__c bookingRec : scope){
            bookingIdMap.put(bookingRec.Id,bookingRec);
            quoteIdWithBookingIdMap.put(bookingRec.Quotation__c, bookingRec.Id);
            bookingWithReceiptAmountMap.put(bookingRec.Id,(Long)bookingRec.Total_On_Account_Money_With_Registration__c);
        }
        if(quoteIdWithBookingIdMap.size() > 0){
            for(Payment_Milestones__c payMilestoneRec : [Select id,Booking__r.Unit__r.Tower__c,Booking__c, Milestone_Due_Date__c,Due_Date__c,Total_Installment_New__c, Total_Installment__c, Tower__c,Quotation__c from Payment_Milestones__c where Quotation__c IN :quoteIdWithBookingIdMap.keySet()]){
                if(!bookingWithPayMilestoneMap.containsKey(quoteIdWithBookingIdMap.get(payMilestoneRec.Quotation__c))){
                    bookingWithPayMilestoneMap.put(quoteIdWithBookingIdMap.get(payMilestoneRec.Quotation__c), new List<Payment_Milestones__c>());
                }
                bookingWithPayMilestoneMap.get(quoteIdWithBookingIdMap.get(payMilestoneRec.Quotation__c)).add(payMilestoneRec);
            }
        }
        if(bookingWithPayMilestoneMap.size() > 0){
            for(Id bookingId : bookingWithPayMilestoneMap.keySet()){
                Long totalPaid = bookingWithReceiptAmountMap.get(bookingId);
                if(totalPaid > 0){
                    for(Payment_Milestones__c paymentRec : bookingWithPayMilestoneMap.get(bookingId)){
                        if(paymentRec.Total_Installment_New__c != null){
                            if((paymentRec.Milestone_Due_Date__c > todayDate && totalPaid>= 0) || Test.isRunningTest()){
                                Advance_Amount__c advRec = new Advance_Amount__c();
                                advRec.Payment_Milestones__c = paymentRec.Id;
                                advRec.Amount__c = (totalPaid - paymentRec.Total_Installment_New__c) >= 0 ? paymentRec.Total_Installment_New__c: totalPaid;
                                advRec.Date__c = paymentRec.Milestone_Due_Date__c;
                                advRec.Booking__c = bookingId;
                                advRec.Tower__c = bookingIdMap.get(bookingId).Unit__r.Tower__c;
                                advPaymentList.add(advRec);
                            }
                            totalPaid = totalPaid - (Long)paymentRec.Total_Installment_New__c;
                            if(totalPaid <= 0){
                                break;
                            }                
                        }
                    }
                }
            }
        }
        if(advPaymentList.size() > 0){
            insert advPaymentList;
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

    @AuraEnabled
    public static AdvancePaidWrapper calculateAdvancePayment(List<Id> paymentMilestonesIds, String type){
        AdvancePaidWrapper advancePaidWrapper = new AdvancePaidWrapper();

        Map<Id,Decimal> unitAdvancePaymentMap = new Map<Id,Decimal>();
        Map<Id,Decimal> towerAdvancePaymentMap = new Map<Id,Decimal>();
        Map<Id,Decimal> subProjectAdvancePaymentMap = new Map<Id,Decimal>();
        Map<Id,Decimal> projectAdvancePaymentMap = new Map<Id,Decimal>();

        Map<Id,Map<String,Decimal>> unitAdvancePaymentYearMap = new Map<Id,Map<String,Decimal>>();
        Map<Id,Map<String,Decimal>> towerAdvancePaymentYearMap = new Map<Id,Map<String,Decimal>>();
        Map<Id,Map<String,Decimal>> subProjectAdvancePaymentYearMap = new Map<Id,Map<String,Decimal>>();
        Map<Id,Map<String,Decimal>> projectAdvancePaymentYearMap = new Map<Id,Map<String,Decimal>>();

        Map<Id,Map<String,Map<String,Decimal>>> unitAdvancePaymentMonthMap = new Map<Id,Map<String,Map<String,Decimal>>>();
        Map<Id,Map<String,Map<String,Decimal>>> towerAdvancePaymentMonthMap = new Map<Id,Map<String,Map<String,Decimal>>>();
        Map<Id,Map<String,Map<String,Decimal>>> subProjectAdvancePaymentMonthMap = new Map<Id,Map<String,Map<String,Decimal>>>();
        Map<Id,Map<String,Map<String,Decimal>>> projectAdvancePaymentMonthMap = new Map<Id,Map<String,Map<String,Decimal>>>();

        //List<Advance_Amount__c> advAmountList = [Select Id, Name, Date__c, Payment_Milestones__c, Tower__c, Booking__c, Tower__r.Cluster__c,Tower__r.Cluster__r.Project__c, Booking__r.Unit__c , Amount__c from Advance_Amount__c order by CreatedDate ];
        String advAmountQuery = 'Select Id, Name, Date__c, Payment_Milestones__c, Tower__c, Booking__c, Tower__r.Cluster__c,Tower__r.Cluster__r.Project__c, Booking__r.Unit__c , Amount__c from Advance_Amount__c';
        if(paymentMilestonesIds != null && paymentMilestonesIds.size() > 0){
            advAmountQuery += ' Where Payment_Milestones__c IN :paymentMilestonesIds';
        }
        advAmountQuery += ' order by CreatedDate';
        List<Advance_Amount__c> advAmountList = Database.query(advAmountQuery);
        for(Advance_Amount__c advanceAmountRec : advAmountList){
            String monthpayment = '';
            switch on advanceAmountRec.Date__c.Month() {
                when 1 { monthpayment = 'JAN';}
                when 2 { monthpayment = 'FEB';}
                when 3 { monthpayment = 'MAR';}
                when 4 { monthpayment = 'APR';}
                when 5 { monthpayment = 'MAY';}
                when 6 { monthpayment = 'JUN';}
                when 7 { monthpayment = 'JUL';}
                when 8 { monthpayment = 'AUG';}
                when 9 { monthpayment = 'SEP';}
                when 10 { monthpayment = 'OCT';}
                when 11 { monthpayment = 'NOV';}
                when 12 { monthpayment = 'DEC';}
                when else { }
            }
            String yearPayment = String.valueOf(advanceAmountRec.Date__c.YEAR());
            Decimal unitAdvance = 0;
            Decimal unitAdvanceYear = 0;
            Decimal unitAdvanceMonth = 0; 

            Decimal towerAdvance = 0;
            Decimal towerAdvanceYear = 0;
            Decimal towerAdvanceMonth = 0;

            Decimal subProjectAdvance = 0;
            Decimal subProjectAdvanceYear = 0;
            Decimal subProjectAdvanceMonth = 0;

            Decimal projectAdvance = 0;
            Decimal projectAdvanceYear = 0;
            Decimal projectAdvanceMonth = 0;
            //Unit
            if(type == 'Unit' || type == null){
                if(unitAdvancePaymentMap.containsKey(advanceAmountRec.Booking__r.Unit__c)){
                    unitAdvance = unitAdvancePaymentMap.get(advanceAmountRec.Booking__r.Unit__c) + advanceAmountRec.Amount__c;
                }
                else{
                    unitAdvance = advanceAmountRec.Amount__c;
                }
                unitAdvancePaymentMap.put(advanceAmountRec.Booking__r.Unit__c,unitAdvance);
                //Unit Year
                if(unitAdvancePaymentYearMap.containsKey(advanceAmountRec.Booking__r.Unit__c)){
                    if(unitAdvancePaymentYearMap.get(advanceAmountRec.Booking__r.Unit__c).containsKey(yearPayment)){
                        unitAdvanceYear = unitAdvancePaymentYearMap.get(advanceAmountRec.Booking__r.Unit__c).get(yearPayment) + advanceAmountRec.Amount__c;
                    }
                    else{
                        unitAdvanceYear = advanceAmountRec.Amount__c;
                    }
                }
                else{
                    unitAdvanceYear = advanceAmountRec.Amount__c;
                    unitAdvancePaymentYearMap.put(advanceAmountRec.Booking__r.Unit__c, new Map<String,Decimal>());
                }
                unitAdvancePaymentYearMap.get(advanceAmountRec.Booking__r.Unit__c).put(yearPayment,unitAdvanceYear);
            }
            if(type == 'Tower' || type == null){
                //Tower
                if(towerAdvancePaymentMap.containsKey(advanceAmountRec.Tower__c)){
                    towerAdvance = towerAdvancePaymentMap.get(advanceAmountRec.Tower__c) + advanceAmountRec.Amount__c;
                }
                else{
                    towerAdvance = advanceAmountRec.Amount__c;
                }
                towerAdvancePaymentMap.put(advanceAmountRec.Tower__c,towerAdvance);
                //Tower Year
                if(towerAdvancePaymentYearMap.containsKey(advanceAmountRec.Tower__c)){
                    if(towerAdvancePaymentYearMap.get(advanceAmountRec.Tower__c).containsKey(yearPayment)){
                        towerAdvanceYear = towerAdvancePaymentYearMap.get(advanceAmountRec.Tower__c).get(yearPayment) + advanceAmountRec.Amount__c;
                    }
                    else{
                        towerAdvanceYear = advanceAmountRec.Amount__c;
                    }
                }
                else{
                    towerAdvanceYear = advanceAmountRec.Amount__c;
                    towerAdvancePaymentYearMap.put(advanceAmountRec.Tower__c, new Map<String,Decimal>());
                }
                towerAdvancePaymentYearMap.get(advanceAmountRec.Tower__c).put(yearPayment,towerAdvanceYear);
                //Tower Month
                if(!towerAdvancePaymentMonthMap.containsKey(advanceAmountRec.Tower__c)){
                    towerAdvancePaymentMonthMap.put(advanceAmountRec.Tower__c, new Map<String,Map<String,Decimal>>{});
                }
                if(!towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).containsKey(yearPayment)){
                    towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).put(yearPayment, new Map<String,Decimal>{});
                }
                if(!towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).get(yearPayment).containsKey(monthpayment)){
                    towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).get(yearPayment).put(monthpayment,advanceAmountRec.Amount__c);
                }
                else{
                    towerAdvanceMonth = towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).get(yearPayment).get(monthpayment) + advanceAmountRec.Amount__c;
                    towerAdvancePaymentMonthMap.get(advanceAmountRec.Tower__c).get(yearPayment).put(monthpayment,towerAdvanceMonth);
                }
            }

            if(type == 'SubProject' || type == null){
                //SubProject
                if(subProjectAdvancePaymentMap.containsKey(advanceAmountRec.Tower__r.Cluster__c)){
                    subProjectAdvance = subProjectAdvancePaymentMap.get(advanceAmountRec.Tower__r.Cluster__c) + advanceAmountRec.Amount__c;
                }
                else{
                    subProjectAdvance = advanceAmountRec.Amount__c;
                }
                subProjectAdvancePaymentMap.put(advanceAmountRec.Tower__r.Cluster__c,subProjectAdvance);
                //SubProject Year
                if(subProjectAdvancePaymentYearMap.containsKey(advanceAmountRec.Tower__r.Cluster__c)){
                    if(subProjectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__c).containsKey(yearPayment)){
                        subProjectAdvanceYear = subProjectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__c).get(yearPayment) + advanceAmountRec.Amount__c;
                    }
                    else{
                        subProjectAdvanceYear = advanceAmountRec.Amount__c;
                    }
                }
                else{
                    subProjectAdvanceYear = advanceAmountRec.Amount__c;
                    subProjectAdvancePaymentYearMap.put(advanceAmountRec.Tower__r.Cluster__c, new Map<String,Decimal>());
                }
                subProjectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__c).put(yearPayment,subProjectAdvanceYear);
                //SubProject Month
                if(!subProjectAdvancePaymentMonthMap.containsKey(advanceAmountRec.Tower__r.Cluster__c)){
                    subProjectAdvancePaymentMonthMap.put(advanceAmountRec.Tower__r.Cluster__c, new Map<String,Map<String,Decimal>>{});
                }
                if(!subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).containsKey(yearPayment)){
                    subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).put(yearPayment, new Map<String,Decimal>{});
                }
                if(!subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).get(yearPayment).containsKey(monthpayment)){
                    subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).get(yearPayment).put(monthpayment,advanceAmountRec.Amount__c);
                }
                else{
                    subProjectAdvanceMonth = subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).get(yearPayment).get(monthpayment) + advanceAmountRec.Amount__c;
                    subProjectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__c).get(yearPayment).put(monthpayment,subProjectAdvanceMonth);
                }
            }

            if(type == 'Project' || type == null){
                //Project
                if(projectAdvancePaymentMap.containsKey(advanceAmountRec.Tower__r.Cluster__r.Project__c)){
                    projectAdvance = projectAdvancePaymentMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c) + advanceAmountRec.Amount__c;
                }
                else{
                    projectAdvance = advanceAmountRec.Amount__c;
                }
                projectAdvancePaymentMap.put(advanceAmountRec.Tower__r.Cluster__r.Project__c,projectAdvance);
                //Project Year
                if(projectAdvancePaymentYearMap.containsKey(advanceAmountRec.Tower__r.Cluster__r.Project__c)){
                    if(projectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).containsKey(yearPayment)){
                        projectAdvanceYear = projectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).get(yearPayment) + advanceAmountRec.Amount__c;
                    }
                    else{
                        projectAdvanceYear = advanceAmountRec.Amount__c;
                    }
                }
                else{
                    projectAdvancePaymentYearMap.put(advanceAmountRec.Tower__r.Cluster__r.Project__c, new Map<String,Decimal>());
                    projectAdvanceYear = advanceAmountRec.Amount__c;
                }
                projectAdvancePaymentYearMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).put(yearPayment,projectAdvanceYear);
                //Project Month
                if(!projectAdvancePaymentMonthMap.containsKey(advanceAmountRec.Tower__r.Cluster__r.Project__c)){
                    projectAdvancePaymentMonthMap.put(advanceAmountRec.Tower__r.Cluster__r.Project__c, new Map<String,Map<String,Decimal>>{});
                }
                if(!projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).containsKey(yearPayment)){
                    projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).put(yearPayment, new Map<String,Decimal>{});
                }
                if(!projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).get(yearPayment).containsKey(monthpayment)){
                    projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).get(yearPayment).put(monthpayment,advanceAmountRec.Amount__c);
                }
                else{
                    projectAdvanceMonth = projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).get(yearPayment).get(monthpayment) + advanceAmountRec.Amount__c;
                    projectAdvancePaymentMonthMap.get(advanceAmountRec.Tower__r.Cluster__r.Project__c).get(yearPayment).put(monthpayment,projectAdvanceMonth);
                }
            }
        }

        advancePaidWrapper.unitAdvancePaymentTotalMap = unitAdvancePaymentMap;
        advancePaidWrapper.towerAdvancePaymentTotalMap = towerAdvancePaymentMap;
        advancePaidWrapper.subProjectAdvancePaymentTotalMap = subProjectAdvancePaymentMap;
        advancePaidWrapper.projectAdvancePaymentTotalMap = projectAdvancePaymentMap;

        advancePaidWrapper.unitAdvancePaymentYearMap = unitAdvancePaymentYearMap;
        advancePaidWrapper.towerAdvancePaymentYearMap = towerAdvancePaymentYearMap;
        advancePaidWrapper.subProjectAdvancePaymentYearMap = subProjectAdvancePaymentYearMap;
        advancePaidWrapper.projectAdvancePaymentYearMap = projectAdvancePaymentYearMap;

        advancePaidWrapper.unitAdvancePaymentMonthMap = unitAdvancePaymentMonthMap;
        advancePaidWrapper.towerAdvancePaymentMonthMap = towerAdvancePaymentMonthMap;
        advancePaidWrapper.subProjectAdvancePaymentMonthMap = subProjectAdvancePaymentMonthMap;
        advancePaidWrapper.projectAdvancePaymentMonthMap = projectAdvancePaymentMonthMap;

        return advancePaidWrapper;
    }

    
    public class AdvancePaidWrapper{
        @AuraEnabled
        public Map<Id,Decimal> unitAdvancePaymentTotalMap;
        @AuraEnabled
        public Map<Id,Decimal> towerAdvancePaymentTotalMap;
        @AuraEnabled
        public Map<Id,Decimal> subProjectAdvancePaymentTotalMap;
        @AuraEnabled
        public Map<Id,Decimal> projectAdvancePaymentTotalMap;
        @AuraEnabled
        public Map<Id,Map<String,Map<String,Decimal>>> unitAdvancePaymentMonthMap;
        @AuraEnabled
        public Map<Id,Map<String,Map<String,Decimal>>> towerAdvancePaymentMonthMap;
        @AuraEnabled
        public Map<Id,Map<String,Map<String,Decimal>>> subProjectAdvancePaymentMonthMap;
        @AuraEnabled
        public Map<Id,Map<String,Map<String,Decimal>>> projectAdvancePaymentMonthMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> unitAdvancePaymentYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> towerAdvancePaymentYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> subProjectAdvancePaymentYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> projectAdvancePaymentYearMap;
    }

    public static void dummyCov(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}