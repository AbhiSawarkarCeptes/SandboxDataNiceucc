public class ApplicantLocationInputController {

  /*@AuraEnabled(Cacheable = true)
    public static List<Applicant_Details__c> getCurrentValues( String recordId) {
        return[SELECT Id,Country__c,City__c, State__c 
               FROM Applicant_Details__c 
              WHERE Id = :recordId];
    }*/
    
    @AuraEnabled(Cacheable = true)
    public static List<pickListWrapper> getCountryList() {
        List<pickListWrapper> countryWrapList = new List<pickListWrapper>();
        // Describe the Account.Industry field
        Schema.DescribeFieldResult fieldDescription = Applicant_Details__c.Country__c.getDescribe();
        // Get picklist values from field description
        List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
        // Do something with entries
        for (Schema.PicklistEntry entry : entries) {
            if(entry.isActive()) {
                pickListWrapper countryWrap = new pickListWrapper();
                countryWrap.label = entry.getLabel();
                countryWrap.value = entry.getValue();
                countryWrapList.add(countryWrap);
            }
        }
        return countryWrapList;
    }
    
    @AuraEnabled(Cacheable = true)
    public Static List<pickListWrapper> getStates(String country) {
        List<pickListWrapper> stateWrapList = new List<pickListWrapper>();
        Set<String> addedCities = new Set<String>();
        List<Country_City_State_Mapping__c> countryRelatedStateList = [SELECT ID,Country__c, State__c,City__c 
                                                                       FROM Country_City_State_Mapping__c
                                                                       WHERE Country__c =:country];
        if(!countryRelatedStateList.isEmpty()) {
            for(Country_City_State_Mapping__c countryStateMap : countryRelatedStateList) {
                if(!addedCities.contains(countryStateMap.State__c)) {
                    pickListWrapper stateWrap = new pickListWrapper();
                    stateWrap.label = countryStateMap.State__c;
                    stateWrap.value = countryStateMap.State__c;
                    stateWrapList.add(stateWrap);
                    addedCities.add(countryStateMap.State__c);
                }
            }
        }
        system.debug(stateWrapList);
        return stateWrapList;
    }
    
    @AuraEnabled(Cacheable = true)
    public Static List<pickListWrapper> getCities(String state) {
        List<pickListWrapper> cityWrapList = new List<pickListWrapper>();
        Set<String> addedCities = new Set<String>();
        List<Country_City_State_Mapping__c> countryRelatedStateList = [SELECT ID,Country__c, State__c,City__c 
                                                                       FROM Country_City_State_Mapping__c
                                                                       WHERE State__c =:state];
        if(!countryRelatedStateList.isEmpty()) {
            for(Country_City_State_Mapping__c countryCityMap : countryRelatedStateList) {
                if(!addedCities.contains(countryCityMap.City__c)) {
                    pickListWrapper cityWrap = new pickListWrapper();
                    cityWrap.label = countryCityMap.City__c;
                    cityWrap.value = countryCityMap.City__c;
                    cityWrapList.add(cityWrap);
                    addedCities.add(countryCityMap.City__c);
                }
            }
        }
        system.debug(cityWrapList);
        return cityWrapList;
    }

    Public class pickListWrapper {
        @AuraEnabled
        Public String label{get;set;}
        @AuraEnabled
        Public String value{get;set;}
    }
}