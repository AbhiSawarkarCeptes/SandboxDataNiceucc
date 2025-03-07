@isTest
public class DocumentUploadLWCCopyController_Test {

    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id marketingIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Marketing Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss = new Incentive_Slab__c(Marketing_Category__c = 'Loyalty Sales', Marketing_Incentive__c = 10, Loyalty_Sales_Executive_Split__c = 10, Marketing_Head_Split__c = 10, CMO_Channel_Relations_Split__c = 10, Promoter_Split__c = 10, Mall_Team_Lead_Split__c = 10, Telesales_Agent_Split__c = 10, Campaign_Manager_Split__c = 20, Digital_Marketing_Head_Split__c = 10, Team_Lead_Split__c = 10, TeleSales_Head_Split__c = 10, RecordtypeId = marketingIncentiveId);
        insert iss;
        
        Id channelPartnerIncentiveId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get('Channel Partner Incentive').getRecordTypeId();
        
        Incentive_Slab__c iss1 = new Incentive_Slab__c(Marketing_Category__c = 'Mall Stands/Kiosks Sales', CMO_Channel_Relations_Split__c = 10, Intl_Broker_New_Customer_Inc__c = 10, Intl_Broker_Old_Customer_Inc__c = 10, Sobha_Connect_UAE_New_Inc__c = 10, Sobha_Connect_UAE_Old_Inc__c = 10, VP_Channel_Relations_Split__c = 10, TL_Channel_Relation_Split__c = 10, RM_Channel_Split__c = 20, RecordtypeId = channelPartnerIncentiveId);
        insert iss1;

        PropStrength__Projects__c proj = new PropStrength__Projects__c(DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Annexure_Document_Uploaded__c = System.Today(), Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker International';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        cont.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Request_Source__c = 'Loyalty';
        insert enq;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        KYC_Documents__c kyc = new KYC_Documents__c(Offer__c = offer.Id, Residential_Status__c = 'Resident');
        insert kyc;
    }

    @isTest
    static void testUpdateKYCCheckList() {
        String selOff = [SELECT Id FROM PropStrength__Offer__c LIMIT 1].Id;
        String resSta = 'Resident';
        String appTy = 'First Applicant';
        String kycId = DocumentUploadLWCCopyController.updateKYCCheckList(selOff, resSta, appTy);
        KYC_Documents__c kyc = [SELECT Id, Offer__c, Residential_Status__c, Applicant_Type__c FROM KYC_Documents__c WHERE Id = :kycId];
    }

    @isTest
    static void testUploadFiles() {
        KYC_Documents__c kyc = [SELECT Id FROM KYC_Documents__c LIMIT 1];

        List<Map<String, Object>> files = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Title' => 'Passport',
                'VersionData' => Blob.valueOf('SampleData')
            },
            new Map<String, Object>{
                'Title' => 'Emirates ID',
                'VersionData' => Blob.valueOf('SampleData')
            }
        };

        String result = DocumentUploadLWCCopyController.uploadFiles(files, kyc.Id);
        List<Attachment> attachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :kyc.Id];
        KYC_Documents__c updatedKyc = [SELECT Id, Passport__c, Emirates_ID__c FROM KYC_Documents__c WHERE Id = :kyc.Id];
    }
    
    @isTest
    static void testUploadFiles2() {
        KYC_Documents__c kyc = [SELECT Id FROM KYC_Documents__c LIMIT 1];
        kyc.Residential_Status__c='Non-Resident';
        update kyc;

        List<Map<String, Object>> files = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Title' => 'Passport',
                'VersionData' => Blob.valueOf('SampleData')
            },
            new Map<String, Object>{
                'Title' => 'Emirates ID',
                'VersionData' => Blob.valueOf('SampleData')
            }
        };

        String result = DocumentUploadLWCCopyController.uploadFiles(files, kyc.Id);
        //List<Attachment> attachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :kyc.Id];
        //KYC_Documents__c updatedKyc = [SELECT Id, Passport__c, Emirates_ID__c FROM KYC_Documents__c WHERE Id = :kyc.Id];
    }
}