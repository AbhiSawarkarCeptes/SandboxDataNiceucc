public class AccountTriggerHelper {
    public static void updateBrokerCode(List<Account> accountList) {
        Map<String, Integer> MapOfMaxBrokerCode = new Map<String, Integer>();
        /*List<AggregateResult> accRec = [SELECT MAX(PropStrength__Broker_Code__c) BR 
                                            FROM Account 
                                            WHERE RecordType.Name = 'Broker' AND 
                                                (PropStrength__Broker_Type__c = 'Standard' OR 
                                                PropStrength__Broker_Type__c = 'Sobha Connect') AND 
                                                PropStrength__Broker_Code__c != null GROUP BY PropStrength__Broker_Type__c];*/
        //System.debug('===> accRec ' + accRec);
        for(AggregateResult a : [SELECT MAX(Last_Broker_Code__c) BR, 
                                            PropStrength__Broker_Type__c tp
                                            FROM Account 
                                            WHERE RecordType.Name = 'Broker' AND 
                                                (PropStrength__Broker_Type__c = 'Standard' OR 
                                                PropStrength__Broker_Type__c = 'Sobha Connect') AND 
                                                PropStrength__Broker_Code__c != null AND 
                                                Last_Broker_Code__c != null AND 
                                                Last_Broker_Code__c >= 0 
                                                GROUP BY PropStrength__Broker_Type__c]) {
            if(a.get('tp') == 'Standard') {
                MapOfMaxBrokerCode.put('Standard', Integer.valueOf(a.get('BR')));
            }
            if(a.get('tp') == 'Sobha Connect') {
                MapOfMaxBrokerCode.put('Sobha Connect', Integer.valueOf(a.get('BR')));
            }
        }
        for(Account acc : accountList) {
            if (acc.PropStrength__Broker_Code__c == null && 
                acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId()) {
                if (MapOfMaxBrokerCode.containsKey(acc.PropStrength__Broker_Type__c) && 
                    MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) != null) {
                    if (acc.PropStrength__Broker_Type__c == 'Standard') {
                        acc.PropStrength__Broker_Code__c = 'CP - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1).leftPad(5,'0');
                        acc.Last_Broker_Code__c = MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1;
                        MapOfMaxBrokerCode.put('Standard', MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1);
                    } else if (acc.PropStrength__Broker_Type__c == 'Sobha Connect') {
                        System.debug('===> SC ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1).leftPad(5,'0'));
                        acc.PropStrength__Broker_Code__c = 'SC - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1).leftPad(5,'0');
                        acc.Last_Broker_Code__c = MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1;
                        MapOfMaxBrokerCode.put('Sobha Connect', MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1);
                    }
                } else {
                    if (acc.PropStrength__Broker_Type__c == 'Standard') {
                        acc.PropStrength__Broker_Code__c = 'CP - 00001';
                        MapOfMaxBrokerCode.put('Standard', 1);
                    }
                    else if (acc.PropStrength__Broker_Type__c == 'Sobha Connect') {
                        acc.PropStrength__Broker_Code__c = 'SC - 00001';
                        MapOfMaxBrokerCode.put('Sobha Connect', 1);
                    }
                }
            }
        }
    }
    //Added by Anil to send mail Public Group - 17/08/2023
    // commented this method by Gourav Gour 22/05/2024
    /*
    public static void sendMailtoPublicGroupInsertion(List<Account> accountList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> ();
        Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account acc : AccountList){
            if(acc.Is_Active__c && acc.RecordTypeId == recordID){
                emails.add(sendMailMethod(acc));
            }
        }
        try{
            if(emails.size()>0 && emails != null)
            {
                Messaging.sendEmail(emails, false);
            }
        }
        catch(Exception e){
            System.debug('Mail send execption' + e.getMessage());
        }
    }
     */
    //Send Mail for update record
    // commented this method by Gourav Gour 22/05/2024
    /*
    public static void sendMailtoPublicGroupUpdation(List<Account> accountList, Map<id, Account> oldAccountList){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> ();
        Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account acc : AccountList){
            if(!(oldAccountList.get(acc.id)).Is_Active__c && acc.Is_Active__c && acc.RecordTypeId == recordID){
                emails.add(sendMailMethod(acc));
            }
        }
        try{
            if(emails.size()>0 && emails != null)
            {
                Messaging.sendEmail(emails, false);
            }
        }
        catch(Exception e){
            System.debug('Mail send execption' + e.getMessage());
        }
        
    }
     */
    //Email method
    // commented this method by Gourav Gour 22/05/2024
    /*
    public static Messaging.SingleEmailMessage sendMailMethod( Account acc){
        List<GroupMember> publicGrp = [Select id, UserOrGroupId  from GroupMember where Group.Name = 'Channel Manager Group'];
        Set<id> ids = new Set<id>();
        for(GroupMember groupMem : publicGrp){
            ids.add(groupMem.UserOrGroupId);
        }
        List<User> users = [Select id, Name, Email from User where Id In :ids ];
        List<string> emailAdr = new List<String>();
        for(User us : users){
            emailAdr.add(us.Email);
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailAdr);
        email.setSubject('Broker Qualified Notification');
        email.setHtmlBody('Hello Team, <br/> <br/> I hope this email finds you well. This to inform you that the below mentioned broker is eligible to provide brokerage services :<br/> <br/>'+
            'Account Name - ' + acc.Name + '<br/>' + 'Email -' + acc.Email_ID_1__c + '<br/>' + 'Mobile Number - ' + acc.Mobile_No__c +
            '<br/> <br/> Account link - '+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + acc.Id +
            '<br/> <br/>Thank you for your attention, and we look forward to a successful partnership with our qualified broker. <br/><br/> Best regards, <br/><br/> Sobha Reality ');
        
        return email;
    }
     */
    public static void sendManDataLetter(List<Account> accList, Map<Id, Account> oldAccountMap ) {
        Set<Id> accId = new set<Id>();
        for(Account accRec : accList) {
            if((accRec.Send_Policy_Mandate_Letter__c != oldAccountMap.get(accRec.Id).Send_Policy_Mandate_Letter__c) && accRec.Send_Policy_Mandate_Letter__c && accRec.Email_ID_1__c != null) {
                accId.add(accRec.Id);
            }
        }
        if(!accId.isEmpty()) {
            AccountTriggerHelper.sendLetterEmail(accId);
        }
        
    }
    @Future(callout=true)
    public static void sendLetterEmail(Set<Id> accId) {
        List<Account> accToSendLetter = [SELECT Id,PropStrength__Broker_Type__c,Email_ID_1__c, OwnerId FROM Account WHERE Id IN : accId];
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate where Name = 'Mandate Letter' limit 1];
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        
        for(Account rec : accToSendLetter) {
            List<String> emailAddress = new List<String>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            emailAddress.add(rec.Email_ID_1__c);
            // emails.setOrgWideEmailAddressId(owea.get(0).Id);
            String aName;
            String b;
            blob content;
            if(rec.PropStrength__Broker_Type__c == 'Sobha Connect') {
                String frmsrc = '/apex/SobhaMandateLetter';
                PageReference p1 = new PageReference(frmsrc);
                aName ='Mandate Letter';
                if (Test.IsRunningTest()) {
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    content = p1.getContentAsPDF();
                }
            }
            else if(rec.PropStrength__Broker_Type__c == 'Standard') {
                String frmsrc = '/apex/ChannelMandataLetter';
                PageReference p1 = new PageReference(frmsrc);
                aName ='Mandate Letter';
                if (Test.IsRunningTest()) {
                    content =  Blob.valueOf('UNIT.TEST');
                } else {
                    content = p1.getContentAsPDF();
                }
            }
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(aName+'.pdf');
            efa.setBody(content);
            emails.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            emails.setWhatId(rec.Id);
            emails.setToAddresses(emailAddress);
            emails.setTemplateId(templatelist[0].Id);
            emails.setSaveAsActivity(true);
            emails.setTargetObjectId(rec.OwnerId);
            emails.setTreatTargetObjectAsRecipient(false);
            emaillist.add(emails);
        }
        try{
            if(emaillist != null && emaillist.size()>0 ) {
                Messaging.sendEmail(emaillist);
            }
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
    }
    
    //Added by Nishank Manwani on 06/02/2024 to update status as per checkboxes
    public static void updateStatus(List<Account> accList, Map<Id, Account> oldAccMap) {
        for(Account acc : accList) {
            if(acc.All_Documents_Updated__c && acc.All_Documents_Updated__c != oldAccMap.get(acc.Id).All_Documents_Updated__c ) {
                acc.PropStrength__Broker_Approval_Status__c = 'All Missing Documents Uploaded';
            }
            if(acc.All_Mandatory_Documents__c && acc.All_Mandatory_Documents__c != oldAccMap.get(acc.Id).All_Mandatory_Documents__c ) {
                //acc.PropStrength__Broker_Approval_Status__c = 'Agreement Is in process'; 
                //commented by nishank on 5 sept as told by sushil
            }
            if(acc.PropStrength__Broker_Approval_Status__c == 'Amendment Approved by Audit' && acc.PropStrength__Broker_Approval_Status__c != oldAccMap.get(acc.Id).PropStrength__Broker_Approval_Status__c ) {
                acc.PropStrength__Broker_Approval_Status__c = 'Amendment Sent for Final Signature';
                AmendmentLetterDocusignHandler.forForSigningFuture2(acc.Id);
            }
            // commented By Gourav 24/05/2024 It is updated by Docgen package
            // if(acc.NOC_Generated__c && acc.NOC_Generated__c != oldAccMap.get(acc.Id).NOC_Generated__c) {
                //     acc.PropStrength__Broker_Approval_Status__c = 'NOC Pending with Audit';
            // }
        }
    }
    
    //Added by Nishank Manwani on 26-Feb-2024 to check duplicate TRN OR Passport number
    public static void checkDuplicatePassportOrTRN(List<Account> accList, Map<Id, Account> oldAccMap) {
        // Get the RecordTypeId for the Broker record type
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        Set<String> regPassport = new Set<String>();
        Set<String> trn = new Set<String>();
        Set<String> reg = new Set<String>();
        
        // Collect Registration_Passport_Number__c and TRN_Number__c from accList
        for (Account acc : accList) {
            if (acc.RecordTypeId == brokerAccId && acc.Emergency_CP_SC_ID__c == false) {
                if (acc.Registration_Passport_Number__c != null) {
                    regPassport.add(acc.Registration_Passport_Number__c);
                }
                if (acc.TRN_Number__c != null) {
                    trn.add(acc.TRN_Number__c);
                }
                if (acc.Registration_Number__c != null) {
                    reg.add(acc.Registration_Number__c);
                }
            }
        }
        
        // Query for existing accounts with the same Passport or TRN numbers that are not in oldAccMap
        if (oldAccMap != null && !oldAccMap.keySet().isEmpty()) {
            accountList = [SELECT Id, Registration_Passport_Number__c, TRN_Number__c, PropStrength__Broker_Code__c, Registration_Number__c 
                        FROM Account 
                        WHERE Id NOT IN :oldAccMap.keySet() 
                        AND RecordTypeId = :brokerAccId 
                        AND (Registration_Passport_Number__c IN :regPassport OR TRN_Number__c IN :trn OR Registration_Number__c IN :reg)];
        } else {
            accountList = [SELECT Id, Registration_Passport_Number__c, TRN_Number__c, PropStrength__Broker_Code__c, Registration_Number__c 
                        FROM Account 
                        WHERE RecordTypeId = :brokerAccId 
                        AND (Registration_Passport_Number__c IN :regPassport OR TRN_Number__c IN :trn OR Registration_Number__c IN :reg)];
        }
        
        // Map for storing existing Registration_Passport_Number__c and TRN_Number__c
        Map<String, Account> accReraMap = new Map<String, Account>();
        Map<String, Account> accTrnMap = new Map<String, Account>();
        Map<String, Account> accRegMap = new Map<String, Account>();
        
        for (Account acc : accountList) {
            if (acc.Registration_Passport_Number__c != null) {
                accReraMap.put(acc.Registration_Passport_Number__c, acc);
            }
            if (acc.TRN_Number__c != null) {
                accTrnMap.put(acc.TRN_Number__c, acc);
            }
            if (acc.Registration_Number__c != null) {
                accRegMap.put(acc.Registration_Number__c, acc);
            }
        }
        
        // Check for duplicates in the input list accList
        for (Account acc : accList) {
            if (acc.RecordTypeId == brokerAccId && acc.Emergency_CP_SC_ID__c == false) {
                if (acc.Registration_Passport_Number__c != null && accReraMap.containsKey(acc.Registration_Passport_Number__c) && accReraMap.get(acc.Registration_Passport_Number__c).PropStrength__Broker_Code__c != acc.PropStrength__Broker_Code__c) {
                    acc.addError('This Passport / Registration number is already in use');
                }
                if (acc.TRN_Number__c != null && accTrnMap.containsKey(acc.TRN_Number__c) && accTrnMap.get(acc.TRN_Number__c).PropStrength__Broker_Code__c != acc.PropStrength__Broker_Code__c) {
                    acc.addError('This TRN number is already in use');
                }
                if (acc.Registration_Number__c != null && accRegMap.containsKey(acc.Registration_Number__c) && accRegMap.get(acc.Registration_Number__c).PropStrength__Broker_Code__c != acc.PropStrength__Broker_Code__c) {
                    acc.addError('This Registration number is already in use');
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 26-Feb-2024 to add Channel Relationship And Sales Head
    public static void addChannelRelationshipAndSalesHead(List<Account> accList) {
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, ManagerId FROM User WHERE ManagerId != null]);
        Map<String, User> userNameMap = new Map<String, User>();
        // Commented By Gourav Gour 21/06/2024 As Sales_Manager__c is replaced By Sales_Manager_User__c
        // for(User u : userMap.values()) {
            //     if(u.Name != null) {
                //         userNameMap.put(u.Name, u);
            //     }
        // }
        
        for(Account acc : accList) {
            if(acc.RecordTypeId == brokerAccId) {
                if(acc.Channel_Relationship_Head__c == null && acc.Channel_Relationship_Manager__c != null && userMap.containsKey(acc.Channel_Relationship_Manager__c)) {
                    acc.Channel_Relationship_Head__c = userMap.get(acc.Channel_Relationship_Manager__c).ManagerId;
                }
                if(acc.Sales_Director__c == null && acc.Sales_Manager_User__c != null && userMap.containsKey(acc.Sales_Manager_User__c)) {
                    acc.Sales_Director__c = userMap.get(acc.Sales_Manager_User__c).ManagerId;
                }
                if( userMap.containsKey(userInfo.getuserId()))
                    acc.Record_Owner_s_Manager__c = userMap.get(userInfo.getuserId()).ManagerId;
            }
        }
    }
    
    public static void updateBookingFromBrokerAccount(List<Account> accList, Map<Id, Account> oldAccMap) {
        Set<Id> accId = new Set<Id>();
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account accRec : accList) {
            if(accRec.RecordTypeId == brokerAccId && accRec.PropStrength__Broker_Approval_Status__c != null && accRec.PropStrength__Broker_Approval_Status__c != oldAccMap.get(accRec.Id).PropStrength__Broker_Approval_Status__c) {
                accId.add(accRec.Id);
            }
        }
        if(!accId.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookinglist = [SELECT Id,PropStrength__Broker_Account__r.PropStrength__Broker_Approval_Status__c from PropStrength__Application_Booking__c WHERE PropStrength__Broker_Account__c IN :accId AND PropStrength__Active__c = true ];
            for(PropStrength__Application_Booking__c bookRec : bookinglist){
                bookRec.Broker_Approval_Status__c = bookRec.PropStrength__Broker_Account__r.PropStrength__Broker_Approval_Status__c;
            }
            if(bookinglist.size() > 0){
                update bookinglist;
            }
        }
    }
    // Modified By gourav 10/05/2024 -> Id category Individual passport name not be updated.
    public static void updateAccount(List<Account> accList, Map<Id, Account> oldAccMap) {
        Map<String, Account> mapOfAcccountNameChange = new Map<String, Account>();
        Map<String, Account> mapOfAcccountNameAsPassport = new Map<String, Account>();
        Map<String, Account> mapOfNameAcccountNameAsNameTradeLicense = new Map<String, Account>();
        Map<String, Account> mapOfNameAcccountCategory = new Map<String, Account>();
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account accRec : accList) {
            if(accRec.RecordTypeId == brokerAccId ) {
                if(oldAccMap == null){
                    // if(accRec.Broker_Category__c == 'Individual')
                    //     accRec.Name_as_per_passport__c = accRec.name;
                    // else
                    // if(accRec.Broker_Category__c == 'Company')
                    //     accRec.Name_as_per_trade_license__c = accRec.name;
                }
                else{
                    accRec.CHRM_Ops_Email__c = System.Label.CHRM_Ops_Email_Broker_Registration;
                    if(accRec.Name != null && accRec.Name != oldAccMap.get(accRec.Id).Name){
                        if(accRec.Broker_Category__c == 'Individual')
                            accRec.Name_as_per_passport__c = accRec.name;
                        else
                            if(accRec.Broker_Category__c == 'Company')
                            accRec.Name_as_per_trade_license__c = accRec.name;
                    }
                    if(accRec.Name_as_per_passport__c != null && accRec.Name_as_per_passport__c != oldAccMap.get(accRec.Id).Name_as_per_passport__c && accRec.Broker_Category__c == 'Individual'){
                        accRec.name = accRec.Name_as_per_passport__c;
                    }
                    if(accRec.Name_as_per_trade_license__c != null && accRec.Name_as_per_trade_license__c != oldAccMap.get(accRec.Id).Name_as_per_trade_license__c && accRec.Broker_Category__c == 'Company'){
                        accRec.name = accRec.Name_as_per_trade_license__c;
                    }
                    if(accRec.Broker_Category__c != null && accRec.Broker_Category__c != oldAccMap.get(accRec.Id).Broker_Category__c){
                        if(accRec.Broker_Category__c == 'Individual'){
                            accRec.Name_as_per_passport__c = accRec.name;
                            // accRec.Name_as_per_trade_license__c = '';
                        }
                        else
                        if(accRec.Broker_Category__c == 'Company'){
                            accRec.Name_as_per_trade_license__c = accRec.name;
                            // accRec.Name_as_per_passport__c = '';
                        }
                    }
                }
            }
        }
    }
    
    public static void sendMailForVatUpload(List<Account> accList, Map<Id, Account> oldAccMap) {
        Set<Id> accId = new Set<Id>();
        Set<Id> crmAccId = new Set<Id>();
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account accRec : accList) {
            if(accRec.RecordTypeId == brokerAccId && accRec.Email_ID_1__c != null && accRec.PropStrength__Broker_Approval_Status__c == 'Executed Agreement Sent to Broker' && accRec.PropStrength__Broker_Approval_Status__c != oldAccMap.get(accRec.Id).PropStrength__Broker_Approval_Status__c) {
                accId.add(accRec.Id);
            }
            if(accRec.RecordTypeId == brokerAccId && accRec.Channel_Relationship_Manager__c != null && accRec.PropStrength__Broker_Approval_Status__c == 'Broker Registration Done' && accRec.PropStrength__Broker_Approval_Status__c != oldAccMap.get(accRec.Id).PropStrength__Broker_Approval_Status__c) {
                crmAccId.add(accRec.Id);
            }
        }
        if(!accId.isEmpty()) {
            // AccountTriggerHelper.sendVatEmail(accId);
        }
        if(!crmAccId.isEmpty()) {
            AccountTriggerHelper.sendCRMNotificationEmail(crmAccId);
        }
    }
    /*
    public static void sendNocForAuditApprovalProcess(List<Account> accList, Map<Id, Account> oldAccMap) {
        List<Account> accListForApproval = new List<Account>();
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account accRec : accList) {
            if(accRec.RecordTypeId == brokerAccId && accRec.NOC_Generated__c && accRec.PropStrength__Broker_Approval_Status__c == 'NOC Pending with Audit' && accRec.PropStrength__Broker_Approval_Status__c != oldAccMap.get(accRec.Id).PropStrength__Broker_Approval_Status__c) {
                accListForApproval.add(accRec);
            }
        }
        if(!accListForApproval.isEmpty()) {
            for(Account rec : accListForApproval) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('NOC for audit approval when NOC Pending with Audit');
                req1.setObjectId(rec.Id);
                req1.setSubmitterId(rec.ownerId);
                req1.setProcessDefinitionNameOrId('NOC_For_Audit_Approval');
                req1.setSkipEntryCriteria(false);
                Approval.ProcessResult result = Approval.process(req1);
            }
        }
    }
     */
    public static void sendNocForFinalSignature(List<Account> accList, Map<Id, Account> oldAccMap) {
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account accRec : accList) {
            if(accRec.RecordTypeId == brokerAccId && (accRec.PropStrength__Broker_Approval_Status__c == 'Pending with Francis Alfred/ Sent for final signatures' || accRec.PropStrength__Broker_Approval_Status__c == 'Pending with Ashish Parakh/ Sent for final signatures' || accRec.PropStrength__Broker_Approval_Status__c =='Sent for Final Signatures') && accRec.PropStrength__Broker_Approval_Status__c != oldAccMap.get(accRec.Id).PropStrength__Broker_Approval_Status__c) {
                NOCDocusignHandler.forForSigningFuture(accRec.Id);
            }
        }
    }
    /*
    @Future(callout=true)
    public static void sendVatEmail(Set<Id> accId) {
        List<Account> accToSendLetter = [SELECT Id,Name,PropStrength__Broker_Type__c, Email_ID_1__c, OwnerId FROM Account WHERE Id IN : accId];
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        
        for(Account rec : accToSendLetter) {
            List<String> emailAddress = new List<String>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            emailAddress.add(rec.Email_ID_1__c);
            emails.setOrgWideEmailAddressId(owea.get(0).Id);
            emails.setWhatId(rec.Id);
            emails.setToAddresses(emailAddress);
            emails.setSaveAsActivity(true);
            emails.setTargetObjectId(rec.OwnerId);
            emails.setTreatTargetObjectAsRecipient(false);
            emails.setSubject('Upload Vat Document');
            emails.setHtmlBody('Hello Team, <br/> <br/> I hope this email finds you well.<br/> <br/>'+
                'Please Upload Vat doucuments on the Account - ' + rec.Name+'.<br/>' +
                'link for uploading File - '+ 'https://sobharealty--devcs.sandbox.my.salesforce-sites.com/vatupload?Id='+rec.Id +
                '<br/> <br/>Thank you for your attention.<br/><br/> Best regards, <br/><br/> Sobha Reality ');
            
            emaillist.add(emails);
        }
        try{
            if(emaillist != null && emaillist.size()>0 ) {
                Messaging.sendEmail(emaillist);
            }
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
    }
     */
    @Future(callout=true)
    public static void sendCRMNotificationEmail(Set<Id> accId) {
        List<Account> recordList = [SELECT Id, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Email, ownerId, Email_ID_1__c FROM Account WHERE Id IN : accId];
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        // 
        List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE DeveloperName  = 'Broker_Account_Notify_CHRM_Manager_on_Broker_Submission_1688626563177' limit 1];
        Contact dummyContact = new Contact(LastName = 'lastname', Email = 'email@emaik.com');
        insert dummyContact;
        for(Account rec : recordList) {
            List<String> emailAddress = new List<String>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            String st = String.valueOf(rec.Channel_Relationship_Manager__r.Email);
            emailAddress.add(st);
            // emails.setOrgWideEmailAddressId(owea.get(0).Id);
            emails.setWhatId(rec.Id);
            emails.setToAddresses(emailAddress);
            emails.setTemplateId(templatelist[0].Id);
            emails.setSaveAsActivity(false);
            emails.setTargetObjectId(dummyContact.Id);
            emails.setTreatTargetObjectAsRecipient(false);
            emaillist.add(emails);
        }
        try{
            if(emaillist != null && emaillist.size()>0 ) {
                Messaging.sendEmail(emaillist);
            }
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
        delete dummyContact;
    }
    
    public static void SendBrokerRegistrationMail(List<Account> accList) {
        Set<Id> accId = new Set<Id>();
        List<Account> updateAccList = new List<Account>();
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        for(Account acc : accList) {
            System.debug('Send Brokekr registartion Form 1');
            if(!acc.Al_Siniya_Partner__c && acc.Channel_Relationship_Manager__c != null && acc.RecordTypeId == brokerAccId) {
                System.debug('Send Brokekr registartion Form 2');
                accId.add(acc.Id);
                updateAccList.add(new Account(Id = acc.Id, BRF_Link__c = System.Label.BRF_site_Link+'?id='+acc.Id));
            }
        }
        if(!accId.isEmpty()) {
            update updateAccList;
            AccountTriggerHelper.sendBrokerRegForm(accId);
        }
        
    }
    @Future(callout=true)
    public static void sendBrokerRegForm(Set<Id> accId) {
        System.debug('Send Brokekr registartion Form');
        List<Account> accToSendLetter = [SELECT Id,PropStrength__Broker_Type__c, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Email, CHRM_s_Email__c, Email_ID_1__c, OwnerId FROM Account WHERE Id IN : accId];
        List<Messaging.SingleEmailMessage> emaillist = new  List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templatelist = [SELECT id,name FROM EmailTemplate WHERE Name = 'Account Broker Registration Form' limit 1];
        // List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        // owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Helpdesk Sobharealty'];             /*WHERE DisplayName = 'Helpdesk Sobharealty'*/
        
        for(Account rec : accToSendLetter) {
            List<String> emailAddress = new List<String>();
            Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
            String st = String.valueOf(rec.Channel_Relationship_Manager__r.Email);
            emailAddress.add(st);
            // emails.setOrgWideEmailAddressId(owea.get(0).Id);
            emails.setWhatId(rec.Id);
            emails.setToAddresses(emailAddress);
            if(templatelist.size() > 0)
                emails.setTemplateId(templatelist[0].Id);
            emails.setSaveAsActivity(true);
            emails.setTargetObjectId(rec.OwnerId);
            emails.setTreatTargetObjectAsRecipient(false);
            emaillist.add(emails);
        }
        try{
            if(emaillist != null && emaillist.size()>0 ) {
                Messaging.sendEmail(emaillist);
            }
        } catch(Exception ex){
            system.debug('===========Exception ============'+ex.getmessage());
            system.debug('===========Exception ============'+ex.getlinenumber());
        }
    }
    // Added By Gourav Gour 30/05/2024
    @future
    public static void updateBrokerApprovalRecord(String triggerData, String triggerOldData){
        List<Account> newRecords = (List<Account>)Json.deserialize(triggerData,List<Account>.class);
        Map<Id, Account> oldMap = (Map<Id,Account>)Json.deserialize(triggerOldData, Map<Id,Account>.class);
        Map<Id, Account> brFieldUpdateMap = new Map<Id, Account>();
        
        
        for (Account record : newRecords) {
            Account oldRecord = oldMap.get(record.Id);
            if(record.Field_Update_Request_Status__c != oldRecord.Field_Update_Request_Status__c) {
                brFieldUpdateMap.put(record.Id, record);
            }
        }
        if(!brFieldUpdateMap.isEmpty()){
            updateBRApprovalRequestData(brFieldUpdateMap);
        }
    }
    // Added By Gourav Gour 30/05/2024
    public static void updateBRApprovalRequestData(Map<Id, Account> brFieldUpdateMap){
        try{
            List<String> statusFilter = new List<String>{'Pending With CHRM OPS Manager',  'Pending with Audit'};
            List<Broker_Account_Approval_History__c> brarList = [SELECT Id, Status__c, Broker_Account__c from Broker_Account_Approval_History__c where Broker_Account__c IN: brFieldUpdateMap.keyset() AND Status__c IN:statusFilter];
            if(brarList.size()>0){
                for(Broker_Account_Approval_History__c brap: brarList){
                    brap.Status__c = brFieldUpdateMap.get(brap.Broker_Account__c).Field_Update_Request_Status__c;
                }
                update brarList;
            }
        }  catch (Exception e) {
            system.debug(e.getMessage());
        }
    }
    // Added By Gourav Gour 05/06/2024
    public static void updateBillingStreetField(List<Account> accList, Map<Id, Account> oldAccMap){
        for(Account acc : accList) {
            if(oldAccMap == null || (oldAccMap != null && (acc.Street_name__c != oldAccMap.get(acc.Id).Street_name__c || acc.Office_Apartment_number__c != oldAccMap.get(acc.Id).Office_Apartment_number__c
            || acc.Villa_Building_name__c != oldAccMap.get(acc.Id).Villa_Building_name__c   || acc.City_Local__c != oldAccMap.get(acc.Id).City_Local__c 
             || acc.Country_CP__c != oldAccMap.get(acc.Id).Country_CP__c  || acc.Zip_Postal_Code_CP__c != oldAccMap.get(acc.Id).Zip_Postal_Code_CP__c))) {
                acc.BillingStreet = acc.Office_Apartment_number__c != null ? acc.Office_Apartment_number__c+', ' : '';
                acc.BillingStreet = acc.Street_name__c != null ? acc.BillingStreet + acc.Street_name__c +', ' : acc.BillingStreet;
                acc.BillingStreet = acc.Villa_Building_name__c != null ? acc.BillingStreet + acc.Villa_Building_name__c: acc.BillingStreet;
                acc.Billingcity = acc.City_Local__c != null ? acc.City_Local__c : '';
                acc.Billingcountry = acc.Country_CP__c != null ? acc.Country_CP__c : '';
                acc.BillingpostalCode = acc.Zip_Postal_Code_CP__c != null ? acc.Zip_Postal_Code_CP__c : '';

            }
        }
    }
    
    public static void updateCRMOpsUser(List<Account> accList, Map<Id,Account> oldAccMap) {
        Id brokerRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        List<Account> accToBeUpdated = new List<Account>();
        for(Account acc : accList) {
            if(acc.RecordTypeId == brokerRecordId && acc.PropStrength__Broker_Type__c != null && (oldAccMap == null || (oldAccMap != null && acc.PropStrength__Broker_Type__c != oldAccMap.get(acc.Id).PropStrength__Broker_Type__c))) {
                accToBeUpdated.add(acc);
            }
        }
        list<string> sobhaConnectQueueMembers = new list<string>();
        list<string> ChannelPartnerQueueMembers = new list<string>();
        if(!accToBeUpdated.isEmpty()) {
            String EmailForSobhaConnect = '';
            String EmailForChannelPartner = '';
            list<Group> groups = [SELECT Id, email FROM Group WHERE type = 'Queue' AND (DeveloperName='Broker_Reg_Channel_Partner_queue' OR DeveloperName='Broker_Registration_Sobha_Connect_Queue')];
            for(GroupMember gm : [SELECT UserOrGroupId, Group.Email, Group.DeveloperName FROM GroupMember WHERE GroupId IN: groups]){
                if(gm.Group.DeveloperName == 'Broker_Registration_Sobha_Connect_Queue') {
                    sobhaConnectQueueMembers.add(gm.UserOrGroupId);
                    EmailForSobhaConnect = gm.Group.Email != null ? gm.Group.Email : '';
                }
                else {
                    ChannelPartnerQueueMembers.add(gm.UserOrGroupId);
                    EmailForChannelPartner = gm.Group.Email != null ? gm.Group.Email : '';
                }
                
            }
            for(Account acc : accToBeUpdated){
                if(acc.PropStrength__Broker_Type__c.contains('Sobha Connect') && !sobhaConnectQueueMembers.isEmpty()){
                    acc.CHRM_Ops__c = sobhaConnectQueueMembers[0];
                    acc.CHRM_s_Email__c = EmailForSobhaConnect != '' ? EmailForSobhaConnect : '';
                }
                else if(acc.PropStrength__Broker_Type__c.contains('Standard') && !ChannelPartnerQueueMembers.isEmpty()){
                    acc.CHRM_Ops__c = ChannelPartnerQueueMembers[0];
                    acc.CHRM_s_Email__c = EmailForChannelPartner != '' ? EmailForChannelPartner : '';
                }
            }
        }
    }
    
    public static void checkActiveStatus(List<Account> accList, Map<Id,Account> oldAccMap){
        for(Account acc : accList){
            if(acc.PropStrength__Broker_Approval_Status__c != oldAccMap.get(acc.id).PropStrength__Broker_Approval_Status__c && acc.PropStrength__Broker_Approval_Status__c == 'Executed Agreement Sent to CHRM'){
                acc.PropStrength__Active__c = 'Yes';
            }
        }
    }

    //Added by Nishank Manwani on 09 Sept 2024 to update Old CHRM head and manager field
    public static void updateOldChrmFields(List<Account> accList, Map<Id,Account> oldAccMap){
        Set<Id> chrmId = new Set<Id>();

        for(Account acc : accList){
            acc.Effective_Date__c = System.Today();
            if(acc.Channel_Relationship_Manager__c != oldAccMap.get(acc.id).Channel_Relationship_Manager__c && acc.Channel_Relationship_Manager__c != null){
                chrmId.add(acc.Channel_Relationship_Manager__c);
            } else if(acc.Channel_Relationship_Head__c != oldAccMap.get(acc.id).Channel_Relationship_Head__c && acc.Channel_Relationship_Head__c != null) {
                acc.Old_Channel_Relationship_Head__c = oldAccMap.get(acc.id).Channel_Relationship_Head__c;
            }
        }

        if(!chrmId.isEmpty()) {
            Map<Id, User> chrmMap = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :chrmId]);

            for(Account acc : accList){
                acc.Effective_Date__c = System.Today();
                if(acc.Channel_Relationship_Manager__c != oldAccMap.get(acc.id).Channel_Relationship_Manager__c && acc.Channel_Relationship_Manager__c != null){
                    acc.Old_Channel_Relationship_Manager__c = oldAccMap.get(acc.id).Channel_Relationship_Manager__c;
                    acc.Old_Channel_Relationship_Head__c = acc.Channel_Relationship_Head__c;
                    acc.Channel_Relationship_Head__c = chrmMap.get(acc.Channel_Relationship_Manager__c).ManagerId;
                }
            }
        }
    }

    //Added by Nishank Manwani on 17-Sept-2024 to update Broker_Bank_Details_Status__c field when bank details get updated from docusign
    public static void bankDetailsUpdated(List<Account> accList, Map<Id, Account> oldAccMap) {
        for(Account acc : accList) {
            if((acc.TRN_Number__c != oldAccMap.get(acc.Id).TRN_Number__c && oldAccMap.get(acc.Id).TRN_Number__c != null) ||
            (acc.Bank_Account_Name__c != oldAccMap.get(acc.Id).Bank_Account_Name__c && oldAccMap.get(acc.Id).Bank_Account_Name__c != null) ||
            (acc.Bank_Name__c != oldAccMap.get(acc.Id).Bank_Name__c && oldAccMap.get(acc.Id).Bank_Name__c != null) ||
            (acc.Bank_Account_Number__c != oldAccMap.get(acc.Id).Bank_Account_Number__c && oldAccMap.get(acc.Id).Bank_Account_Number__c != null) ||
            (acc.IBAN_Number__c != oldAccMap.get(acc.Id).IBAN_Number__c && oldAccMap.get(acc.Id).IBAN_Number__c != null) ||
            (acc.Currency__c != oldAccMap.get(acc.Id).Currency__c && oldAccMap.get(acc.Id).Currency__c != null) ||
            (acc.Bank_Branch__c != oldAccMap.get(acc.Id).Bank_Branch__c && oldAccMap.get(acc.Id).Bank_Branch__c != null) ||
            (acc.Swift_Routing_Sort_Code__c != oldAccMap.get(acc.Id).Swift_Routing_Sort_Code__c && oldAccMap.get(acc.Id).Swift_Routing_Sort_Code__c != null)) {
                acc.Broker_Bank_Details_Status__c = 'Changed';
            }
        }
    }
    
    
}