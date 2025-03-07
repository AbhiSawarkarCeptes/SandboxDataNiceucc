/* DESIGNED ONLY FOR BATCH SIZE 1 */
//Test Class - PSM_ERF_Broker_Batch_Test
global class PSM_ERF_Broker_Batch implements Database.Batchable<sObject>, Database.Stateful {

    public static String CLASS_NAME = 'PSM_ERF_Broker_Batch';
    private List<Id> recordIds;
    private String queryParam;
    
    // Constructor to accept record IDs
    public PSM_ERF_Broker_Batch() {
    }

    // Constructor to accept record IDs
    public PSM_ERF_Broker_Batch(List<Id> ids) {
        this.recordIds = ids;
    }
    
    // Constructor to accept query as param
    public PSM_ERF_Broker_Batch(String qParam) {
        this.queryParam = qParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String query = 'SELECT Id, name,Channel_Partner__c, Sobha_Connect__c,Broker_Account__c from events__c where Broker_Account__c = null';
        //return Database.getQueryLocator(query);
        
        String query;
        
        if (recordIds != null && !recordIds.isEmpty()) {
            // Filter based on provided record IDs
            query = 'SELECT Id, Name, Channel_Partner__c, Sobha_Connect__c, Broker_Account__c ' +
                    'FROM Events__c ' +
                    'WHERE Id IN :recordIds';
        } else if(String.isNotEmpty(queryParam)){
            query = queryParam;
        } else {
            // Default behavior if no IDs are provided
            query = 'SELECT Id, Name, Channel_Partner__c, Sobha_Connect__c, Broker_Account__c ' +
                    'FROM Events__c ' +
                    'WHERE Broker_Account__c = NULL';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Events__c> scope) {
        
        Map<String, String> brmAccountMap = new Map<String, String>();
        Map<String, String> brmBrokerMap = new Map<String, String>();
        List<String> scIdsToSearchInBR = new List<String>();
        List<String> cpIdsToSearchInBR = new List<String>();
        
        Map<String, String> brBrokerMap = new Map<String, String>();
        
        String eventId = scope[0].Id;
        
        /* Iterate through Events */
        for(Events__c event : scope) {
            if(event.channel_partner__c == null && event.Sobha_Connect__c == null) {
                continue;
            }
            if(event.channel_partner__C != null) {
                brmBrokerMap.put(event.Id, event.channel_partner__c);
                cpIdsToSearchInBR.add(event.channel_partner__c);
            }
            else {
                brmBrokerMap.put(event.Id, event.Sobha_Connect__c);
                scIdsToSearchInBR.add(event.Sobha_Connect__c);
            }
        }
        
        System.debug('brmAccountMap' + brmAccountMap);
        System.debug('brmBrokerMap' + brmBrokerMap);
        System.debug('cpIdsToSearchInBR' + cpIdsToSearchInBR);
        System.debug('scIdsToSearchInBR' + scIdsToSearchInBR );

        
        List<Broker_Registration__c> brokerRegistrations = [SELECT Id,SCID__c,CPID__c from Broker_Registration__c WHERE SCID__c IN :scIdsToSearchInBR OR CPID__c IN :cpIdsToSearchInBR];
        List<String> brIds = new List<String>();
        
        System.debug('brIds' + brokerRegistrations);
        for(Broker_Registration__c br: brokerRegistrations ) {
            if(br.cpid__c != null) {
                brBrokerMap.put(br.cpid__c, br.id);
            }
            else {
                brBrokerMap.put(br.scid__c, br.id);
            }
            brIds.add(br.id);

        }
        
        List<Account> psAccounts = [SELECT Id, name, Legacy_Broker_Id__c from account where recordtype.name = 'broker' and (Legacy_Broker_Id__c  IN :brIds OR Legacy_Broker_Id__c  IN:cpIdsToSearchInBR OR Legacy_Broker_Id__c  IN :scIdsToSearchInBR)];
        system.debug('FRUIT1' + psAccounts);
        
        if(psAccounts.size() > 0) {
            Events__c event = new Events__c(id = eventId);
            event.Broker_Account__c = psAccounts[0].Id;
            Database.SaveResult[] srList = Database.update(new List<Events__c>{event}, false);
            trackDML(CLASS_NAME, srList);
        }
        
        
    }   

    global void finish(Database.BatchableContext BC) {
    }
    
    public static void trackDML(String className, Database.SaveResult[] srList) {
        List<Error_log__c> allErrorList = new List<Error_log__c>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted record. Record ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors 
                String errorsCombined = '';               
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Object fields that affected this error: ' + err.getFields());
                    errorsCombined += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                }
                
                Error_Log__c trackRec = new Error_Log__c(Class__c = className, Message__c = errorsCombined );
                allErrorList.add(trackRec);
            }
        }
        if(allErrorList.size() > 0) {
            Database.insert(allErrorList, false);
        }
    }
}