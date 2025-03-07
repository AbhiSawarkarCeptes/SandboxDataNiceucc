public without sharing class StandLeadTriggerHelper {
    public static void createEnquiry(List<Stand_Lead__c> standList, Map<Id, Stand_Lead__c> oldStandMap) {
        List<Stand_Lead__c> standListToProcess = new List<Stand_Lead__c>();
        if(oldStandMap == null) {
            standListToProcess.addAll(standList);
        }
        else {
            for(Stand_Lead__c sm : standList) {
                if(sm.Re_Process__c && !oldStandMap.get(sm.Id).Re_Process__c && sm.Enquiry__c == null) {
                    standListToProcess.add(sm);
                }
            }
        }
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        
        Set<String> emailsV2 = new Set<String>();
        Set<String> phonesV2 = new Set<String>();
        Set<String> projectName = new Set<String>();
        for(Stand_Lead__c sml : standListToProcess) {
            if(sml.Email__c != null) {
                emails.add(sml.Email__c);
            }
            if(sml.Contact_Number__c != null) {
                phones.add(StandLeadTriggerHelper.dividePrefixAndConvert(sml.Contact_Number__c));
            }
            if(sml.Interested_Project__c != null) {
                projectName.add(sml.Interested_Project__c);
            }
        }
        Map<String, Id> projectIdMap = new Map<String, Id>();
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Contact> conLists = [SELECT Id,LastName, FirstName, VCC1__Phone_Encrypted_Data__c, VCC1__Phone_Encrypted__c,RecordTypeId, owner.isActive, ownerID,
                                        VCC1__Mobile_Encrypted__c, VCC1__Mobile_Encrypted_Data__c, VCC1__Calling_Number_Encrypted__c, VCC1__Calling_Number_Encrypted_Data__c,
                                        VCC1__Email_Encrypted__c, VCC1__Email_Encrypt__c
                                        FROM Contact 
                                        WHERE VCC1__Email_Encrypted__c IN :emails 
                                        OR VCC1__Mobile_Encrypted_Data__c IN :phones
                                        OR VCC1__Calling_Number_Encrypted_Data__c IN :phones
                                        OR VCC1__Phone_Encrypted_Data__c IN :phones];
        List<PropStrength__Request__c> transReqToInsert = new List<PropStrength__Request__c>(); 
        List<PropStrength__Projects__c> projId = [SELECT Id, Name FROM PropStrength__Projects__c WHERE Name IN :projectName];
        for(PropStrength__Projects__c prj : projId) {
            projectIdMap.put(prj.Name, prj.Id);
        }
        Map<Id, Contact> contactToUpdate = new Map<Id, Contact>();
        if(conLists.size() > 0) {
            for(Contact c : conLists) {
                for(Stand_Lead__c sml : standListToProcess) {
                    String mobileNo = '';
                    if(sml.Contact_Number__c != null && sml.Contact_Number__c != '') {
                        mobileNo = StandLeadTriggerHelper.dividePrefixAndConvert(sml.Contact_Number__c);
                    }
                    if((sml.Email__c == c.VCC1__Email_Encrypted__c) || (mobileNo != '' && (mobileNo == c.VCC1__Phone_Encrypted_Data__c || mobileNo == c.VCC1__Mobile_Encrypted_Data__c || mobileNo == c.VCC1__Calling_Number_Encrypted_Data__c))) {
                        PropStrength__Request__c enqCreated = new PropStrength__Request__c();
                        enqCreated.PropStrength__Primary_Contact__c = c.Id;
                        enqCreated.PropStrength__Country__c = sml.Country__c;
                        enqCreated.RDS_Country__c = sml.Country__c; 
                        if(!String.isBlank(sml.Mobile_Country_Code__c)) {
                            enqCreated.RDS_Country_Code__c = sml.Mobile_Country_Code__c.startsWith('+') ? sml.Mobile_Country_Code__c : '+' + sml.Mobile_Country_Code__c;
                        }
                        enqCreated.PropStrength__Request_Source__c = 'Stand Leads';
                        enqCreated.PropStrength__Enquiry_Type__c = 'Direct';
                        enqCreated.Promoters__c = sml.Promoter__c;
                        enqCreated.Stand_Lead_Location__c = sml.Stand_Location__c;
                        enqCreated.PropStrength__Request_Status__c = 'Open';
                        enqCreated.PropStrength__Enquiry_Subject__c = 'New Enquiry Received from: Stand Leads';
                        enqCreated.Task_Type__c = 'Enquiry Received';
                        enqCreated.Website_Language__c = sml.Language__c;
                        enqCreated.Prefered_LAnguage__c = sml.Language__c;
                        enqCreated.PropStrength__First_Name__c = sml.FirstName__c;
                        enqCreated.PropStrength__Last_Name__c = sml.Last_Name__c;
                        enqCreated.Willing_to_meet_this_week__c = sml.Willing_to_meet_this_week__c;
                        if(enqCreated.Willing_to_meet_this_week__c == 'Yes') {
                            enqCreated.Accompanied_By__c = sml.Accompanied_By__c;
                            enqCreated.Meeting_Type__c = sml.Meeting_Type__c;
                            enqCreated.ownerId = c.owner.isActive? c.ownerId:UserInfo.getUserId() ;
                        }
                        else if(enqCreated.Willing_to_meet_this_week__c == 'Later') {
                            enqCreated.Tour_Date_Time__c = sml.Tour_Date_Time__c;
                            enqCreated.ownerId = c.owner.isActive? c.ownerId:UserInfo.getUserId() ;
                        }
                        else if(enqCreated.Willing_to_meet_this_week__c == 'Assign RM on Stand') {
                            enqCreated.Sales_Manager__c = sml.Sales_manager__c;
                            enqCreated.PropStrength__Request_Status__c = 'Qualified';
                            enqCreated.ownerId = sml.Sales_manager__c;
                        }


                        
                        
                        // enqCreated.Resident_Type__c = sml.Resident_Type__c;
                        // enqCreated.RDS_Country__c = sml.Country__c; 
                        // enqCreated.PropStrength__City__c = sml.City__c; 
                        // enqCreated.Nationality__c = sml.Nationality__c; 
                        // enqCreated.Website_Language__c = sml.Language__c;
                        // enqCreated.Profession__c = sml.Profession__c;
                        // enqCreated.Preferred_City_of_Interestpicklist__c = sml.Preferred_City_of_Interest__c;
                        // enqCreated.Specific_Location_in_the_City__c = sml.Specific_Location_in_the_City__c;
                        // enqCreated.Purchased_in_the_preferred_City__c = sml.Purchased_in_the_preferred_City__c;
                        // enqCreated.Property_Type__c = sml.Property_Type__c;
                        // enqCreated.Preferred_Property_Status__c = sml.Preferred_Property_Status__c;
                        // enqCreated.Gender__c = sml.Gender__c;
                        // enqCreated.Age__c = sml.Age__c;
                        // enqCreated.Expected_Level_of_Usage__c = sml.Expected_Level_of_Usage__c;
                        // enqCreated.Mortage_Required__c = sml.Mortage_Required__c;
                        // enqCreated.How_Many_Bedroomspicklist__c = sml.How_Many_Bedrooms__c;
                        // enqCreated.Tour_Date_Time__c = sml.Tour_Date_Time__c;
                        // enqCreated.Willing_to_meet_this_week__c = sml.Willing_to_meet_this_week__c;
                        // enqCreated.Accompanied_By__c = sml.Accompanied_By__c;
                        // enqCreated.Meeting_Type__c = sml.Meeting_Type__c;
                        // enqCreated.Current_Residence_Type__c = sml.Rent_Current_Residence__c;
                        // enqCreated.promotors_remarks__c = sml.promotors_remarks__c;
                        // enqCreated.PropStrength__Request_Source__c = 'Stand Leads';
                        // enqCreated.Promoters__c = sml.Promoter__c;
                        // enqCreated.Stand_Lead_Location__c = sml.Stand_Location__c;
                        // enqCreated.Purchased_in_the_preferred_City__c = sml.Purchased_in_the_preferred_City__c;
                        // enqCreated.Sales_Manager__c = sml.Sales_manager__c;
                        // enqCreated.Prefered_LAnguage__c = sml.Language__c;
                        // enqCreated.RDS_Budget__c = sml.Budget__c;
                        enqCreated.PropStrength__Project__c = projectIdMap.containsKey(sml.Interested_Project__c) ? projectIdMap.get(sml.Interested_Project__c) : null;
                        transReqToInsert.add(enqCreated);
                    }
                    emails.remove(c.VCC1__Email_Encrypted__c);
                    phones.remove(c.VCC1__Phone_Encrypted_Data__c);
                    phones.remove(c.VCC1__Mobile_Encrypted_Data__c);
                    phones.remove(c.VCC1__Calling_Number_Encrypted_Data__c);
                    
                    emailsV2.add(c.VCC1__Email_Encrypted__c);
                    phonesV2.add(c.VCC1__Phone_Encrypted_Data__c);
                    phonesV2.add(c.VCC1__Mobile_Encrypted_Data__c);
                    phonesV2.add(c.VCC1__Calling_Number_Encrypted_Data__c);

                    if(sml.Email__c == c.VCC1__Email_Encrypted__c) {
                        if(!contactToUpdate.containsKey(c.Id)) {
                            contactToUpdate.put(c.Id, c);
                        }
                        Contact con = contactToUpdate.get(c.Id);
                        if(con.VCC1__Mobile_Encrypted__c == null ||  con.VCC1__Mobile_Encrypted__c == '') {
                            if(mobileNo != '' && mobileNo != con.VCC1__Phone_Encrypted_Data__c && mobileNo != con.VCC1__Calling_Number_Encrypted_Data__c) {
                                con.VCC1__Mobile_Encrypted__c = sml.Contact_Number__c;
                                con.MobilePhone = sml.Contact_Number__c;
                                con.Phone = sml.Contact_Number__c;
                                contactToUpdate.put(c.Id, con);
                            }      
                        }
                        else if(con.VCC1__Phone_Encrypted__c == null || con.VCC1__Phone_Encrypted__c == '') {
                            if(mobileNo != '' && mobileNo != con.VCC1__Mobile_Encrypted_Data__c && mobileNo != con.VCC1__Calling_Number_Encrypted_Data__c) {
                                con.VCC1__Phone_Encrypted__c = sml.Contact_Number__c;
                                con.MobilePhone = sml.Contact_Number__c;
                                con.Phone = sml.Contact_Number__c;
                                contactToUpdate.put(c.Id, con);
                            }               
                        }
                        else if(con.VCC1__Calling_Number_Encrypted__c == null || con.VCC1__Calling_Number_Encrypted__c == '') {
                            if(mobileNo != '' && mobileNo != con.VCC1__Phone_Encrypted_Data__c && mobileNo != con.VCC1__Mobile_Encrypted_Data__c) {
                                con.VCC1__Calling_Number_Encrypted__c = sml.Contact_Number__c;
                                con.MobilePhone = sml.Contact_Number__c;
                                con.Phone = sml.Contact_Number__c;
                                contactToUpdate.put(c.Id, con);
                            }     
                        }
                    }
                }
            }
        }
        if(!contactToUpdate.values().isEmpty()) {
            update contactToUpdate.values();
        }
        Map<String, PropStrength__Request__c> emailToRequestMap = new Map<String, PropStrength__Request__c>();
        List<Contact> conList = new List<Contact>();
        for(Stand_Lead__c sml : standListToProcess) {
            String phoneNo = '';
            if(sml.Contact_Number__c != null && sml.Contact_Number__c != '') {
                phoneNo = StandLeadTriggerHelper.dividePrefixAndConvert(sml.Contact_Number__c);
            } 
            if(!emailsV2.contains(sml.Email__c) && !phonesV2.contains(phoneNo)) {
                Contact con = new Contact();
                con.FirstName = sml.FirstName__c;
                con.LastName = sml.Last_Name__c;
                con.RecordTypeId = RecordTypeIdContact;
                con.Country__c = sml.Country__c;
                con.City__c = sml.City__c;
                con.PropStrength__Languages__c = sml.Language__c;
                con.VCC1__Languages__c = sml.Language__c;
                con.VCC1__Email_Encrypt__c = sml.Email__c;
                con.Email = sml.Email__c;
                con.VCC1__Mobile_Encrypted__c = sml.Contact_Number__c;
                con.MobilePhone = sml.Contact_Number__c;
                con.Phone = sml.Contact_Number__c;
                if(!String.isBlank(sml.Mobile_Country_Code__c)) {
                    con.VCC1__Country_ISO_Code__c = sml.Mobile_Country_Code__c.startsWith('+') ? sml.Mobile_Country_Code__c : '+' + sml.Mobile_Country_Code__c;
                }
                con.PropStrength__Nationality__c = sml.Nationality__c;
                con.VCC1__Email_Encrypted__c = sml.Email__c;
                con.PropStrength__Profession__c = sml.Profession__c;
                con.Country_Code__c = sml.Mobile_Country_Code__c;
                con.PropStrength__Age__c = sml.Age__c;
                con.Current_Residence_Type__c = sml.Rent_Current_Residence__c;
                conList.add(con);

                PropStrength__Request__c enqCreated = new PropStrength__Request__c();
                enqCreated.PropStrength__Country__c = sml.Country__c;
                enqCreated.PropStrength__City__c = sml.City__c; 
                enqCreated.Date_and_Time_of_Unserviced_Lead__c = System.now(); 
                enqCreated.Expected_Level_of_Usage__c = sml.Expected_Level_of_Usage__c;
                enqCreated.PropStrength__First_Name__c = sml.FirstName__c;
                enqCreated.PropStrength__Last_Name__c = sml.Last_Name__c;
                enqCreated.Gender__c = sml.Gender__c;
                enqCreated.How_Many_Bedroomspicklist__c = sml.How_Many_Bedrooms__c;
                enqCreated.Prefered_LAnguage__c = sml.Language__c;
                enqCreated.PropStrength__Request_Status__c = 'Open';
                enqCreated.Last_Call_Attempt_Status__c = 'Not Actioned';
                enqCreated.PropStrength__Request_Source__c = 'Stand Leads';
                enqCreated.PropStrength__Enquiry_Type__c = 'Direct';
                enqCreated.Nationality__c = sml.Nationality__c; 
                enqCreated.Preferred_City_of_Interestpicklist__c = sml.Preferred_City_of_Interest__c;
                enqCreated.Preferred_Property_Status__c = sml.Preferred_Property_Status__c;
                enqCreated.Profession__c = sml.Profession__c;
                enqCreated.PropStrength__Project__c = projectIdMap.containsKey(sml.Interested_Project__c) ? projectIdMap.get(sml.Interested_Project__c) : null;
                enqCreated.promotors_remarks__c = sml.promotors_remarks__c;
                enqCreated.Property_Type__c = sml.Property_Type__c;
                enqCreated.Purchased_in_the_preferred_City__c = sml.Purchased_in_the_preferred_City__c;
                enqCreated.RDS_Country__c = sml.Country__c; 
                if(!String.isBlank(sml.Mobile_Country_Code__c)) {
                    enqCreated.RDS_Country_Code__c = sml.Mobile_Country_Code__c.startsWith('+') ? sml.Mobile_Country_Code__c : '+' + sml.Mobile_Country_Code__c;
                }
                enqCreated.Willing_to_meet_this_week__c = sml.Willing_to_meet_this_week__c;
                if(enqCreated.Willing_to_meet_this_week__c == 'Yes') {
                    enqCreated.Accompanied_By__c = sml.Accompanied_By__c;
                    enqCreated.Meeting_Type__c = sml.Meeting_Type__c;
                }
                else if(enqCreated.Willing_to_meet_this_week__c == 'Later') {
                    enqCreated.Tour_Date_Time__c = sml.Tour_Date_Time__c;
                }
                else if(enqCreated.Willing_to_meet_this_week__c == 'Assign RM on Stand') {
                    enqCreated.Sales_Manager__c = sml.Sales_manager__c;
                    enqCreated.PropStrength__Request_Status__c = 'Qualified';
                    enqCreated.ownerId = sml.Sales_manager__c;
                }
                enqCreated.Resident_Type__c = sml.Resident_Type__c;
                enqCreated.Specific_Location_in_the_City__c = sml.Specific_Location_in_the_City__c;
                enqCreated.Promoters__c = sml.Promoter__c;
                enqCreated.Website_Language__c = sml.Language__c;
                enqCreated.Mortage_Required__c = sml.Mortage_Required__c;
                enqCreated.Stand_Lead_Location__c = sml.Stand_Location__c;


                // enqCreated.Age__c = sml.Age__c;
                // enqCreated.RDS_Budget__c = sml.Budget__c;
                // enqCreated.Current_Residence_Type__c = sml.Rent_Current_Residence__c;
                
                emailToRequestMap.put(con.VCC1__Email_Encrypted__c, enqCreated);
            }
        }

        if(!conList.isEmpty()) {
            insert conList;
        }
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id, VCC1__Email_Encrypted__c, Owner.isActive, ownerID FROM Contact WHERE Id IN :conList OR Id IN :conLists]);
        for(Contact con : conList) {
            PropStrength__Request__c transReq = emailToRequestMap.get(con.VCC1__Email_Encrypted__c);
            transReq.ownerId = con.owner.isActive?con.ownerId:UserInfo.getUserId();
            transReq.PropStrength__Primary_Contact__c = con.Id;
            transReqToInsert.add(transReq);
        }

        try{
            if(!transReqToInsert.isEmpty()) {
                insert transReqToInsert;
            }
            for(PropStrength__Request__c rec : transReqToInsert) {
                for(Stand_Lead__c sm : standListToProcess) {
                    if(sm.Email__c == conMap.get(rec.PropStrength__Primary_Contact__c).VCC1__Email_Encrypted__c) {
                        sm.Enquiry__c = rec.Id;
                        sm.Processed__c = true;
                        sm.Lead_Creation_status__c = 'Success';
                    }
                }
            }
        }catch (System.DmlException ex) {
            String msg = null;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                msg = 'Lead Insert Failed :' + ex.getMessage();
            }
            System.debug('Error:' + msg);
            for(Stand_Lead__c sm : standListToProcess) {
                sm.Processed__c = true;
                sm.Lead_Creation_status__c = 'Error';
                sm.Lead_Creation_Error_Log__c = msg;
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
        rowNumber = convertInBinary(rowNumber);
        if(!String.isBlank(preNumber)) {
            rowNumber = preNumber + '@@' + rowNumber;
        }
        return rowNumber;
    }
    public static String convertInBinary(String numberStr) {
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
            convertedString += numberToBinary(startCharacter);
        }
        if(!String.isBlank(lastCharacter)) {
            convertedString += '##' + numberToBinary(lastCharacter);
        }
        return convertedString;
    }
    public static String numberToBinary(String numberInString) {
        Integer finalNumber = Integer.valueof(numberInString);
        String convertedData = '';
        while(finalNumber > 0) {
            convertedData = ((Math.mod(finalNumber, 2)) == 0 ? '0' : '1') + convertedData;
            finalNumber = finalNumber/2;
        }
        convertedData = 'av$10' + convertedData + '0fd=1';
        return convertedData;
    }

}