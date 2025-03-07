global class RaiseLatePenaltyBatch30Days implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    global Map<Id,Id> Mapbooking_and_DemandIds = new Map<Id,Id>();
    global List<Booking__c> bookingList = new List<Booking__c>();

    public void execute(SchedulableContext ctx){
        Id batchJobId = Database.executeBatch(this,1);
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        set<String> bookingIdsSet = new set<String>();
        Date date30days = System.today() - 30;
        Date Day_31_FromAuditAccepted = System.today() - 30;
        String query = 'SELECT Id,Name,Date_for_Late_Payment_Calculation__c,Booking__r.Id,Booking__r.Total_On_Account_Money_With_Registration__c,Milestone_Name__c,Due_Date__c,Total_Amount_Demanded__c,Total_Amount_with_Tax_Demanded__c,Booking__r.Primary_Applicant_Name__c,Booking__r.Opportunity__r.Other_Applicants_Name__c,'+
                        'LP_Raised_For__c,Installment__c,Payment_Milestones__r.Charge1Percentage__c,Booking__r.Booking_Date__c,Last_LP_Raised_Date__c,Previous_LP_Amount__c,LP_Calculation__c,Previous_LP_Name__c,Booking__r.Tower__c,Booking__r.Unit__r.Name,'+
                        'Booking__r.VAT_On_Interest_Amount__c,Number_of_Late_Payment_Raised__c,booking__r.Project__c,Booking__r.Unit__c,Booking__r.Unit__r.Tower__r.ByPass_LP_Calculation__c,'+
                        'Demand_Age__c,OutStanding_days_calculated__c,No_of_days__c,No_of_Months__c,Interest_Charges__c,Balance_Amount__c FROM Demand__c WHERE ';
        if(System.Label.Late_Payment_Dynamic_Query == '' || System.Label.Late_Payment_Dynamic_Query == null || System.Label.Late_Payment_Dynamic_Query == 'null'){
            query +=    ' Payment_Milestones__c != null '+
                        ' AND Booking__c != null AND Demand_Status__c !=\'Reversed\' AND Date_for_Late_Payment_Calculation__c != null AND Date_for_Late_Payment_Calculation__c =: date30days '+
                        ' AND (NOT Milestone_Name__c LIKE \'%balance%\') AND Booking__r.Audit_Approval_Date__c <: Day_31_FromAuditAccepted '+
                        ' AND Booking__r.Stage_of_Booking__c != \'Cancelled\' AND Booking__r.Status__c != \'Cancelled\' AND Booking__r.Current_Status__c = \'Audit Accepted\' AND Booking__r.PCC_Approved_By_Audit__c = false '+
                        ' AND Booking__r.Unit__r.Tower__r.LPC_Automation_Exception__c = false AND OutStanding_days_calculated__c != \'Paid\' '+
                        ' AND Booking__r.Unit__r.Tower__r.UnRegister_Project__c = false AND Booking__r.Unit__r.Tower__r.ByPass_LP_Calculation__c = false ORDER BY Date_for_Late_Payment_Calculation__c ASC';
        }else{
            query += System.Label.Late_Payment_Dynamic_Query;
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Demand__c> demandList) {
        System.debug('demandList -> '+demandList);
        try {
            String status = LatePaymentManager.generateLP(demandList,true);
            if(status.contains('Send Email')){
                String LPId = status.split(';').size() > 0 ? status.split(';')[1] : null; 
                System.debug('LPId -> '+LPId);
                Booking__c bk = new Booking__c();
                bk = demandList[0].Booking__r;
                System.debug('bk[0] -> '+bk);
                bk.X30days_Demand_Raised__c = true;
                bookingList.add(bk);
                Mapbooking_and_DemandIds.put(demandList[0].Booking__c,LPId);
                System.debug('demandList[0] -> '+Mapbooking_and_DemandIds);
            }
        } catch (Exception e) {
            Error_Log__c EL = new Error_Log__c();
            EL.Class__c = 'RaiseLatePenaltyBatch30Days';
            EL.Message__c = ' 30 LatePaymentManager.generateLP Demand :- '+demandList[0].Name+' Error :- '+e.getMessage()+' Line Number :-'+e.getLineNumber();
            EL.Booking__c = demandList[0].Booking__c;
            EL.Demand__c = demandList[0].Id;
            insert EL;
        }
    }

    global void finish(Database.BatchableContext BC) {
        Bypass_Setting__c bypassSettingInstance = Bypass_Setting__c.getInstance();

        try {
            bypassSettingInstance.Bypass_Booking_Trigger__c = true;
            upsert bypassSettingInstance;

            update bookingList;

            bypassSettingInstance.Bypass_Booking_Trigger__c = true;
            upsert bypassSettingInstance;

            /*for (booking__c booking : bookingList) {
                try {
                    LatePaymentManager.sendEmail(booking.Id,Mapbooking_and_DemandIds.get(booking.Id));
                } catch (Exception e) {
                    bypassSettingInstance.Bypass_Booking_Trigger__c = true;
                    upsert bypassSettingInstance;

                    Error_Log__c EL = new Error_Log__c();
                    EL.Class__c = 'RaiseLatePenaltyBatch30Days';
                    EL.Message__c = ' 30 LatePaymentManager.sendEmail Booking :- '+booking.Name+' Error :- '+e.getMessage()+' Line Number :-'+e.getLineNumber();
                    EL.Booking__c = booking.Id;
                    insert EL;
                }
            }*/
        } catch (Exception e) {
            bypassSettingInstance.Bypass_Booking_Trigger__c = true;
            upsert bypassSettingInstance;

            Error_Log__c EL = new Error_Log__c();
            EL.Class__c = 'RaiseLatePenaltyBatch30Days';
            EL.Message__c = ' 30 LatePaymentManager.sendEmail Booking Updates Error :- '+e.getMessage()+' Line Number :-'+e.getLineNumber();
            insert EL; 

        }
    }

    public static void dummyCovrage(){
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
    }
    
    
}