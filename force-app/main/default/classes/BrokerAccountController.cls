public without sharing class BrokerAccountController { 

    @AuraEnabled(cacheable= true)  
    public static List<User> getUserManagerDetails(String Managerid) {
            return [select id, Name, Email, Manager_Name__c,Manager.Email,Manager.Manager.Email from user where id =:Managerid];
            //List<User> usrDetail = [select id,Name,Email, Manager_Name__c,Manager.Email,Manager.Manager.Email from user where id =:Managerid];
           // return usrDetail[0].Manager.Email; 
    }

    @AuraEnabled
    public static Account createRecord(Account record){
        try {
            //if( isDuplicate(record) )
            //    throw new BrokerRegistrationException('A broker is already registered with the provided information.');
            
            // record.Registration_Link_Expiry_Date_Time__c = DateTime.now().addDays(1);
            insert record;
            return record;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Boolean isDuplicate(Account record) {
        System.debug('====>');
        String recordId = String.valueOf(record.Id);
        System.debug('===recordId=>'+recordId);
        String email = record.Email__c;
        String phone = record.Mobile__c;
        String tradeLicense = record.Name_as_per_trade_license__c;
        // String registrationNo = record.Registration_Number__c;

        String query = 'SELECT Id FROM Account WHERE (';

        //if( String.isNotBlank(phone) )
           // query += ' OR Mobile__c = :phone ';
        if( String.isNotBlank(tradeLicense) )
            query += ' Name_as_per_trade_license__c = :tradeLicense ';
        //if( String.isNotBlank(registrationNo) )
            //query += ' OR Registration_Number__c = :registrationNo ';

        query += ' ) ';

        if( recordId != null )
            query += ' AND Id != :recordId ';
		System.debug('===query=>'+query);
        List<Account> records = Database.query(query);

        return !records.isEmpty();
    }

    @AuraEnabled
    public static Integer validateRegistrationNo(String registrationNo, String obj){
        system.debug('');
        Integer countRe =0;
        Id currentUser = UserInfo.getUserId();
        if(obj=='Broker'){
            List<Channel_Partner__c> cpList = [Select Id,Emergency_Created_ID__c,OwnerId from Channel_Partner__c where (Passport_No__c =: registrationNo OR RERA_Registration_No__c =: registrationNo)];
            countRe = cpList.size();
            if(cpList.size()>0){
                if(cpList[0].Emergency_Created_ID__c==true && cpList[0].OwnerId==currentUser){
                   countRe = 0; 
                }
            }
        } else {
            List<Sobha_Connect__c> scList = [Select Id,Emergency_Created_ID__c,OwnerId from Sobha_Connect__c where (Registration__c =: registrationNo OR RERA_Number__c=: registrationNo)];
            countRe = scList.size();
            if(scList.size()>0){
                if(scList[0].Emergency_Created_ID__c==true && scList[0].OwnerId==currentUser){
                   countRe = 0; 
                }
            }
        }
        if(countRe==0){
        	//List<AggregateResult> bgList = [Select count(Id) from Account where Registration_Number__c =: registrationNo];
        	//countRe = Integer.valueOf(bgList[0].get('expr0'));
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