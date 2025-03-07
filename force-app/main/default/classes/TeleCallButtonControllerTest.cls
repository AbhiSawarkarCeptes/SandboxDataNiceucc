@isTest public class TeleCallButtonControllerTest {
    @isTest public static void test1(){
        Lead l1 = new Lead();
        l1.lastname='Test1';
        l1.MobilePhone = '1234567891';
        l1.RDS_Country__c ='Test India';
        l1.Campaign_Code__c='Test Campaign';
        insert l1;
        TeleCallButtonController.getLeadMobileNumber(l1.Id);
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b;
        
        NPS_Survey__c npsSurvey = new NPS_Survey__c();
        npsSurvey.Object_Type__c = 'Lead';
        npsSurvey.Phone__c = '9999999999';
        npsSurvey.Record_Id__c = l1.Id;
        insert npsSurvey;
            
        TeleCallButtonController.getBookingMobileNumber(b.Id);
        TeleCallButtonController.getNPSSurveyMobileNumber(npsSurvey.Id);
        TeleCallButtonController.getNPSSurveyStatus(l1.Id);
        TeleCallButtonController.getNPSSurveyStatus(b.Id);
        TeleCallButtonController.getNPSSurveyStatus(recordIdMap.get('OPPORTUNITY'));
        TeleCallButtonController.updateNPSSurveyStatus(l1.Id,'');
        TeleCallButtonController.updateNPSSurveyStatus(b.Id,'');
        TeleCallButtonController.updateNPSSurveyStatus(recordIdMap.get('OPPORTUNITY'),'');
        TeleCallButtonController.getOppMobileNumber(recordIdMap.get('OPPORTUNITY'));
    }
    
    @isTest public static void test2(){
        Lead l1 = new Lead();
        l1.lastname='Test1';
        l1.MobilePhone = '1234567891';
        l1.RDS_Country__c ='Test India';
        l1.Campaign_Code__c='Test Campaign';
        l1.RDS_Country_Code__c = '+971';
        l1.Nationality__c = 'Indian';
        insert l1;
        
        NPS_Survey__c npsSurveyLead = new NPS_Survey__c();
        npsSurveyLead.Object_Type__c = 'Lead';
        npsSurveyLead.Phone__c = '9999999999';
        npsSurveyLead.Record_Id__c = l1.Id;
        insert npsSurveyLead;
        
        Lead insertedLead = [select Id,Lead_Id__c from Lead where Id=:l1.Id];
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Opportunity oppty = new Opportunity(Id=recordIdMap.get('OPPORTUNITY'),Lead_Id__c=insertedLead.Lead_Id__c);
        update oppty;
        
        NPS_Survey__c npsSurveyOppty = new NPS_Survey__c();
        npsSurveyOppty.Object_Type__c = 'Opportunity';
        npsSurveyOppty.Phone__c = '9999999999';
        npsSurveyOppty.Record_Id__c = oppty.Id;
        insert npsSurveyOppty;
        
        
        Id unitId = recordIdMap.get('UNIT');
        Id towerId = recordIdMap.get('TOWER');
        Id clusterId = recordIdMap.get('CLUSTER');
        
        Tower__c tower = [SELECT Id, Name, Cluster__c FROM Tower__c WHERE Id =:towerId];
        tower.Cluster__c = clusterId;
        update tower;
        
        Unit__c u = [Select Id, Name, Unit_Status__c FROM Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Booked';      
        update u;
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q;      
        
        Payment_Milestones__c pm = createPaymentMilestone(q.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        b.Sales_Manager__c = UserInfo.getUserId();
        b.Secondary_Sales_Manager__c = UserInfo.getUserId();
        b.Seller_representative__c = UserInfo.getUserId();
        b.Sales_Head__c = UserInfo.getUserId();
        b.Secondary_Sales_Head__c = UserInfo.getUserId();
        insert b;
        
        NPS_Survey__c npsSurveyBook = new NPS_Survey__c();
        npsSurveyBook.Object_Type__c = 'Booking';
        npsSurveyBook.Phone__c = '9999999999';
        npsSurveyBook.Record_Id__c = b.Id;
        insert npsSurveyBook;
        
        TeleCallButtonController.getTimezone(npsSurveyLead.Id);
        TeleCallButtonController.getTimezone(npsSurveyOppty.Id);
        TeleCallButtonController.getTimezone(npsSurveyBook.Id);
    }
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote) {        
        Payment_Milestones__c pm = new Payment_Milestones__c();
        pm.Time_Period__c = 'Days';
        pm.Number_Of_Days__c = 10;
        pm.Milestone_Due_Date__c = System.today().addDays(100);
        pm.Milestone_Type_edit__c = 'Date Linked';
        pm.Is_Combination_Milestone__c = false;
        pm.Quotation__c = quote;
        pm.Charge1Name__c = 'Basic';
        pm.Charge1Percentage__c = 5;
        pm.C1_Amount__c = 100000;          
        pm.C1_CGST__c = 12369;
        pm.C1_SGST__c = 0;
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';       
        insert pm;        
        return pm;
    }
}