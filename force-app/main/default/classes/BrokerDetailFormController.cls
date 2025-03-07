/*********************************************************************
 * Class Name  :   BrokerDetailFormController
 * Description :   Controller class for the BrokerDetailFormLWC VF component. This class
                    will handle Add Account and it's Contact Records
 * Created Date:   07/07/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 *********************************************************************/
public class BrokerDetailFormController {
    @AuraEnabled
    public static Account accountRecMethod(String aiSiniya, String brkCat, String accSm, String accCr, String accName, String accTrnNumber, String accBrkType, String accBrkSubType, String accPhone, String accEmail, String accRegNo, String accDoj, String accResDate, String accTermDate, String accAlterPhone, String contactRecs, String contryCode, String countryAcc, String chrmEmail) {
        try {
            System.debug('===> Start Here');
            Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
            Account acc = new Account();
            Account accClone = new Account();
            if(!String.isBlank(brkCat)) {
                acc.Broker_Category__c = brkCat;
            }
            if(!String.isBlank(aiSiniya)) {
                acc.Al_Siniya_Partner__c = Boolean.valueOf(aiSiniya);
            } 
            if(!String.isBlank(accSm)) {
                acc.Sales_Manager_User__c = accSm;
                User u = [SELECT Id, Name FROM USER WHERE Id =: accSm LIMIT 1];
                acc.Sales_Manager__c = u.Name;
            } 
            if(!String.isBlank(accCr)) {
                acc.Channel_Relationship_Manager__c = accCr;
            } else {
                acc.Channel_Relationship_Manager__c = UserInfo.getUserId();
            }
            if(accTrnNumber != null && accTrnNumber != '') {
                acc.TRN_Number__c = accTrnNumber;
                acc.Registration_Number__c = accTrnNumber;
            }
            if(accBrkType != null && accBrkType != '') {
                acc.PropStrength__Broker_Type__c = accBrkType;
            }
            if(accBrkSubType != null && accBrkSubType != '') {
                acc.Broker_Sub_Type__c = accBrkSubType;
            }
            if(accName != null && accName != '') {
                acc.Name = accName;
            }
            if(accPhone != null && accPhone != '') {
                acc.Phone = accPhone;
                acc.Mobile_No__c = accPhone;
            }
            if(contryCode != null && contryCode != '') {
                acc.Country_Code__c = contryCode;
            }
            if(countryAcc != null && countryAcc != '') {
                acc.Country__c = contryCode;
            }
            if(accRegNo != null && accRegNo != '') {
                acc.Registration_Passport_Number__c = accRegNo;
                acc.Registration_Number__c = accRegNo;
            }
            if(accDoj != null && accDoj != '') {
                acc.RERA_Registration_No__c = accDoj.contains('/')?accDoj.substring(accDoj.lastIndexOf('/')+1):accDoj;
            }
            if(accResDate != null && accResDate != '') {
                acc.Registration_Date__c = Date.parse(accResDate);
            }
            if(accTermDate != null && accTermDate != '') {
                acc.Expiry_Date__c = Date.parse(accTermDate);
            }
            if(accAlterPhone != null && accAlterPhone != '') {
                acc.Email_ID_1__c = accAlterPhone;
            }
            if(chrmEmail != null && chrmEmail != '') {
                acc.CHRM_s_Email__c = chrmEmail;
            }
            acc.Is_Active__c = true;
            acc.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
            acc.Registration_Link_Expiry_Date_Time__c = System.now().addDays(30);
            acc.RecordTypeId = RecordTypeIdAccount;
            acc.Broker_Created_Date__c = System.now();
            if(acc.Al_Siniya_Partner__c) {
                List<Account> accList = new List<Account>();
                if(brkCat != null && brkCat != '') {
                    accClone.Broker_Category__c = brkCat;
                }
                if(accSm != null && accSm != '') {
                    accClone.Sales_Manager_User__c = accSm;
                    User u = [SELECT Id, Name FROM USER WHERE Id =: accSm LIMIT 1];
                    accClone.Sales_Manager__c = u.Name;
                } 
                if(accCr != null && accCr != '') {
                    accClone.Channel_Relationship_Manager__c = accCr;
                } else {
                    accClone.Channel_Relationship_Manager__c = UserInfo.getUserId();
                }
                if(accTrnNumber != null && accTrnNumber != '') {
                    accClone.TRN_Number__c = accTrnNumber;
                    accClone.Registration_Number__c = accTrnNumber;
                }
                if(accBrkType != null && accBrkType != '') {
                    accClone.PropStrength__Broker_Type__c = accBrkType;
                }
                if(accBrkSubType != null && accBrkSubType != '') {
                    accClone.Broker_Sub_Type__c = accBrkSubType;
                }
                if(accName != null && accName != '') {
                    accClone.Name = accName;
                }
                if(accPhone != null && accPhone != '') {
                    accClone.Phone = accPhone;
                    accClone.Mobile_No__c = accPhone;
                }
                if(contryCode != null && contryCode != '') {
                    accClone.Country_Code__c = contryCode;
                }
                if(countryAcc != null && countryAcc != '') {
                    accClone.Country__c = contryCode;
                }
                if(accRegNo != null && accRegNo != '') {
                    accClone.Registration_Passport_Number__c = accRegNo;
                    accClone.Registration_Number__c = accRegNo;
                }
                if(accDoj != null && accDoj != '') {
                    accClone.RERA_Registration_No__c = accDoj.contains('/')?accDoj.substring(accDoj.lastIndexOf('/')+1):accDoj;
                }
                if(accResDate != null && accResDate != '') {
                    accClone.Registration_Date__c = Date.parse(accResDate);
                }
                if(accTermDate != null && accTermDate != '') {
                    accClone.Expiry_Date__c = Date.parse(accTermDate);
                }
                if(accAlterPhone != null && accAlterPhone != '') {
                    accClone.Email_ID_1__c = accAlterPhone;
                }
                if(chrmEmail != null && chrmEmail != '') {
                    accClone.CHRM_s_Email__c = chrmEmail;
                }
                accClone.Is_Active__c = true;
                accClone.PropStrength__Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
                accClone.Registration_Link_Expiry_Date_Time__c = System.now().addDays(30);
                accClone.RecordTypeId = RecordTypeIdAccount;
                accClone.Al_Siniya_Partner__c = false;
                accClone.Broker_Created_Date__c = System.now();
                Map<String, Integer> MapOfMaxBrokerCode = new Map<String, Integer>();
                /*List<AggregateResult> accRec = [SELECT MAX(PropStrength__Broker_Code__c) BR 
                                                FROM Account 
                                                WHERE RecordType.Name = 'Broker' AND 
                                                    (PropStrength__Broker_Type__c = 'Standard' OR 
                                                    PropStrength__Broker_Type__c = 'Sobha Connect') AND 
                                                    PropStrength__Broker_Code__c != null 
                                                    GROUP BY PropStrength__Broker_Type__c];*/
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
                System.debug('===> MapOfMaxBrokerCode****');
                System.debug(MapOfMaxBrokerCode);
                if(MapOfMaxBrokerCode.containsKey(acc.PropStrength__Broker_Type__c) && 
                    MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) != null) {
                    if(acc.PropStrength__Broker_Type__c == 'Standard') {
                        System.debug('===> CP ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0'));
                        acc.PropStrength__Broker_Code__c = 'CP - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0');
                        accClone.PropStrength__Broker_Code__c = 'CP - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0');
                        acc.Last_Broker_Code__c = MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1;
                    } else if (acc.PropStrength__Broker_Type__c == 'Sobha Connect') {
                        System.debug('===> CP ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0'));
                        acc.PropStrength__Broker_Code__c = 'SC - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0');
                        accClone.PropStrength__Broker_Code__c = 'SC - ' + String.valueOf(MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c)+1).leftPad(5,'0');
                        acc.Last_Broker_Code__c = MapOfMaxBrokerCode.get(acc.PropStrength__Broker_Type__c) + 1;
                    }
                } else {
                    if (acc.PropStrength__Broker_Type__c == 'Standard') {
                        acc.PropStrength__Broker_Code__c = 'CP - 00001';
                        accClone.PropStrength__Broker_Code__c = 'CP - 00001';
                        acc.Last_Broker_Code__c = 1;
                    }
                    else if (acc.PropStrength__Broker_Type__c == 'Sobha Connect') {
                        acc.PropStrength__Broker_Code__c = 'SC - 00001';
                        accClone.PropStrength__Broker_Code__c = 'SC - 00001';
                        acc.Last_Broker_Code__c = 1;
                    }
                }
                accList.add(acc);
                accList.add(accClone);
                insert accList;
            } else {
                insert acc;
            }

            if(accCr != null && accCr != '') {
                //BrokerDetailFormController.sendMailToChannelPartner(acc.Id);
            }

            List<Contact> conts = new List<Contact>();
            contactRecs = contactRecs.substring(contactRecs.indexOf('"'),contactRecs.lastIndexOf('"'));
            for(String str: contactRecs.split('}","')) {
                str += '}"';
                Map<String, Object> finalResult = (Map<String, Object>)JSON.deserializeUntyped(str.substring(str.indexOf(':')+2,str.length()-1));
                if(acc.Al_Siniya_Partner__c) {
                    conts.add(new Contact(Al_Siniya_Partner__c = true, RecordTypeId=RecordTypeIdContact, AccountId = acc.Id, FirstName = (String)finalResult.get('FirstName'), Country_Code__c = (String)finalResult.get('CountryCode'), LastName = (String)finalResult.get('LastName'), Email = (String)finalResult.get('Email'), MobilePhone = (String)finalResult.get('Phone'), PropStrength__Nationality__c = (String)finalResult.get('Nationality'), Passport_No__c = (String)finalResult.get('PassportNumber'), Passport_Nationality__c = (String)finalResult.get('PassportNationality'), Passport_Issue_Date__c = (String)finalResult.get('PassportIssueDate') != null && (String)finalResult.get('PassportIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportIssueDate'))):null, Passport_Expiry_Date__c = (String)finalResult.get('PassportExpiryDate') != null && (String)finalResult.get('PassportExpiryDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportExpiryDate'))) : null, Emirates_ID__c = (String)finalResult.get('EmiratesId'), Emirates_ID_Issue_Date__c = (String)finalResult.get('EmiratesIdIssueDate')!= null && (String)finalResult.get('EmiratesIdIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdIssueDate'))) : null, Emirates_ID_Expiry_Date__c = (String)finalResult.get('EmiratesIdExpiryDate') != null&&(String)finalResult.get('EmiratesIdExpiryDate') != ''?Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdExpiryDate'))):null));
                    conts.add(new Contact(RecordTypeId=RecordTypeIdContact, AccountId = accClone.Id, FirstName = (String)finalResult.get('FirstName'), Country_Code__c = (String)finalResult.get('CountryCode'), LastName = (String)finalResult.get('LastName'), Email = (String)finalResult.get('Email'), MobilePhone = (String)finalResult.get('Phone'), PropStrength__Nationality__c = (String)finalResult.get('Nationality'), Passport_No__c = (String)finalResult.get('PassportNumber'), Passport_Nationality__c = (String)finalResult.get('PassportNationality'), Passport_Issue_Date__c = (String)finalResult.get('PassportIssueDate') != null && (String)finalResult.get('PassportIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportIssueDate'))):null, Passport_Expiry_Date__c = (String)finalResult.get('PassportExpiryDate') != null && (String)finalResult.get('PassportExpiryDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportExpiryDate'))) : null, Emirates_ID__c = (String)finalResult.get('EmiratesId'), Emirates_ID_Issue_Date__c = (String)finalResult.get('EmiratesIdIssueDate')!= null && (String)finalResult.get('EmiratesIdIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdIssueDate'))) : null, Emirates_ID_Expiry_Date__c = (String)finalResult.get('EmiratesIdExpiryDate') != null&&(String)finalResult.get('EmiratesIdExpiryDate') != ''?Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdExpiryDate'))):null));
                } else {
                    conts.add(new Contact(RecordTypeId=RecordTypeIdContact, AccountId = acc.Id, FirstName = (String)finalResult.get('FirstName'), Country_Code__c = (String)finalResult.get('CountryCode'), LastName = (String)finalResult.get('LastName'), Email = (String)finalResult.get('Email'), MobilePhone = (String)finalResult.get('Phone'), PropStrength__Nationality__c = (String)finalResult.get('Nationality'), Passport_No__c = (String)finalResult.get('PassportNumber'), Passport_Nationality__c = (String)finalResult.get('PassportNationality'), Passport_Issue_Date__c = (String)finalResult.get('PassportIssueDate') != null && (String)finalResult.get('PassportIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportIssueDate'))):null, Passport_Expiry_Date__c = (String)finalResult.get('PassportExpiryDate') != null && (String)finalResult.get('PassportExpiryDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('PassportExpiryDate'))) : null, Emirates_ID__c = (String)finalResult.get('EmiratesId'), Emirates_ID_Issue_Date__c = (String)finalResult.get('EmiratesIdIssueDate')!= null && (String)finalResult.get('EmiratesIdIssueDate') != '' ? Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdIssueDate'))) : null, Emirates_ID_Expiry_Date__c = (String)finalResult.get('EmiratesIdExpiryDate') != null&&(String)finalResult.get('EmiratesIdExpiryDate') != ''?Date.parse(BrokerDetailFormController.formatDate((String)finalResult.get('EmiratesIdExpiryDate'))):null));
                }
            }
            if(!conts.isEmpty()) {
                insert conts;
            }

            return acc;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @Future(Callout=True)
    public static void sendMailToChannelPartner(String accId) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> efalst = new  List<Messaging.Emailfileattachment>();
        List<String> sendTo = new List<String>(); 
        set<String> emailAddress = new set<String>(); 
        String tempId = '';
        List<Account> accRecs = [SELECT Id, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Email 
                                                                FROM Account
                                                                WHERE Id = :accId];

        if(!accRecs.isEmpty()) {
            List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                    FROM EmailTemplate 
                                                    WHERE DeveloperName =: 'New_Broker_Account_Created'];
            if(emailTemplate.size() > 0)
                tempId  = emailTemplate[0].Id;
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'helpdesk@sobharealty.com' LIMIT 1];  

            for(Account acc : accRecs) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //if(!sendTo.isEmpty()) {
                    email.setToAddresses(new List<String>{acc.Channel_Relationship_Manager__r.Email});
                //}
                email.setWhatId(acc.id);
                email.setTargetObjectId(acc.Channel_Relationship_Manager__c);
                email.setTreatTargetObjectAsRecipient(False);
                email.setSaveAsActivity(true); 
                email.setTemplateId(tempId);
                if(!owea.isEmpty()) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                system.debug('sendTo::'+sendTo);
                mails.add(email); 
            }
            try {
                if(!mails.isEmpty()){
                    Messaging.sendEmail(mails);
                }
            } catch(Exception e){
                System.debug('--------------Exception in Sending emails--------------------'+e.getMessage());
                System.debug('--------------Exception in Sending emails Line Number::'+e.getLineNumber());
            }
        }
    }
    @AuraEnabled
    public static String registartionNoValidate(String regNumber) {
        Id brokerAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList = [SELECT Id, Name, Registration_Passport_Number__c, TRN_Number__c, PropStrength__Broker_Code__c, Registration_Number__c 
                        FROM Account 
                        WHERE RecordTypeId = :brokerAccId 
                        AND (Registration_Passport_Number__c = :regNumber OR TRN_Number__c = :regNumber OR Registration_Number__c = :regNumber)];
        if(accountList.size()  == 0) {
            return 'Success';
        }
        else {
            return accountList[0].Name;
        }
    }

    @AuraEnabled
    public static String formatDate(String inputDate) {
        if(inputDate != null && inputDate != '') {
            
        String[] parts = inputDate.split('-');
        String day = parts[2].substring(0, 2);
        String month = parts[1];
        String year = parts[0];
        
        return day + '/' + month + '/' + year;
        } 
        return '';
    }
    @AuraEnabled
    public static String getChrmEmail(String searchKeyWrd) {
        User u = [SELECT Id, Email FROM User WHERE Id = :searchKeyWrd];
        return u.Email;
    }

    @AuraEnabled
    public static User getChrmUser() {
        User u = [SELECT Id, Name, Role_Name__c, Email FROM User WHERE Id =  :UserInfo.getUserId()];

        if(u.Role_Name__c.containsIgnoreCase('Channel Relationship Manager')) {
            return u;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<User> searchSalesManager(String searchKeyWrd){
        if(searchKeyWrd != '') {
            searchKeyWrd = '%' + searchKeyWrd + '%';
            return [SELECT Id, Name FROM User WHERE Name LIKE :searchKeyWrd];
        } else {
            return [SELECT Id, Name FROM User];
        }
    }
}