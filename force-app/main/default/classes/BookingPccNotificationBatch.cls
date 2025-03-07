global class BookingPccNotificationBatch implements Database.Batchable<sObject>,Schedulable  {
    
    global void execute(SchedulableContext sc) {
        BookingPccNotificationBatch b = new BookingPccNotificationBatch();
        database.executebatch(b,20);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select id,Name,Title_Transfer_Completed__c,Unit__r.Name,ownerId,Paid_Percentage__c,PCC_Status__c,(Select Id,Status__c,createdDate FROM Mortgages__r Order by CreatedDate DESC limit 1) FROM Booking__c WHERE Title_Transfer_Completed__c != \'Completed\' AND Paid_Percentage__c >= 100 AND PCC_Status__c = null ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<booking__c> records){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Booking_PCC_notification'];
        Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
        Map<Id, Decimal> totalUnitAmountOnBooking = new Map<Id, Decimal>();
        Map<Id, Decimal> totalDemandedAmountOnBooking = new Map<Id, Decimal>();
        for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
            owaMap.put(owa.Address,owa);
        }
        set<id> bookingIdSet = new set<id>();
        for(booking__c b : records){
            boolean sendEmail = false;
            if(b.Mortgages__r != null && b.Mortgages__r.size()>0){
                if(b.Mortgages__r[0].Status__c != 'Rejected by Collection Head' && b.Mortgages__r[0].Status__c != 'Rejected by Accounts' && b.Mortgages__r[0].Status__c != 'Approved by Audit' && b.Mortgages__r[0].Status__c != 'Rejected by Audit & Submitted to Accounts' && b.Mortgages__r[0].Status__c != 'Rejected by Audit & Submitted to Collection & Accounts' && b.Mortgages__r[0].Status__c != 'Rejected by Audit' ){
                    bookingIdSet.add(b.Id);
                }
            }
            else{
                bookingIdSet.add(b.Id);
            }
        }
        for (Receipt__c receipt : [ SELECT Id,Name,Other_Charges_Type__c,Amount_Rs__c,Mode__c,Description__c,Receipt_Date__c,Demand__c,Total_Amount__c,LP_Waiver__c,LP_Waiver__r.Demand__c,Booking__c,
            Registration_Collection_Control_Report__c,CreatedDate,Towards_Other_Charges_Amount__c,RemarksText__c,Credit_Card_Charges__c,LP_Waiver__r.Demand__r.Milestone_Name__c    
            FROM Receipt__c  WHERE Receipt_Status__c = 'Cleared' AND Is_Reversed_Receipt__c = false AND Booking__c IN:bookingIdSet ]) {

            String rd = receipt.Description__c != null ? receipt.Description__c.toLowercase() : '';

            if(rd.containsIgnoreCase('late payment') || rd.containsIgnoreCase('late payment waiver') || rd.containsIgnoreCase('lp waiver') || rd.containsIgnoreCase('lpw') || rd.containsIgnoreCase('interest waiver') || 
            (receipt.LP_Waiver__c != null && receipt.LP_Waiver__r.Demand__c != null && receipt.LP_Waiver__r.Demand__r.Milestone_Name__c.containsIgnoreCase('late payment')) ){
                if(totalUnitAmountOnBooking.containsKey(receipt.Booking__c)){
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + (receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c)));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + receipt.Amount_Rs__c));
                    }
                }else{
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,receipt.Amount_Rs__c);
                    }
                    
                }
            }else if(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver') || (receipt.LP_Waiver__c != null && receipt.LP_Waiver__r.Demand__c != null && receipt.LP_Waiver__r.Demand__r.Milestone_Name__c.containsIgnoreCase('cheque dishonored')) ){
                if(totalUnitAmountOnBooking.containsKey(receipt.Booking__c)){
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + (receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c)));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + receipt.Amount_Rs__c));
                    }
                }else{
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,receipt.Amount_Rs__c);
                    }
                    
                }
            }
            else if(((receipt.Credit_Card_Charges__c == 0 ||  receipt.Credit_Card_Charges__c == null) && receipt.Other_Charges_Type__c == null) || receipt.Other_Charges_Type__c == 'Cheque Dishonoured Charges' ){ // && !(rd.contains('late payment') || rd.contains('late payment waiver') || rd.contains('lp waiver') || rd.contains('lpw') || rd.contains('interest waiver')) && (receipt.LP_Waiver__c == null)
                if(totalUnitAmountOnBooking.containsKey(receipt.Booking__c)){
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + (receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c)));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(totalUnitAmountOnBooking.get(receipt.Booking__c) + receipt.Amount_Rs__c));
                    }
                }else{
                    if(receipt.Registration_Collection_Control_Report__c > 0){
                        totalUnitAmountOnBooking.put(receipt.Booking__c,(receipt.Amount_Rs__c - receipt.Registration_Collection_Control_Report__c));
                    }else{
                        totalUnitAmountOnBooking.put(receipt.Booking__c,receipt.Amount_Rs__c);
                    }
                    
                }
            }
        }
        for (Demand__c demand : [ SELECT Id,Name,Booking__r.Total_On_Account_Money_With_Registration__c,GL_Date__c,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c,Total_Amount_with_Tax_Demanded__c,
            Installment__c,Payment_Milestones__r.Charge1Percentage__c,Booking__r.Booking_Date__c,Date_for_Late_Payment_Calculation__c,Last_LP_Raised_Date__c,Debit_Type__c,
            Booking__r.VAT_On_Interest_Amount__c,Number_of_Late_Payment_Raised__c,Previous_LP_Amount__c,Previous_LP_Name__c,
            Demand_Age__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c  FROM Demand__c WHERE Demand_Status__c !='Reversed' AND Booking__c IN:bookingIdSet
            ORDER BY Date_for_Late_Payment_Calculation__c ASC ]) {

            String Milestone_Name = demand.Milestone_Name__c != null ? demand.Milestone_Name__c.toLowercase() : '';

            if(Milestone_Name.contains('late payment') && !Milestone_Name.contains('debit') && !Milestone_Name.contains('credit')){
                if(totalDemandedAmountOnBooking.containsKey(demand.Booking__c)){
                    totalDemandedAmountOnBooking.put(demand.Booking__c,(totalDemandedAmountOnBooking.get(demand.Booking__c) + demand.Total_Amount_with_Tax_Demanded__c));
                }else{
                    totalDemandedAmountOnBooking.put(demand.Booking__c,demand.Total_Amount_with_Tax_Demanded__c);
                }
            }else if(Milestone_Name.contains('cheque dishonored') && demand.Debit_Type__c != 'Cancellation'){
                if(totalDemandedAmountOnBooking.containsKey(demand.Booking__c)){
                    totalDemandedAmountOnBooking.put(demand.Booking__c,(totalDemandedAmountOnBooking.get(demand.Booking__c) + demand.Total_Amount_with_Tax_Demanded__c));
                }else{
                    totalDemandedAmountOnBooking.put(demand.Booking__c,demand.Total_Amount_with_Tax_Demanded__c);
                }
            }else if(demand.Payment_Milestones__c != null){
                if(totalDemandedAmountOnBooking.containsKey(demand.Booking__c)){
                    totalDemandedAmountOnBooking.put(demand.Booking__c,(totalDemandedAmountOnBooking.get(demand.Booking__c) + demand.Total_Amount_with_Tax_Demanded__c));
                }else{
                    totalDemandedAmountOnBooking.put(demand.Booking__c,demand.Total_Amount_with_Tax_Demanded__c);
                }
            }
            
        }

        for(booking__c b : records){
            if(bookingIdSet.contains(b.id) != null && totalUnitAmountOnBooking.containsKey(b.Id) != null && totalDemandedAmountOnBooking.get(b.Id) != null){
                System.debug('Booking Number -> '+b.Name+' Total Customer Paid '+totalUnitAmountOnBooking.get(b.id)+'- '+totalDemandedAmountOnBooking.get(b.Id)+' Total Demanded Amount ');
            }

            if(bookingIdSet.contains(b.id) != null && totalUnitAmountOnBooking.containsKey(b.Id) != null && totalDemandedAmountOnBooking.get(b.Id) != null && ((totalDemandedAmountOnBooking.get(b.Id) - totalUnitAmountOnBooking.get(b.id))<100)){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                string toAdds = System.Label.BookingPccNotificationToAddress;
                string[] to = toAdds.split(',');
                message.setToAddresses(to);
                message.setTemplateId(emailTemplate.Id);
                message.setSubject('PCC for #Booking: '+b.Name+' can be initiated by CollectionsOps');
                string htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('{b.Name}', b.name);
                htmlBody = htmlBody.replace('{b.Unit__r.Name}', (b.Unit__c != null ? b.Unit__r.Name : ''));
                System.debug(htmlBody);
                message.setHtmlBody(htmlBody);
                message.setOrgWideEmailAddressId(owaMap.get('sfnotifications@sobharealty.com').id);
                emails.add(message);
            }
        }
        if(emails.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        }
        
    }    
    global void finish(Database.BatchableContext bc){

    }    
}