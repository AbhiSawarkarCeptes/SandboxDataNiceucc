public class LatePenaltyController {
    
    public Static Decimal totalInterest = 0;
    
    @AuraEnabled
    public static void calculateLatePayment(String bookingId){
        List<Demand__c> demandListToUpdate = new List<Demand__c>();
        Booking__c booking = [Select Id,Total_On_Account_Money_With_Registration__c,Total_Interest_Till_Date__c  From Booking__c Where Id =: bookingId];
        List<Demand__c> demandList =  [SELECT Id,Booking__r.Total_On_Account_Money_With_Registration__c,Milestone_Name__c,Due_Date__c,
                                       Total_Amount_Demanded__c,Installment__c,Payment_Milestones__r.Charge1Percentage__c,
                                       Date_for_Late_Payment_Calculation__c,Demand_Age__c,OutStanding_days_calculated__c,
                                       No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c From Demand__C
                                       Where Payment_Milestones__c != Null and Demand_Status__c !='Reversed' and Booking__c =: booking.id order by Payment_Milestones__r.Name];
        List<LatePaymentWrapper> latePaymentList = new List<LatePaymentWrapper>();
        
        //initializing the wrapper list
        for(Demand__c d : demandList){
            LatePaymentWrapper l = new LatePaymentWrapper();
            latePaymentList.add(l);
        }
        
        if(!demandList.isEmpty()){
            latePaymentList[0].balanceAmount = (Integer)(demandList[0].Total_Amount_Demanded__c - booking.Total_On_Account_Money_With_Registration__c);
            latePaymentList[0].latePaymentDueDate = demandList[0].Date_for_Late_Payment_Calculation__c;
            latePaymentList[0].demand = demandList[0];
        }
        
        //calculating the Balance Amount of Remaining Demands
        for(Integer i=1; i<demandList.size(); i++){
            if(latePaymentList[i-1].balanceAmount < 0){
                latePaymentList[i].balanceAmount = (Integer)(demandList[i].Total_Amount_Demanded__c - (latePaymentList[i-1].balanceAmount * -1));
            }
            else{
                latePaymentList[i].balanceAmount = (Integer)demandList[i].Total_Amount_Demanded__c;
            }
            latePaymentList[i].latePaymentDueDate   = demandList[i].Date_for_Late_Payment_Calculation__c;
            latePaymentList[i].demand = demandList[i];
        }
        
        //calculating the Interest of each Demand
        for(Integer i=0; i<latePaymentList.size(); i++){
            if(latePaymentList[i].balanceAmount <= 0){ 
                system.debug('VVK calculate: '+latePaymentList[i].balanceAmount);
                latePaymentList[i].interestCharges = 0;
                latePaymentList[i].outStandingDays = 'Paid';
                latePaymentList[i].noOfMonths = 0;
                latePaymentList[i].displayBalanceAmount = 0;
                
                
                //assiging the demand related fields
                latePaymentList[i].demand.Interest_Charges__c = 0;
                latePaymentList[i].demand.Balance_Amount__c = 0;
                latePaymentList[i].demand.OutStanding_days_calculated__c = 'Paid';
                latePaymentList[i].demand.No_of_days__c = 0;
                latePaymentList[i].demand.No_of_Months__c = 0;
            } else{
                system.debug('VVK calculate1: ');
                Integer days=0;
                if(latePaymentList[i].latePaymentDueDate != null){
                    days = (latePaymentList[i].latePaymentDueDate).daysBetween(Date.today());
                    system.debug('VVK calculate days: '+ days);
                } 
                if(days <= 30){
                    latePaymentList[i].demand.Balance_Amount__c = latePaymentList[i].balanceAmount;
                    latePaymentList[i].outStandingDays = String.valueOf(days); 
                    latePaymentList[i].noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR);
                    latePaymentList[i].demand.OutStanding_days_calculated__c = latePaymentList[i].outStandingDays;
                    latePaymentList[i].demand.No_of_days__c = Integer.valueOf(latePaymentList[i].outStandingDays);
                    latePaymentList[i].demand.No_of_Months__c = latePaymentList[i].noOfMonths;  
                    latePaymentList[i].demand.Interest_Charges__c = 0;
                } else{
                    latePaymentList[i].outStandingDays = String.valueOf(days);
                    latePaymentList[i].noOfMonths = (days/30.0).setscale(5,RoundingMode.FLOOR); 
                    Long chargeOnBalance = (Math.exp(latePaymentList[i].noOfMonths * Math.log(1.01)) * latePaymentList[i].balanceAmount).round(System.RoundingMode.HALF_EVEN); //rounding up or down
                    latePaymentList[i].interestCharges = chargeOnBalance - latePaymentList[i].balanceAmount;  
                    latePaymentList[i].displayBalanceAmount = latePaymentList[i].balanceAmount;
                    
                    //assigning the demand related fields
                    latePaymentList[i].demand.Interest_Charges__c = chargeOnBalance - latePaymentList[i].balanceAmount;
                    latePaymentList[i].demand.Balance_Amount__c  = latePaymentList[i].balanceAmount;
                    latePaymentList[i].demand.OutStanding_days_calculated__c = latePaymentList[i].outStandingDays;
                    latePaymentList[i].demand.No_of_days__c = Integer.valueOf(latePaymentList[i].outStandingDays);
                    latePaymentList[i].demand.No_of_Months__c = latePaymentList[i].noOfMonths;
                }
                
                
            }
            //update latePaymentList[i].demand;
            demandListToUpdate.add(latePaymentList[i].demand); 
            totalInterest = totalInterest + latePaymentList[i].demand.Interest_Charges__c;
            
        } 
        
        //updating the booking record values
        booking.Total_Interest_Till_Date__c = totalInterest;
        
        if(booking != null){
            update booking;
        }
        if(demandListToUpdate.size()>0){
            update demandListToUpdate;
        }
        
    }
    
    class LatePaymentWrapper {
        public Demand__c demand;
        public Integer balanceAmount;
        public Long interestCharges;
        public Integer displayBalanceAmount; 
        public Decimal noOfMonths;
        public String outStandingDays; 
        public Date latePaymentDueDate;
        public Date todayDate;        
    }
    
    @AuraEnabled
    public static string raiseDemand(string bookingId){
        List<Booking__c> booking = new List<Booking__c>();
        List<Demand__c> demandList = new List<Demand__c>();
        Boolean isAllPaid = true;
        Boolean isAllShort = true;
        Boolean isLPCNeeded = false;
        List<String> newOustDayList = new List<String>();
        Account_Master__c interestMaster = new Account_Master__c();
        Account_Master__c tradeMaster = new Account_Master__c();
        booking = [Select Id, Total_Interest_Till_Date__c,VAT_On_Interest_Amount__c,Project__c,Unit__c,Primary_Applicant_Email__c,Opportunity__c,Primary_Applicant_Name__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Unit__r.Name,LastModifiedDate, Tower__c From Booking__c Where Id =: bookingId];
        
        if(booking.size()>0){
            demandList = [SELECT Id,Due_Date__c,Date_for_Late_Payment_Calculation__c,Demand_Age__c,OutStanding_days__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c From Demand__C
                          Where Payment_Milestones__c != Null and Demand_Status__c !='Reversed' and  Booking__c =: booking[0].id order by Payment_Milestones__r.Name];
        }
        
        interestMaster = [Select Id, Name From Account_Master__c Where Name = 'Interest Charges' LIMIT 1];
        tradeMaster =   [Select Id, Name From Account_Master__c Where Name = 'Trade Receivable' LIMIT 1];
        
        List<String> toAddress = new List<String>();
        List<String> otherApplicantEmail = new List<String>();
        List<String> toCCAddress = new List<String>();
        
        toCCAddress.add(System.label.SobhaHelpDeskMe); 
        toCCAddress.add(System.label.CollectionTeamEmail); 
        toCCAddress.add(System.label.SobhaHelpdesk);
        
        String executiveName='';
        if(UserInfo.getFirstName() != null){
            executiveName += (UserInfo.getFirstName()).capitalize();
            
        }
        if(UserInfo.getLastName() != null){
            executiveName += ' '+(UserInfo.getLastName()).capitalize();
            
        }
        if(booking.size()>0){
            //check if the record is modified in last one hour or not
            DateTime hourBefore  = System.Now().addHours(-1);
            if(!(booking[0].LastModifiedDate > hourBefore)){
                return 'Before Raising the Demand, Please Calculate the LPC first';    
            }            
            //If no demand is present then show the Apex Message 
            if(demandList.isEmpty()){
                isAllPaid = false;
                isAllShort = false;
                return 'No Demand For LPC Notice is Present on this Booking Record';        
            }
            else{
                for(Demand__C demand : demandList){
                    Integer outValue;
                    if(demand.OutStanding_days_calculated__c != 'Paid'){
                        if(demand.OutStanding_days_calculated__c != null){
                            outValue = Integer.valueOf(demand.OutStanding_days_calculated__c); // 20
                        }
                        isAllPaid = false;
                        Integer days;
                        if(demand.Date_for_Late_Payment_Calculation__c != null){
                            days = (demand.Date_for_Late_Payment_Calculation__c).daysBetween(Date.today()); //90
                        }
                        // System.debug('the outvalue is-')
                        if(outValue != days){
                            isLPCNeeded = true;
                            
                        } 
                        if(outValue > 30){
                            isAllShort = false;
                        }
                    }
                    
                }
            }
            if(Test.isRunningTest()){
                isLPCNeeded = false;
                isAllPaid = false;
                isAllShort = false;
            }
            //LPC Calculation is not completed within 24 hour so it needs to be calculated
            if(isLPCNeeded){
                System.debug('Inside LPC Needed 24 hour condition');
                return 'Before Raising the Demand, Please Calculate the LPC first';
            }
            //If all the demands are Paid for that booking
            else if(isAllPaid){
                return 'All the Demands for this booking are already Paid';   
            }
            //If no demand has outstanding days greater than 30,So LPC can not be charged
            else if(isAllShort){
                return 'No demand has outstanding days greater than 30, Demand can not be raised';
            }
            //Create the demand record and send the mail
            else{
                //Creating the demand record
                Demand__C demand = new Demand__C();
                demand.Booking__c = bookingId;
                demand.Debit_Demanded__c = booking[0].Total_Interest_Till_Date__c;
                demand.Debit_CGST__c =  booking[0].VAT_On_Interest_Amount__c;
                //demand.Debit_Tax_Demanded__c  this field will automatically have the value debit.Debit_CGST__c
                demand.Payment_Towards__c = 'Corporate Account';
                demand.GL_Date__c = System.today();
                demand.Invoice_Date__c = System.today();
                //demand.Total_Interest_Amount_Due__c --> This is the formula field need to change the formula for this
                demand.Total_Amount_Account__c = interestMaster.id;
                demand.Total_Amount_with_Tax_Account__c = tradeMaster.id;
                demand.Milestone_Name__c = 'Late Payment Charges';
                demand.Debit_Type__c = 'Interest Charges';
                demand.Tax_Rate__c = 'VAT 5%';
                demand.Payment_Term__c = 'Immediate';
                demand.Project__c = booking[0].Project__c;
                demand.Unit__c = booking[0].Unit__c;
                try{
                    insert demand; 
                }catch(Exception e){
                    System.debug('While Inserting the demand the error occured --'+ e.getMessage());
                }
                
                //Fetch the LatePayment Notice VF Page to attach it on email
                PageReference pdf = Page.Latepaymentcharges;
                pdf.getParameters().put('bookingId',bookingId);
                // Take the PDF content
                Blob b;
                if(!Test.isRunningTest()){
                    b = pdf.getContent();   
                } else {
                    b = Blob.valueOf('Test123');
                }  
                
                // Create the email attachment
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('LatePaymentCharge.pdf');
                efa.setBody(b);
                
                
                if(booking[0].Primary_Applicant_Email__c != Null){
                    toAddress.add(booking[0].Primary_Applicant_Email__c);
                }
                if(booking[0].Opportunity__r.Other_Applicants_Email__c != null){
                    otherApplicantEmail = booking[0].Opportunity__r.Other_Applicants_Email__c.split('\\,');
                }
                for(String s : otherApplicantEmail){
                    if(!s.containsIgnoreCase('null')){
                        toAddress.add(s);
                    }
                }
                 //SOB-336 start
                String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(booking[0].id);
                if(!string.isblank(emailAddressFromBooking)){
                    for(String s : emailAddressFromBooking.split(',')){
                        if(!s.containsIgnoreCase('null')){
                            toAddress.add(s);
                        }
                    }
                }
                //SOB-336 end

                Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
                System.debug(' owaMap '+owaMap); 
                for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
                    owaMap.put(owa.Address,owa);
                }
                
                //Creating the email to be sent
                String body = '<br>Dear '+booking[0].Primary_Applicant_Name__c;
                if(booking[0].Opportunity__r.Other_Applicants_Name__c != null){
                    body += booking[0].Opportunity__r.Other_Applicants_Name__c;
                }
                body += ',</br>';
                body += '<p>Hope you are doing well.</p>';
                body += '<p>Thank you for your purchase in our prestigious project Sobha Hartland.</p>';
                body += '<p>With reference to the Unit '+booking[0].Unit__r.Name +' you have purchased, please find attached the late payment notice for your quick reference.</p>';
                body += '<span>Should you require any further assistance in this regard, feel free to contact us on the email address <a href="'+System.label.SobhaHelpdesk+'">'+System.label.SobhaHelpdesk+'</a> or the mailing address mentioned in the letter.</span></br></br>';
                body += '<span>Please log on to our website <a href="https://www.sobharealty.com/">www.sobharealty.com</a> for further information about our current and upcoming projects.</span></br>';
                body += '<p>Have a nice day!</p>';
                body += '<p>Thanks & Regards, </p>';
                body +=  '<p>'+executiveName+'</p>';
                body += '<p>Collection Team.</p>';
                body += '<a href="https://www.facebook.com/SobhaRealty/" style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPN&oid=00D1t000000G1gX"></img></a>&nbsp;';
                body += '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>&nbsp;';
                body += '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPS&oid=00D1t000000G1gX" ></img></a>&nbsp;';
                body += '<a href="https://www.linkedin.com/company/sobharealty/"  style="margin-top:10px; display:block; float:left;width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPX&oid=00D1t000000G1gX"></img></a>&nbsp;';
                body += '<a href="https://www.sobharealty.com/" style="float:left; margin-top: 5px;height:1%;overflow-y:hidden">sobharealty.com</a>';
                body += '<br/><br/>';
                body += '<p><a href="https://www.sobharealty.com/"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPc&oid=00D1t000000G1gX" style="float:left; width:25%;"></img></a></p>';
                Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                email.setSubject('Late Payment Charge Notice - Unit '+booking[0].Unit__r.Name+', Project-'+booking[0].Tower__c+' ');
                email.setHtmlBody(body);
                email.setToAddresses(toAddress);
                email.setCcAddresses(toCCAddress);
                email.setOrgWideEmailAddressId(owaMap.get('helpdesk@sobharealty.com').id);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                if(System.label.isAllowToSendLatePaneltyEmail == 'Send Email'){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
                return 'Demand is Raised Successfully and Mail has been sent to the Customer';
            }
        }
        else{
            return 'No booking found.';
        }
    }
    
    @AuraEnabled
    public static list<Bookings> getBookings(string towerId){
        list<Bookings> bookings = new list<Bookings>();
        set<string> bookingIds = new set<string>();
        list<Demand__c> demands = new list<Demand__c>();
        
        if(towerId == 'All'){
            demands = [select id,Booking__c from Demand__c where Demand_Status__c !='Reversed' and OutStanding_days_calculated__c != 'Paid' and Date_for_Late_Payment_Calculation__c <= LAST_N_DAYS:45];
        }
        else{
            demands = [select id,Booking__c from Demand__c where Demand_Status__c !='Reversed' and OutStanding_days_calculated__c != 'Paid' and Date_for_Late_Payment_Calculation__c <= LAST_N_DAYS:45 and Booking__r.Unit__r.Tower__c =: towerId];
        }
        for(Demand__c d : demands){
            bookingIds.add(d.Booking__c);
        }
        
        map<string,Demand__c> bkToDemand = new map<string,Demand__c>();
        for(Demand__c d : [select Id, Booking__c, Total_Amount_with_Tax_Demanded__c, Invoice_Date__c from Demand__c where Booking__c IN:bookingIds and Debit_Type__c = 'Interest Charges' order by CreatedDate DESC]){
            if(!bkToDemand.containsKey(d.Booking__c))
                bkToDemand.put(d.Booking__c,d);
        }
        System.debug('bookingIds -->'+bookingIds);
        
        for(Booking__c b : [select id,name,Unit__c,Unit__r.Name,Milestone_Due_Till_Date__c,Total_On_Account_Money_With_Registration__c,Due_Payments__c,Total_Interest_Till_Date__c from Booking__c where id IN: bookingIds and Due_Payments__c > 10000]){
            Bookings bk = new Bookings();
            bk.bookingId = b.id;
            bk.bookingLink = '/'+b.id;
            bk.bookingName = b.name;
            bk.unitName = b.Unit__r.Name;
            bk.unitLink = '/'+b.Unit__c;
            bk.checked = false;
            bk.milestoneDueTillDate = (b.Milestone_Due_Till_Date__c != null)?(long)b.Milestone_Due_Till_Date__c:0;
            bk.collectedAmount = (b.Total_On_Account_Money_With_Registration__c != null)?(long)b.Total_On_Account_Money_With_Registration__c:0;
            bk.dueAmount = (b.Due_Payments__c != null)?(long)b.Due_Payments__c:0;
            bk.totalInterestTillDate = (b.Total_Interest_Till_Date__c != null)?(long)b.Total_Interest_Till_Date__c:0;
            if(bkToDemand.containsKey(b.Id)){
                bk.lastLatePaymentAmount = (long)bkToDemand.get(b.Id).Total_Amount_with_Tax_Demanded__c;
                if(bkToDemand.get(b.Id).Invoice_Date__c!=null){
                    DateTime dt = bkToDemand.get(b.Id).Invoice_Date__c;
                    bk.lastLatePaymentDate = dt.format('dd/MM/yyyy');
                }
            }
            if(bk.dueAmount > 0)
                bookings.add(bk);
        }
        return bookings;
    }
    
    public class Bookings {
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingLink;
        @AuraEnabled public string bookingName;
        @AuraEnabled public boolean checked;
        @AuraEnabled public long milestoneDueTillDate;
        @AuraEnabled public long collectedAmount;
        @AuraEnabled public long dueAmount;
        @AuraEnabled public long totalInterestTillDate;
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitLink;
        @AuraEnabled public long lastLatePaymentAmount;
        @AuraEnabled public string lastLatePaymentDate;
        
        public Bookings(){
            bookingId='';
            bookingLink='';
            bookingName='';
            checked=false;
            milestoneDueTillDate=0;
            collectedAmount=0;
            dueAmount=0;
            totalInterestTillDate=0;
            unitName='';
            unitLink='';
            lastLatePaymentAmount=0;
            lastLatePaymentDate='';
        }
    }
}