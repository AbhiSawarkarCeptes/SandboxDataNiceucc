public class CustomerDetailUpdateController {
    @AuraEnabled
    public static List<Unit__c> getUnitDetail(String unitName){
        List<Unit__c> un = [SELECT ID FROM Unit__c WHERE Name =:unitName LIMIT 1]; 
        if(un != null && un.size() > 0 ){
            return  un; 
        } 
        return null;
    }
    @AuraEnabled
    public static String getApplicantDetail(String namevalue,String onNationalityValue ,String MailingCityvalue,String MailingStatevalue,String MailingCountryvalue,String Cityvalue,String Statevalue,String Countryvalue,String addressvalue,String emailvalue,String numbervalue,String unitValue,String PassportNumber,date PassportexpireDatevalue,String Emiratesvalue,String value){
        
        Date dateField =   Date.today();
        Date lastDayOfMonth = Date.newInstance(dateField.year(), 12, 31);
        String AccountId ;
        List<Applicant_Details__c> lpList = new List<Applicant_Details__c>();
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Unit__c unList = [SELECT ID,Booking__c,Project__c,Customers__c FROM Unit__c WHERE ID =: unitValue LIMIT 1];
        List<Account> accList =  [SELECT ID FROM Account WHERE Phone =: numbervalue AND PersonEmail =: emailvalue LIMIT 1]; 
        if(accList.size() > 0 && accList != null){
            AccountId = accList[0].Id;
        }
        else{
            Account acc = new Account(FirstName  = namevalue,LastName =namevalue,  PersonEmail = emailvalue ,Phone = numbervalue,RecordTypeId = personAccountRecordTypeId,Country__c = null,
                                      Residential_Street__c = addressvalue ,Office_Street__c = addressvalue);
            Insert acc; 
            AccountId = acc.Id;
        }
        Opportunity oppOld = new Opportunity(Id = unList.Customers__c,Booking__c= null,Unit__c = null);
        Update oppOld;
        Opportunity opp = new Opportunity(Unit__c = unitValue,CloseDate = lastDayOfMonth, Name = namevalue,
                                          Mailing_Address__c= addressvalue,Permanent_Address__c= addressvalue,Email__c = emailvalue, 
                                          Primary_Phone__c = numbervalue,StageName = 'Site Visit Done',AccountId = AccountId,Project__c = unList.Project__c,
                                          Booking__c = unList.Booking__c);
        Insert opp;
        Unit__c un = new Unit__c(Customers__c = opp.Id, Id= unitValue);
        UPDATE un;
        Booking__c bk = new Booking__c(Opportunity__c = opp.Id,ReSale_Transfer_Type__c = 'SMT', Id= unList.Booking__c);
        UPDATE bk;
        For(Applicant_Details__c app : [SELECT Id,Booking__c FROM Applicant_Details__c WHERE Booking__c =: unList.Booking__c]){
            app.Booking__c = null;
            lpList.add(app);
        }
        UPDATE lpList;
        Applicant_Details__c app = new Applicant_Details__c(Account__c = AccountId,Booking__c = unList.Booking__c,Opportunity__c=opp.Id,Unit__c = unitValue,Nationality__c= onNationalityValue,
                                                            Applicant_Number__c='Primary Applicant',Name=namevalue,Mobile_Number__c =numbervalue,Email_Address__c=emailvalue,
                                                            Type_Of_Applicant__c = value,Permanent_Address__c= addressvalue, Mailing_Address__c= addressvalue,
                                                            Passport_Copy_Details__c = PassportNumber,Emirates_ID_Details__c=Emiratesvalue,Mailing_Country__c = MailingCountryvalue, Mailing_state__c=MailingStatevalue,
                                                            Mailing_city__c= MailingCityvalue,Country__c=Countryvalue,state__c=Statevalue,city__c=Cityvalue,Valid_Until_Passport__c=PassportexpireDatevalue); 
        Insert app;
        return 'Success';
    }
    @AuraEnabled
    public static String addApplicantDetail(String namevalue,String onNationalityValue ,String MailingCityvalue,String MailingStatevalue,String MailingCountryvalue,String Cityvalue,String Statevalue,String Countryvalue,
                                            String addressvalue,String emailvalue,String numbervalue,String unitValue,String PassportNumber,date PassportexpireDatevalue,String Emiratesvalue,String value){
                                                List<String> applicantNumberList = new List<String>{'Primary Applicant','Second Applicant','Third Applicant','Fourth Applicant','Fifth Applicant'};
                                                    String ApplicantNumber ;
                                                Unit__c unList = [SELECT ID,Booking__c,Project__c,Customers__c,Customers__r.AccountId FROM Unit__c WHERE ID =: unitValue LIMIT 1];
                                                system.debug('unList'+unList);
                                                for(Applicant_Details__c app : [SELECT Id,Booking__c,Applicant_Number__c FROM Applicant_Details__c WHERE Booking__c =: unList.Booking__c order by createdDate desc LIMIT 1]){
                                                    if(app.Applicant_Number__c == 'Third Applicant'){
                                                        ApplicantNumber = 'Fourth Applicant';
                                                    }
                                                    else if(app.Applicant_Number__c == 'Second Applicant'){
                                                        ApplicantNumber = 'Third Applicant';
                                                    }
                                                    else if(app.Applicant_Number__c == 'Primary Applicant'){
                                                        ApplicantNumber = 'Second Applicant';
                                                    }
                                                }
                                                Applicant_Details__c app = new Applicant_Details__c(Account__c = unList.Customers__r.AccountId,Booking__c = unList.Booking__c,Opportunity__c= unList.Customers__c,
                                                                                                    Applicant_Number__c = ApplicantNumber,Name=namevalue,Mobile_Number__c =numbervalue,Email_Address__c=emailvalue,
                                                                                                    Type_Of_Applicant__c = value,Permanent_Address__c= addressvalue, Mailing_Address__c= addressvalue,Unit__c = unitValue,Nationality__c= onNationalityValue,
                                                                                                    Passport_Copy_Details__c = PassportNumber,Emirates_ID_Details__c=Emiratesvalue,Mailing_Country__c = MailingCountryvalue, Mailing_state__c=MailingStatevalue,
                                                            Mailing_city__c= MailingCityvalue,Country__c=Countryvalue,state__c=Statevalue,city__c=Cityvalue,Valid_Until_Passport__c=PassportexpireDatevalue);
                                                system.debug('app'+app);
                                                Insert app;
                                                return 'Success';
                                            }
    
}