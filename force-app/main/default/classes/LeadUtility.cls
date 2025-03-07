/*
*Class Name : LeadUtility
* Date : 17/3/2023
* Description : Utility class for lead mapping phone number and lead source
* 
*/
public with sharing class LeadUtility {  
    
    /////// Added by Aravind on 17/3/2023 Starts here     
    public static void fetchLeadSource(Lead leadCreated,Social_Media_Lead__c sml){
        List <Lead_Source__c> customLeadSource = new List <Lead_Source__c>();
        if(sml.Form_ID__c != Null){
            customLeadSource = [SELECT Lead__c, Sub_Source__c, UTM_Source__c, UTM_Medium__c, UTM_Campaign__c, UTM_Content__c, Channel_Cluster__c,UTM_Medium_Key__c,
                                Bid_type__c, Goal__c, Digital_Source__c, Adgroup__c, Banner_Size__c, Keyword__c, Placement__c, Ad_position__c,
                                Match_Type__c, Lead_Source_27__c, Last_Mile_Conversion__c, Device__c, OS__c, Resolution__c, Browser__c,
                                GCLID__c, Time_Spent_before_Form_Submit__c, IP_Address__c, Landing_Page_URL__c, Website_Language__c, Network__c,Project_Name__c,Country_Name__c,Project__c,Web_Source__c 
                                FROM Lead_Source__c WHERE UTM_Medium_Key__c = :sml.UTM_Medium_Key__c];
        }
        if(customLeadSource != null && customLeadSource.size() > 0){
            if(String.IsNotBlank(customLeadSource[0].Lead__c) && customLeadSource[0].Lead__c != null)
                leadCreated.LeadSource = customLeadSource[0].Lead__c;  
            if(String.IsNotBlank(customLeadSource[0].Sub_Source__c) && customLeadSource[0].Sub_Source__c != null)
                leadCreated.Lead_Sub_Source__c = customLeadSource[0].Sub_Source__c;
            
            if(String.IsNotBlank(customLeadSource[0].Adgroup__c) && customLeadSource[0].Adgroup__c != null)
                leadCreated.Adgroup__c = customLeadSource[0].Adgroup__c;
            if(String.IsNotBlank(customLeadSource[0].Goal__c) && customLeadSource[0].Goal__c != null)
                leadCreated.Goal__c = customLeadSource[0].Goal__c; 
            if(String.IsNotBlank(customLeadSource[0].Digital_Source__c) && customLeadSource[0].Digital_Source__c != null)
                leadCreated.Digital_Source__c = customLeadSource[0].Digital_Source__c; 
            if(String.IsNotBlank(customLeadSource[0].Channel_Cluster__c) && customLeadSource[0].Channel_Cluster__c != null)
                leadCreated.Channel_Cluster__c = customLeadSource[0].Channel_Cluster__c; 
            if(String.IsNotBlank(customLeadSource[0].Banner_Size__c) && customLeadSource[0].Banner_Size__c != null)
                leadCreated.Web_Banner_Size__c = customLeadSource[0].Banner_Size__c;               
            if(String.IsNotBlank(customLeadSource[0].Keyword__c) && customLeadSource[0].Keyword__c != null)
                leadCreated.Keyword__c = customLeadSource[0].Keyword__c;
            if(String.IsNotBlank(customLeadSource[0].Placement__c) && customLeadSource[0].Placement__c != null)
                leadCreated.Placement__c = customLeadSource[0].Placement__c;
            if(String.IsNotBlank(customLeadSource[0].Ad_position__c) && customLeadSource[0].Ad_position__c != null)
                leadCreated.Adposition__c = customLeadSource[0].Ad_position__c; 
            if(String.IsNotBlank(customLeadSource[0].Match_Type__c) && customLeadSource[0].Match_Type__c != null)
                leadCreated.Matchtype__c = customLeadSource[0].Match_Type__c; 
            //   if(String.IsNotBlank(customLeadSource[0].UTM_Source__c) && customLeadSource[0].UTM_Source__c != null)
            //     leadCreated.UTM_Source__c = customLeadSource[0].UTM_Source__c; 
            if(sml.Source__c == 'propertyfinder' || sml.Source__c == 'LinkedIn' || sml.Source__c == 'yallacompare'){
                leadCreated.UTM_Campaign__c = sml.Campaign_Name__c;
                leadCreated.Project_Name__c = sml.Campaign_Name__c;
            } else {
                if(String.IsNotBlank(customLeadSource[0].UTM_Campaign__c) && customLeadSource[0].UTM_Campaign__c != null)
                    leadCreated.UTM_Campaign__c = customLeadSource[0].UTM_Campaign__c;
                // leadCreated.Project_Name__c = customLeadSource[0].UTM_Campaign__c;
            }
            if(String.IsNotBlank(customLeadSource[0].UTM_Medium__c) && customLeadSource[0].UTM_Medium__c != null)
                leadCreated.UTM_Medium__c = customLeadSource[0].UTM_Medium__c;            
            if(String.IsNotBlank(customLeadSource[0].UTM_Content__c) && customLeadSource[0].UTM_Content__c != null)
                leadCreated.UTM_Content__c = customLeadSource[0].UTM_Content__c;
            if(String.IsNotBlank(customLeadSource[0].Lead_Source_27__c) && customLeadSource[0].Lead_Source_27__c != null)
                leadCreated.Lead_Source__c = customLeadSource[0].Lead_Source_27__c; 
            if(String.IsNotBlank(customLeadSource[0].Last_Mile_Conversion__c) && customLeadSource[0].Last_Mile_Conversion__c != null)
                leadCreated.Last_Mile_Conversion__c = customLeadSource[0].Last_Mile_Conversion__c; 
            if(String.IsNotBlank(customLeadSource[0].Device__c) && customLeadSource[0].Device__c != null)
                leadCreated.Device__c = customLeadSource[0].Device__c; 
            if(String.IsNotBlank(customLeadSource[0].OS__c) && customLeadSource[0].OS__c != null)
                leadCreated.OS__c = customLeadSource[0].OS__c;        
            if(String.IsNotBlank(customLeadSource[0].Resolution__c) && customLeadSource[0].Resolution__c != null)
                leadCreated.Resolution__c = customLeadSource[0].Resolution__c; 
            if(String.IsNotBlank(customLeadSource[0].Browser__c) && customLeadSource[0].Browser__c != null)
                leadCreated.Browser__c = customLeadSource[0].Browser__c; 
            if(String.IsNotBlank(customLeadSource[0].GCLID__c) && customLeadSource[0].GCLID__c != null)
                leadCreated.GCLID__c = customLeadSource[0].GCLID__c;            
            if(String.IsNotBlank(customLeadSource[0].Time_Spent_before_Form_Submit__c) && customLeadSource[0].Time_Spent_before_Form_Submit__c != null)
                leadCreated.Time_Spent_before_Form_Submit__c = customLeadSource[0].Time_Spent_before_Form_Submit__c;
            if(String.IsNotBlank(customLeadSource[0].IP_Address__c) && customLeadSource[0].IP_Address__c != null)
                leadCreated.IP_Address_Web2Lead__c = customLeadSource[0].IP_Address__c;
            if(String.IsNotBlank(customLeadSource[0].Landing_Page_URL__c) && customLeadSource[0].Landing_Page_URL__c != null)
                leadCreated.Landing_Page_URL__c = customLeadSource[0].Landing_Page_URL__c;   
            if(String.IsNotBlank(customLeadSource[0].Bid_Type__c) && customLeadSource[0].Bid_Type__c != null)
                leadCreated.Bid_Type__c = customLeadSource[0].Bid_Type__c; 
            if(String.IsNotBlank(customLeadSource[0].Network__c) && customLeadSource[0].Network__c != null)
                leadCreated.network__c = customLeadSource[0].Network__c;
            if(String.IsNotBlank(customLeadSource[0].Project__c) && customLeadSource[0].Project__c != null)
                leadCreated.Project__c = customLeadSource[0].Project__c;
            if(String.IsNotBlank(customLeadSource[0].Project_Name__c) && customLeadSource[0].Project_Name__c != null)
                leadCreated.Project_Name__c = customLeadSource[0].Project_Name__c;
            if(String.IsNotBlank(customLeadSource[0].Country_Name__c) && customLeadSource[0].Country_Name__c != null)
                leadCreated.social_Media_Country__c = customLeadSource[0].Country_Name__c;
            if(String.IsNotBlank(customLeadSource[0].Web_Source__c) && customLeadSource[0].Web_Source__c != null)
                leadCreated.Web_Source__c = customLeadSource[0].Web_Source__c;
        }
        
    }
    
    /*public static void formatPhone(Lead leadCreated,Social_Media_Lead__c sml) {
    sml.Phone_Number__c.replaceAll('\\s+', '');
    String regex = '[^0-9]';
    String formattedPhone = sml.Phone_Number__c.replaceAll(regex,'');
    System.debug('formatted phone:' + formattedPhone);
    fetchCountryInformation(leadCreated,formattedPhone);
    } */
    
    public static void formatPhone2(Lead leadCreated,Social_Media_Lead__c sml) {
        if(sml.Phone_Number__c != null)
            sml.Phone_Number__c.replaceAll('\\s+', '');
        String regex = '[^0-9]';
        String formattedPhone = '';
        if(sml.Phone_Number__c != null)
            formattedPhone = sml.Phone_Number__c.replaceAll(regex,'');
        System.debug('formatted phone:' + formattedPhone.length());
        fetchCountryInformation(leadCreated,formattedPhone,sml);
    }
    
    public static String fetchCountryInformation(Lead leadCreated,String formattedPhone,Social_Media_Lead__c sml){
        // for india, usa, uk the number of digits in phone # is 10. So if the length is greater than 10
        // then take the last 10 as mobile and whatever is remaining in the first digits after stripping off
        // the 10 digits are taken as countryCode. Then we compare them with potential country code formats that we know of
        // for US, UK,  India and then set the country accordingly.
        
        list<CountryCodeInfo__mdt> countryCodeInfomdt = new List<CountryCodeInfo__mdt>();
        String mobileNumber, countryCode, country;  
        if(sml.Country_Code__c != null && sml.Country_Code__c.length() <= 4) {
            countryCodeInfomdt = [SELECT AlphaCode__c,CountryCodeInfo__c,
                                  CountryName__c
                                  FROM CountryCodeInfo__mdt 
                                  WHERE CountryCodeInfo__c =:sml.Country_Code__c  LIMIT 1];
        }else if(sml.Country__c != null) {//Added by mohit as part of sob-663
            countryCodeInfomdt = [SELECT AlphaCode__c,CountryCodeInfo__c,
                                  CountryName__c
                                  FROM CountryCodeInfo__mdt 
                                  WHERE CountryName__c  =:sml.Country__c  LIMIT 1];
        }
        if(countryCodeInfomdt.size() > 0){   
            leadCreated.RDS_Country__c = countryCodeInfomdt[0].CountryName__c;
            leadCreated.RDS_Country_Code__c = '+' + countryCodeInfomdt[0].CountryCodeInfo__c;
            //leadCreated.mobilePhone = formattedPhone;//.subString(countryCodeInfomdt[0].CountryCodeInfo__c.length(),formattedPhone.length());
            System.debug('leadCreatedcountryMobile : '+leadCreated.RDS_Country__c + '////' + leadCreated.mobilePhone);
            
        } 
        System.debug('leadCreated : '+leadCreated);
        
        return country+':'+countryCode+':'+mobileNumber;
    }
    
    //Update Lead Hash Fields with the SHA value
    public static void updateLeadAttributionHashFields(list<Lead> leadNewList, map<Id,Lead> leadOldMap, boolean isUpdate){
        map<string,string> fieldMapping = new map<string,string>();
        list<Lead_Attribution_Modelling__mdt> mappingList = [Select Lead_Source_Field__c,Lead_Hash_Field__c from Lead_Attribution_Modelling__mdt];
        for(Lead_Attribution_Modelling__mdt mapping : mappingList){
            if(mapping.Lead_Source_Field__c!=null && mapping.Lead_Hash_Field__c!=null){
                fieldMapping.put(mapping.Lead_Source_Field__c,mapping.Lead_Hash_Field__c);
            }
        }
        if(fieldMapping.size()>0){
            set<string> attributionFieldList = fieldMapping.keySet();
            for(Lead l : leadNewList){
                Lead oldLead;
                if(isUpdate)
                	oldLead = leadOldMap.get(l.Id);
                
                for(string aField : attributionFieldList){
                    aField = aField.trim();
                    if(l.get(aField) != null && (!isUpdate || (isUpdate && l.get(aField) != oldLead.get(aField)))){
                        l.put(fieldMapping.get(aField),LeadUtility.getSha256(string.valueOf(l.get(aField))));
                    }
                }
            }
        }
    }
    
    public static String getSha256(String input)
    {        
        Blob hash = Crypto.generateDigest('SHA-256', BLOB.valueOf(input));
        
        String encryptedString =EncodingUtil.convertToHex(hash);
        
        System.debug('encryptedString : '+encryptedString);
        return encryptedString;
    }
    
    
}