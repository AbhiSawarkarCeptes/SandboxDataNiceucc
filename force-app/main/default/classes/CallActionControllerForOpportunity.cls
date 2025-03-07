global class CallActionControllerForOpportunity {
    
    public String recordId {get;set;}
    
    public CallActionControllerForOpportunity(ApexPages.StandardController controller){  
        recordId = controller.getId();
    }
    public CallActionControllerForOpportunity(){  
    }
    
    @AuraEnabled
    @RemoteAction
    global static Map<String,String> getPhoneFields(String recordId) {
    

        system.debug('inside getphoneFields method'+recordId);
        List<Pair> lstfieldname = new List <Pair>();
        String queryFields;
        String sObjectName;
        Map<String,String> resultsMap = new Map<String,String>();
        // sObject types to describe
        String[] types = new String[]{'Opportunity'};
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        System.debug('Got describe information for ' + results.size() + ' sObjects.');
        // For each returned result, get some info
        for(Schema.DescribeSobjectResult res : results) {
            System.debug('sObject Label: ' + res.getLabel());
            sObjectname = res.getName();
            System.debug('Number of fields: ' + res.fields.getMap().size());
            System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            System.debug('Fields Map:' + res.fields.getMap());
            Map<String, Schema.SObjectField> fieldMap = res.fields.getMap();
            queryFields = 'Select ';
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                Pair field = new Pair();
                //String fieldType = dfield.getType().name();
                String fieldLabel = dfield.getLabel();
                
                /*  if(fieldLabel.equalsIgnoreCase('Account Mobile Number') || fieldLabel.equalsIgnoreCase('Phone') || fieldLabel.equalsIgnoreCase('Primary Phone')) */
                if( fieldLabel.equalsIgnoreCase('Account Mobile 1') || fieldLabel.equalsIgnoreCase('Account Mobile 2')) {
                    field.key = dfield.getname();
                    field.val = dfield.getLabel ();
                    queryFields += dField.getName() + ',';
                    lstfieldname.add(field);
                }                
            }            
        }
        if(queryFields.length() > 0 && queryFields.substring(queryFields.length() -1).equals(','))
            queryFields = queryFields.substring(0,queryFields.length() -1);
        String query = queryFields + ' FROM ' + sObjectName + ' where Id = :recordId';
        System.debug('List Field Names:' + lstFieldName);
        System.debug ('Query :' + query);
        List<sObject> sobjList = Database.query(query);
        System.debug('results: ' + sobjList[0]);
        for(Pair p : lstFieldName) {
            if(sObjList[0].get(p.key) != null) {
                System.debug('Field Name:' + p.val + '==>' + sObjList[0].get(p.key));
                String mobile = string.valueOf(sObjList[0].get(p.key));
          //      resultsMap.put(mobile.replace(mobile.substring(0,5),'XXXXX'), string.valueOf(sObjList[0].get(p.key)));
                resultsMap.put(mobile, string.valueOf(sObjList[0].get(p.key)));
            
                
            }
        }
        return resultsMap;
        
        
     //   click2CallCloudagent(recordId,mobile); 
    }
    
    @AuraEnabled
    @RemoteAction
    global static String click2CallCloudagent (String recordId) {
    /*
    List<Account> acclist = New List<Account>();
    List<Opportunity> opplist = New List<Opportunity>();
    opplist = [Select Id, Name, Account_Mobile_Number__c from Opportunity where Id = :recordId];
    String customerPh = opplist[0].Account_Mobile_Number__c;    
    */
    String customerPh='';
        system.debug('In click2CallCloudagent method @@');
        String campaignName = '';
        String userName = '';
        String apiKey = '';
        String agentId = '';
        
        List<User> uList = [Select Id, OzoneTel_AgentId__c, /*OzoneTel_Username__c replaced by */customer__c, campaign_name__c, api_key__c From User Where Id = :UserInfo.getUserId()];
        
        if(uList != null && !uList.isEmpty() ) {
            campaignName = uList[0].campaign_name__c;
            agentID = uList[0].OzoneTel_AgentId__c;
            apiKey = uList[0].api_key__c;
            userName = uList[0].customer__c;
        }
            System.debug('Incoming Number:' + customerPh);
          List<Opportunity> opty1 = [select Id, AccountId, Account_Mobile_Number__c  from Opportunity where Id =: recordId];
          List<Account> acct1 = [select Id, Country_Code__c, Country__c from Account where Id =: opty1[0].AccountId];
          customerPh =opty1[0].Account_Mobile_Number__c ;
          
        if(acct1[0].Country__c == 'United Arab Emirates' ){
       // && customerPh.length() >= 11 && (customerPh.startsWith('+971') || customerPh.startsWith('971') || customerPh.startsWith('00971') || customerPh.startsWith('0971') || customerPh.startsWith('0'))) { 
            system.debug('Inside UAE');
            // if more than 10 digits are being passed, strip of the leading character, keep the last 10 and add 0 to it
         //   customerPh = customerPh.substring(customerPh.length() -9);
            system.debug('Inside United Arab Emirates');
            // if more than 10 digits are being passed, strip of the leading character, keep the last 10 and add 0 to it
           // customerPh = customerPh.substring(customerPh.length() - 10);
            system.debug('customerPh>>>>'+customerPh);
           
            customerPh = '0'+customerPh;
            system.debug('customerPh>>>>'+customerPh);
         
            //customerPh = '0' + customerPh;
            System.debug('Customer Phone:' + customerPh);
            //customerPh = '0' + customerPh;
            System.debug('Customer Phone:' + customerPh);
        }
        
        else{
            List<User> userList = [Select Id, Enable_International_Calling__c From User Where Id = :UserInfo.getUserId()];
            if(userList != null && userList.size() > 0){
                User usrRec = userList.get(0);
                if(usrRec.Enable_International_Calling__c){ 
                    System.debug('International Calling Enabled for user');
                    List<Opportunity> opty = [select Id, AccountId from Opportunity where Id =: recordId];
                    List<Account> acct = [select Id, Country_Code__c, Country__c from Account where Id =: opty[0].AccountId];
                    System.debug('Oportunity::'+opty);
                    System.debug('Customer Ph:'+customerPh);
                    if(acct[0].Country__c != 'United Arab Emirates')  {
                        system.debug('Not UAE Phone Number');
                        if(acct != null && acct.size() > 0){
                            String countryCode = acct.get(0).Country_Code__c;
                            if(countryCode != null && !String.isBlank(countryCode)){
                                if(customerPh != null && ! String.isBlank(customerPh)){
                                    customerPh = customerPh.removeStart('0');
                                }
                               if(countryCode.indexOf('0') != -1){
                                    countryCode = countryCode.removeStart('0');
                                    countryCode = '00' + countryCode;
                                } else if(countryCode.indexOf('+') != -1){
                                    countryCode = countryCode.removeStart('+');
                                    countryCode = '00' + countryCode;
                                } 
                                customerPh = countryCode + customerPh;
                            }
                            System.debug('countryCode::'+countryCode+' customerPh::'+customerPh);
                        }
                    }
                }
                
                
            }
        }
        
        String queryString = 'api_key='+apiKey+'&username='+username+'&agentID='+agentId+'&campaignName='+campaignName+'&customerNumber='+customerPh;       
        String endpoint = 'https://api1.getkookoo.com/CAServices/AgentManualDial.php?'+queryString;
        System.debug('click2call URL:' + endpoint);
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();       
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setMethod('GET');       
        request.setEndPoint(endpoint);
        request.setTimeout(120000);        
        System.Debug('Request:'+request);
        System.Debug('Request:'+request);
        
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
        } else {
            response.setBody('DUMMY');
        }
        System.debug(response.getBody());       
        return (response.getBody());
    }
    
    public class Pair{
        public String key {get; set;}
        public String val {get; set;}
    }
    
}