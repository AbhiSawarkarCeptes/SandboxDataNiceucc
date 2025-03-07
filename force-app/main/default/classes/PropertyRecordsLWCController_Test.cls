@isTest
public class PropertyRecordsLWCController_Test {
	@testSetup static void setup() {
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<PropStrength__Projects__c> projList = new List<PropStrength__Projects__c>();
        projList.add(new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form',DLD_Executive__c=UserInfo.getUserId(), Name = 'T1 Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1));
        projList.add(new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form 2', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project 2', PropStrength__Active__c = true, T_link_Demand_Days__c = 1));
        insert projList;
	
        List<PropStrength__Tower__c> towerList = new List<PropStrength__Tower__c>();
        towerList.add(new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  projList[0].Id, PropStrength__Tower_Code__c = 'A1'));
        towerList.add(new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P2 Tower', PropStrength__Project_Name__c =  projList[1].Id, PropStrength__Tower_Code__c = 'A2'));
		insert towerList;
        
        List<PropStrength__Property_Type__c> propTypeList = new List<PropStrength__Property_Type__c>();
        propTypeList.add(new PropStrength__Property_Type__c(PropStrength__Project__c = projList[0].Id, PropStrength__Active__c = true, PropStrength__Area__c = 500, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '2 BHK'));
        propTypeList.add(new PropStrength__Property_Type__c(PropStrength__Project__c = projList[0].Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BHK'));
        insert propTypeList;
        
        List<PropStrength__Floor__c> floorList = new List<PropStrength__Floor__c>();
        floorList.add(new PropStrength__Floor__c(PropStrength__Floor_Name__c = 'Ground',PropStrength__Floor_Code__c = 'A-Ground', PropStrength__Tower__c = towerList[0].Id, PropStrength__Active__c = true, PropStrength__Floor_Number__c = 0));
        floorList.add(new PropStrength__Floor__c(PropStrength__Floor_Name__c = '1st Floor',PropStrength__Floor_Code__c = 'A-1st Floor', PropStrength__Tower__c = towerList[0].Id, PropStrength__Active__c = true, PropStrength__Floor_Number__c = 1));
       	insert floorList;
        
        List<PropStrength__Property__c> propList = new List<PropStrength__Property__c>();
        propList.add(new PropStrength__Property__c(PropStrength__Property_Alloted_Through_Offer__c = false,PropStrength__Tower__c = towerList[0].Id, PropStrength__Floor__c =floorList[0].Id, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propTypeList[0].Id, PropStrength__Project_Name__c = projList[0].Id, PropStrength__Active__c = true));
        propList.add(new PropStrength__Property__c(PropStrength__Property_Alloted_Through_Offer__c = false, PropStrength__Tower__c = towerList[0].Id, PropStrength__Floor__c =floorList[1].Id, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propTypeList[1].Id, PropStrength__Project_Name__c = projList[0].Id, PropStrength__Active__c = true));
        insert propList;
    }
    @isTest
    public static void getProject(){
        List<PropStrength__Projects__c> projList = PropertyRecordsLWCController.searchProjectRecord('',null);
        System.AssertEquals(1,projList.size());
        List<PropStrength__Projects__c> projList1 = PropertyRecordsLWCController.searchProjectRecord('T1 Pr',null);
        System.AssertEquals(1,projList1.size());
    }
    @isTest
    public static void getTower(){
        List<PropStrength__Projects__c> projList = [SELECT Id FROM PropStrength__Projects__c WHERE Name = 'T1 Project'];
        System.AssertEquals(1,projList.size());
        List<PropStrength__Tower__c> towerList = PropertyRecordsLWCController.searchTowersRecord('',projList[0].Id);
        System.AssertEquals(1,towerList.size());
        List<PropStrength__Tower__c> towerList1 = PropertyRecordsLWCController.searchTowersRecord('T1 P1',projList[0].Id);
        System.AssertEquals(1,towerList1.size());
    }
    @isTest
    public static void getFloor(){
        List<PropStrength__Tower__c> tList = [SELECT Id FROM PropStrength__Tower__c WHERE PropStrength__Tower_Name__c = 'T1 P1 Tower'];
        System.AssertEquals(1,tList.size());
        List<PropStrength__Floor__c> floorList = PropertyRecordsLWCController.searchFloorRecord('',tList[0].Id);
        System.AssertEquals(2,floorList.size());
        List<PropStrength__Floor__c> floorList1 = PropertyRecordsLWCController.searchFloorRecord('Ground',tList[0].Id);
        System.AssertEquals(1,floorList1.size());
    }
    @isTest 
    public static void getProperty() {
        List<PropStrength__Projects__c> projList = [SELECT Id FROM PropStrength__Projects__c WHERE Name = 'T1 Project'];
       	List<PropStrength__Tower__c> tList = [SELECT Id FROM PropStrength__Tower__c WHERE PropStrength__Tower_Name__c = 'T1 P1 Tower'];
        List<PropStrength__Floor__c> floorList = [SELECT Id FROM PropStrength__Floor__c WHERE PropStrength__Floor_Name__c = 'Ground'];
        List<PropStrength__Property__c> ppList = PropertyRecordsLWCController.getPropertyList(projList[0].Id,tList[0].Id, '');
        List<PropStrength__Property__c> ppList1 = PropertyRecordsLWCController.getPropertyList(projList[0].Id,tList[0].Id, floorList[0].Id);
    }
    @isTest 
    public static void validateHoldProperty_Test() {
        List<PropStrength__Projects__c> projList = [SELECT Id FROM PropStrength__Projects__c WHERE Name = 'T1 Project'];
        List<String> str = new List<String>();
        str.add(projList[0].Id);
        
        Unit_Hold__c res = new Unit_Hold__c(Status__c = 'Active');
        //INSERT res;
            
        PropertyRecordsLWCController.validateHoldProperty(str);
        
		
    }
}