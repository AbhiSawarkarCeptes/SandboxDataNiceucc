//testClass: brokerRegistrationTriggerTest
public class brokerRegistrationTrghandler {
    
    public static String renewalRecTypeId = Schema.SObjectType.Broker_Registration__C.getRecordTypeInfosByName().get('Renewal').getRecordTypeId(); 
    
    public static void beforeupdate(List<Broker_Registration__c> newList, Map<ID,Broker_Registration__c> oldMap){
        validateRegistrationNumber(newList, oldMap);
        list<Broker_Registration__c> brToValidateAccess = new list<Broker_Registration__c>();
        
        for(Broker_Registration__c bR : newList){
            if(bR.RecordTypeId != renewalRecTypeId) {
                System.debug('bR.RecordTypeId '+bR.RecordTypeId );
                System.debug('renewalRecTypeId '+renewalRecTypeId );
                preventUpdateOfRecord(bR, oldMap.get(bR.Id));
            }
            
            if((bR.All_Mandatory_Documents__c && bR.All_Mandatory_Documents__c != oldMap.get(bR.Id).All_Mandatory_Documents__c) || (bR.All_Mandatory_Non_Mandatory_Documents__c  && bR.All_Mandatory_Non_Mandatory_Documents__c  != oldMap.get(bR.Id).All_Mandatory_Non_Mandatory_Documents__c)){
                brToValidateAccess.add(bR);
            }
        } 
        if(brToValidateAccess.size()>0){
            brokerRegistrationTrghandler.brToValidateDocumentChecklistAccess(brToValidateAccess);
        }
    }
    
    public static void preventUpdateOfRecord(Broker_Registration__c newBr, Broker_Registration__c oldBr){
        Id userId = userinfo.getProfileId();
        String profileName = [Select Name from Profile where Id =:userId].Name;
        Broker_Registration_Settings__mdt brConfig = Broker_Registration_Settings__mdt.getInstance('Config');
        List<String> statusList = brConfig.Exception_Status_Prevent_Edit_CHRM__c.split(',');
        List<String> profileList = brConfig.Profile_Allowed_to_Edit__c.split(',');
        System.debug('Profile Name : '+profileName);
        System.debug('Profile Name : '+profileList+' new BR.Status : '+newBr.Status__c);
        System.debug('old BR Status : '+oldBr.Status__c+' new BR.Renewal_Status__c : '+newBr.Renewal_Status__c);
    }
    
    //---Send Email Notification Email to Channel Manager informing Agreement is rejected by Channel Ops   
    public static void sendRejectionEmail(Broker_Registration__c brokerReg,String latestComments) {
        
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        
        // Create the email content
        String subject = 'Broker Registration – ' + brokerReg.Name_as_per_trade_license__c + '- Rejected by Channel OPS';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ',\n\n' +
            'This is to inform you that the Broker Registration Request for ' + brokerReg.Name_as_per_trade_license__c + 
            ' has been rejected due to ' + latestComments + '.\n' +
            'Request you to review and provide the required information/documents and submit for approval.\n\n' +
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    //---Send Email Notification Email to Broker informing Registration is rejected by Channel Manager   
    public static void sendRejectionEmailtoBroker(Broker_Registration__c brokerReg,String latestComments) {
        
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c,Registration_Link__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        
        // Create the email content
        String subject = 'Broker Registration – ' + brokerReg.Name_as_per_trade_license__c + '- Rejected';
        System.debug('subject:'+subject);
        String body = 'Dear ' + brokerReg.Name_as_per_trade_license__c + ',\n\n' +
            'This is to inform you that the Broker Registration Request for ' + brokerReg.Name_as_per_trade_license__c + 
            ' has been rejected due to \'' + latestComments + '\'.\n' +
            'Request you to review and provide the required information/documents using the below link.\n' +
            brokerReg.Registration_Link__c +'\n\n'+
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        ccAddresses.add(Label.SF_Notifications);
        
        if (brokerReg.Email__c != null) {
            toAddresses.add(brokerReg.Email__c);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setccAddresses(ccAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }    
    /*public static void SendRenewalReviewDocEmail(Broker_Registration__c brokerReg) {
brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
Owner.Email 
FROM Broker_Registration__c 
WHERE Id = :brokerReg.Id];
System.debug('brokerReg:'+brokerReg);
String ownerEmail = brokerReg.Owner.Email;
String ownerName = brokerReg.Owner.Name;
System.debug('ownerEmail ' + ownerEmail);
System.debug('RecordType.Name'+brokerReg.RecordType.Name);
System.debug('ownerName: ' + ownerName);

// Create the email content
String subject = 'Broker Renewed Agreement Approval - ' + brokerReg.Name_as_per_trade_license__c ;
System.debug('subject:'+subject);
String body = 'Dear CHRM Ops Team,\n\n' +
'This is to inform you that the Renewed Agreement for ' + brokerReg.Name_as_per_trade_license__c +' has been generated.\n' +
'Request you to review and approve the Agreement. Once approved, Agreement is further sent to broker for signature.\n\n' +
'Thanks,\nSobha Realty';
System.debug('body:'+body);
System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
List<String> toAddresses = new List<String>();

if (ownerEmail != null) {
toAddresses.add(ownerEmail);
}
// Send the email
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
email.setToAddresses(toAddresses);
email.setSubject(subject);
email.setPlainTextBody(body);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
}*/
    public static void SendAlldocumentUploadRegistrationEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c,crmOps__r.Name,crmOps__r.Email, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String CHRMOpsemail = brokerReg.crmOps__r.Email;
        
        System.debug('CHRMOpsemail ' + CHRMOpsemail);
        System.debug('RecordType.Name'+brokerReg.RecordType.Name);

        // Create the email content
        String subject = 'Broker Registration -' + brokerReg.Name_as_per_trade_license__c+'- All Missing Documents Uploaded.' ;
        System.debug('subject:'+subject);
        String body = 'Dear CHRM Ops Team,\n\n' +
            'This is to inform you that in regard to the Broker Registration for ' + brokerReg.Name_as_per_trade_license__c +' Channel Manager has uploaded all the missing documents.\n\n' +
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        
        if (CHRMOpsemail != null) {
            toAddresses.add(CHRMOpsemail);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    //Renewal
    public static void SendAlldocumentUploadRenewalEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,crmOps__r.Name, crmOps__r.Email,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.crmOps__r.Email;
        String ownerName = brokerReg.Owner.Name;
        String ChannelOpsExecutiveEmail = brokerReg.crmOps__r.Email;
        
        // Create the email content
        String subject = 'Broker Renewed Agreement Approval - ' + brokerReg.Name_as_per_trade_license__c +'– All Missing Documents Uploaded' ;
        System.debug('subject:'+subject);
        String body = 'Dear CHRM Ops Team,\n\n' +
            'This is to inform you that in regard to the Agreement Renewal for ' + brokerReg.Name_as_per_trade_license__c +' - Channel Manager has uploaded all the missing documents.\n\n' +
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        toAddresses.add(ChannelOpsExecutiveEmail);
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public static void SendBrokerReviewDocEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        System.debug('ownerEmail ' + ownerEmail);
        System.debug('RecordType.Name'+brokerReg.RecordType.Name);
        System.debug('ownerName: ' + ownerName);
        
        // Create the email content
        String subject = 'Broker Renewed Agreement Approval - ' + brokerReg.Name_as_per_trade_license__c ;
        System.debug('subject:'+subject);
        String body = 'Dear CHRM Ops Team,\n\n' +
            'This is to inform you that the Broker Registration Agreement for ' + brokerReg.Name_as_per_trade_license__c +' has been generated.\n' +
            'Request you to review and approve the Agreement. Once approved, Agreement is further sent to broker for signature.\n\n' +
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public static void sendRejectionRenewalEmail(Broker_Registration__c brokerReg,String latestComments) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,RecordType.Name, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        
        
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        System.debug('ownerEmail ' + ownerEmail);
        System.debug('RecordType.Name'+brokerReg.RecordType.Name);
        System.debug('ownerName: ' + ownerName);
        
        System.debug('LatestComments'+latestComments);
        
        // Create the email content
        String subject = 'Broker Agreement Renewal –' + brokerReg.Name_as_per_trade_license__c + '- Rejected by Channel OPS.';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ',\n\n' +
            'This is to inform you that the Agreement Renewal Request for' + brokerReg.Name_as_per_trade_license__c + 
            ' has been rejected due to ' + latestComments+ '.\n' +
            'Request you to review and provide the required information/documents and submit for approval.\n\n' +
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    //FOR STATUS--Agreement created and sent for signature---Shaik Rehaman
    public static void SendAgreementForSignatureEmail(Broker_Registration__c brokerReg) {
        System.debug('brokerReg under Aggreement :'+brokerReg);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        // Create the email content
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Registration  – ' + brokerReg.Name_as_per_trade_license__c + '- Agreement sent for Signature.';
        System.debug('subject:'+subject);
        String body = 'Dear ' +ownerName + ',\n\n' +
            'This is to inform you that the Broker Registration Agreement for  '  + brokerReg.Name_as_per_trade_license__c +  '  has been sent to their registered email address for signature.\n\n'+ 
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public static void SendRenewalAgreementForSignatureEmail(Broker_Registration__c brokerReg) {
        System.debug('brokerReg under Aggreement :'+brokerReg);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        // Create the email content
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Agreement  Renewal  – ' + brokerReg.Name_as_per_trade_license__c + '- Renewal Agreement sent for Signature.';
        System.debug('subject:'+subject);
        String body = 'Dear ' +ownerName + ',\n\n' +
            'This is to inform you that the Renewed Agreement for  '  + brokerReg.Name_as_per_trade_license__c +  ' has been sent to their registered email address for signature.\n\n'+ 
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    //FOR STATUS --Signed Agreement Received - Documents Awaited---Shaik Rehaman
    public static void sendSignedAgreementReceivedEmail(Broker_Registration__c brokerReg) {
        System.debug('brokerReg under Received Signed documents :'+brokerReg);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        System.debug('ownerEmail:'+ownerEmail);
        System.debug('ownerName:'+ownerName);
        
        // Create the email content
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Registration – ' + brokerReg.Name_as_per_trade_license__c + '- Signed Agreement Received';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ',\n\n' +
            'This is to inform you that the Broker Registration Agreement for '  + brokerReg.Name_as_per_trade_license__c +  ' has been signed by the Broker. Kindly upload missing documents (if any) for further processing.\n\n'+ 
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public static void SendRenewalSignedAgreementReceivedEmail(Broker_Registration__c brokerReg) {
        System.debug('brokerReg under Received Signed documents :'+brokerReg);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        System.debug('ownerEmail:'+ownerEmail);
        System.debug('ownerName:'+ownerName);
        
        // Create the email content
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Agreement Renewal  – ' + brokerReg.Name_as_per_trade_license__c + '- Signed Renewal Agreement Received.';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ',\n\n' +
            'This is to inform you that the Renewed Agreement for '  + brokerReg.Name_as_per_trade_license__c +  ' has been signed by the Broker. Kindly upload missing documents (if any) for further processing.\n\n'+ 
            
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        
    }
    
    //NOC Rejected by Audit & Executed Agreement ready Sent to Broker.//developed by--Shaik Rehaman 
    public static void SendRejectAuditEmail(Broker_Registration__c brokerReg,String latestComment) {
        System.debug('Call NOC Rejected by Audit :'+brokerReg);
        System.debug('latestComment :'+ latestComment);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,crmOps__r.Name, crmOps__r.Email ,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        String ChannelOpsExecutiveEmail = brokerReg.crmOps__r.Email;
        //String ChannelOpsExecutiveEmail = 'shaik.rehaman@ceptes.onmicrosoft.com';
        
        String ChannelOpsExecutiveName = brokerReg.crmOps__r.Name;
        System.debug('ownerEmail:'+ownerEmail);
        System.debug('ownerName:'+ownerName);
        System.debug('ChannelOpsExecutiveEmail:'+ChannelOpsExecutiveEmail);
        System.debug('ChannelOpsExecutiveName:'+ChannelOpsExecutiveName);
        
        // Add both Channel Ops Executive and Owner's email to the recipient list
        List<String> toAddresses = new List<String>();
        toAddresses.add(ChannelOpsExecutiveEmail);
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Registration - ' + brokerReg.Name_as_per_trade_license__c + '- NOC Rejected by Channel Ops Audit';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ' / ' + ChannelOpsExecutiveName  +',\n\n' +
            'This is to inform you that the NOC for '  + brokerReg.Name_as_per_trade_license__c +  'has been rejected by Channel Ops Audit due to '+ latestComment + '.\n\n'+ 
            'Request you to review and provide the required information/documents and submit for approval.\n\n'+ 
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    public static void SendRejectRenewalAuditEmail(Broker_Registration__c brokerReg,String latestComment) {
        System.debug('Call NOC Rejected by Audit :'+brokerReg);
        System.debug('latestComment :'+ latestComment);
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,crmOps__r.Name, crmOps__r.Email ,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        String ChannelOpsExecutiveEmail = brokerReg.crmOps__r.Email;
        //String ChannelOpsExecutiveEmail = 'shaik.rehaman@ceptes.onmicrosoft.com';
        
        String ChannelOpsExecutiveName = brokerReg.crmOps__r.Name;
        System.debug('ownerEmail:'+ownerEmail);
        System.debug('ownerName:'+ownerName);
        System.debug('ChannelOpsExecutiveEmail:'+ChannelOpsExecutiveEmail);
        System.debug('ChannelOpsExecutiveName:'+ChannelOpsExecutiveName);
        
        // Add both Channel Ops Executive and Owner's email to the recipient list
        List<String> toAddresses = new List<String>();
        toAddresses.add(ChannelOpsExecutiveEmail);
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Agreement Renewal  - ' + brokerReg.Name_as_per_trade_license__c + '- Renewal NOC Rejected by Channel Ops Audit';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ' / ' + ChannelOpsExecutiveName  +',\n\n' +
            'This is to inform you that the renewal NOC for '  + brokerReg.Name_as_per_trade_license__c +  ' has been rejected by Channel Ops Audit due to '+ latestComment + '.\n\n'+ 
            'Request you to review and provide the required information/documents and submit for approval.\n\n'+ 
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    //Notification Email to Channel OPS informing NOC is rejected by Audit--Renewal //developed by--Shaik Rehaman 
    public static void SendRenewalRejectAuditEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, Email__c,crmOps__r.Name, crmOps__r.Email ,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        String ChannelOpsExecutiveEmail = brokerReg.crmOps__r.Email;
        String ChannelOpsExecutiveName = brokerReg.crmOps__r.Name;
        
        
        // Add both Channel Ops Executive and Owner's email to the recipient list
        List<String> toAddresses = new List<String>();
        toAddresses.add(ChannelOpsExecutiveEmail);
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        String subject = 'Broker Agreement Renewal -' + brokerReg.Name_as_per_trade_license__c + '- Renewal NOC Rejected by Channel Ops Audit.';
        System.debug('subject:'+subject);
        String body = 'Dear ' + ownerName + ' / ' + ChannelOpsExecutiveName  +',\n\n' +
            'This is to inform you that the Renewed NOC for '  + brokerReg.Name_as_per_trade_license__c +  ' has been rejected by Channel Ops Audit due to  '+ brokerReg.Comments__c + '.\n\n'+ 
            'Request you to review and provide the required information/documents and submit for approval.\n\n'+ 
            'Thanks,\nSobha Realty';
        System.debug('body:'+body);
        System.debug(' brokerReg.Email__c '+ brokerReg.Email__c );
        // Send the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    
    //recordtype--New
    public static void SendExecuteBrokerEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c,owner.Firstname,Owner.Lastname, Email__c,crmOps__r.Name, crmOps__r.Email ,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        
        //String ChannelOpsExecutiveEmail = 'shaik.rehaman@ceptes.onmicrosoft.com';
        
        system.debug('owner:'+brokerReg.Owner);
        system.debug('ownerName:'+brokerReg.Owner.name);
        system.debug('brokerReg.Owner.FirstName:'+brokerReg.Owner.FirstName);
        system.debug('LastName:'+brokerReg.Owner.Lastname);
        Contact dummyContact = new Contact(FirstName = 'Test', LastName = String.valueOf(System.Today()));
        System.debug('dummyContact :'+dummyContact);
        insert dummyContact;
        
        // Add both Channel Ops Executive and Owner's email to the recipient list
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        } 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // email.setTargetObjectId(brokerReg.OwnerId);
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'BrokerExecutedDocs_brokerRegCHRM' LIMIT 1];
        email.setTemplateId(template.Id);
        email.setWhatId(brokerReg.Id);
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setTargetObjectId(dummyContact.Id); 
        email.setTreatTargetObjectAsRecipient(false);
        email.setSaveAsActivity(false);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        
        delete dummyContact;
    }
    
    //RecordType--Renewal
    public static void SendExecuteBrokerRenewalEmail(Broker_Registration__c brokerReg) {
        brokerReg = [SELECT Id, Name_as_per_trade_license__c, owner.Firstname,Owner.Lastname, Email__c,crmOps__r.Name, crmOps__r.Email ,CHRM_Manager_Email__c, frmCHRMMgrName__c, Comments__c,Owner.Name, 
                     Owner.Email 
                     FROM Broker_Registration__c 
                     WHERE Id = :brokerReg.Id];
        System.debug('brokerReg:'+brokerReg);
        String ownerEmail = brokerReg.Owner.Email;
        String ownerName = brokerReg.Owner.Name;
        String ChannelOpsExecutiveEmail = brokerReg.crmOps__r.Email;
        //String ChannelOpsExecutiveEmail = 'shaik.rehaman@ceptes.onmicrosoft.com';
        //Contact dummyContact = new Contact(FirstName = brokerReg.Owner.FirstName, LastName = brokerReg.Owner.Lastname);
        Contact dummyContact = new Contact(FirstName = 'Test', LastName = String.ValueOf(System.TODAY()));
        System.debug('dummyContact :'+dummyContact);
        insert dummyContact;
        String ChannelOpsExecutiveName = brokerReg.crmOps__r.Name;
        
        // Add both Channel Ops Executive and Owner's email to the recipient list---depricateChannelOpsExecutiveEmail
        List<String> toAddresses = new List<String>();
        
        if (ownerEmail != null) {
            toAddresses.add(ownerEmail);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setTargetObjectId(brokerReg.OwnerId);
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'BrokerExecutedDocs_brokerRenewal' LIMIT 1];
        email.setTemplateId(template.Id);
        email.setWhatId(brokerReg.Id);
        email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
        email.setToAddresses(toAddresses);
        email.setTargetObjectId(dummyContact.Id); 
        email.setTreatTargetObjectAsRecipient(false);
        email.setSaveAsActivity(false);
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        delete dummyContact;
    }
    
    public static void brToValidateDocumentChecklistAccess(list<Broker_Registration__c> brToValidateAccess){
        list<Group> groups = [Select Id from Group where type='Queue' and (DeveloperName='Sobha_Connect_Queue' OR DeveloperName='Broker_Category_Queue')];
        list<string> sobhaConnectQueueMembers = new list<string>();
        list<string> brokerCategoryQueueMembers = new list<string>();
        for(GroupMember gm : [Select UserOrGroupId, Group.DeveloperName From GroupMember where GroupId IN: groups]){
            if(gm.Group.DeveloperName == 'Sobha_Connect_Queue')
                sobhaConnectQueueMembers.add(gm.UserOrGroupId);
            else
                brokerCategoryQueueMembers.add(gm.UserOrGroupId);
        }
        id profileId = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =: profileId].Name;
        for(Broker_Registration__c bR : brToValidateAccess){
            string category = bR.Broker_Category__c;
            if(category.contains('Sobha Connect')){
                if(!sobhaConnectQueueMembers.contains(UserInfo.getUserId()) && profileName!='System Administrator'){
                    bR.addError('You do not have access to update document checklist.');
                }
            }
            else {
                if(!brokerCategoryQueueMembers.contains(UserInfo.getUserId()) && profileName!='System Administrator'){
                    bR.addError('You do not have access to update document checklist.');
                }
            }
        }
    }
    
    public static void validateRegistrationNumber(List<Broker_Registration__c> newList, Map<ID,Broker_Registration__c> oldMap){
        Broker_Registration_Settings__mdt brConfig = Broker_Registration_Settings__mdt.getInstance('Config');
        if(newList.size()>0 && brConfig.Duplication_Check_for_Registration_No__c){
            Id newRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
            Map<String, Id> dupCheckMap = new Map<String, Id>();
            Set<String> blacklistedLicenses = new Set<String>();
            list<String> cpRegNoList = new List<String>();
            list<String> scRegNoList = new List<String>();
            list<String> regNoList = new List<String>();
            Map<String, String> categoryMap = new Map<String, String>();
            Id currentUser = UserInfo.getUserId();
            for(Broker_Registration__c br: newList){
                if(String.IsNotBlank(br.Registration_Number__c)){   //Added this to bypass validation for Broker registration internal for 
                    if(br.Broker_Category__c.startswith('Broker')){
                        cpRegNoList.add(br.Registration_Number__c);  
                    }
                    else {
                        scRegNoList.add(br.Registration_Number__c);
                    }
                    regNoList.add(br.Registration_Number__c);
                    categoryMap.put(br.Registration_Number__c,br.Broker_Category__c);
                    System.debug('categoryMap:'+categoryMap);
                }                
            }
            system.debug('cpRegNoList:'+cpRegNoList);
            system.debug('scRegNoList:'+scRegNoList);
            List<Broker_Registration__c> dupQryList = [SELECT Id,Registration_Number__c,Broker_Category__c 
                                                       FROM Broker_Registration__c 
                                                       WHERE Registration_Number__c IN:regNoList ];
            
            if(dupQryList.size()>0){
                for(Broker_Registration__c bqr: dupQryList){
                    system.debug('bqr.Broker_Category__c :'+bqr.Broker_Category__c);
                    system.debug('categoryMap.get(bqr.id):'+categoryMap.get(bqr.Registration_Number__c));
                    if(bqr.Broker_Category__c==categoryMap.get(bqr.Registration_Number__c))
                        dupCheckMap.put(bqr.Registration_Number__c, bqr.Id);
                }
            }  system.debug('~~~~dupCheckMap:2'+dupCheckMap);
            
            List<Channel_Partner__c> cpList = [SELECT Id,Passport_No__c,Black_listed_user__c,Emergency_Created_ID__c,OwnerId 
                                               FROM Channel_Partner__c 
                                               WHERE Passport_No__c IN: cpRegNoList];
            if(cpList.size()>0){
                for(Channel_Partner__c cp: cpList){
                    if(cp.Black_listed_user__c == true) {
                        blacklistedLicenses.add(cp.Passport_No__c);
                    }
                    if((cp.Emergency_Created_ID__c==true && cp.OwnerId==currentUser) || BrokerUpdateSetting__c.getInstance().Skip_CP_SC_Registration_No_Validation__c){
                        // Do Nothing
                    } 
                }
            } system.debug('~~~~dupCheckMap:1'+dupCheckMap);
            List<Sobha_Connect__c> scList = [SELECT Id,Registration__c,Black_listed_user__c,Emergency_Created_ID__c,OwnerId 
                                             FROM Sobha_Connect__c 
                                             WHERE Registration__c IN: scRegNoList];
            if(scList.size()>0){
                for(Sobha_Connect__c sc: scList){
                    system.debug('~~~~d'+BrokerUpdateSetting__c.getInstance().Skip_CP_SC_Registration_No_Validation__c);
                    if(sc.Black_listed_user__c == true) {
                        blacklistedLicenses.add(sc.Registration__c);
                    }
                    if((sc.Emergency_Created_ID__c==true && sc.OwnerId==currentUser) || BrokerUpdateSetting__c.getInstance().Skip_CP_SC_Registration_No_Validation__c){
                        // Do Nothing 
                    }
                }
            }
            system.debug('~~~~dupCheckMap:'+dupCheckMap);
            
            for(Broker_Registration__c br: newList){
                if(blacklistedLicenses.contains(br.Registration_Number__c)){
                    br.addError('Broker is blacklisted for given Registration No.');
                }
                else if(dupCheckMap.containsKey(br.Registration_Number__c)){                    
                    if(oldMap.containsKey(br.Id)){
                        if(br.RecordTypeId==newRecordTypeId && br.Registration_Number__c!=oldMap.get(br.Id).Registration_Number__c) {
                            br.addError('Broker already exists for given Registration No.');
                        }  
                    }
                }
            }
        }
    }
    
    public static void beforeinsert(List<Broker_Registration__c> newList, Map<ID,Broker_Registration__c> oldMap){
        validateRegistrationNumber(newList, oldMap);
        Map<Id, User> userMap = new Map<Id, User>();
        List<Id> ownerIdList = new List<Id>();
        for(Broker_Registration__c e : newList){
            ownerIdList.add(e.OwnerId);
        }
        if(ownerIdList.size()>0){
            userMap = new Map<Id, User>([SELECT ID,ManagerId,Manager.ManagerId FROM User WHERE ID IN:ownerIdList ]);
        }
        for(Broker_Registration__c e : (List<Broker_Registration__c>) Trigger.new){
            if(userMap.containsKey(e.OwnerId)){
                if(userMap.get(e.OwnerId).ManagerId!=null){
                    e.CHRM_Manager__c = userMap.get(e.OwnerId).ManagerId;
                }
            }
        }
    }
    
    public static void sendAgreementForCHRMOpsApproval(List<Broker_Registration__c> newList, Map<ID,Broker_Registration__c> oldMap){
        for(Broker_Registration__c reg : newList){
            if((reg.Status__c == 'Pending with Ashish Parakh' || reg.Status__c == 'Send for Approval') && 
               oldMap.get(reg.id).Status__c != reg.Status__c){
                   brokerRegNOCDocuSignController.forForSigningFuture(reg.Id);
               } 
        }
    }
    
    public static void sendEmailForAuditApproval(List<Broker_Registration__c> brokerRegList, Map<Id,Broker_Registration__c> oldMap){
        Id brokerRegToSendEmail ;
        for(Broker_Registration__c brg : brokerRegList){
            if(brg.Status__c != oldMap.get(brg.id).Status__c && brg.Status__c == 'Pending with Audit'){
                brokerRegToSendEmail = brg.id;
            }
        }
        system.debug('brokerRegToSendEmail' + brokerRegToSendEmail);
        if(brokerRegToSendEmail != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            EmailTemplate et = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate  Where DeveloperName ='AuditApproval_brokerReg_VC'];
            List<ContentDocumentLink> cdl = [Select Id, ContentDocument.LatestPublishedVersion.VersionData,contentdocument.FileExtension from ContentDocumentLink where LinkedEntityId =: brokerRegToSendEmail AND ContentDocument.Title like '%NOC%'];            
            if(cdl.size() > 0){
                Blob b = cdl[0].ContentDocument.LatestPublishedVersion.VersionData;
                system.debug('bodydebug' + b +'//////'+ cdl[0].ContentDocument.LatestPublishedVersion.VersionData);    
                attach.setFileName('NOC'+'.'+cdl[0].contentdocument.FileExtension);
                attach.setBody(b);
                email.setTargetObjectId(UserInfo.getUserId());
                email.setOrgWideEmailAddressId(Label.No_Reply_OWA_Id);
                List<String> toAddRess = System.label.AuditApprovalEmals_BrokerReg.split(';');
                email.setTemplateId(et.id);//Replace TEMPLATEID with salesforce email template id
                email.setToAddresses(toAddRess);
                email.whatId = brokerRegToSendEmail;
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
                email.saveAsActivity = false;
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
        }
    }
    
    @future
    public static void updateComments(String triggerData, String triggerOldData){
        
        List<Broker_Registration__c> newRecords = (List<Broker_Registration__c>)Json.deserialize(triggerData,List<Broker_Registration__c>.class);
        Map<Id, Broker_Registration__c> oldMap = (Map<Id,Broker_Registration__c>)Json.deserialize(triggerOldData, Map<Id,Broker_Registration__c>.class);
        
        Set<Id> updatedRecordIds = new Set<Id>();
        //List<Broker_Registration__c> fieldUpdateReqList = new List<Broker_Registration__c>();
        Map<Id, Broker_Registration__c> brFieldUpdateMap = new Map<Id, Broker_Registration__c>();
        
        String latestApprovalComment;
        
        For(Broker_Registration__c newRec: newRecords){
            updatedRecordIds.add(newRec.Id);
        }
        
        // if (!updatedRecordIds.isEmpty()) {
        List<Broker_Registration__c> recordsToUpdate = [SELECT Id,Status__c,RecordType.Name FROM Broker_Registration__c WHERE Id IN :updatedRecordIds];
        //  Broker_Registration__c updatedRecords =[SELECT Id FROM Broker_Registration__c WHERE Id IN :updatedRecordIds];
        list<Broker_Registration__c> recordsTUpdate = new list<Broker_Registration__c>();
 
        for (Broker_Registration__c record : recordsToUpdate) {
            latestApprovalComment = getLatestApprovalComment(record.Id);
            // Replace this with your logic to retrieve latest approval comment from related object
            System.debug('latestApprovalComment'+latestApprovalComment);
            
            if (latestApprovalComment != null || Test.isRunningTest()) {
                record.Comments__c = latestApprovalComment;
                System.debug('record.Comments__c' +record.Comments__c);
                
                recordsTUpdate.add(record);
            }
        }
        if(recordsTUpdate.size()>0){
            if(recordsTUpdate[0].status__c =='Rejected - Rejected by CHRM OPS' && recordsTUpdate[0].RecordType.Name =='Renewal'){
                system.debug('~~~ToUpdate Rejected - Rejected by CHRM OPS Renewal '+recordsTUpdate);
                
                update recordsTUpdate;
                sendRejectionRenewalEmail(recordsTUpdate[0],recordsTUpdate[0].Comments__c);
            }else if(recordsTUpdate[0].status__c =='Rejected - Rejected by CHRM OPS' && recordsTUpdate[0].RecordType.Name =='New'){
                system.debug('~~~ToUpdate: Rejected - Rejected by CHRM OPS New'+recordsTUpdate);
                
                update recordsTUpdate;
                sendRejectionEmail(recordsTUpdate[0],recordsTUpdate[0].Comments__c);
            }
            else if(recordsTUpdate[0].status__c =='Rejected by Channel Ops Audit' && recordsTUpdate[0].RecordType.Name =='Renewal'){
                system.debug('~~~ToUpdate:AUDIT '+recordsTUpdate);
                update recordsTUpdate;
                SendRejectRenewalAuditEmail(recordsTUpdate[0],recordsTUpdate[0].Comments__c);
            }
            else if(recordsTUpdate[0].status__c =='Rejected by Channel Ops Audit' && recordsTUpdate[0].RecordType.Name =='New'){
                system.debug('~~~ToUpdate:AUDIT '+recordsTUpdate);
                update recordsTUpdate;
                SendRejectAuditEmail(recordsTUpdate[0],recordsTUpdate[0].Comments__c);
            }
            else if(recordsTUpdate[0].status__c =='Rejected by CHRM'){
                system.debug('~~~ToUpdate:CHRM '+recordsTUpdate);
                recordsTUpdate[0].status__c = '';
                update recordsTUpdate;
                sendRejectionEmailtoBroker(recordsTUpdate[0],recordsTUpdate[0].Comments__c);
            }
        }        
        if(!brFieldUpdateMap.isEmpty()){
            updateBRApprovalRequestData(brFieldUpdateMap);
        }
    }
    
    public static void updateBRApprovalRequestData(Map<Id, Broker_Registration__c> brFieldUpdateMap){
        try{
            List<String> statusFilter = new List<String>{'Pending With CHRM OPS Manager',  'Pending with Audit'};
                List<Broker_Registration_Approval_Request__c> brarList = [Select Id, Status__c, Broker_Registration__c from Broker_Registration_Approval_Request__c where Broker_Registration__c IN: brFieldUpdateMap.keyset() AND Status__c IN:statusFilter];
            if(brarList.size()>0){
                for(Broker_Registration_Approval_Request__c brap: brarList){
                    brap.Status__c = brFieldUpdateMap.get(brap.Broker_Registration__c).Field_Update_Request_Status__c;
                }
                update brarList;
            }
        }  catch (Exception e) {
            system.debug(e.getMessage());
        }
    }

    public static String getLatestApprovalComment(String registrationId) {
        List<String> latestApprovalComments = new List<String>();
        
        // Query ProcessInstance and ProcessInstanceStep records for the given recordId
        List<ProcessInstance> processInstances = [SELECT Id, TargetObjectId 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :registrationId];
        String returnString;
        if (processInstances.isEmpty()) {
            return returnString; // No approval process for the given recordId
        }
        
        Map<Id, List<ProcessInstanceStep>> stepsMap = new Map<Id, List<ProcessInstanceStep>>();
        
        List<ProcessInstanceStep> steps = [SELECT Id, StepStatus, Comments, CreatedDate, ProcessInstanceId
                                           FROM ProcessInstanceStep 
                                           WHERE ProcessInstanceId IN :processInstances
                                           ORDER BY CreatedDate DESC LIMIT 1];
        
        // Group ProcessInstanceSteps by ProcessInstanceId
        for (ProcessInstanceStep step : steps) {
            if (!stepsMap.containsKey(step.ProcessInstanceId)) {
                stepsMap.put(step.ProcessInstanceId, new List<ProcessInstanceStep>());
            }
            stepsMap.get(step.ProcessInstanceId).add(step);
        }
        
        // Loop through ProcessInstance records and retrieve the latest comment from stepsMap
        for (ProcessInstance processInstance : processInstances) {
            if (stepsMap.containsKey(processInstance.Id)) {
                List<ProcessInstanceStep> instanceSteps = stepsMap.get(processInstance.Id);
                if (!instanceSteps.isEmpty()) {
                    ProcessInstanceStep latestStep = instanceSteps[0]; // The first entry is the latest one due to the sorting
                    latestApprovalComments.add(latestStep.Comments);
                    returnString=latestStep.Comments;
                }
            }
        }
        
        return returnString;
    }
    
    public static void updateStatusAfterDocUpload(List<ContentDocumentLink> newLinks) {
        Set<Id> brokerRegistrationIdsToUpdate = new Set<Id>();
        Set<Id> brokerRegistrationIdsToUpdateAgreement = new Set<Id>();
        Set<Id> brokerRegistrationdocIds = new Set<Id>();
        Set<Id> brokerRegistrationdocIdsExt = new Set<Id>();
        // Loop through the newly inserted ContentDocumentLink records
        for (ContentDocumentLink link : newLinks) {
            // Check if the linked entity is a Broker_Registration__c record
            if (link.LinkedEntityId.getSObjectType() == Broker_Registration__c.SObjectType) {
                // Query the linked ContentDocument
                System.debug('link.contentDocId : '+link.ContentDocumentId);
                ContentDocument document = [
                    SELECT Title
                    FROM ContentDocument
                    WHERE Id = :link.ContentDocumentId
                ];
                System.debug('Title : '+document.Title);
                // Check if the document title contains "NOC" (case insensitive)
                if (document.Title != null && document.Title.toUpperCase().contains('NOC')) {
                    // Add the Broker_Registration__c record ID to the set
                    brokerRegistrationIdsToUpdate.add(link.LinkedEntityId);
                }
                if (document.Title != null && document.Title.toUpperCase().contains('AGREEMENT')) {
                    // Add the Broker_Registration__c record ID to the set
                    brokerRegistrationIdsToUpdateAgreement.add(link.LinkedEntityId);
                }
                if(document.Title != null && !(document.Title.toUpperCase().contains('AGREEMENT') || document.Title.toUpperCase().contains('NOC'))){
                    brokerRegistrationdocIds.add(link.LinkedEntityId);
                }
                if(document.Title != null && document.Title.toUpperCase().contains('EXTENSION')){
                    System.debug('inside docuemnt title');
                    brokerRegistrationdocIdsExt.add(link.LinkedEntityId);
                }
            }
        }
        System.debug('brokerRegistrationdocIdsExt : '+brokerRegistrationdocIdsExt);
        // Update the status__c field on Broker_Registration__c records
        List<Broker_Registration__c> brokerRegistrationsToUpdate = [
            SELECT Id, status__c, NOC_generated_status_updated__c,Agreement_Generated_Status_Updatec__c 
            FROM Broker_Registration__c
            WHERE Id IN :brokerRegistrationIdsToUpdate
        ];
        system.debug('~~~~'+brokerRegistrationsToUpdate);
        List<Broker_Registration__c> brokerRegistrationsToUpdate1 = [
            SELECT Id, status__c,Agreement_Generated_Status_Updatec__c,NOC_generated_status_updated__c
            FROM Broker_Registration__c
            WHERE Id IN :brokerRegistrationIdsToUpdateAgreement
        ];
        
        List<Broker_Registration__c> brokerRegistrationsToUpdate2 = [
            SELECT Id, status__c,Extension_Status_Updated__c,NOC_generated_status_updated__c
            FROM Broker_Registration__c
            WHERE Id IN :brokerRegistrationdocIdsExt
        ];
        
        for (Broker_Registration__c brokerRegistration : brokerRegistrationsToUpdate) {
            if (!brokerRegistration.NOC_generated_status_updated__c || (brokerRegistration.status__c == 'CP/SC ID Generated' && brokerRegistration.NOC_generated_status_updated__c) ) {
                brokerRegistration.status__c = 'NOC Generated';
                brokerRegistration.NOC_generated_status_updated__c = true;
            }
        }
        
        for (Broker_Registration__c brokerRegistration1 : brokerRegistrationsToUpdate1) {
            if (!brokerRegistration1.Agreement_Generated_Status_Updatec__c || ((brokerRegistration1.status__c == 'Approved - Agreement Is in process' || brokerRegistration1.status__c == 'Agreement Rejected by CHRM OPS') && brokerRegistration1.Agreement_Generated_Status_Updatec__c)) {
                brokerRegistration1.status__c = 'Agreement Generated';
                brokerRegistration1.Agreement_Generated_Status_Updatec__c = true;
            }
        }
        
        for (Broker_Registration__c brokerRegistration1 : brokerRegistrationsToUpdate2) {
            if (!brokerRegistration1.Extension_Status_Updated__c || (brokerRegistration1.status__c == 'Executed Agreement sent to Broker' || brokerRegistration1.status__c == 'Executed Agreement sent to CHRM') ) {
                brokerRegistration1.status__c = 'Extension Generated';
                brokerRegistration1.Extension_Status_Updated__c = true;
            }
        }           
        
        if (!brokerRegistrationsToUpdate.isEmpty()) {
            update brokerRegistrationsToUpdate;
        }
        
        if (!brokerRegistrationsToUpdate1.isEmpty()) {
            update brokerRegistrationsToUpdate1;
        }
        System.debug('brokerRegistrationsToUpdate2 : '+brokerRegistrationsToUpdate2);                
        if (!brokerRegistrationsToUpdate2.isEmpty()) {
            update brokerRegistrationsToUpdate2;
        }
        
        if(!brokerRegistrationdocIds.isEmpty()){
            
        }
    }
    
    public static void afterUpdate(List<Broker_Registration__c> newList, Map<ID,Broker_Registration__c> oldMap){
        system.debug('Inside After Update');
        // Fetch the RecordType.Name for the records being updated
        Map<Id, Broker_Registration__c> brokerRegMap = new Map<Id, Broker_Registration__c>(
            [SELECT Id, RecordType.Name,All_Document_Uploaded__c ,
             Status__c, crmOps__r.Email,crmOps__r.Name,
             owner.Firstname,Owner.Lastname, Owner.Email , LastModifiedById, OwnerId 
             FROM Broker_Registration__c 
             WHERE Id IN :Trigger.new]
        );
        Set<Id> brokerRegIdsToUpdate = new Set<Id>();
        List<Broker_Registration__c> brokerRegsToUpdate = new List<Broker_Registration__c>();
        Group brokerQueue = [SELECT Id FROM Group WHERE Name = 'Broker Category Queue' AND Type = 'Queue' LIMIT 1];
        // Handle CHRM OPS rejection status and send email
        for (Broker_Registration__c brokerReg : newList) {
            Broker_Registration__c queriedBrokerReg = brokerRegMap.get(brokerReg.Id);
            Boolean hasAllDocsChanged = queriedBrokerReg.All_Document_Uploaded__c != oldMap.get(brokerReg.Id).All_Document_Uploaded__c;
            Boolean hasAllDocsUploaded = queriedBrokerReg.All_Document_Uploaded__c == true;
            
            //added by artee on 27th dec'24
            Boolean hasAllDocsUnchecked = queriedBrokerReg.All_Document_Uploaded__c == false;
            // If the checkbox was unchecked, revert status to 'Signed Agreement Received - Documents Awaited'
            if (hasAllDocsChanged && hasAllDocsUnchecked && queriedBrokerReg.Status__c != 'Signed Agreement Received - Documents Awaited') {
                queriedBrokerReg.Status__c = 'CP/SC ID in Process';
                brokerRegsToUpdate.add(queriedBrokerReg);
            }
            //added by artee on 27th dec'24
            
            if (hasAllDocsChanged && hasAllDocsUploaded && queriedBrokerReg.Status__c =='CP/SC ID in Process') {
                if(!brokerRegIdsToUpdate.contains(queriedBrokerReg.Id)) {
                    brokerRegsToUpdate.add(queriedBrokerReg);
                }
                brokerRegIdsToUpdate.add(queriedBrokerReg.Id);
            }
            if (queriedBrokerReg.Status__c=='Agreement created and sent for signature' && 
                oldMap.get(queriedBrokerReg.Id).Status__c != 'Agreement created and sent for signature'){
                    System.debug('queriedBrokerReg.RecordType.Name'+queriedBrokerReg.RecordType.Name);
                    if(queriedBrokerReg.RecordType.Name =='New'){
                        System.debug('You are in New');
                        brokerRegistrationTrghandler.sendAgreementForSignatureEmail(brokerReg);
                    }else if(queriedBrokerReg.RecordType.Name =='Renewal'){
                        System.debug('You are in renewal');
                        brokerRegistrationTrghandler.sendRenewalAgreementForSignatureEmail(brokerReg);
                    }
                    
                }
            else if (queriedBrokerReg.Status__c=='Approved - Agreement Is in Process' && oldMap.get(queriedBrokerReg.Id).Status__c != 'Approved - Agreement Is in Process'){
                
                queriedBrokerReg.crmOps__c = queriedBrokerReg.LastModifiedById;
                //queriedBrokerReg.OwnerId = brokerQueue.Id;--bug no need to assign Owner ID 
                brokerRegsToUpdate.add(queriedBrokerReg);
                system.debug('After Update when status is Approved - Agreement Is in Process');
            } 
            else if (queriedBrokerReg.Status__c=='CP/SC ID in Process' && oldMap.get(queriedBrokerReg.Id).Status__c != 'CP/SC ID in Process'){
                if(queriedBrokerReg.RecordType.Name =='New'){
                    brokerRegistrationTrghandler.sendSignedAgreementReceivedEmail(brokerReg);
                }else if(queriedBrokerReg.RecordType.Name =='Renewal'){
                    brokerRegistrationTrghandler.SendRenewalSignedAgreementReceivedEmail(brokerReg); 
                }
            } 
            else if(queriedBrokerReg.Status__c=='All missing documents uploaded' && oldMap.get(queriedBrokerReg.Id).Status__c != 'All missing documents uploaded') {
                system.debug('Inside After Update2');
                
                if(queriedBrokerReg.RecordType.Name =='New'){
                    system.debug('Inside After Update3');
                    
                    brokerRegistrationTrghandler.SendAlldocumentUploadRegistrationEmail(brokerReg);
                    System.debug('All missing documents uploaded--New'+brokerReg.Status__c);
                }else if(queriedBrokerReg.RecordType.Name =='Renewal'){
                    system.debug('Inside After Update4');
                    
                    System.debug('All missing documents uploaded--Renewal'+brokerReg.Status__c);
                    brokerRegistrationTrghandler.SendAlldocumentUploadRenewalEmail(brokerReg);
                }
            }
            
            else if(queriedBrokerReg.Status__c=='Executed Agreement sent to CRHM' && 
                    oldMap.get(brokerReg.Id).Status__c != 'Executed Agreement sent to CRHM'){
                        System.debug('OOO brokerReg.Status__c'+brokerReg.Status__c);
                        System.debug('OOO queriedBrokerReg.RecordType.Name'+queriedBrokerReg.RecordType.Name);
                        
                        if(queriedBrokerReg.RecordType.Name =='New'){ brokerRegistrationTrghandler.SendExecuteBrokerEmail(brokerReg);}
                        else if(queriedBrokerReg.RecordType.Name =='Renewal'){
                            brokerRegistrationTrghandler.SendExecuteBrokerRenewalEmail(brokerReg);
                        }
                    }
        }
        if (!brokerRegsToUpdate.isEmpty()) {
            update brokerRegsToUpdate;
            system.debug('Records updated with new crmOps__c and assigned to Broker Category Queue.');
        }
        if (!brokerRegIdsToUpdate.isEmpty() ) {
            /* Call handler to perform updates & email in the event of all docs upload */
            brokerRegistrationTrgHelper.handleAllDocsUploadEvent(brokerRegsToUpdate);
        }
        
        if(!System.isFuture() && !System.isBatch()){
            system.debug('System.isFuture() Called');
            brokerRegistrationTrghandler.updateComments(JSON.serialize(Trigger.new), JSON.serialize(Trigger.oldMap));
        }
    }
    
    /******************************************************************************************************************
    Method : processBrokerRegFieldsBeforeSave
    Purpose : NICE - Apex class handler method for before insert, encrypts mobile numbers & emails if they are provided.
    Author : Artee Varma
    Date : 16-01-2025
    ******************************************************************************************************************/
    
    public static void processBrokerRegFieldsBeforeSave(List<Broker_Registration__c> newRecords) {        
        for (Broker_Registration__c br : newRecords) {
            if (!String.isBlank(br.Mobile_Country_Code__c) && !String.isBlank(br.Mobile__c)) {
                br.Primary_Mobile_Number__c = br.Mobile_Country_Code__c + br.Mobile__c;
                br.Primary_Mobile_Number_M__c = Nice_FieldMaskingUtility.maskPhoneNumber(br.Primary_Mobile_Number__c);
                br.Primary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Primary_Mobile_Number__c);
            }
            if (!String.isBlank(br.Email__c)) {
                System.debug('Primary_Email_M__c::::'+br.Primary_Email_M__c);
                br.Primary_Email_M__c = Nice_FieldMaskingUtility.maskEmail(br.Email__c);
                System.debug('Primary_Email_M__c::::'+br.Primary_Email_M__c);
                br.Primary_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Email__c);
            } 
            /*if (!String.isBlank(br.Telephone_Country_Code__c) && !String.isBlank(br.Telephone__c)) {
            br.Secondary_Mobile_Number__c = br.Telephone_Country_Code__c + br.Telephone__c;
            br.Secondary_Mobile_Number_M__c = FieldMaskingUtil.maskPhoneNumber(br.Secondary_Mobile_Number__c);
            br.Secondary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Secondary_Mobile_Number__c);
            }*/                           
                        /*if (!String.isBlank(br.Second_Signatory_Email__c)) {
            System.debug('Secondary_Email_M__c::::'+br.Secondary_Email_M__c);
            br.Secondary_Email_E__c = FieldMaskingUtil.maskEmail(br.Second_Signatory_Email__c);
            System.debug('Secondary_Email_M__c::::'+br.Secondary_Email_M__c);
            br.Secondary_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Second_Signatory_Email__c);
            }*/
        }
    }
    
    /******************************************************************************************************************
    Method : processBrokerRegFieldsBeforeUpdate
    Purpose : NICE - Apex class handler method for before update, encrypts mobile numbers & emails if they are provided.
    Author : Artee Varma
    Date : 16-01-2025
    ******************************************************************************************************************/
    
    public static void processBrokerRegFieldsBeforeUpdate(Map<Id, Broker_Registration__c> newMap, Map<Id, Broker_Registration__c> oldMap) {
        List<Broker_Registration__c> brokerRegToEncrypt = new List<Broker_Registration__c>();
        
        for (Broker_Registration__c br : newMap.values()) {
            Boolean isMobileChanged = oldMap == null || br.Mobile__c != oldMap.get(br.Id)?.Mobile__c;
            Boolean isMobileCountryChanged = oldMap == null || br.Mobile_Country_Code__c != oldMap.get(br.Id)?.Mobile_Country_Code__c;
            Boolean isTelephoneNumberChanged = oldMap == null || br.Telephone__c != oldMap.get(br.Id)?.Telephone__c;
            Boolean isTelephoneCountryChanged = oldMap == null || br.Telephone_Country_Code__c != oldMap.get(br.Id)?.Telephone_Country_Code__c;
            Boolean isPrimaryNumberChanged = oldMap == null || br.Primary_Mobile_Number__c != oldMap.get(br.Id)?.Primary_Mobile_Number__c;
            Boolean isSecondaryNumberChanged = oldMap == null || br.Secondary_Mobile_Number__c != oldMap.get(br.Id)?.Secondary_Mobile_Number__c;
            Boolean isPrimaryEmailChanged = oldMap == null || br.Email__c != oldMap.get(br.Id)?.Email__c;
            Boolean isSecondaryEmailChanged = oldMap == null || br.Second_Signatory_Email__c != oldMap.get(br.Id)?.Second_Signatory_Email__c;
            Boolean isThirdEmailChanged = oldMap == null || br.Third_Signatory_Email__c != oldMap.get(br.Id)?.Third_Signatory_Email__c;
            Boolean isAccountEmailChanged = oldMap == null || br.Account_Email__c != oldMap.get(br.Id)?.Account_Email__c;
            Boolean isOwnerEmailChanged = oldMap == null || br.Alternate_Email__c != oldMap.get(br.Id)?.Alternate_Email__c;         
            
            if (!String.isBlank(br.Mobile__c) && (isMobileChanged || isMobileCountryChanged)) {
                System.debug('Mobile number changed////');
                br.Primary_Mobile_Number__c = br.Mobile_Country_Code__c + br.Mobile__c;
                br.Primary_Mobile_Number_M__c = Nice_FieldMaskingUtility.maskPhoneNumber(br.Primary_Mobile_Number__c);
                br.Primary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Primary_Mobile_Number__c);
            }  
            if (!String.isBlank(br.Telephone__c) && (isTelephoneNumberChanged || isTelephoneCountryChanged)) {
                System.debug('Telephone number changed////');
                br.Secondary_Mobile_Number__c = br.Telephone_Country_Code__c + br.Telephone__c;
                br.Secondary_Mobile_Number_M__c = Nice_FieldMaskingUtility.maskPhoneNumber(br.Secondary_Mobile_Number__c);
                br.Secondary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Secondary_Mobile_Number__c);
            }              
            if (!String.isBlank(br.Primary_Mobile_Number__c) && isPrimaryNumberChanged) {
                System.debug('Primary Mobile number changed////');
                br.Primary_Mobile_Number_M__c = Nice_FieldMaskingUtility.maskPhoneNumber(br.Primary_Mobile_Number__c);
                br.Primary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Primary_Mobile_Number__c);
            }  
            if (!String.isBlank(br.Secondary_Mobile_Number__c) && isSecondaryNumberChanged) {
                System.debug('Secondary Mobile number changed////');
                br.Secondary_Mobile_Number_M__c = Nice_FieldMaskingUtility.maskPhoneNumber(br.Secondary_Mobile_Number__c);
                br.Secondary_Mobile_Number_E__c = Nice_AesEncryptionUtility.encryptMobile(br.Secondary_Mobile_Number__c);     
            }
            if (!String.isBlank(br.Email__c) && isPrimaryEmailChanged ) {
                System.debug('Email changed////');
                br.Primary_Email_M__c = Nice_FieldMaskingUtility.maskEmail(br.Email__c);
                br.Primary_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Email__c);
            }
            if (!String.isBlank(br.Second_Signatory_Email__c) && isSecondaryEmailChanged) {
                System.debug('Second Signatory Email changed////');
                br.Second_Signatory_Email_M__c = Nice_FieldMaskingUtility.maskEmail(br.Second_Signatory_Email__c);
                br.Second_Signatory_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Second_Signatory_Email__c);
            }
            if (!String.isBlank(br.Third_Signatory_Email__c) && isThirdEmailChanged) {
                System.debug('Third Signatory Email changed////');
                br.Third_Signatory_Email_M__c = Nice_FieldMaskingUtility.maskEmail(br.Third_Signatory_Email__c);
                br.Third_Signatory_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Third_Signatory_Email__c);
            }
            if (!String.isBlank(br.Account_Email__c) && isAccountEmailChanged) {
                System.debug('Account Email changed////');
                br.Account_Email_M__c = Nice_FieldMaskingUtility.maskEmail(br.Account_Email__c);
                br.Account_Email_E__c = Nice_AesEncryptionUtility.encryptEmail(br.Account_Email__c);
            }
            if (!String.isBlank(br.Alternate_Email__c) && isOwnerEmailChanged) {
                System.debug('Owner Email changed////');
                br.Owner_s_Email_E__c = Nice_FieldMaskingUtility.maskEmail(br.Alternate_Email__c);
                br.Owner_s_Email_M__c = Nice_AesEncryptionUtility.encryptEmail(br.Alternate_Email__c);
            }
            brokerRegToEncrypt.add(br);
        }
    }
    //added by Artee on 16-01-2025
}