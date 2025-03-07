@RestResource(urlMapping='/PSsobhaConnect/')
global class PSsobhaConnectBrokerAPI {
    @HttpGet
    global static List<Account>  GetPSsobhaConnectBrokerAPI() {
        List<Account> resWrap = new List<Account>();
        try {
            RestRequest request = RestContext.request;
            List<Account> contactList = [SELECT Id,Name,Email_ID_1__c,Mobile_No__c,Contact_Person__c, 
                                         Phone,RERA_Registration_No__c,BillingCity,BillingStreet,
                                         BillingPostalCode,BillingState,BillingCountry
                                         FROM Account
                                         WHERE RecordType.Name = 'Broker' AND PropStrength__Broker_Type__c = 'Sobha Connect'];
            if(!contactList.isEmpty()) {
                for(Account sr : contactList) {  
                    Account res = new Account();
                    res.Id = sr.Id;
                    res.SC_Id__c = sr.Id;
                    res.Email_Id__c = sr.Email_ID_1__c != null ? sr.Email_ID_1__c : '';
                    res.Contact_Person__c = sr.Contact_Person__c != null ? sr.Contact_Person__c : '';
                    res.Name = sr.Name;
                    res.Mobile_No__c = sr.Mobile_No__c != null ? sr.Mobile_No__c : '';
                    res.RERA_Number__c = sr.RERA_Registration_No__c != null ? sr.RERA_Registration_No__c : '';
                    res.Address__c =   (sr.BillingStreet != null ? sr.BillingStreet : '') + ' ' + 
                                    (sr.BillingCity != null ? sr.BillingCity : '') + ' ' + 
                                    (sr.BillingPostalCode != null ? sr.BillingPostalCode : '') + ' ' + 
                                    (sr.BillingState != null ? sr.BillingState : '') + ' ' + 
                                    (sr.BillingCountry != null ? sr.BillingCountry : '');
                    resWrap.add(res);
                }
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
        return resWrap;
    }
}