global class AutoCancelBookingAfter15Days_PS Implements Database.Batchable<sObject>,Schedulable {
    global List<PropStrength__Application_Booking__c> start(Database.BatchableContext BC) {
        DateTime targetDate = DateTime.newInstance(2023, 01, 01, 0, 0, 0);

        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c> ();
        List<PropStrength__Application_Booking__c> returnBookingList = new List<PropStrength__Application_Booking__c> ();

        bookingList = [SELECT Id, Name, PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Total_Service_Tax_due_on_Booking__c, PropStrength__Property_Name__c, Docusign_Sales_Ops_Email__c, Sales_Manager__c, Sales_Director__c, Sales_Director__r.Email, Sales_Manager__r.Email, Sales_Head__c, Sales_Head__r.Email, SBF_Assigned_To__c, SBF_Assigned_To__r.Email, PropStrength__Booking_Amount__c, PropStrength__Total_Payment_Received__c, PropStrength__Booking_Date__c,PropStrength__Application_Booking__c.House_Unit_No__c,No_Cancellation__c, PropStrength__Property__r.Roadshow_Booking__c,
                        PropStrength__Application_Booking__c.PropStrength__Tower__c, PropStrength__Primary_Customer__c,PropStrength__Active__c,PropStrength__Total_Paid_Percent__c,
                        (SELECT Id, PropStrength__Type__c, PropStrength__Applicant_Email__c, PropStrength__Customer_Name__c FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE ORDER BY PropStrength__Type__c),
                        (SELECT Id, Amount__c FROM Payment_Requests__r WHERE (NOT Status__c LIKE '%Rejected%')), 
                        PropStrength__Application_Booking__c.Project_Name__c, PropStrength__Property__c, PropStrength__Property__r.File_Note__c, Management_Approval__c,
                        PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c, CreatedById, CreatedBy.UserRole.Name, CreatedBy.ManagerId, CreatedBy.Manager.UserRole.Name, 
                        CreatedBy.Manager.ManagerId, CreatedBy.Manager.Manager.UserRole.Name, CreatedBy.Manager.Manager.ManagerId, CreatedBy.Manager.Manager.Manager.UserRole.Name, 
                        CreatedBy.Email, CreatedBy.Manager.Email, CreatedBy.Manager.Manager.Email, CreatedBy.Manager.Manager.Manager.Email, CreatedBy.UserRoleId, CreatedBy.Manager.UserRoleId, 
                        CreatedBy.Manager.Manager.UserRoleId, CreatedBy.Manager.Manager.Manager.UserRoleId 
                        FROM PropStrength__Application_Booking__c 
                        WHERE PropStrength__Active__c = TRUE  
                        AND CreatedDate >= :targetDate 
                        AND PropStrength__Property__c != null 
                        AND (PropStrength__Property__r.PropStrength__Tower__r.Stop_Auto_Cancelation__c = FALSE OR PropStrength__Project__r.Stop_Auto_Cancelation__c = FALSE)
                        AND (No_Cancellation__c = FALSE
                        AND PropStrength__Property__r.Roadshow_Booking__c = FALSE
                        AND PropStrength__Property__r.File_Note__c = FALSE
                        AND Management_Approval__c = FALSE
                        AND (PropStrength__Status__c = 'Processed' OR PropStrength__Status__c = 'Unprocessed' OR PropStrength__Status__c = 'Booking In Process' OR PropStrength__Status__c = 'Application Form Filled')
                        AND (NOT(PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c = 'Employee Reference' OR PropStrength__Offer__r.PropStrength__Request__r.PropStrength__Request_Source__c = 'Management Reference')))];

        if(!bookingList.isEmpty()) {
            Map<Id, Decimal> mapOfBookAndPr = new Map<Id, Decimal>();
            Map<Id, Decimal> mapOfPropAndPr = new Map<Id, Decimal>();
            Set<Id> propId = new Set<Id>();

            for(PropStrength__Application_Booking__c book : bookingList) {
                if(book.PropStrength__Property__c != null) {
                    propId.add(book.PropStrength__Property__c);
                }
            }

            List<Payment_Request__c> prPropList = [SELECT Id, Amount__c, Property__c FROM Payment_Request__c WHERE Property__c IN :propId AND (NOT Status__c LIKE '%Rejected%')];

            if(!prPropList.isEmpty()) {
                for(Payment_Request__c pr : prPropList) {
                    if(mapOfPropAndPr.containsKey(pr.Id)) {
                        Decimal amt = mapOfPropAndPr.get(pr.Id);
                        mapOfPropAndPr.put(pr.Id, amt + pr.Amount__c);
                    } else {
                        mapOfPropAndPr.put(pr.Id, pr.Amount__c);
                    }
                }
            }

            for(PropStrength__Application_Booking__c book : bookingList) {
                if(book.PropStrength__Booking_Date__c != null && book.PropStrength__Booking_Date__c.daysBetween(System.Today()) > 14) {
                    if(!book.Payment_Requests__r.isEmpty()) {
                        Decimal sumAmt = 0;
                        for(Payment_Request__c pr : book.Payment_Requests__r) {
                            if(pr.Amount__c != null) {
                                sumAmt += pr.Amount__c;
                            }
                        }
                        Decimal propPrAmtTotal =  0;
                        if(mapOfPropAndPr.containsKey(book.PropStrength__Property__c)) {
                            propPrAmtTotal = mapOfPropAndPr.get(book.PropStrength__Property__c);
                        }
                        mapOfBookAndPr.put(book.Id, sumAmt+propPrAmtTotal);
                    }
                }
            }

            System.debug('mapOfBookAndPr****');
            System.debug(mapOfBookAndPr);

            for(PropStrength__Application_Booking__c book : bookingList) {
                System.debug(book.PropStrength__Booking_Date__c);
                System.debug(book.PropStrength__Booking_Date__c.daysBetween(System.Today()));
                if(book.PropStrength__Booking_Date__c != null && book.PropStrength__Booking_Date__c.daysBetween(System.Today()) > 14) {
                    /*if(book.PropStrength__Booking_Amount__c > book.PropStrength__Total_Payment_Received__c) {
                        returnBookingList.add(book);
                    } else if(mapOfBookAndPr.containsKey(book.Id) && book.PropStrength__Booking_Amount__c > mapOfBookAndPr.get(book.Id)) {
                        returnBookingList.add(book);
                    } */     
                    
                    if(mapOfBookAndPr.containsKey(book.Id) && (mapOfBookAndPr.get(book.Id) / (book.PropStrength__Revised_Total_Sales_Consideration__c - book.PropStrength__Total_Service_Tax_due_on_Booking__c)) < 9.5) {
                        returnBookingList.add(book);
                        System.debug((mapOfBookAndPr.get(book.Id) / (book.PropStrength__Revised_Total_Sales_Consideration__c - book.PropStrength__Total_Service_Tax_due_on_Booking__c)));
                    }
                }
            }
        }
        return returnBookingList;
    }

    public void execute(SchedulableContext context) {
        AutoCancelBookingAfter15Days_PS batch = new AutoCancelBookingAfter15Days_PS();
        Database.executeBatch(batch);
    }

    global void execute(Database.BatchableContext BC, List<PropStrength__Application_Booking__c> scope) {
        System.debug('Scope::&&&&');
        System.debug(scope);
        List<PropStrength__Application_Booking__c> updateBookList = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Property__c> updatePropList = new List<PropStrength__Property__c>();

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddressEmails = new List<String>();
        List<String> ccAddressEmails = new List<String>();
        List<EmailTemplate> templatelist ;
        Id TempId;
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' AND IsVerified = true LIMIT 1];  
        templatelist = [SELECT id,name, DeveloperName FROM EmailTemplate where DeveloperName = 'Cancellation_Of_Booking' limit 1];
        if(!templatelist.isEmpty()) {
            TempId = templatelist[0].id;
        }


        for(PropStrength__Application_Booking__c book : scope) {
            updateBookList.add(new PropStrength__Application_Booking__c(Id=book.Id, PropStrength__Active__c = FALSE, PropStrength__Booking_Cancelled__c = TRUE, PropStrength__Property_Allotted__c = FALSE, PropStrength__Status__c = 'Booking_Cancelled', PropStrength__Booking_Cancellation_Reason__c = 'Auto cancellation (14 days policy)', PropStrength__Booking_Cancelled_Date__c = System.Today(), PropStrength__Property__c = null));
            updatePropList.add(new PropStrength__Property__c(Id=book.PropStrength__Property__c, PropStrength__Allotted__c = FALSE, PropStrength__Property_Alloted_Through_Offer__c = FALSE, Reason_for_Cancellation__c = 'Non-submission of 9.5% of the unit purchase price for Booking Id: '+book.Name+' within 14 days.', Customers__c = null));

            for(PropStrength__Applicant_Detail__c appDet: book.PropStrength__Applicant_Details__r) {
                if(appDet.PropStrength__Type__c == '1st Applicant') {
                    toAddressEmails.add(appDet.PropStrength__Applicant_Email__c);
                } else {
                    ccAddressEmails.add(appDet.PropStrength__Applicant_Email__c);
                }
            }

            if(book.Sales_Manager__c != null) {
                ccAddressEmails.add(book.Sales_Manager__r.Email);
            }
            if(book.Sales_Head__c != null) {
                ccAddressEmails.add(book.Sales_Head__r.Email);
            }
            if(book.SBF_Assigned_To__c != null) {
                ccAddressEmails.add(book.SBF_Assigned_To__r.Email);
            }
            if(book.Sales_Director__c != null) {
                ccAddressEmails.add(book.Sales_Director__r.Email);
            }
            if(book.Docusign_Sales_Ops_Email__c != null) {
                ccAddressEmails.add(book.Docusign_Sales_Ops_Email__c);
            }
            if(book.CreatedById != null && book.CreatedBy.Email != null && book.CreatedBy.UserRoleId != null && (book.CreatedBy.UserRole.Name.containsIgnoreCase('Vice President') || book.CreatedBy.UserRole.Name.containsIgnoreCase('Senior Vice President'))) {
                ccAddressEmails.add(book.CreatedBy.Email);
            }
            if(book.CreatedById != null && book.CreatedBy.ManagerId != null && book.CreatedBy.Manager.Email != null && book.CreatedBy.Manager.UserRoleId != null && (book.CreatedBy.Manager.UserRole.Name.containsIgnoreCase('Vice President') || book.CreatedBy.Manager.UserRole.Name.containsIgnoreCase('Senior Vice President'))) {
                ccAddressEmails.add(book.CreatedBy.Manager.Email);
            }
            if(book.CreatedById != null && book.CreatedBy.ManagerId != null && book.CreatedBy.Manager.ManagerId != null && book.CreatedBy.Manager.Manager.Email != null && book.CreatedBy.Manager.Manager.UserRoleId != null && (book.CreatedBy.Manager.Manager.UserRole.Name.containsIgnoreCase('Vice President') || book.CreatedBy.Manager.Manager.UserRole.Name.containsIgnoreCase('Senior Vice President'))) {
                ccAddressEmails.add(book.CreatedBy.Manager.Manager.Email);
            }
            if(book.CreatedById != null && book.CreatedBy.ManagerId != null && book.CreatedBy.Manager.ManagerId != null && book.CreatedBy.Manager.Manager.ManagerId != null && book.CreatedBy.Manager.Manager.Manager.Email != null && book.CreatedBy.Manager.Manager.Manager.UserRoleId != null && (book.CreatedBy.Manager.Manager.Manager.UserRole.Name.containsIgnoreCase('Vice President') || book.CreatedBy.Manager.Manager.Manager.UserRole.Name.containsIgnoreCase('Senior Vice President'))) {
                ccAddressEmails.add(book.CreatedBy.Manager.Manager.Manager.Email);
            }

            ccAddressEmails.add('helpdesk@sobharealty.com');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddressEmails);
            mail.setTemplateId(TempId);
            mail.setSaveAsActivity(true); 
            mail.setWhatId(book.Id);
            mail.setTargetObjectId(book.PropStrength__Primary_Customer__c);
            if(!owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            if(!ccAddressEmails.isEmpty()) {
                mail.setccAddresses(ccAddressEmails);
            }
            
            System.debug(mail);
            emailList.add(mail);
        }

        System.debug(emailList);
        if(emailList != null && emailList.size()>0 ) {
            System.debug(emailList);
            Messaging.sendEmail(emailList);
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
    }

    global void finish(Database.BatchableContext BC) {
        //System.schedule('AutoCancelBookingAfter15Days_PS_Hourly'+System.now().addDays(Integer.valueof((Math.random() * 100))), '0 0 * * * ?', new AutoCancelBookingAfter15Days_PS() );
    }
}