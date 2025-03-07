public without sharing class PreRegistrationOnBookingCreation {
    
    public static void startPreRegistrationProcessFuture(string bookid){
        List <Booking__c> bookList = new List <Booking__c>();
        
        bookList = [SELECT Id, OwnerId,  Quotation__c, Project_Name__c, Project__r.Name, Unit__r.Tower__c, Opportunity__r.Name, Owner.Email, Unit__r.Tower__r.Cluster__r.Name,
                    Unit__c, Unit__r.Name, Project__c, Primary_Applicant_Email__c, Owner.Name, Unit__r.Tower__r.RDS_Company_Code__c, Name,
                    Primary_Applicant_Name__c, Unit__r.Tower__r.Project_Executive_CRM__r.Name, Unit__r.Tower__r.Team_Manager_CRM__r.Name,
                    Unit__r.Tower__r.Project_Executive_CRM__r.Email, Unit__r.Tower__r.Team_Manager_CRM__r.Email,Cluster__c,Booking_Date__c,
                    Sales_Managers__r.Email, Sales_Head__r.Email,Secondary_Sales_Manager_VP__r.Email,Sales_Managers__c,Sales_Head__c,Secondary_Sales_Manager_VP__c ,
                    Sales_Head__r.Manager.email,unit__r.Tower__r.name
                    FROM Booking__c WHERE Id =:bookid];
        if(bookList != null && !bookList.isEmpty()){
            Booking__c b = bookList[0];
            Map<String, ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(b.Project__r.Name, b.Unit__r.Tower__c);      
            Map<String, Integer> SDRChargesSeqMap = new Map<String, Integer>();
            List <Payment_Milestones__c> pmList;
            Integer Seq = 1;
            String chgBucket = ''; 
            Decimal totalAmt = 0;
            for(String chargeName: projChargesMap.keySet()) {
                chgBucket = projChargesMap.get(chargeName).ChargeBucket__c;
                if(chgBucket.equalsIgnoreCase('Stamp Duty and Registration')) {
                    SDRChargesSeqMap.put(chargeName, Seq);
                }        
                Seq++;
            }
            
            String queryString1 = '';
            String qId = b.Quotation__c;
            for(Integer i = 1; i<=25; i++) {
                queryString1 += 'Charge' + i + 'Name__c'   + ',';
                queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
                queryString1 += 'C' + i + '_Amount__c' + ',';                    
                queryString1 += 'C' + i + '_CGST__c'   + ','; 
                queryString1 += 'C' + i + '_SGST__c'   + ','; 
            }
            
            if (qId != null) {
                queryString1 = 'Select ' + queryString1  + ' Id, Name, Milestone_Name__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c From Payment_Milestones__c where Quotation__c = \'' + qId + '\'' ;
                pmList = Database.Query(queryString1);
            }    
            for(Payment_Milestones__c pm : pmList) {           
                for(Integer i : SDRChargesSeqMap.values()) {
                    totalAmt += (Decimal)pm.get('C' +i + '_Amount__c');
                }
            }  
            
            Demand__c d = new Demand__C();
            d.Project__c = b.Project__c;
            d.Unit__c = b.Unit__c;
            d.Quotation__c = b.Quotation__c;
            d.Booking__c = b.Id;
            d.Invoice_Date__c = System.Today();
            d.Due_Date__c = System.Today().addDays(30);
            d.GL_Date__c = System.Today(); 
            d.Remarks__c = 'Debit note for DLD Charges';
            d.Milestone_Name__c = 'Debit note for DLD Charges';
            d.Debit_Demanded__c = totalAmt;
            d.Debit_Type__c = 'DLD Charges';
            d.Tax_Rate__c = 'OUT OF SCOPE';
            
            List<Account_Master__c> am = new List<Account_Master__c>();
            Map<String, Id> accMasterMap = new Map<String, Id>();
            am = [SELECT Id, Name, Type__c FROM Account_Master__c]; 
            if(!am.isEmpty()){
                for(Account_Master__c a: am){                   
                    accMasterMap.put(a.name, a.Id); 
                }                         
                for(String s: accMasterMap.keySet()){
                    if(s.equalsIgnoreCase('Trade Receivable'))
                        d.Total_Amount_with_Tax_Account__c = accMasterMap.get(s);
                    if(s.equalsIgnoreCase('Pre registration Payable'))  
                        d.Total_Amount_Account__c = accMasterMap.get(s);
                    if(s.equalsIgnoreCase('Vat Out of Scope'))  
                        d.Total_Tax_Account__c = accMasterMap.get(s);
                }
            }    
            
            if(b.Unit__c != null){
                Unit__c u = [SELECT Tower__c FROM Unit__c where Id = :b.Unit__c];
                if(u.Tower__c != null){
                    Tower__c t = [SELECT Business_Unit__c, Business_Unit_Code__c FROM Tower__c WHERE Id = :u.Tower__c];
                    d.Business_Unit__c = t.Business_Unit__c;
                    d.Business_Unit_Code__c = t.Business_Unit_Code__c;
                }
            }
            d.GL_Date__c = System.Today();
            d.Payment_Towards__c = 'Corporate Account';
            try{
                insert d;
            }
            catch(Exception e){
                System.debug('Error occurred while inserting debit note');
            }
            // if(b.Project__r.Name != 'Sobha Siniya Island'){
                sendAttachNotice(b);   
            // }
            
            Task t = new Task();
            t.OwnerId = b.OwnerId;
            t.Priority  = 'Normal';
            t.Status = 'Open';
            t.ActivityDate = system.today() + 7;
            t.Date_Time_of_Registration_Notification__c	= system.now();
            t.RecordTypeId = '0121t0000010WPY';
            t.Subject = 'Pre-Registration Process Initiated';
            t.WhatId = b.Id;
            insert t;
        } 
    }
    
    public static pageReference sendAttachNotice(Booking__c booking){
        
        EmailOptOutBooking__c emailOptOutCS = EmailOptOutBooking__c.getInstance('Send Email On Booking Creation');
        Boolean emailOptOut = emailOptOutCS.Send_Welcome_Email__c;
        System.debug(emailOptOutCS.Send_Welcome_Email__c);
        
        if(emailOptOut){
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: system.label.WelcomeEmailOrgWideId];
            
            string names=booking.Primary_Applicant_Name__c;
            string emailAddresses=booking.Primary_Applicant_Email__c;
            for(Applicant_Details__c ad : [select Name, Email_Address__c from Applicant_Details__c where Booking__c =: booking.Id and Applicant_Number__c != 'Primary Applicant']){
                names += ', '+ad.Name;
                emailAddresses += ','+ad.Email_Address__c;
            }
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            List<Id> ContentDocumentids = new List<Id>();
            for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid = :booking.id]){
                ContentDocumentids.add(CDLink.ContentDocumentid); 
            }      
            for(ContentVersion cversion : [SELECT title, PathOnClient, FileType, versiondata
                                           FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids AND title =: booking.Name]){
                                               blob WOCFbody = cversion.versiondata;
                                               Messaging.Emailfileattachment attach2 = new Messaging.Emailfileattachment();
                                               attach2.setFileName('Booking Form.pdf');
                                               attach2.setBody(WOCFbody);
                                               fileAttachments.add(attach2);  
                                           }   
            
            Integer noOfSubmissionDays = 7;
            String excemptionTowerName = System.label.ExcemtionTower;
            if(booking.unit__r.Tower__r.name == excemptionTowerName){
                noOfSubmissionDays = 2;
            }
            
            PageReference pref = new PageReference('/apex/PreRegistrationNotice');
            pref.getParameters().put('Id', booking.Id);
            Blob b;
            if(!Test.isRunningTest()){
                b = pref.getContentAsPDF();   
            } else {
                b = Blob.valueOf('Test123');
            }              
            Messaging.EmailFileAttachment attach3 = new Messaging.EmailFileAttachment();                                
            attach3.setBody(b);
            attach3.setFileName('Pre-Registration Notice.pdf');  
            fileAttachments.add(attach3);    
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();              
            email.setSubject('Congratulations on booking unit ' + booking.Unit__r.Name);
            list<string> lststringtoaddress = new list<string>();
            list<string> lststringccaddress = new list<string>();
            String body = '';
            body =  'Dear ' + names + ',<br/><br/>' + 
                '<b>Greetings from Sobha!</b><br/><br/>'+
                'Thank you for your purchase in our prestigious project <b>'+booking.Project__r.Name+'</b><br/><br/>'+
                'Please find attached booking form for unit <b>'+booking.Unit__r.Name+'</b>. We request you to kindly sign all pages of the booking form and submit along with below listed documents for processing the unit registration.<br/><br/>'+
                'In order to register the Unit(s) with the DLD, you are requested to make the payment of the registration fee as mentioned in the attached Notice for Pre-registration and fee payment.<br/><br/>'+
                'Kindly note, if the booking form is not submitted in '+ noOfSubmissionDays +' calendar days from today, the unit will be auto rejected by the system.<br/><br/>'+
                'For any further queries please contact your sales manager.<br/><br/>'+
                'Regards,<br/>'+
                'Sobha LLC';
            
            if(!String.isEmpty(emailAddresses)){
                lststringtoaddress.addAll(emailAddresses.split(','));
            } 
            if(booking.Owner.Email != null && booking.Owner.Email != ''){
                //lststringccaddress.add('helpdesk@sobharealty.com');
                if(booking.Sales_Managers__c != null)
                    lststringccaddress.add(booking.Sales_Managers__r.Email);   
                if(booking.Sales_Head__c != null){
                    lststringccaddress.add(booking.Sales_Head__r.Email); 
                    
                }
                if(booking.Secondary_Sales_Manager_VP__c != null)
                    lststringccaddress.add(booking.Secondary_Sales_Manager_VP__r.Email); 
                if(system.label.Pre_Registration_Booking_CC_email != '*'){
                    for(string emailToCc : system.label.Pre_Registration_Booking_CC_email.split(';')){
                        lststringccaddress.add(emailToCc);
                    }
                }
                if(booking.Sales_Head__r.Manager.email != null)
                    lststringccaddress.add(booking.Sales_Head__r.Manager.email); 
                
                
            }    
            //SOB-336 start
            String emailAddressFromBooking = BookingUtilityClass.getEmailOfApplicants(booking.id);
            if(!string.isblank(emailAddressFromBooking)){
                for(String s : emailAddressFromBooking.split(',')){
                    if(!s.containsIgnoreCase('null')){
                        lststringtoaddress.add(s);
                    }
                }
            }
            //SOB-336 end
            email.setToAddresses(lststringtoaddress);
            email.setCCAddresses(lststringccaddress);
            email.setHtmlBody(body);
            email.setFileAttachments(fileAttachments);  
            if(owea.size() > 0){
                email.setOrgWideEmailAddressId( owea.get(0).Id);
                
            }
            
            try{
                Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});      
            }catch(exception e){
                
            }
        }
        return null;
    }
}