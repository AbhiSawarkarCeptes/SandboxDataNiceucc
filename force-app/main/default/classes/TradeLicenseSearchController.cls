public class TradeLicenseSearchController {
    @AuraEnabled
    public static List<RecordWrapper> getRecordsData(String firstSearchKey) {
         List<RecordWrapper> wrapList = new List<RecordWrapper>();
        if(firstSearchKey == ''){
            return wrapList;
        }
       
        List<Channel_Partner__c> channelpartnerList = [SELECT Id,Name,Channel_Relationship_Manager__c,Channel_Relationship_Manager_Name__c,Channel_Relationship_Head__r.Name 
                                                       From Channel_Partner__c where 
                                                       Passport_No__c =: firstSearchKey OR RERA_Registration_No__c =: firstSearchKey];
        List<Sobha_Connect__c> sobhaConnectList = [SELECT Id,Name,Sales_Manager__r.Name,Sales_Head__r.Name From Sobha_Connect__c where Registration__c =: firstSearchKey];
        List<Broker_Registration__c> brokerList = [SELECT Id,Name,CHRM_Manager__r.Name,CHRM_ManagerHead__r.Name From Broker_Registration__c where RERA_Number__c =: firstSearchKey OR Registration_Number__c =: firstSearchKey];
        wrapList.add(new RecordWrapper(channelpartnerList, sobhaConnectList,brokerList));
        return wrapList;
        
    }
    public class RecordWrapper{
        @AuraEnabled public List<Channel_Partner__c> channelpartnerList{get;set;}
        @AuraEnabled public List<Sobha_Connect__c> sobhaConnectList{get;set;}
        @AuraEnabled public List<Broker_Registration__c> brokerList{get;set;}
        public RecordWrapper(List<Channel_Partner__c> channelpartnerList, List<Sobha_Connect__c> sobhaConnectList,List<Broker_Registration__c> brokerList){
            this.channelpartnerList = channelpartnerList;
            this.sobhaConnectList = sobhaConnectList;
            this.brokerList = brokerList;
        }
    }
}