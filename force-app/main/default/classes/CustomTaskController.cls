public class CustomTaskController {
    //@InvocableVariable(label='Id' required=true)
    public static Id Idtask;
    public Task__c taskData {get;set;}
    /*public CustomTaskController(){
        
        system.debug('constructor:'+ApexPages.currentPage().getParameters().get('id'));
        Idtask = ApexPages.currentPage().getParameters().get('id');
        taskData = new Task__c();
        
        
    }*/
    @InvocableMethod(label='Send Email from Task')
    public static void sendEmail(List<Id> taskId) {
        
    Idtask =  taskId[0];
        system.debug('CustomTaskController'+taskId);
        
        Task__c taskData = [SELECT Amount_To_Be_Paid_After_Discount__c, Amount_To_Be_Paid_In_Advance__c,Bank_Name__c,Booking__c,
                    Booking_Balance__c,Booking_Project__c,Booking_Sale_Value__c,Booking_Unit__c,
                    Discount_Amount__c, Expected_Date_Of_The_Payment__c,Category__c,
                            Booking_Project__r.Name,Booking_Unit__r.Name,Booking__r.Primary_Applicant_Email__c,
                            Booking__r.Project__r.Name,Booking__r.Unit__r.name,Booking__r.Primary_Applicant_Name__c,
                            Booking__r.Agreement_Value__c,Booking__r.Total_On_Account_Money__c
                    FROM Task__c 
                    WHERE id =: taskId[0] 
                    LIMIT 1];
        
        system.debug('taskData'+taskData);
        
        EmailTemplate e = [select id, HtmlValue, subject from EmailTemplate where DeveloperName ='Send_Email_From_Task'];
        string body = e.HtmlValue;
        body = body.replace('#customer#', taskData.Booking__r.Primary_Applicant_Name__c);
        body = body.replace('#Unit#', taskData.Booking__r.Unit__r.name);
        body = body.replace('#SaleValue#', String.valueOf(taskData.Booking__r.Agreement_Value__c.format()));
        body = body.replace('#AmountToBePaidInAdvance#',String.valueOf(taskData.Amount_To_Be_Paid_In_Advance__c.format()));
        body = body.replace('#DiscountAmount#', String.valueOf(taskData.Discount_Amount__c.format()));
        body = body.replace('#AmountAfterDiscount#', String.valueOf(taskData.Amount_To_Be_Paid_After_Discount__c.format()));
        date myDate = date.newInstance(taskData.Expected_Date_Of_The_Payment__c.year(),taskData.Expected_Date_Of_The_Payment__c.month(),taskData.Expected_Date_Of_The_Payment__c.day());
		String dayString = myDate.format();
        body = body.replace('#ExpectedDate#', dayString);
        body = body.replace('#PaidTillDate#', String.valueOf(taskData.Booking__r.Total_On_Account_Money__c.format()));
             
        string subject = e.subject;
        subject = subject.replace('#Unit#', taskData.Booking__r.Unit__r.name);
        subject = subject.replace('#project#', taskData.Booking__r.Project__r.Name);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setSubject(subject); 
        mail.setHtmlBody(body);
        list<string> toaddress = new List<string>();
         //SOB-336 start
         String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(taskData.Booking__c);
         if(!string.isblank(emailAddressFromBooking)){
             for(String s : emailAddressFromBooking.split(',')){
                 if(!s.containsIgnoreCase('null')){
                    toaddress.add(s);
                 }
             }
         }
        //SOB-336 end
        toaddress.add(taskData.Booking__r.Primary_Applicant_Email__c);
        list<string> ccAddress = new list<string>();
        ccAddress.add(System.label.SobhaHelpdesk);
        mail.setToAddresses(toaddress);
        mail.setCcAddresses(ccAddress);
        mail.setSaveAsActivity(false); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

}