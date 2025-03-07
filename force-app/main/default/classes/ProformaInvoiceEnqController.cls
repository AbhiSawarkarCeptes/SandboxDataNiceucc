public without sharing class ProformaInvoiceEnqController {

    public static Decimal purchaseprice;
    public static String totalval{get;set;}
    public static Decimal total=0;
    public static String ProformaInvoiceName{get;set;}
    
    public ProformaInvoiceEnqController() {}
        
    public ProformaInvoiceEnqController(ApexPages.StandardController controller){
        PropStrength__Request__c opp = (PropStrength__Request__c)controller.getRecord();             
     }    
    
    @AuraEnabled
    public static PropStrength__Request__c getOpportunity(String recId) {
        PropStrength__Request__c op;
        
        try{
            op =  [Select id, Name,PropStrength__Primary_Contact__r.Name, PropStrength__Primary_Contact__c,
                        PropStrength__Selected_Property_Ids__c,PropStrength__Primary_Contact__r.MailingStreet,PropStrength__Primary_Contact__r.Mailing_City__c,
                        PropStrength__Primary_Contact__r.MailingState,PropStrength__Primary_Contact__r.MailingCountry,
                        PropStrength__Primary_Contact__r.MailingPostalCode, PropStrength__Primary_Contact__r.MobilePhone, PropStrength__Primary_Contact__r.Email,
                        Proforma_Invoice_Type__c                    
                        FROM PropStrength__Request__c 
                        WHERE Id =: recId]; 
        }catch (Exception e) {return null;}
        
        if(op!=null){
            return op;
        }else{ return null;}        
    }

    @AuraEnabled
    public static PropStrength__Property__c getProperty(String recId) {
        if(recId != null) {
            if(recId.contains(',')) {
                List<Id> propIdList = recId.split(',');
                recId = propIdList[propIdList.size()-1];
            }
        }
        PropStrength__Property__c op;
        
        try{
            op =  [Select id, Name, PropStrength__Project_Name__r.Name,
                        PropStrength__Total_Sales_Consideration__c,PropStrength__Project_Name__c, 
                        Legal_Entity__r.Favouring__c,Legal_Entity__r.Account_Number__c,
                        Legal_Entity__r.Bank_Name__c,Legal_Entity__r.IBAN__c, 
                        Legal_Entity__r.Swift_Code__c,Legal_Entity__r.Branch__c,
                        PropStrength__Chargeable_Area__c, PropStrength__Super_Area__c,
                        (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Rate_per_unit_Area__c FROM PropStrength__Property_Charges__r), 
                        (SELECT Id, Name FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1)                
                        FROM PropStrength__Property__c 
                        WHERE Id =: recId]; 
        }catch (Exception e) {return null;}
        
        if(op!=null){
            return op;
        }else{ return null;}        
    }

    @AuraEnabled
    public static string objectName(String recordId){
        try {
            String objType;
            Schema.SObjectType opportunityType = Schema.PropStrength__Request__c.getSObjectType();
            Schema.SObjectType obj = Id.valueOf(recordId).getSObjectType();
            if (opportunityType == obj) {
                objType = 'PropStrength__Request__c';
            } /*else { 
                objType = 'Booking'; 
            }*/
            return objType;
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static PropStrength__Application_Booking__c getBooking(String recId) {
        PropStrength__Application_Booking__c bk;
        
        try{
            bk =  [Select id, Name,
                        (SELECT Id, Name, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c, PropStrength__Applicant_Mobile__c, 
                        PropStrength__Applicant_Address__c 
                        FROM PropStrength__Applicant_Details__r WHERE PropStrength__Active__c = TRUE),
                        PropStrength__Property__c,
                        PropStrength__Property__r.PropStrength__Project_Name__r.Name,
                        PropStrength__Property__r.PropStrength__Project_Name__c, 
                        PropStrength__Property__r.Legal_Entity__r.Favouring__c,
                        PropStrength__Property__r.Legal_Entity__r.IBAN__c, 
                        PropStrength__Property__r.PropStrength__Chargeable_Area__c
                        FROM PropStrength__Application_Booking__c 
                        WHERE Id =: recId]; //Agreement_Value__c,Unit__r.Puchase_Price__c,PropStrength__Property__r.Legal_Entity__r.Account_Number__c,PropStrength__Property__r.Legal_Entity__r.Bank_Name__c,PropStrength__Property__r.Legal_Entity__r.Swift_Code__c,PropStrength__Property__r.Legal_Entity__r.Branch__c,
        }catch (Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            return null;
        }
        
        if(bk!=null){  return bk; }else{ return null; }        
    }
    
    @AuraEnabled
    public static Decimal calculate(String selectedOption,Decimal inputValue,Id oppId,Decimal purchasePrice,string recId, Boolean fromBooking) {
        PropStrength__Request__c opp = new PropStrength__Request__c();
        String opptyId;
        if (fromBooking) {
            PropStrength__Application_Booking__c bk = [Select Id,PropStrength__Offer__r.PropStrength__Request__c From PropStrength__Application_Booking__c where id =:recId]; 
            opptyId = bk.PropStrength__Offer__r.PropStrength__Request__c;
        } else {
            opptyId = recId;
        }
        
        if(selectedOption=='Percentage'){  
            total = (purchasePrice != null ?purchasePrice *inputValue/100:0);
            opp.Id = opptyId;
            opp.Proforma_Invoice_Sub_Type__c ='Percentage';  
            opp.Calculated_Value__c=total;
            opp.Input_Value__c= inputValue;
            upsert opp;
            system.debug('TotalAMOUNT++++'+total);
        }
        else if(selectedOption=='Amount') {        
            total= (purchasePrice != null ?inputValue/purchasePrice*100:0);
            opp.Id = opptyId;
            opp.Proforma_Invoice_Sub_Type__c ='Amount'; 
            opp.Calculated_Value__c= total;
            opp.Input_Value__c=inputValue;
            upsert opp; 
        }              
        return total.setScale(2);
    }
    
    @AuraEnabled
    public static String updateParent(String ProformaInvoiceTypeApex, Id recId, Boolean fromBooking ){
        PropStrength__Request__c opportunityInstance;
        if (!fromBooking) {
            opportunityInstance= [select id,Proforma_Invoice_Type__c,Calculated_Value__c,Proforma_Invoice_Sub_Type__c, Recent_Property_Purchase_Price__c from PropStrength__Request__c where Id=:recId];
        } else {
            PropStrength__Application_Booking__c bookingInstance= [select id, PropStrength__Offer__r.PropStrength__Request__c from PropStrength__Application_Booking__c where Id=: recId];
            opportunityInstance= new PropStrength__Request__c(); 
            opportunityInstance.Id = bookingInstance.PropStrength__Offer__r.PropStrength__Request__c;
        }
        opportunityInstance.Proforma_Invoice_Type__c=ProformaInvoiceTypeApex;
        upsert opportunityInstance; 
            
        if(opportunityInstance.Proforma_Invoice_Type__c=='DLD Amount'){
            opportunityInstance.Input_Value__c=4.00;
            opportunityInstance.Calculated_Value__c= opportunityInstance.Recent_Property_Purchase_Price__c != null ? opportunityInstance.Recent_Property_Purchase_Price__c * 0.04 : 0;
            opportunityInstance.Proforma_Invoice_Sub_Type__c ='';
            upsert opportunityInstance;
        }
        return ProformaInvoiceTypeApex;
    }

    @AuraEnabled
    public static Boolean checkPDFGeneration(Id recId) {
        Boolean pdfGeneration = false;
        String objType;
        Schema.SObjectType opportunityType = Schema.PropStrength__Request__c.getSObjectType();
        Schema.SObjectType obj = Id.valueOf(recId).getSObjectType();
        if (opportunityType == obj) {
            Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
            String pname = p.name;
            if (pname == 'Sales Operation') {
                pdfGeneration = true;
            }
        } else {
            pdfGeneration = true;
        } 
        return pdfGeneration;
    }

    @AuraEnabled
    public static String createAndSubmit(Id recId,String amountvalue,Decimal percentagevalue,Decimal totalvalue, Boolean fromBooking) {
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;

        if (!fromBooking) {
            if (pname == 'Sales Operation') {
                proformainv.Enquiry__c = recId; proformainv.Status__c = 'Raised'; insert proformainv;
            } else {
                proformainv.Enquiry__c = recId;
                proformainv.Status__c = 'Unsubmitted';
                insert proformainv;

                /*********************Submit for Approval****************/
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(proformainv.id);
                Approval.ProcessResult result = Approval.process(req1); 
            }
        } else {
            // proformainv.Booking__c = recId; 
            proformainv.Status__c = 'Raised';  
            proformainv.Enquiry__c = [Select Id,PropStrength__Offer__r.PropStrength__Request__c From PropStrength__Application_Booking__c where id =:recId].PropStrength__Offer__r.PropStrength__Request__c; 
            insert proformainv;
        }

        return proformainv.Id;        
    }

    @AuraEnabled
    public static Boolean generatePDFForBooking(String recId, Decimal totalvalue) {
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice2;
        System.debug('PI ID :'+recId);
        pdf.getParameters().put('id',recId);
        pdf.getParameters().put('totalval',totalval);
        pdf.setRedirect(true);       
        Blob body;
        try { 
            body = pdf.getContent(); 
            return true;  
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
            return false;
        } 
    }

    @AuraEnabled
    public static void sendEmailAfterApproval(String recId) {
        List<String> emails = new List<String>();
        List<String> ccemails = new List<String>();

        List<Attachment> attachment = [SELECT name FROM Attachment WHERE ParentID =:recId];
        Proforma_Invoice__c proformainv = [Select id, OwnerId,Enquiry__r.PropStrength__Selected_Property_Ids__c,
                                            Owner_s_Manager2__c, Owner_s_Manager_s_Manager2__c
                                            From Proforma_Invoice__c
                                            Where id =:recId];

        PropStrength__Property__c op = new PropStrength__Property__c();

        if(proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c != null) {
            String propId;
            if(!proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c.contains(',')) {
                propId = proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c;
            } else {
                List<Id> propIdList = proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c.split(',');
                propId = propIdList[propIdList.size()-1];
            }
            op =  [Select id, PropStrength__Property_Name__c, Name, PropStrength__Project_Name__r.Name,
                PropStrength__Total_Sales_Consideration__c,PropStrength__Project_Name__c, 
                Legal_Entity__r.Favouring__c,Legal_Entity__r.Account_Number__c,
                Legal_Entity__r.Bank_Name__c,Legal_Entity__r.IBAN__c, 
                Legal_Entity__r.Swift_Code__c,Legal_Entity__r.Branch__c,
                PropStrength__Chargeable_Area__c, 
                (SELECT Id, Name FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1)                
                FROM PropStrength__Property__c 
                WHERE Id =: propId]; 
        }

        User ownerUser = [Select id, email From User where id=:proformainv.OwnerId limit 1];

        emails.add(ownerUser.email);

        if (proformainv.Owner_s_Manager2__c != null) {
            User manager = [Select id,email from User where id=:proformainv.Owner_s_Manager2__c];
            ccemails.add(manager.email);
        }

        if (proformainv.Owner_s_Manager_s_Manager2__c != null) {
            User managermanager = [Select id,email from User where id=:proformainv.Owner_s_Manager_s_Manager2__c];
            ccemails.add(managermanager.email);
        }

        //Apex Single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emails);
        if (ccemails.size() > 0) {
            mail.setCcAddresses(ccemails);
        }
        mail.setSubject('Request for Payment - Unit -'+(op != null && op.PropStrength__Property_Name__c != null ? op.PropStrength__Property_Name__c : '')+' , Booking ' + (op != null && !op.PropStrength__Application_Booking__r.isEmpty() ? op.PropStrength__Application_Booking__r[0].Name : ''));
        mail.setHtmlBody('Dear Sales Manager, <br><br>Your request for payment for unit '+(op != null && op.PropStrength__Property_Name__c != null ? op.PropStrength__Property_Name__c : '')+' under booking '+(op != null && !op.PropStrength__Application_Booking__r.isEmpty() ? op.PropStrength__Application_Booking__r[0].Name : '') + ' has been generated.<br><br>Kindly refer the attachment.<br><br>Regards,<br>Sales Force');
        if (!Test.isRunningTest()) { mail.setEntityAttachments(new Id[]{attachment[0].id}); }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    
    @InvocableMethod(label='Generate RFP pdf')
    public static void generatePDF(List<Id> recordIds) {
       //Id oppoId,Decimal totalvalue
        Id recordId = recordIds[0];
        Proforma_Invoice__c rfp=[Select id,Enquiry__c 
                                    FROM Proforma_Invoice__c
                                    WHERE Id =: recordId]; //Booking__c
        
        
        PageReference pdf = Page.PerformaInvoice2;
        pdf.getParameters().put('id',rfp.Id);
        pdf.setRedirect(true); 
        system.debug('i am totalval'+totalval);      
        Blob body;   
        try {        
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }    
        
        Group salesOpsTeamGroup = [SELECT Id FROM Group WHERE Name= 'RFP Sales Ops Team' LIMIT 1];
        Group vpGroup = [SELECT Id FROM Group WHERE Name= 'RFP Sales Ops VP Director' LIMIT 1];
        List<GroupMember> salesOpsTeam = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =:salesOpsTeamGroup.Id];
        List<GroupMember> vpTeam = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =:vpGroup.Id];


        List<Id> userIds = new List<Id>();
        for (GroupMember gm:salesOpsTeam) {
            userIds.add(gm.UserOrGroupId);
        }

        if (userIds.size() < 1) return; 

        List<Id> vpGrpIds = new List<Id>();
        for (GroupMember gm:vpTeam) {
            vpGrpIds.add(gm.UserOrGroupId);
        }


        List<User> users = [Select id,email from User where id IN:userIds];
        List<String> emails = new List<String>();
        for (User u:users) {
            emails.add(u.email);
        }

        List<User> usersVpGrp = [Select id,email from User where id IN:vpGrpIds];
        List<String> emailsvpgrp = new List<String>();
        for (User u:users) {
            emailsvpgrp.add(u.email);
        }

        List<Attachment> attachment = [SELECT name FROM Attachment WHERE ParentID =:rfp.id];
        Proforma_Invoice__c proformainv = [Select id, Enquiry__r.Name,  Enquiry__r.PropStrength__Selected_Property_Ids__c
                                            From Proforma_Invoice__c
                                            Where id =:rfp.id];

        PropStrength__Property__c op = new PropStrength__Property__c();

        if(proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c != null) {
            String propId;
            if(!proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c.contains(',')) {
                propId = proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c;
            } else {
                List<Id> propIdList = proformainv.Enquiry__r.PropStrength__Selected_Property_Ids__c.split(',');
                propId = propIdList[propIdList.size()-1];
            }
            op =  [Select id, PropStrength__Property_Name__c, Name, PropStrength__Project_Name__r.Name,
                PropStrength__Total_Sales_Consideration__c,PropStrength__Project_Name__c, 
                Legal_Entity__r.Favouring__c,Legal_Entity__r.Account_Number__c,
                Legal_Entity__r.Bank_Name__c,Legal_Entity__r.IBAN__c, 
                Legal_Entity__r.Swift_Code__c,Legal_Entity__r.Branch__c,
                PropStrength__Chargeable_Area__c, 
                (SELECT Id, Name FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE ORDER BY CreatedDate DESC LIMIT 1)                
                FROM PropStrength__Property__c 
                WHERE Id =: propId]; 
        }

        //Apex Single email message 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emails);
        mail.setCcAddresses(emailsvpgrp);
        mail.setSubject('Approved : Request for Payment - Unit -'+(op != null && op.PropStrength__Property_Name__c != null ? op.PropStrength__Property_Name__c : '')+' , Opportunity '+proformainv.Enquiry__r.Name);
        mail.setHtmlBody('Dear Sales Manager, <br><br>Please note, request for payment for unit '+(op != null && op.PropStrength__Property_Name__c != null ? op.PropStrength__Property_Name__c : '')+' on opportunity '+ proformainv.Enquiry__r.Name + ' has been generated.<br><br>Kindly refer the attachment.<br><br>Regards,<br>Sales Force');
        if (!Test.isRunningTest()) { mail.setEntityAttachments(new Id[]{attachment[0].id});}
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @AuraEnabled
    public static String generatePDF(Id oppoId,String amountvalue,Decimal percentagevalue,Decimal totalvalue) {
        PropStrength__Request__c op=[Select id
                        FROM PropStrength__Request__c
                        WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice2;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {        
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Enquiry__c = op.Id;
        insert proformainv;
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Enquiry__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );    
        
        
        if(proformainv.Id !=null ){
            Attachment attachmentProformaInvoice = new Attachment();
            attachmentProformaInvoice.Body = body;
            attachmentProformaInvoice.Name = 'ProformaInvoice'+System.now()+'.pdf';
            attachmentProformaInvoice.IsPrivate = false;
            attachmentProformaInvoice.ParentId = proformainv.Id;
            attachmentProformaInvoice.ContentType='application/pdf';
            
            upsert attachmentProformaInvoice ;
            System.debug('NEWLY CREATED PROFORMA INVOICE CREATED------');        
        }
        return proformainv.Id;        
    }

    @AuraEnabled
    public static String generatePDF2(Id oppoId,String amountvalue,Decimal percentagevalue,Decimal totalvalue) {
        PropStrength__Request__c op=[Select id
                        FROM PropStrength__Request__c
                        WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice2;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {        
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Enquiry__c = op.Id;
        insert proformainv;
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Enquiry__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );  
        
        
        if(proformainv.Id !=null ){
            Attachment attachmentProformaInvoice = new Attachment();
            attachmentProformaInvoice.Body = body;
            attachmentProformaInvoice.Name = 'ProformaInvoice'+System.now()+'.pdf';
            attachmentProformaInvoice.IsPrivate = false;
            attachmentProformaInvoice.ParentId = proformainv.Id;
            attachmentProformaInvoice.ContentType='application/pdf';
            
            upsert attachmentProformaInvoice ;
            System.debug('NEWLY CREATED PROFORMA INVOICE CREATED------');        
        }
        return proformainv.Id;        
    }

    @AuraEnabled
    public static String generatePDF3(Id oppoId,String amountvalue,Decimal percentagevalue,Decimal totalvalue) {
        PropStrength__Request__c op=[Select id
                        FROM PropStrength__Request__c
                        WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice2;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {    
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Enquiry__c = op.Id;
        insert proformainv;
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Enquiry__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );

        if(proformainv.Id !=null ){
            Attachment attachmentProformaInvoice = new Attachment();
            attachmentProformaInvoice.Body = body;
            attachmentProformaInvoice.Name = 'ProformaInvoice'+System.now()+'.pdf';
            attachmentProformaInvoice.IsPrivate = false;
            attachmentProformaInvoice.ParentId = proformainv.Id;
            attachmentProformaInvoice.ContentType='application/pdf';
            
            upsert attachmentProformaInvoice ;
            System.debug('NEWLY CREATED PROFORMA INVOICE CREATED------');        
        }
        return proformainv.Id;        
    }
}