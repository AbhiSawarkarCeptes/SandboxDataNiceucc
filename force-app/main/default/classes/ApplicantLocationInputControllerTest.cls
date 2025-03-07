@IsTest
private class ApplicantLocationInputControllerTest {
    @TestSetup
    static void setup() {
        // Create test data for Country_City_State_Mapping__c
        List<Country_City_State_Mapping__c> mappingRecords = new List<Country_City_State_Mapping__c>();
        mappingRecords.add(new Country_City_State_Mapping__c(Country__c = 'USA', State__c = 'California', City__c = 'Los Angeles'));
        mappingRecords.add(new Country_City_State_Mapping__c(Country__c = 'USA', State__c = 'California', City__c = 'San Francisco'));
        mappingRecords.add(new Country_City_State_Mapping__c(Country__c = 'USA', State__c = 'New York', City__c = 'New York City'));

       insert mappingRecords;
    }

    @IsTest
    static void testGetCountryList() {
        // Test getCountryList method
        Test.startTest();
        List<ApplicantLocationInputController.pickListWrapper> countryList = ApplicantLocationInputController.getCountryList();
        Test.stopTest();
        
        // Check that the country list is not empty
        System.assertNotEquals(0, countryList.size(), 'Country list should not be empty');
       
    }

    @IsTest
    static void testGetStates() {
        // Test getStates method for USA
        Test.startTest();
        List<ApplicantLocationInputController.pickListWrapper> stateList = ApplicantLocationInputController.getStates('USA');
        Test.stopTest();
        
        // Check that the state list is not empty
        System.assertNotEquals(0, stateList.size(), 'State list should not be empty');
        
        // Check that the state list contains expected states
        Set<String> expectedStates = new Set<String>{'California', 'New York'};
        for (ApplicantLocationInputController.pickListWrapper state : stateList) {
            System.assert(expectedStates.contains(state.value), 'State list should contain ' + state.value);
        }
    }

    @IsTest
    static void testGetCities() {
        // Test getCities() 
        Test.startTest();
        List<ApplicantLocationInputController.pickListWrapper> cityList = ApplicantLocationInputController.getCities('California');
        Test.stopTest();
        
        // Check that the city list is not empty
        System.assertNotEquals(0, cityList.size(), 'City list should not be empty');
        
        // Check that the city list contains expected cities
        Set<String> expectedCities = new Set<String>{'Los Angeles', 'San Francisco'};
        for (ApplicantLocationInputController.pickListWrapper city : cityList) {
            System.assert(expectedCities.contains(city.value), 'City list should contain ' + city.value);
        }
    }
}