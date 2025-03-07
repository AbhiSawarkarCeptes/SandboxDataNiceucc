public with sharing class CsoAnnouncementBoard {
         @AuraEnabled(Cacheable=true)
        public static List<CSO_Announcment__c> getAllActiveAnnouncements(Integer pageSize){
            List<CSO_Announcment__c> annList = new List<CSO_Announcment__c>();
            try {
                // Retrieve records from the last 7 days
                Date last7Days = Date.today().addDays(-7);
                annList = [SELECT Id, Name, Title__c, Active__c, CreatedDate, Notification__c 
                           FROM CSO_Announcment__c 
                           WHERE Active__c = true AND Valid_Till__c >= TODAY
                           ORDER BY CreatedDate DESC 
                           LIMIT :pageSize ];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return annList;
        }

        @AuraEnabled(Cacheable=true)
        public static List<CSOs_General_Instructions__c> getGeneralInstructions() {
            //List<CSOs_General_Instructions__c> instructions;
            List<CSOs_General_Instructions__c> gi= new List<CSOs_General_Instructions__c>();
            try {
             
                gi=[SELECT Id,Instruction__c,Sequence__c FROM CSOs_General_Instructions__c WHERE Active__c = true ORDER BY Sequence__c ASC];
                //instructions=gi'  
            } catch (Exception e) {
                
                System.debug('Exception: ' + e.getMessage());
            }
    
            return gi;
        }
}