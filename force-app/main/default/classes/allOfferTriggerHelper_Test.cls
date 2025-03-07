/*********************************************************************
* Class Name  :   allOfferTriggerHelper_Test
* Description :   Test Class of allOfferTriggerHelper
* Created Date:   24/07/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 24/07/2023
*********************************************************************/
@isTest
public class allOfferTriggerHelper_Test {
	@isTest
    static void testMethod1() {
        PropStrength__Tax_Record__c tr = new PropStrength__Tax_Record__c(PropStrength__Tax_Type__c = 'VAT', PropStrength__Tax_Percentage_Aftr_limit__c = 15, PropStrength__Tax_Percentage__c = 15, PropStrength__Start_Date__c = System.Today(), PropStrength__PMAY_GST__c = 10, PropStrength__Abatement_Rate__c = 10, PropStrength__End_Date__c = System.Today().addDays(30), PropStrength__New_Tax_Percentage_After_Set_Limit__c = 10, PropStrength__New_Tax_Percentage__c = 10, PropStrength__New_PMAY_GST__c = 10);
        insert tr;
        
        PropStrength__Tax_Record__c tr1 = new PropStrength__Tax_Record__c(PropStrength__Tax_Type__c = 'VAT', PropStrength__Tax_Percentage_Aftr_limit__c = 15, PropStrength__Tax_Percentage__c = 15, PropStrength__Start_Date__c = System.Today(), PropStrength__PMAY_GST__c = 10, PropStrength__Abatement_Rate__c = 10, PropStrength__End_Date__c = System.Today().addDays(30), PropStrength__New_Tax_Percentage_After_Set_Limit__c = 10, PropStrength__New_Tax_Percentage__c = 10, PropStrength__New_PMAY_GST__c = 10);
        insert tr1;
        
        PropStrength__Tax_Record__c tr2 = new PropStrength__Tax_Record__c(PropStrength__Tax_Type__c = 'VAT', PropStrength__Tax_Percentage_Aftr_limit__c = 15, PropStrength__Tax_Percentage__c = 15, PropStrength__Start_Date__c = System.Today(), PropStrength__PMAY_GST__c = 10, PropStrength__Abatement_Rate__c = 10, PropStrength__End_Date__c = System.Today().addDays(30), PropStrength__New_Tax_Percentage_After_Set_Limit__c = 10, PropStrength__New_Tax_Percentage__c = 10, PropStrength__New_PMAY_GST__c = 10);
        insert tr2;
        
        PropStrength__Tax_Record__c tr3 = new PropStrength__Tax_Record__c(PropStrength__Tax_Type__c = 'VAT', PropStrength__Tax_Percentage_Aftr_limit__c = 15, PropStrength__Tax_Percentage__c = 15, PropStrength__Start_Date__c = System.Today(), PropStrength__PMAY_GST__c = 10, PropStrength__Abatement_Rate__c = 10, PropStrength__End_Date__c = System.Today().addDays(30), PropStrength__New_Tax_Percentage_After_Set_Limit__c = 10, PropStrength__New_Tax_Percentage__c = 10, PropStrength__New_PMAY_GST__c = 10);
        insert tr3;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Name = 'Test Project', PropStrength__Active__c = TRUE);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        PropStrength__Projects__c proj1 = new PropStrength__Projects__c(Name = 'Test Project1', PropStrength__Active__c = TRUE);
        insert proj1;
        
        PropStrength__Property_Type__c propType1 = new PropStrength__Property_Type__c(PropStrength__Project__c = proj1.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '4 BR Zazen');
        insert propType1;
        
        PropStrength__Property__c prop1 = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType1.Id, PropStrength__Project_Name__c = proj1.Id, PropStrength__Active__c = true);
        insert prop1;
        
        PropStrength__Projects__c proj2 = new PropStrength__Projects__c(Name = 'Test Project12', PropStrength__Active__c = TRUE);
        insert proj2;
        
        PropStrength__Property_Type__c propType2 = new PropStrength__Property_Type__c(PropStrength__Project__c = proj2.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '2 BR Zazen');
        insert propType2;
        
        PropStrength__Property__c prop2 = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType2.Id, PropStrength__Project_Name__c = proj2.Id, PropStrength__Active__c = true);
        insert prop2;
        
        PropStrength__Projects__c proj3 = new PropStrength__Projects__c(Name = 'Test Project123', PropStrength__Active__c = TRUE);
        insert proj3;
        
        PropStrength__Property_Type__c propType3 = new PropStrength__Property_Type__c(PropStrength__Project__c = proj3.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '1 BR Zazen');
        insert propType3;
        
        PropStrength__Property__c prop3 = new PropStrength__Property__c(RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType3.Id, PropStrength__Project_Name__c = proj3.Id, PropStrength__Active__c = true);
        insert prop3;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        acc.PropStrength__Broker_Type__c = 'Standard';
        acc.Broker_Sub_Type__c = 'Broker UAE';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test' + DateTime.now();
        cont.LastName = 'testKYCForm';
        cont.Email = 'test@test.com';
        insert cont;
        
        PropStrength__Payment_Plan__c ppd = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123', PropStrength__Active__c = true, Name = 'Test Plan');
        insert ppd;
        
        PropStrength__Payment_Plan__c ppd1 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj1.Id, PropStrength__Payment_Plan_Code__c ='Test Plan1234', PropStrength__Active__c = true, Name = 'Test Plan1');
        insert ppd1;
        
        PropStrength__Payment_Plan__c ppd2 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj2.Id, PropStrength__Payment_Plan_Code__c ='Test Plan12345', PropStrength__Active__c = true, Name = 'Test Plan12');
        insert ppd2;
        
        PropStrength__Payment_Plan__c ppd3 = new PropStrength__Payment_Plan__c(PropStrength__Project__c = proj3.Id, PropStrength__Payment_Plan_Code__c ='Test Plan123456', PropStrength__Active__c = true, Name = 'Test Plan123');
        insert ppd3;
        
        Marketing_Plan__c mp = new Marketing_Plan__c(Active__c = TRUE, Marketing_Plan_Cost__c = 1000000, Start_Date__c = System.Today().addDays(-2), End_Date__c = System.Today().addDays(60));
        insert mp;
        
        Marketing_Channel__c mc = new Marketing_Channel__c(Budget_Allotted__c = 100000, Marketing_Plan__c = mp.Id, Start_Date__c = System.Today(), End_Date__c = System.Today().addDays(30));
        insert mc;
        
        PropStrength__Advertisement__c advt = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__IsActive__c = true,PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000);
        insert advt;
        
        PropStrength__Advertisement__c advt1 = new PropStrength__Advertisement__c(PropStrength__End_Date__c = System.Today().addDays(28), PropStrength__IsActive__c = true,PropStrength__Start_Date__c = System.Today().addDays(1), Marketing_Channel__c = mc.Id, PropStrength__Budgeted_Cost__c = 1000);
        insert advt1;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = cont.Id;
        enq.PropStrength__Advertisement__c = advt.Id;
        insert enq;
        
        PropStrength__Request__c enq1  = new PropStrength__Request__c();
        enq1.PropStrength__Primary_Contact__c = cont.Id;
        enq1.PropStrength__Advertisement__c = advt1.Id;
        insert enq1;
        
        PropStrength__Offer__c off =  new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id);
        insert off;
        
        off.PropStrength__Request__c = enq1.Id;
        update off;
        
        List<PropStrength__Offer__c> offList = new List<PropStrength__Offer__c>();
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id));
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Offer_Through__c = 'Broker', PropStrength__Payment_Plan__c = ppd1.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj1.Id, PropStrength__Property__c = prop1.Id, PropStrength__Property_Type__c = propType1.Id, PropStrength__Primary_Contact__c = cont.Id, PropStrength__Broker_Contact__c = cont.Id));
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Offer_Through__c = 'Direct', PropStrength__Payment_Plan__c = ppd1.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true,  PropStrength__Project__c = proj1.Id, PropStrength__Property__c = prop1.Id, PropStrength__Property_Type__c = propType1.Id, PropStrength__Primary_Contact__c = cont.Id));
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Offer_Through__c = 'Broker', PropStrength__Payment_Plan__c = ppd.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = cont.Id, PropStrength__Broker_Contact__c = cont.Id));
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Offer_Through__c = 'Broker', PropStrength__Payment_Plan__c = ppd2.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj2.Id, PropStrength__Property__c = prop2.Id, PropStrength__Property_Type__c = propType2.Id, PropStrength__Primary_Contact__c = cont.Id, PropStrength__Broker_Contact__c = cont.Id));
        offList.add(new PropStrength__Offer__c(PropStrength__Request__c = enq.Id, PropStrength__Broker_Account__c = acc.Id, PropStrength__Offer_Through__c = 'Broker', PropStrength__Payment_Plan__c = ppd3.Id, PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj3.Id, PropStrength__Property__c = prop3.Id, PropStrength__Property_Type__c = propType3.Id, PropStrength__Primary_Contact__c = cont.Id, PropStrength__Broker_Contact__c = cont.Id));
        insert offList;
        
        delete off;
    }
}