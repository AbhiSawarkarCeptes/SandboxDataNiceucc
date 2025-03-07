public class applicantTriggerHelper {
    
    public static void updateFirstApplicantFields(List<PropStrength__Applicant_Detail__c> newList) { 
        Map<String,List<PropStrength__Applicant_Detail__c>> mapOFContainsFirstChild = new Map<String,List<PropStrength__Applicant_Detail__c>>();
        Map<String,List<PropStrength__Applicant_Detail__c>> mapOFWithoutFirstChild = new Map<String,List<PropStrength__Applicant_Detail__c>>();
        Map<String,PropStrength__Applicant_Detail__c> mapOFTRRec = new Map<String,PropStrength__Applicant_Detail__c>();
        List<PropStrength__Applicant_Detail__c> queryList = [SELECT id,Nationality__c, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c,
                                                             PropStrength__Applicant_Mobile__c, PropStrength__Applicant_Address__c, Passport_No_Doc__c, 
                                                             Formatted_Applicant_Nationality_Docgen__c, Formatted_Applicant_Name_For_Docgen__c,PropStrength__Application__c ,                                                         
                                                             PropStrength__Contact__r.MailingAddress,PropStrength__Contact__r.Passport_No__c, Formatted_Applicant_Email_For_Docgen__c,
                                                             Formatted_Applicant_Phone_For_Docgen__c, Formatted_Applicant_Address_For_Docgen__c, Formatted_Applicant_Passport_For_Docgen__c,
                                                             PropStrength__Type__c  from PropStrength__Applicant_Detail__c 
                                                             Where Id IN : newList];
        for(PropStrength__Applicant_Detail__c cusDet : queryList){
            if(cusDet.PropStrength__Type__c == '1st Applicant'){
                cusDet.Nationality__c = cusDet.Nationality__c ?? ' ';                
                mapOFTRRec.put(cusDet.PropStrength__Application__c,cusDet);
            }
        }
        System.debug('mapOFTRRec*----'+mapOFTRRec);
        for(PropStrength__Applicant_Detail__c cusDet : queryList){
            if(mapOFTRRec.containskey(cusDet.PropStrength__Application__c)){                
                if(mapOFContainsFirstChild.containskey(cusDet.PropStrength__Application__c)){
                    mapOFContainsFirstChild.get(cusDet.PropStrength__Application__c).add(cusDet);
                }
                else{
                    mapOFContainsFirstChild.put(cusDet.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{cusDet});
                }
            }
            else{
                if(mapOFWithoutFirstChild.containskey(cusDet.PropStrength__Application__c)){
                    mapOFWithoutFirstChild.get(cusDet.PropStrength__Application__c).add(cusDet);
                }
                else{
                    mapOFWithoutFirstChild.put(cusDet.PropStrength__Application__c, new List<PropStrength__Applicant_Detail__c>{cusDet});
                }
            }
        }     
        System.debug('mapOFContainsFirstChild*----'+mapOFContainsFirstChild);
        System.debug('mapOFWithoutFirstChild*----'+mapOFWithoutFirstChild);    
        List<PropStrength__Applicant_Detail__c> listOfCustRec = [SELECT id,Nationality__c, PropStrength__Customer_Name__c, PropStrength__Applicant_Email__c,
                                                             PropStrength__Applicant_Mobile__c, PropStrength__Applicant_Address__c, Passport_No_Doc__c, 
                                                             Formatted_Applicant_Nationality_Docgen__c, Formatted_Applicant_Name_For_Docgen__c,  PropStrength__Application__c ,                                                       
                                                             PropStrength__Contact__r.MailingAddress,PropStrength__Contact__r.Passport_No__c, Formatted_Applicant_Email_For_Docgen__c,
                                                             Formatted_Applicant_Phone_For_Docgen__c, Formatted_Applicant_Address_For_Docgen__c, Formatted_Applicant_Passport_For_Docgen__c,
                                                             PropStrength__Type__c  from PropStrength__Applicant_Detail__c  WHERE PropStrength__Application__c IN: mapOFWithoutFirstChild.keySet() 
                                                                 AND PropStrength__Type__c = '1st Applicant'];
        Map<String,PropStrength__Applicant_Detail__c> mapOFTrAndCustRec = new Map<String,PropStrength__Applicant_Detail__c>();
        for(PropStrength__Applicant_Detail__c custRec : listOfCustRec){
            custRec.Nationality__c = custRec.Nationality__c ?? ' ';            
            mapOFTrAndCustRec.put(custRec.PropStrength__Application__c,custRec);
        }
        List<PropStrength__Applicant_Detail__c> updateRec = new List<PropStrength__Applicant_Detail__c>();
        for(String trRec : mapOFContainsFirstChild.keyset()){
            PropStrength__Applicant_Detail__c cdRec = new PropStrength__Applicant_Detail__c();
            String notionalityFieldCombo = '';
            String nameFieldCombo = '';
            String emailFieldCombo = '';
            String phoneFieldCombo = '';
            String addressFieldCombo = '';
            String passportFieldCombo = '';
            for(PropStrength__Applicant_Detail__c custRec : mapOFContainsFirstChild.get(trRec)){
                if(custRec.PropStrength__Type__c != '1st Applicant'){   
                    System.debug(custRec.Nationality__c+ ' *----*custRec.Nationality__c--'+notionalityFieldCombo);                
                    notionalityFieldCombo += notionalityFieldCombo == '' ? ( (custRec.Nationality__c != '' && custRec.Nationality__c != 'null' && custRec.Nationality__c != null) ? custRec.Nationality__c : '' ) : ' & ' + custRec.Nationality__c ;               
                    nameFieldCombo += nameFieldCombo == '' ? ( (custRec.PropStrength__Customer_Name__c != '' && custRec.PropStrength__Customer_Name__c != 'null' && custRec.PropStrength__Customer_Name__c != null) ? custRec.PropStrength__Customer_Name__c : '' ) : ' & ' + custRec.PropStrength__Customer_Name__c ;  
                    emailFieldCombo += emailFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Email__c != '' && custRec.PropStrength__Applicant_Email__c != 'null' && custRec.PropStrength__Applicant_Email__c != null) ? custRec.PropStrength__Applicant_Email__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Email__c ;  
                    phoneFieldCombo += phoneFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Mobile__c != '' && custRec.PropStrength__Applicant_Mobile__c != 'null' && custRec.PropStrength__Applicant_Mobile__c != null) ? custRec.PropStrength__Applicant_Mobile__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Mobile__c ;  
                    addressFieldCombo += addressFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Address__c != '' && custRec.PropStrength__Applicant_Address__c != 'null' && custRec.PropStrength__Applicant_Address__c != null) ? custRec.PropStrength__Applicant_Address__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Address__c ;   
                    passportFieldCombo += passportFieldCombo == '' ? ( (custRec.Passport_No_Doc__c != '' && custRec.Passport_No_Doc__c != 'null' && custRec.Passport_No_Doc__c != null) ? custRec.Passport_No_Doc__c : '' ) : ' & ' + custRec.Passport_No_Doc__c ;       
                    System.debug(custRec.Nationality__c+ ' *----*custRec.Nationality__c--'+notionalityFieldCombo);
                }                
            }
            
            if(mapOFTRRec.containskey(trRec)){
                cdRec.id = mapOFTRRec.get(trRec).Id;                
                cdRec.Formatted_Applicant_Nationality_Docgen__c = cdRec.Formatted_Applicant_Nationality_Docgen__c == null ? (notionalityFieldCombo == '' ? mapOFTRRec.get(trRec).Nationality__c : mapOFTRRec.get(trRec).Nationality__c + ' & ' + notionalityFieldCombo )  : mapOFTRRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c + ' & ' + notionalityFieldCombo; 
                if(!String.isBlank(cdRec.Formatted_Applicant_Nationality_Docgen__c)){
                    cdRec.Formatted_Applicant_Nationality_Docgen__c = cdRec.Formatted_Applicant_Nationality_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Nationality_Docgen__c = cdRec.Formatted_Applicant_Nationality_Docgen__c.removeEnd('& ');
                }             
                cdRec.Formatted_Applicant_Name_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c == null ? (nameFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Customer_Name__c : mapOFTRRec.get(trRec).PropStrength__Customer_Name__c + ' & ' + nameFieldCombo )  : mapOFTRRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c + ' & ' + nameFieldCombo;
                if(!String.isBlank(cdRec.Formatted_Applicant_Name_For_Docgen__c)){
                    cdRec.Formatted_Applicant_Name_For_Docgen__c = cdRec.Formatted_Applicant_Name_For_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Name_For_Docgen__c = cdRec.Formatted_Applicant_Name_For_Docgen__c.removeEnd('& ');
                }
                cdRec.Formatted_Applicant_Email_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c == null ? (emailFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Applicant_Email__c : mapOFTRRec.get(trRec).PropStrength__Applicant_Email__c + ' & ' + emailFieldCombo) : mapOFTRRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c + ' & ' + emailFieldCombo;
                if(!String.isBlank(cdRec.Formatted_Applicant_Email_For_Docgen__c)){
                    cdRec.Formatted_Applicant_Email_For_Docgen__c = cdRec.Formatted_Applicant_Email_For_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Email_For_Docgen__c = cdRec.Formatted_Applicant_Email_For_Docgen__c.removeEnd('& ');
                }
                cdRec.Formatted_Applicant_Phone_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c == null ? (phoneFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Applicant_Mobile__c : mapOFTRRec.get(trRec).PropStrength__Applicant_Mobile__c + ' & ' + phoneFieldCombo) : mapOFTRRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c + ' & ' + phoneFieldCombo;
                if(!String.isBlank(cdRec.Formatted_Applicant_Phone_For_Docgen__c)){
                    cdRec.Formatted_Applicant_Phone_For_Docgen__c = cdRec.Formatted_Applicant_Phone_For_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Phone_For_Docgen__c = cdRec.Formatted_Applicant_Phone_For_Docgen__c.removeEnd('& ');
                }
                cdRec.Formatted_Applicant_Address_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c == null ? (addressFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Applicant_Address__c : mapOFTRRec.get(trRec).PropStrength__Applicant_Address__c + ' & ' + addressFieldCombo) : mapOFTRRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c + ' & ' + addressFieldCombo;
                if(!String.isBlank(cdRec.Formatted_Applicant_Address_For_Docgen__c)){
                    cdRec.Formatted_Applicant_Address_For_Docgen__c = cdRec.Formatted_Applicant_Address_For_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Address_For_Docgen__c = cdRec.Formatted_Applicant_Address_For_Docgen__c.removeEnd('& ');
                }
                cdRec.Formatted_Applicant_Passport_For_Docgen__c = mapOFTRRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c == null ? (passportFieldCombo == '' ? mapOFTRRec.get(trRec).PropStrength__Contact__r.Passport_No__c : mapOFTRRec.get(trRec).PropStrength__Contact__r.Passport_No__c + ' & ' + passportFieldCombo) : mapOFTRRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c + ' & ' + passportFieldCombo;  
                if(!String.isBlank(cdRec.Formatted_Applicant_Passport_For_Docgen__c)){
                    cdRec.Formatted_Applicant_Passport_For_Docgen__c = cdRec.Formatted_Applicant_Passport_For_Docgen__c.removeStart(' &');
                    cdRec.Formatted_Applicant_Passport_For_Docgen__c = cdRec.Formatted_Applicant_Passport_For_Docgen__c.removeEnd('& ');
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
            for(PropStrength__Applicant_Detail__c custRec : mapOFWithoutFirstChild.get(trRec)){
                notionalityFieldCombo += notionalityFieldCombo == '' ? ( (custRec.Nationality__c != '' && custRec.Nationality__c != 'null' && custRec.Nationality__c != null) ? custRec.Nationality__c : '' ) : ' & ' + custRec.Nationality__c ;               
                nameFieldCombo += nameFieldCombo == '' ? ( (custRec.PropStrength__Customer_Name__c != '' && custRec.PropStrength__Customer_Name__c != 'null' && custRec.PropStrength__Customer_Name__c != null) ? custRec.PropStrength__Customer_Name__c : '' ) : ' & ' + custRec.PropStrength__Customer_Name__c ;  
                emailFieldCombo += emailFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Email__c != '' && custRec.PropStrength__Applicant_Email__c != 'null' && custRec.PropStrength__Applicant_Email__c != null) ? custRec.PropStrength__Applicant_Email__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Email__c ;  
                phoneFieldCombo += phoneFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Mobile__c != '' && custRec.PropStrength__Applicant_Mobile__c != 'null' && custRec.PropStrength__Applicant_Mobile__c != null) ? custRec.PropStrength__Applicant_Mobile__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Mobile__c ;  
                addressFieldCombo += addressFieldCombo == '' ? ( (custRec.PropStrength__Applicant_Address__c != '' && custRec.PropStrength__Applicant_Address__c != 'null' && custRec.PropStrength__Applicant_Address__c != null) ? custRec.PropStrength__Applicant_Address__c : '' ) : ' & ' + custRec.PropStrength__Applicant_Address__c ;   
                passportFieldCombo += passportFieldCombo == '' ? ( (custRec.Passport_No_Doc__c != '' && custRec.Passport_No_Doc__c != 'null' && custRec.Passport_No_Doc__c != null) ? custRec.Passport_No_Doc__c : '' ) : ' & ' + custRec.Passport_No_Doc__c ;                
                
            }
            if(trRec != null && mapOFTrAndCustRec.containsKey(trRec)) {
                System.debug(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c+'///notionalityFieldCombo///'+notionalityFieldCombo+'//**//'+mapOFTrAndCustRec.get(trRec).Nationality__c);
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c == null ? (notionalityFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).Nationality__c : mapOFTrAndCustRec.get(trRec).Nationality__c + ' & ' + notionalityFieldCombo )  : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c + ' & ' + notionalityFieldCombo;
                System.debug(' *----*custRec.Nationality__c--'+mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c);
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c.removeEnd('& ');
                }
                System.debug(' *----*custRec.Nationality__c--'+mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Nationality_Docgen__c);
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c == null ? (nameFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Customer_Name__c : mapOFTrAndCustRec.get(trRec).PropStrength__Customer_Name__c + ' & ' + nameFieldCombo )  : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c + ' & ' + nameFieldCombo;
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Name_For_Docgen__c.removeEnd('& ');
                }
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c == null ? (emailFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Email__c : mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Email__c + ' & ' + emailFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c + ' & ' + emailFieldCombo;
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Email_For_Docgen__c.removeEnd('& ');
                }
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c == null ? (phoneFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Mobile__c : mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Mobile__c + ' & ' + phoneFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c + ' & ' + phoneFieldCombo;
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Phone_For_Docgen__c.removeEnd('& ');
                }
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c == null ? (addressFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Address__c : mapOFTrAndCustRec.get(trRec).PropStrength__Applicant_Address__c + ' & ' + addressFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c + ' & ' + addressFieldCombo;
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Address_For_Docgen__c.removeEnd('& ');
                }
                mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c == null ? (passportFieldCombo == '' ? mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Passport_No__c : mapOFTrAndCustRec.get(trRec).PropStrength__Contact__r.Passport_No__c + ' & ' + passportFieldCombo) : mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c + ' & ' + passportFieldCombo;  
                
                System.debug(' *----*custRec.Nationality__c--'+mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c); 
                if(!String.isBlank(mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c)){
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c.removeStart(' &');
                    mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c = mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c.removeEnd('& ');
                }
                System.debug(' *----*custRec.Nationality__c--'+mapOFTrAndCustRec.get(trRec).Formatted_Applicant_Passport_For_Docgen__c); 
                updateRec.add(mapOFTrAndCustRec.get(trRec));
            }
        }
        
        System.debug('updateRec*-----'+updateRec);
        if(updateRec.size() > 0){
            update updateRec;
        }
        
    }
    
    public static void updateBookingApplicantCreated(List<PropStrength__Applicant_Detail__c> newList) { 
        set<Id> appIds = new Set<Id>();
        List<PropStrength__Application_Booking__c> updateList = new List<PropStrength__Application_Booking__c>();
        for(PropStrength__Applicant_Detail__c pr: newList) {
            if(pr.PropStrength__Active__c &&
               pr.PropStrength__Type__c == '1st Applicant') {
                   appIds.add(pr.PropStrength__Application__c);
               }
        }
        if(!appIds.isEmpty()) {
            List<PropStrength__Application_Booking__c> bookingList = [SELECT Id 
                                                                      FROM PropStrength__Application_Booking__c 
                                                                      WHERE Id IN: appIds];
            if(!bookingList.isEmpty()) {
                for(PropStrength__Application_Booking__c book : bookingList) {
                    PropStrength__Application_Booking__c b = new PropStrength__Application_Booking__c();
                    b.Id= book.Id;
                    b.Applicant_Created__c = true;
                    updateList.add(b);
                }
                if(!updateList.isEmpty()) {
                    update updateList;
                }
            }
        }
    }
    
    public static void sendToMobile(List<PropStrength__Applicant_Detail__c> newList,map<Id,PropStrength__Applicant_Detail__c> oldMap) { 
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        boolean trgFlg = mobile_appmdt.User_trigger__c;
        set<Id> appIds = new Set<Id>();
        if(trgFlg) {
            for(PropStrength__Applicant_Detail__c pr : newList) {
                if((pr.PropStrength__Applicant_Acc__c != oldMap.get(pr.Id).PropStrength__Applicant_Acc__c && 
                    pr.PropStrength__Active__c) ||
                   (pr.PropStrength__Active__c &&
                    pr.PropStrength__Active__c != oldMap.get(pr.Id).PropStrength__Active__c)) {
                        appIds.add(pr.Id);
                    }
            }
            system.debug('appIds::'+appIds);
            if(!appIds.isEmpty() && !System.IsBatch() && !System.isFuture()) {
                applicantTriggerHelper.sendToMobileAPI(appIds);
            }
        }
    }
    
    @future(callOut=true)
    public static void sendToMobileAPI(set<Id> appIds) {
        List<PropStrength__Applicant_Detail__c> appList = [SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Applicant_Acc__r.LastName,
                                                           PropStrength__Applicant_Acc__r.FirstName,PropStrength__Applicant_Mobile__c,PropStrength__Applicant_Acc__r.Country_Code__c
                                                           FROM PropStrength__Applicant_Detail__c
                                                           WHERE Id IN: appIds];
        if(!appList.isEmpty()) {
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endPointURL = mobile_appmdt.End_Point__c;
            String sftoken = mobile_appmdt.sf_Token__c;
            String Subscription_Key = mobile_appmdt.Subscription_Key__c;
            //System.debug('endpoint : '+endpoint);
            //String endPointURL = endpoint+'/sruser/v1/user';
            String serializedJSON = '';
            try {
                requestBodyWrapper reqWrap = new requestBodyWrapper();
                for(PropStrength__Applicant_Detail__c bk : appList) {
                    reqWrap.lastName = (bk.PropStrength__Applicant_Acc__r.LastName != null ? bk.PropStrength__Applicant_Acc__r.LastName : '');
                    reqWrap.email = (bk.PropStrength__Applicant_Email__c != null ? bk.PropStrength__Applicant_Email__c : '');
                    reqWrap.mobile = (bk.PropStrength__Applicant_Mobile__c != null ? bk.PropStrength__Applicant_Mobile__c : '');
                    reqWrap.source = 'salesForce';
                    reqWrap.firstName = (bk.PropStrength__Applicant_Acc__r.firstName != null ? bk.PropStrength__Applicant_Acc__r.firstName : '');
                    reqWrap.dialCode = (bk.PropStrength__Applicant_Acc__r.Country_Code__c != null ? bk.PropStrength__Applicant_Acc__r.Country_Code__c : '0');
                    //reqWrap.password = 'G345345';
                }
                if(reqWrap != null) {
                    system.debug('wraplst::'+wraplst);
                    serializedJSON = JSON.serialize(reqWrap);
                    System.debug('serializedJSON::'+serializedJSON);
                    if(!String.isBlank(serializedJSON)) {
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(endPointURL);
                        request.setMethod('POST');
                        request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
                        request.setHeader('Content-Type','application/json');
                        request.setHeader('x-integration-key', 'salesforce');
                        request.setHeader('x-sf-token',sftoken);
                        request.setBody(serializedJSON);
                        HttpResponse response = http.send(request);
                        system.debug('getBody:::'+ response.getBody());
                        if(response.getStatusCode() == 200) {
                            for(PropStrength__Applicant_Detail__c bk : appList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Applicant_Detail__c = bk.Id;
                                appLog.Request_Body__c = serializedJSON;
                                appLog.Status__c = '200';
                                appLog.API_Name__c = endPointURL;
                                appLog.Class_Name__c = 'applicantTriggerHelper';
                                appLog.Response_Body__c = response.getBody();
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                            system.debug('sucess:::'+response.getBody());
                        } else {
                            for(PropStrength__Applicant_Detail__c bk : appList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Applicant_Detail__c = bk.Id;
                                appLog.Class_Name__c = 'applicantTriggerHelper';
                                appLog.Status__c = '400';
                                appLog.API_Name__c = endPointURL;
                                appLog.Request_Body__c = serializedJSON;
                                appLog.Response_Body__c = response.getBody();
                                insertList.add(appLog);
                            }
                            system.debug('Error:::'+response.getBody());
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                }
            } catch(Exception e) {
                for(PropStrength__Applicant_Detail__c bk : appList) {
                    Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                    appLog.Applicant_Detail__c = bk.Id;
                    appLog.Status__c = '400';
                    appLog.API_Name__c = endPointURL;
                    appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                    appLog.Response_Body__c = String.valueOf(e.getStackTraceString());
                    insertList.add(appLog);
                }
                if(!insertList.isEmpty()) {
                    insert insertList;
                }
                system.debug('~~~~~Error: '+e.getStackTraceString());
            }
        }
    }
    
    public class requestBodyWrapper{
        String firstName;
        String lastName;
        String email;
        String dialCode;
        String mobile;
        String source;
        //String password;
    }
}