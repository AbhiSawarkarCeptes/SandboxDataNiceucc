@isTest
public class TestUnitTriggerHandler {

    @isTest
    static void testSendToMobileAPI() {
        
        Mobile_TestUtil.createBooking();
        
        Map<Id,Unit__c> unitsMap = new Map<Id,Unit__c>();
        Unit__c u = [Select id,Permitted_Use__c ,Parking_Bay_Allocation_No__c ,RERA_Chargeable_Area_Sq_Ft__c,Plot_Area__c,Chargeable_Area__c ,Car_Park_Count_1__c,Car_Park_Type_1__c ,Project_Property_Type__c,name,Floor_No_to_print__c,Unit_Type__c,No_of_Bedroom__c,Puchase_Price__c,DLD_Building_Number__c From Unit__c limit 1];
        unitsMap.put(u.id,u); 
        
        List<Unit__c> updatedUnits = new List<Unit__c>();
        u.name = 'UnitChanged';
        u.Floor_No_to_print__c = 'flr';
        u.Unit_Type__c  = 'Villa';
        u.Puchase_Price__c = 1234567;
        u.No_of_Bedroom__c = '3';
        u.Not_Available_for_Sales__c = true;
      //  u.DLD_Building_Number__c = '12345';
        u.Permitted_Use__c = 'Residential';
        u.Project_Property_Type__c = 'Residential';
        u.Car_Park_Count_1__c = 1;
        u.Car_Park_Type_1__c  = 'Open';
        u.Chargeable_Area__c = 1323.12;
        u.Plot_Area__c = 2343.34;
        u.RERA_Chargeable_Area_Sq_Ft__c = 1234.12;
        u.Parking_Bay_Allocation_No__c = '23423';
        update u;
        
        Unit__c uUpdated = [Select id,name,Permitted_Use__c ,Parking_Bay_Allocation_No__c ,RERA_Chargeable_Area_Sq_Ft__c,Plot_Area__c,Chargeable_Area__c ,Car_Park_Count_1__c,Car_Park_Type_1__c ,Project_Property_Type__c,Floor_No_to_print__c,Unit_Type__c,No_of_Bedroom__c,Puchase_Price__c,DLD_Building_Number__c From Unit__c where id=:u.id];
		List<Unit__c> updatedList = new List<Unit__c>();
        updatedList.add(uUpdated);
        // Serialize newUnitList to JSON
        String newUnitString = JSON.serialize(updatedList);

        // Call the future method
        Test.startTest();
        UnitTriggerHandler.sendToMobileAPI(newUnitString, JSON.serialize(unitsMap));
        UnitTriggerHandler.sendToMobileAPI(newUnitString, null);
        Test.stopTest();
    }
    
    @isTest
    static void testSendToMobileAPI2() {
        
        Mobile_TestUtil.createBooking();
        
        Map<Id,Unit__c> unitsMap = new Map<Id,Unit__c>();
        Unit__c u = [Select id,Permitted_Use__c ,Parking_Bay_Allocation_No__c ,RERA_Chargeable_Area_Sq_Ft__c,Plot_Area__c,Chargeable_Area__c ,Car_Park_Count_1__c,Car_Park_Type_1__c ,Project_Property_Type__c,name,Floor_No_to_print__c,Unit_Type__c,No_of_Bedroom__c,Puchase_Price__c,DLD_Building_Number__c From Unit__c limit 1];
        unitsMap.put(u.id,u); 
        String oldMapString = JSON.serialize(unitsMap);
        
        List<Unit__c> updatedUnits = new List<Unit__c>();
        u.name = 'UnitChanged';
        u.Floor_No_to_print__c = 'flr';
        u.Unit_Type__c  = 'Villa';
        u.Puchase_Price__c = 1234567;
        u.No_of_Bedroom__c = '3';
        u.Not_Available_for_Sales__c = true;
       // u.DLD_Building_Number__c = '12345';
        u.Permitted_Use__c = 'Residential';
        u.Project_Property_Type__c = 'Residential';
        u.Car_Park_Count_1__c = 1;
        u.Car_Park_Type_1__c  = 'Open';
        u.Chargeable_Area__c = 1323.12;
        u.Plot_Area__c = 2343.34;
        u.RERA_Chargeable_Area_Sq_Ft__c = 1234.12;
        u.Parking_Bay_Allocation_No__c = '23423';
        update u;
        
        Unit__c uUpdated = [Select id,name,Permitted_Use__c ,Parking_Bay_Allocation_No__c ,RERA_Chargeable_Area_Sq_Ft__c,Plot_Area__c,Chargeable_Area__c ,Car_Park_Count_1__c,Car_Park_Type_1__c ,Project_Property_Type__c,Floor_No_to_print__c,Unit_Type__c,No_of_Bedroom__c,Puchase_Price__c,DLD_Building_Number__c From Unit__c where id=:u.id];
		List<Unit__c> updatedList = new List<Unit__c>();
        updatedList.add(uUpdated);
        // Serialize newUnitList to JSON
        String newUnitString = JSON.serialize(updatedList);

        // Call the future method
        Test.startTest();
        UnitTriggerHandler.sendToMobileAPI(newUnitString, oldMapString);
        Test.stopTest();
    }
}