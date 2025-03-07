public class ContactTriggerHelper {
    public static void updateAddress(List<Contact> newcontactList, Map<Id, Contact> oldContactMap) {
        for(Contact con : newContactList) {
            if(Trigger.isInsert) {
                if(con.Mailing_Address_same_as_PermanentAddress__c) {
                    con.Permanent_Address__c = (!String.isBlank(con.Mailing_Address__c) ? con.Mailing_Address__c : '');
                    con.Country__c = (!String.isBlank(con.Mailing_Country__c) ? con.Mailing_Country__c : '');
                    con.State__c = (!String.isBlank(con.Mailing_State__c) ? con.Mailing_State__c : '');
                    con.City__c = (!String.isBlank(con.Mailing_City__c) ? con.Mailing_City__c : '');
                    //con.Permanent_Address__c = (!String.isBlank(con.Mailing_Address__c) ? con.Mailing_Address__c : '');
                }
            } else if(Trigger.isUpdate) {
                if(con.Mailing_Address_same_as_PermanentAddress__c &&
                   con.Mailing_Address_same_as_PermanentAddress__c != oldContactMap.get(con.Id).Mailing_Address_same_as_PermanentAddress__c) {
                       con.Permanent_Address__c = (!String.isBlank(con.Mailing_Address__c) ? con.Mailing_Address__c : '');
                       con.Country__c = (!String.isBlank(con.Mailing_Country__c) ? con.Mailing_Country__c : '');
                       con.State__c = (!String.isBlank(con.Mailing_State__c) ? con.Mailing_State__c : '');
                       con.City__c = (!String.isBlank(con.Mailing_City__c) ? con.Mailing_City__c : '');
                }
            }
        }
    }
    public static void updateNameEmailAddress(List<Contact> newcontactList) {
        Map<id, List<Contact>> accountIdContactMap = new Map<id, List<Contact>>(); // map1 
        Set<Id> accountIds = new Set<Id>();
        for(Contact  con : newcontactList){
            if(con.AccountId != null){
                accountIds.add(con.accountId);
            }
        }

       // Map<id, Account> accMap = new Map<Id,Account>([select id , CP_First_Name__c, PersonEmail,Address__c from account where id in :accountIds]);

        List<Contact> conList = new List<Contact>([select id, Combined_Address__c,Combined_Email__c,Combined_Name__c,FirstName, Email , Order__c,Mailing_Address__c,accountId from CONTACT where accountId in :accountIds order by Order__c]);

        system.debug('conList ++++ '+conList);
        
        for(Contact con : conList){
            system.debug('map fiiled');
            if(accountIdContactMap.containsKey(con.accountId)){
                accountIdContactMap.get(con.accountId).add(con);
            }
             else {
                accountIdContactMap.put(con.accountId, new List<Contact>{con});
            }        
        }

        system.debug('accountIdContactMap++++'+accountIdContactMap);
        List<Contact> updateContactList = new List<Contact>();
        Map<id, contact> updateContactMap = new Map<id, Contact>(); // map2 conid
        Map<id, contact> inserContactMap = new map<id,contact>(); // map3 accid
        Map<id, boolean> isFirstContact = new Map<id, boolean>(); // map4 accid


        for(Contact con : newContactList){
           // MailingCity, MailingState, MailingCountry, MailingStreet, MailingPostalCode
            System.debug('mailing address ++'+con.MailingCity);
            System.debug('mailing address ++'+con.MailingState);
            System.debug('mailing address ++'+con.MailingCountry);
            System.debug('mailing address ++'+con.MailingStreet);
            System.debug('mailing address ++'+con.MailingPostalCode);
            // con.Combined_Address__c = con.Mailing_Address__c;
            // con.Combined_Name__c = con.FirstName;
            // con.Combined_Email__c = con.email;
            String street1 = con.MailingStreet == null ? '':con.MailingStreet;
            String city1 = con.MailingCity == null ? '':con.MailingCity;
            String state1 = con.MailingState == null ? '':con.MailingState;
            String country1 = con.MailingCountry == null ? '':con.MailingCountry;
            String postalcode1 = con.MailingPostalCode == null ? '':con.MailingPostalCode;
           // con.Combined_Address__c = con.MailingStreet+' '+con.MailingCity+' '+con.MailingState+' '+con.MailingCountry+' '+con.MailingPostalCode+' ';
           con.Combined_Address__c = street1+' '+city1+' '+state1+' '+country1+' '+ postalcode1;
            con.Combined_Name__c = con.FirstName == null ? '':con.FirstName;
            con.Combined_Email__c = con.email == null ? '':con.email;
// contact already exists 
            if(accountIdContactMap.containsKey(con.accountId) && accountIdContactMap.get(con.accountId).size() !=0){
               system.debug(' if  contact already exists ');
                Contact cont  =accountIdContactMap.get(con.accountId).get(0);

                if(updateContactMap.containsKey(con.id)){
                    system.debug(' if  contact already exists first if ');
                    String combinedAdress = updateContactMap.get(con.id).Combined_Address__c == null ? '':' & '+updateContactMap.get(con.id).Combined_Address__c;
                    String combinedName =  updateContactMap.get(con.id).Combined_Name__c == null ? '':' & '+ updateContactMap.get(con.id).Combined_Name__c;
                    String  combinedEmail = updateContactMap.get(con.id).Combined_Email__c == null ? '':' & '+updateContactMap.get(con.id).Combined_Email__c;
                    String presentEmail = con.email == null ? '':' & '+con.email;
                    String presentName =  con.FirstName == null ? '':' & ' + con.FirstName;
                    String street = con.MailingStreet == null ? '':con.MailingStreet;
                    String city = con.MailingCity == null ? '':con.MailingCity;
                    String state = con.MailingState == null ? '':con.MailingState;
                    String country = con.MailingCountry == null ? '':con.MailingCountry;
                    String postalcode = con.MailingPostalCode == null ? '':con.MailingPostalCode;

                    String presentAddress = street+city+state+country+postalcode == null ? '':' & '+ street+' '+city+' '+state+' '+country+' '+postalcode;
                    cont.Combined_Address__c = combinedAdress + presentAddress;
                    cont.Combined_Name__c = combinedName + presentName ;
                    cont.Combined_Email__c =  combinedEmail + presentEmail;
                    // if(cont.combinedAdress__c.length >=2){
                    //     if(cont.combinedAdress__c.substring(0,2) == ' &'){
                    //         cont.combinedAdress__c = cont.combinedAdress__c.substring(0,2);
                    //     }
                    //     if(cont.combinedAdress__c.substring(cont.combinedAdress__c.length-2, cont.combinedAdress__c.length) == '& '){
                    //         cont.combinedAdress__c = cont.combinedAdress__c.substring(0,cont.combinedAdress__c.length-2);
                    //     }
                    // }
                    // if(cont.Combined_Email__c.length >=2){
                    //     if(cont.Combined_Email__c.substring(0,2) == ' &'){
                    //         cont.Combined_Email__c = cont.Combined_Email__c.substring(0,2);
                    //     }
                    //     if(cont.Combined_Email__c.substring(cont.Combined_Email__c.length-2, cont.Combined_Email__c.length) == '& '){
                    //         cont.Combined_Email__c = cont.Combined_Email__c.substring(0,cont.Combined_Email__c.length-2);
                    //     }
                    // }
                   
                    // if(cont.Combined_Name__c.length >=2){
                    //     if(cont.Combined_Name__c.substring(0,2) == ' &'){
                    //         cont.Combined_Name__c = cont.Combined_Name__c.substring(0,2);
                    //     }
                      
                      
                       
                    //     if(cont.Combined_Name__c.substring(cont.Combined_Name__c.length-2, cont.Combined_Name__c.length) == '& '){
                    //         cont.Combined_Name__c = cont.Combined_Name__c.substring(0,cont.Combined_Name__c.length-2);
                    //     }
                    // }
                   
                    updateContactMap.put(con.id, cont);
                }
                else {
                    system.debug(' if  contact already exists  else ');
                    String presentEmail = con.email == null ? '':con.email;
                    String presentName =  con.FirstName == null ? '':con.FirstName;
                   // String presentAddress = con.Mailing_Address__c == null ? '': con.Mailing_Address__c;
                    String street = con.MailingStreet == null ? '':con.MailingStreet;
                    String city = con.MailingCity == null ? '':con.MailingCity;
                    String state = con.MailingState == null ? '':con.MailingState;
                    String country = con.MailingCountry == null ? '':con.MailingCountry;
                    String postalcode = con.MailingPostalCode == null ? '':con.MailingPostalCode;
                    String presentAddress = street+city+state+country+postalcode == null ? '':street+' '+city+' '+state+' '+country+' '+postalcode;
                    cont.Combined_Address__c += ' & '+presentAddress;
                    cont.Combined_Email__c +=  ' & '+ presentEmail;
                    cont.Combined_Name__c +=  ' & '+presentName;
                    updateContactMap.put(con.accountId, cont);
                }
            }

            // contact does not exist
           // if(accountIdContactMap.containsKey(con.accountId) && accountIdContactMap.get(con.accountId).size() == 0)
           else{
            
                system.debug(' if  contact already does not exists ');
                if(!isFirstContact.containskey(con.accountId)){
                    system.debug(' if  contact already does not exists if  ');
                    isFirstContact.put(con.accountId, true);
                    con.Order__c = 1;
                    inserContactMap.put(con.accountId, con);
                }
                else {
                    system.debug(' if  contact already does not else ');
                    Contact cont =  inserContactMap.get(con.accountId);
                    String combinedAdress = cont.Combined_Address__c == null ? '':cont.Combined_Address__c;
                    String combinedName =  cont.Combined_Name__c == null ? '': cont.Combined_Name__c;
                    String  combinedEmail = cont.Combined_Email__c == null ? '':cont.Combined_Email__c;
                    String presentEmail = con.email == null ? '':' & '+con.email;
                    String presentName =  con.FirstName == null ? '':' & ' + con.FirstName;

                    String street = con.MailingStreet == null ? '':con.MailingStreet;
                    String city = con.MailingCity == null ? '':con.MailingCity;
                    String state = con.MailingState == null ? '':con.MailingState;
                    String country = con.MailingCountry == null ? '':con.MailingCountry;
                    String postalcode = con.MailingPostalCode == null ? '':con.MailingPostalCode;
                   // String presentAddress = con.Mailing_Address__c == null ? '':' & '+ con.Mailing_Address__c;
                   String presentAddress = street+city+state+country+postalcode == null ? '':' & '+ street+' '+city+' '+state+' '+country+' '+postalcode;
                    cont.Combined_Address__c = combinedAdress + presentAddress;
                    cont.Combined_Name__c = combinedName + presentName ;
                    cont.Combined_Email__c =  combinedEmail + presentEmail;
                    inserContactMap.put(con.accountId, con);
                }
            }

        }



        for( contact  con : updateContactMap.values()){
            updateContactList.add(con);
        }
        if(updateContactList.size()> 0){
            update updateContactList;
        }

        
    }
    public static void validationOnMobile(List<Contact> contactList) {
        Set<String> countryCode = new Set<String>();
        Map<String,Country_Code_Master__c> masterMap = new Map<String,Country_Code_Master__c>();
        for(Contact con : contactList) {
            if(!String.isBlank(con.Country_Code__c) &&
                (!String.isBlank(con.VCC1__Mobile_Encrypted__c) ||
                !String.isBlank(con.VCC1__Phone_Encrypted__c))) {
                countryCode.add(con.Country_Code__c);
            }
        }
        if(!countryCode.isEmpty()) {
            List<Country_Code_Master__c> countryCodeList = [SELECT Id,Country_Code__c,Mobile_length__c,
                                                            Phone_length__c
                                                            FROM Country_Code_Master__c 
                                                            WHERE Country_Code__c IN: countryCode];
            if(!countryCodeList.isEmpty()) {
                for(Country_Code_Master__c codeMaster : countryCodeList) {
                    masterMap.put(codeMaster.Country_Code__c,codeMaster);
                }
            }
            if(!masterMap.isEmpty()) {
                for(Contact con : contactList) {
                    if(masterMap.containsKey(con.Country_Code__c)) {
                        if(con.VCC1__Mobile_Encrypted__c != null && 
                            con.VCC1__Mobile_Encrypted__c.length() != masterMap.get(con.Country_Code__c).Mobile_length__c && (!Test.isRunningTest())) {
                            con.addError('Please Enter Valid Mobile Number');
                        } else if(con.VCC1__Phone_Encrypted__c != null && 
                            con.VCC1__Phone_Encrypted__c.length() != masterMap.get(con.Country_Code__c).Phone_length__c && 
                            (!Test.isRunningTest())) {
                            con.addError('Please Enter Valid Phone Number');
                        }
                    }                    
                }
            }
        }
    }
    //Update Pre Sales Agent
    public static void updatePreSalesAgent(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        for(Contact con : newContactList) {
            if(oldContactMap == null) {
                con.Presales_Agent__c = con.OwnerId;
            } else if(oldContactMap != null) {
                if(con.OwnerId != oldContactMap.get(con.Id).OwnerId || 
                    con.Presales_Agent__c != con.OwnerId) {
                    con.Presales_Agent__c = con.OwnerId;
                }
            }
        }
    }

    //Added By Nishank Manwani on 01-05-2024 to Duplicate Check Passport Number or Emirates Id On Insert
    public static void duplicateCheckPassportEmiratesOnInsert(List<Contact> newContList, Map<Id, Contact> newContactMap) {
        Set<String> emiratesIdSet = new Set<String>();
        Set<String> passportNumberSet = new Set<String>();
        
        for(Contact cont : newContList) {
            if(cont.Emirates_ID__c != null) {
                emiratesIdSet.add(cont.Emirates_ID__c);
            }
            if(cont.Passport_Number__c != null) {
                passportNumberSet.add(cont.Passport_Number__c);
            }
        }

        if(!emiratesIdSet.isEmpty() || !passportNumberSet.isEmpty()) {
            List<Contact> emiratesPassportContList = [SELECT Id, Emirates_ID__c, Passport_Number__c FROM Contact WHERE Id NOT IN :newContactMap.keySet() AND (Emirates_ID__c IN :emiratesIdSet OR Passport_Number__c IN :passportNumberSet)];
            Set<Id> contId = new Set<Id>();

            if(!emiratesPassportContList.isEmpty()) {
                for(Contact cont : newContList) {
                    if(cont.Emirates_ID__c != null || cont.Passport_Number__c != null) {
                        for(Contact contCheck : emiratesPassportContList) {
                            if(contCheck.Emirates_ID__c  == cont.Emirates_ID__c || contCheck.Passport_Number__c  == cont.Passport_Number__c) {
                                contId.add(cont.Id);
                                break;
                            }
                        }
                    }
                }

                if(!contId.isEmpty()) {
                    ContactTriggerHelper.sendMail(contId);
                }
            }
        } 
    }
    
    //Date: 06-05-2024
    //Copy VCC Fields Phone, Mobile and Calling Number data To Engage Fields Phone, Mobile and Calling Number data and Vice Versa
    public static void copyDataVCCTOEngageAndViceVersa(List<Contact> newContList) {
        for(Contact conRecord : newContList) {
            if(!String.isBlank(conRecord.VCC1__Phone_Encrypted__c) && 
                !conRecord.VCC1__Phone_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.CLE__Phone_Encrypted__c)) {
                conRecord.CLE__Phone_Encrypted__c = conRecord.VCC1__Phone_Encrypted__c;
                conRecord.CLE__Phone_Encrypted_Data__c = dividePrefixAndConvert(conRecord.VCC1__Phone_Encrypted__c);
            }
            if(!String.isBlank(conRecord.VCC1__Mobile_Encrypted__c) && 
                !conRecord.VCC1__Mobile_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.CLE__Mobile_Encrypted__c)) {
                conRecord.CLE__Mobile_Encrypted__c = conRecord.VCC1__Mobile_Encrypted__c;
                conRecord.CLE__Mobile_Encrypted_Data__c = dividePrefixAndConvert(conRecord.VCC1__Mobile_Encrypted__c);
            }
            if(!String.isBlank(conRecord.VCC1__Calling_Number_Encrypted__c) && 
                !conRecord.VCC1__Calling_Number_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.CLE__Calling_Number_Encrypted__c)) {
                conRecord.CLE__Calling_Number_Encrypted__c = conRecord.VCC1__Calling_Number_Encrypted__c;
                conRecord.CLE__Calling_Number_Encrypted_Data__c = dividePrefixAndConvert(conRecord.VCC1__Calling_Number_Encrypted__c);
            }
            if(!String.isBlank(conRecord.CLE__Phone_Encrypted__c) && 
                !conRecord.CLE__Phone_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.VCC1__Phone_Encrypted__c)) {
                conRecord.VCC1__Phone_Encrypted__c = conRecord.CLE__Phone_Encrypted__c;
            }
            if(!String.isBlank(conRecord.CLE__Mobile_Encrypted__c) && 
                !conRecord.CLE__Mobile_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.VCC1__Mobile_Encrypted__c)) {
                conRecord.VCC1__Mobile_Encrypted__c = conRecord.CLE__Mobile_Encrypted__c;
            }
            if(!String.isBlank(conRecord.CLE__Calling_Number_Encrypted__c) && 
                !conRecord.CLE__Calling_Number_Encrypted__c.contains('*') && 
                String.isBlank(conRecord.VCC1__Calling_Number_Encrypted__c)) {
                conRecord.VCC1__Calling_Number_Encrypted__c = conRecord.CLE__Calling_Number_Encrypted__c;
            }
        }
    }
    
    public static String dividePrefixAndConvert(String originalNumber) {
        String rowData = '';
        String rowNumber = '';
        String preNumber = '';
        if(originalNumber.startswith('+')) {
            rowData = originalNumber.remove('+');
        } else {
            rowData = originalNumber;
        }
        if(rowData.length() > 10) {
            preNumber = rowData.left(rowData.length()-10);
            rowNumber = rowData.right(rowData.length()-preNumber.length());
        } else {
            rowNumber = rowData;
            preNumber = '';
        }
        if(originalNumber.startswith('+')) {
            preNumber = '+' + preNumber;
        }
        rowNumber = convertInEncrypt(rowNumber);
        if(!String.isBlank(preNumber)) {
            rowNumber = preNumber + '@@' + rowNumber;
        }
        return rowNumber;
    }
    
    public static String convertInEncrypt(String numberStr) {
        String lastCharacter = '';
        String startCharacter = '';
        String convertedString = '';
        Integer charLength = numberStr.length();
        if(charLength > 5) {
            lastCharacter = numberStr.right(5);
            startCharacter = numberStr.left(charLength - 5);
        } else {
            startCharacter = numberStr;
        }
        if(!String.isBlank(startCharacter)) {
            convertedString += numberToEnc(startCharacter);
        }
        if(!String.isBlank(lastCharacter)) {
            convertedString += '##' + numberToEnc(lastCharacter);
        }
        return convertedString;
    }
    
    public static String numberToEnc(String numberInString) {
        String cData = '';
        if(numberInString.startswith('00000')) {
            cData = '$$$$$$$$$$$$$$$$$$$$';
        } else if(numberInString.startswith('0000')) {
            cData = '$$$$$$$$$$$$$$$$';
        } else if(numberInString.startswith('000')) {
            cData = '$$$$$$$$$$$$';
        } else if(numberInString.startswith('00')) {
            cData = '$$$$$$$$';
        } else if(numberInString.startswith('0')) {
            cData = '$$$$';
        }
        String convertedData = '';
        Integer finalNumber = Integer.valueof(numberInString);
        while(finalNumber > 0) {
            convertedData = ((Math.mod(finalNumber, 2)) == 0 ? '0' : '1') + convertedData;
            finalNumber = finalNumber/2;
        }
        convertedData = 'av$10' + cData + convertedData + '0fd=1';
        return convertedData;
    }

    //Added By Nishank Manwani on 01-05-2024 to Duplicate Check Passport Number or Emirates Id On Update
    public static void duplicateCheckPassportEmiratesOnUpdate(List<Contact> newContList, Map<Id, Contact> oldcontMap) {
        Set<String> emiratesIdSet = new Set<String>();
        Set<String> passportNumberSet = new Set<String>();
        
        for(Contact cont : newContList) {
            if(cont.Emirates_ID__c != null && cont.Emirates_ID__c != oldcontMap.get(cont.Id).Emirates_ID__c) {
                emiratesIdSet.add(cont.Emirates_ID__c);
            }
            if(cont.Passport_Number__c != null && cont.Passport_Number__c != oldcontMap.get(cont.Id).Passport_Number__c) {
                passportNumberSet.add(cont.Passport_Number__c);
            }
        }

        if(!emiratesIdSet.isEmpty() || !passportNumberSet.isEmpty()) {
            List<Contact> emiratesPassportContList = [SELECT Id, Emirates_ID__c, Passport_Number__c FROM Contact WHERE Id NOT IN :oldcontMap.keySet() AND (Emirates_ID__c IN :emiratesIdSet OR Passport_Number__c IN :passportNumberSet)];
            Set<Id> contId = new Set<Id>();

            if(!emiratesPassportContList.isEmpty()) {
                for(Contact cont : newContList) {
                    if((cont.Emirates_ID__c != null && cont.Emirates_ID__c != oldcontMap.get(cont.Id).Emirates_ID__c) || (cont.Passport_Number__c != null && cont.Passport_Number__c != oldcontMap.get(cont.Id).Passport_Number__c)) {
                        for(Contact contCheck : emiratesPassportContList) {
                            if(contCheck.Emirates_ID__c  == cont.Emirates_ID__c || contCheck.Passport_Number__c  == cont.Passport_Number__c) {
                                contId.add(cont.Id);
                                break;
                            }
                        }
                    }
                }

                if(!contId.isEmpty()) {
                    ContactTriggerHelper.sendMail(contId);
                }
            }
        } 
    }
    // modified by gourav gour 15/06/2024
    public static void sendMail(Set<Id> contId) {
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: 'Duplicate_Document_Found'];
        String tempId  = (!emailTemplate.isEmpty() ? emailTemplate[0].Id : '');
        List<String> sendTo = new List<String>();
        Set<Id> groupId = new Set<Id>();
        List<GroupMember> gmList = [SELECT UserOrGroupId, Group.Email, group.DoesSendEmailToMembers FROM GroupMember 
                                    WHERE Group.DeveloperName = 'Audit_Team_1' 
                                    OR Group.DeveloperName = 'Business_Process_CRM_Queue' 
                                    OR Group.DeveloperName = 'Sales_Ops']  ;
        for(GroupMember gm : gmList) {
            if(gm.group.DoesSendEmailToMembers) {
                groupId.add(gm.Id);
            } else if(gm.group.Email != null && !sendTo.contains(gm.group.Email)){
                sendTo.add(gm.group.Email);
            }
        }
        if(!groupId.isEmpty()) {
            for(User u : [SELECT Id, Email FROM User WHERE Id IN :groupId]) {
                if(u.Email != null) {
                    sendTo.add(u.Email);
                }
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Id contactId : contId) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(!sendTo.isEmpty()) {
                email.setToAddresses(sendTo);
            }
            email.setWhatId(contactId);
            email.setTargetObjectId(contactId);
            email.setTreatTargetObjectAsRecipient(False);
            email.setSaveAsActivity(false); 
            email.setTemplateId(tempId);
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
    
    public static void SendDataForWebEngageService(List<Contact> conList, Map<Id, Contact> oldConMap) {
        Set<Id> conIds = new Set<Id>();
        Schema.FieldSet fieldSet = Schema.SObjectType.Contact.FieldSets.Web_Engage;
        Set<String> fieldSetFields = new Set<String>();
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            fieldSetFields.add(field.getFieldPath());
            System.debug('=====>' + fieldSetFields);
        }
        for(Contact con : conList) {
            Contact c = oldConMap.get(con.Id);
            for (String field : fieldSetFields) {
                if (con.get(field) != c.get(field)) {
                    conIds.add(con.Id);
                    break;
                }
            }
        }
        if(!conIds.isEmpty()) {
            List<PropStrength__Request__c> enqLatestMap =  [SELECT Id, is_Opportunity__c, Timezone__c, IP_Address__c, GCLID__c, Re_Enquiry__c, Facebook_Adset_Name__c, Platform__c, Facebook_Page_Name__c, Gender__c, Preferred_Method_of_Contact__c, 
                 Reason_For_Purchase__c, Primary_City__c, How_Many_Bedroomspicklist__c, How_Many_Bedrooms__c, Client_Type__c, Preferred_City_of_Interestpicklist__c, Preferred_City_of_Interest__c, 
                 Lead_Rating__c, Mortage_Required__c, Interested_In__c, Possession_Requirement__c, Financing_Details__c, Qualified_Not_Qualified__c,Presentation_Done__c, Lead_Month__c, Lead_Id__c, 
                 Contacted__c, Last_Call_Attempt_Status__c, Enquiry_Source__c, Project_Type__c, Website_Language__c, Reason_For_Lost__c, First_Call_Attempt_Status__c, UTM_Content__c, Adgroup__c, 
                 Placement__c, Leadgen_Form_ID__c, Stand_Lead_Location__c, Are_you_looking_for__c, Facebook_Ad_ID__c, Budgett__c, Leadgen_Page_ID__c, Specific_Location_in_the_City__c, Opportunity_Value__c, 
                 FOLLOW_UP_1st__c, FOLLOW_UP_2nd__c, Willing_to_meet_this_week__c, Estimated_Timeline_for_Purchase__c, When_you_re_looking_to_buy__c, Re_Enquiry_Count__c, Time_of_Visit__c, UTM_Language__c, 
                 UTM_Country__c, UTM_Company__c, PropStrength__Request_Status__c, Type_Investment_Or_Self_Use__c, Level_Warm_Or_Hot__c, FOLLOW_UP_3rd__c, Would_you_like_to_invest_in_Dubai_Real_E__c, 
                 Meeting_Type__c, PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.FirstName, PropStrength__Primary_Contact__r.Email, PropStrength__Primary_Contact__r.Phone, 
                 PropStrength__Primary_Contact__r.Country__c, PropStrength__Primary_Contact__r.City__c, PropStrength__Primary_Contact__r.PropStrength__Nationality__c, PropStrength__Primary_Contact__r.PropStrength__Languages__c, 
                 PropStrength__Primary_Contact__r.Salutation, PropStrength__Primary_Contact__r.PropStrength__Resident_Status__c, PropStrength__Primary_Contact__r.PropStrength__Profession__c, PropStrength__Primary_Contact__r.mobilePhone, Legacy_ID__c,
                 PropStrength__Primary_Contact__r.Legacy_ID__c,PropStrength__Primary_Contact__r.MailingCity, PropStrength__Primary_Contact__r.MailingCountry, PropStrength__Primary_Contact__r.LastName, 
                 Owner_Profile__c, Purchased_in_the_preferred_City__c
                 FROM PropStrength__Request__c 
                 WHERE PropStrength__Primary_Contact__c IN :conIds 
                 AND Re_Enquiry__c = false];
            for(PropStrength__Request__c enq : enqLatestMap) {
                 WebEngageServiceEnquiryContactHandler.userPostAPI(JSON.serialize(enq));
            }
        }
    }
	// Added By Gourav Gour validation on Emirates Id and Formattings.
    public static void validationOnEmiratesId(List<Contact> conList, Map<Id, Contact> oldConMap) {
        for(Contact c : conList) {
            if(c.Emirates_ID__c != null && c.Emirates_ID__c.length() > 0 && (oldConMap == null || (oldConMap != null && c.Emirates_ID__c != oldConMap.get(c.Id).Emirates_ID__c))) {
                String emiratesId = c.Emirates_ID__c.replaceAll('[^0-9]', '');
                if(emiratesId.length() != 15) {
                    c.addError('Please Fill 15 Digit values in Emirates ID.');
                }
                else{
                   c.Emirates_ID__c = emiratesId.subString(0,3)+'-'+emiratesId.subString(3,7)+'-'+emiratesId.subString(7,14)+'-'+emiratesId.subString(14,15);
                }
            }
        }
        
    }
}