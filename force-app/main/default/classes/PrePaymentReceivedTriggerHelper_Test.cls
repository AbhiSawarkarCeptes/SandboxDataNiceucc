/*********************************************************************
* Class Name  :   PrePaymentReceivedTriggerHelper_Test
* Description :   Test class for the PrePaymentReceivedTriggerHelper
* Created Date:   05/06/2022
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 05/06/2022
*********************************************************************/
@isTest
public class PrePaymentReceivedTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', T_link_Demand_Days__c = 10, Payment_Method_Single_Hold_Duration__c = 12.00, Payment_Method_Multiple_Hold_Duration__c = 10.00);
        insert proj;
        
         
        
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;

        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
            
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Single', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 11000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        pre.Approval_Status__c = 'Rejected';
        update pre;
    }
    
    @isTest
    static void testMethod2() {
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', T_link_Demand_Days__c = 10, Payment_Method_Single_Hold_Duration__c = 12.00, Payment_Method_Multiple_Hold_Duration__c = 10.00);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
            
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Multiple', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__PrePayment_Received__c pre1 = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 11000, PropStrength__Offer__c = offer.Id,PropStrength__Payment_Mode__c = 'CDM-Cheque');
        insert pre1;
        
        List<PropStrength__PrePayment_Received__c> updPrePay = new List<PropStrength__PrePayment_Received__c>();
        updPrePay.add(new PropStrength__PrePayment_Received__c(Id = pre.Id, Approval_Status__c = 'Approved', PropStrength__Payment_Mode__c = 'CDM-Cheque' ));
        updPrePay.add(new PropStrength__PrePayment_Received__c(Id = pre1.Id, Approval_Status__c = 'Approved'));
        update updPrePay;
    }
    
    @isTest
    static void testMethod3() {
       PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', T_link_Demand_Days__c = 10, Payment_Method_Single_Hold_Duration__c = 12.00, Payment_Method_Multiple_Hold_Duration__c = 10.00);
        insert proj;
        
         
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId(),Payment_Method_Multiple_Hold_Duration__c=10.0);
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,PropStrength__Tower__c = tower.id);
        insert prop;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Milestone__c mileSt = new PropStrength__Milestone__c(PropStrength__Actual_Completed_Date__c = System.Today(), PropStrength__Project__c = proj.Id, PropStrength__Milestone_Code__c = 'Test Mile', PropStrength__Active__c = true, PropStrength__Milestone_Name__c = 'Test - 123');
        insert mileSt;
        
        PropStrength__Payment_Plan_Line_Items__c ppli = new PropStrength__Payment_Plan_Line_Items__c(PropStrength__Amount_Percent__c = 10.00, PropStrength__Milestone__c = mileSt.Id, PropStrength__Order__c = 1, PropStrength__Due_After_Days__c = 10, PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Block_Demand_Generation__c = false, PropStrength__Payment_Plan_Line_Item_Code__c = 'Test', PropStrength__Payment_Plan_Line_Item_Name__c = 'Test PLI');
        insert ppli;
            
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Multiple', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id, Hold_Amount__c = 50);
        insert offer;
        
        PropStrength__PrePayment_Received__c pre = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 1000, PropStrength__Offer__c = offer.Id);
        insert pre;
        
        PropStrength__PrePayment_Received__c pre1 = new PropStrength__PrePayment_Received__c(PropStrength__Amount__c = 11000, PropStrength__Offer__c = offer.Id,PropStrength__Payment_Mode__c = 'CDM-Cheque');
        insert pre1;
        
        List<PropStrength__PrePayment_Received__c> updPrePay = new List<PropStrength__PrePayment_Received__c>();
        updPrePay.add(new PropStrength__PrePayment_Received__c(Id = pre.Id, Approval_Status__c = 'Approved', PropStrength__Payment_Mode__c = 'CDM-Cheque' ));
        updPrePay.add(new PropStrength__PrePayment_Received__c(Id = pre1.Id, Approval_Status__c = 'Approved'));
        update updPrePay;

    }
    
}