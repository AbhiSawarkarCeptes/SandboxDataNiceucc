public without sharing class ProformaInvoiceController {

    public static Decimal purchaseprice;
    public static String totalval{get;set;}
    public static Decimal total=0;
    public static String ProformaInvoiceName{get;set;}
    
    public ProformaInvoiceController() {}
        
    public ProformaInvoiceController(ApexPages.StandardController controller){
        opportunity opp = (Opportunity)controller.getRecord();             
     }    
    
    @AuraEnabled
    public static Opportunity getOpportunity(String recId) {
        Opportunity op;
        
        try{
            op =  [Select id, Name,Primary_Name__c ,
                        Other_Applicants_Name__c ,Unit__r.Project__r.Name,Permanent_Address__c,
                        Unit__c,
                        Unit__r.Puchase_Price__c,
                        Account_Mobile_Number__c,Account_Email__c,Unit__r.Project__c, Unit__r.Legal_Entity__r.Favouring__c,
                        Unit__r.Legal_Entity__r.Account_Number_Flat_Cost__c,Unit__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,
                        Unit__r.Legal_Entity__r.IBAN__c, Unit__r.Legal_Entity__r.MICR_Code_Flat_Cost__c,
                        Unit__r.Legal_Entity__r.Branch_Name_Flat_Cost__c,Is_Active_basis_close_date__c,
                        Unit__r.Chargeable_Area__c ,Proforma_Invoice_Type__c,Booking__c
                    
                   FROM Opportunity 
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
            Schema.SObjectType opportunityType = Schema.Opportunity.getSObjectType();
            Schema.SObjectType obj = Id.valueOf(recordId).getSObjectType();
            if (opportunityType == obj) {
                objType = 'Opportunity';
            } else { objType = 'Booking'; }
            return objType;
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static Booking__c getBooking(String recId) {
        Booking__c bk;
        
        try{
            bk =  [Select id, Name,
                        Primary_Applicant_Name__c ,
                        Agreement_Value__c ,
                        Applicant_2_Name__c ,
                        PrimaryMobileNumber__c,
                        Primary_Applicant_Email__c,
                        Primary_Applicant_Address__c,
                        Unit__c,
                        Unit__r.Project__r.Name,
                        Unit__r.Puchase_Price__c,
                        Unit__r.Project__c, 
                        Unit__r.Legal_Entity__r.Favouring__c,
                        Unit__r.Legal_Entity__r.Account_Number_Flat_Cost__c,
                        Unit__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,
                        Unit__r.Legal_Entity__r.IBAN__c, 
                        Unit__r.Legal_Entity__r.MICR_Code_Flat_Cost__c,
                        Unit__r.Legal_Entity__r.Branch_Name_Flat_Cost__c,
                        Unit__r.Chargeable_Area__c
                   FROM Booking__c 
                   WHERE Id =: recId];
                              
            
            
        }catch (Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            return null;
        }
        
        if(bk!=null){  return bk; }else{ return null; }        
    }
    
    @AuraEnabled
    public static Decimal calculate(String selectedOption,Decimal inputValue,Id oppId,Decimal purchasePrice,string recId, Boolean fromBooking) {
        
        Opportunity opp = new Opportunity();
        String opptyId;
        if (fromBooking) {
            Booking__c bk = [Select Id,Opportunity__c From Booking__c where id =:recId]; opptyId = bk.Opportunity__c;
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
        else if(selectedOption=='Amount')
        {        
            
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
        Opportunity opportunityInstance;
        if (!fromBooking) {
            opportunityInstance= [select id,Proforma_Invoice_Type__c,Calculated_Value__c,Proforma_Invoice_Sub_Type__c from Opportunity where Id=:recId];
        } else {
            Booking__c bookingInstance= [select id, Opportunity__c from Booking__c where Id=: recId];
            opportunityInstance= new Opportunity(); opportunityInstance.Id = bookingInstance.Opportunity__c;
        }
        opportunityInstance.Proforma_Invoice_Type__c=ProformaInvoiceTypeApex;
        upsert opportunityInstance; 
            
        if(opportunityInstance.Proforma_Invoice_Type__c=='DLD Amount'){
            opportunityInstance.Input_Value__c=4.00;
            opportunityInstance.Calculated_Value__c= 0.00;
            opportunityInstance.Proforma_Invoice_Sub_Type__c ='';
            upsert opportunityInstance;
        }
        return ProformaInvoiceTypeApex;
      }

      @AuraEnabled
      public static Boolean checkPDFGeneration(Id recId) {
        Boolean pdfGeneration = false;
        String objType;
        Schema.SObjectType opportunityType = Schema.Opportunity.getSObjectType();
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
        Boolean containsCollections=pname.contains('Collection');

        if (!fromBooking) {
            if (pname == 'Sales Operation' || containsCollections == true) {
                proformainv.Opportunity__c = recId; proformainv.Status__c = 'Raised'; insert proformainv;
            } else {
            proformainv.Opportunity__c = recId;
            proformainv.Status__c = 'Unsubmitted';
            insert proformainv;

            /*********************Submit for Approval****************/
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(proformainv.id);
            Approval.ProcessResult result = Approval.process(req1); 
            }

        } else {
            proformainv.Booking__c = recId; proformainv.Status__c = 'Raised';  
            proformainv.Opportunity__c = [Select Id,Opportunity__c From Booking__c where id =:recId].Opportunity__c; 
            insert proformainv;

            //generatePDFFuture(proformainv.id,totalvalue);
        }

        return proformainv.Id;        
    }

    @AuraEnabled
    public static Boolean generatePDFForBooking(String recId, Decimal totalvalue) {
        totalval = string.valueof(totalvalue); 
            PageReference pdf = Page.PerformaInvoice;
            System.debug('PI ID :'+recId);
            pdf.getParameters().put('id',recId);
            pdf.getParameters().put('totalval',totalval);
            pdf.setRedirect(true);       
            Blob body;
            try { 
                body = pdf.getContent(); return true;  
            } 
            catch (VisualforceException e) {
                body = Blob.valueOf('Some Error ');
                return false;
            } 
    }

    @AuraEnabled
    public static void sendEmailAfterApproval(String recId) {

        /*Group salesOpsTeamGroup = [SELECT Id FROM Group WHERE Name= 'RFP Sales Ops Team' LIMIT 1];
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
        }*/

        List<String> emails = new List<String>();
        List<String> ccemails = new List<String>();

        List<Attachment> attachment = [SELECT name FROM Attachment WHERE ParentID =:recId];
        Proforma_Invoice__c proformainv = [Select id, OwnerId, Opportunity__r.Unit__r.name, Booking__r.Name,
                                            Owner_s_Manager__c, Owner_s_Manager_s_Manager__c
                                            From Proforma_Invoice__c
                                            Where id =:recId];

        User ownerUser = [Select id, email From User where id=:proformainv.OwnerId limit 1];

        emails.add(ownerUser.email);

        if (proformainv.Owner_s_Manager__c != null) {
            User manager = [Select id,email from User where id=:proformainv.Owner_s_Manager__c];
            ccemails.add(manager.email);
        }

        if (proformainv.Owner_s_Manager_s_Manager__c != null) {
            User managermanager = [Select id,email from User where id=:proformainv.Owner_s_Manager_s_Manager__c];
            ccemails.add(managermanager.email);
        }

        //Apex Single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emails);
        if (ccemails.size() > 0) {
            mail.setCcAddresses(ccemails);
        }
        mail.setSubject('Request for Payment - Unit -'+proformainv.Opportunity__r.Unit__r.name+' , Booking '+proformainv.Booking__r.Name);
        mail.setHtmlBody('Dear Sales Manager, <br><br>Your request for payment for unit '+proformainv.Opportunity__r.Unit__r.name+' under booking '+ proformainv.Booking__r.Name + ' has been generated.<br><br>Kindly refer the attachment.<br><br>Regards,<br>Sales Force');
        if (!Test.isRunningTest()) { mail.setEntityAttachments(new Id[]{attachment[0].id}); }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    
    @InvocableMethod(label='Generate RFP pdf')
    public static void generatePDF(List<Id> recordIds) {

       //Id oppoId,Decimal totalvalue
       Id recordId = recordIds[0];
       Proforma_Invoice__c rfp=[Select id,Opportunity__c,Booking__c
                                    FROM Proforma_Invoice__c
                                    WHERE Id =: recordId];
        
        
        //totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice;
        pdf.getParameters().put('id',rfp.Id);
        //pdf.getParameters().put('generatepdf','true');
        pdf.setRedirect(true);
        //pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        //pdf.setRedirect(false);       
        Blob body;   
        try {        
            // returns the output of the page as a PDF
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
        Proforma_Invoice__c proformainv = [Select id, Opportunity__r.Unit__r.name, Opportunity__r.Name, Opportunity__r.Opportunity_ID__c
                                            From Proforma_Invoice__c
                                            Where id =:rfp.id];

        //Apex Single email message 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emails);
        mail.setCcAddresses(emailsvpgrp);
        mail.setSubject('Approved : Request for Payment - Unit -'+proformainv.Opportunity__r.Unit__r.name+' , Opportunity '+proformainv.Opportunity__r.Opportunity_ID__c);
        mail.setHtmlBody('Dear Sales Manager, <br><br>Please note, request for payment for unit '+proformainv.Opportunity__r.Unit__r.name+' on opportunity '+ proformainv.Opportunity__r.Opportunity_ID__c + ' has been generated.<br><br>Kindly refer the attachment.<br><br>Regards,<br>Sales Force');
        if (!Test.isRunningTest()) { mail.setEntityAttachments(new Id[]{attachment[0].id});}
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
               
    }

    @AuraEnabled
    public static String generatePDF(Id oppoId,String amountvalue,Decimal percentagevalue,Decimal totalvalue) {
       Opportunity op=[Select id
                       FROM Opportunity
                       WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {        
            // returns the output of the page as a PDF
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Opportunity__c = op.Id;
        insert proformainv;
       
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Opportunity__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );    
        //op.Proforma_Invoice_Number__c =   ProformaInvoiceName ; update op;
        
        
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
       Opportunity op=[Select id
                       FROM Opportunity
                       WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {        
            // returns the output of the page as a PDF
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Opportunity__c = op.Id;
        insert proformainv;
       
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Opportunity__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );    
        //op.Proforma_Invoice_Number__c =   ProformaInvoiceName ; update op;
        
        
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
       Opportunity op=[Select id
                       FROM Opportunity
                       WHERE Id =: oppoId];
        
        
        totalval = string.valueof(totalvalue); 
        PageReference pdf = Page.PerformaInvoice;
        pdf.getParameters().put('id',op.Id);
        pdf.getParameters().put('totalval',totalval); 
        system.debug('i am totalval'+totalval); 
        pdf.setRedirect(true);       
        Blob body;   
        try {        
            // returns the output of the page as a PDF
            body = pdf.getContent();            
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Some Error ');
        }        
        
        /*********************Creation of Proforma Invoice record****************/
        Proforma_Invoice__c proformainv = new Proforma_Invoice__c();
        proformainv.Status__c = 'Raised';
        proformainv.Opportunity__c = op.Id;
        insert proformainv;
       
        
        //updating Opportunity Proforma iNvoice Number 
        Proforma_Invoice__c proformaInvoiceInstance = [select id, Name, Opportunity__c from Proforma_Invoice__c where id =:proformainv.Id];         
        System.debug('NEWLY CREATED PROFORMA INVOICE RECORD ID'+proformaInvoiceInstance.Name);
        ProformaInvoiceName = proformaInvoiceInstance.Name;
        system.debug('NAME++++++++'+ProformaInvoiceName );    
        //op.Proforma_Invoice_Number__c =   ProformaInvoiceName ; update op;
        
        
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