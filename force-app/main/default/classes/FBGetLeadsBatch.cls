global class FBGetLeadsBatch implements Database.Batchable <sObject>,Database.AllowsCallouts {
    Public String Query; 
    //test commit new 
    
    public FBGetLeadsBatch() {
        Query = 'Select WeChat_ID__c,AdSet_Id__c,Ad_ID__c,Mobile_Number__c,Ad_Name__c,AdSet_Name__c,First_Name__c,Language__c,Last_Name__c,UTM_Medium_Key__c,Campaign_Id__c,Campaign_Name__c,Country__c,CreatedById,CreatedDate,Custom_Disclaimer_Responses__c,Disclaimer__c,Email__c,Formatted_Phone__c,Form_Data__c,Form_ID__c,Form_Name__c,Full_Name__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lead_Created_Time__c,Lead_ID__c,Name,OwnerId,Page_ID__c,Page_Name__c,Partner_Name__c,Phone_Number__c,Platform_ig__c,Processed__c,Raw_Country__c,Raw_Email__c,Raw_FullName__c,Raw_PhoneNumber__c,Remarks__c,Result__c,Retailer_Item_ID__c,SF_Account__c,SF_Lead__c,Source__c,SystemModstamp,Vehicle__c,Country_Code__c,When_are_you_looking_to_buy__c,Would_you_like_to_invest_in_Dubai__c ,Select_call_back_time__c,Looking_for__c,Budgett__c,Mobile_Number_No_Country_Code__c,Recording_URL__c from Social_media_lead__c where processed__c = false and isDeleted= false ';
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext info, List<Social_Media_Lead__c> scope){
           //SocialMediaLeadServices.getFBleads(scope);a
           SocialMediaLeadServices.PrepareLeadfromSML(scope);
    }
    
    global void finish(Database.BatchableContext info){     
    }   
}