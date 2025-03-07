public class CustomerDetailTriggerHelper {
    public static void concateFieldsToFirstChild(List<PropStrength__Customer_Detail__c> newList) {        
        Map<String,List<PropStrength__Customer_Detail__c>> mapOFContainsFirstChild = new Map<String,List<PropStrength__Customer_Detail__c>>();
        Map<String,List<PropStrength__Customer_Detail__c>> mapOFWithoutFirstChild = new Map<String,List<PropStrength__Customer_Detail__c>>();
        Map<String,PropStrength__Customer_Detail__c> mapOFTRRec = new Map<String,PropStrength__Customer_Detail__c>();
        List<PropStrength__Customer_Detail__c> queryList = [SELECT id,PropStrength__Contact__r.Email,PropStrength__Contact__r.name,PropStrength__Contact__r.phone,PropStrength__Transaction_Request__c,Formatted_Buyer_Nationality_Docgen__c,Formatted_Buyer_Passport_For_Docgen__c,Formatted_Buyer_Address_For_Docgen__c,Formatted_Buyer_Phone_For_Docgen__c,Formatted_Buyer_Name_For_Docgen__c,Formatted_Buyer_Email_For_Docgen__c,
                     PropStrength__Contact__r.MailingAddress,PropStrength__Contact__r.Passport_No__c,Nationality__c,PropStrength__Type__c  from PropStrength__Customer_Detail__c Where Id IN : newList];
        for(PropStrength__Customer_Detail__c cusDet : queryList){
            if(cusDet.PropStrength__Type__c == '1st Applicant'){
                mapOFTRRec.put(cusDet.PropStrength__Transaction_Request__c,cusDet);
            }
        }
        System.debug('mapOFTRRec*----'+mapOFTRRec);
        for(PropStrength__Customer_Detail__c cusDet : queryList){
            if(mapOFTRRec.containskey(cusDet.PropStrength__Transaction_Request__c)){                
                if(mapOFContainsFirstChild.containskey(cusDet.PropStrength__Transaction_Request__c)){
                    mapOFContainsFirstChild.get(cusDet.PropStrength__Transaction_Request__c).add(cusDet);
                }
                else{
                    mapOFContainsFirstChild.put(cusDet.PropStrength__Transaction_Request__c, new List<PropStrength__Customer_Detail__c>{cusDet});
                }
            }
            else{
                if(mapOFWithoutFirstChild.containskey(cusDet.PropStrength__Transaction_Request__c)){
                    mapOFWithoutFirstChild.get(cusDet.PropStrength__Transaction_Request__c).add(cusDet);
                }
                else{
                    mapOFWithoutFirstChild.put(cusDet.PropStrength__Transaction_Request__c, new List<PropStrength__Customer_Detail__c>{cusDet});
                }
            }
        }     
        System.debug('mapOFContainsFirstChild*----'+mapOFContainsFirstChild);
        System.debug('mapOFWithoutFirstChild*----'+mapOFWithoutFirstChild);   
        List<PropStrength__Customer_Detail__c> listOfCustRec = [SELECT id,PropStrength__Contact__r.Email,PropStrength__Contact__r.name,PropStrength__Contact__r.phone,PropStrength__Transaction_Request__c,Formatted_Buyer_Nationality_Docgen__c,Formatted_Buyer_Passport_For_Docgen__c,Formatted_Buyer_Address_For_Docgen__c,Formatted_Buyer_Phone_For_Docgen__c,Formatted_Buyer_Name_For_Docgen__c,Formatted_Buyer_Email_For_Docgen__c,
        PropStrength__Contact__r.MailingAddress,PropStrength__Contact__r.Passport_No__c,Nationality__c from PropStrength__Customer_Detail__c  WHERE PropStrength__Transaction_Request__c IN: mapOFWithoutFirstChild.keySet() 
                                                                AND PropStrength__Type__c = '1st Applicant'];
        Map<String,PropStrength__Customer_Detail__c> mapOFTrAndCustRec = new Map<String,PropStrength__Customer_Detail__c>();
        for(PropStrength__Customer_Detail__c custRec : listOfCustRec){
            mapOFTrAndCustRec.put(custRec.PropStrength__Transaction_Request__c,custRec);
        }
        List<PropStrength__Customer_Detail__c> updateRec = new List<PropStrength__Customer_Detail__c>();
        for(String trRec : mapOFContainsFirstChild.keyset()){
            PropStrength__Customer_Detail__c cdRec = new PropStrength__Customer_Detail__c();
            String notionalityFieldCombo = '';
            String nameFieldCombo = '';
            String emailFieldCombo = '';
            String phoneFieldCombo = '';
            String addressFieldCombo = '';
            String passportFieldCombo = '';
            for(PropStrength__Customer_Detail__c custRec : mapOFContainsFirstChild.get(trRec)){
                if(custRec.PropStrength__Type__c != '1st Applicant'){
                        notionalityFieldCombo += notionalityFieldCombo == '' ? custRec.Nationality__c : ' & ' + custRec.Nationality__c;
                        nameFieldCombo += nameFieldCombo == '' ? custRec.PropStrength__Contact__r.name : ' & ' + custRec.PropStrength__Contact__r.name;  
                        emailFieldCombo += emailFieldCombo == '' ? custRec.PropStrength__Contact__r.Email : ' & ' + custRec.PropStrength__Contact__r.Email;  
                        phoneFieldCombo += phoneFieldCombo == '' ? custRec.PropStrength__Contact__r.phone : ' & ' + custRec.PropStrength__Contact__r.phone;  
                      //  addressFieldCombo += addressFieldCombo == '' ? addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode() : ' & ' + addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();  
                        passportFieldCombo += passportFieldCombo == '' ? custRec.PropStrength__Contact__r.Passport_No__c : ' & ' + custRec.PropStrength__Contact__r.Passport_No__c;
                        Address addr = custRec.PropStrength__Contact__r.MailingAddress;
                        if(addr != null){
                            if(addressFieldCombo == '')
                                addressFieldCombo += addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();
                            else
                                addressFieldCombo += ' & ' + addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode(); 
                        }
                                                               
                }                
            }
            System.debug(cdRec.Formatted_Buyer_Address_For_Docgen__c+'--nameFieldCombo**--'+addressFieldCombo);
            System.debug(mapOFTRRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c+'--nameFieldCombo**--'+nameFieldCombo);
            if(mapOFTRRec.containskey(trRec)){
                cdRec.id = mapOFTRRec.get(trRec).Id;                
                cdRec.Formatted_Buyer_Nationality_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Nationality_Docgen__c == null ? (notionalityFieldCombo == '' ? mapOFTRRec.get(trRec).Nationality__c : mapOFTRRec.get(trRec).Nationality__c + ' & ' + notionalityFieldCombo ) : mapOFTRRec.get(trRec).Formatted_Buyer_Nationality_Docgen__c + ' & ' + notionalityFieldCombo; 
                cdRec.Formatted_Buyer_Name_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c == null ? (nameFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.name : mapOFTRRec.get(trRec).PropStrength__Contact__r.name + ' & ' + nameFieldCombo ) : mapOFTRRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c + ' & ' + nameFieldCombo;
                cdRec.Formatted_Buyer_Email_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Email_For_Docgen__c == null ? (emailFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.Email : mapOFTRRec.get(trRec).PropStrength__Contact__r.Email + ' & ' + emailFieldCombo)  : mapOFTRRec.get(trRec).Formatted_Buyer_Email_For_Docgen__c + ' & ' + emailFieldCombo;
                cdRec.Formatted_Buyer_Phone_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Phone_For_Docgen__c == null ? (phoneFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.phone  : mapOFTRRec.get(trRec).PropStrength__Contact__r.phone + ' & ' + phoneFieldCombo) : mapOFTRRec.get(trRec).Formatted_Buyer_Phone_For_Docgen__c + ' & ' + phoneFieldCombo;
               // cdRec.Formatted_Buyer_Address_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c == null ? (addressFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.MailingAddress : mapOFTRRec.get(trRec).PropStrength__Contact__r.MailingAddress + ' & ' + addressFieldCombo) : mapOFTRRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c + ' & ' + addressFieldCombo;
                cdRec.Formatted_Buyer_Passport_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Buyer_Passport_For_Docgen__c == null ? (passportFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.Passport_No__c : mapOFTRRec.get(trRec).PropStrength__Contact__r.Passport_No__c + ' & ' + passportFieldCombo)  : mapOFTRRec.get(trRec).Formatted_Buyer_Passport_For_Docgen__c + ' & ' + passportFieldCombo;
                if(mapOFTRRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c == null){
                    Address addr = mapOFTRRec.get(trRec).PropStrength__Contact__r.MailingAddress;
                    if(addr != null) {
                        if(addressFieldCombo == '')
                            cdRec.Formatted_Buyer_Address_For_Docgen__c = addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();
                        else {
                            cdRec.Formatted_Buyer_Address_For_Docgen__c = addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode() + ' & ' + addressFieldCombo;
                        }
                    }
                }
                else{
                    cdRec.Formatted_Buyer_Address_For_Docgen__c +=  ' & ' + addressFieldCombo;
                }
                                      
                System.debug('trRec*-----'+cdRec);
                updateRec.add(cdRec);
            }
        }
        for(String trRec : mapOFWithoutFirstChild.keyset()){
            String notionalityFieldCombo = '';
            String nameFieldCombo = '';
            String emailFieldCombo = '';
            String phoneFieldCombo = '';
            String addressFieldCombo = '';
            String passportFieldCombo = '';
            for(PropStrength__Customer_Detail__c custRec : mapOFWithoutFirstChild.get(trRec)){
                notionalityFieldCombo += notionalityFieldCombo == '' ? custRec.Nationality__c : ' & ' + custRec.Nationality__c;
                nameFieldCombo += nameFieldCombo == '' ? custRec.PropStrength__Contact__r.name : ' & ' + custRec.PropStrength__Contact__r.name;  
                emailFieldCombo += emailFieldCombo == '' ? custRec.PropStrength__Contact__r.Email : ' & ' + custRec.PropStrength__Contact__r.Email;  
                phoneFieldCombo += phoneFieldCombo == '' ? custRec.PropStrength__Contact__r.phone : ' & ' + custRec.PropStrength__Contact__r.phone;  
              //  addressFieldCombo += addressFieldCombo == '' ? addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode() : ' & ' + addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();  
                passportFieldCombo += passportFieldCombo == '' ? custRec.PropStrength__Contact__r.Passport_No__c : ' & ' + custRec.PropStrength__Contact__r.Passport_No__c; 
                Address addr = custRec.PropStrength__Contact__r.MailingAddress;
                if(addr != null){
                    if(addressFieldCombo == '')
                        addressFieldCombo += addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();
                    else
                        addressFieldCombo += ' & ' + addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode(); 
                }                                          
            }
            System.debug( mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c+'--nameFieldCombo**--'+addressFieldCombo);
            System.debug(mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c+'--nameFieldCombo**--'+nameFieldCombo);
            mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Nationality_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Nationality_Docgen__c == null ? (notionalityFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).Nationality__c : mapOFTrAndCustRec.get(trRec).Nationality__c + ' & ' + notionalityFieldCombo )  : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Nationality_Docgen__c + ' & ' + notionalityFieldCombo;
            mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c == null ? (nameFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.name : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.name + ' & ' + nameFieldCombo )  : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Name_For_Docgen__c + ' & ' + nameFieldCombo;
            mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Email_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Email_For_Docgen__c == null ? (emailFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Email : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Email + ' & ' + emailFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Email_For_Docgen__c + ' & ' + emailFieldCombo;
            mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Phone_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Phone_For_Docgen__c == null ? (phoneFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.phone : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.phone + ' & ' + phoneFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Phone_For_Docgen__c + ' & ' + phoneFieldCombo;
            // mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c == null ? (addressFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.MailingAddress : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.MailingAddress + ' & ' + addressFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c + ' & ' + addressFieldCombo;
            mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Passport_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Passport_For_Docgen__c == null ? (passportFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Passport_No__c : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Passport_No__c + ' & ' + passportFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Passport_For_Docgen__c + ' & ' + passportFieldCombo;
            if(mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c == null){   
                Address addr = mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.MailingAddress;  
                if(addressFieldCombo == '')           
                    mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c = addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode();   
                else {
                    mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c = addr.getStreet()+',' + addr.getCity()+',' + addr.getState()+',' + addr.getCountry()+',' + addr.getPostalCode() + ' & ' + addressFieldCombo;
                }         
               
            System.debug('trRec*-----'+trRec);
            }
            else {
                mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Buyer_Address_For_Docgen__c + ' & ' + addressFieldCombo;
            }
            updateRec.add(mapOFTrAndCustRec.get(trRec));
        }

        System.debug('updateRec*-----'+updateRec);
        if(updateRec.size() > 0){
            update updateRec;
        }
    }

    //Added by Nishank Manwani on 16-05-2024 to create task on Transaction request
    public static void createTaskOnTr(List<PropStrength__Customer_Detail__c> crDetList) {
        Set<Id> trId = new Set<Id>();

        for(PropStrength__Customer_Detail__c cd : crDetList) {
            if(cd.PropStrength__Transaction_Request__c != null) {
                trId.add(cd.PropStrength__Transaction_Request__c);
            }
        }

        if(!trId.isEmpty()) {
            List<Task> createTaskList = new List<Task>();
            Map<Id, PropStrength__Transaction_Requests__c> trMap = new Map<Id, PropStrength__Transaction_Requests__c>([SELECT Id 
                                                                    , PropStrength__Application_Booking__r.CRM_Executive__c 
                                                                    FROM PropStrength__Transaction_Requests__c WHERE RecordType.Name = 'Addition / Deletion of Name']);
            
            if(!trMap.isEmpty()) {
                for(Id tId : trId) {
                    Task taskRec = new Task();
                    taskRec.Subject = 'Collect Name Addition/ Deletion Fees';
                    taskRec.Description = 'Collect Name Addition/ Deletion Fees';
                    taskRec.WhatId = tId;
                    taskRec.ActivityDate = Date.today().addDays(1);
                    if(trMap.containskey(tId) && trMap.get(tId).PropStrength__Application_Booking__r != null && trMap.get(tId).PropStrength__Application_Booking__r.CRM_Executive__c != null)
                        taskRec.OwnerId = trMap.get(tId).PropStrength__Application_Booking__r.CRM_Executive__c;
                    createTaskList.add(taskRec);
                }

                if(!createTaskList.isEmpty()) {
                    // insert createTaskList;   // commented for Gourav Gour 09/06/2024
                }
            }
        }
    }
}