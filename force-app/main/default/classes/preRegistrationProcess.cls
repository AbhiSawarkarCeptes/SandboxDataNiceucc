public without sharing class preRegistrationProcess{
    @InvocableMethod
    public static void getPaymentMilestones(List<Id> bookid){
        List <Booking__c> bookList = new List <Booking__c>();
        bookList = [SELECT Id, Quotation__c, Project__r.Name, Unit__r.Tower__c, Opportunity__r.Name, Owner.Email, Unit__r.Tower__r.Cluster__r.Name,
                    Unit__c, Unit__r.Name, Project__c, Primary_Applicant_Email__c, Owner.Name, Unit__r.Tower__r.RDS_Company_Code__c, Name,
                    Primary_Applicant_Name__c, Unit__r.Tower__r.Project_Executive_CRM__r.Name, Unit__r.Tower__r.Team_Manager_CRM__r.Name,
                    Unit__r.Tower__r.Project_Executive_CRM__r.Email, Unit__r.Tower__r.Team_Manager_CRM__r.Email,Cluster__c,Booking_Date__c,Unit__r.Store_Unit__c,
                    Sales_Managers__r.Email, Sales_Head__r.Email,Secondary_Sales_Manager_VP__r.Email,Sales_Managers__c,Sales_Head__c,Secondary_Sales_Manager_VP__c
                    FROM Booking__c WHERE Id IN :bookid];
        DateTime firstJune2020 = Datetime.newInstance(2022, 6, 1,0,0,0);
        if(bookList != null && !bookList.isEmpty()){
            Booking__c b = bookList[0];
            if(b.Booking_Date__c < firstJune2020){
                system.debug('VVK here inside');
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
                
                //create Debit Note for DLD, Knowledge Fees and DLD Admin Fees 
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
                
                //added by Neha on 11/6/19 to tag natural account on dld charges debit note        
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
                d.GL_Date__c = System.Today(); // date demand is raised
                d.Payment_Towards__c = 'Corporate Account';
                try{
                    insert d;
                }
                catch(Exception e){
                    System.debug('Error occurred while inserting debit note');
                }
            }
            sendAttachNotice(b);
            if(bookList != null && bookList.size() > 0)
                update bookList;                
        } 
    }
    
    public static pageReference sendAttachNotice(Booking__c booking){
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
        ///// Welcome letter attachment          
        PageReference pref1 = new PageReference('/apex/N_WelcomeLetterPDF');
        pref1.getParameters().put('Id', booking.Id);
        Blob b1;
        if(!Test.isRunningTest()){
            b1 = pref1.getContent();   
        } else {
            b1 = Blob.valueOf('Test123');
        }   
        
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();                                
        attach1.setBody(b1);
        attach1.setFileName('Welcome Letter.pdf');  
        fileAttachments.add(attach1);
        
        ////// Booking Form attachment  
        List<Id> ContentDocumentids = new List<Id>();
        for(contentDocumentLink CDLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid = :booking.id]){
            ContentDocumentids.add(CDLink.ContentDocumentid); 
        }       
        for(ContentVersion cversion : [SELECT title, PathOnClient, FileType, versiondata
                                       FROM contentversion WHERE ContentDocumentId IN :ContentDocumentids AND title LIKE 'Booking Form%']){
                                           blob WOCFbody = cversion.versiondata;
                                           Messaging.Emailfileattachment attach2 = new Messaging.Emailfileattachment();
                                           attach2.setFileName('Booking Form.pdf');
                                           attach2.setBody(WOCFbody);
                                           fileAttachments.add(attach2);                     
                                       }                                    
        
        ///// Pre registration notice attachment   
        DateTime firstJune2020 = Datetime.newInstance(2022, 6, 1,0,0,0);
        if(booking.Booking_Date__c < firstJune2020){
            PageReference pref = new PageReference('/apex/PreRegistrationNotice');
            pref.getParameters().put('Id', booking.Id);
            Blob b;
            if(!Test.isRunningTest()){
                b = pref.getContent();   
            } else {
                b = Blob.valueOf('Test123');
            }              
            Messaging.EmailFileAttachment attach3 = new Messaging.EmailFileAttachment();                                
            attach3.setBody(b);
            attach3.setFileName('Pre-Registration Notice.pdf');  
            fileAttachments.add(attach3);    
        }
        /////////////////Extra Attachments added by VAMSI////////////////////////////////
        system.debug(booking.Cluster__c+'booking.Cluster__c');
        if(system.Label.one_park_PS.split(',').contains(booking.Cluster__c)){
            system.debug('In here');
            List<contentversion> fillst = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.Logic_statement.split(',')];
            system.debug(fillst);
            for(contentversion ct : fillst){
                Messaging.EmailFileAttachment tempaatach = new Messaging.EmailFileAttachment();
                tempaatach.setBody(ct.versiondata);
                tempaatach.setContentType('application/pdf');
                tempaatach.setFileName(ct.title+'.pdf');  
                tempaatach.setInline(false);
                fileAttachments.add(tempaatach);
            }
        }
        if(system.Label.CVR_PS.split(',').contains(booking.Cluster__c)){
            List<contentversion> fillst1 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.Logic_statement_for_OPA.split(',')];
            system.debug(fillst1);
            for(contentversion ct1 : fillst1){
                Messaging.EmailFileAttachment tempaatach1 = new Messaging.EmailFileAttachment();
                tempaatach1.setBody(ct1.versiondata);
                tempaatach1.setContentType('application/pdf');
                tempaatach1.setFileName(ct1.title+'.pdf');  
                tempaatach1.setInline(false);
                fileAttachments.add(tempaatach1);
            }
        }   
        if(system.Label.Waves_Project_Statement.split(',').contains(booking.Cluster__c)){
            List<contentversion> fillst2 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.PDF_statement_For_Waves_PS.split(',')];
            system.debug(fillst2);
            for(contentversion ct2 : fillst2){
                Messaging.EmailFileAttachment tempaatach2 = new Messaging.EmailFileAttachment();
                tempaatach2.setBody(ct2.versiondata);
                tempaatach2.setContentType('application/pdf');
                tempaatach2.setFileName(ct2.title+'.pdf');  
                tempaatach2.setInline(false);
                fileAttachments.add(tempaatach2);
            }
        }   
        if(system.Label.Waves_Grande_Project_Statement.split(',').contains(booking.Cluster__c)){
            List<contentversion> fillst3 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.PDF_statement_For_Waves_Grande_PS.split(',')];
            system.debug(fillst3);
            for(contentversion ct3 : fillst3){
                Messaging.EmailFileAttachment tempaatach3 = new Messaging.EmailFileAttachment();
                tempaatach3.setBody(ct3.versiondata);
                tempaatach3.setContentType('application/pdf');
                tempaatach3.setFileName(ct3.title+'.pdf');  
                tempaatach3.setInline(false);
                fileAttachments.add(tempaatach3);
            }
        } 
            if(system.Label.The_Crest.split(',').contains(booking.Cluster__c) && !booking.Unit__r.Store_Unit__c){
                List<contentversion> fillst4 = [ SELECT title, PathOnClient, FileType, versiondata FROM contentversion where title = :system.Label.PDF_statement_For_The_Crest_PS.split(',')];
                system.debug(fillst4);
                for(contentversion ct4 : fillst4){
                    Messaging.EmailFileAttachment tempaatach4 = new Messaging.EmailFileAttachment();
                    tempaatach4.setBody(ct4.versiondata);
                    tempaatach4.setContentType('application/pdf');
                    tempaatach4.setFileName(ct4.title+'.pdf');  
                    tempaatach4.setInline(false);
                    fileAttachments.add(tempaatach4);
                }
            } 
                
        //email                       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
        string names=booking.Primary_Applicant_Name__c;
        string emailAddresses=booking.Primary_Applicant_Email__c;
        for(Applicant_Details__c ad : [select Name, Email_Address__c from Applicant_Details__c where Booking__c =: booking.Id and Applicant_Number__c != 'Primary Applicant']){
            names += ', '+ad.Name;
            emailAddresses += ','+ad.Email_Address__c;
        }
        email.setSubject('Unit No. ' + booking.Unit__r.Name + ' ' + booking.Project__r.Name + ' ' + booking.Unit__r.Tower__r.Cluster__r.Name + ' - Welcome Email');
        list<string> lststringtoaddress = new list<string>();
        list<string> lststringccaddress = new list<string>();
        String body = '';
        if(booking.Booking_Date__c < firstJune2020){
            body =  'Dear ' + names + ',<br/><br/>' + 
                
                '<b>Greetings from Sobha!</b><br/><br/>'+
                
                'Congratulations on your new home in Sobha Hartland. We would like to introduce ourselves ' +
                'as the Customer Relation Management team (CRM) of Sobha Realty and will be your single '+
                'point of contact with regard to all matters pertaining to your unit '+ booking.Unit__r.Name + ' in the above mentioned project.<br/><br/> ' + 
                
                'We are at your service to assist any queries and issues pertaining to the '+ 
                'project, including transactions on payments/ legal/ project updates, handover of units and '+
                'subsequent registration of the same. Kindly contact the undersigned for the same at '+
                System.label.SobhaHelpdesk+'.<br/><br/>'+
                
                'You can reach us on a dedicated <b style="color:blue">CUSTOMER SERVICE HELP LINE NUMBER +971 4 3687845</b>. This number will ensure a timely response and the lines will be active from 9:30 to 07:00PM from Monday to Friday.<br/><br/>' + 
                
                
                'Please find attached a copy of the below documents:<br/>'+
                '<ol>'+
                '<li>Welcome Letter</li>'+
                '<li>Booking Form</li>'+
                '<li>Pre-Registration Notice (kindly ignore this notice if the pre-registration fees has already been paid )</li>'+
                '<li>Project Statement</li>'+
                '</ol>'+
                'For more information on new & ongoing projects, please visit our website www.sobharealty.com. We assure you our best services at all times. <br/><br/>'+
                'Regards,<br/>'+
                'CRM Team';
              body =  booking.Unit__r.Store_Unit__c ?  body.remove('<li>Project Statement</li>') : body;
            
        }
        else{
            body =  'Dear ' + names + ',<br/><br/>' + 
                
                '<b>Greetings from Sobha!</b><br/><br/>'+
                
                'Congratulations on your new home in Sobha Hartland. We would like to introduce ourselves ' +
                'as the Customer Relation Management team (CRM) of Sobha Realty and will be your single '+
                'point of contact with regard to all matters pertaining to your unit '+ booking.Unit__r.Name + ' in the above mentioned project.<br/><br/> ' + 
                
                'We are at your service to assist any queries and issues pertaining to the '+ 
                'project, including transactions on payments/ legal/ project updates, handover of units and '+
                'subsequent registration of the same. Kindly contact the undersigned for the same at '+
                System.label.SobhaHelpdesk+'.<br/><br/>'+
                
                'You can reach us on a dedicated <b style="color:blue">CUSTOMER SERVICE HELP LINE NUMBER +971 4 3687845</b>. This number will ensure a timely response and the lines will be active from 9:30 to 07:00PM from Monday to Friday.<br/><br/>' + 
                
                'Please find attached a copy of the below documents:<br/>'+
                '<ol>'+
                '<li>Welcome Letter</li>'+
                '<li>Booking Form</li>'+
                '<li>Project Statement</li>'+
                '</ol>'+
                'For more information on new & ongoing projects, please visit our website www.sobharealty.com. We assure you our best services at all times. <br/><br/>'+
                'Regards,<br/>'+
                'CRM Team';
                body =  booking.Unit__r.Store_Unit__c ?  body.remove('<li>Project Statement</li>') : body;
            
        }
        
        /* Email TO */
        if(emailAddresses != ''){
            lststringtoaddress.addAll(emailAddresses.split(','));
        }
        
        /* Email CC */
        lststringccaddress.add(System.label.SobhaHelpdesk); 
        if(booking.Sales_Managers__c != null)
            lststringccaddress.add(booking.Sales_Managers__r.Email);   
        if(booking.Sales_Head__c != null)
            lststringccaddress.add(booking.Sales_Head__r.Email); 
        if(booking.Secondary_Sales_Manager_VP__c != null)
            lststringccaddress.add(booking.Secondary_Sales_Manager_VP__r.Email);
        
        email.setToAddresses(lststringtoaddress);
        email.setCCAddresses(lststringccaddress);
        email.setHtmlBody(body);
        email.setFileAttachments(fileAttachments);                  
        Messaging.sendEmail(new Messaging.Singleemailmessage[] {email});           
        return null;
    }
}