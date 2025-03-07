public class DueDemandsController {
    //public static Booking__c bookingDatapdf {get;set;}
    public static decimal amountToBePaid {get;set;}
    
    @AuraEnabled
    public static List<Booking__c> getDueDemands(){        
        List<Demand__c> demandData = new List<Demand__c>();
        demandData = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c
                      FROM Demand__c 
                      WHERE OutStanding_days_calculated__c != 'paid' and Ageing__c >=30];
        set<Id> bookingIdset = new set<Id>();
        for(Demand__c demandloop : demandData){
            bookingIdset.add(demandloop.Booking__c);
        }
        List<Booking__c> bookingData = new List<Booking__c>();
        bookingData = [SELECT id,Name,Milestone_Due_Till_Date__c, Total_On_Account_Money_With_Registration__c 
                       FROM Booking__c
                       WHERE ID IN:bookingIdSet AND Remainder_Notice__c = FALSE];
        List<Booking__c> bookingfinalList = new List<Booking__c>();
        for(Booking__c bookingloopvalue : bookingData){
            if(bookingloopvalue.Milestone_Due_Till_Date__c > bookingloopvalue.Total_On_Account_Money_With_Registration__c){
                bookingfinalList.add(bookingloopvalue);
            }
        }
        return bookingfinalList;
    }
    
    @AuraEnabled
    public static void demandActions(String type,List<String> demandId){
        
       /* List<Booking__c> bookingDataList = [SELECT ID,Primary_Applicant_Name__c,unit__r.Name,Booking_Date__c,Primary_Applicant_Address__c,
                          Name,Milestone_Due_Till_Date__c, Total_On_Account_Money_With_Registration__c,Project_Name__c,
                          OwnerId,Due_Payments__c,remainder_notice__c,Reminder_Sent_Date__c,Last_Reminder_Notice_Amount__c        
                            FROM Booking__c
                            WHERE ID IN:bookingId];*/
        List<Demand__c> demandDataList = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,
                                      Booking__r.Milestone_Due_Till_Date__c,Agreement_Value_Balance__c,
                          			  booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                          			  booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,
                                      Last_Reminder_Notice_Amount_1__c,Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,
                                      Reminder_Notice2__c,Reminder_Sent_Date_2__c,booking__r.name,Reminder_Sent_Date1__c,
                                      Total_Amount_Demanded__c,booking__r.opportunity__r.Other_Applicants_Name__c
                      	              FROM Demand__c 
                                      WHERE ID IN:demandId
                                     ];
       
        List<Demand__c> demandList = new List<Demand__c>();
        List<Task__c> taskList = new List<Task__c>();
        for(demand__c demanddata : demandDataList){
        system.debug('demanddata'+demanddata.id);
        if(demanddata.id !=null){
            if(type == '15days'){
                demanddata.Reminder_Notice1__c = True;
            	demanddata.Reminder_Sent_Date1__c= System.today();
            	demanddata.Last_Reminder_Notice_Amount_1__c = demanddata.Total_Amount_Demanded__c;
             	system.debug('bookingdataremainder'+demanddata.Reminder_Notice1__c);
            	demandList.add(demanddata);
            }else{
                demanddata.Reminder_Notice2__c = True;
            	demanddata.Reminder_Sent_Date_2__c= System.today();
            	demanddata.Last_Reminder_Notice_Amount2__c = demanddata.Total_Amount_Demanded__c;
             	system.debug('bookingdataremainder'+demanddata.Reminder_Notice2__c);
            	demandList.add(demanddata);
            }
        	
        }
        Task__c createTask = new Task__c();
        createTask.Manual_Dial__c = false;
        createTask.Category__c = 'Unable to Pay';
        createTask.Booking_Unit__c = demanddata.booking__r.Unit__c;
        createTask.Booking__c = demanddata.booking__r.id;
        createTask.Remainder_Sent_Date__c = System.TODAY();
        createTask.demand__c = demanddata.id;
        taskList.add(createTask);       
        }
        update demandList;
        insert taskList;
    }
    
    @AuraEnabled
    public static void sendEmail(String type,List<String> demandId){
        List<Messaging.SingleEmailMessage> masterListMails =  new List<Messaging.SingleEmailMessage>();
        
        String dueAmountText = '';
        Integer dueAmountInt = 0;
        String applicantNames = '';
        Decimal totalAmountDemanded = 0;
        Decimal TotalonAccountmoney = 0;
        String otherEmails = '';
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        System.debug(todaysDateStr);
        Datetime condieredDate = System.today().addDays((-1)*15);
        /* List<Booking__c> bookingDatapdfList = [SELECT ID,Primary_Applicant_Name__c,unit__r.Name,Booking_Date__c,Primary_Applicant_Address__c,
                                        Name,Milestone_Due_Till_Date__c, Total_On_Account_Money_With_Registration__c,Project_Name__c,OwnerId,
                                        Purchase_Price_Only__c,opportunity__r.Other_Applicants_Email__c,Opportunity__r.Other_Applicants_Name__c,
                                        Opportunity__r.Primary_Name__c,Opportunity__r.Primary_Email__c,Project__r.Name,SPA_Executed_Date__c
                                        FROM Booking__c
                                        WHERE Id IN: bookingId];*/
            List<Demand__c> demandDataList = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,
                                        Booking__r.Milestone_Due_Till_Date__c,Agreement_Value_Balance__c,
                                        booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                                        booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,
                                        Last_Reminder_Notice_Amount_1__c,Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,
                                        Reminder_Notice2__c,Reminder_Sent_Date_2__c,booking__r.name,Reminder_Sent_Date1__c,
                                        Total_Amount_Demanded__c,booking__r.Opportunity__r.Primary_Email__c,
                                        booking__r.SPA_Executed_Date__c,booking__r.opportunity__r.Other_Applicants_Email__c,
                                        booking__r.Opportunity__r.Other_Applicants_Name__c,booking__r.Primary_Applicant_Name__c,
                                        booking__r.Purchase_Price_Only__c,booking__r.Opportunity__r.Primary_Name__c,Due_Date__c,
                                        Project__r.Name,Installment__c,Payment_Milestones__r.Milestone_Name__c,
                                        Unit__r.legal_entity__r.Favouring__c,
                                        Unit__r.legal_entity__r.Account_Number_Flat_Cost__c,
                                        Unit__r.legal_entity__r.IBAN__c,
                                        Unit__r.legal_entity__r.MICR_Code_Flat_Cost__c,
                                        Unit__r.legal_entity__r.Bank_Name_Flat_Cost__c
                                        FROM Demand__c 
                                        WHERE ID IN:demandId	
                                        ];

        for(Demand__c demandDatapdf : demandDataList){
            
        List <String> lststringtoaddress = new List<String>();
        List <String> lstStringccaddress = new List <String>();
        List <String> lstStringbccaddress = new List <String>();
            
        otherEmails = demandDatapdf.booking__r.opportunity__r.Other_Applicants_Email__c;
        List<String> emailList = new List<String>(); 
        if(otherEmails != null && otherEmails != ''){
            emailList = otherEmails.split(',');
        }
        List<string> otherEmailsList = new List<String>();
        if(emailList.size()>0){
        for(String s : emailList){
            if(s.contains('@')){
                otherEmailsList.add(s);
                lststringtoaddress.add(s);
                
            }
        }
        }
        if(demandDatapdf.Total_Amount_Demanded__c != null){
            totalAmountDemanded = demandDatapdf.Total_Amount_Demanded__c;
            dueAmountInt = Integer.valueOf(totalAmountDemanded);
            dueAmountText = NumberToText.convert(dueAmountInt);
        }
        amountToBePaid = totalAmountDemanded;
        List<String> args = new String[]{'0','number','###,###,###,###'};
        String amount = String.format(amountToBePaid.format(), args);
        System.debug(amount);
        
            Boolean negative = false;
        if(amountToBePaid < 0) {
            negative = true;
        }
        String m1 = String.valueOf(math.abs(amountToBePaid.setscale(0, RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i, i+1);        
            if(i==2 || i==5 || i==8 || i==11 || i==14) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }   
        if(!negative)
            mf =  mf;
        else
            mf = '- ' + mf;

        String fileName;
        
        //User usr = [SELECT Id, Email,Name FROM User WHERE Id = :bookingDatapdf.ownerId]; 
        if(demandDatapdf.booking__r.Opportunity__r.Primary_Email__c != null && demandDatapdf.booking__r.Opportunity__r.Primary_Email__c!= ''){
            lststringtoaddress.add(demandDatapdf.booking__r.Opportunity__r.Primary_Email__c);
            
        }
        if(demandDatapdf.booking__r.Opportunity__r.Primary_Name__c != null && demandDatapdf.booking__r.Opportunity__r.Primary_Name__c!= ''){
                applicantNames = demandDatapdf.booking__r.opportunity__r.Primary_Name__c;
        }
        if(demandDatapdf.booking__r.opportunity__r.Other_Applicants_Name__c != null && demandDatapdf.booking__r.opportunity__r.Other_Applicants_Name__c!= ''){
                applicantNames = applicantNames + ' , ' +demandDatapdf.booking__r.opportunity__r.Other_Applicants_Name__c;
        }
        String UserEmail = UserInfo.getUserEmail();
        System.debug('i am current user '+UserInfo.getUserEmail());
        lstStringccaddress.add(System.label.CollectionTeamEmail);
        if(UserEmail !=null && UserEmail != ''){
            lstStringccaddress.add(UserEmail);
        }
        PageReference pref = new PageReference('/apex/DueDemand');
        pref.getParameters().put('id', demandDatapdf.Id);
        Blob b;
        if(!Test.isRunningTest()){
            b = pref.getContent();   
        } else {
            b = Blob.valueOf('Test123');
        }                           
        
        fileName = 'reminder Notice';
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();                                
        attach.setBody(b);
        attach.setFileName(fileName+'.pdf');  

        Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
        System.debug(' owaMap '+owaMap); 
        for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
            owaMap.put(owa.Address,owa);
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
        email.setSubject('Reminder Notice');
            String body = '';
            body ='Dear '+applicantNames+',<br/><br/>'+                        
                'Greetings! <br/><br/>'+
                'We would like to inform you that as per the payment plan you have an upcoming instalment '+
                demandDatapdf.Installment__c + ' for ' + demandDatapdf.Payment_Milestones__r.Milestone_Name__c+
                ' getting due on '+demandDatapdf.Due_Date__c+' amounting AED '+' ' +mf+' '+' towards your purchase price for unit: '+
                demandDatapdf.booking__r.Unit__r.Name+' , Project: '+demandDatapdf.Project__r.Name+'.<br/><br/>'+
                'Please note that if you fail to pay the Due Amount in full, within the due date,  we hereby reserve the right to take necessary actions like Late penalty charges/probable cancellation as per the terms and conditions of the Contract/booking form.<br/><br/>'+
                'Please refer to the attached reminder notice for more details.<br/><br/>'+
                'In case you have already made the transfer, kindly ignore this reminder email.<br/><br/>'+
                '<u>For making transfer, please find below details</u> :-<br/>'+
                'By way of Wire Transfer:<br/>'+
                'Favoring	:	'+demandDatapdf.Unit__r.legal_entity__r.Favouring__c+',<br/>'+
                'Escrow Account No	: '+demandDatapdf.Unit__r.legal_entity__r.Account_Number_Flat_Cost__c+',<br/>'+
                'IBAN	:   '+demandDatapdf.Unit__r.legal_entity__r.IBAN__c+',<br/>'+
                'Swift Code	:	'+demandDatapdf.Unit__r.legal_entity__r.MICR_Code_Flat_Cost__c+',<br/>'+
                'Name of the Bank	:	'+demandDatapdf.Unit__r.legal_entity__r.Bank_Name_Flat_Cost__c+'<br/>'+
                'OR<br/>'+
                'By way of cheque issued in favour of '+demandDatapdf.Unit__r.legal_entity__r.Favouring__c+' payable at Dubai.<br/><br/>'+
                'In case you have any query or issue you can directly reach out to collection executive who is in touch with you, or you can write an email to '+System.label.SobhaHelpdesk+'<br/><br/>'+
                'Regards,<br/>'+
                'Collection Team<br/><br/>';

            email.setToAddresses(lststringtoaddress);
            email.setCcAddresses(lstStringccaddress);
            email.setWhatId(demandDatapdf.Booking__c);
            email.setHtmlBody('<span style="font-family:Tahoma;font-size:13px;" >'+body+'</span>');
            email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);

            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});           

            if(demandDatapdf.booking__r.Opportunity__r.Primary_Email__c != null && demandDatapdf.booking__r.Opportunity__r.Primary_Email__c!= ''){
                masterListMails.add(email);
                //Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});
            }
        } 
        Messaging.sendEmail(masterListMails);
    }
    
    @AuraEnabled
    public static List<Bookings> getDueDemandsForTower(String towerName,String projectName,String type){   
        Datetime condieredDate = System.today().addDays((1)*14); 
        Date consideredDate1 = Date.newInstance(condieredDate.year(), condieredDate.month(), condieredDate.day());
        Date tomorrowDate = System.today().addDays(1);
        Datetime condieredDate2 = System.today().addDays((1)*15); 
        Date consideredDate3 = Date.newInstance(condieredDate2.year(), condieredDate2.month(), condieredDate2	.day());
        Datetime reminderDate = System.today().addDays((-1)*14);
        Date reminderDate1 = Date.newInstance(reminderDate.year(), reminderDate.month(), reminderDate.day());
        System.debug('consideredDate1'+consideredDate1);
        System.debug('consideredDate3'+consideredDate3);
        System.debug('tomorrowsdate'+tomorrowDate);
        
        List<Demand__c> demandData = new List<Demand__c>();
        if(type == '15days'){
        	demandData = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,Booking__r.Milestone_Due_Till_Date__c,
                          booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                          booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,Last_Reminder_Notice_Amount_1__c,
                          Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,Reminder_Notice2__c,Reminder_Sent_Date_2__c,
                          Reminder_Sent_Date1__c,booking__r.name,Booking__r.Primary_Applicant_Name__c
                      	  FROM Demand__c 
                          WHERE OutStanding_days_calculated__c != 'paid' and 
                          Date_for_Late_Payment_Calculation__c >=:consideredDate1 and 
                          Date_for_Late_Payment_Calculation__c <=:consideredDate3 and 
                          (Reminder_Notice1__c = FALSE OR Reminder_Sent_Date1__c <=: reminderDate1) and
                          Tower__c =: towerName and Project__c =: projectName and unit__r.Tower__r.UnRegister_Project__c = false];
        
        }else if(type == 'onduedate'){
			demandData = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,Booking__r.Milestone_Due_Till_Date__c,
                          booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                          booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,Last_Reminder_Notice_Amount_1__c,
                          Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,Reminder_Notice2__c,Reminder_Sent_Date_2__c,
                          Reminder_Sent_Date1__c,booking__r.name,Booking__r.Primary_Applicant_Name__c
                      	  FROM Demand__c 
                          WHERE OutStanding_days_calculated__c != 'paid' and 
                          Date_for_Late_Payment_Calculation__c =:System.today() and
                          (Reminder_Notice1__c = FALSE OR Reminder_Sent_Date1__c <=: reminderDate1) and
                          Tower__c =: towerName and Project__c =: projectName and unit__r.Tower__r.UnRegister_Project__c = false];            
        }else{
            demandData = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,Booking__r.Milestone_Due_Till_Date__c,
                          booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                          booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,Last_Reminder_Notice_Amount_1__c,
                          Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,Reminder_Notice2__c,Reminder_Sent_Date_2__c,
                          Reminder_Sent_Date1__c,booking__r.name,Booking__r.Primary_Applicant_Name__c
                          FROM Demand__c 
                          WHERE OutStanding_days_calculated__c != 'paid' and 
                          (Date_for_Late_Payment_Calculation__c =:System.today() OR 
                          (Date_for_Late_Payment_Calculation__c >=:consideredDate1 and 
                          Date_for_Late_Payment_Calculation__c <=:consideredDate3)) and
                          (Reminder_Notice1__c = FALSE OR Reminder_Sent_Date1__c <=: reminderDate1) and
                          Tower__c =: towerName and Project__c =: projectName and unit__r.Tower__r.UnRegister_Project__c = false];
        }
        set<Id> bookingIdset = new set<Id>();
        for(Demand__c demandloop : demandData){
            bookingIdset.add(demandloop.Booking__c);
        }
        List<Booking__c> bookingData = new List<Booking__c>();
        
		
        List<Bookings> bookingfinalList = new List<Bookings>();
        for(Demand__c demandloopvalue : demandData){
            if(demandloopvalue.booking__r.Milestone_Due_Till_Date__c > demandloopvalue.booking__r.Total_On_Account_Money_With_Registration__c && demandloopvalue.booking__r.Due_Payments__c > 10000){
                 Bookings bk = new Bookings();
            bk.bookingId = demandloopvalue.booking__r.id;
            bk.bookingLink = '/'+bk.bookingId;
            bk.bookingName = demandloopvalue.booking__r.name;	
            bk.checked = false;
            bk.unitName = demandloopvalue.booking__r.Unit__r.Name;
            bk.milestoneDueTillDate = (demandloopvalue.booking__r.Milestone_Due_Till_Date__c != null)?(long)demandloopvalue.booking__r.Milestone_Due_Till_Date__c:0;
            bk.collectedAmount = (demandloopvalue.booking__r.Total_On_Account_Money_With_Registration__c != null)?(long)demandloopvalue.booking__r.Total_On_Account_Money_With_Registration__c:0;
            bk.dueAmount = (demandloopvalue.booking__r.Due_Payments__c != null)?(long)demandloopvalue.booking__r.Due_Payments__c:0;
            bk.reminderSentDate = (demandloopvalue.Reminder_Sent_Date1__c != null)?String.valueOfGmt(demandloopvalue.Reminder_Sent_Date1__c):'';
            bk.customerName = demandloopvalue.booking__r.Primary_Applicant_Name__c;
            bk.totalInterestTillDate = (demandloopvalue.booking__r.Total_Interest_Till_Date__c != null)?(long)demandloopvalue.booking__r.Total_Interest_Till_Date__c:0;
            bk.lastReminderAmount = (demandloopvalue.Last_Reminder_Notice_Amount_1__c != null)?(long)demandloopvalue.Last_Reminder_Notice_Amount_1__c:0;    
            bk.age = demandloopvalue.Reminder_Notice1__c == true ? 'On DueDate' : '15days' ; 
            bk.demandId = demandloopvalue.id;
                bookingfinalList.add(bk);
            }
        }
        system.debug('I am list'+bookingfinalList);
        return bookingfinalList;
    }
    
    
    @AuraEnabled
    public static List<Project__c> getProjects(){
        List<Project__c> projectsList = new List<Project__c>();
        projectsList = [SELECT ID,NAME, (select Id, Name from Towers__r Order By Name ASC) FROM PROJECT__C];
        return projectsList;
    } 
  
    public class Bookings {
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingLink;
        @AuraEnabled public string bookingName;
        @AuraEnabled public boolean checked;
        @AuraEnabled public long milestoneDueTillDate;
        @AuraEnabled public long collectedAmount;
        @AuraEnabled public long dueAmount;
        @AuraEnabled public string reminderSentDate;
        @AuraEnabled public long lastReminderAmount;
        @AuraEnabled public string unitName;
        @AuraEnabled public string customerName;
        @AuraEnabled public long totalInterestTillDate;
        @AuraEnabled public string age;
        @AuraEnabled public string demandId;
        public Bookings(){
            bookingId='';
            bookingLink='';
            bookingName='';
            checked=false;
            milestoneDueTillDate=0;
            collectedAmount=0;
            dueAmount=0;
            unitName='';
            reminderSentDate='';
           	customerName='';
            totalInterestTillDate=0;
            lastReminderAmount=0;
            age='';
            demandId = '';
            
        }
    }
}