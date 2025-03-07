@RestResource(urlMapping='/PSBrokers/*')
global class GetPSBrokers {
    @HttpGet
    global static List<Account> GetPSBrokersData() {
       List<Account> resAcc = new List<Account>();
        try {
            RestRequest request = RestContext.request;
            List<Account> contactList = [SELECT Id,Name,Email_ID_2__c,Email_ID_1__c,Mobile_No__c,Channel_Relationship_Manager_Name__c,
                                         Phone,RERA_Registration_No__c,Broker_Category__c,BillingCity,BillingStreet,ChannelPartner_Id__c,
                                         BillingPostalCode,BillingState,BillingCountry
                                         FROM Account 
                                         WHERE RecordType.Name = 'Broker' AND PropStrength__Broker_Type__c = 'Standard'];
            
            if(!contactList.isEmpty()) {
                for(Account sr : contactList) {  
                    Account res = new Account();
                    res.Id = sr.Id;
                    res.Name = sr.Name != null ? sr.Name : '';
                    res.ChannelPartner_Id__c = sr.ChannelPartner_Id__c != null ? sr.ChannelPartner_Id__c : '';
                    res.Email_ID_1__c = sr.Email_ID_1__c != null ? sr.Email_ID_1__c : '';
                    res.Email_ID_2__c = sr.Email_ID_2__c != null ? sr.Email_ID_2__c : '';
                    res.Mobile_No__c = sr.Mobile_No__c != null ? sr.Mobile_No__c : '';
                    res.Office_No__c = sr.Phone != null ? sr.Phone : '';
                    res.RERA_Registration_No__c = sr.RERA_Registration_No__c != null ? sr.RERA_Registration_No__c : '';
                    res.Address__c =   (sr.BillingStreet != null ? sr.BillingStreet : '' + ' ') +
                                    (sr.BillingCity != null ? sr.BillingCity : '') + ' ' + 
                                    (sr.BillingPostalCode != null ? sr.BillingPostalCode : '') + ' ' + 
                                    (sr.BillingState != null ? sr.BillingState : '') + ' ' + 
                                    (sr.BillingCountry != null ? sr.BillingCountry : '');
                    res.Is_Active__c = true;
                    res.Channel_Relationship_Manager_Name__c = sr.Channel_Relationship_Manager_Name__c != null ? sr.Channel_Relationship_Manager_Name__c : '';
                    res.Category__c = sr.Broker_Category__c != null ? sr.Broker_Category__c : '';
                    resAcc.add(res);
                }
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
        return resAcc;
    }
}