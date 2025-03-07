global class SendEmailOnBookingFormNew Implements Schedulable {
    
    
    global void execute(SchedulableContext sc)
    {
        insertBookings();   
    }
    
    public void insertBookings() {
        
      
        Shoba_Default_Settings__mdt sobhaSettings = [SELECT booking_cancellation_days__c FROM Shoba_Default_Settings__mdt 
                                                     WHERE QualifiedApiName = 'Org_Defaults'
                                                     LIMIT 1];
        List<opportunity> oppUpdate = new List<opportunity>();
        List<ID> unitIdList = new List<Id>();
        List<Id> oppIdList = new List<ID>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<unit__c> unitUpdate = new List<Unit__c>();
        List<String> invalidEmails = new List<String>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        DateTime myDateTime = DateTime.newInstance(2022, 6, 1, 0, 0, 0);
        Integer cancellationDays = Integer.valueOf(sobhaSettings.booking_cancellation_days__c);
        Datetime condieredDate = System.today().addDays((-1)*cancellationDays);
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        list<string> reprocessBookingCancelList = new list<string>();
        String reprocessBookingCancel = System.Label.Reprocess_Booking_Cancellation;
        reprocessBookingCancelList.addAll(reprocessBookingCancel.split(','));
        
        if(Test.isRunningTest()){
            reprocessBookingCancelList.clear();
            Booking__c b = [select Id,Name from Booking__c limit 1];
            reprocessBookingCancelList.add(b.Name);
        }
        
        Date consideredDate1 = Date.newInstance(condieredDate.year(), condieredDate.month(), condieredDate.day());
        Datetime condieredDate2 = consideredDate1.addDays(1);
        List<Booking__c> bookingList = new List<Booking__c>();
        bookingList = [SELECT ID,STATUS__C,opportunity__r.StageName,opportunity__r.Unit__c,unit__r.Booking__c,
                       Unit__r.Unit_Status__c,Signed_Status__c,Unit__c,Tower__c,Project__c,Primary_Applicant_Name__c,
                       OwnerId,Primary_Applicant_Email__c,Sales_Head__c,Secondary_Sales_Manager_VP__c,Sales_Head__r.ManagerId,Sales_Head__r.Manager.Email,Secondary_Sales_Head__r.ManagerId,Secondary_Sales_Head__r.Manager.Email,
                       Secondary_Sales_Manager_VP__r.email,Sales_Head__r.email,Unit__r.Name,Project__r.Name,Sales_Managers__r.email,Secondary_Sales_Manager__r.email,
                       unit__r.Customers__c,Booking_Date__c,Secondary_Sales_Head__r.email
                       FROM Booking__c 
                       WHERE Name IN : reprocessBookingCancelList];

        if(bookingList.size()>0){
            //SOB-336 start
            Map<Id,String> mapOfBookingToAddress = new Map<Id,String>();
            for(Booking__c booking: [SELECT Id,(Select Name, Email_Address__c from ApplicantDetails__r where Applicant_Number__c != 'Primary Applicant') FROM Booking__c WHERE ID IN :bookingList]){
                for(Applicant_Details__c applicantDetails : booking.ApplicantDetails__r){
                    if(!mapOfBookingToAddress.containsKey(booking.id)){
                        mapOfBookingToAddress.put(booking.id,applicantDetails.Email_Address__c);
                    }else{
                        mapOfBookingToAddress.put(booking.id, mapOfBookingToAddress.get(booking.id)+','+applicantDetails.Email_Address__c);
                    }
                    
                }
            
            }
            ////SOB-336 end
            for(Booking__c booking1 : bookingList){
                
                
                if((booking1.Signed_Status__c == null || booking1.Signed_Status__c == '') && booking1.Status__c =='UnProcessed' && booking1.Booking_Date__c >= myDateTime){
                    oppIdList.add(booking1.Opportunity__c);
                    unitIdList.add(booking1.Unit__c);
                    booking1.Status__c = 'Cancelled';
                    //booking1.Unit__c=null;
                    //booking1.Opportunity__c=null;
                    booking1.Cancellation_Date__c = System.now();
                    bookList.add(booking1);
                    
                    //user u = [select id,email from User where id =: booking1.ownerId];    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                    email.setSubject('Cancellation Notice ' +booking1.Unit__r.Name+' '+booking1.Tower__c+' '+booking1.Project__r.Name);
                    List <String> lststringtoaddress = new List<String>();
                    List <String> lstStringccaddress = new List <String>();
                    List <String> lstStringbccaddress = new List <String>();
                    
                    String body =  'Dear ' + booking1.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'We refer to the unit '+booking1.Unit__r.Name+','+' Sobha Hartland – '+booking1.Tower__c+'.<br/><br/>'+
                        'Since we have not received signed booking form for unit blocked, the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                        'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts, or any other marketing material.<br/><br/>'+
                        'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses, and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                        'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on helpdesk@sobharealty.com if you have any questions.<br/><br/>'+
                        'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha LLC';    
                    //if(u.Email != null && u.Email != ''){
                        
                        //lstStringtoaddress.add(u.Email);  
                    //}                   
                    String emailAddressFromBooking = mapOfBookingToAddress.get(booking1.id);
                    if(!string.isBlank(emailAddressFromBooking)){
                        lststringtoaddress.addAll(emailAddressFromBooking.split(','));
                    }
                    if(booking1.Primary_Applicant_Email__c != null && booking1.Primary_Applicant_Email__c != ''){
                        lstStringtoaddress.add(booking1.Primary_Applicant_Email__c);
                    }
                    SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
                    if(booking1.Sales_Head__c != null){
                        lstStringccaddress.add(booking1.Sales_Head__r.email);
                        if(booking1.Sales_Head__r.ManagerId != null)
                        	lstStringccaddress.add(booking1.Sales_Head__r.Manager.Email);
                        SYSTEM.DEBUG('I AM EMAIL'+booking1.sales_Head__r.email);
                    }
                    if(booking1.Secondary_Sales_Head__c!=null && booking1.Secondary_Sales_Head__r.ManagerId != null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Head__r.Manager.Email);
                    }
                    if(booking1.Sales_Managers__c!=null){
                        lstStringccaddress.add(booking1.Sales_Managers__r.email);
                    }
                    if(booking1.Secondary_Sales_Manager__c!=null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Manager__r.email);
                    }
                    if(booking1.Secondary_Sales_Head__c!=null){
                        lstStringccaddress.add(booking1.Secondary_Sales_Head__r.email);
                    }
                    
                    lstStringccaddress.add('salesops@sobharealty.com');
                    List<String> toAddressEmails = new List<String>();
                    for(String toEmail : lststringtoaddress){
                        Matcher MyMatcher = MyPattern.matcher(toEmail);
                        if(!MyMatcher.matches()){
                            invalidEmails.add(toEmail);
                        }else{
                            toAddressEmails.add(toEmail);
                        }
                    }
                    List<String> ccAddressEmails = new List<String>();
                    for(String ccEmail : lstStringccaddress){
                        Matcher MyMatcher = MyPattern.matcher(ccEmail);
                        if(!MyMatcher.matches()){
                            invalidEmails.add(ccEmail);
                        }else{
                            ccAddressEmails.add(ccEmail);
                        }
                    }
                    
                    email.setToAddresses(toAddressEmails);
                    email.setccAddresses(ccAddressEmails);
                    //email.setbccAddresses(lstStringbccaddress);
                    email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');  
                     if(booking1.Primary_Applicant_Email__c != null && booking1.Primary_Applicant_Email__c != ''){
                         if(!toAddressEmails.isEmpty()){
                             emails.add(email);
                         }
                     }
                    system.debug('i am afteremail'+email);
                    }
                }
            }
                if(unitIdList.size() >0 ){
                    
                    List<Unit__c> unitList = [SELECT ID,Unit_Status__c,Booking__c,Customers__c FROM Unit__c Where id IN : unitIdList];
                    for(Unit__c unit:unitList){        
                        unit.Unit_Status__c = 'Available';
                        unit.Booking__c = null;
                        unit.Customers__c = null;
                        unitUpdate.add(unit); 
                        
                    }
                }
                if(oppIdList.size()>0){
                    
                    List<Opportunity> oppList = [SELECT ID,UNIT__C,StageName FROM Opportunity Where id IN:oppIdList];
                    for(Opportunity opp : oppList){
                        opp.Unit__c = null;
                        opp.StageName = 'Cancelled';
                        oppUpdate.add(opp);
                        
                    }
                }
                
               /* for(Booking__c booking : bookingList){
                    DateTime myDateTime = DateTime.newInstance(2022, 6, 1, 0, 0, 0);
                    if((booking.Signed_Status__c == null || booking.Signed_Status__c == '') && booking.Status__c =='UnProcessed' && booking.Booking_Date__c >= myDateTime){
                    user u = [select id,email from User where id =: booking.ownerId];    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
                    email.setSubject('Cancellation Notice ' +booking.Unit__r.Name+' '+booking.Tower__c+' '+booking.Project__r.Name);
                    List <String> lststringtoaddress = new List<String>();
                    List <String> lstStringccaddress = new List <String>();
                    List <String> lstStringbccaddress = new List <String>();
                    
                    String body =  'Dear ' + booking.Primary_Applicant_Name__c+ ',<br/><br/>' +                        
                        
                        'We refer to the unit '+booking.Unit__r.Name+','+' Sobha Hartland – '+booking.Tower__c+'.<br/><br/>'+
                        'Since we have not received signed booking form for unit blocked, the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                        'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts, or any other marketing material.<br/><br/>'+
                        'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses, and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                        'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on helpdesk@sobharealty.com if you have any questions.<br/><br/>'+
                        'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                        
                        'Thanks & Regards,<br/><br/>'+
                        'Sobha LLC';    
                    if(u.Email != null && u.Email != ''){
                        
                        lstStringtoaddress.add(u.Email);  
                    }                   
                    
                    if(booking.Primary_Applicant_Email__c != null && booking.Primary_Applicant_Email__c != ''){
                        lstStringccaddress.add(booking.Primary_Applicant_Email__c);
                    }
                    if(booking.Sales_Head__c != null && booking.Sales_Head__c != ''){
                        lstStringccaddress.add(booking.Sales_Head__r.email);
                    }
                    if(booking.Secondary_Sales_Manager_VP__c != null && booking.Secondary_Sales_Manager_VP__c != ''){
                        lstStringccaddress.add(booking.Secondary_Sales_Manager_VP__r.email);
                    }
                    
                    lstStringccaddress.add('salesops@sobharealty.com');
                    email.setToAddresses(lststringtoaddress);
                    email.setccAddresses(lstStringccaddress);
                    email.setbccAddresses(lstStringbccaddress);
                    email.setHtmlBody('<span style="font-family:Tahoma;font-size:14px;" >'+body+'</span>');  
                    emails.add(email);
                    }
                }*/
        update bookList;
        update unitUpdate;
        update oppUpdate;
        Messaging.sendEmail(emails);  
        if(!invalidEmails.isEmpty()){
            Messaging.SingleEmailMessage invalidEmailMessage = new Messaging.SingleEmailMessage();      
            invalidEmailMessage.setSubject('Invalid customer email in no SBF uploaded booking');
            invalidEmailMessage.setToAddresses(new List<String>{'salesops@sobharealty.com'});
            String body = 'Below bookings didnt get cancelled due to invalid customer email address please take action :- \n';
            for(String email : invalidEmails){
                body = body + email + '\n';
            }
            invalidEmailMessage.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{invalidEmailMessage});  
        }
    }
    
    //@InvocableMethod
    /*public static List<Booking__c> insertBookings(List<Id> bookingId) {

}*/
    
}