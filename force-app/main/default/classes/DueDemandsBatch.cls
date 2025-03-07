global class DueDemandsBatch implements Database.Batchable<sObject>, Database.Stateful{
   
    global list<string> demandIdList =  new List<string>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime condieredDate = System.today().addDays((1)*14);
       
        Date consideredDate1 = Date.newInstance(condieredDate.year(), condieredDate.month(), condieredDate.day());
        Datetime condieredDate2 = System.today().addDays((1)*15);
        Date consideredDate3 = Date.newInstance(condieredDate2.year(), condieredDate2.month(), condieredDate2.day());
        Datetime reminderDate = System.today().addDays((-1)*14);
        Date reminderDate1 = Date.newInstance(reminderDate.year(), reminderDate.month(), reminderDate.day());
        Date currentdate = System.today();
        System.debug('consideredDate1'+consideredDate1);
        System.debug('consideredDate3'+consideredDate3);
        
        String query = 'SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,Booking__r.Milestone_Due_Till_Date__c,'+
                          'booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,Date_for_Late_Payment_Calculation__c,'+
                         'booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,Last_Reminder_Notice_Amount_1__c,'+
                          'Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,Reminder_Notice2__c,Reminder_Sent_Date_2__c,'+
                          'Reminder_Sent_Date1__c,booking__r.name,Booking__r.Primary_Applicant_Name__c '+
                          'FROM Demand__c'+ 
                          ' WHERE Payment_Milestones__c != null and'+ 
                          ' OutStanding_days_calculated__c != \'paid\' and'+ 
                          ' (Date_for_Late_Payment_Calculation__c =:currentdate'+' OR'+ 
                          ' (Date_for_Late_Payment_Calculation__c >=:consideredDate1'+' and'+ 
                          ' Date_for_Late_Payment_Calculation__c <=:consideredDate3'+')) and'+
                          ' (Reminder_Notice1__c = FALSE OR Reminder_Sent_Date1__c <=:reminderDate1'+ ') and'+
                          ' unit__r.Tower__r.UnRegister_Project__c = false and Booking__r.Due_Payments__c > 10000';
        System.debug('I am query '+ query);
        return Database.getQueryLocator(query);
    }
	
    global void execute(Database.BatchableContext BC, List<Demand__C> demandList) {
        
        System.debug('i am demandList'+demandList.size());
        List<String> demands15DaysList = new List<String>();
        List<String> demandsOnDueList = new List<String>();
        for(Demand__c demand : demandList){
            if(demand.Date_for_Late_Payment_Calculation__c == System.today()){
                demandsOnDueList.add(demand.id);
                System.debug('i am demandListondue'+demandsOnDueList);
            }else{
                demands15DaysList.add(demand.id);
                System.debug('i am demandList15'+demands15DaysList);
            }
        }
        System.debug('i am demandList ondue'+demandsOnDueList);
        System.debug('i am demandList 15'+demands15DaysList);
         if(demands15DaysList != null && demands15DaysList.size()>0){
        	DueDemandsController.demandActions('15days',demands15DaysList);
            DueDemandsController.sendEmail('15days',demands15DaysList);
             
         }
         if(demandsOnDueList != null && demandsOnDueList.size()>0){
        	DueDemandsController.demandActions('onduedate',demandsOnDueList);
            DueDemandsController.sendEmail('onduedate',demandsOnDueList);
         }
        
    }
     global void finish(Database.BatchableContext BC) {
        
    }
}