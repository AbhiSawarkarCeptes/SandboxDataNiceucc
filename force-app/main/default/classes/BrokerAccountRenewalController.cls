public without sharing class BrokerAccountRenewalController {
    @InvocableMethod
    public static List<ID> createRenewalRecord(List<Account> acRecord){
        try{
            /* Broker_Created_Date__c, RERA_Number__c, First_Name__c, Last_Name__c, Sales_Manager__c, Fax__c*/  
            Account queryRecord = [SELECT Id, Name, Account_Owner_Email__c, Al_Siniya_Partner__c, Broker_Created_Date__c, Fax_correspondence__c, Country_Code__c,Country_CP__c, Name_as_per_trade_license__c, Name_as_per_passport__c, Email_ID_1__c, Mobile_No__c, OwnerId,
                                    Designation1__c, Registration_Number__c, Street_name__c, Channel_Relationship_Manager__c, Channel_Relationship_Head__c,Channel_Relationship_Manager__r.Email, 
                                                 Broker_Category__c,CHRM_s_Email__c,  Nationality__c, RERA_Registration_No__c,Witness_Email__c,  Broker_Sub_Type__c, PropStrength__Broker_Type__c, Office_Apartment_number__c, billingStreet, Villa_Building_name__c, BillingState,
                                                 BillingCity, BillingCountry,Witness_Name__c,Company_Registered_In__c,  BillingPostalCode, phone, Fax  FROM Account WHERE ID=: acRecord[0].Id];
            Broker_Renewal__c broker = new Broker_Renewal__c();
            broker.Name_as_per_trade_license__c = queryRecord.Name;
            broker.Name_as_per_passport__c = queryRecord.Name_as_per_passport__c;
            broker.Email_ID_1__c = queryRecord.Email_ID_1__c;
            broker.Mobile_No__c = queryRecord.Mobile_No__c;
            broker.Al_Siniya_Partner__c = queryRecord.Al_Siniya_Partner__c;
            broker.OwnerId = queryRecord.OwnerId;
            broker.Registration_Link_Expiry_Date_Time__c = System.now().addDays(30);
            broker.Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
            broker.Designation__c = queryRecord.Designation1__c;
            broker.Nationality__c = queryRecord.Nationality__c;
            broker.Registration_Number__c = queryRecord.Registration_Number__c;
            broker.RERA_Registration_No__c = queryRecord.RERA_Registration_No__c;
            broker.Channel_Relationship_Manager__c = queryRecord.Channel_Relationship_Manager__c;
            broker.Channel_Relationship_Head__c = queryRecord.Channel_Relationship_Head__c;
            broker.Broker_Category__c = queryRecord.Broker_Category__c;
            broker.Broker_Sub_Type__c = queryRecord.Broker_Sub_Type__c;
            broker.Witness_Email__c = queryRecord.Witness_Email__c;
            broker.Witness_Name__c = queryRecord.Witness_Name__c;
            broker.Broker_Type__c = queryRecord.PropStrength__Broker_Type__c;
            broker.Company_Registered_In__c = queryRecord.Company_Registered_In__c;
            broker.Office_Apartment_number__c = queryRecord.Office_Apartment_number__c;
            broker.Street_name__c = queryRecord.Street_name__c;
            broker.Villa_Building_name__c = queryRecord.Villa_Building_name__c;
            broker.District_Area__c = queryRecord.BillingState;
            broker.City_Province__c = queryRecord.BillingCity;
            broker.Country_Code__c = queryRecord.Country_Code__c;
            broker.Country__c = queryRecord.BillingCountry;
            broker.ZIP_Postal_Code_PO_Box__c = queryRecord.BillingPostalCode;
            broker.Phone__c = queryRecord.phone;
            broker.Broker_Account__c = queryRecord.Id;
            broker.Fax__c = queryRecord.Fax_correspondence__c;
            broker.CRM_Email__c = queryRecord.CHRM_s_Email__c;
            broker.Country_CP__c = queryRecord.Country_CP__c;
            broker.Account_Owner_Email__c = queryRecord.Account_Owner_Email__c;
            insert broker;

            broker.BRF_Link__c = System.Label.BRF_site_Link+'renewbroker/?id='+broker.Id;
            update broker;
            
            Account brokerAccount = new Account();
            brokerAccount.Id = queryRecord.Id;
            brokerAccount.Renewal_Status__c = 'Renewal Initiated';
            brokerAccount.Renewal_Record_Id__c = broker.Id;
            brokerAccount.Show_Send_Renewal_Link_Button__c = true;
            update brokerAccount;
            
            List<Id> reutrnId = new List<Id>();
            reutrnId.add(broker.Id);
            return reutrnId;
        }  catch (Exception e) {
            system.debug('~~~Error: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}