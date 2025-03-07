public class MilestoneAgeingController {
    public static void calculateAging(List<Booking__c> bookingsList){
        try {
            List<String> quotationIDsList = new List<String>();
            List<Milestone_Ageing__c> upsertAgeingList = new List<Milestone_Ageing__c>();
            List<Milestone_Ageing__c> createAgeingList = new List<Milestone_Ageing__c>();
            Map<String,List<Payment_Milestones__c>> quotationMap = new Map<String,List<Payment_Milestones__c>>();
            Set<Id> bookingIdSet = new Set<Id>();
            
            //Get quotation ids
            for(Booking__C booking : bookingsList){
                quotationIdsList.add(booking.quotation__c);
                bookingIdSet.add(booking.Id);
            }
            System.debug('quotationIdsList : '+ quotationIdsList);
            System.debug('Heap @ Start: ' + (Limits.getLimitHeapSize()-Limits.getHeapSize()));
            //Get payment milestone records which are related to quotaiton and store them in quotationMap
            List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
            pmList = [SELECT id,Name,quotation__c,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c FROM Payment_Milestones__c WHERE quotation__c IN : quotationIdsList 
                        AND Milestone_Due_Date__c <=: SYSTEM.TODAY() ORDER BY Milestone_Due_Date__c ASC];
            for(Payment_Milestones__c milestone : pmList){
                if(quotationMap.containsKey(milestone.quotation__c)){ 
                    List<Payment_Milestones__c> milestoneList = quotationMap.get(milestone.quotation__c);
                    milestoneList.add(milestone);
                    quotationMap.put(milestone.quotation__c, milestoneList);
                }else{
                    quotationMap.put(milestone.quotation__c, new List<Payment_Milestones__c> {milestone});
                }
            }
            System.debug('quotationMap : '+ quotationMap);
            System.debug('Heap @ Start: ' + (Limits.getLimitHeapSize()-Limits.getHeapSize()));
            //Get Milestone Ageing Records which are related to quotation
            List<Milestone_Ageing__c> ageingRecordsList = new List<Milestone_Ageing__c>();
            Map<String,Milestone_Ageing__c> ageingRecordsMap = new Map<String,Milestone_Ageing__c>();
            ageingRecordsList = [SELECT Id, Name, Total_On_Account_Money__c,Total_Pre_Registration_Amount__c, B1_0_30_Days__c, B7_361_Days__c, B5_121_180_Days__c, B6_181_360_Days__c, Total_Milestone_Amount__c,
                                B4_91_120_Days__c, B2_31_60_Days__c, B3_61_90_Days__c, Unit__c, Booking__c, Project__c, B1_Net__c, 
                                B2_Net__c, B3_Net__c, B4_Net__c, B5_Net__c, B6_Net__c, B7_Net__c, Quotation__c 
                                FROM Milestone_Ageing__c WHERE Booking__c IN: bookingIdSet ];
            System.debug('bookingIdSet : '+ bookingIdSet);
            System.debug('ageingRecordsList : '+ ageingRecordsList);
            System.debug('Heap @ Start: ' + (Limits.getLimitHeapSize()-Limits.getHeapSize()));
            for(Milestone_Ageing__c ageingRec : ageingRecordsList){
                System.debug('ageingRec : '+ ageingRec);
                ageingRecordsMap.put(ageingRec.booking__c,ageingRec);
                System.debug('ageingRecordsMap : '+ ageingRecordsMap);
            }
            System.debug('Heap @ Start: ' + (Limits.getLimitHeapSize()-Limits.getHeapSize()));
            System.debug('ageingRecordsMap : '+ ageingRecordsMap);
            
            //logic for calculating milestone age starts here
            for(Booking__c bookingRec : bookingsList){
                
                //Get total on account money from booking 
                Decimal Total_On_Account_Money = bookingRec.Total_On_Account_Money_With_Registration__c;
                System.debug('Initial Total_On_Account_Money : '+ Total_On_Account_Money);
                List<Payment_Milestones__c> milestoneData = new List<Payment_Milestones__c>();
                Milestone_Ageing__c ageingRec = new Milestone_Ageing__c();
                
                //Get payment milestone records which are related to current booking from quotation map
                if(quotationMap != null && quotationMap.containskey(bookingRec.quotation__c) && quotationMap.get(bookingRec.Quotation__c) != null){
                    milestoneData = quotationMap.get(bookingRec.Quotation__c);
                    if(ageingRecordsMap != null && ageingRecordsMap.containskey(bookingRec.Id) && ageingRecordsMap.get(bookingRec.id) != null){
                        ageingRec = ageingRecordsMap.get(bookingRec.id);
                    }
                    ageingRec.Total_Milestone_Amount__c = 0;
                    ageingRec.B1_0_30_Days__c = 0;
                    ageingRec.B2_31_60_Days__c = 0;
                    ageingRec.B3_61_90_Days__c = 0;
                    ageingRec.B4_91_120_Days__c = 0;
                    ageingRec.B5_121_180_Days__c = 0;
                    ageingRec.B6_181_360_Days__c = 0;
                    ageingRec.B7_361_Days__c = 0;
                    ageingRec.B7_Net__c = 0;
                    ageingRec.B6_Net__c = 0;
                    ageingRec.B5_Net__c = 0;
                    ageingRec.B4_Net__c = 0;
                    ageingRec.B3_Net__c = 0;
                    ageingRec.B2_Net__c = 0;
                    ageingRec.B1_Net__c = 0;
                    for(Payment_Milestones__c milestoneRec : milestoneData){
                        //Calculate no of days between milestone due date and today
                        Integer days = milestoneRec.Milestone_Due_Date__c .daysBetween(System.TODAY());
                        Decimal totalPayableAmount = 0;
                        Decimal pendingAmount = 0;
                        Map<String,Decimal> netAmountMap = new Map<String,Decimal>();
                        ageingRec.Booking__c =  bookingRec.id;
                        ageingRec.Unit__c = bookingRec.Unit__c;
                        ageingRec.Project__c = bookingRec.Project__c;
                        ageingRec.quotation__c = bookingRec.Quotation__c;
                        ageingRec.Total_On_Account_Money__c = bookingRec.Total_On_Account_Money_With_Registration__c;
                        ageingRec.Total_Pre_Registration_Amount__c = bookingRec.Total_On_Account_Money__c -  bookingRec.Total_On_Account_Money_With_Registration__c;
                        ageingRec.Total_Milestone_Amount__c += milestoneRec.Total_Installment_New__c;
                        ageingRec.Latest_Milestone_Due_Date__c = milestoneRec.Milestone_Due_Date__c;
                        System.debug('milestoneRec  '+milestoneRec.Name+' milestoneRec -> '+milestoneRec.Milestone_Due_Date__c +' days -> '+days+' Total_Installment_New__c ->  '+milestoneRec.Total_Installment_New__c);
                        if(days <= 30){
                            ageingRec.B1_Net__c	=	(ageingRec.B1_Net__c == null ? 0 : ageingRec.B1_Net__c) + milestoneRec.Total_Installment_New__c;
                        }else if(days > 30 && days <= 60){
                            ageingRec.B2_Net__c	=	(ageingRec.B2_Net__c == null ? 0 : ageingRec.B2_Net__c) + milestoneRec.Total_Installment_New__c;
                        }else if(days > 60 && days <= 90){
                            ageingRec.B3_Net__c	=	(ageingRec.B3_Net__c == null ? 0 : ageingRec.B3_Net__c) + milestoneRec.Total_Installment_New__c;
                        }else if(days > 90 && days <= 120){
                            ageingRec.B4_Net__c	=	(ageingRec.B4_Net__c == null ? 0 : ageingRec.B4_Net__c) + milestoneRec.Total_Installment_New__c;
                        }else if(days > 120 && days <= 180){
                            ageingRec.B5_Net__c	=	(ageingRec.B5_Net__c == null ? 0 : ageingRec.B5_Net__c) + milestoneRec.Total_Installment_New__c;                           
                        }else if(days > 181 && days <= 360){
                            ageingRec.B6_Net__c	= (ageingRec.B6_Net__c == null ? 0 : ageingRec.B6_Net__c) + milestoneRec.Total_Installment_New__c;
                        }else if(days > 360){
                            ageingRec.B7_Net__c = (ageingRec.B7_Net__c == null ? 0 : ageingRec.B7_Net__c) + milestoneRec.Total_Installment_New__c;
                        }                    
                    }
                    ageingRec.B7_361_Days__c = ageingRec.B7_Net__c;
                    ageingRec.B6_181_360_Days__c = ageingRec.B6_Net__c;
                    ageingRec.B5_121_180_Days__c = ageingRec.B5_Net__c;
                    ageingRec.B4_91_120_Days__c = ageingRec.B4_Net__c;
                    ageingRec.B3_61_90_Days__c = ageingRec.B3_Net__c;
                    ageingRec.B2_31_60_Days__c = ageingRec.B2_Net__c;
                    ageingRec.B1_0_30_Days__c = ageingRec.B1_Net__c;
                    
                    System.debug('ageingRec -> '+ageingRec);
                    System.debug('7 Total_On_Account_Money -> '+Total_On_Account_Money+' B7 NET '+ageingRec.B7_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B7_Net__c > 0 ){
                        ageingRec.B7_361_Days__c = (Total_On_Account_Money - ageingRec.B7_Net__c) > 0 ? 0 : ageingRec.B7_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B7_Net__c;
                    }
                    System.debug('ageingRec.B7_361_Days__c -> '+ageingRec.B7_361_Days__c);
                    System.debug('6 Total_On_Account_Money -> '+Total_On_Account_Money+' B6 NET '+ageingRec.B6_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B7_361_Days__c <= 0 && ageingRec.B6_Net__c > 0){
                        ageingRec.B6_181_360_Days__c = (Total_On_Account_Money - ageingRec.B6_Net__c) > 0 ? 0 : ageingRec.B6_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B6_Net__c;
                    }
                    System.debug('ageingRec.B6_181_360_Days__c -> '+ageingRec.B6_181_360_Days__c);
                    System.debug('5 Total_On_Account_Money -> '+Total_On_Account_Money+' B5 NET '+ageingRec.B5_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B6_181_360_Days__c <= 0 && ageingRec.B5_Net__c > 0){
                        ageingRec.B5_121_180_Days__c = (Total_On_Account_Money - ageingRec.B5_Net__c) > 0 ? 0 : ageingRec.B5_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B5_Net__c;
                    }
                    System.debug('ageingRec.B5_121_180_Days__c -> '+ageingRec.B5_121_180_Days__c);
                    System.debug('4 Total_On_Account_Money -> '+Total_On_Account_Money+' B4 NET '+ageingRec.B4_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B5_121_180_Days__c <= 0 && ageingRec.B4_Net__c > 0){
                        ageingRec.B4_91_120_Days__c = (Total_On_Account_Money - ageingRec.B5_Net__c) > 0 ? 0 : ageingRec.B5_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B4_Net__c;
                    }
                    System.debug('ageingRec.B4_91_120_Days__c -> '+ageingRec.B4_91_120_Days__c);
                    System.debug('3 Total_On_Account_Money -> '+Total_On_Account_Money+' B3 NET '+ageingRec.B3_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B4_91_120_Days__c <= 0 && ageingRec.B3_Net__c > 0){
                        ageingRec.B3_61_90_Days__c = (Total_On_Account_Money - ageingRec.B3_Net__c) > 0 ? 0 : ageingRec.B3_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B3_Net__c;
                    }
                    System.debug('ageingRec.B3_61_90_Days__c -> '+ageingRec.B3_61_90_Days__c);
                    System.debug('2 Total_On_Account_Money -> '+Total_On_Account_Money+' B2 NET '+ageingRec.B2_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B3_61_90_Days__c <= 0 && ageingRec.B2_Net__c > 0){
                        ageingRec.B2_31_60_Days__c = (Total_On_Account_Money - ageingRec.B2_Net__c) > 0 ? 0 : ageingRec.B2_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B2_Net__c;
                    }
                    System.debug('ageingRec.B2_31_60_Days__c -> '+ageingRec.B2_31_60_Days__c);
                    System.debug('1 Total_On_Account_Money -> '+Total_On_Account_Money+' B1 NET '+ageingRec.B1_Net__c);
                    if(Total_On_Account_Money != null && Total_On_Account_Money > 0 && ageingRec.B2_31_60_Days__c <= 0 && ageingRec.B1_Net__c > 0){
                        ageingRec.B1_0_30_Days__c = (Total_On_Account_Money - ageingRec.B1_Net__c) > 0 ? 0 : ageingRec.B1_Net__c - Total_On_Account_Money;
                        Total_On_Account_Money = Total_On_Account_Money - ageingRec.B1_Net__c;
                    }
                    System.debug('ageingRec.B1_0_30_Days__c -> '+ageingRec.B1_0_30_Days__c);
                    upsertAgeingList.add(ageingRec);
                    System.debug('upsertAgeingList ->'+upsertAgeingList);
                }  
            }
            //Update milestone ageing records
            if(upsertAgeingList != null && !upsertAgeingList.isEmpty()){
                Schema.SObjectField ftoken = Milestone_Ageing__c.Fields.id;
                Database.UpsertResult[] resultupsertAgeingList = Database.upsert(upsertAgeingList,ftoken,false);
                upsert upsertAgeingList;
            }
        } catch (Exception e) {
            System.debug('Exception E'+e);
            System.debug('Exception E'+e.getMessage());
        }
        
    }
}