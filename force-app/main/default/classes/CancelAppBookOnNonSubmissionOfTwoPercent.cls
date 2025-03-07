global class CancelAppBookOnNonSubmissionOfTwoPercent implements Database.Batchable <sObject>, Schedulable {
    
    global List<PropStrength__Application_Booking__c> start(Database.BatchableContext BC) {
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c> ();
        List<PropStrength__Application_Booking__c> returnBookingList = new List<PropStrength__Application_Booking__c> ();

        bookingList = [SELECT Id, Name, PropStrength__Booking_Date__c, PropStrength__Property__c, House_Unit_No__c, PropStrength__Tower__c, Project_Name__c, 
                        PropStrength__Primary_Applicant_Name__c, PropStrength__Active__c, PropStrength__Total_Paid_Percent__c, No_Cancellation__c, PropStrength__Property__r.Roadshow_Booking__c,
                        PropStrength__Property__r.File_Note__c, Management_Approval__c, PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c,
                        Sales_Head__r.Email, Sales_Head__r.Manager.Email, Sales_Manager__r.Email, 
                        Secondary_Sales_Head__r.Email, Secondary_Sales_Head__r.Manager.Email, Secondary_Sales_Manager__r.Email,
                        (SELECT Id, PropStrength__Type__c, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE ORDER BY PropStrength__Type__c) 
                        FROM PropStrength__Application_Booking__c 
                        WHERE PropStrength__Active__c = TRUE 
                        AND PropStrength__Total_Paid_Percent__c < 2 
                        AND PropStrength__Property__c != null 
                        AND (PropStrength__Property__r.PropStrength__Tower__r.Stop_Auto_Cancelation__c = FALSE OR PropStrength__Project__r.Stop_Auto_Cancelation__c = FALSE)
                        AND No_Cancellation__c = FALSE
                        AND PropStrength__Property__r.Roadshow_Booking__c = FALSE
                        AND PropStrength__Property__r.File_Note__c = FALSE
                        AND Management_Approval__c = FALSE
                        AND (NOT(PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c = 'Employee Reference' OR PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c = 'Management Reference'))];
                        

        if(!bookingList.isEmpty()) {
            for(PropStrength__Application_Booking__c book : bookingList) {
                System.debug(book.PropStrength__Booking_Date__c);
                System.debug(book.PropStrength__Booking_Date__c.daysBetween(System.Today()));
                if(book.PropStrength__Booking_Date__c.daysBetween(System.Today()) > 14) {
                    returnBookingList.add(book);
                }
            }
        }
        return returnBookingList;
    }

    public void execute(SchedulableContext context) {
        CancelAppBookOnNonSubmissionOfTwoPercent batch = new CancelAppBookOnNonSubmissionOfTwoPercent();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> scope) {
        System.debug('Scope::&&&&');
        System.debug(scope);
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        if( !test.isrunningtest())
            owea = [SELECT id from OrgWideEmailAddress where DisplayName =: System.Label.Contact_From_Address_Email limit 1];


        List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Property__c> updatePropList = new List<PropStrength__Property__c>();

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddressEmails = new List<String>();
        List<String> ccAddressEmails = new List<String>();
        String toAdd = '';
        String ccAdd = '';
        List<EmailMessage> newEmailList = new List<EmailMessage>();

        for(PropStrength__Application_Booking__c book : scope) {
            updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, PropStrength__Active__c = FALSE, PropStrength__Booking_Cancelled__c = TRUE, PropStrength__Property_Allotted__c = FALSE, PropStrength__Status__c = 'Booking_Cancelled', PropStrength__Booking_Cancellation_Reason__c = '15 days - 2%', PropStrength__Booking_Cancelled_Date__c = System.Today(), PropStrength__Property__c = null));
            updatePropList.add(new PropStrength__Property__c(Id=book.PropStrength__Property__c, PropStrength__Allotted__c = FALSE, PropStrength__Property_Alloted_Through_Offer__c = FALSE, PropStrength__Unit_Status__c = 'Available', Reason_for_Cancellation__c = 'Non-submission of 2% of the unit purchase price for Booking Id: '+book.Name+' within 14 days.', Customers__c = null));

            for(PropStrength__Applicant_Detail__c appDet: book.PropStrength__Applicant_Details__r) {
                System.debug('===>Test'+ appDet.PropStrength__Applicant_Email__c);
                if(appDet.PropStrength__Type__c == '1st Applicant') {
                    toAddressEmails.add(appDet.PropStrength__Applicant_Email__c);
                    toAdd = appDet.PropStrength__Applicant_Email__c;
                } else {
                    ccAddressEmails.add(appDet.PropStrength__Applicant_Email__c);
                    ccAdd += appDet.PropStrength__Applicant_Email__c + ',';
                }
            }
            if(book.Sales_Head__c != null){
                ccAddressEmails.add(book.Sales_Head__r.Email);
                ccAdd += book.Sales_Head__r.Email + ',';
            }
            if(book.Sales_Head__r.Manager !=null){
                ccAddressEmails.add(book.Sales_Head__r.Manager.Email);
                ccAdd +=book.Sales_Head__r.Manager.Email + ',';
            }
            if(book.Sales_Manager__c!=null){
                ccAddressEmails.add(book.Sales_Manager__r.Email);
                ccAdd +=book.Sales_Manager__r.Email + ',';
            }
            if(book.Secondary_Sales_Head__c != null){
                ccAddressEmails.add(book.Secondary_Sales_Head__r.Email);
                ccAdd += book.Secondary_Sales_Head__r.Email + ',';
            }
            if(book.Secondary_Sales_Head__r.Manager !=null){
                ccAddressEmails.add(book.Secondary_Sales_Head__r.Manager.Email);
                ccAdd +=book.Secondary_Sales_Head__r.Manager.Email + ',';
            }
            if(book.Secondary_Sales_Manager__r !=null){
                ccAddressEmails.add(book.Secondary_Sales_Manager__r.Email);
                ccAdd +=book.Secondary_Sales_Manager__r.Email + ',';
            }
            
            String body =  'Dear ' + book.PropStrength__Primary_Applicant_Name__c+ ',<br/><br/>' +
                            'We refer to the Blocking Amount paid by you for the unit '+book.House_Unit_No__c+', '+book.Project_Name__c +' – '+book.PropStrength__Tower__c+'.<br/><br/>'+
                            'Since you have not made full payment of the instalment amount, as per the terms of the booking form signed by you for the Unit in accordance with our standard sales policy despite repeated reminders from our Sales team, the booking is hereby cancelled.<br/><br/>'+ 
                            'You shall not have any claim, right or interest over the Booking and/or the Unit in whatsoever manner, notwithstanding the possession of any documents with respect to the Units including but not limited to brochures, receipts or any other marketing material.<br/><br/>'+
                            'Further, you shall indemnify and hold us harmless against any costs, fees, expenses, damages, losses and consequences arising out of or with respect to any compliance procedures or legal actions by any authority including but not limited to the Dubai Land Department, Real Estate Regulatory Agency due to the cancellation of booking.<br/><br/>'+
                            'We regret that the purchase of the Unit could not be completed on this occasion, however, should you be interested in our range of products, please do feel free to contact our sales team or visit www.sobharealty.com. You may also write to us on '+System.label.SobhaHelpdesk+' if you have any questions.<br/><br/>'+
                            'We look forward to welcoming you into the proud family of Sobha homeowners, in the near future!<br/><br/>'+
                            
                            'Thanks & Regards,<br/><br/>'+
                            'Sobha LLC'; 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Cancellation Notice ' +book.House_Unit_No__c+', ' + book.Project_Name__c + ' – ' + book.PropStrength__Tower__c);
            mail.setPlainTextBody(body);
            mail.setToAddresses(toAddressEmails);
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            if(!ccAddressEmails.isEmpty()) {
                mail.setccAddresses(ccAddressEmails);
            }
            
            System.debug(mail);
            emailList.add(mail);

            EmailMessage newEmail = new EmailMessage();
            newEmail.ToAddress = toAdd;
            if(ccAdd != '') {
                newEmail.CcAddress = ccAdd.substring(0, ccAdd.length()-1);
            }
            newEmail.Subject = 'Cancellation Notice ' +book.House_Unit_No__c+', ' + book.Project_Name__c + ' – ' + book.PropStrength__Tower__c;
            newEmail.TextBody = mail.getPlainTextBody();
            newEmail.RelatedToId = book.Id;
            newEmail.Status = '3';
            newEmailList.add(newEmail);
        }

        System.debug('updateBookList*****');
        System.debug(updateBookList);
        System.debug('updatePropList*****');
        System.debug(updatePropList);

        if(!updateBookList.isEmpty()) {
            update updateBookList;
        }
        if(!updatePropList.isEmpty()) {
            update updatePropList;
        }
        
        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.sendEmail(emailList);
            System.debug(newEmailList);
            insert newEmailList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        //System.schedule('CancelAppBookOnNonSubmissionOfTwoPercent_Hourly'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new CancelAppBookOnNonSubmissionOfTwoPercent() );
    }
}