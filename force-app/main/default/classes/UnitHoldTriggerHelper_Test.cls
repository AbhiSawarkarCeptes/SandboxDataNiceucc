@isTest
public class UnitHoldTriggerHelper_Test {
    @isTest 
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
          Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Id unitId = recordIdMap.get('UNIT');
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', DLD_Executive__c=UserInfo.getUserId(), Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Apartment').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true);
        insert prop;
        
        List<Unit_Hold__c> unitHoldList = new List<Unit_Hold__c>();
        unitHoldList.add(new Unit_Hold__c(Customer_Full_Name__c = 'Test Unit Hold',Sales_Manager__c =userinfo.getUserId() ,Sales_VP__c = userinfo.getUserId(),Request_Time__c = '1 Day',Unit_No__c = Id.valueOf(prop.Id),Unit_Hold_Requested__c = true,Status__c = 'Inactive',OwnerId = UserInfo.getUserId(), unit__c = unitId));
        unitHoldList.add(new Unit_Hold__c(Unit_Hold_Approval_Status__c = 'Approved', Customer_Full_Name__c = 'Test Unit Hold 2',Request_Time__c = '4 Hour',Sales_Manager__c =userinfo.getUserId() ,Sales_VP__c = userinfo.getUserId(),Unit_No__c = Id.valueOf(prop.Id),Unit_Hold_Requested__c = true,Status__c = 'Inactive',OwnerId = UserInfo.getUserId(), unit__c = unitId));
        insert unitHoldList;

/*        Map<id,Unit_Hold__c> oldMap = new Map<id,Unit_Hold__c>([select id,Unit_Hold_Approval_Status__c from Unit_Hold__c]);
        List<Unit_Hold__c> ulList = new List<Unit_Hold__c>([select id, Unit_Hold_Approval_Status__c from Unit_Hold__c order by Customer_Full_Name__c ]);
        List<Unit_Hold__c> newList = new List<Unit_Hold__c>();
        newList.add(new Unit_Hold__c(id= unitHoldList[0].id,Unit_Hold_Approval_Status__c ='Approved' ));
        UnitHoldTriggerHelper.statusFieldUpdate(newList, oldMap);
     */
        List<Unit_Hold__c> updateList = new List<Unit_Hold__c>();
        updateList.add(new Unit_Hold__c(id= unitHoldList[0].id,Unit_Hold_Approval_Status__c ='Approved' ));
        update updateList;
    }
}