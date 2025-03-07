public class PaymentTriggerHelper {
    
    
    public static void updateApproveValue(List<PropStrength__Received_Payment__c> newList){
        String intPayRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        String intPayIncChargeRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        for(PropStrength__Received_Payment__c payRec : newList){
            if(payRec.RecordTypeId == intPayRecTypeId || payRec.RecordTypeId == intPayIncChargeRecTypeId){ 
                payRec.Audit_Approval_Status__c = 'Under Approval';
                payRec.Submission_Resubmission_Date__c = System.today(); // Added By Gourav Gour 27/05/2024
            }
        }
    }
    
    @future(callOut=true)
    Public static void sendToMobileAPI(string newString, string oldString,boolean isInsert) {
        list<PropStrength__Received_Payment__c> newList = (list<PropStrength__Received_Payment__c>)JSON.deserialize(newString, list<PropStrength__Received_Payment__c>.Class);
        Id paymentDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        Id chargeDueId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        String notificationStatus = '';
        Boolean sendAlert = false;
        String response = '';
        list<Id> payIds = new list<Id>();
        for(PropStrength__Received_Payment__c bk : newList) {
            if(oldString != null) {
                Map<Id,PropStrength__Received_Payment__c> oldMap = (Map<Id,PropStrength__Received_Payment__c>)JSON.deserialize(oldString, Map<Id,PropStrength__Received_Payment__c>.Class);
                if(bk.Demand_Raise__c == true && 
                   bk.Demand_Raise__c != oldMap.get(bk.Id).Demand_Raise__c) {
                       notificationStatus = 'upon_demand_generation';
                       sendAlert = true;
                       payIds.add(bk.Id);
                   }
                if(bk.X1st_Reminder_Sent__c != oldMap.get(bk.Id).X1st_Reminder_Sent__c && bk.X1st_Reminder_Sent__c) {
                    notificationStatus = 'reminder_pre_due_date';
                    sendAlert = true;
                    payIds.add(bk.Id);
                } else if(bk.X2nd_Reminder_Sent__c != oldMap.get(bk.Id).X2nd_Reminder_Sent__c && bk.X2nd_Reminder_Sent__c) {
                    notificationStatus = 'reminder_pre_due_date';
                    sendAlert = true;
                    payIds.add(bk.Id);
                } else if(bk.X3rd_Reminder_Sent__c != oldMap.get(bk.Id).X3rd_Reminder_Sent__c && bk.X3rd_Reminder_Sent__c) {
                    notificationStatus = 'reminder_pre_due_date';
                    sendAlert = true;
                    payIds.add(bk.Id);
                } else if(bk.X4th_Reminder_Sent__c != oldMap.get(bk.Id).X4th_Reminder_Sent__c && bk.X4th_Reminder_Sent__c) {
                    notificationStatus = 'reminder_pre_due_date';
                    sendAlert = true;
                    payIds.add(bk.Id);
                }
                
                if(bk.Last_Reminder_Sent__c != oldMap.get(bk.Id).Last_Reminder_Sent__c && 
                   bk.Last_Reminder_Sent__c) {
                       notificationStatus = 'reminder_post_due_date';
                       sendAlert = true;
                       payIds.add(bk.Id);
                   }
            }
            else {
                /**/
                
                if(bk.PropStrength__Amount_Due_Type__c == 'Late Payment Fee' && 
                   bk.RecordTypeId == chargeDueId) {
                       notificationStatus = 'late_payments_charges';
                       sendAlert = true;
                       payIds.add(bk.Id);
                   }
            }
        }
        if(payIds != null && payIds.size() > 0){
            response = callbookingAPI(payIds,isInsert, sendAlert, notificationStatus);
        }
    }
    
    public static String callbookingAPI(list<Id> payIds,Boolean isInsert, Boolean sendAlert,String notificationStatus){
        String response = '';
        if(isInsert){ 
            ID jobID = System.enqueueJob(new MobileAppQueuable_PS(new List<String>{payIds[0]},notificationStatus,'alert'));
        }else if(sendAlert){ 
            ID jobID = System.enqueueJob(new MobileAppQueuable_PS(new List<String>{payIds[0]},notificationStatus,'alert'));
        }
        return response;
    }
    
    public static void UpdatePayment(List<PropStrength__Received_Payment__c> payList){
        Id payDue = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        for(PropStrength__Received_Payment__c onePay : payList) {
            if(onePay.PropStrength__Amount_Due_Type__c == 'Reversal payment due' && onePay.RecordTypeId == payDue) {
                onePay.PropStrength__Demand_Email_Sent__c = true;
            }
        }
    }
    
    public static void sendEmailChequeBounced(List<PropStrength__Received_Payment__c> payList){
        Id incomeChargeDue = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Set<Id> payIds = new Set<Id>(); 
        Set<Id> bookingIds = new Set<Id>(); 
        for(PropStrength__Received_Payment__c onePay : payList) {
            if(onePay.PropStrength__Amount_Due_Type__c == 'Cheque Bouncing Charges' && onePay.RecordTypeId == incomeChargeDue) {
                bookingIds.add(onePay.PropStrength__Application_Booking__c);
                payIds.add(onePay.Id);
            }
        }
        system.debug('payIds::'+payIds);
        system.debug('bookingIds::'+bookingIds);
        if(!payIds.isEmpty() && !bookingIds.isEmpty()) {
            if(System.IsBatch() == false && System.isFuture() == false) { 
                Database.executeBatch(new sendEmailChequeBouncedPaymentBatch(payIds,bookingIds),1);
            }
        }
    }
    
    public static void updateIssuedBankGl(List<PropStrength__Received_Payment__c> newRecList) {
        List<Id> bookIds = new List<Id>();
        for(PropStrength__Received_Payment__c payRec : newRecList) {
            if(payRec.PropStrength__Application_Booking__c != null) {
                bookIds.add(payRec.PropStrength__Application_Booking__c);
            }
        }
        System.debug('bookIds****'+bookIds);
        if(!bookIds.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> booking = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Offer__c FROM PropStrength__Application_Booking__c WHERE Id IN :bookIds]);
            if(!booking.isEmpty()) {
                List<Id> offerIds = new List<Id>();
                for(PropStrength__Application_Booking__c book : booking.values()) {
                    offerIds.add(book.PropStrength__Offer__c);
                }
                System.debug('offerIds****'+offerIds);
                if(!offerIds.isEmpty()) {
                    List<PropStrength__Received_Payment__c> updRec = new List<PropStrength__Received_Payment__c>();
                    Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, (SELECT Id, Bank_GL__c, Instrument_Date__c, GL_Date__c, Payment_Clearance_Date__c, Instrument_Number__c FROM PropStrength__PrePayment_Received__r) FROM PropStrength__Offer__c WHERE Id IN :offerIds]);
                    for(PropStrength__Received_Payment__c payRec : newRecList) {
                        if(payRec.Payment_Clearance_Date__c == null && payRec.Bank_GL__c == null && payRec.Instrument_Date__c == null && payRec.Instrument_Number__c == null && payRec.GL_Date__c == null && booking.containsKey(payRec.PropStrength__Application_Booking__c) && booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c != null && offerMap.containsKey(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c) && offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r.size() == 1) {
                            updRec.add(new PropStrength__Received_Payment__c(Id = payRec.Id, Bank_GL__c = offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r[0].Bank_GL__c, Instrument_Date__c = offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r[0].Instrument_Date__c, GL_Date__c = offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r[0].GL_Date__c, Payment_Clearance_Date__c = offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r[0].Payment_Clearance_Date__c, Instrument_Number__c = offerMap.get(booking.get(payRec.PropStrength__Application_Booking__c).PropStrength__Offer__c).PropStrength__PrePayment_Received__r[0].Instrument_Number__c));
                        }
                    }
                    System.debug('updRec****'+updRec);
                    if(!updRec.isEmpty() && !Test.isRunningTest()) {
                        update updRec;
                    }
                }
            }
        }
    }
    
    /* public static void updatePercentageBooking(List<PropStrength__Received_Payment__c> newRecList) {
// PaymentTriggerHandler.updatePercentageBooking(newRecList);
}
*/
    //Added by deepak sharma on 17 august 2023 to send demand letter when ppd is get approved
    public static void sendDemandLetter(List<PropStrength__Received_Payment__c> newRecList) {
        Id payDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId();
        Set<Id> payId = new Set<Id>();
        
        for(PropStrength__Received_Payment__c pay : newRecList) {
            if(pay.RecordTypeId == payDueRT) {
                payId.add(pay.Id);
            }
        }
        
        if(!payId.isEmpty()) {
            Set<Id> payIdset = new Set<Id>(); 
            List<PropStrength__Received_Payment__c> payList = [SELECT Id, PropStrength__Billing_Date__c, PropStrength__Demand_Email_Sent__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Project__r.Grace_Days_Time_Linked__c, PropStrength__Payment_Date__c, PropStrength__Payment_Plan_Detail__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Is_Milestone_Completed__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Approval_Status__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Project__r.Grace_Days__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Milestone_Type__c FROM PropStrength__Received_Payment__c WHERE Id IN :payId]; 
            List<PropStrength__Received_Payment__c> updatePaymentList = new List<PropStrength__Received_Payment__c>();
            List<PropStrength__Payment_Plan_Details__c> updatePpdList = new List<PropStrength__Payment_Plan_Details__c>();
            
            for(PropStrength__Received_Payment__c pay : payList) {
                if(pay.PropStrength__Payment_Plan_Detail__c != null && pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Is_Milestone_Completed__c && pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Approval_Status__c == 'Approved') {
                    payIdset.add(pay.Id);
                }
            }
            System.debug('payIdset***'+payIdset);
            
            if(!payIdSet.isEmpty()) {  
                SendEmailQueue emailJob = new SendEmailQueue(payIdset);
                System.enqueueJob(emailJob);
                for(PropStrength__Received_Payment__c pay : payList) {
                    if(pay.PropStrength__Payment_Plan_Detail__c != null && pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Is_Milestone_Completed__c && pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Approval_Status__c == 'Approved') {
                        PropStrength__Received_Payment__c upPay = new PropStrength__Received_Payment__c();
                        upPay.Id = pay.Id;
                        upPay.PropStrength__Demand_Generation_Date__c = date.today();
                        upPay.PropStrength__Demand_Generated__c = true;
                        upPay.PropStrength__Demand_Email_Sent__c = true;
                        upPay.PropStrength__Demand_Status__c = 'Demand Generated';
                        if(pay.PropStrength__Payment_Date__c < System.Today()) {
                            upPay.PropStrength__Payment_Date__c = pay.PropStrength__Billing_Date__c;
                            pay.PropStrength__Payment_Date__c = pay.PropStrength__Billing_Date__c;
                        }
                        if(pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Milestone_Type__c == 'Time Linked') {
                            upPay.PropStrength__Actual_Payment_Date__c = (pay.PropStrength__Payment_Date__c != null ? pay.PropStrength__Payment_Date__c : null) + 
                                Integer.valueOf(pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Project__r.Grace_Days_Time_Linked__c);
                        } else if(pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Milestone_Type__c == 'Construction Linked') {
                            upPay.PropStrength__Actual_Payment_Date__c = (pay.PropStrength__Payment_Date__c != null ? pay.PropStrength__Payment_Date__c : null) + 
                                Integer.valueOf(pay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone__r.PropStrength__Project__r.Grace_Days__c);
                        }
                        updatePaymentList.add(upPay);
                        updatePpdList.add(new PropStrength__Payment_Plan_Details__c(Id=pay.PropStrength__Payment_Plan_Detail__c, PropStrength__Final_Payment_Date__c=upPay.PropStrength__Actual_Payment_Date__c));
                    }
                }
                
                System.debug('updatePaymentList***'+updatePaymentList);
                if(!updatePaymentList.isEmpty() && !Test.isRunningTest()) {
                    update updatePaymentList;
                }
                if(!updatePpdList.isEmpty()) {
                    update updatePpdList;
                }
            }
        }
    }
    
    //Added by deepak sharma on 23 October 2023 to update Total Interest Due Till Date On booking
    public static void updateTotalIntDueOnbook(List<PropStrength__Received_Payment__c> newRecList) {
        Id incChrgeDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Set<Id> bookingId = new Set<Id>();
        
        for(PropStrength__Received_Payment__c pay: newRecList) {
            if(pay.RecordTypeId == incChrgeDueRT && pay.PropStrength__Amount_Due_Type__c == 'Late Payment Fee' && pay.PropStrength__Application_Booking__c!= null) {
                bookingId.add(pay.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookingId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :incChrgeDueRT AND PropStrength__Amount_Due_Type__c = 'Late Payment Fee') FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId];
            List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                    Decimal sum = 0;
                    for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                        if(pay.PropStrength__Amount__c != null) {
                            sum += pay.PropStrength__Amount__c;
                        }
                    }
                    updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, Total_Interest_Due_Till_Date__c = sum));
                }
            }
            
            if(!updateBookList.isEmpty()) {
                update updateBookList;
            }
        }
    }
    // Added by Gourav Gour On 12/04/2024
    // Modified By Gourav Gour 27/05/2024
    public static void updateTotalDLDFeesOnBook(List<PropStrength__Received_Payment__c> newRecList) {
        Id incChrgeDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Id incChrgeRecieveRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        List<String> incomeChargeDueAmountType= System.Label.IncomeChargeDue_AmountType.split(',');
        List<String> incomeChargeReceivedAmountType= System.Label.IncomeChargeReceived_AmountType.split(',');
        Set<Id> bookingId = new Set<Id>();
        for(PropStrength__Received_Payment__c pay: newRecList) {
            if(( (pay.RecordTypeId == incChrgeDueRT && incomeChargeDueAmountType.contains(pay.PropStrength__Amount_Due_Type__c)) 
                || (pay.RecordTypeId == incChrgeRecieveRT && incomeChargeReceivedAmountType.contains(pay.PropStrength__Amount_Due_Type__c))) 
               && pay.PropStrength__Application_Booking__c != null && !pay.PropStrength__Is_Reversal_Created__c) {
                   bookingId.add(pay.PropStrength__Application_Booking__c);
               }
        }
        if(!bookingId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Amount__c, RecordTypeId FROM PropStrength__Payments_Cheques__r WHERE ((RecordTypeId = :incChrgeDueRT AND PropStrength__Amount_Due_Type__c IN :incomeChargeDueAmountType) OR (RecordTypeId =:incChrgeRecieveRT AND PropStrength__Amount_Due_Type__c IN :incomeChargeReceivedAmountType)) AND PropStrength__Is_Reversal_Created__c =false) FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId];
            List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                    Decimal sumDue = 0;
                    Decimal sumRecieve = 0;
                    for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                        if(pay.RecordTypeId == incChrgeDueRT && pay.PropStrength__Amount__c != null) {
                            sumDue += pay.PropStrength__Amount__c;
                        }
                        if(pay.RecordTypeId == incChrgeRecieveRT && pay.PropStrength__Amount__c != null) {
                            sumRecieve += pay.PropStrength__Amount__c;
                        }
                    }
                    if(sumRecieve >= sumDue) {
                        updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, DLD_Fees_Due__c = sumDue, DLD_Fees_Received__c = sumRecieve, Oqood_Fees_Received_Date__c = System.Today(), Oqood_Fees_Received__c = true));
                    } else {
                        updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, DLD_Fees_Due__c = sumDue, DLD_Fees_Received__c = sumRecieve));
                    }
                }
            }
            if(!updateBookList.isEmpty()) {
                update updateBookList;
            }
        }
    }
    
    //Added by deepak sharma on 23 October 2023 to update Total Interest Due Till Date On booking (on Update)
    public static void updateTotalIntDueOnbookOnUpd(List<PropStrength__Received_Payment__c> newRecList, Map<Id, PropStrength__Received_Payment__c> oldPayRecMap) {
        Id incChrgeDueRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Set<Id> bookingId = new Set<Id>();
        
        for(PropStrength__Received_Payment__c pay: newRecList) {
            if(pay.RecordTypeId == incChrgeDueRT && pay.PropStrength__Amount_Due_Type__c == 'Late Payment Fee' && pay.PropStrength__Application_Booking__c!= null  && oldPayRecMap.get(pay.Id).PropStrength__Application_Booking__c != pay.PropStrength__Application_Booking__c) {
                bookingId.add(pay.PropStrength__Application_Booking__c);
                bookingId.add(oldPayRecMap.get(pay.Id).PropStrength__Application_Booking__c);
            } else if(pay.RecordTypeId == incChrgeDueRT && pay.PropStrength__Amount_Due_Type__c == 'Late Payment Fee' && pay.PropStrength__Application_Booking__c!= null && oldPayRecMap.get(pay.Id).PropStrength__Amount__c != pay.PropStrength__Amount__c) {
                bookingId.add(pay.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookingId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, (SELECT Id, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :incChrgeDueRT AND PropStrength__Amount_Due_Type__c = 'Late Payment Fee') FROM PropStrength__Application_Booking__c WHERE Id IN :bookingId];
            List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
            
            for(PropStrength__Application_Booking__c book : bookList) {
                if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                    Decimal sum = 0;
                    for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                        if(pay.PropStrength__Amount__c != null) {
                            sum += pay.PropStrength__Amount__c;
                        }
                    }
                    updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, Total_Interest_Due_Till_Date__c = sum));
                }
            }
            
            if(!updateBookList.isEmpty()) {
                update updateBookList;
            }
        }
    }
    
    //Added by deepak sharma on 26 October 2023 to show error when Payment Received is created more than pre-payment on booking (on insert)
    public static void checkPrePayment(List<PropStrength__Received_Payment__c> newRecList) {
        Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Set<Id> bookId = new Set<Id>();
        Decimal sizePayRec = 0;
        
        for(PropStrength__Received_Payment__c pay : newRecList) {
            System.debug(pay.PropStrength__Application_Booking__c);
            System.debug(pay.RecordTypeId == payRecRT);
            System.debug(pay.RecordTypeId);
            System.debug(payRecRT);
            if(pay.RecordTypeId == payRecRT && pay.PropStrength__Application_Booking__c != null) {
                bookId.add(pay.PropStrength__Application_Booking__c);
                sizePayRec++;
            }
        }
        
        System.debug('bookId: '+bookId);
        System.debug('sizePayRec: '+sizePayRec);
        
        if(!bookId.isEmpty()) {
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Offer__c, CreatedDate FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
            
            System.debug('bookMap: '+bookMap);
            
            if(!bookMap.isEmpty()) {
                Set<Id> offerId = new Set<Id>();
                
                for(PropStrength__Application_Booking__c book : bookMap.values()) {
                    if(book.PropStrength__Offer__c != null) {
                        offerId.add(book.PropStrength__Offer__c);
                    }
                }
                
                System.debug('offerId: '+offerId);
                
                if(!offerId.isEmpty()) {
                    Map<Id, PropStrength__Offer__c> offerMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, (SELECT Id FROM PropStrength__PrePayment_Received__r)  FROM PropStrength__Offer__c WHERE Id IN :offerId]);
                    System.debug('offerMap: '+offerMap);
                    
                    Map<Id, Decimal> bookPrePayCount = new Map<Id,Decimal>();
                    
                    if(!offerMap.isEmpty()) {
                        for(Id bookIdMap : bookMap.keySet()) {
                            Id offId = bookMap.get(bookIdMap).PropStrength__Offer__c;
                            if(offerMap.containskey(offId) && offerMap.get(offId).PropStrength__PrePayment_Received__r != null )
                                bookPrePayCount.put(bookIdMap, offerMap.get(offId).PropStrength__PrePayment_Received__r.size());
                        }
                    }
                    
                    System.debug('bookPrePayCount: '+bookPrePayCount);
                    
                    if(!bookPrePayCount.isEmpty()) {
                        for(PropStrength__Received_Payment__c pay : newRecList) {
                            if(pay.RecordTypeId == payRecRT && pay.PropStrength__Application_Booking__c != null && bookMap.containsKey(pay.PropStrength__Application_Booking__c)) {
                                Datetime recordCreatedDateTime =  bookMap.get(pay.PropStrength__Application_Booking__c).CreatedDate;
                                Datetime currentDateTime = Datetime.now();
                                
                                // Calculate the time difference in minutes
                                Integer minutesDifference = currentDateTime.minute() - recordCreatedDateTime.minute();
                                
                                if (minutesDifference <= 1) {
                                    if(!Test.isRunningTest() && sizePayRec != null && bookPrePayCount.get(pay.PropStrength__Application_Booking__c) != sizePayRec) {
                                        //pay.addError('You can\'t Add/Remove Payment');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Added by Deepak Sharma on 01'Nov 2023 to check if balance is zero , generate PCC document (On insert of Payment received)
    public static void checkBalance(List<PropStrength__Received_Payment__c> newRecList) {
        Id payRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Set<Id> bookIdRecs = new Set<Id>();
        for(PropStrength__Received_Payment__c pay: newRecList) {
            if(pay.RecordTypeId == payRecTypeId) { 
                bookIdRecs.add(pay.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookIdRecs.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookRecs = [SELECT Id, Total_Interest_Due_Till_Date__c, Total_Interest_Received_Till_Date__c FROM PropStrength__Application_Booking__c WHERE PCC_Document_Generated__c = FALSE AND SPA_Executed__c = TRUE AND PropStrength__Active__c = TRUE AND Pre_Registration_Completed__c = TRUE AND Id IN :bookIdRecs];
            System.debug('bookRecs PCC***'+bookRecs);
            if(!bookRecs.isEmpty()) {
                Set<Id> bookId = new Set<Id>();
                for(PropStrength__Application_Booking__c book: bookRecs) {
                    Decimal totInt = book.Total_Interest_Due_Till_Date__c != null ? book.Total_Interest_Due_Till_Date__c : 0;
                    if((totInt- book.Total_Interest_Received_Till_Date__c) <= 0) {
                        bookId.add(book.Id);
                    }
                }
                if(!bookId.isEmpty() && !System.isBatch()) {
                    BookingTriggerHelper.createPCCDocAtt(bookId);
                }
            }
        }
    }
    
    //Added by Deepak sharma on 21 Nov 2023 to create Income charge received on creation of Income charge due (DLD Fee)
    public static void createIncomChargeRecDLD(List<PropStrength__Received_Payment__c> newRecList) {
        Id payRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        Id incChrgeRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        
        Set<Id> bookIdRecs = new Set<Id>();
        for(PropStrength__Received_Payment__c pay: newRecList) {
            if(pay.RecordTypeId == payRecTypeId && pay.PropStrength__Amount_Due_Type__c == 'DLD Fees') { 
                bookIdRecs.add(pay.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookIdRecs.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookRecs = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Offer__c, PropStrength__Offer__r.Payment_Request_1__c,
                                                                                                                        PropStrength__Offer__r.Payment_Request_2__c, PropStrength__Offer__r.DLD_Amount__c,PropStrength__Offer__r.DLD_Amount_2__c,
                                                                                                                        PropStrength__Offer__r.Payment_Request_1__r.Mode__c, PropStrength__Offer__r.Payment_Request_2__r.Mode__c, PropStrength__Offer__r.Payment_Request_1__r.Instrument_Date__c, 
                                                                                                                        PropStrength__Offer__r.Payment_Request_2__r.Instrument_Date__c,PropStrength__Offer__r.Payment_Request_1__r.Instrument_Number__c,
                                                                                                                        PropStrength__Offer__r.Payment_Request_2__r.Instrument_Number__c, PropStrength__Offer__r.Payment_Request_1__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c,
                                                                                                                        PropStrength__Offer__r.Payment_Request_2__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c 
                                                                                                                        FROM PropStrength__Application_Booking__c WHERE Id IN :bookIdRecs AND PropStrength__Offer__c != null]);
            
            List<PropStrength__Received_Payment__c> createIncomeChargeRec = new List<PropStrength__Received_Payment__c>();
            
            for(PropStrength__Received_Payment__c pay: newRecList) {
                if(pay.RecordTypeId == payRecTypeId && pay.PropStrength__Amount_Due_Type__c == 'DLD Fees') {
                    if(pay.PropStrength__Application_Booking__c != null && !bookRecs.isEmpty() && bookRecs.containsKey(pay.PropStrength__Application_Booking__c)) {
                        if(bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__c != null && bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount__c != null && bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount__c > 0) {
                            createIncomeChargeRec.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pay.PropStrength__Application_Booking__c, Bank_GL__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c, PropStrength__Payment_Status__c = 'Approved', Instrument_Number__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__r.Instrument_Number__c, Instrument_Date__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__r.Instrument_Date__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Amount__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount__c, PropStrength__Amount_Due_Type__c = 'DLD Fees', PropStrength__Payment_Type__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__r.Mode__c, RecordTypeId = incChrgeRecTypeId, PropStrength__Income_Charge_Due__c = pay.Id));
                        }
                    }
                }
            }
            
            System.debug('createIncomeChargeRec*****');
            System.debug(createIncomeChargeRec);
            
            if(!createIncomeChargeRec.isEmpty()) {
                //insert createIncomeChargeRec;
                
                createIncomeChargeRec = new List<PropStrength__Received_Payment__c>();
                for(PropStrength__Received_Payment__c pay: newRecList) {
                    if(pay.RecordTypeId == payRecTypeId && pay.PropStrength__Amount_Due_Type__c == 'DLD Fees') {
                        if(pay.PropStrength__Application_Booking__c != null && !bookRecs.isEmpty() && bookRecs.containsKey(pay.PropStrength__Application_Booking__c)) {
                            if(bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__c != null && bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount_2__c != null && bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount_2__c > 0) {
                                createIncomeChargeRec.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = pay.PropStrength__Application_Booking__c, Bank_GL__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c, PropStrength__Payment_Status__c = 'Approved', Instrument_Number__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__r.Instrument_Number__c, Instrument_Date__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__r.Instrument_Date__c, PropStrength__Payment_Date__c = System.Today(), PropStrength__Amount__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.DLD_Amount_2__c, PropStrength__Amount_Due_Type__c = 'DLD Fees', PropStrength__Payment_Type__c = bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__r.Mode__c, RecordTypeId = incChrgeRecTypeId, PropStrength__Income_Charge_Due__c = pay.Id));
                            }
                        }
                    }
                }
                
                if(!createIncomeChargeRec.isEmpty()) {
                    //insert createIncomeChargeRec;
                }
                
                Map<Id, List<Id>> bookingIncChrRec = new Map<Id, List<Id>>();
                
                for(PropStrength__Received_Payment__c pay: newRecList) {
                    if(pay.RecordTypeId == payRecTypeId && pay.PropStrength__Amount_Due_Type__c == 'DLD Fees') {
                        for(PropStrength__Received_Payment__c insertedPay : createIncomeChargeRec) {
                            if(pay.PropStrength__Application_Booking__c != null && insertedPay.PropStrength__Application_Booking__c == pay.PropStrength__Application_Booking__c) {
                                if(!bookingIncChrRec.containsKey(pay.PropStrength__Application_Booking__c)) {
                                    bookingIncChrRec.put(pay.PropStrength__Application_Booking__c, new List<Id>{insertedPay.Id});
                                } else if(bookingIncChrRec.containsKey(pay.PropStrength__Application_Booking__c) && bookingIncChrRec.get(pay.PropStrength__Application_Booking__c).size() < 2) {
                                    bookingIncChrRec.get(pay.PropStrength__Application_Booking__c).add(insertedPay.Id);
                                }
                            }
                        }
                    }
                }
                
                System.debug('bookingIncChrRec*****');
                System.debug(bookingIncChrRec);
                
                List<Payment_Request__c> updatePrList = new List<Payment_Request__c>();
                for(PropStrength__Received_Payment__c pay: newRecList) {
                    if(pay.RecordTypeId == payRecTypeId && pay.PropStrength__Amount_Due_Type__c == 'DLD Fees') {
                        if(pay.PropStrength__Application_Booking__c != null && !bookRecs.isEmpty() && bookRecs.containsKey(pay.PropStrength__Application_Booking__c)) {
                            if(bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__c != null) {
                                if(bookingIncChrRec.containsKey(pay.PropStrength__Application_Booking__c)) {
                                    List<Id> tempList = bookingIncChrRec.get(pay.PropStrength__Application_Booking__c);
                                    if(!tempList.isEmpty()) {
                                        updatePrList.add(new Payment_Request__c(Id=bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_1__c, Payment__c = bookingIncChrRec.get(pay.PropStrength__Application_Booking__c)[0]));
                                    }
                                }
                            }
                            if(bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__c != null) {
                                if(bookingIncChrRec.containsKey(pay.PropStrength__Application_Booking__c)) {
                                    List<Id> tempList = bookingIncChrRec.get(pay.PropStrength__Application_Booking__c);
                                    if(tempList.size() > 1) {
                                        updatePrList.add(new Payment_Request__c(Id=bookRecs.get(pay.PropStrength__Application_Booking__c).PropStrength__Offer__r.Payment_Request_2__c, Payment__c = bookingIncChrRec.get(pay.PropStrength__Application_Booking__c)[1]));
                                    }
                                }
                            }
                        }
                    }
                }
                
                System.debug('updatePrList*****');
                System.debug(updatePrList);
                
                if(!updatePrList.isEmpty()) {
                    //update updatePrList;
                }
            }
        }
    }
    
    //Added by Deepak on 26 April 2024 to update fields according to metadata
    // Modified By gourav gour 27/05/2024 
    public static void updatePaymentRec(List<PropStrength__Received_Payment__c> newRecList) {        
        List<Payment_Object_Metadata_CS__c> metaDataRec = Payment_Object_Metadata_CS__c.getAll().values();
        Map<String,Id> mapOfDebitAccount = new Map<String,Id>();
        Map<String,Id> mapOfVATDebitAccount = new Map<String,Id>();
        Map<String,Id> mapOfCreditAccount = new Map<String,Id>();
        Set<String> accountMasterIds = new Set<String>();
        for(Payment_Object_Metadata_CS__c rec : metaDataRec){
            accountMasterIds.add(rec.Debit_Account_Account_Master_Id__c);
            accountMasterIds.add(rec.VAT_Debit_Account_Account_Master_Id__c);
            accountMasterIds.add(rec.Credit_Account_Account_Master_Id__c);            
        }
        if(!accountMasterIds.isEmpty()) {
            Map<Id, Account_Master__c > accountmasterRec = new Map<Id, Account_Master__c >([SELECT Id, name from Account_Master__c WHERE Id IN:accountMasterIds]);
            
            for(Payment_Object_Metadata_CS__c rec : metaDataRec){
                if(accountmasterRec.containskey(rec.Debit_Account_Account_Master_Id__c))
                    mapOfDebitAccount.put(rec.Record_type__c+''+rec.Amount_Type__c+''+rec.Other_Charges_Type__c, accountmasterRec.get(rec.Debit_Account_Account_Master_Id__c).Id);
                if(accountmasterRec.containskey(rec.VAT_Debit_Account_Account_Master_Id__c))
                    mapOfVATDebitAccount.put(rec.Record_type__c+''+rec.Amount_Type__c+''+rec.Other_Charges_Type__c, accountmasterRec.get(rec.VAT_Debit_Account_Account_Master_Id__c).Id);
                if(accountmasterRec.containskey(rec.Credit_Account_Account_Master_Id__c))
                    mapOfCreditAccount.put(rec.Record_type__c+''+rec.Amount_Type__c+''+rec.Other_Charges_Type__c, accountmasterRec.get(rec.Credit_Account_Account_Master_Id__c).Id);
            }
            Map<String,String> mapOfRecordTypeAndName = new Map<String,String>();
            mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId() ,'Payment Received');
            mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId() ,'Income Charge Due');
            mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId() ,'Income Charge Received');
            mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId() ,'Payment Due');
            
            
            Set<Id> payReceiptId = new Set<Id>();
            Set<Id> receiptReversalId = new Set<Id>();
            for(PropStrength__Received_Payment__c pay : newRecList) {           
                if(mapOfDebitAccount.containskey(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c)) {
                    pay.Debit_Account_1__c = mapOfDebitAccount.get(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c+''+pay.Charge_Type__c);
                }
                if(mapOfVATDebitAccount.containskey(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c)) {
                    pay.Tax_Debit_Account_1__c = mapOfVATDebitAccount.get(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c+''+pay.Charge_Type__c);
                }
                if(mapOfCreditAccount.containskey(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c)) {
                    pay.Credit_Account_1__c = mapOfCreditAccount.get(mapOfRecordTypeAndName.get(pay.recordtypeId)+''+pay.PropStrength__Amount_Due_Type__c+''+pay.Charge_Type__c);
                }            
            } 
        }
    }
    
    //Added by Deepak on 1 May 2024 to update fields according to type
    public static void updatePaymentRecForVAT(List<PropStrength__Received_Payment__c> newRecList) { 
        for(PropStrength__Received_Payment__c payRec : newRecList){
            if(payRec.Amount_Without_VAT__c != null && payRec.Amount_With_VAT__c != null){
                payRec.addError('You can\'t add Both value "Amount Without VAT" And "Amount With VAT" at same time');
            }
        }
        Map<String,String> mapOfRecordTypeAndName = new Map<String,String>();
        mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId() ,'Payment Received');
        mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId() ,'Income Charge Due');
        mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId() ,'Income Charge Received');
        mapOfRecordTypeAndName.put(Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Due').getRecordTypeId() ,'Payment Due');
        
        List<Update_VAT_on_Payment__mdt> metaDataRec = Update_VAT_on_Payment__mdt.getAll().values();
        List<String> listOfRecordTypeAmount = new List<String>();
        for(Update_VAT_on_Payment__mdt rec : metaDataRec){
            listOfRecordTypeAmount.add(rec.Record_Type__c+''+rec.Amount_Type__c);
        }
        for(PropStrength__Received_Payment__c payRec : newRecList){
            System.debug(mapOfRecordTypeAndName.get(payRec.recordtypeId) + '' + payRec.PropStrength__Amount_Due_Type__c+'*-----'+listOfRecordTypeAmount);
            if(listOfRecordTypeAmount.contains(mapOfRecordTypeAndName.get(payRec.recordtypeId) + '' + payRec.PropStrength__Amount_Due_Type__c)){
                if(payRec.Amount_Without_VAT__c == null && payRec.Amount_With_VAT__c == null){
                    payRec.addError('Please update amount in Amount Without VAT or Amount With VAT');
                }
                else{
                    if(payRec.VAT__c != null  ){
                        if(payRec.Amount_Without_VAT__c != null && payRec.Amount_With_VAT__c == null){
                            payRec.Amount_With_VAT__c = payRec.Amount_Without_VAT__c + (payRec.Amount_Without_VAT__c * payRec.VAT__c ) / 100;
                            payRec.VAT_Amount__c = payRec.Amount_With_VAT__c  - payRec.Amount_Without_VAT__c;
                            payRec.PropStrength__Amount__c = payRec.Amount_With_VAT__c;
                        }
                        else if(payRec.Amount_With_VAT__c != null && payRec.Amount_Without_VAT__c == null){
                            payRec.Amount_Without_VAT__c = ( payRec.Amount_With_VAT__c * 100 ) / ( 100 + payRec.VAT__c);
                            payRec.VAT_Amount__c = payRec.Amount_With_VAT__c - payRec.Amount_Without_VAT__c;
                            payRec.PropStrength__Amount__c = payRec.Amount_With_VAT__c;
                        }
                    }
                    else
                        payRec.addError('VAT % is mandatory in '+payRec.PropStrength__Amount_Due_Type__c + ' Value');
                }
            }  
        }
    }
    
    //Added by Nishank Manwani on 03 Jan 2024 to send Payment Receipt Mail and Receipt Reversal Email
    public static void sendPaymentReceipt(List<PropStrength__Received_Payment__c> newRecList) {
        Id paymentReceiveRecType = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        
        Set<Id> payReceiptId = new Set<Id>();
        Set<Id> receiptReversalId = new Set<Id>();
        for(PropStrength__Received_Payment__c pay : newRecList) {
            if(pay.RecordTypeId == paymentReceiveRecType) {
                if(pay.PropStrength__Amount__c >= 0 && !pay.Interim_Receipt_sent_to_customer__c && pay.Interim_Receipt_Sent_Date__c == null) {
                    payReceiptId.add(pay.Id);
                }
                if(pay.PropStrength__Amount__c < 0 && pay.PropStrength__Receipt_Reversed__c && pay.PropStrength__Amount_Due_Type__c == 'Receipt Reversal') {
                    receiptReversalId.add(pay.Id);
                }
            }
        }
        
        if(!payReceiptId.isEmpty() && !System.isBatch()) {
            PaymentTriggerHelper.sendPaymentReceiptMail(payReceiptId);
        }
        if(!receiptReversalId.isEmpty() && !System.isBatch()) {
            PaymentTriggerHelper.sendReceiptReversalMail(receiptReversalId);
        }
    }
    
    //Added by deepak sharma on 28 Feb 2023 to update date value on booking (on Update)
    public static void updateDatesOnBooking(List<PropStrength__Received_Payment__c> newRecList, Map<Id, PropStrength__Received_Payment__c> oldPayRecMap) {
        Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Set<Id> bookingIds = new Set<Id>();
        
        for(PropStrength__Received_Payment__c payRec : newRecList) {
            if(payRec.PropStrength__Application_Booking__c != null && payRec.RecordTypeId == payRecRT && !payRec.PropStrength__Receipt_Reversed__c 
               && ( ( oldPayRecMap == null && payRec.GL_Date__c != null ) || ( oldPayRecMap != null && payRec.GL_Date__c != oldPayRecMap.get(payRec.Id).GL_Date__c ) ) ) {
                   bookingIds.add(payRec.PropStrength__Application_Booking__c);
               }
        }
        
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
            List<Incentive_Payouts__c> createIncentivePayoutList = new List<Incentive_Payouts__c>();
            List<Incentive_Payouts__c> updateIncentivePayoutList = new List<Incentive_Payouts__c>();
            Id incentiveDueRecTypeId = Schema.SObjectType.Incentive_Payouts__c.getRecordTypeInfosByName().get('Incentive Due').getRecordTypeId();
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, 
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name, X20_Payment_GL_Date__c,X10_Payment_GL_Date__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, 
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c, 
                 Sales_Manager_Incentive__c, Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Director_Incentive__c, 
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, 
                 X10_Payment_Received_Date__c, X20_Payment_Received_Date__c, PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c, 
                 (SELECT Id, PropStrength__Amount__c,GL_Date__c  FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :payRecRT)
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
            
            for(PropStrength__Received_Payment__c payRec : newRecList) {
                if(payRec.PropStrength__Application_Booking__c != null && payRec.RecordTypeId == payRecRT && !payRec.PropStrength__Receipt_Reversed__c && !bookMap.isEmpty() && bookMap.containsKey(payRec.PropStrength__Application_Booking__c)) {
                    PropStrength__Application_Booking__c tempBooking = bookMap.get(payRec.PropStrength__Application_Booking__c);
                    Decimal totalPastPaymentGLAmt = 0.00;
                    if(!tempBooking.PropStrength__Payments_Cheques__r.isEmpty()) {
                        for(PropStrength__Received_Payment__c payRecord : tempBooking.PropStrength__Payments_Cheques__r) {
                            if(payRecord.GL_Date__c != null ){
                                totalPastPaymentGLAmt += payRecord.PropStrength__Amount__c; 
                            }
                        }
                        if(payRec.GL_Date__c != null)
                            totalPastPaymentGLAmt += payRec.PropStrength__Amount__c;
                        
                        Decimal totalPercentage = (totalPastPaymentGLAmt / (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c)) * 100;
                        //Decimal twentyPercentage = tempBooking.PropStrength__Revised_Total_Sales_Consideration__c * 0.20;
                        //Decimal nineFivePercent = tempBooking.PropStrength__Revised_Total_Sales_Consideration__c * 0.095;
                        System.debug('test*-----'+totalPercentage);
                        PropStrength__Application_Booking__c newbook = new PropStrength__Application_Booking__c();
                        
                        if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 9.5)) {
                            if(tempBooking.X9_5_Payment_Received_Date__c == null) {
                                newbook.Id = tempBooking.Id;
                                newbook.X9_5_Payment_Received_Date__c = System.Today();
                            }
                        }
                        if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 10)) {
                            newbook.Id = tempBooking.Id;
                            if(tempBooking.X10_Payment_Received_Date__c == null)                                
                                newbook.X10_Payment_Received_Date__c = System.Today();
                            if(tempBooking.X10_Payment_GL_Date__c == null)  
                                newbook.X10_Payment_GL_Date__c = payRec.GL_Date__c != null ? Date.ValueOf(payRec.GL_Date__c) : null; 
                            
                        }
                        if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 20)) {
                            newbook.Id = tempBooking.Id;
                            if(tempBooking.X20_Payment_Received_Date__c == null)                                 
                                newbook.X20_Payment_Received_Date__c = System.Today();
                            if(tempBooking.X20_Payment_GL_Date__c == null)   
                                newbook.X20_Payment_GL_Date__c = payRec.GL_Date__c != null ? Date.ValueOf(payRec.GL_Date__c) : null;   //@Deeapak Added For GL Date
                            
                        }
                        if(newBook != null && newBook.Id != null) {
                            updateBookingPerc.add(newbook);
                        }
                    }
                }
            }
            if(updateBookingPerc.size() > 0){
                update updateBookingPerc;
            }
        }
    }
    
    //Added by Nishank Manwani on 03 Jan 2024 to send Payment Receipt Mail
    @Future(callout=true)
    public static void sendPaymentReceiptMail(Set<Id> paymentId) {
        if(!paymentId.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentRec = [SELECT Id, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c, PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c, PropStrength__Application_Booking__r.CRM_Executive_Email__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c FROM PropStrength__Received_Payment__c WHERE Id IN :paymentId];
            Set<String> emailAddress = new Set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Payment Receipt Email Template' limit 1];
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest()) {
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: paymentRec[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c limit 1];             
            }
            Id TempId;
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            if(!paymentRec.isEmpty()) {
                Set<Id> bookId = new Set<Id>();
                Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>();
                
                for(PropStrength__Received_Payment__c pay : paymentRec) {
                    if(pay.PropStrength__Application_Booking__c != null) {
                        bookId.add(pay.PropStrength__Application_Booking__c);
                    }
                }
                
                if(!bookId.isEmpty()) {
                    bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, (SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Name 
                                                                                             FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = true) FROM PropStrength__Application_Booking__c WHERE Id IN :bookId]);
                }
                
                List<Attachment> insertAttList = new List<Attachment>();
                List<PropStrength__Received_Payment__c> updatePayRecList = new List<PropStrength__Received_Payment__c>();
                
                for(PropStrength__Received_Payment__c pay : paymentRec) {
                    String frmsrc = '';
                    PageReference p1 = null;
                    if(pay.PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.Siniya_Island_Project__c) {
                        frmsrc = '/apex/PaymentReceiptSiniya?id=' + pay.Id+'&type=Receipt';
                        p1 = Page.PaymentReceiptSiniya;
                    } else {
                        frmsrc = '/apex/PaymentReceipt?id=' + pay.Id+'&type=Receipt';
                        p1 = Page.PaymentReceipt;
                    }
                    
                    p1.getParameters().put('id', String.valueOf(pay.Id));
                    p1.getParameters().put('type', 'Receipt');
                    String aName;
                    String b;
                    blob content;
                    aName ='PaymentReceipt';
                    
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    List<String> toList = new List<String>();
                    
                    emailAddress.add(pay.PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c);
                    if (owea.size() > 0) {
                        emails.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    
                    Attachment a1 = new Attachment();
                    a1.parentid = pay.Id;
                    a1.name = aName + '.pdf';
                    if (Test.IsRunningTest()) {
                        a1.body = Blob.valueOf('UNIT.TEST');
                        content =  Blob.valueOf('UNIT.TEST');
                    } else {
                        a1.body = p1.getContentAsPDF();
                        content = p1.getContentAsPDF();
                    } 
                    insertAttList.add(a1);
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(aName+'.pdf');
                    efa.setBody(content);
                    emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    emails.setWhatId(pay.Id);
                    
                    if(!bookMap.isEmpty() && pay.PropStrength__Application_Booking__c != null && bookMap.containsKey(pay.PropStrength__Application_Booking__c)) {
                        for(PropStrength__Applicant_Detail__c appDetails : bookMap.get(pay.PropStrength__Application_Booking__c).PropStrength__Applicant_Details__r) {
                            if(appDetails.PropStrength__Applicant_Email__c != null) {
                                toList.add(appDetails.PropStrength__Applicant_Email__c);
                            }
                        }
                    }
                    
                    if(!toList.isEmpty()) {
                        emails.setToAddresses(toList); 
                    }
                    
                    emails.setTemplateId(TempId);
                    if(pay.PropStrength__Application_Booking__r.CRM_Executive_Email__c != null && pay.PropStrength__Application_Booking__r.CRM_Executive_Email__c != '') {
                        emails.setccAddresses(new String[] {pay.PropStrength__Application_Booking__r.CRM_Executive_Email__c});
                    }
                    
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(pay.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    emaillist.add(emails);
                    
                    PropStrength__Received_Payment__c updPay = new PropStrength__Received_Payment__c();
                    updPay.Id = pay.Id;
                    updPay.Interim_Receipt_sent_to_customer__c = true;
                    updPay.Interim_Receipt_Sent_Date__c = Date.today();
                    updatePayRecList.add(updPay);
                }
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                        if(!insertAttList.isEmpty()) {
                            insert insertAttList;
                        }
                        if(!updatePayRecList.isEmpty()) {
                            update updatePayRecList;
                        }
                    }
                } catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }  
        }
    }
    
    
    
    //Added by Nishank Manwani on 03 Jan 2024 to send Receipt Reversal Email
    @Future(callout=true)
    public static void sendReceiptReversalMail(set<Id> paymentId) {
        if(!paymentId.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentRec = [SELECT Id, PropStrength__Application_Booking__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email FROM PropStrength__Received_Payment__c WHERE Id IN :paymentId];
            Set<String> emailAddress = new Set<String>();
            List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
            
            List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE Name = 'Receipt Reversal Email Template' limit 1];
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if( !test.isrunningtest())
                owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];
            
            Id TempId;
            if(!templatelist.isEmpty()) {
                TempId = templatelist[0].id;
            }
            
            if(!paymentRec.isEmpty()) {
                for(PropStrength__Received_Payment__c pay : paymentRec) {
                    Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                    List<String> toList = new List<String>{pay.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email};
                        emails.setWhatId(pay.Id);
                    
                    if(!toList.isEmpty()) {
                        emails.setToAddresses(toList); 
                    }
                    
                    emails.setTemplateId(TempId);
                    emails.setSaveAsActivity(true); 
                    emails.setTargetObjectId(pay.PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c);
                    emails.setTreatTargetObjectAsRecipient(false); 
                    if (owea.size() > 0) {
                        emails.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    emaillist.add(emails);
                }
                try{
                    if(emaillist != null && emaillist.size()>0 ) {
                        Messaging.sendEmail(emaillist);
                    }
                } catch(Exception ex){
                    system.debug('===========Exception ============'+ex.getmessage());
                    system.debug('===========Exception ============'+ex.getlinenumber());
                }
            }  
        }
    }
    
    //Added By Nishank Manwani on 29-04-2024 to raise PPD When 95% payment is made by the Customer towards installment
    public static void raisePpdAfter95Perc(List<PropStrength__Received_Payment__c> paymentlist) {
        Set<Id> bookId = new Set<Id>();
        Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id advPayRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Advance Payment').getRecordTypeId();
        
        for(PropStrength__Received_Payment__c pay : paymentlist) {
            if(pay.PropStrength__Application_Booking__c != null && (pay.RecordTypeId == payRecRT || pay.RecordTypeId == advPayRT) && pay.PropStrength__Amount_Due_Type__c == 'Installment') {
                bookId.add(pay.PropStrength__Application_Booking__c);
            }
        }
        
        if(!bookId.isEmpty()) {
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, 
                                                                                                                       PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Total_Service_Tax_due_on_Booking__c, 
                                                                                                                       (SELECT Id FROM PropStrength__Payment_Plan_Details__r 
                                                                                                                        WHERE PropStrength__Approval_Status__c != 'Approved' AND 
                                                                                                                        PropStrength__Is_Milestone_Completed__c = FALSE), 
                                                                                                                       (SELECT Id, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r 
                                                                                                                        WHERE (RecordTypeId = :payRecRT OR RecordTypeId = :advPayRT) AND 
                                                                                                                        PropStrength__Amount_Due_Type__c = 'Installment') 
                                                                                                                       FROM PropStrength__Application_Booking__c 
                                                                                                                       WHERE Id IN :bookId]);
            
            for(PropStrength__Application_Booking__c book : bookMap.values()) {
                if(!book.PropStrength__Payment_Plan_Details__r.isEmpty()) {
                    if(!book.PropStrength__Payments_Cheques__r.isEmpty()) {
                        Decimal totalPayRec = 0;
                        for(PropStrength__Received_Payment__c pay : book.PropStrength__Payments_Cheques__r) {
                            totalPayRec += pay.PropStrength__Amount__c;
                        }
                        
                        System.debug('totalPayRec****');
                        System.debug(totalPayRec);
                        
                        if(totalPayRec > 0 && book.PropStrength__Revised_Total_Sales_Consideration__c != null && book.PropStrength__Total_Service_Tax_due_on_Booking__c != null) {
                            Decimal totalPaidPerc = totalPayRec / (book.PropStrength__Revised_Total_Sales_Consideration__c - book.PropStrength__Total_Service_Tax_due_on_Booking__c);
                            totalPaidPerc *= 100;
                            
                            System.debug('totalPaidPerc****');
                            System.debug(totalPaidPerc);
                            
                            if(totalPaidPerc >= 95) {
                                Set<Id> ppdIds = new Set<Id>();
                                
                                for(PropStrength__Payment_Plan_Details__c ppd : book.PropStrength__Payment_Plan_Details__r) {
                                    ppdIds.add(ppd.Id);
                                }
                                
                                PaymentTriggerHelper.raiseAllPpd(ppdIds);
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Added By Nishank Manwani to raise PPD asynchronously on 29-04-2024
    @Future(callOut=true)
    public static void raiseAllPpd(Set<Id> ppdId) {
        List<PropStrength__Payment_Plan_Details__c> updatePpdList = new List<PropStrength__Payment_Plan_Details__c>();
        for(Id ppd : ppdId) {
            updatePpdList.add(new PropStrength__Payment_Plan_Details__c(Id=ppd, PropStrength__Approval_Status__c = 'Approved', PropStrength__Is_Milestone_Completed__c = true));
        }
        
        update updatePpdList;
    }
    
    public static void updateIncomeChargeDue(List<PropStrength__Received_Payment__c> newList){
        String recievedRecTypeID = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        system.debug('recievedRecTypeID ++'+recievedRecTypeID);
        String dueRecTypeID = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();
        system.debug('dueRecTypeID ++'+dueRecTypeID);
        Set<Id> bookingIds = new Set<Id>();
        Set<String> amountType = new Set<String>();
        for(PropStrength__Received_Payment__c recPayment : newList){
            if(recPayment.RecordTypeId == recievedRecTypeID){
                bookingIds.add(recPayment.PropStrength__Application_Booking__c);
                amountType.add(recPayment.PropStrength__Amount_Due_Type__c);
            }
        }
        
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentList = new List<PropStrength__Received_Payment__c>([select id,PropStrength__Application_Booking__c,RecordTypeId,PropStrength__Amount_Due_Type__c,PropStrength__Balance__c from PropStrength__Received_Payment__c where PropStrength__Application_Booking__c in:bookingIds AND
                                                                                                               RecordTypeId =:dueRecTypeID AND  PropStrength__Amount_Due_Type__c IN :amountType AND  PropStrength__Balance__c > 0]);
            
            
            for(PropStrength__Received_Payment__c newPay : newList) {
                if(newPay.PropStrength__Amount_Due_Type__c!= null){
                    for(PropStrength__Received_Payment__c oldPay : paymentList ){
                        if(newPay.PropStrength__Application_Booking__c != null && newPay.PropStrength__Application_Booking__c == oldPay.PropStrength__Application_Booking__c &&  newPay.PropStrength__Amount_Due_Type__c == oldpay.PropStrength__Amount_Due_Type__c ){
                            newpay.PropStrength__Income_Charge_Due__c = oldPay.id;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    public static void uodateAuditHistory(List<PropStrength__Received_Payment__c> newRecList, Map<Id, PropStrength__Received_Payment__c> oldPayRecMap){
        Set<String> payRecids = new Set<String>();
        for(PropStrength__Received_Payment__c payRec : newRecList){
            if(oldPayRecMap != null && payRec.Audit_Approval_Status__c != null && payRec.Audit_Approval_Status__c != oldPayRecMap.get(payRec.Id).Audit_Approval_Status__c &&
               (payRec.Audit_Approval_Status__c == 'Under Approval' || payRec.Audit_Approval_Status__c == 'Approved' 
                || payRec.Audit_Approval_Status__c == 'Rejected')){               
                    payRecids.add(payRec.Id);
                }
        }
        
        if(!payRecids.isEmpty()) {
            Map<String, PropStrength__Received_Payment__c> mapOfPayRecords = new Map<String, PropStrength__Received_Payment__c>([SELECT Id,Audit_Approval_Status__c,
                                                                                                                                 Audit_History__c from 
                                                                                                                                 PropStrength__Received_Payment__c 
                                                                                                                                 WHERE Id IN : payRecids]);
            for(PropStrength__Received_Payment__c payRec : newRecList){
                if(oldPayRecMap == null && payRec.Audit_Approval_Status__c != null && (payRec.Audit_Approval_Status__c == 'Under Approval' 
                                                                                       || payRec.Audit_Approval_Status__c == 'Approved' || payRec.Audit_Approval_Status__c == 'Rejected')){
                                                                                           payRec.Audit_History__c = UserInfo.getName() + ' changed status from null to ' 
                                                                                               + payRec.Audit_Approval_Status__c + ' on ' + System.now().format();
                                                                                       }
                else if(oldPayRecMap != null && payRec.Audit_Approval_Status__c != null && (payRec.Audit_Approval_Status__c == 'Under Approval' 
                                                                                            || payRec.Audit_Approval_Status__c == 'Approved' || payRec.Audit_Approval_Status__c == 'Rejected') 
                        && mapOfPayRecords.containskey(payRec.Id)){
                            SYstem.debug(mapOfPayRecords.get(payRec.Id).Audit_History__c+ ' **---**----**'+payRec.Audit_Approval_Status__c);
                            payRec.Audit_History__c = (mapOfPayRecords.get(payRec.Id).Audit_History__c != null ? mapOfPayRecords.get(payRec.Id).Audit_History__c : '') + ' \n ' + UserInfo.getName() + ' changed status from '+
                                mapOfPayRecords.get(payRec.Id).Audit_Approval_Status__c + ' to ' + payRec.Audit_Approval_Status__c + ' on ' + System.now().format();
                            SYstem.debug(payRec.Audit_History__c+ ' **---**----**'+payRec.Audit_Approval_Status__c);
                        }
            }
        }
    }
    /*public static void createLedger(List<PropStrength__Received_Payment__c> newRecList, Map<Id, PropStrength__Received_Payment__c> oldPayRecMap){
Set<Id> bookingIds = new Set<Id>();
String recType = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Due').getRecordTypeId();


for (PropStrength__Received_Payment__c pay1 : newRecList){
if(pay1.RecordTypeId == recType && pay1.PropStrength__Amount_Due_Type__c != null && pay1.PropStrength__Amount_Due_Type__c =='DLD Fees' &&  pay1.PropStrength__Balance__c != null && pay1.PropStrength__Balance__c == 0        ){
if(pay1.PropStrength__Prorated_Payment_Received__c != oldPayRecMap.get(pay1.Id).PropStrength__Prorated_Payment_Received__c || pay1.PropStrength__Waiver_Amount__c != oldPayRecMap.get(pay1.Id).PropStrength__Waiver_Amount__c)
bookingIds.add(pay1.PropStrength__Application_Booking__c);                
}
}

if(!bookingIds.isEmpty()) {
Map<Id, PropStrength__Application_Booking__c> bookBPMMap = new Map<Id, PropStrength__Application_Booking__c>([SELECT Id, PropStrength__Status__c, DLD_Fees_Due__c,X10_Payment_Received_Date__c,X20_Payment_Received_Date__c,  
DLD_Fees_Received__c, Booking_Form_Executed__c, PropStrength__Total_Paid_Percent__c, Oqood_Fees_Received__c, SPA_Executed__c, X9_5_Payment_Received_Date__c,
SPA_Execution_Date__c, PropStrength__Broker_Account__c, PropStrength__Project__r.RERA_Registered__c,Total_Payment_Receive_Percent__c,
(SELECT Id, PropStrength__Amount_Paid_By_Customer__c, PropStrength__Brokerage_Type__c, PropStrength__Is_Paid__c, PropStrength__Due_Date__c,
PropStrength__Brokerage_Due_Rs__c, PropStrength__Broker_Service_Tax__c, Booking_Form_Audit_Approved__c, DLD_Fee_Received__c, SPA_Executed__c,
Order__c, PropStrength__Active__c
FROM PropStrength__Broker_Payment_Milestones__r)
FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
List<PropStrength__Broker_Ledger__c> bpmLedgerList = new List<PropStrength__Broker_Ledger__c>();
Id bpmLedgerDueId = Schema.SObjectType.PropStrength__Broker_Ledger__c.getRecordTypeInfosByName().get('Brokerage Due').getRecordTypeId();
for(PropStrength__Application_Booking__c book : bookBPMMap.values()) {
for(PropStrength__Broker_Payment_Milestone__c bpm : book.PropStrength__Broker_Payment_Milestones__r) {
if(bpm.Booking_Form_Audit_Approved__c && bpm.DLD_Fee_Received__c && bpm.PropStrength__Amount_Paid_By_Customer__c >=9.5){

Map<String, String> checkMap = new Map<String, String>();

if(bpm.PropStrength__Amount_Paid_By_Customer__c != null) {
if(book.Total_Payment_Receive_Percent__c >= bpm.PropStrength__Amount_Paid_By_Customer__c) {
checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'true');
} else {
checkMap.put('PropStrength__Amount_check_Paid_By_Customer__c', 'false');
}
}
if(bpm.DLD_Fee_Received__c) {
if(book.DLD_Fees_Received__c >= book.DLD_Fees_Due__c) {
checkMap.put('DLD_Fee_Received__c', 'true');
} else {
checkMap.put('DLD_Fee_Received__c', 'false');
}
}
if(bpm.Booking_Form_Audit_Approved__c) {
if(book.Booking_Form_Executed__c) {
checkMap.put('Booking_Form_Audit_Approved__c', 'true');
} else {
checkMap.put('Booking_Form_Audit_Approved__c', 'false');
}
}
if(book.PropStrength__Project__r.RERA_Registered__c && bpm.SPA_Executed__c) {
if(book.SPA_Executed__c) {
checkMap.put('SPA_Executed__c', 'true');
} else {
checkMap.put('SPA_Executed__c', 'false');
}
}


if(!checkMap.isEmpty() && !checkMap.values().contains('false')) {
bpmLedgerList.add(new PropStrength__Broker_Ledger__c(PropStrength__Broker_Account__c = book.PropStrength__Broker_Account__c, PropStrength__Broker_Payment_Milestone__c= bpm.Id, PropStrength__Active__c = TRUE, PropStrength__Brokerage_Due_Rs__c = bpm.PropStrength__Brokerage_Due_Rs__c, PropStrength__Service_Tax__c = bpm.PropStrength__Broker_Service_Tax__c, RecordTypeId = bpmLedgerDueId, PropStrength__Brokerage_Type__c = 'Standard',  PropStrength__Amount_Due_Type__c = 'Against Invoice'));
}
}

}
}
if(!bpmLedgerList.isEmpty()) {
insert bpmLedgerList;
}

}
}*/
    
    public static void updateNonGlDatesOnBooking(List<PropStrength__Received_Payment__c> newRecList, Map<Id, PropStrength__Received_Payment__c> oldPayRecMap) {
        Id payRecRT = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Set<Id> bookingIds = new Set<Id>();
        
        for(PropStrength__Received_Payment__c payRec : newRecList) {
            if(payRec.PropStrength__Application_Booking__c != null && payRec.RecordTypeId == payRecRT && payRec.PropStrength__Receipt_Reversed__c != null && !payRec.PropStrength__Receipt_Reversed__c 
               && ( ( oldPayRecMap == null && payRec.Receipt_Date__c != null ) || ( oldPayRecMap != null && payRec.Receipt_Date__c != oldPayRecMap.get(payRec.Id).Receipt_Date__c ) ) ) {
                   bookingIds.add(payRec.PropStrength__Application_Booking__c);
               }
        }
        
        if(!bookingIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> updateBookingPerc = new List<PropStrength__Application_Booking__c>();
            
            Map<Id, PropStrength__Application_Booking__c> bookMap = new Map<Id, PropStrength__Application_Booking__c>(
                [SELECT Id, PropStrength__Broker_Account__r.Broker_Sub_Type__c, Sales_Head__c, PropStrength__Property__c, PropStrength__Property__r.PropStrength__Tower__c, 
                 PropStrength__Broker_Account__r.PropStrength__Broker_Type__c, PropStrength__Broker_Account__c, 
                 PropStrength__Primary_Customer__c,PropStrength__Booking_Through__c,RecordType.Name, X20_Payment_RECEIVED_Date__c,X10_Payment_Received_Date__c,
                 PropStrength__Total_Service_Tax_due_on_Booking__c, X9_5_Payment_Received_Date__c, 
                 PropStrength__Offer__r.Additional_Discount_Given__c, PropStrength__Offer__r.PropStrength__Offer_Through__c, 
                 Sales_Manager_Incentive__c, Sales_Head_Incentive__c, VP_Incentive__c, CSO_Incentive__c, Sales_Director_Incentive__c, 
                 PropStrength__Booking_Date__c, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, 
                 PropStrength__Offer__c, PropStrength__Offer__r.PropStrength__Request__c, 
                 (SELECT Id, PropStrength__Amount__c,RECEIPT_Date__c  FROM PropStrength__Payments_Cheques__r WHERE RecordTypeId = :payRecRT)
                 FROM PropStrength__Application_Booking__c WHERE Id IN :bookingIds]);
            
            for(PropStrength__Received_Payment__c payRec : newRecList) {
                if(payRec.PropStrength__Application_Booking__c != null && payRec.RecordTypeId == payRecRT && !payRec.PropStrength__Receipt_Reversed__c && !bookMap.isEmpty() && bookMap.containsKey(payRec.PropStrength__Application_Booking__c)) {
                    PropStrength__Application_Booking__c tempBooking = bookMap.get(payRec.PropStrength__Application_Booking__c);
                    Decimal totalPastPaymentGLAmt = 0.00;
                    if(!tempBooking.PropStrength__Payments_Cheques__r.isEmpty()) {
                        for(PropStrength__Received_Payment__c payRecord : tempBooking.PropStrength__Payments_Cheques__r) {
                            if(payRecord.RECEIPT_Date__c != null ){
                                if(payRecord.PropStrength__Amount__c != null){
                                    totalPastPaymentGLAmt += payRecord.PropStrength__Amount__c; 
                                    
                                }
                            }
                        }
                        if(payRec.Receipt_Date__c != null && payRec.PropStrength__Amount__c != null )
                            totalPastPaymentGLAmt += payRec.PropStrength__Amount__c;
                        if(tempBooking.PropStrength__Revised_Total_Sales_Consideration__c != null){
                            Decimal totalPercentage = (totalPastPaymentGLAmt / (tempBooking.PropStrength__Revised_Total_Sales_Consideration__c)) * 100;
                            
                            System.debug('test*-----'+totalPercentage);
                            PropStrength__Application_Booking__c newbook = new PropStrength__Application_Booking__c();
                            newbook.id = tempBooking.Id;
                            newbook.Total_Payment_Receive_Percent__c = totalPercentage;
                            if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 9.5)) {
                                if(tempBooking.X9_5_Payment_Received_Date__c == null) {
                                    newbook.Id = tempBooking.Id;
                                    newbook.X9_5_Payment_Received_Date__c = System.Today();
                                }
                            }
                            if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 10)) {
                                newbook.Id = tempBooking.Id;
                                if(tempBooking.X10_Payment_Received_Date__c == null)                                
                                    newbook.X10_Payment_Received_Date__c = System.Today();
                                if(tempBooking.X10_Payment_Received_Date__c == null)  
                                    newbook.X10_Payment_Received_Date__c = payRec.Receipt_Date__c != null ? Date.ValueOf(payRec.Receipt_Date__c) : null; 
                                
                            }
                            if(payRec.PropStrength__Amount__c != null && (totalPercentage >= 20)) {
                                newbook.Id = tempBooking.Id;
                                if(tempBooking.X20_Payment_Received_Date__c == null)                                 
                                    newbook.X20_Payment_Received_Date__c = System.Today();
                                if(tempBooking.X20_Payment_RECEIVED_Date__c == null)   
                                    newbook.X20_Payment_RECEIVED_Date__c = payRec.Receipt_Date__c != null ? Date.ValueOf(payRec.RECEIPT_Date__c) : null;   //@Deeapak Added For GL Date
                                
                            }
                            if(newBook != null && newBook.Id != null) {
                                updateBookingPerc.add(newbook);
                            }
                            
                        }
                    }
                }
            }
            if(updateBookingPerc.size() > 0){
                update updateBookingPerc;
            }
        }
    }
    
}