public without sharing class BRPortalHeaderButtonController {
    @AuraEnabled
    public static String createCase(String email, String phone, String Remarks, String Subject) {
        //try {
            List<User> lstUser = new List<User>();
            List<Contact> partners = new List<Contact>();
            List<Sobha_Connect__c> sobhapartners = new List<Sobha_Connect__c>();
            List<PropStrength__Service_Request__c> requestList = new List<PropStrength__Service_Request__c>();
            String userName = UserInfo.getUserId();
            system.debug('userName::'+userName);
            if(!String.isBlank(userName)) {
                lstUser = [SELECT Id, ContactId, AccountId 
                            FROM User 
                            WHERE Id =: userName AND 
                                ContactId != null 
                                ORDER BY CreatedDate DESC LIMIT 1];
            }
            system.debug('lstUser::'+lstUser);
            if(!lstUser.isEmpty()) {
                partners = [SELECT id, Account.Channel_Relationship_Manager__c, 
                                Account.Channel_Relationship_Manager__r.Email, 
                                Account.Channel_Relationship_Head__r.Email 
                                FROM Contact 
                                WHERE Id =: lstUser[0].ContactId AND 
                                    Account.Channel_Relationship_Manager__c != null 
                                    LIMIT 1];

                //     partners = [SELECT Channel_Relationship_Manager__c 
                // FROM Channel_Partner__c 
                // WHERE Contact__c =: lstUser[0].ContactId AND 
                //     Channel_Relationship_Manager__c != null 
                //     ORDER BY CreatedDate DESC LIMIT 1];
            }
            String owner_Id;
            if(!Test.isRunningTest()) {
                if(!partners.isEmpty()) {
                    owner_Id = partners[0].Account.Channel_Relationship_Manager__c;
                } else {
                    return 'Channel Relationship Manager in not maintained';
                } /*else if(!lstUser.isEmpty()) {
                    sobhapartners = [SELECT Channel_Relationship_Manager__c 
                                        FROM Sobha_Connect__c 
                                        WHERE Contact__c =: lstUser[0].ContactId AND 
                                            Channel_Relationship_Manager__c != null 
                                            ORDER BY CreatedDate DESC LIMIT 1];
                    if(!sobhapartners.isEmpty()) {
                        owner_Id = sobhapartners[0].Channel_Relationship_Manager__c;
                    }
                }*/
            }
            Id o_Id;
            //Create an Service Request
            if(!lstUser.isEmpty()) {
                PropStrength__Service_Request__c reqRec = new PropStrength__Service_Request__c(); 
                reqRec.Contact__c = lstUser[0].ContactId;
                reqRec.PropStrength__Priority__c = 'High';
                reqRec.PropStrength__Supplied_Email__c = email;
                reqRec.PropStrength__Supplied_Phone__c = phone;
                reqRec.RecordTypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                reqRec.PropStrength__Description__c = (!String.isBlank(Remarks)) ? Remarks : '';
                reqRec.PropStrength__Status__c = 'New';
                reqRec.OwnerId = owner_Id != null ? owner_Id : lstUser[0].Id;
                reqRec.PropStrength__Email_Address__c = (!String.isBlank(email)) ? email : '';
                reqRec.PropStrength__Mobile_Phone__c = (!String.isBlank(phone)) ? phone : '';
                reqRec.PropStrength__Subject__c = (!String.isBlank(Subject)) ? Subject : '';
                reqRec.PropStrength__Origin__c = 'Web';
                reqRec.PropStrength__SR_Type__c = 'Query';
                requestList.add(reqRec);
                o_Id = owner_Id != null ? owner_Id : lstUser[0].Id;
            }
            System.debug('===> requestList ' + requestList);
            if(!requestList.isEmpty()) {
                Id srId;
                Database.SaveResult[] saveSRResult = Database.insert(requestList, false);
                for(Database.SaveResult srSR : saveSRResult) {
                    if(srSR.isSuccess()) {
                        System.debug('===> srSR.getId() ' + srSR.getId());
                        srId = srSR.getId();
                    } else {
                        for(Database.Error errEnq : srSR.getErrors()) {
                            System.debug('===> Exception: ' + errEnq.getMessage());
                        }
                    }
                }
                List<String> emailChainList = new List<String>();
                if(!String.isBlank(email)) {
                    emailChainList.add(email);
                }
                List<String> emailChainCCList = new List<String>();
                if(!partners.isEmpty() && partners[0].Account.Channel_Relationship_Manager__r.Email != null) {
                    emailChainCCList.add(partners[0].Account.Channel_Relationship_Manager__r.Email);
                }
                if(!partners.isEmpty() && partners[0].Account.Channel_Relationship_Head__r.Email != null) {
                    emailChainCCList.add(partners[0].Account.Channel_Relationship_Head__r.Email);
                }
                emailChainCCList.add('channeloperations@sobharealty.com');
                if(!Test.isRunningTest()) {
                    PropStrength__Service_Request__c sr = [SELECT Id, Name, Contact_Name__c FROM PropStrength__Service_Request__c WHERE Id = :srId];
                    send_Email(emailChainList, emailChainCCList, sr.Contact_Name__c, sr.Name);
                }
                return srId;
            }
        /*} catch(Exception e) {
            System.debug('===> Exception ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }*/
        return null;
    }
    @AuraEnabled
    public static void send_Email(List<String> emailAddressList, List<String> emailAddressCCList, String name, String srName) {
        //List<EmailTemplate> templateList = new List<EmailTemplate>();
        /*if(!emailAddressList.isEmpty()) {
            templateList = [SELECT Id, Subject, Body  
                                FROM EmailTemplate 
                                WHERE DeveloperName = 'CreateEnquiry' LIMIT 1];
        }*/
        if(!emailAddressList.isEmpty()) {
            /*Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //email.setToAddresses(emailAddressList);
            email.setToAddresses(new List<String>{'marteen@cloudsteer.com'});
            //email.setSubject('Your Service Request Created Successfully');
            //email.setHtmlBody(' Hi ' + name + ', <br/><br/> Your Service Request ('+srName+') was created successfully. <br/>It was assigned to the CHRM Manager. we will get back to you shortly.<br/><br/>Regards,<br/>Channel Operations');
            email.setWhatId('a49Vc000000BJQj');
            email.setTemplateId('00XVc000000Gd3p');
            email.setTargetObjectId('005Vc0000027SZe');
            email.setSaveAsActivity(true);
            email.setTreatTargetObjectAsRecipient(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});*/

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(emailAddressList);
            if(!emailAddressCCList.isEmpty()) {
                email.setCCAddresses(emailAddressCCList);
            }
            email.setSubject('Your Service Request Created Successfully');
            email.setHtmlBody(' Hi ' + name + ', <br/><br/> Your Service Request (' + srName + ') was created successfully. <br/>It was assigned to the CHRM Manager. we will get back to you shortly.<br/><br/>Regards,<br/>Channel Operations');
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            }
        }
    }
    @AuraEnabled
    public static List<SRWrapper> getAllCasesByCurrentUser() {
        String userId = UserInfo.getUserId();
        List<User> lstUser = new List<User>();
        List<SRWrapper> wrapList = new List<SRWrapper>();
        if(!String.isBlank(userId)) {
            lstUser = [SELECT Id, ContactId 
                        FROM User 
                        WHERE Id =: userId AND 
                            ContactId != null 
                            ORDER BY CreatedDate DESC LIMIT 1];
        }
        if(!lstUser.isEmpty()) {
            for(PropStrength__Service_Request__c req : [SELECT Id, Name, CreatedDate, PropStrength__Assigned_To__c, 
                                                            SR_Closed_Date__c, PropStrength__Description__c, 
                                                            PropStrength__Status__c, PropStrength__Email_Address__c, 
                                                            PropStrength__Subject__c 
                                                            FROM PropStrength__Service_Request__c 
                                                            WHERE (Contact__c =: lstUser[0].ContactId OR PropStrength__Assigned_To__c = :lstUser[0].ContactId)
                                                                ORDER BY CreatedDate DESC LIMIT 9999]) {
                SRWrapper wrap = new SRWrapper();
                wrap.srRecord = req;
                wrap.createDate = req.CreatedDate.format('dd/MM/yyyy');
                wrap.closeDate = req.SR_Closed_Date__c != null ? req.SR_Closed_Date__c.format('dd/MM/yyyy') : '';
                wrapList.add(wrap);
            }
        }
        return wrapList;
    }
    public class SRWrapper {
        @AuraEnabled
        public PropStrength__Service_Request__c srRecord {get; set;}
        @AuraEnabled
        public String createDate {get; set;}
        @AuraEnabled
        public String closeDate {get; set;}
    }
}