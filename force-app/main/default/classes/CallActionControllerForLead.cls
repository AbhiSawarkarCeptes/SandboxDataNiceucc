global class CallActionControllerForLead {
    
    public String LeadId{get;set;}
    
    public CallActionControllerForLead (ApexPages.StandardController controller){  
        LeadId = controller.getId();
    }
    
    @RemoteAction
    global static Map<String,String> getPhoneFields(Id leadId) {
        system.debug('inside getphoneFields method'+leadId);
        List<Pair> lstfieldname = new List<Pair>();
        String queryFields;
        String sObjectName;
        Map<String,String> resultsMap = new Map<String,String>();
        // sObject types to describe
        String[] types = new String[]{'Lead'};
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
                system.debug('fieldLabel::'+fieldLabel);
                if(fieldLabel.equalsIgnoreCase('Mobile') || fieldLabel.equalsIgnoreCase('Phone')) {
                    system.debug('Match found');
                    field.key = dfield.getname();
                    system.debug('lstfield key'+field.key );
                    field.val = dfield.getLabel();
                    system.debug('value '+field.val);
                    queryFields += dField.getName() + ',';
                    lstfieldname.add(field);
                    system.debug('lstfieldname'+lstfieldname);
                }                
            }            
        }
        if(queryFields.length() > 0 && queryFields.substring(queryFields.length() -1).equals(','))
            queryFields = queryFields.substring(0,queryFields.length() -1);
        String query = queryFields + ' FROM ' + sObjectName + ' where Id = :leadId';
        System.debug('List Field Names:' + lstFieldName);
        System.debug ('Query :' + query);
        List<sObject> sobjList = Database.query(query);
        
       // Lead l = (Lead)sobjList[0];
     //   System.debug('results: ' + l.Phone);
       // System.debug('results: ' +sobjList[0]);
       // system.debug('mpbile 1'+l.MobilePhone);
      //  system.debug('Alternate mpbile 2'+l.Phone);
        system.debug('lstFieldName'+lstFieldName);
        for(Pair p : lstFieldName) {
            if(sObjList[0].get(p.key) != null) {
                System.debug('Field Name:' + p.val + '==>' + sObjList[0].get(p.key));
                String mobile = string.valueOf(sObjList[0].get(p.key));
                
          //    resultsMap.put(mobile.replace(mobile.substring(0,5),'XXXXX'), string.valueOf(sObjList[0].get(p.key)));
                resultsMap.put(mobile, string.valueOf(sObjList[0].get(p.key)));
            }
        }
        system.debug('results Map'+resultsMap);
        return resultsMap;
    }
    
    @AuraEnabled
    @RemoteAction
    global static String click2CallCloudagent (String recordId) {
        system.debug('Inside click2CallCloudagent method');
    //    system.debug('customerPh from page::: ' + customerPh);
        String campaignName = '';
        String userName = '';
        String apiKey = '';
        String agentId = '';
        String customerPh ='';
   //     System.debug('Incoming Number:' + customerPh);
        system.debug('recordId >> '+recordId);
        
        List<Lead> leads1 = [select Id, Name, RDS_Country__c, RDS_Country_Code__c, MobilePhone from Lead where Id = :recordId];
        
        if((leads1[0].RDS_Country__c == 'United Arab Emirates')){
            system.debug('Inside United Arab Emirates'+leads1[0].Name);
            // if more than 10 digits are being passed, strip of the leading character, keep the last 10 and add 0 to it
           // customerPh = customerPh.substring(customerPh.length() - 10);
            system.debug('customerPh>>>>'+customerPh);
           
           // customerPh = leads1[0].RDS_Country_Code__c +customerPh;
            system.debug('customerPh>>>>'+customerPh);
            if(leads1[0].MobilePhone != Null){
            customerPh = '0'+leads1[0].MobilePhone ;
            }
            System.debug('Customer Phone:' + customerPh);
        } else{  
            system.debug('Inside International');
           
           List<User> userList = [Select Id, Enable_International_Calling__c From User Where Id = :UserInfo.getUserId()];
           system.debug('userList'+userList);
            if(userList != null && userList.size() > 0){
                User usrRec = userList.get(0);
                if(usrRec.Enable_International_Calling__c){ 
                    System.debug('International Calling Enabled for user');
                    List<Lead> leads = [select Id, Name, RDS_Country__c , RDS_Country_Code__c, MobilePhone from Lead where Id =: recordId];
                    System.debug('Leads::'+leads);
                    System.debug('Customer Ph:'+customerPh);
                    if(leads[0].RDS_Country__c != 'United Arab Emirates') {
                        system.debug('Non UAE Phone Number');
                        if(leads != null && leads.size() > 0){
                          if(leads[0].MobilePhone != null){
                           customerPh =leads[0].MobilePhone;
                          }
                            String countryCode = leads.get(0).RDS_Country_Code__c;
                            if(countryCode != null && !String.isBlank(countryCode)){
                                if(customerPh != null && ! String.isBlank(customerPh)){
                                    customerPh = customerPh.removeStart('0');
                                }                                
                                if(countryCode.indexOf('0') != -1){
                                    countryCode = countryCode.removeStart('0');
                                    countryCode = '00' + countryCode;
                                }
                                else if(countryCode.indexOf('+') != -1){                                
                                    countryCode = countryCode.removeStart('+');
                                    countryCode = '00' + countryCode;
                                } 
                                system.debug('customerPh>>>>'+customerPh);
                                system.debug('countryCode  >>>>'+countryCode );
                                
                                customerPh = countryCode + customerPh;
                                system.debug('customerPh>>>>'+customerPh);
                            }
                            System.debug('countryCode::'+countryCode+' customerPh::'+customerPh);
                        }
                    }
                }           
            }
        }
        
        List<User> uList = [Select Id, OzoneTel_AgentId__c, Campaign_name__c, api_key__c, customer__c 
                            From User Where Id = :UserInfo.getUserId()];
        
        if(uList != null && !uList.isEmpty()) {
            campaignName = uList[0].Campaign_name__c;
            agentID = uList[0].OzoneTel_AgentId__c;
            apiKey = uList[0].api_key__c; 
            userName = uList[0].customer__c;
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
        System.Debug('Request:'+request);
        request.setTimeout(120000);  
     
        
        
        HttpResponse response = new HttpResponse();
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
        } else {
            response.setBody('DUMMY');
        }
        System.debug(response.getBody());
        string tempResponse = response.getBody() + '- called customer ' ;
        return (tempResponse); 
    }
       
    public class Pair{
        public String key {get; set;}
        public String val {get; set;}
    }   
}