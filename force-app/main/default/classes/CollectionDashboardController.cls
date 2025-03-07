public class CollectionDashboardController {
    @AuraEnabled
    public static list<Project__c> getProjects(){
        return [SELECT Id, Name, (SELECT Id, Name FROM Towers__r Order By Name ASC) FROM Project__c Order By Name ASC];
    }

    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
         Schema.DescribeFieldResult fieldResult = Task__c.Category__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             pickListValuesList.add(pickListVal.getLabel());
         }     
         return pickListValuesList;
    }

    @AuraEnabled
    public static list<BookingWrapper> getBookingsByBucket(string projectId, string towerId, string selectedType, string bucketColor){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();
        
        if(selectedType == 'Follow-Ups'){
            list<Booking__c> bookings = [SELECT id,primaryMobileNumber__c FROM Booking__c WHERE Status__c != 'Cancelled' AND Current_Status__c = 'Audit Accepted' AND Next_Action_Date__c != null AND Next_Action_Date__c <= TODAY AND Last_Call_Attempted_By__c =: UserINfo.getName()];
            pmList = [SELECT id,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c 
                    WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__c IN: bookings ORDER BY Milestone_Due_Date__c ASC];
        }
        else if(selectedType != 'Follow-Ups' && selectedType != 'Due Payments' && selectedType != 'Advance Payments' && selectedType != 'Gross All'){
            searchByCategory = true;
            if(selectedType == 'All'){
                pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Last_Call_Attempt_Status__c IN : categoryList ORDER BY Milestone_Due_Date__c ASC];
            }
            else{
                pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Last_Call_Attempt_Status__c =: selectedType ORDER BY Milestone_Due_Date__c ASC];
            }
        }
        else if(selectedType == 'Gross All'){
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Unit__r.Tower__c =: towerId 
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }
        else{
            pmList = [SELECT id,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c, Milestone_Due_Date__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c 
                        WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' 
                            AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' 
                            AND Quotation__c != null AND Milestone_Due_Date__c != null 
                            AND Milestone_Due_Date__c <= TODAY 
                            AND Quotation__r.Unit__r.Tower__c =: towerId  
                            AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND 
                            (Quotation__r.Booking__r.Last_Call_Attempt_Status__c = null 
                                OR Quotation__r.Booking__r.Last_Call_Attempt_Status__c = 'Not Pitched')
                            Order By Milestone_Due_Date__c ASC];
        }
        
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        
        map<string,Booking__c> bookingIdToBooking = new map<string,Booking__c>();
        
        for(Booking__c b : [SELECT id,PrimaryMobileNumber__c,Last_Call_Attempt_Status__c,Full_Due__c,Pre_Registration_Status__c,Booking_Date__c,Last_Call_Description__c,Opportunity__c,
            Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,name,Unit__c,Unit__r.Name,Unit__r.Tower__r.Due_Payments__c,Unit__r.Tower__r.Advance_Payments__c,Primary_Applicant_Name__c,
            Agreement_Value__c,Total_Agreement_Value_Demanded__c,Total_On_Account_Money_With_Registration__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c,
            (SELECT id, Notes__c FROM Tasks__r order by createddate desc limit 1) FROM Booking__c WHERE Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }
        
        for(string booking : bookingToPM.keySet()){
            BookingWrapper wrap = new BookingWrapper();
            Booking__c bk = bookingIdToBooking.get(booking);
            wrap.unitName = bk.Unit__r.Name;
            wrap.unitId = '/'+bk.Unit__c;
            wrap.bookingName = bk.Name;
            wrap.bookingId = '/'+bk.id;
            wrap.bookingIdVal = bk.id;
            wrap.customerName = bk.Primary_Applicant_Name__c;
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Name__c != null){
                wrap.customerName = wrap.customerName + ' & ' + bk.Opportunity__r.Other_Applicants_Name__c;
            }
            wrap.saleValue = (Long) bk.Agreement_Value__c;
            wrap.demands = (Long) bk.Total_Agreement_Value_Demanded__c;
            wrap.collected = (Long) bk.Total_On_Account_Money_With_Registration__c;
            wrap.fullDue = (Long) bk.Full_Due__c;
            wrap.registrationStatus = bk.Pre_Registration_Status__c;
            wrap.lastCallAttemptStatus = bk.Last_Call_Attempt_Status__c;
            wrap.ByPass_Unit_Cancellation = bk.Unit__r.Tower__r.ByPass_Unit_Cancellation__c;
            wrap.primaryMobileNumber = bk.PrimaryMobileNumber__c;
            if(bk.Booking_Date__c != null){
                wrap.bookingDate = bk.Booking_Date__c.format('dd/MM/yyyy');
            }
            wrap.soaLink = '/apex/N_CustomerSOAPage?id='+bk.Opportunity__c+'&bookingid='+bk.Id;
            if(bk.Tasks__r.size()>0)
                wrap.commentsHistory = bk.Tasks__r[0].Notes__c;
            
            long sum = 0;
            long duePayment = (Long) bk.Unit__r.Tower__r.Due_Payments__c;
            long advPayment = (Long) bk.Unit__r.Tower__r.Advance_Payments__c;
            Integer diffDays = 0;
            Boolean milestoneHit = false;
            for(Payment_Milestones__c pm : bookingToPM.get(booking)){
                sum = sum + (long)pm.Total_Installment_New__c;
                if (sum > (long)bk.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                    Date milestoneDate = pm.Milestone_Due_Date__c;
                    Date startDate = Date.today();
                    Date endDate = milestoneDate;
                    diffDays = endDate.daysBetween(startDate);
                    milestoneHit = true;
                }
            }
                        
            if(selectedType == 'Due Payments'){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) >= duePayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Due Payments';
                        if(bucketColor == 'Green'){
                            if (diffDays <= 30) {
                                wrap.bucketColor = '#B1ffB1';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        } else if(bucketColor == 'Yellow'){
                            if (diffDays > 30 && diffDays <= 60) {
                                wrap.bucketColor = '#FCFF6F';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        } else if(bucketColor == 'Amber'){
                            if (diffDays > 60 && diffDays <= 90) {
                                wrap.bucketColor = '#FFBF00';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        }else if(bucketColor == 'Red'){
                            if (diffDays > 90) {
                                wrap.bucketColor = '#FF6F59';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        }
                    }
                }
            }
            if(selectedType == 'Gross All'){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    wrap.milestoneDue = sum;
                    wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                    wrap.category = 'Due Payments';
                    if(bucketColor == 'Green'){
                        if (diffDays <= 30) {
                            wrap.bucketColor = '#B1ffB1';
                            wrap.age = diffDays;
                            wrapList.add(wrap);
                        }
                    } else if(bucketColor == 'Yellow'){
                        if (diffDays > 30 && diffDays <= 60) {
                            wrap.bucketColor = '#FCFF6F';
                            wrap.age = diffDays;
                            wrapList.add(wrap);
                        }
                    } else if(bucketColor == 'Amber'){
                        if (diffDays > 60 && diffDays <= 90) {
                            wrap.bucketColor = '#FFBF00';
                            wrap.age = diffDays;
                            wrapList.add(wrap);
                        }
                    }else if(bucketColor == 'Red'){
                        if (diffDays > 90) {
                            wrap.bucketColor = '#FF6F59';
                            wrap.age = diffDays;
                            wrapList.add(wrap);
                        }
                    }
                }
            }
            
            /*if((selectedType == 'Advance Payments' && bk.Full_Due__c != 0) || (selectedType == 'Gross All' && bk.Full_Due__c != 0)){
                if((long) bk.Total_On_Account_Money_With_Registration__c >= sum ){
                    wrap.milestoneDue = sum;
                    //wrap.due = (long) bk.Total_On_Account_Money_With_Registration__c - sum;
                    wrap.category = 'Advance Payments';
                    wrap.bucketColor = '#ADD8E6';
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
                else if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) <= advPayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Advance Payments';
                        wrap.bucketColor = '#ADD8E6';
                        wrap.age = diffDays;
                        wrapList.add(wrap);
                    }
                }
            }*/
            
            if(selectedType == 'Follow-Ups' || searchByCategory){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) >= duePayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Due Payments';
                        if(bucketColor == 'Green'){
                            if (diffDays <= 30) {
                                wrap.bucketColor = '#B1ffB1';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        } else if(bucketColor == 'Yellow'){
                            if (diffDays > 30 && diffDays <= 60) {
                                wrap.bucketColor = '#FCFF6F';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        } else if(bucketColor == 'Amber'){
                            if (diffDays > 60 && diffDays <= 90) {
                                wrap.bucketColor = '#FFBF00';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        }else if(bucketColor == 'Red'){
                            if (diffDays > 90) {
                                wrap.bucketColor = '#FF6F59';
                                wrap.age = diffDays;
                                wrapList.add(wrap);
                            }
                        }
                    }
                    else if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) <= advPayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Advance Payments';   
                        wrap.age = diffDays;                     
                        wrapList.add(wrap);
                    }
                }
                if((long) bk.Total_On_Account_Money_With_Registration__c >= sum ){
                    wrap.milestoneDue = sum;
                    wrap.due = (long) bk.Total_On_Account_Money_With_Registration__c - sum;
                    wrap.category = 'Advance Payments';
                    wrap.bucketColor = '#ADD8E6';
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
            }
        }
        wrapList.sort();
        return wrapList;
    }
    
    @AuraEnabled
    public static list<BookingWrapper> getBookings(string projectId, string towerId, string selectedType){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        boolean searchByCategory = false;
        List<String> categoryList = getPickListValuesIntoList();
        
        if(selectedType == 'Follow-Ups'){
            list<Booking__c> bookings = [SELECT id FROM Booking__c WHERE Status__c != 'Cancelled' AND Current_Status__c = 'Audit Accepted' AND Next_Action_Date__c != null AND Next_Action_Date__c <= TODAY AND Last_Call_Attempted_By__c =: UserINfo.getName()];
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__c IN: bookings ORDER BY Milestone_Due_Date__c ASC];
        }
        else if(selectedType != 'Follow-Ups' && selectedType != 'Due Payments' && selectedType != 'Advance Payments' && selectedType != 'Gross All'){
            searchByCategory = true;
            if(selectedType == 'All'){
                pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Last_Call_Attempt_Status__c IN : categoryList ORDER BY Milestone_Due_Date__c ASC];
            }
            else{
                pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Unit__r.Tower__c =: towerId AND Quotation__r.Unit__r.Project__c =: projectId AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Last_Call_Attempt_Status__c =: selectedType ORDER BY Milestone_Due_Date__c ASC];
            }
        }
        else if(selectedType == 'Gross All'){
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Unit__r.Tower__c =: towerId 
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }
        else{
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Unit__r.Tower__c =: towerId 
                      AND Quotation__r.Unit__r.Project__c =: projectId 
                      AND Quotation__r.Booking__c != null AND 
                      (Quotation__r.Booking__r.Last_Call_Attempt_Status__c = null 
                       OR Quotation__r.Booking__r.Last_Call_Attempt_Status__c = 'Not Pitched')
                      ORDER BY Milestone_Due_Date__c ASC];
        }

        set<string> greenList = new set<string>();
        set<string> yellowList = new set<string>();
        set<string> amberList = new set<string>();
        set<string> redList = new set<string>();

        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        
        map<string,Booking__c> bookingIdToBooking = new map<string,Booking__c>();
        
        for(Booking__c b : [SELECT id,PrimaryMobileNumber__c,Last_Call_Attempt_Status__c,Full_Due__c,Pre_Registration_Status__c,Booking_Date__c,Last_Call_Description__c,Opportunity__c,
            Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,name,Unit__c,Unit__r.Name,Unit__r.Tower__r.Due_Payments__c,Unit__r.Tower__r.Advance_Payments__c,Primary_Applicant_Name__c,
            Agreement_Value__c,Total_Agreement_Value_Demanded__c,Total_On_Account_Money_With_Registration__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c,
            (SELECT id, Notes__c FROM Tasks__r order by createddate desc limit 1)  FROM Booking__c WHERE Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }
        
        for(string booking : bookingToPM.keySet()){
            BookingWrapper wrap = new BookingWrapper();
            Booking__c bk = bookingIdToBooking.get(booking);
            wrap.unitName = bk.Unit__r.Name;
            wrap.unitId = '/'+bk.Unit__c;
            wrap.bookingName = bk.Name;
            wrap.bookingId = '/'+bk.id;
            wrap.bookingIdVal = bk.id;
            wrap.customerName = bk.Primary_Applicant_Name__c;
            wrap.ByPass_Unit_Cancellation = bk.Unit__r.Tower__r.ByPass_Unit_Cancellation__c;
            wrap.primaryMobileNumber = bk.PrimaryMobileNumber__c;
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Name__c != null){
                wrap.customerName = wrap.customerName + ' & ' + bk.Opportunity__r.Other_Applicants_Name__c;
            }
            wrap.saleValue = (Long) bk.Agreement_Value__c;
            wrap.demands = (Long) bk.Total_Agreement_Value_Demanded__c;
            wrap.collected = (Long) bk.Total_On_Account_Money_With_Registration__c;
            wrap.fullDue = (Long) bk.Full_Due__c;
            wrap.registrationStatus = bk.Pre_Registration_Status__c;
            wrap.lastCallAttemptStatus = bk.Last_Call_Attempt_Status__c;
            if(bk.Booking_Date__c != null){
                wrap.bookingDate = bk.Booking_Date__c.format('dd/MM/yyyy');
            }
            wrap.soaLink = '/apex/N_CustomerSOAPage?id='+bk.Opportunity__c+'&bookingid='+bk.Id;
            if(bk.Tasks__r.size()>0)
                wrap.commentsHistory = bk.Tasks__r[0].Notes__c;
            
            long sum = 0;
            long duePayment = (Long) bk.Unit__r.Tower__r.Due_Payments__c;
            long advPayment = (Long) bk.Unit__r.Tower__r.Advance_Payments__c;
            
            Integer diffDays = 0;
        	Boolean milestoneHit = false;
            for(Payment_Milestones__c pm : bookingToPM.get(booking)){
                sum = sum + (long)pm.Total_Installment_New__c;
                if (sum > (long)bk.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                    Date milestoneDate = pm.Milestone_Due_Date__c;
                    Date startDate = Date.today();
                    Date endDate = milestoneDate;
                    diffDays = endDate.daysBetween(startDate);
                    milestoneHit = true;
                }
            }
                        
            if(selectedType == 'Due Payments'){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) >= duePayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Due Payments';
                        if (diffDays <= 30) {
                            wrap.bucketColor = '#B1ffB1';                        
                        } else if (diffDays > 30 && diffDays <= 60) {
                            wrap.bucketColor = '#FCFF6F';
                        } else if (diffDays > 60 && diffDays <= 90) {
                            wrap.bucketColor = '#FFBF00';
                        } else if(diffDays > 90){
                            wrap.bucketColor = '#FF6F59';
                        }
                        wrap.age = diffDays;
                        wrapList.add(wrap);
                    }
                }
            }
            
            if((selectedType == 'Advance Payments' && bk.Full_Due__c != 0)){
                if((long) bk.Total_On_Account_Money_With_Registration__c >= sum ){
                    wrap.milestoneDue = sum;
                    //wrap.due = (long) bk.Total_On_Account_Money_With_Registration__c - sum;
                    wrap.category = 'Advance Payments';
                    wrap.bucketColor = '#ADD8E6';
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
                else if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) <= advPayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Advance Payments';
                        wrap.bucketColor = '#ADD8E6';
                        wrap.age = diffDays;
                        wrapList.add(wrap);
                    }
                }
            }

            if(selectedType == 'Gross All'){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    wrap.milestoneDue = sum;
                    wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                    wrap.category = 'Due Payments';
                    if (diffDays <= 30) {
                        wrap.bucketColor = '#B1ffB1';                        
                    } else if (diffDays > 30 && diffDays <= 60) {
                        wrap.bucketColor = '#FCFF6F';
                    } else if (diffDays > 60 && diffDays <= 90) {
                        wrap.bucketColor = '#FFBF00';
                    } else if(diffDays > 90){
                        wrap.bucketColor = '#FF6F59';
                    }
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
                if((long) bk.Total_On_Account_Money_With_Registration__c >= sum ){
                    wrap.milestoneDue = sum;
                    wrap.category = 'Advance Payments';
                    wrap.bucketColor = '#ADD8E6';
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
            }
            
            if(selectedType == 'Follow-Ups' || searchByCategory){
                if(sum > (long) bk.Total_On_Account_Money_With_Registration__c){
                    if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) >= duePayment){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Due Payments';
                        if (diffDays <= 30) {
                            wrap.bucketColor = '#B1ffB1';                            
                        } else if (diffDays > 30 && diffDays <= 60) {
                            wrap.bucketColor = '#FCFF6F';
                        } else if (diffDays > 60 && diffDays <= 90) {
                            wrap.bucketColor = '#FFBF00';
                        } else if(diffDays > 90){
                            wrap.bucketColor = '#FF6F59';
                        }
                        wrap.age = diffDays;
                        wrapList.add(wrap);
                    }
                    else if((sum - (long) bk.Total_On_Account_Money_With_Registration__c) <= advPayment && bk.Full_Due__c != 0){
                        wrap.milestoneDue = sum;
                        wrap.due = sum - (long) bk.Total_On_Account_Money_With_Registration__c;
                        wrap.category = 'Advance Payments';
                        if (diffDays <= 30) {
                            wrap.bucketColor = '#B1ffB1';                            
                        } else if (diffDays > 30 && diffDays <= 60) {
                            wrap.bucketColor = '#FCFF6F';
                        } else if (diffDays > 60 && diffDays <= 90) {
                            wrap.bucketColor = '#FFBF00';
                        } else if(diffDays > 90){
                            wrap.bucketColor = '#FF6F59'; 
                        }
                        wrap.age = diffDays;
                        wrapList.add(wrap);
                    }
                }
                if((long) bk.Total_On_Account_Money_With_Registration__c >= sum && bk.Full_Due__c != 0){
                    wrap.milestoneDue = sum;
                    wrap.due = (long) bk.Total_On_Account_Money_With_Registration__c - sum;
                    wrap.category = 'Advance Payments';
                    wrap.bucketColor = '#ADD8E6';
                    wrap.age = diffDays;
                    wrapList.add(wrap);
                }
            }
        }
        wrapList.sort();
        return wrapList;
    }
    
    @AuraEnabled
    public static void updateLastActionOnBooking(string category, string bookingId, string taskId, string dueOrAdvanceAmount){
        dueOrAdvanceAmount = dueOrAdvanceAmount.remove(',');
        Task__c task = [SELECT id,Category__c,Communication_Mode__c,Follow_up_Date__c,CreatedDate,Owner.Name,Notes__c,Expected_Date_Of_The_Payment__c,Customer_Interested__c FROM Task__c WHERE Id =: taskId];
        Booking__c bk = new Booking__c();
        bk.Id = bookingId;
        bk.Category__c = category;
        bk.Last_Call_Attempt_Date__c = task.CreatedDate;
        bk.Last_Call_Attempt_Status__c = task.Category__c;
        if(task.Category__c == 'Raise for Cancellation'){
            bk.X30days_Demand_Raised__c = true;
            bk.X15days_Demand_Raised__c = true;
        }
        bk.Last_Call_Description__c = task.Notes__c;
        bk.Last_Action_Type__c = task.Communication_Mode__c;
        bk.Next_Action_Date__c = task.Follow_up_Date__c;
        bk.Due_Advance_Amount__c = Long.valueOf(dueOrAdvanceAmount);
        if(task.Customer_Interested__c == 'Yes'){
            bk.Next_Action_Date__c = task.Expected_Date_Of_The_Payment__c;
        }
        bk.Last_Call_Attempted_By__c = task.Owner.Name;
        update bk;
    }

    @AuraEnabled
    public static string createTaskOnCall(string bookingId){
        Task__c t = new Task__c();
        t.Booking__c = bookingId;
        t.Manual_Dial__c = false;
        insert t;
        return t.Id;
    }
    
    @AuraEnabled
    public static void sendEmail(string bookingId){
        Booking__c bk = [SELECT id,Due_Payments__c,Project_Name__c,Unit__r.Name,Last_Call_Attempt_Status__c,Primary_Applicant_Email__c,Opportunity__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Primary_Applicant_Name__c FROM Booking__c WHERE id =: bookingId];
        if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' || bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation'){
            string templateDeveloperName = '';
            if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach')
                templateDeveloperName = 'No_Contact_Or_Unable_To_Reach';
            if(bk.Last_Call_Attempt_Status__c == 'Raise for Cancellation')
                templateDeveloperName = 'Raise_for_Cancellation';
            EmailTemplate e = [SELECT id, HtmlValue, subject FROM EmailTemplate WHERE DeveloperName =: templateDeveloperName];
            string body = e.HtmlValue;
            body = body.replace('#PrimaryApplicant#', bk.Primary_Applicant_Name__c);
            body = body.replace('#Unit#', bk.Unit__r.Name);
            string projectName = '';
            if(bk.Project_Name__c != null)
                projectName = bk.Project_Name__c;
            body = body.replace('#Project#', projectName);
            if(bk.Last_Call_Attempt_Status__c == 'No Contact / Unable to Reach' && bk.Due_Payments__c != null){
                body = body.replace('#OverdueAmount#', String.valueOf(bk.Due_Payments__c));
            }
            string subject = e.subject;
            subject = subject.replace('#Unit#', bk.Unit__r.Name);
            subject = subject.replace('#Project#', projectName);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setSubject(subject); 
            mail.setHtmlBody(body);
            list<string> toAddress = new list<string>();
            list<string> ccAddress = new list<string>();
            toAddress.add(bk.Primary_Applicant_Email__c);
            if(bk.Opportunity__c != null && bk.Opportunity__r.Other_Applicants_Email__c != null){
                string emails = bk.Opportunity__r.Other_Applicants_Email__c;
                emails = emails.trim();
                emails = emails.removeEnd(',');
                ccAddress.addAll(emails.split(','));
            }
            ccAddress.add(UserInfo.getUserEmail());
            ccAddress.add(System.label.collection_email);
            ccAddress.add('sfnotifications@sobharealty.com'); 
            mail.setToAddresses(toAddress);
            mail.setCcAddresses(ccAddress);
            mail.setWhatId(bk.id);
            mail.setSaveAsActivity(true); 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    @AuraEnabled
    public static Boolean sendBankDetailsEmail(String unitId){
        Boolean result = false;
        Unit__c u = [SELECT id,Booking__r.Primary_Applicant_Email__c FROM Unit__c WHERE id=:unitId];
        EmailTemplate et = [SELECT Id,Name FROM EmailTemplate WHERE Name = 'Bank Account Details ticker'];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        List<String> toCCAddress = new List<String>();
        toCCAddress.add(System.label.collection_email);
        toCCAddress.add('sfnotifications@sobharealty.com'); 

        message.setTargetObjectId(UserInfo.getUserId());
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setCcAddresses(toCCAddress);
        message.setSaveAsActivity(false);
        message.setTreatTargetObjectAsRecipient(false);

        message.setTemplateID(et.Id);
        message.setWhatId(unitId);
        message.toAddresses = new String[] { u.Booking__r.Primary_Applicant_Email__c};

        Messaging.SingleEmailMessage[] messages = new   
        List<Messaging.SingleEmailMessage> {message};

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    @future
    public static void createTask(list<string> bkIds){
        list<Booking__c> bkListToCreateTask = [SELECT id,Unit__r.Tower__r.Advance_Payments__c,Total_On_Account_Money__c,Registration_Amount_Paid__c,Total_On_Account_Money_With_Registration__c FROM Booking__c WHERE Id IN: bkIds];
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        pmList = [SELECT id,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c FROM Payment_Milestones__c WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND Quotation__c != null AND Milestone_Due_Date__c != null AND Milestone_Due_Date__c <= TODAY AND Quotation__r.Booking__c IN: bkListToCreateTask];
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }
        Map<String,Long> bookingIdToAdvanceAmount = new Map<String,Long>();
        List<Task__c> tasksToCreate = new List<Task__c>();
        for(Booking__c booking : bkListToCreateTask){
            if(bookingToPM.containsKey(booking.Id)){
                long sum = 0;
                long amount = 0;
                boolean isCreateTask = false;
                for(Payment_Milestones__c pm : bookingToPM.get(booking.Id)){
                    sum = sum + (long)pm.Total_Installment_New__c;
                }
                long totalOnAccountMoneyWithRegistration = (long)booking.Total_On_Account_Money_With_Registration__c;
                if(totalOnAccountMoneyWithRegistration >= sum){ 
                    amount = totalOnAccountMoneyWithRegistration-sum;
                    isCreateTask = true;
                }
                else if(((sum - totalOnAccountMoneyWithRegistration) > 0 && (sum - totalOnAccountMoneyWithRegistration) <= booking.Unit__r.Tower__r.Advance_Payments__c)){
                    amount = sum - totalOnAccountMoneyWithRegistration;
                    isCreateTask = true;
                }
                if(isCreateTask){
                    Task__c t = new Task__c();
                    t.Category__c = 'Not Pitched';
                    t.Booking__c = booking.Id;
                    t.Notes__c = 'Not Pitched';
                    tasksToCreate.add(t);
                    bookingIdToAdvanceAmount.put(booking.Id,amount);
                }
            }
        }
        if(tasksToCreate.size()>0){
            insert tasksToCreate;
        }
        if(bookingIdToAdvanceAmount.size()>0){
            CollectionDashboardController.updateTaskDetailsOnBooking(bookingIdToAdvanceAmount); 
        }
    }
    
    public static void updateTaskDetailsOnBooking(Map<String,Long> bookingIdToAdvanceAmount){
        list<Booking__c> bkListToUpdate = new list<Booking__c>();
        for(string bookingId : bookingIdToAdvanceAmount.keySet()){
            Booking__c b = new Booking__c(Id=bookingId);
            b.Category__c = 'Advance Payments';
            b.Last_Call_Attempt_Date__c = System.now();
            b.Last_Call_Attempt_Status__c = 'Not Pitched';
            b.Last_Call_Description__c = 'Not Pitched';
            b.Due_Advance_Amount__c = bookingIdToAdvanceAmount.get(bookingId);
            b.Last_Call_Attempted_By__c = 'System Automated';
            bkListToUpdate.add(b);
        }
        update bkListToUpdate;
    }

    @AuraEnabled
    public static list<string> getMonthList(){
        list<string> monthList = new list<string>();
        Integer nextYear = system.today().year() + 1;
        Date maxDate = system.today().addMonths(7).toStartofMonth().addDays(-1);
        //Date maxDate = Date.newInstance(nextYear, 12, 31);
        List<Payment_Milestones__c> pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c, 
                                                Quotation__r.Unit__r.Tower__c FROM Payment_Milestones__c WHERE 
                                                Quotation__c != null AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Milestone_Due_Date__c != null AND 
                                                (Milestone_Due_Date__c > TODAY AND Milestone_Due_Date__c <= :maxDate) 
                                                AND Quotation__r.Unit__c != null ORDER BY Milestone_Due_Date__c ASC];
        map<integer,string> monthNumberToMonthName = new map<integer,string>();
        monthNumberToMonthName.put(1,'JAN');
        monthNumberToMonthName.put(2,'FEB');
        monthNumberToMonthName.put(3,'MAR');
        monthNumberToMonthName.put(4,'APR');
        monthNumberToMonthName.put(5,'MAY');
        monthNumberToMonthName.put(6,'JUN');
        monthNumberToMonthName.put(7,'JUL');
        monthNumberToMonthName.put(8,'AUG');
        monthNumberToMonthName.put(9,'SEP');
        monthNumberToMonthName.put(10,'OCT');
        monthNumberToMonthName.put(11,'NOV');
        monthNumberToMonthName.put(12,'DEC');
        for(Payment_Milestones__c p : pmList){
            Date dueDate = p.Milestone_Due_Date__c;
            string str = monthNumberToMonthName.get(dueDate.month()) + ' ' + string.valueOf(dueDate.year());
            if(!monthList.contains(str))
                monthList.add(str);
        }
        return monthList;
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getTowerData(string towerId){
        map<string,ExecutiveCategoryData> towerDataMap = new map<string,ExecutiveCategoryData>();
        map<string,ExecutiveCategoryData> tempDataMap = new map<string,ExecutiveCategoryData>();
        list<string> monthList = new list<string>();
        Integer nextYear = system.today().year() + 1;
        Date maxDate = system.today().addMonths(7).toStartofMonth().addDays(-1);
        List<Payment_Milestones__c> pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c,
                                        Quotation__r.Unit__r.Tower__c FROM Payment_Milestones__c WHERE 
                                        Quotation__c != null AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Milestone_Due_Date__c != null AND 
                                        (Milestone_Due_Date__c > TODAY AND Milestone_Due_Date__c <= :maxDate) 
                                        AND Quotation__r.Unit__c != null ORDER BY Milestone_Due_Date__c ASC];
            
        map<string,long> projectToFutureDues = new map<string,long>();
        map<string,list<long>> projectToFutureDueList = new map<string,list<long>>();
        List<Id> pmIdsList = new List<Id>();
        for(Payment_Milestones__c p : pmList){
            Date dueDate = p.Milestone_Due_Date__c;
            string str = string.valueOf(dueDate.month()) + '-' + string.valueOf(dueDate.year());
            if(!monthList.contains(str))
                monthList.add(str);
            string pId = p.Quotation__r.Unit__r.Tower__c + '##' + str;
            if(projectToFutureDues.containsKey(pId)){
                long dueAmt = projectToFutureDues.get(pId);
                dueAmt = (p.Total_Installment_New__c != null)?(dueAmt + (long)p.Total_Installment_New__c):dueAmt; 
                projectToFutureDues.put(pId, dueAmt);
            }
            else{
                long dueAmt = (p.Total_Installment_New__c != null)?(long)p.Total_Installment_New__c:0;
                projectToFutureDues.put(pId, dueAmt);
            }
            pmIdsList.add(p.Id);
        }
        map<string,long> projectToFutureDuesNew = new map<string,long>();
        set<string> keyList = projectToFutureDues.keySet();
        for(string pId : projectToFutureDues.keySet()){
            string actualPId = pId.split('##')[0];
            string tmp = pId.split('##')[1];
            integer mon = Integer.valueOf(tmp.split('-')[0]);
            integer yer = Integer.valueOf(tmp.split('-')[1]);
            Date yr = Date.newInstance(yer, mon, 1);
            for(string str : monthList){
                string key = actualPId+'##'+str;
                integer mon1 = Integer.valueOf(str.split('-')[0]);
                integer yer1 = Integer.valueOf(str.split('-')[1]);
                Date yrr = Date.newInstance(yer1, mon1, 1);
                if((yrr <= yr)){
                    if(!keyList.contains(key)){
                        if(!projectToFutureDuesNew.containsKey(key))
                            projectToFutureDuesNew.put(key, 0);
                    }
                    if(yrr == yr) break;
                }
            }
            projectToFutureDuesNew.put(pId,projectToFutureDues.get(pId));
        }
        createAdvancePaymentRecordsBatch.AdvancePaidWrapper advancePaidTillDate = createAdvancePaymentRecordsBatch.calculateAdvancePayment(pmIdsList, 'Tower');
        Map<Id,Map<String,Map<String,Decimal>>> towerAdvancePaymentMonthMap = advancePaidTillDate.towerAdvancePaymentMonthMap;
        if(towerAdvancePaymentMonthMap.size() > 0){
            for(Id towrId : towerAdvancePaymentMonthMap.keySet()){
                for(String yearOfPayment : towerAdvancePaymentMonthMap.get(towrId).keySet()){
                    for(String monthOfPayment : towerAdvancePaymentMonthMap.get(towrId).get(yearOfPayment).keySet()){
                        String monthString = '';
                        switch on monthOfPayment{
                            when 'JAN' { monthString = '1';}
                            when 'FEB' { monthString = '2';}
                            when 'MAR' { monthString = '3';}
                            when 'APR' { monthString = '4';}
                            when 'MAY' { monthString = '5';}
                            when 'JUN' { monthString = '6';}
                            when 'JUL' { monthString = '7';}
                            when 'AUG' { monthString = '8';}
                            when 'SEP' { monthString = '9';}
                            when 'OCT' { monthString = '10';}
                            when 'NOV' { monthString = '11';}
                            when 'DEC' { monthString = '12';}
                            when else { }
                        }
                        string str = monthString + '-' +yearOfPayment;
                        if(monthList.contains(str)){
                            string pId = towrId + '##' + str;
                            long dueAmount = projectToFutureDuesNew.get(pId);
                            if(projectToFutureDuesNew.get(pId) != null){
                                long differenceAmount = dueAmount - (long)towerAdvancePaymentMonthMap.get(towrId).get(yearOfPayment).get(monthOfPayment);
                                projectToFutureDuesNew.put(pId,differenceAmount);
                            }
                        }
                    }
                }
            }
        }

        for(string pId : projectToFutureDuesNew.keySet()){
            string actualPId = pId.split('##')[0];
            if(projectToFutureDueList.containsKey(actualPId)){
                list<long> dueList = projectToFutureDueList.get(actualPId);
                dueList.add(projectToFutureDuesNew.get(pId));
                projectToFutureDueList.put(actualPId,dueList);
            }
            else{
                projectToFutureDueList.put(actualPId, new list<long>{projectToFutureDuesNew.get(pId)});
            }
        }

        List<Booking__c> bookings = new List<Booking__c>();
        if(towerId == 'All'){
            bookings = [SELECT Id, Unit__r.Tower__c, Unit__r.Tower__r.Name, Last_Call_Attempt_Status__c,Agreement_Value__c, Total_Agreement_Value_Demanded__c, Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, 
            Due_Payments__c, Advance_Payments__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Booking__c WHERE Unit__r.Tower__c != null and Status__c != 'Cancelled' and Current_Status__c = 'Audit Accepted' and (NOT Unit__r.Tower__r.Name LIKE '%UnderWriting%')];
        }
        else {
            bookings = [SELECT Id, Unit__r.Tower__c, Unit__r.Tower__r.Name, Last_Call_Attempt_Status__c,Agreement_Value__c, Total_Agreement_Value_Demanded__c, Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, 
            Due_Payments__c, Advance_Payments__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Booking__c WHERE Unit__r.Tower__c != null and Unit__r.Tower__c =: towerId and Status__c != 'Cancelled' and Current_Status__c = 'Audit Accepted'];
        }

        for(Booking__c b : bookings){
            if(towerDataMap.containsKey(b.Unit__r.Tower__c)){
                ExecutiveCategoryData d = towerDataMap.get(b.Unit__r.Tower__c);
                d.categoryCount = d.categoryCount + 1;
                d.saleValue = (b.Agreement_Value__c!=null)?(d.saleValue + (Long)b.Agreement_Value__c):d.saleValue;
                d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)b.Total_On_Account_Money_With_Registration__c):d.collected;
                d.due = (b.Due_Payments__c!=null)?(d.due + (Long)b.Due_Payments__c):d.due;
                towerDataMap.put(b.Unit__r.Tower__c, d);
            }
            else {
                ExecutiveCategoryData d = new ExecutiveCategoryData();
                d.towerId = b.Unit__r.Tower__c;
                d.towerName = b.Unit__r.Tower__r.Name;
                d.categoryCount = 1;
                d.saleValue = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                d.due = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                towerDataMap.put(b.Unit__r.Tower__c, d);
            }
        }        
        for(string tId : towerDataMap.keySet()){
            ExecutiveCategoryData ecd = towerDataMap.get(tId);
            if(projectToFutureDueList.containsKey(tId)){
                ecd.futureMonthlyDues = projectToFutureDueList.get(tId);
            }
            else{
                list<long> tmpFutureDues = new list<long>();
                for(string str : monthList){
                    tmpFutureDues.add(0);
                }
                ecd.futureMonthlyDues = tmpFutureDues;
            }
            integer s = ecd.futureMonthlyDues.size();
            for(integer i=s; i<monthList.size(); i++){
                ecd.futureMonthlyDues.add(0);
            }
            tempDataMap.put(tId,ecd);
        }
        return tempDataMap.values();
    }

    @AuraEnabled
    public static List<ExecutiveTargetData> getTargetData(){
        List<ExecutiveTargetData> data = new List<ExecutiveTargetData>();
        map<string,ExecutiveTargetData> targetDataMap = new map<string,ExecutiveTargetData>();
        List<Receipt__c> receipts = new List<Receipt__c>();
        receipts = [SELECT Id,GL_Date__c,Total_Amount__c, Registration_Collection_Control_Report__c,Booking__r.Unit__r.Tower__r.Name,Booking__r.Unit__r.Tower__c,Booking__r.Unit__r.Tower__r.Target__c FROM Receipt__c WHERE Booking__c != null and Booking__r.Unit__c != null and Booking__r.Unit__r.Tower__c != null and GL_Date__c = THIS_MONTH and Receipt_Status__c = 'Cleared' and Booking__r.Paid_Percentage__c >= 10];
        for(Receipt__c r : receipts){
            if(targetDataMap.containsKey(r.Booking__r.Unit__r.Tower__c)){
                ExecutiveTargetData exeData = targetDataMap.get(r.Booking__r.Unit__r.Tower__c);
                long regCollControlRep = (long)(r.Registration_Collection_Control_Report__c != null ? r.Registration_Collection_Control_Report__c : 0);
                exeData.achieved = exeData.achieved + (Long) (r.Total_Amount__c - regCollControlRep);
                targetDataMap.put(r.Booking__r.Unit__r.Tower__c, exeData);
            }
            else{
                ExecutiveTargetData exeData = new ExecutiveTargetData();
                exeData.towerId = r.Booking__r.Unit__r.Tower__c;
                exeData.towerName = r.Booking__r.Unit__r.Tower__r.Name;
                exeData.target = (r.Booking__r.Unit__r.Tower__r.Target__c != null)?(Long)r.Booking__r.Unit__r.Tower__r.Target__c:0;
                exeData.achieved = (Long) (r.Total_Amount__c - r.Registration_Collection_Control_Report__c);
                targetDataMap.put(r.Booking__r.Unit__r.Tower__c, exeData);
            }
        }
        map<string,ExecutiveTargetData> finalTargetDataMap = new map<string,ExecutiveTargetData>();
        Long totalTarget = 0;
        Long totalAcheived = 0;
        for(string tower : targetDataMap.keySet()){
            ExecutiveTargetData exeData = targetDataMap.get(tower);
            Decimal totalAcheivedD = (Decimal)exeData.achieved;
            Decimal totalTargetD = (Decimal)exeData.target;
            Decimal achievedPercentage = 0;
            if(totalTargetD != 0 && totalTargetD != null)
                achievedPercentage = totalAcheivedD.divide(totalTargetD, 2);
            exeData.achievedPercentage = achievedPercentage;
            finalTargetDataMap.put(tower, exeData);
            totalAcheived = totalAcheived + exeData.achieved;
        }
        List<Tower__c> towers = [SELECT Id,Name,Target__c FROM Tower__c];
        for(Tower__c t : towers){
            if(t.Target__c != null){
                totalTarget = totalTarget + (Long)t.Target__c;
            }
        }
        Decimal totalAcheivedD = (Decimal)totalAcheived;
        Decimal totalTargetD = (Decimal)totalTarget;
        Decimal totalAchievedPercentage = 0;
        if(totalTargetD != 0 && totalTargetD != null)
            totalAchievedPercentage = totalAcheivedD.divide(totalTargetD, 2);
        ExecutiveTargetData exeDataAll = new ExecutiveTargetData();
        exeDataAll.towerId = 'All';
        exeDataAll.towerName = 'All';
        exeDataAll.target = totalTarget;
        exeDataAll.achieved = totalAcheived;
        exeDataAll.achievedPercentage = totalAchievedPercentage;
        finalTargetDataMap.put('All', exeDataAll);

        map<string,ExecutiveTargetData> dataMap = new map<string,ExecutiveTargetData>();
        for(Tower__c t : towers){
            if(finalTargetDataMap.containsKey(t.Id)){
                dataMap.put(t.Id,finalTargetDataMap.get(t.Id));
            }
            else{
                ExecutiveTargetData ob = new ExecutiveTargetData();
                ob.target = (t.Target__c != null)?(Long)t.Target__c : 0;
                ob.achieved = 0;
                ob.achievedPercentage = 0;
                ob.towerId = t.Id;
                ob.towerName = t.Name;
                dataMap.put(t.Id,ob);
            }
        }
        dataMap.put('All', exeDataAll);

        return dataMap.values();
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getCategoryData(string towerId){
        map<string,ExecutiveCategoryData> categorytDataMap = new map<string,ExecutiveCategoryData>();
        ExecutiveCategoryData serviced = new ExecutiveCategoryData();
        serviced.fontWeight = 'font-weight: bold';
        serviced.category = 'Serviced';
        categorytDataMap.put('Serviced',serviced);
        ExecutiveCategoryData unserviced = new ExecutiveCategoryData();
        unserviced.fontWeight = 'font-weight: bold';
        unserviced.category = 'Unserved';
        categorytDataMap.put('Unserved',unserviced);
        ExecutiveCategoryData grandTotal = new ExecutiveCategoryData();
        grandTotal.fontWeight = 'font-weight: bold';
        grandTotal.category = 'Grand Total';
        categorytDataMap.put('Grand Total',grandTotal);
        List<Booking__c> bookings = new List<Booking__c>();
        if(towerId == 'All'){
            bookings = [SELECT Id, Unit__r.Tower__c, Unit__r.Tower__r.Name, Last_Call_Attempt_Status__c,Agreement_Value__c, Total_Agreement_Value_Demanded__c, Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, Due_Payments__c, Advance_Payments__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Booking__c WHERE Status__c != 'Cancelled' and Current_Status__c = 'Audit Accepted'];
        }
        else {
            bookings = [SELECT Id, Unit__r.Tower__c, Unit__r.Tower__r.Name, Last_Call_Attempt_Status__c,Agreement_Value__c, Total_Agreement_Value_Demanded__c, Total_On_Account_Money_With_Registration__c, Milestone_Due_Till_Date__c, Due_Payments__c, Advance_Payments__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Booking__c WHERE Unit__r.Tower__c =: towerId and Status__c != 'Cancelled' and Current_Status__c = 'Audit Accepted'];
        }

        for(Booking__c b : bookings){
            if(b.Last_Call_Attempt_Status__c != null){
                if(categorytDataMap.containsKey(b.Last_Call_Attempt_Status__c)){
                    ExecutiveCategoryData d = categorytDataMap.get(b.Last_Call_Attempt_Status__c);
                    d.categoryCount = d.categoryCount + 1;
                    d.saleValue = (b.Agreement_Value__c!=null)?(d.saleValue + (Long)b.Agreement_Value__c):d.saleValue;
                    d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)b.Total_On_Account_Money_With_Registration__c):d.collected;
                    d.due = (b.Due_Payments__c!=null)?(d.due + (Long)b.Due_Payments__c):d.due;
                    categorytDataMap.put(b.Last_Call_Attempt_Status__c, d);
                }
                else {
                    ExecutiveCategoryData d = new ExecutiveCategoryData();
                    d.fontWeight = 'font-weight: normal';
                    d.towerId = b.Unit__r.Tower__c;
                    d.towerName = b.Unit__r.Tower__r.Name;
                    d.category = b.Last_Call_Attempt_Status__c;
                    d.categoryCount = 1;
                    d.saleValue = (b.Agreement_Value__c!=null)?(Long)b.Agreement_Value__c:0;
                    d.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(Long)b.Total_On_Account_Money_With_Registration__c:0;
                    d.due = (b.Due_Payments__c!=null)?(Long)b.Due_Payments__c:0;
                    categorytDataMap.put(b.Last_Call_Attempt_Status__c, d);
                }
                ExecutiveCategoryData served = categorytDataMap.get('Serviced');
                served.categoryCount = served.categoryCount + 1;
                served.saleValue = (b.Agreement_Value__c!=null)?(served.saleValue + (Long)b.Agreement_Value__c):served.saleValue;
                served.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(served.collected + (Long)b.Total_On_Account_Money_With_Registration__c):served.collected;
                served.due = (b.Due_Payments__c!=null)?(served.due + (Long)b.Due_Payments__c):served.due;
                categorytDataMap.put('Serviced', served);
            }
            else{
                ExecutiveCategoryData unserved = categorytDataMap.get('Unserved');
                unserved.categoryCount = unserved.categoryCount + 1;
                unserved.saleValue = (b.Agreement_Value__c!=null)?(unserved.saleValue + (Long)b.Agreement_Value__c):unserved.saleValue;
                unserved.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(unserved.collected + (Long)b.Total_On_Account_Money_With_Registration__c):unserved.collected;
                unserved.due = (b.Due_Payments__c!=null)?(unserved.due + (Long)b.Due_Payments__c):unserved.due;
                categorytDataMap.put('Unserved', unserved);
            }
            ExecutiveCategoryData total = categorytDataMap.get('Grand Total');
            total.categoryCount = total.categoryCount + 1;
            total.saleValue = (b.Agreement_Value__c!=null)?(total.saleValue + (Long)b.Agreement_Value__c):total.saleValue;
            total.collected = (b.Total_On_Account_Money_With_Registration__c!=null)?(total.collected + (Long)b.Total_On_Account_Money_With_Registration__c):total.collected;
            total.due = (b.Due_Payments__c!=null)?(total.due + (Long)b.Due_Payments__c):total.due;
            categorytDataMap.put('Grand Total', total);
        }
        map<string,ExecutiveCategoryData> categorytDataMapTemp = new map<string,ExecutiveCategoryData>();
        categorytDataMapTemp.put('Serviced',categorytDataMap.get('Serviced'));
        for(string str : categorytDataMap.keySet()){
            if(str != 'Serviced' && str != 'Unserved' && str != 'Grand Total'){
                categorytDataMapTemp.put(str,categorytDataMap.get(str));
            }
        }
        categorytDataMapTemp.put('Unserved',categorytDataMap.get('Unserved'));
        categorytDataMapTemp.put('Grand Total',categorytDataMap.get('Grand Total'));
        return categorytDataMapTemp.values();
    }

    @AuraEnabled
    public static List<ExecutiveCategoryData> getAgeingData(string towerId){
        map<string,ExecutiveCategoryData> categorytDataMap = new map<string,ExecutiveCategoryData>();
        list<Payment_Milestones__c> pmList = new list<Payment_Milestones__c>();
        map<string, list<Payment_Milestones__c>> bookingToPM = new map<string, list<Payment_Milestones__c>>();
        if(towerId == 'All'){
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c ,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c
                      FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }
        else{
            pmList = [SELECT id,Milestone_Due_Date__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c, Quotation__c, Quotation__r.Booking__c ,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c
                      FROM Payment_Milestones__c 
                      WHERE Quotation__r.Booking__r.Status__c != 'Cancelled' AND 
                      Quotation__r.Booking__r.Current_Status__c = 'Audit Accepted' AND 
                      Quotation__c != null AND Milestone_Due_Date__c != null AND 
                      Milestone_Due_Date__c <= TODAY 
                      AND Quotation__r.Unit__r.Tower__c =: towerId 
                      AND Quotation__r.Booking__c != null 
                      ORDER BY Milestone_Due_Date__c ASC];
        }
        
        for(Payment_Milestones__c pm : pmList){
            if(bookingToPM.containsKey(pm.Quotation__r.Booking__c)){
                list<Payment_Milestones__c> pms = bookingToPM.get(pm.Quotation__r.Booking__c);
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
            else{
                list<Payment_Milestones__c> pms = new list<Payment_Milestones__c>();
                pms.add(pm);
                bookingToPM.put(pm.Quotation__r.Booking__c,pms);
            }
        }

        map<string,Booking__c> bookingIdToBooking = new map<string,Booking__c>();
        for(Booking__c b : [SELECT id,PrimaryMobileNumber__c,Last_Call_Attempt_Status__c,Full_Due__c,Unit__r.Tower__c,
                            Pre_Registration_Status__c,Booking_Date__c,Last_Call_Description__c,Unit__r.Tower__r.Name,
                            Opportunity__c,Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,
                            Name,Unit__c,Unit__r.Name,Unit__r.Tower__r.Due_Payments__c,Unit__r.Tower__r.Advance_Payments__c,
                            Primary_Applicant_Name__c,Agreement_Value__c,Total_Agreement_Value_Demanded__c,Due_Payments__c,
                            Total_On_Account_Money_With_Registration__c,Unit__r.Tower__r.ByPass_Unit_Cancellation__c FROM Booking__c WHERE Id IN: bookingToPM.keySet()]){
            bookingIdToBooking.put(b.id,b);
        }

        for(string booking : bookingToPM.keySet()){
            Booking__c bk = bookingIdToBooking.get(booking);
            Integer diffDays = 0;
            long sum = 0;
        	Boolean milestoneHit = false;
            String ageingColor = '';
            if(bookingToPM.containsKey(booking)){
                for(Payment_Milestones__c pm : bookingToPM.get(booking)){
                    sum = sum + (long)pm.Total_Installment_New__c;
                    if (sum > (long)bk.Total_On_Account_Money_With_Registration__c && !milestoneHit) {
                        Date milestoneDate = pm.Milestone_Due_Date__c;
                        Date startDate = Date.today();
                        Date endDate = milestoneDate;
                        diffDays = endDate.daysBetween(startDate);
                        milestoneHit = true;
                    }
                }
            }
            if (diffDays <= 30) {
                ageingColor = 'Green';                        
            } else if (diffDays > 30 && diffDays <= 60) {
                ageingColor = 'Yellow';  
            } else if (diffDays > 60 && diffDays <= 90) {
                ageingColor = 'Amber';  
            } else if(diffDays > 90){
                ageingColor = 'Red';  
            }
            if(categorytDataMap.containsKey(ageingColor)){
                ExecutiveCategoryData d = categorytDataMap.get(ageingColor);
                d.categoryCount = d.categoryCount + 1;
                d.saleValue = (bk.Agreement_Value__c!=null)?(d.saleValue + (Long)bk.Agreement_Value__c):d.saleValue;
                d.collected = (bk.Total_On_Account_Money_With_Registration__c!=null)?(d.collected + (Long)bk.Total_On_Account_Money_With_Registration__c):d.collected;
                d.due = (bk.Due_Payments__c!=null)?(d.due + (Long)bk.Due_Payments__c):d.due;
                categorytDataMap.put(ageingColor, d);
            }
            else {
                ExecutiveCategoryData d = new ExecutiveCategoryData();
                d.towerId = bk.Unit__r.Tower__c;
                d.towerName = bk.Unit__r.Tower__r.Name;
                d.category = ageingColor;
                d.categoryCount = 1;
                d.saleValue = (bk.Agreement_Value__c!=null)?(Long)bk.Agreement_Value__c:0;
                d.collected = (bk.Total_On_Account_Money_With_Registration__c!=null)?(Long)bk.Total_On_Account_Money_With_Registration__c:0;
                d.due = (bk.Due_Payments__c!=null)?(Long)bk.Due_Payments__c:0;
                categorytDataMap.put(ageingColor, d);
            }
        }
        map<string,ExecutiveCategoryData> categorytDataMapTemp = new map<string,ExecutiveCategoryData>();
        if(categorytDataMap.containsKey('Green'))
            categorytDataMapTemp.put('Green (< 30 Days)', categorytDataMap.get('Green'));
        if(categorytDataMap.containsKey('Yellow'))
            categorytDataMapTemp.put('Yellow (31-60 Days)', categorytDataMap.get('Yellow'));
        if(categorytDataMap.containsKey('Amber'))
            categorytDataMapTemp.put('Amber (61-90 Days)', categorytDataMap.get('Amber'));
        if(categorytDataMap.containsKey('Red'))
            categorytDataMapTemp.put('Red (> 91 Days)', categorytDataMap.get('Red'));

        categorytDataMap = new map<string,ExecutiveCategoryData>();

        for(string key : categorytDataMapTemp.keySet()){
            ExecutiveCategoryData ecd = categorytDataMapTemp.get(key);
            ecd.category = key;
            categorytDataMap.put(key, ecd);
        }
        return categorytDataMap.values();
    }

    @AuraEnabled
    public static PaymentMilestoneWrapper getYearWisePaymentMilestones(String type){
        try {
            Integer nextYear = system.today().year() + 1;
            Date maxDate = Date.newInstance(nextYear, 12, 31);
            Map<Id,Map<String,Decimal>> unitPaymentMilestoneYearMap = new Map<Id,Map<String,Decimal>>();
            Map<Id,Map<String,Decimal>> towerPaymentMilestoneYearMap = new Map<Id,Map<String,Decimal>>();
            Map<Id,Map<String,Decimal>> subProjectPaymentMilestoneYearMap = new Map<Id,Map<String,Decimal>>();
            Map<Id,Map<String,Decimal>> projectPaymentMilestoneYearMap = new Map<Id,Map<String,Decimal>>();
            
            for(Payment_Milestones__c pmRec : [SELECT id,Milestone_Due_Date__c, Quotation__r.Unit__r.Tower__c,Quotation__r.Unit__r.Project__c, Quotation__r.Unit__r.Tower__r.Cluster__c,Total_Installment__c,Total_Installment_New__c,Total_Installment_Tax__c,Quotation__r.Booking__r.Unit__r.Tower__r.ByPass_Unit_Cancellation__c  FROM Payment_Milestones__c WHERE 
                                                    Quotation__c != null AND Quotation__r.Booking__c != null AND Quotation__r.Booking__r.Status__c = 'Processed' AND Milestone_Due_Date__c != null AND 
                                                    (Milestone_Due_Date__c > TODAY AND Milestone_Due_Date__c <= :maxDate) 
                                                    AND Quotation__r.Unit__c != null ORDER BY Milestone_Due_Date__c ASC]){
                
                String pmYear = String.valueOf(pmRec.Milestone_Due_Date__c.year());
                Decimal unitPmTotal = 0;
                Decimal towerPmTotal = 0;
                Decimal subProjectPmTotal = 0;
                Decimal projectPmTotal = 0;
                if(type == 'SubProject'){
                    //SubProject 
                    if(subProjectPaymentMilestoneYearMap.containsKey(pmRec.Quotation__r.Unit__r.Tower__r.Cluster__c)){
                        if(subProjectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__r.Cluster__c).containsKey(pmYear)){
                            subProjectPmTotal = subProjectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__r.Cluster__c).get(pmYear) + pmRec.Total_Installment_New__c;
                        }
                        else{
                            subProjectPmTotal = pmRec.Total_Installment_New__c;
                        }
                    }
                    else{
                        subProjectPaymentMilestoneYearMap.put(pmRec.Quotation__r.Unit__r.Tower__r.Cluster__c, new Map<String,Decimal>());
                        subProjectPmTotal = pmRec.Total_Installment_New__c;
                    }
                    subProjectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__r.Cluster__c).put(pmYear,subProjectPmTotal);
                } 
                if(type == 'Project'){
                   //Project 
                   if(projectPaymentMilestoneYearMap.containsKey(pmRec.Quotation__r.Unit__r.Project__c)){
                        if(projectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Project__c).containsKey(pmYear)){
                            projectPmTotal = projectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Project__c).get(pmYear) + pmRec.Total_Installment_New__c;
                        }
                        else{
                            projectPmTotal = pmRec.Total_Installment_New__c;
                        }
                    }
                    else{
                        projectPaymentMilestoneYearMap.put(pmRec.Quotation__r.Unit__r.Project__c, new Map<String,Decimal>());
                        projectPmTotal = pmRec.Total_Installment_New__c;
                    }
                    projectPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Project__c).put(pmYear,projectPmTotal);
                }
                if(type == 'Tower'){
                   //Tower 
                   if(towerPaymentMilestoneYearMap.containsKey(pmRec.Quotation__r.Unit__r.Tower__c)){
                        if(towerPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__c).containsKey(pmYear)){
                            towerPmTotal = towerPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__c).get(pmYear) + pmRec.Total_Installment_New__c;
                        }
                        else{
                            towerPmTotal = pmRec.Total_Installment_New__c;
                        }
                    }
                    else{
                        towerPaymentMilestoneYearMap.put(pmRec.Quotation__r.Unit__r.Tower__c, new Map<String,Decimal>());
                        towerPmTotal = pmRec.Total_Installment_New__c;
                    }
                    towerPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__r.Tower__c).put(pmYear,towerPmTotal);
                }
                if(type == 'Unit'){
                    //Unit 
                   if(unitPaymentMilestoneYearMap.containsKey(pmRec.Quotation__r.Unit__c)){
                        if(unitPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__c).containsKey(pmYear)){
                            unitPmTotal = unitPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__c).get(pmYear) + pmRec.Total_Installment_New__c;
                        }
                        else{
                            unitPmTotal = pmRec.Total_Installment_New__c;
                        }
                    }
                    else{
                        unitPaymentMilestoneYearMap.put(pmRec.Quotation__r.Unit__c, new Map<String,Decimal>());
                        unitPmTotal = pmRec.Total_Installment_New__c;
                    }
                    unitPaymentMilestoneYearMap.get(pmRec.Quotation__r.Unit__c).put(pmYear,unitPmTotal);
                }
            }

            PaymentMilestoneWrapper paymentMilestoneWrapper = new PaymentMilestoneWrapper();
            paymentMilestoneWrapper.unitPaymentMilestoneYearMap = unitPaymentMilestoneYearMap;
            paymentMilestoneWrapper.towerPaymentMilestoneYearMap = towerPaymentMilestoneYearMap;
            paymentMilestoneWrapper.subProjectPaymentMilestoneYearMap = subProjectPaymentMilestoneYearMap;
            paymentMilestoneWrapper.projectPaymentMilestoneYearMap = projectPaymentMilestoneYearMap;

            return paymentMilestoneWrapper;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class PaymentMilestoneWrapper{
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> unitPaymentMilestoneYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> towerPaymentMilestoneYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> subProjectPaymentMilestoneYearMap;
        @AuraEnabled
        public Map<Id,Map<String,Decimal>> projectPaymentMilestoneYearMap;
    }

    public class ExecutiveCategoryData {
        @AuraEnabled public string towerId;
        @AuraEnabled public string towerName;
        @AuraEnabled public string category;
        @AuraEnabled public Integer categoryCount;
        @AuraEnabled public Long saleValue;
        @AuraEnabled public Long collected;
        @AuraEnabled public Long due;
        @AuraEnabled public string fontWeight;
        @AuraEnabled public list<long> futureMonthlyDues;
        
        ExecutiveCategoryData(){
            towerId = '';
            towerName = '';
            category = '';
            categoryCount = 0;
            saleValue = 0;
            collected = 0;
            due = 0;
            fontWeight = '';
            futureMonthlyDues = new list<long>();
        }
    }

    public class ExecutiveTargetData {
        @AuraEnabled public string towerId;
        @AuraEnabled public string towerName;
        @AuraEnabled public long target;
        @AuraEnabled public long achieved;
        @AuraEnabled public Decimal achievedPercentage;
        public ExecutiveTargetData(){
            towerId = '';
            towerName = '';
            target = 0;
            achieved = 0;
            achievedPercentage = 0;
        }
    }
    
    public class BookingWrapper implements Comparable {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingIdVal;
        @AuraEnabled public string customerName;
        @AuraEnabled public long saleValue;
        @AuraEnabled public long demands;
        @AuraEnabled public long milestoneDue;
        @AuraEnabled public boolean ByPass_Unit_Cancellation;
        @AuraEnabled public long collected;
        @AuraEnabled public long due;
        @AuraEnabled public long fullDue;
        @AuraEnabled public string category;
        @AuraEnabled public string commentsHistory;
        @AuraEnabled public string soaLink;
        @AuraEnabled public string registrationStatus;
        @AuraEnabled public string bookingDate;
        @AuraEnabled public string bucketColor;
        @AuraEnabled public string lastCallAttemptStatus;
        @AuraEnabled public string primaryMobileNumber;
        @AuraEnabled public integer age;
        
        public BookingWrapper(){
            unitName = '';
            unitId = '';
            bookingName = '';
            bookingId = '';
            bookingIdVal = '';
            customerName = '';
            saleValue = 0;
            demands = 0;
            milestoneDue = 0;
            collected = 0;
            due = 0;
            fullDue = 0;
            category = '';
            commentsHistory = '';
            soaLink = '';
            registrationStatus = '';
            bookingDate = '';
            bucketColor = '';
            lastCallAttemptStatus = '';
        }
        
        public Integer compareTo(Object objToCompare) {
            if(category == 'Advance Payments')
                return Integer.valueOf(((BookingWrapper)objToCompare).fullDue - fullDue);
            else
                return Integer.valueOf(((BookingWrapper)objToCompare).due - due);
        }
    }
    
    public static void getColorCode(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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