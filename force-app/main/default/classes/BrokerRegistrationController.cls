public without sharing class BrokerRegistrationController { 

    @AuraEnabled(cacheable= true)  
    public static List<User> getUserManagerDetails(String Managerid) {
            return [select id, Name, Email, Manager_Name__c,Manager.Email,Manager.Manager.Email from user where id =:Managerid];
            //List<User> usrDetail = [select id,Name,Email, Manager_Name__c,Manager.Email,Manager.Manager.Email from user where id =:Managerid];
           // return usrDetail[0].Manager.Email; 
    }

    @AuraEnabled
    public static Broker_Registration__c createRecord(Broker_Registration__c record){
        try {
            //if( isDuplicate(record) )
            //    throw new BrokerRegistrationException('A broker is already registered with the provided information.');
              if (record.Broker_Category__c == 'Broker - RERA') {
            record.Company_Registered_In__c = 'Dubai';
            }
        

            
            record.Registration_Link_Expiry_Date_Time__c = DateTime.now().addDays(30);
            insert record;
            return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean isDuplicate(Broker_Registration__c record) {
        Id recordId = record.Id;
        String email = record.Email__c;
        String phone = record.Mobile__c;
        String tradeLicense = record.Name_as_per_trade_license__c;
        String registrationNo = record.Registration_Number__c;

        String query = 'SELECT Id FROM Broker_Registration__c WHERE (';

        //if( String.isNotBlank(phone) )
           // query += ' OR Mobile__c = :phone ';
        if( String.isNotBlank(tradeLicense) )
            query += ' Name_as_per_trade_license__c = :tradeLicense ';
        //if( String.isNotBlank(registrationNo) )
            //query += ' OR Registration_Number__c = :registrationNo ';

        query += ' ) ';

        if( recordId != null )
            query += ' AND Id != :recordId ';

        List<Broker_Registration__c> records = Database.query(query);

        return !records.isEmpty();
    }

    @AuraEnabled
    public static Integer validateRegistrationNo(String registrationNo, String obj){
        system.debug('');
        Integer countRe =0;
        Id currentUser = UserInfo.getUserId();
        if(obj=='Broker'){
            List<Channel_Partner__c> cpList = [Select Id,Emergency_Created_ID__c,OwnerId, black_listed_user__c 
                                               from Channel_Partner__c 
                                               where (Passport_No__c =: registrationNo OR RERA_Registration_No__c =: registrationNo)
                                               ];
            countRe = cpList.size();
            if(cpList.size()>0){
                for(Channel_Partner__c channelPartner: cpList) {
                    if(channelPartner.black_listed_user__c == TRUE) {
                        return -1;
                    }
                }
                if(cpList[0].Emergency_Created_ID__c==true && cpList[0].OwnerId==currentUser){
                   countRe = 0; 
                }
            }
        } else {
            List<Sobha_Connect__c> scList = [Select Id,Emergency_Created_ID__c,OwnerId, black_listed_user__c from Sobha_Connect__c
                                             where (Registration__c =: registrationNo OR RERA_Number__c=: registrationNo)
                                             ];
            countRe = scList.size();
            if(scList.size()>0){
                 for(Sobha_Connect__c sobhaConnect: scList) {
                    if(sobhaConnect.black_listed_user__c == TRUE) {
                        return -1;
                    }
                }
                if(scList[0].Emergency_Created_ID__c==true && scList[0].OwnerId==currentUser){
                   countRe = 0; 
                }
            }
        }
        if(countRe==0){
        	List<AggregateResult> bgList = [Select count(Id) from Broker_Registration__c where Registration_Number__c =: registrationNo];
        	countRe = Integer.valueOf(bgList[0].get('expr0'));
        }
        return countRe;
    }

    @AuraEnabled
    public static Id getReportingManger(Id salesManagerId){
        try {
            system.debug('~~~~~'+salesManagerId);
            Id reportingMangerId;
            reportingMangerId=[Select ManagerId from user where Id=:salesManagerId].ManagerId;
            return reportingMangerId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    class BrokerRegistrationException extends Exception { }
}