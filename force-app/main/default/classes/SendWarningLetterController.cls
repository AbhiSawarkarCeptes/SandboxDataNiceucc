public without sharing class SendWarningLetterController {
    
    public Id bookingId;
    public Booking__c b {get;set;}
    public string todaysDate {get;set;}
    public boolean showError {get;set;}
    public Boolean isSiniya {get;set;}
    
    public SendWarningLetterController(){
        Date dToday = Date.today();
        todaysDate = Date.today().format();
        showError = false;
        if(ApexPages.currentPage().getParameters().get('id') != null){
            bookingId = ApexPages.currentPage().getParameters().get('id');
        }
        if(bookingId != null){
            try {
                b = [SELECT Id, Name, Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name,Unit__r.Project__r.Name,
                     Booking_Date__c, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Primary_Applicant_Address__c,
                     PrimaryMobileNumber__c, Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Other_Applicants_Email__c,
                     Opportunity__r.Other_Applicant_Mobile_Number__c, Signed_Date__c, Total_On_Account_Money_With_Registration__c,
                     As_On_Date_Due_Amount__c, Milestone_Due_Date__c, Milestone_Due_Till_Date__c
                     FROM Booking__c WHERE Unit__r.Tower__r.ByPass_Warning_Latter__c = false AND Unit__r.Tower__r.Stop_Automatic_Email__c = false AND Id =: bookingId];
                     showError = false;

                    if(b.Project__r.Name.contains('Siniya')){
                        isSiniya = true;
                    }else{
                        isSiniya = false;
                    }
            } catch (Exception e) {
                showError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'On this tower warning latter is disabled'));
            }
        }
    }
    
    @AuraEnabled
    public static list<Tower__c> getTowers(){
        return [SELECT Id,Name FROM Tower__c WHERE ByPass_Warning_Latter__c = false ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static list<BookingWrapper> getBookings(string towerId){
        list<BookingWrapper> wrapList = new list<BookingWrapper>();
        list<Booking__c> bookingList = new list<Booking__c>();
        if(towerId == 'All'){
            bookingList = [SELECT Id,Name,Unit__c,Unit__r.Name,Agreement_Value__c,Due_Payments__c,Ageing_days__c,Last_Warning_Sent__c,
                           (SELECT Id,GL_Date__c FROM Receipts__r WHERE Mode__c != 'Credit Note' AND GL_Date__c != NULL ORDER BY CreatedDate DESC),
                           (SELECT Id FROM Warning_Letter_History__r) 
                           FROM Booking__c
                           WHERE Current_Status__c = 'Audit Accepted' AND Status__c != 'Cancelled' AND Unit__r.Tower__r.ByPass_Warning_Latter__c = false AND
                           Overdue__c >= 5 AND Ageing_days__c >= 30
                           ORDER BY Ageing_days__c DESC];
        }
        else{
            bookingList = [SELECT Id,Name,Unit__c,Unit__r.Name,Agreement_Value__c,Due_Payments__c,Ageing_days__c,Last_Warning_Sent__c,
                           (SELECT Id,GL_Date__c FROM Receipts__r WHERE Mode__c != 'Credit Note' AND GL_Date__c != NULL ORDER BY CreatedDate DESC),
                           (SELECT Id FROM Warning_Letter_History__r) 
                           FROM Booking__c
                           WHERE Current_Status__c = 'Audit Accepted' AND Status__c != 'Cancelled' AND Unit__r.Tower__r.ByPass_Warning_Latter__c = false AND
                           Overdue__c >= 5 AND Ageing_days__c >= 30 AND Unit__r.Tower__c =: towerId 
                           ORDER BY Ageing_days__c DESC];
        }
        
        for(Booking__c b : bookingList){
            if(b.Last_Warning_Sent__c == null || b.Last_Warning_Sent__c.daysBetween(System.today()) > 60){
                BookingWrapper wrap = new BookingWrapper();
                wrap.unitId = b.Unit__c;
                wrap.unitName = b.Unit__r.Name;
                wrap.unitLink = '/'+b.Unit__c;
                wrap.bookingId = b.Id;
                wrap.bookingName = b.Name;
                wrap.bookingLink = '/'+b.Id;
                wrap.saleValue = (Double)b.Agreement_Value__c;
                wrap.overdue = (Double)b.Due_Payments__c;
                wrap.ageing = (Integer)b.Ageing_days__c;
                wrap.checked = false;
                if(b.Receipts__r != null && b.Receipts__r.size() > 0){
                    if(b.Receipts__r[0].GL_Date__c != null){
                        Date glDate = b.Receipts__r[0].GL_Date__c;
                        Datetime glDateTime = datetime.newInstance(glDate.year(), glDate.month(),glDate.day());
                        wrap.lastPaidDate = glDateTime.format('dd/MM/yyyy');
                    }
                }
                if(b.Warning_Letter_History__r != null){
                    wrap.warningSent = b.Warning_Letter_History__r.size();
                }
                wrapList.add(wrap);
            }
        }
        return wrapList;
    }
    
    @AuraEnabled
    public static string sendWarningLetter(string bookingId){
        try{
            Booking__c b = [SELECT Id,Primary_Applicant_Name__c,Primary_Applicant_Email__c,Overdue__c,Ageing_Date__c,Opportunity__c,
                            Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Other_Applicants_Email__c,Project__r.Name,
                            Due_Payments__c,Ageing_days__c,Unit__r.Name,Unit__r.Tower__r.Name,Unit__r.Project__r.Name,
                            (SELECT Id,GL_Date__c FROM Receipts__r WHERE Mode__c != 'Credit Note' AND GL_Date__c != NULL ORDER BY CreatedDate DESC) 
                            FROM Booking__c WHERE Id =: bookingId AND Unit__r.Tower__r.ByPass_Warning_Latter__c = false ];
            
            Warning_Letter_History__c warning = new Warning_Letter_History__c();
            warning.Ageing_days__c = b.Ageing_days__c;
            warning.Ageing_Date__c = b.Ageing_Date__c;
            warning.Booking__c = b.Id;
            warning.Overdue__c = b.Overdue__c;
            warning.Overdue_Amount__c = b.Due_Payments__c;
            warning.Sent_By__c = UserInfo.getUserId();
            warning.Sent_Date__c = System.today();
            if(b.Receipts__r != null && b.Receipts__r.size() > 0){
                warning.Last_Paid_Date__c = b.Receipts__r[0].GL_Date__c;
            }
            insert warning;
            
            b.Last_Warning_Sent__c = System.today();
            update b;

            Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
            System.debug(' owaMap '+owaMap); 
            for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
                owaMap.put(owa.Address,owa);
            }
            
            List<Messaging.EmailFileAttachment> attList = new List<Messaging.EmailFileAttachment>();
            
            PageReference prefLetter = new PageReference('/apex/WarningLetter');
            prefLetter.getParameters().put('id', b.Id);
            Blob blbLetter;
            if(!Test.isRunningTest()){
                blbLetter = prefLetter.getContent();   
            } else {
                blbLetter = Blob.valueOf('TestWarningLetter');
            }
            
            Messaging.EmailFileAttachment attachLetter = new Messaging.EmailFileAttachment();                                
            attachLetter.setBody(blbLetter);
            attachLetter.setFileName(b.Unit__r.Name+'_Urgent Attention Notice'+'.pdf');
            attList.add(attachLetter);
            
            if(b.Opportunity__c != null){
                PageReference prefSOA = new PageReference('/apex/N_CustomerSOAPage');
                prefSOA.getParameters().put('Id', b.Opportunity__c);
                prefSOA.getParameters().put('bookingid', b.Id);
                Blob blbSOA;
                if(!Test.isRunningTest()){
                    blbSOA = prefSOA.getContent();   
                } else {
                    blbSOA = Blob.valueOf('TestSOA');
                }                           
                
                Messaging.EmailFileAttachment attachSOA = new Messaging.EmailFileAttachment();                                
                attachSOA.setBody(blbSOA);
                attachSOA.setFileName('SOA.pdf');
                attList.add(attachSOA);
            }
            
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage(); 
            List<String> sendTo = new List<String>();
            
            if(b.Primary_Applicant_Email__c != null && b.Primary_Applicant_Email__c != '')
                sendTo.add(b.Primary_Applicant_Email__c);
            
            string otherApplicantName='';
            if(b.Opportunity__r.Other_Applicants_Name__c != null && b.Opportunity__r.Other_Applicants_Name__c != '')
                otherApplicantName=b.Opportunity__r.Other_Applicants_Name__c;
            
            string otherApplicantEmail='';
            if(b.Opportunity__r.Other_Applicants_Email__c != null && b.Opportunity__r.Other_Applicants_Email__c != ''){
                otherApplicantEmail=b.Opportunity__r.Other_Applicants_Email__c;
                otherApplicantEmail = otherApplicantEmail.trim();
                otherApplicantEmail = otherApplicantEmail.removeEnd(',');
                sendTo.addAll(otherApplicantEmail.split(','));
            }
            
            list<string> ccEmailAddress = new list<string>();
            ccEmailAddress.add(UserInfo.getUserEmail());
            string ccAddress = System.Label.CollectionTeamEmail;
            if(ccAddress != null && ccAddress != ''){
                ccAddress = ccAddress.trim();
                ccEmailAddress.addAll(ccAddress.split(','));
            }
            
            
            string body='Dear ' + b.Primary_Applicant_Name__c + ', '+ otherApplicantName +'<br/><br/>'+
                'Greetings!! <br/><br/>'+
                'This is with regards to the unit that you have purchased in Sobha Hartland.<br/><br/>'+
                'Please find attached the final communication to pay the due amounts. Kindly note that failure to pay the due amounts in the time allotted will result in the unit to be processed for termination.<br/><br/>'+
                'Request you to kindly go through the attached notice as well as refer to the attached Statement of account to know the outstanding due as on date. should you require any additional details please feel free to contact us.<br/><br/>'+
                'Best Regards,<br/>'+
                'Collections | Sobha LLC';
            
            mail.setSubject('Urgent Attention required for '+b.Unit__r.Name+', '+b.Unit__r.Tower__r.Name+', '+b.Unit__r.Project__r.Name);
            mail.setHtmlBody(body);
            mail.setToAddresses(sendTo);
            mail.setCcAddresses(ccEmailAddress);
            mail.setFileAttachments(attList);  
            mail.setWhatId(b.Id);
            if(b.Project__r.Name.contains('Siniya')){
                mail.setOrgWideEmailAddressId(owaMap.get(System.Label.Collection_Siniya_Email).id);
            }else{
                mail.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
            }
            if(sendTo.size()>0){
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    public class BookingWrapper {
        @AuraEnabled public string unitName;
        @AuraEnabled public string unitId;
        @AuraEnabled public string unitLink;
        @AuraEnabled public string bookingName;
        @AuraEnabled public string bookingId;
        @AuraEnabled public string bookingLink;
        @AuraEnabled public double saleValue;
        @AuraEnabled public double overdue;
        @AuraEnabled public integer ageing;
        @AuraEnabled public string lastPaidDate;
        @AuraEnabled public integer warningSent;
        @AuraEnabled public boolean checked;
        
        public BookingWrapper(){
            unitName = '';
            unitId = '';
            unitLink = '';
            bookingName = '';
            bookingId = '';
            bookingLink = '';
            saleValue = 0;
            overdue = 0;
            ageing = 0;
            lastPaidDate = '';
            warningSent = 0;
            checked = false;
        }
    }
}